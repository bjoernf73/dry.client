<# 
 This module downloads a list of references to git repos, and ensures that those
 repos are present in a PSModulePath on the system.

 Copyright (C) 2021  Bjorn Henrik Formo (bjornhenrikformo@gmail.com)
 LICENSE: https://raw.githubusercontent.com/bjoernf73/dry.client/main/LICENSE
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along
 with this program; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#>

function Get-DryClientModules {
    [CmdLetBinding()]
    param (
    )

    try {
        [String]$DryClientProgramData  = "$($env:ProgramData)\DryClient"
        [String]$GLOBAL:DryClientLog   = Join-Path -Path $DryClientProgramData -ChildPath 'dry.client.log'
        if (-not (Test-Path -Path $DryClientProgramData)) {
            New-Item -Path $DryClientProgramData -ItemType Directory -ErrorAction Stop -Force | 
            Out-Null
        }
        ocl i "Starting update of client modules."

        switch (Test-DryElevated) {
            $false {
                ocl e "Script was run un-elevated - fail and return"
                throw "Run elevated"
            }
            $true {
                ocl i "Script was run elevated - continuing"
                [String]$DefaultModulesListUrl = 'https://raw.githubusercontent.com/bjoernf73/dry.client/main/dry.client.list.json'
                [String]$ModulesPath           = "$($env:ProgramFiles)\WindowsPowershell\Modules"  
                [String]$SettingsFile          = Join-Path -Path $DryClientProgramData -ChildPath 'dry.client.settings.json'
                [String]$ModulesListUrl        = ''
                 
                if (Test-Path -Path $SettingsFile) {
                    ocl i "SettingsFile '$SettingsFile' exists - getting it"
                    $DryClientSettings = Get-Content -Path $SettingsFile -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
                    if (($null -ne $DryClientSettings.client.list.url) -and (($DryClientSettings.client.list.url).Trim() -ne '')) {
                        ocl i "Using custom URL for list '$($DryClientSettings.client.list.url)'"
                        [String]$ModulesListUrl = $DryClientSettings.client.list.url
                    }
                }

                if ($ModulesListUrl -eq '') {
                    $ModulesListUrl = $DefaultModulesListUrl
                }

                ocl i "Downloading list '$ModulesListUrl'"
                [Array]$ModuleList = Invoke-WebRequest -Uri $ModulesListUrl -ErrorAction Stop | 
                    Select-Object -ExpandProperty Content -ErrorAction Stop | 
                    ConvertFrom-Json -ErrorAction Stop

                foreach ($Project in $ModuleList) {
                    olc i "Getting url:    '$($Project.url)'"
                    olc i "        path:   '$ModulesPath'"
                    $InstallDryGitModuleParams = @{
                        Source = $Project.url
                        Path = $ModulesPath
                    }
                    
                    if ($Project.branch) {
                        olc i "        branch: '$($Project.branch)'"
                        $InstallDryGitModuleParams += @{
                            Branch = $Project.branch
                        }
                    }
                    else {
                        olc i "        branch: (n/a)"
                    }
                    Install-DryGitModule @InstallDryGitModuleParams
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        ocl i "------------------------------------"
    }
}