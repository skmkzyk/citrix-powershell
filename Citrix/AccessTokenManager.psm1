# AccessTokenManager.psm1

class AccessToken {
    [string]$Token
    [datetime]$Expiry
}

function Get-CitrixAccessToken {
    # throw error if CLIENT_ID, CLIENT_SECRET or CUSTOMER_ID is not set
    if (-not $Env:CLIENT_ID -or -not $Env:CLIENT_SECRET-or -not $Env:CUSTOMER_ID) {
        throw "CLIENT_ID, CLIENT_SECRET and CUSTOMER_ID must be set in the environment"
    }

    $currentToken = Get-CurrentAccessToken

    if ($null -eq $currentToken -or $currentToken.Expiry -le (Get-Date)) {
        # URL for the token endpoint
        $url = "https://api-us.cloud.com/cctrustoauth2/$Env:CUSTOMER_ID/tokens/clients"

        # define the headers
        $headers = @{
            "Accept"       = "application/json"
            "Content-Type" = "application/x-www-form-urlencoded"
        }

        # define the body
        $body = @{
            "grant_type"    = "client_credentials"
            "client_id"     = $Env:CLIENT_ID
            "client_secret" = $Env:CLIENT_SECRET
        }

        # send the POST request to get the token
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body

        # store the token in a variable
        $newToken = $response.access_token
        $expiry = (Get-Date).AddHours(1)

        $currentToken = [AccessToken]@{
            Token = $newToken
            Expiry = $expiry
        }

        Set-CurrentAccessToken -AccessToken $currentToken
    }

    return $currentToken.Token
}

function Set-CurrentAccessToken {
    param([AccessToken]$AccessToken)

    $script:currentAccessToken = $AccessToken
}

function Get-CurrentAccessToken {
    return $script:currentAccessToken
}

Export-ModuleMember -Function 'Get-CitrixAccessToken'
