
$UserstoFill = $null


$WholeCompanyOU = 'OU=XYZ Company,DC=xyz,DC=local'
$AllUsersComputersOU = 'OU=Users and Computers,OU=XYZ Company,DC=xyz,DC=local'
$AdminOU = 'OU=Administration,OU=Users and Computers,OU=XYZ Company,DC=xyz,DC=local'
$EngineeringOU = 'OU=Engineering,OU=Users and Computers,OU=XYZ Company,DC=xyz,DC=local'
$MarketingOU = 'OU=Marketing,OU=Users and Computers,OU=XYZ Company,DC=xyz,DC=local'



$UserstoFill = @(Get-ADUser -SearchBase $MarketingOU -filter *)

Add-ADGroupMember -Identity "Marketing" -Members $UserstoFill
