# Kali Security Shell

A comprehensive penetration testing environment providing 29 security tools from Kali Linux, packaged for reproducible deployment across any platform.

## Getting Started

Launch the Kali security environment:
```bash
nix develop .#kali
```

## Security Tools Available

### Web Application Testing
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **ffuf** | Fast web fuzzer | `ffuf -u https://target.com/FUZZ -w wordlist.txt` |
| **gobuster** | Directory/file brute forcer | `gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt` |
| **dirb** | Web content scanner | `dirb https://target.com` |
| **sqlmap** | SQL injection tester | `sqlmap -u "https://target.com/page?id=1"` |
| **nikto** | Web server scanner | `nikto -h https://target.com` |
| **wpscan** | WordPress scanner | `wpscan --url https://wordpress-site.com` |
| **burpsuite** | Web proxy & scanner | `burpsuite` |

### Network Reconnaissance
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **nmap** | Network mapper | `nmap -sS -O target.com` |
| **masscan** | High-speed port scanner | `masscan -p1-65535 10.0.0.0/8 --rate=1000` |
| **netcat** | Network swiss army knife | `nc -lvp 4444` |
| **socat** | Advanced relay tool | `socat TCP-LISTEN:8080,fork TCP:target.com:80` |

### Credential Testing
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **john** | Password cracker | `john --wordlist=rockyou.txt hashes.txt` |
| **hashcat** | Advanced password recovery | `hashcat -m 0 -a 0 hashes.txt wordlist.txt` |
| **thc-hydra** | Network login brute forcer | `hydra -l admin -P passwords.txt ssh://target.com` |
| **medusa** | Modular login brute forcer | `medusa -h target.com -u admin -P passwords.txt -M ssh` |

### SMB/Windows Enumeration
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **enum4linux** | SMB enumeration (classic) | `enum4linux target.com` |
| **enum4linux-ng** | SMB enumeration (modern) | `enum4linux-ng target.com` |

### DNS Intelligence
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **dnsenum** | DNS record enumeration | `dnsenum domain.com` |

### Wireless Security
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **aircrack-ng** | WiFi security testing | `aircrack-ng capture.cap -w wordlist.txt` |

### Intelligence Gathering
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **theharvester** | Email & subdomain harvester | `theharvester -d target.com -b google` |
| **whatweb** | Web technology fingerprinter | `whatweb target.com` |
| **recon-ng** | Reconnaissance framework | `recon-ng -w workspace_name` |

### Memory Analysis
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **vol** | Volatility 3 forensics | `vol -f memory.dump windows.info` |
| **volatility2** | Volatility 2 forensics | `volatility2 -f memory.dump --profile=Win7SP1x64 pslist` |

### Reverse Engineering
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **radare2** | Binary analysis framework | `r2 binary` |
| **objdump** | Object file disassembler | `objdump -d binary` |
| **strings** | Extract printable strings | `strings binary \| grep -i password` |
| **binwalk** | Firmware analysis tool | `binwalk -e firmware.bin` |

### Exploitation
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **metasploit** | Exploitation framework | `msfconsole` |

### Network Analysis
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **wireshark** | Packet analyzer (GUI) | `wireshark` |
| **tcpdump** | Packet capture (CLI) | `tcpdump -i eth0 host target.com` |

### Essential Utilities
| Tool | Purpose | Quick Start |
|------|---------|-------------|
| **curl** | HTTP client | `curl -X POST https://api.target.com/endpoint` |
| **wget** | File downloader | `wget https://target.com/file.txt` |

## Environment Features

### Automatic Setup
When launching the Kali shell, these directories are created automatically:
- `~/.config/kali` - Tool configurations
- `~/.local/share/wordlists` - Security wordlists storage
- `~/.local/share/kali-tools` - Additional tool data

### Environment Variables
Pre-configured variables for seamless tool integration:
- `KALI_ROOT` - Base directory (`~/.local/share/kali`)
- `BURP_USER_CONFIG_FILE` - Burp Suite configuration path
- `NO_AT_BRIDGE=1` - Suppresses GUI warnings for headless usage

## Tool Categories Summary

| Category | Tool Count | Examples |
|----------|------------|----------|
| Web Application Testing | 7 | ffuf, burpsuite, sqlmap |
| Network Reconnaissance | 4 | nmap, masscan, netcat |
| Credential Testing | 4 | john, hashcat, hydra, medusa |
| Reverse Engineering | 4 | radare2, objdump, strings, binwalk |
| Memory Analysis | 2 | vol, volatility2 |
| SMB Enumeration | 2 | enum4linux, enum4linux-ng |
| Intelligence Gathering | 3 | theharvester, whatweb, recon-ng |
| Other Specialties | 6 | metasploit, aircrack-ng, dnsenum |

**Total: 32 Security Tools**

## Platform Support
- **Linux** (x86_64, ARM64)
- **macOS** (Intel, Apple Silicon)
- **Windows** (WSL2)
- **Containers** (Docker, Podman)

## Advantages

### Reproducible Environments
Every tool installation is identical across systems, eliminating "works on my machine" issues common in security testing environments.

### No System Pollution
Tools run in isolated environments without affecting your host system or conflicting with other software.

### Instant Provisioning
Launch a fully-equipped penetration testing environment in seconds, not hours of manual tool installation.

### Version Consistency
All team members use identical tool versions, ensuring consistent results across security assessments.

### Cross-Platform
Same environment works identically on Linux, macOS, and Windows (via WSL2).

## Use Cases

- **Penetration Testing**: Comprehensive toolkit for security assessments
- **Bug Bounty Hunting**: Quick access to reconnaissance and exploitation tools
- **Security Research**: Reproducible environment for tool testing and development
- **Training**: Consistent environment for security education
- **CTF Competitions**: Rapid deployment of security tools

## Comparison to Traditional Kali Linux

| Feature | Traditional Kali | Kalilix Kali Shell |
|---------|------------------|-------------------|
| Installation Time | 2-4 GB download + setup | Seconds (cached builds) |
| System Requirements | Full VM or bare metal | Any system with Nix |
| Reproducibility | Manual package management | Declarative, reproducible |
| Version Consistency | Varies by installation date | Pinned, identical everywhere |
| Resource Usage | Full OS overhead | Minimal, shell-only |
| Platform Support | Linux-focused | Linux, macOS, Windows |

This Kali security shell provides the essential penetration testing capabilities of Kali Linux in a modern, reproducible package management system suitable for professional security work.