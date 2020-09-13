# Changelog for xCredSSP

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Updated to use the new CI/CD pipeline.

### Fixed

- Fixed issue where the Set method did not correct DelegateComputers, when
  two machines were accidentally added as one string instead of an array.

## [1.3.0.0] - 2017-05-31

### Changed

- Added a fix to enable CredSSP with a fresh server installation.

## [1.2.0.0] - 2017-03-24

### Changed

- Converted appveyor.yml to install Pester from PSGallery instead of from
  Chocolatey.
- Implemented a GPO check to prevent an endless reboot loop when CredSSP is
  configured via a GPO.
- Fixed issue with Test always returning false with other regional settings
  then english.
- Added check to test if Role=Server and DelegateComputers parameter is
  specified.
- Added parameter to suppress a reboot, default value is false (reboot
  server when required).

## [1.1.0.0] - 2016-03-30

- Made sure DSC reboots if credSS is enabled

## [1.0.1.0] - 2015-04-23

- Updated with minor bug fixes.

## [1.0.0.0] - 2015-04-15

- Initial release with the following resources
 - <span style="font-family:Calibri; font-size:medium">xADDomain</span>
