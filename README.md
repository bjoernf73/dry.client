# dry.client

- Ensures that a list of git repositories, that are PowerShell modules, are present in a PSModulePath on a client system. 
- The list is dynamic, in that it is not part of this module itself, but is downloaded from a publicly available git repository. That way, the PSGallery-module `dry.client` does not need to be updated when the list of repositories changes. 
- The URL to the list of modules to be downloaded is part of this very repository by default, but may be customized in a settings file on the target system.

## Install
```
Install-Module -Name dry.client
```

## Requirements
- The *GitAutomation* powershell module 

## Use
Features one exported function `Get-DryClientModules`. Execute without parameters: 
```PowerShell
Get-DryClientModules
```

## Description
When run, the following occurs: 
1. Test for a local `dry.client.settings.json` file. If found, and the file specifies the property `client.list.url`, like
    ```
    {  
        "client.list.url": "https://gitlab.my.local/DryClientList/-/raw/main/dry.client.list.json"
    }
    ```
    that file is downloaded. If not, the default is used: 
    ```
    { 
        "client.list.url": "https://raw.githubusercontent.com/bjoernf73/dry.client/main/dry.client.list.json" 
    }
    ```
    Note that the URL should be a link to the RAW file. 

1. For each object in the list that does not exist locally: 
   - the repo is cloned to `"$($env:ProgramFiles)\WindowsPowerShell\Modules"`
   - the specified branch is checked out 

1. For modules that already exists:
   - changes are pulled to make sure all branches in the remote exists locally
   - the specified branch is checked out
   - changes are pulled again on the checked out branch