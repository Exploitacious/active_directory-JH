
$Path = "$PSScriptroot\Data\"     # Data Location

$json = ( Get-Content $Path\ad_schema.json | ConvertFrom-JSON)


foreach ( $user in $json.users ) {
    CreateADUser $user
}


function CreateADUser() {
    param( [Parameter(Mandatory = $true)] $userObject )

    # Pull out the name from the JSON object
    $name = $userObject.name
    $password = $userObject.password

    # Generate a "first initial, last name" structure for username
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()
    $samAccountName = $username
    $principalname = $username

    # Actually create the AD user object
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

}