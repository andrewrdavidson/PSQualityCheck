function GetTagList {
    <#
        .SYNOPSIS
        Return a list of test tags

        .DESCRIPTION
        Return a list of test tags from the module and script checks file

        .EXAMPLE
        ($moduleTags, $scriptTags) = GetTagList

    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
    )

    $moduleTags = @()
    $scriptTags = @()

    $modulePath = (Get-Module -Name 'PSQualityCheck').ModuleBase

    $checksPath = (Join-Path -Path $modulePath -ChildPath "data")

    Get-Content -Path (Join-Path -Path $checksPath -ChildPath "Module.Tests.ps1") -Raw | ForEach-Object {
        $ast = [Management.Automation.Language.Parser]::ParseInput($_, [ref]$null, [ref]$null)
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "Describe" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $moduleTags += $_.CommandElements[3].Value
        }
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "It" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $moduleTags += $_.CommandElements[3].Value
        }
    }

    Get-Content -Path (Join-Path -Path $checksPath -ChildPath "Script.Tests.ps1") -Raw | ForEach-Object {
        $ast = [Management.Automation.Language.Parser]::ParseInput($_, [ref]$null, [ref]$null)
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "Describe" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $scriptTags += $_.CommandElements[3].Value
        }
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "It" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $scriptTags += $_.CommandElements[3].Value
        }
    }

    return $moduleTags, $scriptTags

}
