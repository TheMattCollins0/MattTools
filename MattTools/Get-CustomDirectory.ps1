# Function to Get Custom Directory path
Function Get-CustomDirectory {
    [CmdletBinding()]
    [Alias("CDir")]
    [OutputType([String])]
    Param
    (
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        $Path = $PWD.Path
    )
    
    Begin {
        #Custom directories as a HashTable
        $CustomDirectories = @{

            $env:TEMP                                                      = 'Temp'
            $env:APPDATA                                                   = 'AppData'
            "C:\Users\Matt.Collins\OneDrive - Node IT Solutions\Desktop"   = 'Desktop'
            "C:\Users\Matt.Collins\OneDrive - Node IT Solutions\Documents" = 'MyDocuments'
            "C:\Users\Matt.Collins\Downloads"                              = 'Downloads'
            "C:\GitHub"                                                    = 'GitHub'
            "C:\GitHub\PowerShell"                                         = 'PowerShell'
            "C:\Scripts"                                                   = 'Scripts'
            "C:\Scripts\Input"                                             = 'Input'
            "C:\Scripts\Output"                                            = 'Output'
        } 
    }
    Process {
        Foreach ($Item in $Path) {
            $Match = ($CustomDirectories.GetEnumerator().name | Where-Object {$Item -eq "$_" -or $Item -like "$_*"} |`
                    Select-Object @{n = 'Directory'; e = {$_}}, @{n = 'Length'; e = {$_.length}} | Sort-Object Length -Descending | Select-Object -First 1).directory
            If ($Match) {
                [String]($Item -replace [regex]::Escape($Match), $CustomDirectories[$Match])            
            }
            ElseIf ($pwd.Path -ne $Item) {
                $Item
            }
            Else {
                $pwd.Path
            }
        }
    }
    End {
    }
}
