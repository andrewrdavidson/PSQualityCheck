@{
    # HashTable of the keys that you want in your help comments
    # If the test finds an element that does not appear in this list then the test will fail

    # Possible key elements
    # '.SYNOPSIS'
    # '.DESCRIPTION'
    # '.PARAMETER'
    # '.EXAMPLE'
    # '.INPUTS'
    # '.OUTPUTS'
    # '.NOTES'
    # '.LINK'
    # '.COMPONENT'
    # '.ROLE'
    # '.FUNCTIONALITY'
    # '.FORWARDHELPTARGETNAME'
    # '.FORWARDHELPCATEGORY'
    # '.REMOTEHELPRUNSPACE'
    # '.EXTERNALHELP'

    # If a key is required then it must exist, and have between MinOccurrences and MaxOccurrences count
    # The keys will be matched in the numerical sequence below
    '1' = @{
        Key = '.SYNOPSIS'
        Required = $true
        MinOccurrences = 1
        MaxOccurrences = 1
    }
    '2' = @{
        Key = '.DESCRIPTION'
        Required = $true
        MinOccurrences = 1
        MaxOccurrences = 1
    }
    '3' = @{
        Key = '.PARAMETER'
        Required = $false
        MinOccurrences = 0
        MaxOccurrences = 0
    }
    '4' = @{
        Key = '.EXAMPLE'
        Required = $true
        MinOccurrences = 1
        MaxOccurrences = 100
        # MaxOccurrences = 1
    }
    '5' = @{
        Key = '.INPUTS'
        Required = $false
        MinOccurrences = 0
        MaxOccurrences = 0
    }
    '6' = @{
        Key = '.OUTPUTS'
        Required = $false
        MinOccurrences = 0
        MaxOccurrences = 0
    }
    '7' = @{
        Key = '.NOTES'
        Required = $false
        MinOccurrences = 0
        MaxOccurrences = 0
    }
    '8' = @{
        Key = '.LINK'
        Required = $false
        MinOccurrences = 0
        MaxOccurrences = 0
    }
}
