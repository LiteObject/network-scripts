# Network Scripts

## `TCPRemoteShell.ps1` Script Summary
This PowerShell script establishes a TCP connection to a remote host at a specified IP address and port. It provides a basic **remote command execution** capability, allowing commands to be sent to the remote host, executed locally, and the results returned. The script includes:

1. **TCP Client Setup:** Connects to a remote IP and port.

2. **Data Encryption:** Uses AES encryption to secure data sent over the network.

3. **Command Execution:** Executes commands received from the remote host using Invoke-Expression.

4. **Error Handling:** Includes try-catch blocks to manage connection and execution errors.

5. **Two-Way Communication:** Sends and receives data over the network stream.