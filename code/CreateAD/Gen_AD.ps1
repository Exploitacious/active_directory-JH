# Create an Active Directory Domain Structure for home lab environment
# Inspired by many, including John Hammond.
# Created by Alex Ivantsov

# Set Global Variables

$Path = "$PSScriptroot\Data\"     # Data Location

$Domain = "xyz.local"
$DNSDomain = "xyz.com"
$CompanyName = "XYZ Co"
$ou = "OU=Users and Computers,OU=XYZ Company,DC=xyz,DC=local"


$UserCount = 1


$first_names = [System.Collections.ArrayList](Get-Content "$path/firstnames.txt")
$last_names = [System.Collections.ArrayList](Get-Content "$path/lastnames.txt")
$passwords = [System.Collections.ArrayList](Get-Content "$path/passwords.txt")


$userdetails = @()


# Generate Users
for ( $i = 1; $i -le $UserCount; $i++ ) {
    $first_name = (Get-Random -InputObject $first_names)
    $last_name = (Get-Random -InputObject $last_names)
    $password = (Get-Random -InputObject $passwords)
    $accountName = ($first_name[0] + $last_name).ToLower()


    # Set User Params 
    $new_user = @{
        "Enabled"           = $True
        "name"              = "$first_name $last_name"
        "password"          = "$password"
        "Company Name"      = "$CompanyName"
        "SamAccountName"    = "$accountName"
        "UserPrincipalName" = "$accountName@$Domain"
        "Email"             = "$accountName@$DNSDomain"
        "Path"              = "$ou"
    }

    $userdetails += $new_user

    $first_names.Remove($first_name)
    $last_names.Remove($last_name)
    $passwords.Remove($password)
}

ConvertTo-Json -InputObject @{ 
    "domain" = "xyz.com"
    "users"  = $userdetails
} | Out-File $path\ad_schema.json


