# dry.client

- Ensures that a list of git repositories, that are PowerShell modules, are present in a PSModulePath on a client system. 
- The list is dynamic, in that it is not part of this module itself, but is downloaded from a publicly available git repository. That way, the PSGallery-module `dry.client` does not need to be updated when the list of repositories changes. 
- The URL to the list of modules to be downloaded is part of this very repository by default, but may be customized in a settings file on the target system.

## Install
```
Install-Module -Name dry.client
```

## Requirements
- Git client installed and `git.exe` in a `$env:path`.

## Use
Features one exported function `Update-DryClientModules`. When run,  
1. Test for a local `dry.client.settings.json` file. If found, and the file specifies 
    ```
    {
        "client.list.url": "https://my.internal.git/dry.client.list.git"
    }
    ```
    that file is downloaded. If not, the default is used: 
    ```
    {
        "client.list.url": ""
    }
    ```

1. Downloads a list of 