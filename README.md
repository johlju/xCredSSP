# xCredSSP

[![Build Status](https://dev.azure.com/dsccommunity/xCredSSP/_apis/build/status/dsccommunity.xCredSSP?branchName=master)](https://dev.azure.com/dsccommunity/xCredSSP/_build/latest?definitionId={definitionId}&branchName=master)
![Azure DevOps coverage (branch)](https://img.shields.io/azure-devops/coverage/dsccommunity/xCredSSP/{definitionId}/master)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/xCredSSP/{definitionId}/master)](https://dsccommunity.visualstudio.com/xCredSSP/_test/analytics?definitionId={definitionId}&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/xCredSSP?label=xCredSSP%20Preview)](https://www.powershellgallery.com/packages/xCredSSP/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/xCredSSP?label=xCredSSP)](https://www.powershellgallery.com/packages/xCredSSP/)

This module contains the **xCredSSP** resource, which enables or disables
Credential Security Support Provider (CredSSP) authentication on a client
or on a server computer, and which server or servers the client credentials
can be delegated to.

## Code of Conduct

This project has adopted this [Code of Conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `master` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Requirements

This module requires the latest version of PowerShell (v4.0, which ships in
Windows 8.1 or Windows Server 2012 R2). To easily use PowerShell 4.0 on
older operating systems, [<span style="color:#0000ff">install WMF 4.0</span>](http://www.microsoft.com/en-us/download/details.aspx?id=40855).
Please read the installation instructions that are present on both the 
download page and the release notes for WMF 4.0.

## Resources

### xCredSSP

The **xCredSSP** resource enables or disables Credential Security Support Provider
(CredSSP) authentication on a client or on a server computer, and which server
or servers the client credentials can be delegated to.

The **xCredSSP** resource has following properties:

- **Ensure:** Specifies whether the domain trust is present or absent.
- **Role**: REQUIRED parameter representing the CredSSP role, and is either
  "Server" or "Client".
- **DelegateComputers**: Array of servers to be delegated to, REQUIRED when
  Role is set to "Client".
- **SuppressReboot**: Specifies whether a necessary reboot has to be suppressed
  or not.

## Examples

Enable CredSSP for both server and client roles, and delegate to Server1
and Server2.

```powershell
Configuration EnableCredSSP
{
    Import-DscResource -Module xCredSSP
    Node localhost
    {
        xCredSSP Server
        {
            Ensure = "Present"
            Role = "Server"
        }
        xCredSSP Client
        {
            Ensure = "Present"
            Role = "Client"
            DelegateComputers = "Server1","Server2"
        }
    }
}
```
