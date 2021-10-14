#!/bin/bash

function printHelp {
    printBanner
    echo "Usage:"
    echo "    -ip/--ip 192.168.1.1          | set the target ip                          | required"
    echo "    -p/--port 443                 | set the target ip                          | required"
    echo "    -d/--domain target.example    | set the target domain		       | optional"
    echo "    --vuln                        | if set, triggers nmap vuln scripts         | optional"
    echo "    -e/--interface tun0           | specify network interface, default: eth0   | optional"
    echo "    -h/--help                     | display the help menu"
    
    exit 1
}

function printBanner {
	/usr/bin/base64 -d <<<"H4sIAAAAAAAAA5VQQQ7DMAi75xXclkpr+c1OSPQhefyMSdNFnbQOmjRg7BCKTOa5h8kXi+yJXEumTJmgBhdRirersgZk8I/iK31IH02wU2CITfZ13ZiKHunemVnE+h5KwnFKuiRJSjShxoZC9DGUDQnH2sFgNpjaJSUBcgjv42Qdw0BMXoKPU1Bcu+CmOKlUqFQqnV7dj0PuywQ3xolh1ubQUvzA8s0jcu8JrCeywSHTjoEkEKEOuNOJpfR9M8dYFOQfxuf/J33TWrylvAGWQbLG1wIAAA==" | /usr/bin/gunzip
}

# check if no argument was supplied and print help

function printSeparator {
	printf "\n"
	/usr/bin/base64 -d <<<"H4sIAAAAAAAAA+NSiAcDSimuGgiDUoqLCwBNcUR3kgAAAA==" | /usr/bin/gunzip
	printf "\n"
}

if [ -z "$1" ]; then
    echo "No argument supplied"
    printHelp
    exit 1
fi

# set values to default
ip=""
port=""
domain=""
vuln=""
interface="eth0"

# Load the user defined parameters
while [[ $# > 0 ]]
do
	case "$1" in
		-ip|--ip)
			ip="$2"
			shift #pop the first parameter in the series, making what used to be $2, now be $1.
			;;
		-p|--port)
			port="$2"
			shift
			;;
		-d|--domain)
			domain="$2"
			shift
			;;
		--vuln)
			vuln=1
			shift
			;;
		-e|--interface)
			interface="$2"
			shift
			;;
		-h|--help)
			printHelp
			;;
	esac
	shift
done

# check if required parameters were !supplied: print help menu and exit
if [[ -z $ip || -z $port ]]; then
	echo "Please supply an IP and PORT to test"
	printHelp
fi

printBanner
printSeparator

# 1. prepare result directory

currentDate=`/usr/bin/date "+%Y%m%d-%H%M%S"`
resultDirectory="/tmp/webScan_results_"$ip"_"$currentDate"/"
printf "Preparing output directory\n\n"
printf "Results are stored in /tmp folder: "$resultDirectory"\n"
mkdir $resultDirectory
printSeparator

# 2. run nmap service and version scan

printf "Run nmap service and version scan "$ip":$port\n\n"
nmapServiceScanOutputFile=$resultDirectory"nmapServiceScanOutput"
printf "Command: /usr/bin/nmap -p$port $ip -sC -sV -oA $nmapServiceScanOutputFile\n\n"

(/usr/bin/nmap -p$port $ip -sC -sV -oA $nmapServiceScanOutputFile && printf "nmap service and version scan succesful")

printSeparator

# 3. run nmap ssl enum ciphers

printf "Check ciphers with nmap ssl-enum-ciphers\n\n"
printf "Command: /usr/bin/nmap -p$port $ip --script=\"ssl-enum-ciphers\"\n\n"
printf "Understanding the results: Least strength is the weakest cipher/link, with A being the best rating and F being the worst. \n TLS >= TLSv1.2 is considered secure.\n\n"
sleep 2
nmapCipherScanOutputFile=$resultDirectory"nmapCipherScanOutput"
(/usr/bin/nmap -p$port $ip --script="ssl-enum-ciphers" -oA $nmapCipherScanOutputFile && printf "nmap cipher scan successful")
printSeparator

# 4. run certificate check if domain is set

if [ $domain ]; then
	printf "Run certificate check\n\n"
	printf "Command: /usr/bin/openssl s_client -showcerts -connect "$domain":"$port" -servername $domain <<< "Q"\n\n"  
	sleep 2
	certificateCheckOutputFile=$resultDirectory"certificateCheckOutput"
	(/usr/bin/openssl s_client -showcerts -connect $domain":"$port -servername $domain <<< "Q" | /usr/bin/tee $certificateCheckOutputFile && printf "certs check successful")
	printSeparator
fi

# 5. run nikto scan on domain or on ip and port if domain is not set

niktoScanOutputFile=$resultDirectory"niktoScanOutput"
printf "Run nikto scan on domain or otherwise ip and port\n\n"
if [ $domain ]; then
	printf "Command: /usr/bin/nikto -h $domain -o $niktoScanOutputFile -Format xml\n\n" 		
	sleep 2
	(/usr/bin/nikto -h $domain -o $niktoScanOutputFile -Format txt,xml && printf "nikto scan successful")
	printSeparator
else
	printf "Command: /usr/bin/nikto -h $ip":"$port -output $niktoScanOutputFile\n\n" 		
	sleep 2
	(/usr/bin/sudo /usr/bin/nikto -h $/usr/bin/nikto -h $ip":"$port -o $niktoScanOutputFile -Format xml && printf "nikto scan succcessful")
	printSeparator

fi

# 6. run nmap vuln scan ip and port if --vuln is set

if [ $vuln ]; then
	printf "Run nmap vuln scan on ip and port\n\n"
	nmapVulnScanOutputFile=$resultDirectory"nmapVulnScanOutput"
	printf "Command: /usr/bin/sudo /usr/bin/nmap -p$port --script="vuln" -oA $nmapVulnScanOUtputFile $ip\n\n" 	
	
	sleep 2
	(/usr/bin/sudo /usr/bin/nmap -p$port --script="vuln" -oA $nmapVulnScanOUtputFile $ip && printf "vuln Scan successful")
	printSeparator
fi

printf "Results are stored in: "$resultDirectory
