# PSMPSession

## Planned Updates
- Future planned updates will be detailed here

## Unreleased

- Add `TargetPort` & `TunnelPort` parameters
  - Appended to target address using `TargetAddressPortDelimiter`
- Add `SSHArgument` parameter
  - Passes arguments such as `-t`, `-i`, `-L` to the ssh client
- Add `Command` parameter
  - Command to run on the target after connecting
- Add `PSMPAddress` alias for `TargetMachine`
- Fix pipeline input
  - ssh connection now made for each piped object, not only the last
- Throw if `TargetAccount` is in UPN format and `TargetDomain` is not provided
- Fix incorrect help examples
## **1.0**

- Initial Release
