[cmdletbinding()]
param()

# Get all the functions within the module path
$Scripts = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
Foreach ($Script in @( $Scripts )) {
    Try {
        . $Script.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Export the module members
Export-ModuleMember -function (Get-ChildItem -Path $PSScriptRoot\*.ps1).basename
