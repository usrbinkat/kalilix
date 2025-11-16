{ pkgs, lib, system, ... }:

let
  # Helper to check if running on Linux
  isLinux = lib.strings.hasSuffix "-linux" system;
in
{
  # Security tools that are already in nixpkgs
  # These are direct references to nixpkgs packages
  nixpkgsSecurityTools = with pkgs; [
    # Cross-platform tools (darwin + linux)
    ffuf # Fast web fuzzer
    nmap # Network discovery and security auditing
    aircrack-ng # Wireless security auditing
    hashcat # Password recovery utility
    wireshark # Network protocol analyzer
    curl # Command line HTTP client
    wget # File retriever
    netcat # TCP/UDP swiss army knife
    socat # Multipurpose relay tool
    tcpdump # Command-line packet analyzer
  ] ++ lib.optionals isLinux [
    # Linux-only tools
    burpsuite # Web application security testing (Linux only)
  ];

  # Custom kali-style desktop entries for security tools
  kali-desktop-entries = pkgs.writeText "kali-security-desktop-entries" ''
    # Desktop entries for Kali-style menu integration
    # These follow the Kali Linux convention for security tools
  '';

  # Default ffuf configuration following Kali conventions
  ffuf-config = pkgs.writeText "ffuf-default.conf" ''
    # Kalilix ffuf Configuration
    # Default settings optimized for security testing

    # General settings
    threads: 40
    timeout: 10

    # Output settings
    color: true
    verbose: false

    # Matcher defaults (match successful responses)
    match-codes: 200-299,301,302,307,401,403,405,500

    # Filter settings (common false positives)
    # Note: These can be overridden via command line
  '';

  # Kali-style ffuf wrapper with default config
  ffuf-kali = pkgs.writeShellApplication {
    name = "ffuf";
    runtimeInputs = [ pkgs.ffuf ];
    text = ''
      # Check if user provided explicit config
      if [[ " $* " == *" -config "* ]]; then
        # User provided config, use it directly
        exec ffuf "$@"
      else
        # For now, just use vanilla ffuf (config integration later)
        exec ffuf "$@"
      fi
    '';
  };
}

