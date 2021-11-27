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

<#
.SYNOPSIS
Logs to file

.DESCRIPTION
Logs to file

.PARAMETER Type
Types follow Windows Streams, except for stream 1 (output) which isn't
used. You may also use first letter of a stream name, so type 2 and 'e'
are both the error stream, type 3 and 'w' the warning, and so on.
    Type 2 or 'e' = Error
    Type 3 or 'w' = Warning
    Type 4 or 'v' = Verbose
    Type 5 or 'd' = Debug
    Type 6 or 'i' = Information

.PARAMETER Message
The text to display and/or log.

#>
function Out-DryClientLog {
    [Alias("ocl")]
    param (
        [Alias("t")]
        [Parameter(Mandatory,Position=0)]
        [String]$Type,

        [Alias("m")]
        [Parameter(Mandatory,Position=1)]
        [AllowEmptyString()]
        [String]$Message
    )
    $LogFile = $GLOBAL:DryClientLog

    try {
        $Caller = (Get-PSCallStack)[1]
        [String] $Location = ($Caller.location).Replace(' line ','')

        switch ($Type) {
            {$_ -in ('2','e')} {
                $TextType = "ERROR:  "
            }
            {$_ -in ('3','w')} {
                $TextType = "WARNING:"
            }
            {$_ -in ('5','d')} {
                $TextType = "DEBUG:  "
            }
            {$_ -in ('6','i')} {
                $TextType = "INFO:   "
            }
            default {
                $Type = 'v'
                $TextType = "VERBOSE:"
            }
        }      
        $LogMessage = "{0} `$$<{1}><{2} {3}><thread={4}>" -f ($TextType + $Message), "$Location", (Get-Date -Format "MM-dd-yyyy"), (Get-Date -Format "HH:mm:ss.ffffff"), $PID
        $LogMessage | Out-File -Append -Encoding UTF8 -FilePath ("filesystem::{0}" -f $LogFile) -Force  
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}