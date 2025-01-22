# Network Scripts

## `TCPRemoteShell.ps1`
This PowerShell script establishes a TCP connection to a remote host at a specified IP address and port. It provides a basic **remote command execution** capability, allowing commands to be sent to the remote host, executed locally, and the results returned. The script includes:

1. **TCP Client Setup:** Connects to a remote IP and port.

2. **Data Encryption:** Uses AES encryption to secure data sent over the network.

3. **Command Execution:** Executes commands received from the remote host using Invoke-Expression.

4. **Error Handling:** Includes try-catch blocks to manage connection and execution errors.

5. **Two-Way Communication:** Sends and receives data over the network stream.

## `NetworkSpeedTest.ps1`
This script provides a simple way to measure network speed between two computers. For more advanced testing, consider using tools like iPerf or iperf3. Let me know if you need further assistance!

### How It Works

1. Server Side (Receiver):
   - Listens for incoming connections on a specified port.
   - Receives the test file from the client.
   - Calculates the transfer speed based on the file size and transfer time.

2. Client Side (Sender):
   - Connects to the server and sends a test file.
   - The file is generated with random data to simulate a real transfer.

3. Speed Calculation:
   - The script measures the time taken to transfer the file and calculates the speed in MB/s.

### Steps to Use
1. On the Server Computer:
   - Run the script and choose option `1` to start the server.
   - Wait for the client to connect and send the file.

2. On the Client Computer:
   - Run the script and choose option `2` to start the client.
   - The client will send the test file to the server.

3. View the Results:
   - The server will display the transfer speed after receiving the file.

### Requirements
- Both computers must have PowerShell installed.
- Ensure the firewall allows communication on the specified port (`5000` in this case).
- Replace `$serverIP` with the actual IP address of the server.