# Contributing

All contributions, whether comments, code or otherwise are welcomed and appreciated.

## PSMPSession Issues

If you find an error in `PSMPSession`, or have a question relating to the module, [log an issue][new-issue].

## Pull Requests

When submitting a Pull Request to PSMPSession, automated tasks will run in Appveyor.

- Appveyor will increment the version number (there is no need to do this manually)
- The [`Pester`][pester-repo] tests for the module will run.
- Once code is merged into the `main` branch, and all tests pass, the module is automatically published to the PowerShell Gallery and tagged as a Release on GitHub
  - No PR's should be submitted to the main branch; submitting to the Dev branch allows for required tests & documentation to be updated prior to any code release.

## Contributing Code

- Fork the repo.
- Push your changes to your fork.
- Write [good commit messages][commit]
- If no related issue exists already, open a [New Issue][new-issue] describing the problem being fixed or feature.
- [Update documentation](#updating-documentation) for the command as required.
- Submit a pull request to the [Dev Branch][dev-branch]
  - Keep pull requests limited to a single issue
  - Discussion, or necessary changes may be needed before merging the contribution.
  - Link the pull request to the related issue

### PowerShell Styleguide

Use the standard *Verb*-*Noun* convention, and only use approved verbs.

All Functions must have Comment Based Help.

[K&R (One True Brace Style variant)](https://github.com/PoshCode/PowerShellPracticeAndStyle/issues/81) preferred.

[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[OTBS]: https://github.com/PoshCode/PowerShellPracticeAndStyle/issues/81
[new-issue]: https://github.com/pspete/PSMPSession/issues/new
[dev-branch]: https://github.com/pspete/PSMPSession/tree/dev
[pester-repo]: https://github.com/pester/Pester