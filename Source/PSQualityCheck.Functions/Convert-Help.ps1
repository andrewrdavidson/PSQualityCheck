function Convert-Help {
    <#
        .SYNOPSIS
        Convert the help comment into an object

        .DESCRIPTION
        Convert the help comment into an object containing all the elements from the help comment

        .PARAMETER HelpComment
        A string containing the Help Comment

        .EXAMPLE
        $helpObject = Convert-Help -HelpComment $helpComment
    #>
    [CmdletBinding()]
    [OutputType([HashTable], [System.Exception])]
    param (
        [parameter(Mandatory = $true)]
        [string]$HelpComment
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
                $HelpComment.StartsWith("<#") -and
                $HelpComment.EndsWith("#>")
            )) {
            throw "Help does not appear to be a comment block"
        }

        # an array of string help elements to look for
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

        # Split the single comment string into it's line components
        $commentArray = ($HelpComment -split '\n').Trim()

        # initialise an empty HashTable ready for the found help elements to be stored
        $foundElements = @{}
        $numFound = 0
        $lastHelpElement = $null

        # loop through all the 'lines' of the help comment
        for ($line = 0; $line -lt $commentArray.Count; $line++) {

            # get the first 'word' of the help comment. This is required so that we can
            # match '.PARAMETER' since it has a parameter name after it
            $helpElementName = ($commentArray[$line] -split " ")[0]

            # see whether the $helpElements array contains the first 'word'
            if ($helpElementsToFind -contains $helpElementName) {

                $numFound++

                if ($numFound -ge 2) {

                    # of it's the second element then we must set the help comment text of the
                    # previous element to the found text so far, then reset it

                    $lastElement = @($foundElements[$lastHelpElement])
                    $lastElement[$lastElement.Count - 1].Text = $help
                    $foundElements[$lastHelpElement] = $lastElement

                    $help = $null
                }

                # this should be an array of HashTables {LineNumber, Name & Text}
                $currentElement = @($foundElements[$helpElementName])

                $newElement = @{}
                $newElement.LineNumber = $line
                $newElement.Name = ($commentArray[$line] -split " ")[1]
                $newElement.Text = ""

                if ($null -eq $currentElement[0]) {

                    $currentElement = $newElement

                }
                else {
                    $currentElement += $newElement
                }

                # update the foundItems HashTable with the new found element
                $foundElements[$helpElementName] = $currentElement

                $lastHelpElement = $helpElementName

            }
            else {

                if ($numFound -ge 1 -and $line -lt ($commentArray.Count - 1)) {

                    $help += $commentArray[$line]

                }

            }

        }

        if ( -not ([string]::IsNullOrEmpty($lastHelpElement))) {
            # process the very last one
            $currentElement = @($foundElements[$lastHelpElement])
            $currentElement[$currentElement.Count - 1].Text = $help
            $foundElements[$lastHelpElement] = $currentElement
        }

        return $foundElements

    }
    catch {

        throw $_.Exception.Message

    }

}
