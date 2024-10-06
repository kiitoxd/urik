# Set the path to your Git repository
$pathToWatch = "E:\\urik"

# Verify the path exists before setting up the watcher
if (-Not (Test-Path -Path $pathToWatch)) {
    Write-Host "The directory '$pathToWatch' does not exist. Please verify the path."
    exit
}

Write-Host "Monitoring directory: $pathToWatch"

# Create a FileSystemWatcher object using the constructor with path and filter
try {
    $watcher = [System.IO.FileSystemWatcher]::new($pathToWatch, "*.*")
    Write-Host "FileSystemWatcher object created successfully with path: $watcher.Path"
} catch {
    Write-Host "Failed to create FileSystemWatcher object. Error: $_"
    exit
}

# Print all properties of the watcher object to debug
$watcher | Format-List -Property *

# Verify the watcher type and check for null values
if ($watcher -eq $null) {
    Write-Host "The watcher object is null. Exiting script."
    exit
}

if ($watcher.GetType().FullName -ne "System.IO.FileSystemWatcher") {
    Write-Host "The watcher is not a valid FileSystemWatcher object. Object type: " + $watcher.GetType().FullName
    exit
}

# Print a debug message to confirm properties
Write-Host "Path: $($watcher.Path), Filter: $($watcher.Filter)"

# Set IncludeSubdirectories to true if it's not already set
if (-not $watcher.IncludeSubdirectories) {
    $watcher.IncludeSubdirectories = $true
    Write-Host "IncludeSubdirectories set to: $($watcher.IncludeSubdirectories)"
}

# Define an action to take on file change
$action = {
    Write-Host "Change detected. Committing and pushing to GitHub..."
    cd $pathToWatch

    # Git commands to add, commit, and push changes
    git add --all
    git commit -m "Auto commit - added new changes"
    git push origin main  # Change "main" to your branch name if different

    Write-Host "Changes pushed to GitHub successfully."
}

# Attach event handlers only if the watcher is correctly set up
try {
    if ($watcher -and $watcher.Path -and (Test-Path $watcher.Path)) {
        # Attach event handlers
        $watcher.Changed.Add($action)
        $watcher.Created.Add($action)
        $watcher.Deleted.Add($action)
        $watcher.Renamed.Add($action)
        Write-Host "Event handlers attached successfully."
    } else {
        Write-Host "Watcher path or object is not valid. Cannot attach event handlers."
        exit
    }
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
