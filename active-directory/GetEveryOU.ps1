<#
.SYNOPSIS
     Get every OU in the domain
.NOTES
     Author: Cody Wellman <cody@codexmicro.systems>
#>

Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-Table Name, DistinguishedName -A