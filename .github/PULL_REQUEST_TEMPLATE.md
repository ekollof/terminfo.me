## Description

<!-- A clear and concise description of what this PR does. -->

## Type of Change

- [ ] New terminfo entry
- [ ] Improvement / fix to an existing entry
- [ ] Documentation or website change
- [ ] Other (please describe below)

## Checklist

Please confirm the following before requesting review:

- [ ] I have run `contrib/run-all-checks.sh` locally and all checks pass
- [ ] For **new entries**: I have appended the SHA-256 checksum to `static/terminfo/checksums.txt`
- [ ] The `.ti` file compiles cleanly with `tic -x`
- [ ] The header contains at minimum: `Terminal:`, `Source:`, and `License:`
- [ ] I have read the [Contribute guide](https://terminfo.me/contribute)

## Related Issue

<!-- Link to the GitHub issue this PR addresses (recommended) -->
Closes #XXX

## Testing

<!-- How did you test this change? -->
- [ ] Locally with `tic -x`
- [ ] Using the install script
- [ ] Other: <!-- describe -->

## Additional Notes

<!-- Any other context, screenshots, or things reviewers should know. -->
