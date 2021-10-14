# webScan (c) dombg

## Why should I use webScan?

The script simply automates common and important steps in pen-testing a website to save time during an engagement. 

Even though these are common steps, the tests performed barely touch the surface of web-app-security audits which requires a lot of manual testing. It is recommended to follow guides like the one from OWASP: https://owasp.org/www-project-web-security-testing-guide/v42/ and to supplement it with additional resources.

## Execution

1. Run nmap safe scripts (-sC) and service+version (-sV) enumeration on IP and PORT.
2. Run cipher checks with nmap's ssl_enum-ciphers script.
3. Perform certificate checks (if domain is provided).
4. Run nikto scan on domain, or else on ip:port. 
5. Optionally runs nmap vuln scripts (--scripts="vuln") as an additional scan.

## Help
![image](https://user-images.githubusercontent.com/7427205/137287716-f8af3411-0f59-4cc0-a59d-5c2de77a70c9.png)

Mind: Please don't grant users permanent sudo rights to this script, easy PrivEsc via Command Injection since I don't sanitize any input.
