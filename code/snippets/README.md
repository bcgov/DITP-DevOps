# Code Snippets

## getDockerHost

Gets the Docker host address depending on the host system.  Refer to the documentation in the script for further details; [getDockerHost](./getDockerHost).

To use this function in your script add the following two lines:
```
. /dev/stdin <<<"$(cat <(curl -s --raw https://raw.githubusercontent.com/bcgov/DITP-DevOps/main/code/snippets/getDockerHost))" 
export DOCKERHOST=$(getDockerHost)
```

The first line of code sources (imports) the [getDockerHost](./getDockerHost) function dynamically from this repository and makes it available for use in subsequent lines of your script.  The second line simply calls the function and exports the return value in the `DOCKERHOST` variable.

This code includes a workaround for known limitations of process substitution in bash 3.2 which can be found on many Macs; [Why source command doesn't work with process substitution in bash 3.2?](https://stackoverflow.com/a/32596626).  This workaround also works on newer versions of bash.

Example of the version of bash that requires the workaround;
```
GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin21)
Copyright (C) 2007 Free Software Foundation, Inc.
```

For completeness, on newer versions of bash the process substitution could be written as:
```
. <(curl -s --raw https://raw.githubusercontent.com/bcgov/DITP-DevOps/main/code/snippets/getDockerHost)
```
However you then loose the backward compatibility with the older versions of bash.