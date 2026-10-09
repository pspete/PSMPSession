# PSMPSession

## Unreleased

- N/A

## [2.0.0] - 2026-10-09

### Added

- Add `New-SIASession`
  - Connect via CyberArk Secure Infrastructure Access (SIA)
  - Zero standing privileges & vaulted (local / domain account) access
  - Supports target port, network name, custom gateway, ssh arguments & inline commands
- Add `Save-SIASSHKey`
  - Downloads an SIA MFA caching SSH key (OpenSSH or PPK format) via sftp
  - Restricts key file access to the current user
- `New-PSMPSession`
  - Add `TargetPort` & `TunnelPort` parameters
    - Appended to target address using `TargetAddressPortDelimiter`
  - Add `SSHArgument` parameter
    - Passes arguments such as `-t`, `-i`, `-L` to the ssh client
  - Add `Command` parameter
    - Command to run on the target after connecting
  - Add `PSMPAddress` alias for `TargetMachine`

### Changed

- `New-PSMPSession`: throw if `TargetAccount` is in UPN format and `TargetDomain` is not provided
- Help is now external help (`en-US/PSMPSession-help.xml`), generated from the command markdown in `docs/collections/_commands`.
- Build, test and release moved from AppVeyor to GitHub Actions; tests run on Windows PowerShell 5.1, PowerShell 7 on Windows and PowerShell 7 on Linux.

### Fixed

- `New-PSMPSession`: fix pipeline input
  - ssh connection now made for each piped object, not only the last
- Fix incorrect help examples

## [1.0] - 2022-02-10

- Initial Release
