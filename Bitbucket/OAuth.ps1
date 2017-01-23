<#
.Synopsis
   Login to your Bitbucket account for use with other commands.
.DESCRIPTION
   Logs in to your Bitbucket account and stores it in your current PowerShell session for later use.
.EXAMPLE
   Login-BitbucketAccount
.EXAMPLE
   Login-BitbucketAccount -Credential $credential
#>
function Login-BitbucketAccount() {
    Param(
        [Parameter()]
        [PSCredential]$Credential
    )

    if ($Credential) {
        $global:BitbucketCredential = $Credential
    } else {
        if(!(Test-Path Variable::global:BitbucketCredential) -or ($global:BitbucketCredential -isnot [PSCredential])) {
            $global:BitbucketCredential = Get-Credential -Message "Enter your Bitbucket email and password."
        }
    }
}

<#
.Synopsis
   Gets an OAuth2 access token for use with the Bitbucket API.
.DESCRIPTION
   This script uses the 'Resource Owner Password Credentials Grant' OAuth2 flow to acquire an access token for the specified consumer.
.EXAMPLE
   Get-BitbucketAccessToken -ConsumerKey abcd1234 -ConsumerSecret $consumerSecret
.EXAMPLE
   ConvertTo-SecureString "abcd1234abcd1234" -AsPlainText -Force | Get-BitbucketAccessToken -ConsumerKey abcd1234
#>
function Get-BitbucketAccessToken() {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ConsumerKey,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Security.SecureString]$ConsumerSecret,

        [Parameter()]
        [string]$AccessTokenEndpointUrl = "https://bitbucket.org/site/oauth2/access_token"
    )

    # Login if not already done
    Login-BitbucketAccount

    # Construct BitBucket request
    # For more information, see the "Resource Owner Password Credentials Grant" section here:
    # https://developer.atlassian.com/bitbucket/concepts/oauth2.html
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes((
                "{0}:{1}" -f $ConsumerKey, `
        [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConsumerSecret)))))
        
    $requestBody = @{
        grant_type = 'password'
        username = $global:BitbucketCredential.UserName
        password = $global:BitbucketCredential.GetNetworkCredential().Password 
    }

    # Perform the request to Bitbucket OAuth2.0
    return Invoke-RestMethod -Uri $accessTokenEndpointUrl -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo) } -Method Post -Body $requestBody
}