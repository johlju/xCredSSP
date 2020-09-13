$script:dscModuleName      = 'xCredSSP'
$script:dscResourceName    = 'MSFT_xCredSSP'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit
#endregion

try
{
    InModuleScope $script :DSCResourceName {
        Describe 'MSFT_xCredSSP\Get-TargetResource' {
            # TODO: Complete Tests...
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context "Enable Server Role with invalid delegate Computer parameter" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Enable-WSManCredSSP
                Mock -CommandName Disable-WSManCredSSP

                It 'Should return $false' {
                    Test-TargetResource -Ensure 'Present' -Role Server -DelegateComputer 'foo' | Should -BeFalse
                }
            }

            Context "Server Role not configured" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{ auth_credssp = 0 }
                }

                It 'Should return $false' {
                    Test-TargetResource -Ensure 'Present' -Role Server | should -BeFalse
                }
            }

            Context "Client Role not configured" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Get-WSManCredSSP -MockWith {
                    return @(
                        [string]::Empty,
                        [string]::Empty
                    )
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        1 = "wsman/testserver.domain.com"
                        2 = "wsman/testserver2.domain.com"
                    }
                }

                Mock -CommandName Get-Item -MockWith {
                    $client1 = New-Object -typename PSObject|
                                Add-Member NoteProperty "Name" 1 -PassThru |
                                Add-Member NoteProperty "Property" 1 -PassThru

                    $client2 = New-Object -typename PSObject|
                                Add-Member NoteProperty "Name" 2 -PassThru |
                                Add-Member NoteProperty "Property" 2 -PassThru

                    return @(
                        $client1,
                        $client2
                    )
                }

                It 'Should return $false' {
                    Test-TargetResource -Ensure 'Present' -Role Client -DelegateComputer 'foo' | Should -BeFalse
                }
            }
        }

        Describe 'MSFT_xCredSSP\Set-TargetResource' {
            Context "Enable Server Role with invalid delegate Computer parameter" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Enable-WSManCredSSP
                Mock -CommandName Disable-WSManCredSSP

                It 'Should throw' {
                    { Set-TargetResource -Ensure 'Present' -Role Server -DelegateComputer 'foo' } | Should -Throw
                }

                It 'Should have not called enable' {
                    Assert-MockCalled -CommandName Enable-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should have not called disable' {
                    Assert-MockCalled -CommandName Disable-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should not have triggered a reboot' {
                    $global:DSCMachineStatus | Should -BeNullOrEmpty
                }
            }

            Context "Enable Server Role when it has been configured using GPO" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Enable-WSManCredSSP
                Mock -CommandName Disable-WSManCredSSP

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        AllowCredSSP = 1
                    }
                } -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service'
                }

                It 'Should throw' {
                    { Set-TargetResource -Ensure 'Present' -Role Server } | Should -Throw
                }

                It 'Should have not called enable' {
                    Assert-MockCalled -CommandName Enable-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should have not called disable' {
                    Assert-MockCalled -CommandName Disable-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should not have triggered a reboot' {
                    $global:DSCMachineStatus | Should -BeNullOrEmpty
                }
            }

            Context "Enable Client Role when it has been configured using GPO" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Enable-WSManCredSSP
                Mock -CommandName Disable-WSManCredSSP

                mock Get-ItemProperty -MockWith {
                    return @{
                        AllowCredSSP = 1
                    }
                } -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client'
                }

                It 'Should throw' {
                    { Set-TargetResource -Ensure 'Present' -Role Client -DelegateComputers 'foo' } | Should -Throw
                }

                It 'Should have not called enable' {
                    Assert-MockCalled -CommandName Enable-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should have not called disable' {
                    Assert-MockCalled -CommandName Disable-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should not have triggered a reboot' {
                    $global:DSCMachineStatus | Should -BeNullOrEmpty
                }
            }

            Context "Enable Server Role" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Enable-WSManCredSSP
                Mock -CommandName Disable-WSManCredSSP

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{ auth_credssp = 1 }
                }

                It 'Should not return anything' {
                    Set-TargetResource -Ensure 'Present' -Role Server | Should -BeNullOrEmpty
                }

                It 'Should have called enable'{
                    Assert-MockCalled -CommandName Enable-WSManCredSSP -Times 1 -ParameterFilter {
                        $Role -eq 'Server' -and $Force -eq $true
                    }
                }

                It 'Should have not called disable' {
                    Assert-MockCalled -CommandName Disable-WSManCredSSP -Times 0
                }

                It 'Should have triggered a reboot'{
                    $global:DSCMachineStatus | Should -Be 1
                }
            }

            Context "Enable Client Role" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Get-WSManCredSSP -MockWith {
                    return @(
                        [string]::Empty,
                        [string]::Empty
                    )
                }

                Mock -CommandName Enable-WSManCredSSP
                Mock -CommandName Disable-WSManCredSSP

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        1 = 'wsman/testserver.domain.com'
                        2 = 'wsman/testserver2.domain.com'
                    }
                }

                Mock -CommandName Get-Item -MockWith {
                    $client1 = New-Object -typename PSObject|
                                Add-Member NoteProperty "Name" 1 -PassThru |
                                Add-Member NoteProperty "Property" 1 -PassThru

                    $client2 = New-Object -typename PSObject|
                                Add-Member NoteProperty "Name" 2 -PassThru |
                                Add-Member NoteProperty "Property" 2 -PassThru

                    return @(
                        $client1,
                        $client2
                    )
                }

                It 'Should not return anything' {
                    Set-TargetResource -Ensure 'Present' -Role Client -DelegateComputer 'foo' | Should -BeNullOrEmpty
                }

                It 'Should have called enable'{
                    Assert-MockCalled -CommandName Enable-WSManCredSSP -Times 1 -ParameterFilter {
                        $Role -eq 'Client' -and $Force -eq $true -and $DelegateComputer -eq 'foo'
                    }
                }

                It 'Should have not called disable' {
                    Assert-MockCalled -CommandName Disable-WSManCredSSP -Times 0
                }

                It 'Should have triggered a reboot'{
                    $global:DSCMachineStatus | Should -Be 1
                }
            }

            Context "Enable Client Role  with invalid delegate Computer parameter" {
                BeforeAll {
                    $global:DSCMachineStatus = $null
                }

                AfterAll {
                    $global:DSCMachineStatus = $null
                }

                Mock -CommandName Get-WSManCredSSP -MockWith {
                    @(
                        [string]::Empty,
                        [string]::Empty
                    )
                }

                Mock -CommandName Enable-WSManCredSSP
                Mock -CommandName Disable-WSManCredSSP

                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        auth_credssp = 1
                    }
                }

                Mock -CommandName Get-Item -MockWith {
                    return @(
                        @{
                            Name = 1
                            Property = 'wsman/foo'
                        },
                        @{
                            Name = 1
                            Property = 'wsman/testserver.domain.com'
                        }
                    )
                }

                It 'Should throw' {
                    { Set-TargetResource -Ensure 'Present' -Role Client } | Should -Throw 'DelegateComputers is required!'
                }

                It 'Should have not called get' {
                    Assert-MockCalled -CommandName Get-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should have called enable' {
                    Assert-MockCalled -CommandName Enable-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should have not called disable' {
                    Assert-MockCalled -CommandName Disable-WSManCredSSP -Times 0 -Scope 'Context'
                }

                It 'Should not have triggered a reboot'{
                    $global:DSCMachineStatus | Should -BeNullOrEmpty
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
