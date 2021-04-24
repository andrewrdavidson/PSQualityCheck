param(
    [parameter(Mandatory = $true)]
    [string]$Path
)

BeforeDiscovery {

    $scriptsPath = Join-Path -Path $Path -ChildPath "Scripts"
    $sourcePath = Join-Path -Path $Path -ChildPath "Source"
    $testPath = Join-Path -Path $Path -ChildPath "Tests"
    $unitTestPath = Join-Path -Path $testPath -ChildPath "Unit"
    $integrationTestPath = Join-Path -Path $testPath -ChildPath "Integration"

    $moduleList = Get-ChildItem -Path $sourcePath -Directory | Select-Object -Property Name

    $moduleData = @()

    foreach ($module in $moduleList) {

        $moduleFolder = Join-Path -Path $sourcePath -ChildPath $module.Name
        $privateFolder = Join-Path -Path $moduleFolder -ChildPath "Private"
        $publicFolder = Join-Path -Path $moduleFolder -ChildPath "Public"
        $unitTestFolder = Join-Path -Path $unitTestPath -ChildPath $module.Name
        $integrationTestFolder = Join-Path -Path $integrationTestPath -ChildPath $module.Name

        $privateModules = Get-ChildItem -Path $privateFolder | Select-Object -Property Name, BaseName, FullName
        $publicModules = Get-ChildItem -Path $publicFolder | Select-Object -Property Name, BaseName, FullName

        $moduleData += @{
            'Name'                  = $module.Name
            'Path'                  = $moduleFolder
            'PublicFolder'          = $publicFolder
            'PrivateFolder'         = $privateFolder
            'UnitTestFolder'        = $unitTestFolder
            'IntegrationTestFolder' = $integrationTestFolder
            'Public'                = $publicModules
            'Private'               = $privateModules
        }
    }

}

Describe "Project Test" -Tag "Project" {

    Context "Checking fixed folder structure" {

        It "should contain <_> folder" -Foreach @($sourcePath, $TestPath, $unitTestPath, $scriptsPath, $integrationTestPath) {

            $_ | Should -Exist

        }

    }

    Context "checking module <_.Name>" -Foreach $moduleData {

        BeforeAll {

            $approvedVerbs = Get-Verb | Select-Object -Property Verb

        }

        It "Private folder exists" {

            $_.PrivateFolder | Should -Exist

        }

        It "Public folder exists" {

            $_.PublicFolder | Should -Exist

        }

        It "Unit Test folder exists" {

            $_.UnitTestFolder | Should -Exist

        }

        Context "Checking Public Script <_.Name>" -ForEach $_.Public {

            It "public script has a unit test" {

                $testFileName = "{0}{1}" -f $_.BaseName, ".Tests.ps1"
                $TestScript = Join-Path -Path $unitTestFolder -ChildPath $testFileName
                $TestScript | Should -Exist

            }

            It "public script has a valid verb-noun format" {

                ($verb, $noun) = $_.Name -Split "-"

                $verb | Should -Not -BeNullOrEmpty
                $noun | Should -Not -BeNullOrEmpty

                $approvedVerbs.Verb -contains $verb | Should -BeTrue

            }

        }

        Context "Checking Private Script <_.Name>" -ForEach $_.Private {

            It "private script has a valid format" {

                $Script = $_.Name

                $Script | Should -Not -Match "-"

            }

        }

    }

}
