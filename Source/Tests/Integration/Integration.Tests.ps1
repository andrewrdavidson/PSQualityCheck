Describe "Integration Tests" {

    # Use the files in the TestFiles folder to do complete runs and then check the output

    Context "HelpRules tests" {

        ## Should validate the rules in the HelpElementsRules.psd1

        # Help Element Rule should have 4 properties, Key [string], Required [bool], MinOccurrences [int] and MaxOccurrences [int]
        # '1' = @{
        #     Key = '.SYNOPSIS'
        #     Required = $true
        #     MinOccurrences = 1
        #     MaxOccurrences = 1
        # }

        # Help Element rule should match if required

        # Help Element rule should match if not required

        # Help Element rule should not fail if not required

        # Help Element rule should be greater (or equal) than MinOccurrences and less than (or equal) to MaxOccurrences



    }

}
