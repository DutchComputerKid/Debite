#!/bin/bash

# By Quintus Snitjer, built over a LONG time of tweaking and improving server needs.
echo -e "\033[1;34mDebite\033[0m"
echo -en "\033[1;34mVersion: 0.5\033[0m\n"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    if [ -d $scriptdl ]; then rm -rf $scriptdl; fi && unset workdir && printf "${GREEN}Debite: ${NC}Script ended!\n"
fi

# > Install dependencies & set working directory in buffer
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Terminal color codes
RED='\e[1;31m'
NC='\033[0m' # No Colors
GREEN='\e[1;32m'
YELLOW='\033[1m\033[33m'
MAGENTA='\033[1m\033[35m'

#List of available software
declare SoftwareArray=("Setup nonfree and contrib repositories" "Various console-oriented tools" "LXDE Setup" "LXQT Setup" "GUI-Required Tools" "nVidia Driver (latest from repo's)" "Visual Studio Code" "Telegram Desktop" "Wine32+Wine64" "Discord" "Subsonic Music Server" "KVM+Manager" "DeaDBeeF Music Player" "Lutris" "Minecraft Launcher (Official)" "LAMP Stack" "Tor Browser" "Skype For Linux" "Microsoft Teams" "TeamViewer" "Steam" "Google Chrome" "XRDP + Sound support" "MakeMKV (NOT UNATTENDED)" "RubyRipper")
# Display help first if desired
if [[ $@ == *"-help"* ]]; then
    printf "${GREEN}Help: ${NC}Debite can either run via dialog, or command line. \n"
    printf "${GREEN}Help: ${NC}For the command line, the same list of numbers from the text interface is used to choose programs or functions. \n"
    printf "${GREEN}Help: ${NC}This will also allow you to choose your own sequence in which order to install what software. \n"
    printf "${GREEN}Help: ${NC}Would you like to view the list, or just use the interface as a list? \n"
    let "currlist=0"
    select li in "List" "Interface"; do
        case $li in
            List)
                # Iterate the string array using for loop
                for val in "${SoftwareArray[@]}"; do
                    let "currlist=currlist+1"
                    printf "${GREEN}Program $currlist: ${NC} $val \n"
                done
                if [ -d $scriptdl ]; then rm -rf $scriptdl; fi && unset workdir && printf "${GREEN}Debite: ${NC}Script ended!\n" && exit
            ;;
            Interface) printf "${GREEN}Help: ${NC}To use the text interface, please run the script with no arguments. \n" && if [ -d $scriptdl ]; then rm -rf $scriptdl; fi && unset workdir && printf "${GREEN}Debite: ${NC}Script ended!\n" && exit ;;
        esac
    done
fi

if [ ! -e /usr/bin/dialog ]; then
    clear
    echo -e "Installing dependencies to run the installer program..."
    apt -qq install dialog >/dev/null 2>&1
fi

# Set up a working directory
workdir="pwd 3>&1 1>&2 2>&3 3>&1"
eval $workdir >/dev/null 2>&1
cwd=$($eval $workdir)
scriptdl=$cwd/downloads
if [ ! -d $scriptdl ]; then mkdir downloads; fi

#handy functions
yell() { echo "$0: $*" >&2; }
die() {
    yell "$*"
    exit 111
}
try() { "$@" || die "cannot $*"; }

source=/usr/share/debconf/confmodule

#Finish saving other functions
help() {
    echo "Oops, that did not work, or you cancelled! Try running the script without arguments to get a menu instead"
    echo "Or, execute with --help for a how-to use the available switches."
}

textmenu() { #Test user interface, in case you dont use the command line options.
    cmd=(dialog --title "[ Software Installer ]" --separate-output --checklist "Select options:" 22 76 16)
    options=(1 "Add all extra repositories" off # any option can be set to default to "on"
        2 "Console-related tools" off
        3 "LXDE Setup" off
        4 "LXQt Setup" off
        5 "GUI-driven software" off
        6 "nVidia Driver (latest)" off
        7 "Visual Studio Code" off
        8 "Telegram Desktop" off
        9 "Wine32+Wine64" off
        10 "Discord" off
        11 "Subsonic Music Server" off
        12 "KVM+Manager" off
        13 "DeaDBeeF Music Player" off
        14 "Lutris" off
        15 "Minecraft Launcher (Official)" off
        16 "LAMP Stack" off
        17 "Tor Browser" off
        18 "Skype For Linux" off
        19 "Microsoft Teams" off
        20 "TeamViewer" off
        21 "Steam" off
        22 "Google Chrome" off
        23 "XRDP + Sound support" off
        24 "MakeMKV (NOT UNATTENDED)" off
        25 "RubyRipper" off)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for var in $choices; do
        case $var in
            $var) installers ;;
            *) needhelp=true ;; # If something goes wrong
        esac
    done
    ranfromtextmode="true"
}

installers() {
    # Installer triggered, run code from installer list which the main code requested.
    for instll in "$var"; do
        case $instll in
            1)
                DEBIAN_RELEASE=$(cat /etc/*-release 2>/dev/null | grep PRETTY_NAME | awk -F "=" {'print $2'} | awk -F "(" {'print $2'} | awk -F ")" {'print $1'})
                if [ -f "/etc/apt/sources.list.d/nonfree.list" ]; then
                    printf "${MAGENTA}Notice: ${NC}non-free repo has already been installed." && printf "\n"
                else
                    echo "deb http://http.debian.net/debian $DEBIAN_RELEASE non-free" >>/etc/apt/sources.list.d/nonfree.list
                    echo "deb-src http://http.debian.net/debian $DEBIAN_RELEASE non-free" >>/etc/apt/sources.list.d/nonfree.list
                fi
                if [ -f "/etc/apt/sources.list.d/contrib.list" ]; then
                    printf "${MAGENTA}Notice: ${NC}contrib repo has already been installed." && printf "\n"
                else
                    echo "deb http://http.debian.net/debian $DEBIAN_RELEASE contrib" >>/etc/apt/sources.list.d/contrib.list
                    echo "deb-src http://http.debian.net/debian $DEBIAN_RELEASE contrib" >>/etc/apt/sources.list.d/contrib.list
                fi
                if [ -f "/etc/apt/sources.list.d/backports.list" ]; then
                    printf "${MAGENTA}Notice: ${NC}backports repo has already been installed." && printf "\n"
                else
                    echo "deb http://http.debian.net/debian $DEBIAN_RELEASE-backports main contrib" >>/etc/apt/sources.list.d/backports.list
                    echo "deb-src http://http.debian.net/debian $DEBIAN_RELEASE-backports main contrib" >>/etc/apt/sources.list.d/backports.list
                fi
                apt-get update -qq
            ;;
            2)
                #Console-only related tools and other software.
                debconf-apt-progress -- apt install -y htop iptraf-ng stress-ng lm-sensors speedtest-cli build-essential net-tools bind9utils mc iftop iotop nmap nethogs nload acl traceroute lsof tmux vim moc alpine cowsay lynx emacs elinks byobu weechat speedtest-cli mikmod iptraf wordgrinder dtrx pv mtr multitail netcat irssi iotop iftop htop lm-sensors mc antiword cmatrix p7zip hdparm gpm devscripts
            ;;
            3)
                #Official setup for LXDE
                debconf-apt-progress -- apt-get -q -y -o APT::Install-Recommends=true -o APT::Get::AutomaticRemove=true -o APT::Acquire::Retries=3 install task-lxde-desktop
                systemctl set-default multi-user.target
            ;;
            4)
                #Official setup for LXQt
                debconf-apt-progress -- apt-get -q -y -o APT::Install-Recommends=true -o APT::Get::AutomaticRemove=true -o APT::Acquire::Retries=3 install task-lxqt-desktop
                systemctl set-default multi-user.target
            ;;
            5)
                #GUI-related tools, software and other.
                debconf-apt-progress -- apt install -y gsmartcontrol gdebi default-jre gedit firefox-esr audacity hexchat transmission okular
            ;;
            6)
                #nouveau detection procedure. It will detect if the blacklist was activated or not. If its not, then it will do so
                #When this procedure is forgotten, the user is greeted with a black screen and a dead installation.
                declare file="/etc/modprobe.d/blacklist-nvidia-nouveau.conf"
                declare regex="\s+nouveau\s+"
                declare file_content=$(cat "${file}")
                if [[ " $file_content " =~ $regex ]]; then # please note the space before and after the file content
                    printf "${MAGENTA}Notice: ${NC}nouveau blacklist detected, not updating initramfs.\n"
                else
                    bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
                    bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
                    sudo update-initramfs -u 2>/dev/null
                fi
                #nVidia driver install procedure. Also with a detection function.
                if [ -f "/usr/bin/nvidia-settings" ]; then
                    printf "${GREEN}Notice: ${NC}the nVidia drivers already exist." && printf "\n"
                else
                    #If not, download and install.
                    printf "${GREEN}Running: ${NC}nVidia driver\n"
                    (lspci | grep -i --color 'vga\|3d\|2d' | grep -i 'nvidia') && NVHW="true" || NVHW="false" # Look for any installed nVidia hardware
                    if [ $NVHW = "true" ]; then                                                               # If its present, run the drivers.
                        debconf-apt-progress -- apt-get install -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" nvidia-driver linux-headers-$(uname -r | sed 's/[^-]*-[^-]*-//')
                        #Check if it exists now, and if so the installation went OK.
                        if [ -f "/usr/bin/nvidia-settings" ]; then
                            printf "${GREEN}Success: ${NC}nvidia-driver installation complete, reboot required after script." && printf "\n"
                        fi
                    fi
                fi
            ;;
            7)
                #Check for the main bin if it's already been installed.
                if [ -f "/usr/bin/code" ]; then
                    printf "${GREEN}Notice: ${NC}Visual Studio Code has already been installed." && printf "\n"
                else
                    debconf-apt-progress -- apt update
                    debconf-apt-progress -- apt install -y software-properties-common apt-transport-https wget
                    #After running the required software and maybe updating them, see if the repo exists.
                    if [ -f "/etc/apt/sources.list.d/vscode.list" ]; then
                        printf "${MAGENTA}Notice: ${NC}VSCode repo has already been installed." && printf "\n"
                    else
                        #If it doesnt, add it to its own list file.
                        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                        install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
                        sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
                    fi
                    #Continue with the install as usual.
                    debconf-apt-progress -- apt update
                    debconf-apt-progress -- apt install -y code
                    if [ -f "/usr/bin/code" ]; then
                        printf "${GREEN}Success: ${NC}Visual Studio Code has been installed." && printf "\n"
                    fi
                fi
            ;;
            8)
                #Check if TG already exists in target directory:
                if [ -f "/opt/Telegram/Telegram" ]; then
                    printf "${GREEN}Notice: ${NC}Telegram Desktop has already been installed." && printf "\n"
                else
                    #If not, download and install TG.
                    printf "${GREEN}Running: ${NC}Telegram Desktop\n"
                    debconf-apt-progress -- apt install -y gconf2
                    wget -q -O $scriptdl/telegram.tar.xz https://telegram.org/dl/desktop/linux 2>/dev/null && tar -C /opt -xf $scriptdl/telegram.tar.xz 2>/dev/null
                    ln -s /opt/Telegram/Telegram /usr/local/bin/telegram-desktop 2>/dev/null
                    #Check if it exists now, and if so the installation went OK.
                    if [ -f "/opt/Telegram/Telegram" ]; then
                        printf "${GREEN}Success: ${NC}Telegram Desktop has been installed." && printf "\n"
                    fi
                fi
            ;;
            9)
                if [ -f "/usr/bin/wine" ]; then
                    printf "${GREEN}Notice: ${NC}Wine has already been installed." && printf "\n"
                else
                    printf "${GREEN}Running: ${NC}Wine\n"
                    cd $scriptdl
                    # Add architecture
                    dpkg --add-architecture i386 2>/dev/null
                    apt-get update -qq
                    # Install repository
                    wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - 2>/dev/null
                    apt-add-repository https://dl.winehq.org/wine-builds/debian/ 2>/dev/null
                    debconf-apt-progress -- apt install -y libstb0 libstb0:i386 #Dependency for wine
                    apt-get update -qq
                    # Download required audio library
                    wget -qO libfaudio0_20.01-0~buster_amd64.deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/amd64/libfaudio0_20.01-0~buster_amd64.deb
                    dpkg -force-confold --force-confdef -i libfaudio0_20.01-0~buster_amd64.deb &>/dev/null
                    apt-get update -qq
                    # Also in i386 form
                    wget -qO libfaudio0_20.01-0~buster_i386.deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/i386/libfaudio0_20.01-0~buster_i386.deb
                    dpkg -force-confold --force-confdef -i libfaudio0_20.01-0~buster_i386.deb &>/dev/null
                    apt-get update -qq
                    # Main Wine installer
                    debconf-apt-progress -- apt install -y libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386 libcapi20-3:i386 libcups2:i386 libglu1-mesa:i386 libgssapi-krb5-2:i386 libkrb5-3:i386 libodbc1:i386 libosmesa6:i386 libsane:i386 libv4l-0:i386 libxcomposite1:i386 libxslt1.1:i386
                    debconf-apt-progress -- apt install -y winehq-stable winetricks playonlinux wine32 wine64
                    if [ -f "/usr/bin/wine" ]; then
                        printf "${GREEN}Success: ${NC}Wine installation complete.\n"
                    fi
                fi
            ;;
            10)
                if [ -f "/usr/bin/discord" ]; then
                    printf "${GREEN}Notice: ${NC}Discord has already been installed." && printf "\n"
                else
                    printf "${GREEN}Running: ${NC}Discord\n"
                    cd $scriptdl
                    wget -q -O discordapp.deb "https://discordapp.com/api/download?platform=linux&format=deb" 2>/dev/null
                    sudo dpkg --force-confold --force-confdef -i discordapp.deb 2>/dev/null
                    apt-get install -qq -y --fix-broken -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>/dev/null
                    cd $cwd
                    if [ -f "/usr/bin/discord" ]; then
                        printf "${GREEN}Success: ${NC}Discord installation complete.\n"
                    fi
                fi
            ;;
            11)
                printf "${GREEN}Running: ${NC}Subsonic Music Server installation.\n"
                wget -q -O $scriptdl/subsonic.deb "https://s3-eu-west-1.amazonaws.com/subsonic-public/download/subsonic-6.1.6.deb" 2</dev/null
                if [ -f "$scriptdl/subsonic.deb" ]; then # Firstly see if the deb file downloaded.
                    dpkg --force-confold --force-confdef -i $scriptdl/subsonic.deb &>/dev/null
                    minimumsize=851 # one byte smaller then the actual default file to trigger the if test correctly.
                    actualsize=$(wc -c <"/etc/default/subsonic")
                    if [ $actualsize -ge $minimumsize ]; then # After install, check the configuration files that should have been made.
                        printf "${GREEN}Success: ${NC}Subsonic installation complete: \n"
                    else
                        printf "${RED} Notice: ${NC}The configuration file for Subsonic seems smaller then normal, you might want to check it.\n"
                    fi
                else
                    printf "${RED} Something went wrong! Maybe the file is missing?${NC}\n"
                fi
            ;;
            12)
                #Set up KVM with extra's
                #!/bin/bash
                #vmx is for Intel, svm is for AMD.
                PATTERN="vmx\|svm"
                FILE=/proc/cpuinfo
                if grep -q $PATTERN $FILE; then
                    #System CPU detects the virtualization feature
                    #grep vmx /proc/cpuinfo
                    debconf-apt-progress -- apt-get install -y virt-manager qemu-kvm libvirt-clients libvirt-daemon-system
                    if [ $(dpkg-query -W -f='${Status}' virt-manager 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
                        printf "${RED} Notice: ${NC}Failed to detect the precence of virt-manager, check if anything broke!.\n"
                    else
                        systemctl enable --now libvirtd
                        printf "${GREEN}Success: ${NC}KVM/virt-manager installation complete: \n"
                    fi
                else
                    #System is not capable of or has not turned on virtualization.
                    printf "${RED} Notice: ${NC}The system might not be capable of, or has not enabled virtualization.\n"
                fi
            ;;
            13)
                #See if DeaDBeeF exists in its default location.
                if [ -f "/opt/deadbeef/bin/deadbeef" ]; then
                    printf "${GREEN}Notice: ${NC}DeaDBeeF has already been installed." && printf "\n"
                else
                    printf "${GREEN}Running: ${NC}DeaDBeeF\n"
                    cd $scriptdl
                    wget -q -O $scriptdl/deadbeef.deb "https://sourceforge.net/projects/deadbeef/files/travis/linux/1.8.1/deadbeef-static_1.8.1-1_amd64.deb/download" 2>/dev/null
                    #The DPKG will install, but fail due to missing dependencies.
                    dpkg --force-confold --force-confdef -i $scriptdl/deadbeef.deb &>/dev/null
                    #Thus, an apt-get with --fix-broken is used to correct this and set it up correctly.
                    debconf-apt-progress -- apt-get install -qq -y --fix-broken -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef"
                    cd $cwd
                    #Then, see if it exists again and if so, give feedback.
                    if [ -f "/opt/deadbeef/bin/deadbeef" ]; then
                        printf "${GREEN}Success: ${NC}DeaDBeeF installation complete.\n"
                    fi
                fi
            ;;
            14)
                # Check if binary exists
                if [ -f "/usr/games/lutris" ]; then
                    printf "${GREEN}Notice: ${NC}Lutris has already been installed." && printf "\n"
                else
                    # If not, install it.
                    printf "${GREEN}Running: ${NC}Lutris\n"
                    cd $scriptdl
                    echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | sudo tee /etc/apt/sources.list.d/lutris.list
                    wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | sudo apt-key add -
                    debconf-apt-progress -- apt update
                    debconf-apt-progress -- apt install -y lutris
                    cd $cwd
                    if [ -f "/usr/games/lutris" ]; then
                        printf "${GREEN}Success: ${NC}Lutris installation complete.\n"
                    else
                        printf "${RED} Notice: ${NC}Could not detect the Lutris binary, something went wrong!.\n"
                    fi
                fi
            ;;
            15)
                #Check if the required bin has been installed already or is located.
                if [ -f "/usr/bin/minecraft-launcher" ]; then
                    printf "${GREEN}Notice: ${NC}Minecraft has already been installed." && printf "\n"
                else
                    printf "${GREEN}Running: ${NC}Minecraft\n"
                    cd $scriptdl
                    wget -q -O minecraft.deb https://launcher.mojang.com/download/Minecraft.deb 2>/dev/null
                    dpkg --force-confold --force-confdef -i minecraft.deb &>/dev/null
                    cd $cwd
                    #Then, see if it exists again and if so, give feedback.
                    if [ -f "/usr/bin/minecraft-launcher" ]; then
                        printf "${GREEN}Success: ${NC}Minecraft installation complete.\n"
                    else
                        printf "${RED} Notice: ${NC}Could not detect the minecraft binary, something went wrong!.\n"
                    fi
                fi
            ;;
            16)
                #PHP 7.4
                #install reqquired software for the repo.
                debconf-apt-progress -- apt install -y ca-certificates apt-transport-https
                #Check and add repo if required.
                if [ -f "/etc/apt/sources.list.d/php.list" ]; then
                    printf "${MAGENTA}Notice: ${NC}PHP repo has already been installed." && printf "\n"
                else
                    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
                    echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
                fi
                apt update -qq
                
                #Install PHP7.4 from the new repo
                debconf-apt-progress -- apt install -y php7.4
                if [ -f "/usr/bin/php7.4" ]; then
                    #install other PHP modules when the base install went OK.
                    debconf-apt-progress -- apt install -y php7.4-cli php7.4-common php7.4-curl php7.4-mbstring php7.4-mysql php7.4-xml
                else
                    printf "${RED} Notice: ${NC}Could not detect the PHP7.3 binary, something went wrong!.\n"
                fi
                
                #Latest cURL
                if [ -f "/usr/bin/curl" ]; then
                    #install other PHP modules when the base install went OK.
                    printf "${MAGENTA}Notice: ${NC}The cURL package has already been installed." && printf "\n"
                else
                    debconf-apt-progress -- apt install -y curl
                fi
                
                #Apache2 HTML server
                if [ -f "/usr/sbin/apache2" ]; then
                    #install other PHP modules when the base install went OK.
                    printf "${MAGENTA}Notice: ${NC}The apache2 webserver package has already been installed." && printf "\n"
                else
                    #Then check for the apache2 repo.
                    if [ -f "/etc/apt/sources.list.d/apache2.list" ]; then
                        printf "${MAGENTA}Notice: ${NC}Apache2 repo has already been installed." && printf "\n"
                    else
                        wget -q https://packages.sury.org/apache2/apt.gpg -O- | sudo apt-key add -
                        echo "deb https://packages.sury.org/apache2 stretch main" | sudo tee /etc/apt/sources.list.d/apache2.list
                    fi
                    #Then install apache2 via the official command.
                    debconf-apt-progress -- apt-get -y -o APT::Install-Recommends=true -o APT::Get::AutomaticRemove=true -o APT::Acquire::Retries=3 install task-web-server
                fi
                #If the server has not been updated in a while, a sirtuation can appear where the non-installed software listed above needs updating.
                debconf-apt-progress -- apt -y upgrade
            ;;
            17)
                #Check if the required bin has been installed already or is located.
                if [ -f "/usr/bin/torbrowser-launcher" ]; then
                    printf "${GREEN}Notice: ${NC}Tor Browser has already been installed." && printf "\n"
                else
                    #Check and add repbackports if required.
                    if [ -f "/etc/apt/sources.list.d/backports.list" ]; then
                        printf "${MAGENTA}Notice: ${NC}Debian Backports repo has already been installed." && printf "\n"
                    else
                        printf "${MAGENTA}Notice: ${NC}Adding Debian Backports to system." && printf "\n"
                        printf "deb http://deb.debian.org/debian buster-backports main contrib" >/etc/apt/sources.list.d/buster-backports.list
                        apt update
                    fi
                    #grab torbrowser-launcher from the Backporst repo.
                    debconf-apt-progress -- apt install -y torbrowser-launcher -t buster-backports
                    if [ -f "/usr/bin/torbrowser-launcher" ]; then
                        printf "${GREEN}Success: ${NC}Tor Browser installation complete.\n"
                    else
                        printf "${RED} Notice: ${NC}Could not detect the torbrowser binary, you might want to add contrib to /etc/apt/sources.list.d/buster-backports.list then try again.\n"
                    fi
                fi
            ;;
            18)
                printf "${GREEN}Running: ${NC}SkypeForLinux\n"
                #Check for / install the skypeforlinux repo.
                if [ -f "/usr/bin/skypeforlinux" ]; then
                    printf "${MAGENTA}Notice: ${NC}Skype has already been installed." && printf "\n"
                else
                    cd $scriptdl
                    wget -L -q -O skype.deb https://go.skype.com/skypeforlinux-64.deb
                    dpkg --force-confold --force-confdef -i skype.deb &>/dev/null
                fi
                if [ -f "/usr/bin/skypeforlinux" ]; then
                    printf "${GREEN}Success: ${NC}Microsoft Skype installation complete.\n"
                fi
                #Done
            ;;
            19)
                #Microsoft teams DEB installer
                if [ -f "/usr/bin/teams" ]; then
                    printf "${GREEN}Notice: ${NC}Microsoft Teams has already been installed." && printf "\n"
                else
                    printf "${GREEN}Running: ${NC}Microsoft Teams\n"
                    cd $scriptdl
                    #Download latest DEB
                    printf "${GREEN}Notice: ${NC}Downloading, might take a while..." && printf "\n"
                    wget -L -q -O teams-latest.deb "https://go.microsoft.com/fwlink/p/?linkid=2112886&clcid=0x409&culture=en-us&country=us" 2>/dev/null
                    #Install the DEB itself.
                    dpkg --force-confold --force-confdef -i teams-latest.deb &>/dev/null
                    #Just in case, check for and fix missing libraries
                    debconf-apt-progress -- apt-get install -qq -y --fix-broken -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>/dev/null
                    #Return to script
                    cd $cwd
                    if [ -f "/usr/bin/teams" ]; then
                        printf "${GREEN}Success: ${NC}Microsoft Teams installation complete.\n"
                    fi
                fi
            ;;
            20)
                #TeamViewer Installer
                if [ -f "/usr/bin/teamviewer" ]; then
                    printf "${GREEN}Notice: ${NC}TeamViewer has already been installed." && printf "\n"
                else
                    printf "${GREEN}Running: ${NC}TeamViewer \n"
                    cd $scriptdl
                    #Download latest DEB
                    printf "${GREEN}Notice: ${NC}Downloading, might take a while..." && printf "\n"
                    wget -L -q -O teamviewer_amd64.deb "https://download.teamviewer.com/download/linux/teamviewer_amd64.deb" 2>/dev/null
                    #Install the DEB itself.
                    dpkg --force-confold --force-confdef -i teamviewer_amd64.deb &>/dev/null
                    #Just in case, check for and fix missing libraries
                    debconf-apt-progress -- apt-get install -qq -y --fix-broken -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>/dev/null
                    #Return to script
                    cd $cwd
                    if [ -f "/usr/bin/teamviewer"]; then
                        printf "${GREEN}Success: ${NC}TeamViewer installation complete.\n"
                    fi
                fi
            ;;
            21)
                
                #Steamy stuff
                # Check if binary exists
                if [ -f "/usr/games/steam" ]; then
                    printf "${GREEN}Notice: ${NC}Steam has already been installed." && printf "\n"
                else
                    #Check for repo existence
                    if [ -f "/etc/apt/sources.list.d/nonfree.list" ]; then
                        printf "${MAGENTA}Notice: ${NC}non-free repo has already been installed." && printf "\n"
                    else
                        echo "deb http://http.debian.net/debian $DEBIAN_RELEASE non-free" >>/etc/apt/sources.list.d/nonfree.list
                        echo "deb-src http://http.debian.net/debian $DEBIAN_RELEASE non-free" >>/etc/apt/sources.list.d/nonfree.list
                    fi
                    #Add i386 support
                    dpkg --add-architecture i386
                    #Update stuffs
                    debconf-apt-progress -- apt update
                    #Install Steam
                    debconf-apt-progress -- apt install -y steam
                    #Add Vulkan if missing
                    debconf-apt-progress -- apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
                    #Just in case, check for and fix missing libraries: Sometimes the repos are messed up and steam will be missing a buttton of libraries.
                    debconf-apt-progress -- apt-get install -qq -y --fix-broken -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>/dev/null
                    if [ -f "/usr/games/steam" ]; then
                        printf "${GREEN}Success: ${NC}Steam installation complete.\n"
                    else
                        printf "${RED} Notice: ${NC}Could not detect the steam binary, some libraries might be missing.\n"
                    fi
                fi
            ;;
            22)
                #Microsoft teams DEB installer
                if [ -f "/usr/bin/google-chrome" ]; then
                    printf "${GREEN}Notice: ${NC}Google Chrome has already been installed." && printf "\n"
                else
                    printf "${GREEN}Running: ${NC}Google Chrome \n"
                    cd $scriptdl
                    #Download latest DEB
                    printf "${GREEN}Notice: ${NC}Downloading, might take a while..." && printf "\n"
                    wget -q -O chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" 2>/dev/null
                    #Install the DEB itself.
                    dpkg --force-confold --force-confdef -i chrome.deb &>/dev/null
                    #Just in case, check for and fix missing libraries
                    debconf-apt-progress -- apt-get install -qq -y --fix-broken -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>/dev/null
                    #Return to script
                    cd $cwd
                    if [ -f "/usr/bin/google-chrome" ]; then
                        printf "${GREEN}Success: ${NC}Google Chrome installation complete.\n"
                    else
                        printf "${RED}Notice: ${NC}Could not detect the Google Chrome binary, oh no. \n"
                    fi
                fi
            ;;
            23)
                printf "${GREEN}Running: ${NC}XRDP plus sound module... \n"
                # 12.2-4+deb10u1
                # Step 1 - Install Some PreReqs
                debconf-apt-progress -- apt -qq -y install git libpulse-dev autoconf m4 intltool build-essential dpkg-dev
                debconf-apt-progress -- apt build-dep pulseaudio -qq -y 2>/dev/null
                
                #  Download pulseaudio source in /tmp directory - Do not forget to enable source repositories
                cd /tmp
                sudo apt source -qq pulseaudio=12.2-4+deb10u1 2>/dev/null
                
                # Compile
                pulsever=$(pulseaudio --version | awk '{print $2}') # This might arrise issues.
                cd /tmp/pulseaudio-$pulsever
                sudo ./configure -s 2>/dev/null
                
                # Create xrdp sound modules
                sudo git clone --quiet https://github.com/neutrinolabs/pulseaudio-module-xrdp.git 2>/dev/null
                cd pulseaudio-module-xrdp
                sudo ./bootstrap -s 2>/dev/null
                sudo ./configure -s PULSE_DIR="/tmp/pulseaudio-$pulsever" 2>/dev/null
                sudo make -s 2>/dev/null
                
                #copy files to correct location (as defined in /etc/xrdp/pulse/default.pa)
                cd /tmp/pulseaudio-$pulsever/pulseaudio-module-xrdp/src/.libs 2>/dev/null
                sudo install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so 2>/dev/null
                
                #See if XRDP itself exists, otherwise dont install it.
                if [ -f "/usr/sbin/xrdp" ]; then
                    printf "${GREEN}Notice: ${NC}XRDP itself seems to be installed already.\n"
                else
                    printf "${RED}Notice: ${NC}Could not detect the XRDP binary, installing with VNC. \n"
                    debconf-apt-progress -- apt -qq -y install xrdp tigervnc-standalone-server
                fi
                
                #Check for files
                if [ -f /etc/xrdp/pulse/default.pa -a -f /usr/sbin/xrdp ]; then
                    printf "${GREEN}XRDP: ${NC}main executable and sound module detected! Please reboot system soon.\n"
                else
                    printf "${RED}Notice: ${NC}Could not detect the XRDP binary and sound module, oh no. \n"
                fi
            ;;
            24)
                MakeMKVVersion="1.16.4"
                if [ -f "/usr/bin/makemkv" ]; then
                    printf "${GREEN}Notice: ${NC}MakeMKV itself seems to be installed already: forcing update...\n"
                fi
                cd $scriptdl
                printf "${GREEN}Notice: ${NC}Building MakeMKV v$MakeMKVVersion. \n"
                #Download source
                wget -q https://www.makemkv.com/download/makemkv-bin-$MakeMKVVersion.tar.gz 2>/dev/null
                wget -q https://www.makemkv.com/download/makemkv-oss-$MakeMKVVersion.tar.gz 2>/dev/null
                #Build deps
                debconf-apt-progress -- apt -qq -y install build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev qtbase5-dev zlib1g-dev
                #Unpack source files
                tar xzf makemkv-bin-$MakeMKVVersion.tar.gz 2>/dev/null
                tar xzf makemkv-oss-$MakeMKVVersion.tar.gz 2>/dev/null
                #Start building
                cd makemkv-oss-$MakeMKVVersion/
                ./configure 2>/dev/null
                make -s  2>/dev/null
                sudo make install -s 2>/dev/null
                cd ..
                cd makemkv-bin-$MakeMKVVersion
                #Will ask for user input!
                printf "${GREEN}MakeMKV: ${NC}Accept EULA: \n"
                make -s
                sudo make install -s
                cd ..
                #Remove left overs
                rm -R makemkv-oss-$MakeMKVVersion
                rm -R makemkv-bin-$MakeMKVVersion
                rm -R *.tar.gz*
                #Check for files
                if [ -f /usr/bin/makemkv ]; then
                    printf "${GREEN}MakeMKV: ${NC}main executable detected! Installation complete.\n"
                else
                    printf "${RED}Notice: ${NC}Could not detect the MakeMKV binary, something might have gone wrong. \n"
                fi
                cd $cwd
            ;;
            25)
                if [[ -f  /usr/bin/rrip_cli && -f /usr/bin/rrip_gui ]]; then
                    printf "${GREEN}Notice: ${NC}RubyRipper has already been installed." && printf "\n"
                else
                    cd $scriptdl
                    #Install requiresites
                    debconf-apt-progress -- sudo apt -y install cd-discid cdparanoia flac lame normalize-audio ruby-gnome2 ruby vorbisgain cd-discid ruby-gettext ruby-gtk3 sox cdrdao
                    #Download latest from source
                    git clone https://github.com/bleskodev/rubyripper 2>/dev/null
                    cd rubyripper 
                    #Build from source, install to system.
                    ./configure --enable-lang-all --enable-gtk3 --enable-cli --prefix=/usr 2>/dev/null
                    make install -s 2>/dev/null
                    if [[ -f /usr/bin/rrip_cli && -f /usr/bin/rrip_gui ]]; then
                        printf "${GREEN}RubyRipper: ${NC}scripts detected! Installation complete.\n"
                    else
                        printf "${RED}Notice: ${NC}Could not detect the one or both of the RubyRipper scripts, something might have gone wrong. \n"
                    fi
                fi
                cd $cwd
            ;;
        esac
    done
}

#Program start
echo -e "Updating/checking dependencies to run..."
apt-get install --no-install-recommends -qq -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" dialog debconf-apt-progress 2>/dev/null
debconf-apt-progress -- apt install -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" curl git software-properties-common
#Ready

if [ $# -eq 0 ]; then
    echo "No arguments supplied, launching TUI..."
    sleep 1
    textmenu #Open the dialog-based selection menu
else
    #if the user after viewing help would like to use the text menu, do so.
    if [ "$startwithdialog" = true ]; then
        textmenu
    fi
    
    #If not, continue.
    #Check if an user is inputting values that exceed the program count, but not if help is found in the arguments.
    for args in ${@//[!0-9]/}; do
        if [ $args -ge 26 ]; then
            echo "A number in the arguments was greater then the amount of scripted tools or programs. Please check with --help" && printf "\n"
            printf "${MAGENTA}Notice: ${NC} '[: --help: integer expression expected' is a known error, you may ignore it. \n"
            if [ -d $scriptdl ]; then rm -rf $scriptdl; fi && unset workdir && printf "${GREEN}Debite: ${NC}Script ended!\n" && exit
        fi
        #Can result in a [: --help: integer expression expected error.
    done
    
    # #If textmenu was used but cancelled, then the selection confirmation reads the highest in the array. To avoid this, dont run it when textmode was used.
    #if [ !"$startwithdialog" = true ]; then
    #Show user what was selected to install
    printf "${GREEN}Selected: ${NC}"
    for args in $@; do
        for val in "${SoftwareArray[args - 1]}"; do # Minus one cause arrays start at 0, otherwise it would shift all up by 1.
            printf " $val //"
        done
    done
    printf "\n" # New line
    echo "Check: Is this list of selected programs correct?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes)
                break
            ;;
            No) if [ -d $scriptdl ]; then rm -rf $scriptdl; fi && unset workdir && printf "${GREEN}Debite: ${NC}Script ended!\n" && exit ;;
        esac
    done
    # fi
    
    #Execute said installers.
    for var in "${@,,}"; do # The ,, converts all inputs that pass the for loop to lowercase
        case $var in        #Arguments are automatically transferred
            "$var") installers ;;
            *) needhelp='true' ;;
        esac
    done
fi
# > Unload and delete cached stuff
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

if [ -d $scriptdl ]; then rm -rf $scriptdl; fi
unset workdir

# Display help if needed
if [ "$needhelp" = "true" ]; then
    help #display help
fi

printf "${GREEN}Debite: ${NC}Script complete!\n"
