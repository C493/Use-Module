Function Use-Module {
    <#
    .SYNOPSIS
        Check for, and if required, install and/or import specified module(s) for use.

    .DESCRIPTION
        If modules are already installed and imported, no action is taken.
        If modules are already installed but not imported, they are simply imported for use.

        **Note:** Modules are installed and imported using the currentuser/local scope.

        Supports specifying multiple module names via parameter or pipeline input.
        Multiple module names specified by parameter should be comma separated.
        If module names contains spaces, the name should be wrapped in quotes (e.g "Module Name").

    .NOTES
        Author  :   Patrick Cage (patrick@patrickcage.com)
        Version :   1.0.0 (2022-09-28)
		License :   GNU General Public License (GPL) v3

    .PARAMETER ModuleName
        <string[]> The name(s) of module(s) to be installed and/or imported for use.

    .EXAMPLE
        Use-Module "Module One"

    .EXAMPLE
        Use-Module -ModuleName "Module One"

    .EXAMPLE
        Use-Module "Module One", "Mondule Two", "Module Three"

    .EXAMPLE
        Use-Module -ModuleName "Module One", "Module Two", "Module Three"

    .LINK
        https://www.patrickcage.com/use-module

    .LINK
        https://github.com/C493/use-module

---

If this has helped you, please consider [buying me a coffee](https://www.buymeacoffee.com/patrickcage)
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,
        HelpMessage="The name of the module you want to use")]
        [string[]] $ModuleName
    )

    Begin {

        Function Invoke-ImportModule {
            [CmdletBinding()]
            Param(
                [Parameter(Mandatory,Position = 0,ValueFromPipeline,
                HelpMessage="The name of the Module to be imported")]
                [string] $ModuleName
            )

            Write-Host -ForegroundColor Yellow "Importing Module `"$($ModuleName)`"..."

            Try {
                Import-Module -Name $ModuleName -Scope Local -Force -ErrorAction Stop -WarningAction SilentlyContinue
                Write-Host -ForegroundColor Green "Module `"$($ModuleName)`" imported successfully"
                Try { Write-ToLog -Tag "Use-Module" -Message "Module `"$($ModuleName)`" imported successfully" }
                Catch { Write-Verbose -Message "[Use-Module] Module `"$($ModuleName)`" imported successfully" }
            }
            Catch {
                Try { Write-ToLog -Severity ERROR -Tag "$($MyInvocation.MyCommand.Name)" -Message "Unable to import module" }
                Catch { Write-Warning -Message "[Use-Module] Unable to import module `"$($ModuleName)`"" }
                Throw "Unable to import module `"$($ModuleName)`""
            }
        }

        Function Invoke-InstallPackageProvider {
            [CmdletBinding()]
            Param(
                [Parameter(Mandatory,Position=0,ValueFromPipeline,
                HelpMessage="The name of the Package Provider to be installed")]
                [string] $PackageProviderName
            )

            Write-Host -ForegroundColor Yellow "Installing Package Provider `"$($PackageProviderName)`"..."

            Try {
                Install-PackageProvider -Name $PackageProviderName -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
                Try { Write-ToLog -Tag "Use-Module" -Message "Package Provider `"$($PackageProviderName)`" installed successfully" }
                Catch { Write-Verbose -Message "[Use-Module] Package Provider `"$($PackageProviderName)`" installed successfully" }
                Write-Host -ForegroundColor Green "Package Provider `"$($PackageProviderName)`" installed successfully"
            }
            Catch [System.Exception] {
                Try { Write-ToLog -Severity ERROR -Tag "Use-Module" -Message "A Package Provider with the Name `"$($PackageProviderName)`" could not be found" }
                Catch { Write-Warning -Message "[Use-Module] A Package Provider with the Name `"$($PackageProviderName)`" could not be found" }
                Throw "A Package Provider with the Name `"$($PackageProviderName)`" could not be found"
            }
            Catch {
                Try { Write-ToLog -Severity ERROR -Tag "Use-Module" -Message "Failed to install Package Provider `"$($PackageProviderName)`"" }
                Catch { Write-Warning -Message "[Use-Module] Failed to install Package Provider `"$($PackageProviderName)`"" }
                Throw "Failed to install Package Provider `"$($PackageProviderName)`""
            }
        }

        Function Invoke-InstallModule {
            [CmdletBinding()]
            Param(
                [Parameter(Mandatory,Position=0,ValueFromPipeline,
                HelpMessage="The name of the Module to be installed")]
                [string] $ModuleName
            )

            If (Find-Module -Name $ModuleName -ErrorAction SilentlyContinue) {

                Write-Host -ForegroundColor Yellow "Installing Module `"$($ModuleName)`"..."

                Try {
                    Install-Module -Name $ModuleName -Scope CurrentUser -Force -ErrorAction Stop
                    # Check if install was successful
                    If (Get-Module -ListAvailable -Name "$($ModuleName)") {
                        Try { Write-ToLog -Tag "Use-Module" -Message "Module `"$($ModuleName)`" installed successfully" }
                        Catch { Write-Verbose -Message "[Use-Module] Module `"$($ModuleName)`" installed successfully" }
                        Write-Host -ForegroundColor Green "Module `"$($ModuleName)`" installed successfully"
                        Return $true
                    }
                    Else {
                        Try { Write-ToLog -Severity ERROR -Tag "Use-Module" -Message "Unable to install Module `"$($ModuleName)`"" }
                        Catch { Write-Warning -Message "[Use-Module] Unable to install Module `"$($ModuleName)`"" }
                        Throw "Unable to install Module `"$($ModuleName)`"."
                    }
                }
                Catch {
                    Try { Write-ToLog -Severity ERROR -Tag "Use-Module" -Message "Unable to install Module `"$($ModuleName)`"" }
                    Catch { Write-Warning -Message "[Use-Module] Unable to install module `"$($ModuleName)`"" }
                    Throw "Unable to install module `"$($ModuleName)`""
                }
            }
            Else {
                # No such module found
                Try { Write-ToLog -Tag "Use-Module" -Message "No Module called `"$($ModuleName)`" is available to install" }
                Catch { Write-Warning -Message "[Use-Module] No Module called `"$($ModuleName)`" is available to install" }
                Write-Warning -Message "[Use-Module] No Module called `"$($ModuleName)`" is available to install"
                Return $false
            }
        }

    }

    Process {

        Foreach ($Module in $ModuleName) {

            # Check if the module is already imported, if so, there is nothing to do
            If (Get-Module -Name $Module) {
                Try { Write-ToLog -Tag "$($MyInvocation.MyCommand.Name)" -Message "The Module `"$($Module)`" is already imported" }
                Catch { Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] The Module `"$($Module)`" is already imported" }
                Continue
            }

            # Check if the module is already installed, if so, import it
            If (Get-Module -ListAvailable -Name $Module) {
                Invoke-ImportModule -ModuleName $Module
                Continue
            }

            # If "NuGet" Package Provider is not installed, install it
            If (!(Get-PackageProvider -ListAvailable -Name "NuGet" -ErrorAction SilentlyContinue)) {
                Invoke-InstallPackageProvider -PackageProviderName "NuGet"
            }

            If (Invoke-InstallModule -ModuleName $Module) {
                Invoke-ImportModule -ModuleName $Module
                Continue
            }
            Else { Continue }

        }
    }
}

Get-Help Use-Module -Full