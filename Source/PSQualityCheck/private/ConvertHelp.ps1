function ConvertHelp {
    <#
        .SYNOPSIS
        Convert the help comment into an object

        .DESCRIPTION
        Convert the help comment into an object containing all the elements from the help comment

        .PARAMETER Help
        A string containing the Help Comment

        .EXAMPLE
        $helpObject = ConvertHelp -Help $Help
    #>
    [CmdletBinding()]
    [OutputType([HashTable], [System.Exception])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Help
    )

    # These are the possible Help Comment elements that the script will look for
    # .SYNOPSIS
    # .DESCRIPTION
    # .PARAMETER
    # .EXAMPLE
    # .INPUTS
    # .OUTPUTS
    # .NOTES
    # .LINK
    # .COMPONENT
    # .ROLE
    # .FUNCTIONALITY
    # .FORWARDHELPTARGETNAME
    # .FORWARDHELPCATEGORY
    # .REMOTEHELPRUNSPACE
    # .EXTERNALHELP

    # This function will go through the help and work out which elements are where and what text they contain

    try {

        if (-not(
                $Help.StartsWith("<#") -and
                $Help.EndsWith("#>")
            )) {
            throw "Help does not appear to be a comment block"
        }

        $helpElementsToFind =
        '.SYNOPSIS',
        '.DESCRIPTION',
        '.PARAMETER',
        '.EXAMPLE',
        '.INPUTS',
        '.OUTPUTS',
        '.NOTES',
        '.LINK',
        '.COMPONENT',
        '.ROLE',
        '.FUNCTIONALITY',
        '.FORWARDHELPTARGETNAME',
        '.FORWARDHELPCATEGORY',
        '.REMOTEHELPRUNSPACE',
        '.EXTERNALHELP'

        $commentArray = ($Help -split '\n').Trim()

        $foundElements = @{}
        $numFound = 0
        $lastHelpElement = $null

        for ($line = 0; $line -lt $commentArray.Count; $line++) {

            # get the first 'word' of the help comment. This is required so that we can
            # match '.PARAMETER' since it has a parameter name after it
            $helpElementKey = ($commentArray[$line] -split " ")[0]

            # Get the value of the Help Comment (the parameter name)
            try {
                $helpElementName = ($commentArray[$line] -split " ")[1]
            }
            catch {
                $helpElementName = ""
            }

            if ($helpElementsToFind -contains $helpElementKey) {

                $numFound++

                if ($numFound -ge 2) {

                    # if it's the second element then we must set the help comment text of the
                    # previous element to the found text so far, then reset it

                    $lastElement = @($foundElements[$lastHelpElement])
                    $lastElement[$lastElement.Count - 1].Text = $helpData
                    $foundElements[$lastHelpElement] = $lastElement

                    $helpData = $null
                }

                # this should be an array of HashTables
                # each hash table will contain the properties LineNumber, Name & Text
                $currentElement = @($foundElements[$helpElementKey])

                $newElement = @{}
                $newElement.LineNumber = $line
                $newElement.Name = $helpElementName
                $newElement.Text = ""

                if ($null -eq $currentElement[0]) {
                    $currentElement = $newElement
                }
                else {
                    $currentElement += $newElement
                }

                $foundElements[$helpElementKey] = $currentElement

                $lastHelpElement = $helpElementKey

            }
            else {

                if ($numFound -ge 1 -and $line -lt ($commentArray.Count - 1)) {
                    $helpData += $commentArray[$line]
                }

            }

        }

        if ( -not ([string]::IsNullOrEmpty($lastHelpElement))) {
            $currentElement = @($foundElements[$lastHelpElement])
            $currentElement[$currentElement.Count - 1].Text = $helpData
            $foundElements[$lastHelpElement] = $currentElement
        }

        return $foundElements

    }
    catch {

        throw $_.Exception.Message

    }

}
