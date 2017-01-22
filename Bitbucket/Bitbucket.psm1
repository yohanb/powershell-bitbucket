if (Get-Module Bitbucket) { return }

$currentWorkingFolder = Get-Location

Push-Location $PSScriptRoot

. .\OAuth.ps1

Export-ModuleMember `
    -Function @('Get-BitbucketAccessToken')

Push-Location $currentWorkingFolder