<#
.SYNOPSIS
     Get every OU in the domain
.NOTES
     Author: Cody Wellman <cody.wellman@emp-corp.net>
#>

Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-Table Name, DistinguishedName -A