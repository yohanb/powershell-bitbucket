if (Get-Module Bitbucket) { return }

$currentWorkingFolder = Get-Location

Push-Location $PSScriptRoot

. .\OAuth.ps1

Export-ModuleMember `
    -Function @('Get-BitbucketAccessToken', 'Login-BitbucketAccount')

Push-Location $currentWorkingFolder