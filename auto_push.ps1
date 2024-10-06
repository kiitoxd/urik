# Set the path to your Git repository (use double quotes and escape backslashes)
$pathToWatch = "E:\\urik"

# Verify the path exists before setting up the watcher
if (-Not (Test-Path -Path $pathToWatch)) {
    Write-Host "The directory '$pathToWatch' does not exist. Please verify the path."
    exit
}

Write-Host "Monitoring directory: $pathToWatch"

# Create a FileSystemWatcher object using constructor with path and filter
try {
    $watcher = [System.IO.FileSystemWatcher]::new($pathToWatch, "*.*")
    Write-Host "FileSystemWatcher object created successfully with path: $($watcher.Path)"
} catch {
    Write-Host "Failed to create FileSystemWatcher object. Error: $_"
    exit
}

# Set IncludeSubdirectories to true
$watcher.IncludeSubdirectories = $true

# Define the event handler action
$eventAction = {
    Write-Host "Change detected. Committing and pushing to GitHub..."
    cd $pathToWatch

    # Git commands to add, commit, and push changes
    git add --all
    git commit -m "Auto commit - added new changes"
    git push origin main  # Change "main" to your branch name if different

    Write-Host "Changes pushed to GitHub successfully."
}

# Attach event handlers using Register-ObjectEvent
try {
    Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $eventAction
    Register-ObjectEvent -InputObject $watcher -EventName Created -Action $eventAction
    Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $eventAction
    Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $eventAction
    Write-Host "Event handlers attached successfully."
} catch {
    Write-Host "Failed to attach event handlers. Error: $_"
    exit
}

# Enable event handling after attaching the events
try {
    $watcher.EnableRaisingEvents = $true
    Write-Host "FileSystemWatcher is now monitoring directory: $watcher.Path"
} catch {
    Write-Host "Failed to enable raising events. Error: $_"
    exit
}

# Keep the script running indefinitely
while ($true) { Start-Sleep 1 }