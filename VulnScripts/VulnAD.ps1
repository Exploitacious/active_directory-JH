#Base Lists 
$Global:HighGroups = @('Information Technology', 'Executives', 'Human Resources');
$Global:MidGroups = @('Accounting', 'Administration', 'Management');
$Global:NormalGroups = @('Engineering', 'Developer', 'Quality Assurance', 'Researcher', 'Marketing', 'Sales', 'Customer Relations');
$Global:BadACL = @('GenericAll', 'GenericWrite', 'WriteOwner', 'WriteDACL', 'Self', 'WriteProperty');
$Global:ServicesAccountsAndSPNs = @('mssql_svc,mssqlserver', 'http_svc,httpserver', 'exchange_svc,exserver');
$Global:CreatedUsers = @(Get-ADUser -Filter *)
$Global:AllObjects = @(Get-ADGroup -Filter *)
$Global:Domain = "xyz.local"
$DataPath = "$PSScriptRoot\data\"
$passwordsFile = "$DataPath\Passwords.txt"
$passwords = gc $passwordsFile


# Strings 
$Global:Spacing = "`t"
$Global:PlusLine = "`t[+]"
$Global:ErrorLine = "`t[-]"
$Global:InfoLine = "`t[*]"
function Write-Good { param( $String ) Write-Host $Global:PlusLine  $String -ForegroundColor 'Green' }
function Write-Bad { param( $String ) Write-Host $Global:ErrorLine $String -ForegroundColor 'red' }
function Write-Info { param( $String ) Write-Host $Global:InfoLine $String -ForegroundColor 'gray' }
function ShowBanner {
    $banner = @()
    $banner += $Global:Spacing + ''
    $banner += $Global:Spacing + 'VULN AD - Vulnerable Active Directory'
    $banner += $Global:Spacing + ''                                                  
    $banner += $Global:Spacing + 'By wazehell @safe_buffer'
    $banner += $Global:Spacing + 'Modified by Alex Ivantsov'
    $banner += $Global:Spacing + ''  

    $banner | ForEach-Object {
        Write-Host $_ -ForegroundColor (Get-Random -Input @('Green', 'Cyan', 'Yellow', 'gray', 'white'))
    }                             
}
function VulnAD-GetRandom {
    Param(
        [array]$InputList
    )
    return Get-Random -InputObject $InputList
}
function VulnAD-AddACL {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Security.Principal.IdentityReference]$Source,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Rights

    )
    $ADObject = [ADSI]("LDAP://" + $Destination)
    $identity = $Source
    $adRights = [System.DirectoryServices.ActiveDirectoryRights]$Rights
    $type = [System.Security.AccessControl.AccessControlType] "Allow"
    $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
    $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $identity, $adRights, $type, $inheritanceType
    $ADObject.psbase.ObjectSecurity.AddAccessRule($ACE)
    $ADObject.psbase.commitchanges()
}
function VulnAD-BadAcls {
    foreach ($abuse in $Global:BadACL) {
        $ngroup = VulnAD-GetRandom -InputList $Global:NormalGroups
        $mgroup = VulnAD-GetRandom -InputList $Global:MidGroups
        $DstGroup = Get-ADGroup -Identity $mgroup
        $SrcGroup = Get-ADGroup -Identity $ngroup
        VulnAD-AddACL -Source $SrcGroup.sid -Destination $DstGroup.DistinguishedName -Rights $abuse
        Write-Info "BadACL $abuse $ngroup to $mgroup"
    }
    foreach ($abuse in $Global:BadACL) {
        $hgroup = VulnAD-GetRandom -InputList $Global:HighGroups
        $mgroup = VulnAD-GetRandom -InputList $Global:MidGroups
        $DstGroup = Get-ADGroup -Identity $hgroup
        $SrcGroup = Get-ADGroup -Identity $mgroup
        VulnAD-AddACL -Source $SrcGroup.sid -Destination $DstGroup.DistinguishedName -Rights $abuse
        Write-Info "BadACL $abuse $mgroup to $hgroup"
    }
    for ($i = 1; $i -le (Get-Random -Maximum 25); $i = $i + 1 ) {
        $abuse = (VulnAD-GetRandom -InputList $Global:BadACL);
        $randomuser = VulnAD-GetRandom -InputList $Global:CreatedUsers
        $randomgroup = VulnAD-GetRandom -InputList $Global:AllObjects
        if ((Get-Random -Maximum 2)) {
            $Dstobj = Get-ADUser -Identity $randomuser
            $Srcobj = Get-ADGroup -Identity $randomgroup
        }
        else {
            $Srcobj = Get-ADUser -Identity $randomuser
            $Dstobj = Get-ADGroup -Identity $randomgroup
        }
        VulnAD-AddACL -Source $Srcobj.sid -Destination $Dstobj.DistinguishedName -Rights $abuse 
        Write-Info "BadACL $abuse $randomuser and $randomgroup"
    }
}
function VulnAD-Kerberoasting {
    $selected_service = (VulnAD-GetRandom -InputList $Global:ServicesAccountsAndSPNs)
    $svc = $selected_service.split(',')[0];
    $spn = $selected_service.split(',')[1];
    $Password = Get-Random $passwords;
    Write-Info "Kerberoasting $svc $spn"
    Try { New-ADServiceAccount -Name $svc -ServicePrincipalNames "$svc/$spn.$Global:Domain" -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -RestrictToSingleComputer -PassThru } Catch {}
    foreach ($sv in $Global:ServicesAccountsAndSPNs) {
        if ($selected_service -ne $sv) {
            $svc = $sv.split(',')[0];
            $spn = $sv.split(',')[1];
            Write-Info "Creating $svc services account"
            $password = Get-Random $passwords
            Try { New-ADServiceAccount -Name $svc -ServicePrincipalNames "$svc/$spn.$Global:Domain" -RestrictToSingleComputer -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru } Catch {}

        }
    }
}
function VulnAD-ASREPRoasting {
    for ($i = 1; $i -le (Get-Random -Maximum 6); $i = $i + 1 ) {
        $randomuser = (VulnAD-GetRandom -InputList $Global:CreatedUsers)
        $Password = Get-Random $passwords;
        Set-ADAccountPassword -Identity $randomuser -Reset -NewPassword (ConvertTo-SecureString $password -AsPlainText -Force)
        Set-ADAccountControl -Identity $randomuser -DoesNotRequirePreAuth 1
        Write-Info "AS-REPRoasting $randomuser"
    }
}
function VulnAD-DnsAdmins {
    for ($i = 1; $i -le (Get-Random -Maximum 6); $i = $i + 1 ) {
        $randomuser = (VulnAD-GetRandom -InputList $Global:CreatedUsers)
        Add-ADGroupMember -Identity "DnsAdmins" -Members $randomuser
        Write-Info "DnsAdmins : $randomuser"
    }
    $randomg = (VulnAD-GetRandom -InputList $Global:MidGroups)
    Add-ADGroupMember -Identity "DnsAdmins" -Members $randomg
    Write-Info "DnsAdmins Nested Group : $randomg"
}
function VulnAD-PwdInObjectDescription {
    for ($i = 1; $i -le (Get-Random -Maximum 6); $i = $i + 1 ) {
        $randomuser = (VulnAD-GetRandom -InputList $Global:CreatedUsers)
        $password = Get-Random $passwords
        Set-ADAccountPassword -Identity $randomuser -Reset -NewPassword (ConvertTo-SecureString $password -AsPlainText -Force)
        Set-ADUser $randomuser -Description "User Password $password"
        Write-Info "Password in Description : $randomuser"
    }
}
function VulnAD-DefaultPassword {
    for ($i = 1; $i -le (Get-Random -Maximum 5); $i = $i + 1 ) {
        $randomuser = (VulnAD-GetRandom -InputList $Global:CreatedUsers)
        $password = "Changeme123!";
        Set-ADAccountPassword -Identity $randomuser -Reset -NewPassword (ConvertTo-SecureString $password -AsPlainText -Force)
        Set-ADUser $randomuser -Description "New User ,DefaultPassword"
        Set-ADUser $randomuser -ChangePasswordAtLogon $true
        Write-Info "Default Password : $randomuser"
    }
}
function VulnAD-PasswordSpraying {
    $same_password = "ncc1701";
    for ($i = 1; $i -le (Get-Random -Maximum 12); $i = $i + 1 ) {
        $randomuser = (VulnAD-GetRandom -InputList $Global:CreatedUsers)
        Set-ADAccountPassword -Identity $randomuser -Reset -NewPassword (ConvertTo-SecureString $same_password -AsPlainText -Force)
        Set-ADUser $randomuser -Description "Shared User"
        Write-Info "Same Password (Password Spraying) : $randomuser"
    }
}
function VulnAD-DCSync {
    for ($i = 1; $i -le (Get-Random -Maximum 6); $i = $i + 1 ) {
        $ADObject = [ADSI]("LDAP://" + (Get-ADDomain "XYZ.local").DistinguishedName)
        $randomuser = (VulnAD-GetRandom -InputList $Global:CreatedUsers)
        $sid = (Get-ADUser -Identity $randomuser).sid

        $objectGuidGetChanges = New-Object Guid 1131f6aa-9c07-11d1-f79f-00c04fc2dcd2
        $ACEGetChanges = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid, 'ExtendedRight', 'Allow', $objectGuidGetChanges)
        $ADObject.psbase.Get_objectsecurity().AddAccessRule($ACEGetChanges)

        $objectGuidGetChanges = New-Object Guid 1131f6ad-9c07-11d1-f79f-00c04fc2dcd2
        $ACEGetChanges = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid, 'ExtendedRight', 'Allow', $objectGuidGetChanges)
        $ADObject.psbase.Get_objectsecurity().AddAccessRule($ACEGetChanges)

        $objectGuidGetChanges = New-Object Guid 89e95b76-444d-4c62-991a-0facbeda640c
        $ACEGetChanges = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid, 'ExtendedRight', 'Allow', $objectGuidGetChanges)
        $ADObject.psbase.Get_objectsecurity().AddAccessRule($ACEGetChanges)
        $ADObject.psbase.CommitChanges()

        Set-ADUser $randomuser -Description "Replication Account"
        Write-Info "Giving DCSync to : $randomuser"
    }
}
function VulnAD-DisableSMBSigning {
    Set-SmbClientConfiguration -RequireSecuritySignature 0 -EnableSecuritySignature 0 -Confirm -Force
}





ShowBanner
$Global:Domain = $DomainName

VulnAD-BadAcls
Write-Good "BadACL Done"
VulnAD-Kerberoasting
Write-Good "Kerberoasting Done"
VulnAD-ASREPRoasting
Write-Good "AS-REPRoasting Done"
VulnAD-DnsAdmins
Write-Good "DnsAdmins Done"
VulnAD-PwdInObjectDescription
Write-Good "Password In Object Description Done"
VulnAD-DefaultPassword
Write-Good "Default Password Done"
VulnAD-PasswordSpraying
Write-Good "Password Spraying Done"
VulnAD-DCSync
Write-Good "DCSync Done"
# VulnAD-DisableSMBSigning
# Write-Good "SMB Signing Disabled"
