![logo](https://raw.githubusercontent.com/SecureHats/SecureHacks/main/media/sh-banners.png)
=========
[![Maintenance](https://img.shields.io/maintenance/yes/2022.svg?style=flat-square)]()
# Analytics Rules Validator

This GitHub action can be used to validate Microsoft Sentinel Analytics rules in both JSON and YML format.
>Add the following code block to your Github workflow:

```yaml
name: Analytics
on: push

jobs:
  pester-test:
    name: validate detections
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v3
      - name: Validate Sentinel Analytics Rules
        uses: SecureHats/validate-detections@v1
        with:
          filesPath: templates
```

> Use the filesPath parameter to specify the folder containing the detection rules.

## Current incuded tests

![image](https://user-images.githubusercontent.com/40334679/170026369-fa0fa7b8-e580-42d4-9c2d-c36edb506094.png)

## Current limitations / Under Development

- No support for Hunting Queries
- No support for Fusion rules
