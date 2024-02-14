$workdir = "c:\unTemp\"
$firefoxdir = "c:\Program Files\Mozilla Firefox\browser"
$neovimdir = "C:\Program Files\nvim-win64\"
$vscodedir = "C:\Program Files\Microsoft VS Code"
$pandocdir = "C:\Program Files\Pandoc"

# Make temporary directory if it doesn't already exist
if(!(Test-Path -Path $workdir)) {
New-Item -Path $workdir -ItemType directory 
}

# Install Firefox if it has not already been installed
if(!(Test-Path -Path $firefoxdir)) { 
Invoke-WebRequest "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US" -OutFile "$workdir\firefox.exe"
Start-Process -FilePath "$workdir\firefox.exe" -ArgumentList '/silent' -Wait
}

# Install Mozilla's group policy definitions if they have not been installed
if(!(Test-Path -Path "C:\Windows\PolicyDefinitions\firefox.admx" -PathType leaf)) { 
Invoke-WebRequest "https://github.com/mozilla/policy-templates/releases/download/v5.2/policy_templates_v5.2.zip" -OutFile "$workdir\policy_templates.zip"
Expand-Archive -Path "$workdir\policy_templates.zip" -DestinationPath "$workdir\policies\"
Copy-Item -Path "$workdir\policies\windows\*" -Destination "C:\Windows\PolicyDefinitions"
Copy-Item -Path "$workdir\policies\windows\en-US\*" -Destination "C:\Windows\PolicyDefinitions\en-US" -Recurse
}


# Install neovim if it has not already been installed
if(!(Test-Path -Path $neovimdir)) { 
Invoke-WebRequest "https://github.com/neovim/neovim/releases/download/stable/nvim-win64.zip" -OutFile "$workdir\nvim.zip"
Expand-Archive -Path "$workdir\nvim.zip" -DestinationPath "$workdir\"
Move-Item -Path "$workdir\nvim-win64" -Destination "C:\Program Files\"
Invoke-WebRequest "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile "$workdir\vcredist.exe"
Start-Process -FilePath "$workdir\vcredist.exe" -ArgumentList '/q /norestart' -Wait
}


# Install VS Code if it has not already been installed
if(!(Test-Path -Path $vscodedir)) { 
Invoke-WebRequest "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" -OutFile "$workdir\code.exe"
Start-Process -FilePath "$workdir\code.exe" -ArgumentList '/VERYSILENT /MERGETASKS=!runcode"' -Wait
}

# Download the miktex installer if it is not present, each user will have to install it themselves
if(!(Test-Path -Path "C:\Miktex")) {
    New-Item -Path "C:\Miktex" -ItemType directory 
    Invoke-WebRequest "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-23.9-x64.exe" -OutFile "C:\Miktex\miktex.exe"
}

# Install Pandoc if it has not already been installed
if(!(Test-Path -Path $pandocdir)) { 
    Invoke-WebRequest "https://github.com/jgm/pandoc/releases/download/3.1.8/pandoc-3.1.8-windows-x86_64.zip" -OutFile "$workdir\pandoc.zip"
    Expand-Archive -Path "$workdir\pandoc.zip" -DestinationPath "$workdir\"
    Rename-Item -Path "$workdir\pandoc-3.1.8\" -NewName "Pandoc"
    Move-Item -Path "$workdir\Pandoc" -Destination "c:\Program Files\"
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Pandoc", "Machine")
}

#Lastly, delete the temporary directory
rm $workdir -r -force