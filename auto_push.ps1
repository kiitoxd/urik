# Set the path to your Git repository (use double quotes and escape backslashes or use forward slashes)
$pathToWatch = "E:\\urik"

# Verify the path exists before setting up the watcher
if (-Not (Test-Path -Path $pathToWatch)) {
    Write-Host "The directory '$pathToWatch' does not exist. Please verify the path."
    exit
}

Write-Host "Monitoring directory: $pathToWatch"

# Create a FileSystemWatcher object and set the path and filter directly using constructor
try {
    $watcher = [System.IO.FileSystemWatcher]::new($pathToWatch, "*.*")
    Write-Host "FileSystemWatcher object created successfully with path: $pathToWatch"
} catch {
    Write-Host "Failed to create FileSystemWatcher object. Error: $_"
    exit
}

# Ensure the watcher is not null
if ($null -eq $watcher) {
    Write-Host "The watcher object is null. Exiting script."
    exit
}

# Print watcher path to verify
Write-Host "Watcher path set to: $watcher.Path"

# Set other watcher properties
$watcher.IncludeSubdirectories = $true

# Define an action to take on file change
$action = {
    Write-Host "Change detected. Committing and pushing to GitHub..."
    cd $pathToWatch

    # Git commands to add all changes, including untracked files
    git add --all
    git commit -m "Auto commit - added new changes"
    git push origin main  # Change "main" to your branch name if different

    Write-Host "Changes pushed to GitHub successfully."
}

# Check if the watcher properties are correctly set before attaching events
if ($watcher -and $watcher.Path -and (Test-Path $watcher.Path)) {
    try {
        # Attach the action to different file change events only if watcher is properly initialized
        $watcher.Changed.Add($action)
        $watcher.Created.Add($action)
        $watcher.Deleted.Add($action)
        $watcher.Renamed.Add($action)
        Write-Host "Event handlers attached successfully."
    } catch {
        Write-Host "Failed to attach event handlers. Error: $_"
        exit
    }
} else {
    Write-Host "Watcher path or object is not valid. Cannot attach event handlers."
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
