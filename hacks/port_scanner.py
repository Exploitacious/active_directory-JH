import socket
import termcolor


def add_ports(target, ports):
    print(f"scanning {target}")
    for port in range(1, ports):
        scan_port(target, port)


def scan_port(target, port):
    try:
        sock = socket.socket()
        sock.connect((target, port))
        print(termcolor.colored(
            f" [+] port {str(port)} open on {str(target)}", 'green'))
        sock.close()
    except:
        pass


# input(str("[*] Enter Targets (split by commas)\n"))
targets = "192.168.146.123"
# input(int("[*] Enter ending port (scan port 1 - <enteredPort>)\n"))
ports = 50

print("Scanning for open ports on specified targets.")

if ',' in targets:
    print("[*] Scanning multiple targets")
    for ip_addr in targets.split(','):
        target = ip_addr.strip(' ')
        add_ports(target, ports)
else:
    print("[*] Scanning single target")
    add_ports(targets, ports)
