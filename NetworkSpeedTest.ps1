# Network Speed Test Script
# Server Side (Receiver)
# Client Side (Sender)

# Define common parameters
$testFileSizeMB = 100  # Size of the test file in MB
$testFileName = "testfile.bin"
$bufferSize = 1MB     # Buffer size for data transfer
$serverIP = "192.168.7.133"  # Replace with the server's IP address
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
    try {
        # Create and start the TCP listener
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $serverPort)
        $listener.Start()
        Write-Host "Server started on port $serverPort. Waiting for client connection..."
        Write-Host "Press 'Q' to stop the server."

        $client = $null
        $stream = $null

        # Initialize the buffer
        $buffer = New-Object Byte[] $bufferSize

        # Loop to wait for client connection or manual exit
        while ($true) {
            if ($listener.Pending()) {
                $client = $listener.AcceptTcpClient()
                $stream = $client.GetStream()

                # Notify that a client has connected
                Write-Host "Client connected: $($client.Client.RemoteEndPoint)"

                $startTime = [System.Diagnostics.Stopwatch]::StartNew()

                # Receive the test file as a stream
                $fileBytes = @()
                $totalBytesRead = 0
                $fileSizeBytes = $testFileSizeMB * 1MB  # Expected file size in bytes

                do {
                    $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
                    if ($bytesRead -gt 0) {
                        $fileBytes += $buffer[0..($bytesRead - 1)]
                        $totalBytesRead += $bytesRead

                        # Calculate progress percentage
                        $progress = [math]::Round(($totalBytesRead / $fileSizeBytes) * 100, 2)

                        # Display progress on the console
                        Write-Progress -Activity "Receiving file" -Status "$progress% Complete" -PercentComplete $progress
                    }
                } while ($bytesRead -gt 0)

                $elapsedTime = $startTime.Elapsed.TotalSeconds
                $fileSizeMB = $fileBytes.Length / 1MB
                $transferSpeedMBps = $fileSizeMB / $elapsedTime

                Write-Host "File received. Size: $fileSizeMB MB, Time: $elapsedTime seconds, Speed: $transferSpeedMBps MB/s"

                $stream.Close()
                $client.Close()
                Write-Host "Client disconnected."
            }

            # Check for key press to exit
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if ($key.Key -eq [ConsoleKey]::Q) {
                    Write-Host "Stopping server..."
                    break
                }
            }

            # Small delay to avoid high CPU usage
            Start-Sleep -Milliseconds 100
        }
    } catch {
        Write-Error "An error occurred: $_"
    } finally {
        # Ensure the listener is stopped
        if ($listener -and $listener.Server.IsBound) {
            $listener.Stop()
            Write-Host "Server stopped."
        }
    }
}

# Function to start the client (sender)
function Start-Client {
    try {
        # Create a TCP client and connect to the server
        $client = [System.Net.Sockets.TcpClient]::new($serverIP, $serverPort)
        $stream = $client.GetStream()

        # Open the test file for reading
        $fileStream = [System.IO.File]::OpenRead($testFileName)
        $buffer = New-Object Byte[] $bufferSize
        $startTime = [System.Diagnostics.Stopwatch]::StartNew()

        # Get the total file size
        $fileSizeBytes = $fileStream.Length
        $totalBytesSent = 0

        Write-Host "Sending test file to server..."

        # Send the file in chunks and display progress
        do {
            $bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)
            if ($bytesRead -gt 0) {
                $stream.Write($buffer, 0, $bytesRead)
                $totalBytesSent += $bytesRead

                # Calculate progress percentage
                $progress = [math]::Round(($totalBytesSent / $fileSizeBytes) * 100, 2)

                # Display progress on the console
                Write-Progress -Activity "Sending file" -Status "$progress% Complete" -PercentComplete $progress
            }
        } while ($bytesRead -gt 0)

        # Calculate transfer speed
        $elapsedTime = $startTime.Elapsed.TotalSeconds
        $fileSizeMB = $fileSizeBytes / 1MB
        $transferSpeedMBps = $fileSizeMB / $elapsedTime

        Write-Host "Test file sent. Size: $fileSizeMB MB, Time: $elapsedTime seconds, Speed: $transferSpeedMBps MB/s"
    } catch {
        Write-Error "An error occurred: $_"
    } finally {
        # Close the file stream and network stream
        if ($fileStream) { $fileStream.Close() }
        if ($stream) { $stream.Close() }
        if ($client) { $client.Close() }
    }
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