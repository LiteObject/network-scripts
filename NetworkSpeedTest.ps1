# Network Speed Test Script
# Server Side (Receiver)
# Client Side (Sender)

# Define common parameters
$testFileSizeMB = 10  # Size of the test file in MB
$testFileName = "testfile.bin"
$bufferSize = 1MB     # Buffer size for data transfer
$serverIP = "192.168.1.100"  # Replace with the server's IP address
$serverPort = 5000    # Port for communication

# Function to create a test file
function Create-TestFile {
    param ($fileName, $fileSizeMB)
    $fileSizeBytes = $fileSizeMB * 1MB
    $randomData = New-Object Byte[] $fileSizeBytes
    (New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomData)
    [System.IO.File]::WriteAllBytes($fileName, $randomData)
    Write-Host "Test file '$fileName' created with size $fileSizeMB MB."
}

# Function to start the server (receiver)
function Start-Server {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $serverPort)
    $listener.Start()
    Write-Host "Server started. Waiting for client connection..."

    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $startTime = [System.Diagnostics.Stopwatch]::StartNew()

    # Receive the test file
    $fileBytes = @()
    while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $fileBytes += $buffer[0..($bytesRead - 1)]
    }

    $elapsedTime = $startTime.Elapsed.TotalSeconds
    $fileSizeMB = $fileBytes.Length / 1MB
    $transferSpeedMBps = $fileSizeMB / $elapsedTime

    Write-Host "File received. Size: $fileSizeMB MB, Time: $elapsedTime seconds, Speed: $transferSpeedMBps MB/s"

    $stream.Close()
    $client.Close()
    $listener.Stop()
}

# Function to start the client (sender)
function Start-Client {
    $client = [System.Net.Sockets.TcpClient]::new($serverIP, $serverPort)
    $stream = $client.GetStream()

    # Send the test file
    $fileBytes = [System.IO.File]::ReadAllBytes($testFileName)
    $stream.Write($fileBytes, 0, $fileBytes.Length)
    Write-Host "Test file sent to server."

    $stream.Close()
    $client.Close()
}

# Main script logic
Write-Host "Network Speed Test Script"
Write-Host "1. Start Server (Receiver)"
Write-Host "2. Start Client (Sender)"
$choice = Read-Host "Enter your choice (1 or 2)"

switch ($choice) {
    1 {
        # Create a test file on the server (optional)
        Create-TestFile -fileName $testFileName -fileSizeMB $testFileSizeMB
        Start-Server
    }
    2 {
        # Create a test file on the client
        Create-TestFile -fileName $testFileName -fileSizeMB $testFileSizeMB
        Start-Client
    }
    default {
        Write-Host "Invalid choice. Exiting."
    }
}