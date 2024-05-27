$WorkDir = "c:\unTemp"
$FirefoxDir = "c:\Program Files\Mozilla Firefox\browser"
$NeovimDir = "C:\Program Files\nvim-win64"
$VsCodeDir = "C:\Program Files\Microsoft VS Code"
$PandocDir = "C:\Program Files\Pandoc"
$MiktexDir = "C:\Program Files\Miktex Setup"

# Make temporary directory if it doesn't already exist
if(!(Test-Path -Path $WorkDir)) {
New-Item -Path $WorkDir -ItemType directory 
}

# Install Firefox if it has not already been installed
if(!(Test-Path -Path $FirefoxDir)) { 
Invoke-WebRequest "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US" -OutFile "$WorkDir\firefox.exe"
Start-Process -FilePath "$WorkDir\firefox.exe" -ArgumentList '/silent' -Wait
}

# Install Mozilla's group policy definitions if they have not been installed
if(!(Test-Path -Path "C:\Windows\PolicyDefinitions\firefox.admx" -PathType leaf)) { 
Invoke-WebRequest "https://github.com/mozilla/policy-templates/releases/download/v5.2/policy_templates_v5.2.zip" -OutFile "$WorkDir\policy_templates.zip"
Expand-Archive -Path "$WorkDir\policy_templates.zip" -DestinationPath "$WorkDir\policies\"
Copy-Item -Path "$WorkDir\policies\windows\*" -Destination "C:\Windows\PolicyDefinitions"
Copy-Item -Path "$WorkDir\policies\windows\en-US\*" -Destination "C:\Windows\PolicyDefinitions\en-US" -Recurse
}


# Install neovim if it has not already been installed
if(!(Test-Path -Path $NeovimDir)) { 
Invoke-WebRequest "https://github.com/neovim/neovim/releases/download/stable/nvim-win64.zip" -OutFile "$WorkDir\nvim.zip"
Expand-Archive -Path "$WorkDir\nvim.zip" -DestinationPath "$WorkDir\"
Move-Item -Path "$WorkDir\nvim-win64" -Destination "C:\Program Files\"
Invoke-WebRequest "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile "$WorkDir\vcredist.exe"
Start-Process -FilePath "$WorkDir\vcredist.exe" -ArgumentList '/q /norestart' -Wait
}


# Install VS Code if it has not already been installed
if(!(Test-Path -Path $VsCodeDir)) { 
Invoke-WebRequest "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" -OutFile "$WorkDir\code.exe"
Start-Process -FilePath "$WorkDir\code.exe" -ArgumentList '/VERYSILENT /MERGETASKS=!runcode"' -Wait
}

# Download the miktex installer if it is not present, each user will have to install it themselves
if(!(Test-Path -Path "$MiktexDir")) {
    New-Item -Path "$MiktexDir" -ItemType directory 
    Invoke-WebRequest "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-23.9-x64.exe" -OutFile "$MiktexDir"
}

# Install Pandoc if it has not already been installed
if(!(Test-Path -Path $PandocDir)) { 
    Invoke-WebRequest "https://github.com/jgm/pandoc/releases/download/3.1.8/pandoc-3.1.8-windows-x86_64.zip" -OutFile "$WorkDir\pandoc.zip"
    Expand-Archive -Path "$WorkDir\pandoc.zip" -DestinationPath "$WorkDir\"
    Rename-Item -Path "$WorkDir\pandoc-3.1.8\" -NewName "Pandoc"
    Move-Item -Path "$WorkDir\Pandoc" -Destination "c:\Program Files\"
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Pandoc", "Machine")
}

# Delete the temporary directory
rm $WorkDir -r -force
