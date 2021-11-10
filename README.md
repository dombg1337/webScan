# webScan (c) dombg

## Description

The script automates common and important steps in (pen-)testing a webserver to save time during an engagement or for sys-admins after setting it up. 

Even though these are common checks, the tests performed barely touch the surface of web-app-security audits and only check common things of the webserver hosting the web-app. Web-app-security audits require a lot of manual testing. It is recommended to follow guides like the one from OWASP: https://owasp.org/www-project-web-security-testing-guide/v42/ and to supplement it with additional resources.

## Execution

1. Run nmap safe scripts (-sC) and service+version (-sV) enumeration on IP and PORT.
2. Run cipher checks with nmap's ssl_enum-ciphers script.
3. Perform certificate checks (if domain is provided).
4. Run nikto scan on domain, or else on ip:port. 
5. Optionally runs nmap vuln scripts (--scripts="vuln") as an additional scan.

Output is stored in all possible formats (nikto in txt,xml).

## Help
![image](https://user-images.githubusercontent.com/7427205/137322622-d964e72e-2673-4a00-90d6-fe19dd6f6c72.png)

Mind: Please don't grant users permanent sudo rights to this script, easy PrivEsc via Command Injection since I don't sanitize any input.

### Usage examples

```
sudo ./webScan --ip 192.168.1.2 --port 443
sudo ./webScan --ip 192.168.1.2 --port 443 --domain foo.bar --vuln
```

## Requirements

- [nmap](https://nmap.org/)
- [nikto](https://github.com/sullo/nikto)

## Disclaimer

webScan is written for webserver assessments where the scanning is explicitly allowed by the owner of the target system, please use it responsively. I'm not responsible for any misuse of this tool.
