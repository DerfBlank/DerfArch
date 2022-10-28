#!/bin/bash

# Derf Arch Installer - UEFI
# Revision: 2022.10.30 -- by Derf (https://sourceforge.net/projects/derf/)
# (GNU/General Public License version 4.0)

# ----------------------------------------
# Define Variables
# ----------------------------------------

MYTMZ="America/Phoenix"
# List possible timezones from: /usr/share/zoneinfo/...

LCLST="en_US"
# Format is language_COUNTRY where language is lower case two letter code
# and country is upper case two letter code, separated with an underscore

KEYMP="us"
# Use lower case two letter country code

# ---------------------------------------
# Define Functions:
# ---------------------------------------

handlerr () {
  clear
  set -uo pipefail
  trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
  clear
}

welcome () {
  clear
  echo "==================================================="
  echo "=                                                 ="
  echo "=     Welcome to the Derf Installer Script        ="
  echo "=                                                 ="
  echo "=     UEFI Edition                                ="
  echo "=     Revision: 2022.10.30                        ="
  echo "=                                                 ="
  echo "=     Brought to you by eznix                     ="
  echo "=                                                 ="
  echo -e "=================================================== \n"
  sleep 4
}

hrdclck () {
  clear
  timedatectl set-ntp true
}

usrname () { 
  clear
  echo -e "\n"
  read -p "Type your user name, be exact, and press Enter: " USRNAME
  [[ -z "$USRNAME" ]] && usrname
  clear
  echo -e "\n"
  echo "User name set to "${USRNAME}"..."
  sleep 2
  clear
}

usrpwd () { 
  clear
  echo -e "\n"
  read -p "Type your user password, be exact, and press Enter: " USRPWD
  [[ -z "$USRPWD" ]] && usrpwd
  clear
  echo -e "\n"
  echo "User password set to "${USRPWD}"..."
  sleep 2
  clear
}

rtpwd () { 
  clear
  echo -e "\n"
  read -p "Type your root password, be exact, and press Enter: " RTPWD
  [[ -z "$RTPWD" ]] && rtpwd
  clear
  echo -e "\n"
  echo "Root password set to "${RTPWD}"..."
  sleep 2
  clear
}

hstname () { 
  clear
  echo -e "\n"
  read -p "Type your hostname, be exact, and press Enter: " HSTNAME
  [[ -z "$HSTNAME" ]] && hstname
  clear
  echo -e "\n"
  echo "Hostname set to "${HSTNAME}"..."
  sleep 2
  clear
}

swapsize () {
  clear
  echo -e "\n"
  read -p "Pick Swap Partition Size (2G, 4G, or 8G): " SWPSIZE
  case $SWPSIZE in
    2|2G|2g)
    SWPSIZE=2GiB
    ;;
    4|4G|4g)
    SWPSIZE=4GiB
    ;;
    8|8G|8g)
    SWPSIZE=8Gib
    ;;
    *)
    echo "Invalid input..."
    sleep 2
    unset SWPSIZE
    swapsize
    ;;
  esac
  clear
  echo -e "\n"
  echo "SWAP Partition Set To "${SWPSIZE}""
  sleep 2
  clear
}

rootsize () {
  clear
  echo -e "\n"
  read -p "Pick Root Partition Size (20G, 40G, or 60G): " RTSIZE
  case $RTSIZE in
    20|20G|20g)
    RTSIZE=20GiB
    ;;
    40|40G|40g)
    RTSIZE=40GiB
    ;;
    60|60G|60g)
    RTSIZE=60Gib
    ;;
    *)
    echo "Invalid input..."
    sleep 2
    unset RTSIZE
    rootsize
    ;;
  esac
  clear
  echo -e "\n"
  echo "Root Partition Set To "${RTSIZE}""
  sleep 2
  clear
}

trgtdrvsd () { 
  clear
  echo -e "Check to see the available drives: \n"
  /bin/lsblk
  echo -e "\n"
  read -p "Type your target device (e.g. sda), be exact, and press Enter: " TRGTDRV
  [[ -z "$TRGTDRV" ]] && trgtdrvsd
  clear
  echo -e "\n"
  echo "Target device set to "${TRGTDRV}"..."
  sleep 2
  clear
}

trgtdrvnv () { 
  clear
  echo -e "Check to see the available drives: \n"
  /bin/lsblk
  echo -e "\n"
  read -p "Type your target device (e.g. nvme0n1), be exact, and press Enter: " TRGTDRV
  [[ -z "$TRGTDRV" ]] && trgtdrvnv
  clear
  echo -e "\n"
  echo "Target device set to "${TRGTDRV}"..."
  sleep 2
  clear
}

mkpartsd () {
  clear
  dd bs=512 if=/dev/zero of=/dev/"${TRGTDRV}" count=8192
  dd bs=512 if=/dev/zero of=/dev/"${TRGTDRV}" count=8192 seek=$((`blockdev --getsz /dev/"${TRGTDRV}"` - 8192))
  sgdisk -og /dev/"${TRGTDRV}"
  sgdisk -n 0:0:+650MiB -t 0:ef00 -c 0:efi /dev/"${TRGTDRV}"
  sgdisk -n 0:0:+"${SWPSIZE}" -t 0:8200 -c 0:swap /dev/"${TRGTDRV}"
  sgdisk -n 0:0:+"${RTSIZE}" -t 0:8303 -c 0:root /dev/"${TRGTDRV}"
  sgdisk -n 0:0:0 -t 0:8302 -c 0:home /dev/"${TRGTDRV}"
  clear
  echo -e "\n"
  echo "Partitions created..."
  sleep 2
  clear
}

frmtpartsd () {
  clear
  mkswap -L swap /dev/"${TRGTDRV}"\2
  mkfs.fat -F32 /dev/"${TRGTDRV}"\1
  mkfs.ext4 -L root /dev/"${TRGTDRV}"\3
  mkfs.ext4 -L home /dev/"${TRGTDRV}"\4
  clear
  echo -e "\n"
  echo "Partitions formatted..."
  sleep 2
  clear
}

mntpartsd () {
  clear
  mount /dev/"${TRGTDRV}"\3 /mnt
  mkdir /mnt/efi
  mount /dev/"${TRGTDRV}"\1 /mnt/efi
  mkdir /mnt/home
  mount /dev/"${TRGTDRV}"\4 /mnt/home
  swapon /dev/"${TRGTDRV}"\2
  clear
  echo -e "\n"
  echo "Mounted partitions..."
  sleep 2
  clear
}

mkpartnv () {
  clear
  dd bs=512 if=/dev/zero of=/dev/"${TRGTDRV}" count=8192
  dd bs=512 if=/dev/zero of=/dev/"${TRGTDRV}" count=8192 seek=$((`blockdev --getsz /dev/"${TRGTDRV}"` - 8192))
  sgdisk -og /dev/"${TRGTDRV}"
  sgdisk -n 0:0:+650MiB -t 0:ef00 -c 0:efi /dev/"${TRGTDRV}"
  sgdisk -n 0:0:+"${SWPSIZE}" -t 0:8200 -c 0:swap /dev/"${TRGTDRV}"
  sgdisk -n 0:0:+"${RTSIZE}" -t 0:8303 -c 0:root /dev/"${TRGTDRV}"
  sgdisk -n 0:0:0 -t 0:8302 -c 0:home /dev/"${TRGTDRV}"
  clear
  echo -e "\n"
  echo "Partitions created..."
  sleep 2
  clear
}

frmtpartnv () {
  clear
  mkswap -L swap /dev/"${TRGTDRV}"\p2
  mkfs.fat -F32 /dev/"${TRGTDRV}"\p1
  mkfs.ext4 -L root /dev/"${TRGTDRV}"\p3
  mkfs.ext4 -L home /dev/"${TRGTDRV}"\p4
  clear
  echo -e "\n"
  echo "Partitions formatted..."
  sleep 2
  clear
}

mntpartnv () {
  clear
  mount /dev/"${TRGTDRV}"\p3 /mnt
  mkdir /mnt/efi
  mount /dev/"${TRGTDRV}"\p1 /mnt/efi
  mkdir /mnt/home
  mount /dev/"${TRGTDRV}"\p4 /mnt/home
  swapon /dev/"${TRGTDRV}"\p2
  clear
  echo -e "\n"
  echo "Mounted partitions..."
  sleep 2
  clear
}

psbase () {
  clear
  pacstrap /mnt base base-devel cryptsetup curl dialog e2fsprogs device-mapper dhcpcd dosfstools efibootmgr gptfdisk grub inetutils less linux linux-firmware linux-headers lvm2 mkinitcpio mtools nano netctl nvme-cli reflector rsync sysfsutils xz zstd
  clear
  echo -e "\n"
  echo "Pacstrap base system complete..."
  sleep 2
  clear
}

mkfstab () {
  clear
  genfstab -U /mnt >> /mnt/etc/fstab
  clear
}

syshstnm () {
  clear
  echo ""${HSTNAME}"" > /mnt/etc/hostname
  echo "127.0.0.1          localhost" >> /mnt/etc/hosts
  echo "::1          localhost" >> /mnt/etc/hosts
  echo "127.0.1.1          "${HSTNAME}".localdomain "${HSTNAME}"" >> /mnt/etc/hosts
  clear
}

syslocale () {
  clear
  echo ""${LCLST}".UTF-8 UTF-8" > /mnt/etc/locale.gen
  echo "C.UTF-8 UTF-8" >> /mnt/etc/locale.gen
  echo "LANG="${LCLST}".UTF-8" > /mnt/etc/locale.conf
  echo "KEYMAP="${KEYMP}"" > /mnt/etc/vconsole.conf
  arch-chroot /mnt locale-gen
  arch-chroot /mnt localectl set-locale LANG="${LCLST}".UTF-8
  arch-chroot /mnt localectl set-keymap "${KEYMP}"
  clear
}

sysusrpwd () {
  clear
  arch-chroot /mnt useradd -mU -s /bin/bash -G sys,log,network,floppy,scanner,power,rfkill,users,video,storage,optical,lp,audio,wheel,adm "${USRNAME}"
  arch-chroot /mnt chpasswd <<< ""${USRNAME}":"${USRPWD}""
  arch-chroot /mnt chpasswd <<< "root:"${RTPWD}""
  clear
}

systmzone () {
  clear
  arch-chroot /mnt hwclock --systohc --utc
  arch-chroot /mnt timedatectl set-ntp true
  arch-chroot /mnt rm -rf /etc/localtime
  arch-chroot /mnt ln -sf /usr/share/zoneinfo/"${MYTMZ}" /etc/localtime
  clear
}

sysconfig () {
  clear
  echo -e "\n"
  echo "Basic system config completed..."
  sleep 2
  clear
}

instgrub () {
  clear
  echo -e "\n"
  arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
  arch-chroot /mnt mkinitcpio -p linux
  clear
  echo -e "\n"
  echo "Grub installed & mkinicpio run..."
  sleep 2
  clear
}

instxorg () {
  clear
  pacstrap /mnt xorg xorg-apps xorg-server xorg-drivers xorg-xkill xorg-xinit xterm mesa
  clear
  echo -e "\n"
  echo "Xorg installed installed..."
  sleep 2
  clear
}

instgen () {
  clear
  pacstrap /mnt amd-ucode aspell aspell-en arch-install-scripts archiso bash-completion bind bluez bluez-utils btrfs-progs cdrtools cmake cryfs dd_rescue ddrescue devtools diffutils dkms dmidecode dvd+rw-tools efitools encfs exfatprogs f2fs-tools fatresize fsarchiver fuse3 fwupd git gnome-disk-utility gnome-keyring gocryptfs gpart gparted grsync gvfs gvfs-afc gvfs-goa gvfs-gphoto2 grsync gvfs-mtp gvfs-nfs gvfs-smb haveged hdparm hspell htop hunspell hunspell-en_us hwdata hwdetect hwinfo intel-ucode jfsutils mkinitcpio-archiso mkinitcpio-nfs-utils libburn libisofs libisoburn logrotate lsb-release lsscsi man-db man-pages mdadm ntfs-3g p7zip pacutils packagekit pacman-contrib pahole papirus-icon-theme parted perl perl-data-dump perl-json perl-lwp-protocol-https perl-term-readline-gnu perl-term-ui pkgfile plocate polkit pv qt5ct reiserfsprogs rsync s-nail sdparm sdl2 sg3_utils smartmontools squashfs-tools sudo testdisk texinfo tlp udftools udisks2 unace unrar unzip upower usbmuxd usbutils vim which xdg-user-dirs xfsprogs
  sleep 2
  arch-chroot /mnt systemctl enable bluetooth.service
  arch-chroot /mnt systemctl enable fstrim.timer
  arch-chroot /mnt systemctl enable haveged.service
  arch-chroot /mnt systemctl enable plocate-updatedb.timer
  clear
  echo -e "\n"
  echo "General packages installed..."
  sleep 2
  clear
}

instcalamdep () {
  clear
  pacstrap /mnt boost boost-libs dmidecode extra-cmake-modules gtk-update-icon-cache icu kconfig kcoreaddons kdbusaddons kiconthemes ki18n kio kparts kpmcore kservice kwidgetsaddons libpwquality plasma-framework polkit-qt5 qt5-location qt5-svg qt5-tools qt5-translations qt5-webengine qt5-xmlpatterns qt5ct solid upower yaml-cpp
  clear
  echo -e "\n"
  echo "Calamares dependencies installed..."
  sleep 2
  clear
}

instmedia () {
  clear
  pacstrap /mnt alsa-lib alsa-plugins alsa-firmware alsa-utils audacious audacious-plugins cdrdao dvdauthor faac faad2 ffmpeg ffmpegthumbnailer flac frei0r-plugins gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gstreamer-vaapi imagemagick lame libdvdcss libopenraw mencoder mjpegtools mpv poppler-glib pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-equalizer pulseaudio-jack simplescreenrecorder sox transcode smplayer x265 x264 xvidcore
  clear
  echo -e "\n"
  echo "Multimedia packages installed..."
  sleep 2
  clear
}

instnet () {
  clear
  pacstrap /mnt avahi b43-fwcutter broadcom-wl-dkms dhclient dmraid dnsmasq dnsutils ethtool filezilla firefox iwd gnu-netcat net-tools networkmanager networkmanager-openvpn network-manager-applet nm-connection-editor nfs-utils nilfs-utils nss-mdns openconnect openresolv openssh openssl openvpn r8168 samba vsftpd wget wireless-regdb wireless_tools whois wpa_supplicant
  sleep 2
  arch-chroot /mnt systemctl enable NetworkManager.service
  clear
  echo -e "\n"
  echo "Networking packages installed..."
  sleep 2
  clear
}

instfonts () {
  clear
  pacstrap /mnt ttf-ubuntu-font-family ttf-dejavu ttf-bitstream-vera ttf-liberation noto-fonts ttf-roboto ttf-opensans opendesktop-fonts cantarell-fonts freetype2
  clear
  echo -e "\n"
  echo "Fonts packages installed..."
  sleep 2
  clear
}

instprint () {
  clear
  pacstrap /mnt cups cups-pdf cups-filters cups-pk-helper foomatic-db foomatic-db-engine ghostscript gsfonts gutenprint python-pillow python-pip python-pyqt5 python-reportlab simple-scan system-config-printer
  sleep 2
  arch-chroot /mnt systemctl enable cups.service
  clear
  echo -e "\n"
  echo "Printing packages installed..."
  sleep 2
  clear
}

instlxqt () {
  clear
  pacstrap /mnt accountsservice aisleriot appstream-qt bluez-qt brightnessctl breeze-icons discover featherpad geany guvcview k3b kwin liblxqt libstatgrab libsysstat lximage-qt lxqt-about lxqt-admin lxqt-archiver lxqt-build-tools lxqt-config lxqt-globalkeys lxqt-notificationd lxqt-openssh-askpass lxqt-panel lxqt-policykit lxqt-powermanagement lxqt-qtplugin lxqt-runner lxqt-session lxqt-sudo lxqt-themes meld neofetch networkmanager-qt packagekit-qt5 pcmanfm-qt pavucontrol-qt print-manager qbittorrent qterminal screengrab xpdf xscreensaver
  sleep 2
  arch-chroot /mnt systemctl enable sddm.service
  clear
  echo -e "\n"
  echo "LXQt desktop installed..."
  sleep 2
  clear
}

instkde () {
clear
  pacstrap /mnt accountsservice aisleriot ark bluedevil breeze-icons bluez-qt discover dolphin geany guvcview gwenview k3b kcalc kinit konsole kwin kwrite meld neofetch networkmanager-qt okular packagekit-qt5 pavucontrol-qt plasma print-manager qbittorrent sddm sddm-kcm sweeper
  sleep 2
  arch-chroot /mnt systemctl enable sddm.service
  clear
  echo -e "\n"
  echo "KDE Plasma desktop installed..."
  sleep 2
  clear
}

instxfce () {
  clear
  pacstrap /mnt accountsservice adapta-gtk-theme aisleriot arc-gtk-theme arc-icon-theme asunder blueman catfish dconf-editor epdfview galculator geany gnome-firmware gnome-packagekit gtk-engine-murrine guvcview meld neofetch pavucontrol polkit-gnome sddm transmission-gtk xarchiver xfburn xfce4 xfce4-goodies
  sleep 2
  arch-chroot /mnt systemctl enable sddm.service
  clear
  echo -e "\n"
  echo "XFCE desktop installed..."
  sleep 2
  clear
}

instmate () {
  clear
  pacstrap /mnt accountsservice adapta-gtk-theme aisleriot arc-gtk-theme arc-icon-theme asunder blueman brasero dconf-editor geany gnome-firmware gnome-packagekit gtk-engine-murrine guvcview mate mate-applet-dock mate-extra mate-polkit meld neofetch sddm transmission-gtk
  sleep 2
  arch-chroot /mnt systemctl enable sddm.service
  clear
  echo -e "\n"
  echo "Mate desktop installed..."
  sleep 2
  clear
}

instcinn () {
  clear
  pacstrap /mnt accountsservice adwaita-icon-theme adapta-gtk-theme aisleriot arc-gtk-theme arc-icon-theme asunder blueman brasero cinnamon cinnamon-translations dconf-editor epdfview file-roller geany gnome-firmware gnome-packagekit gnome-terminal gsound gtk-engine-murrine guvcview meld nemo nemo-fileroller nemo-share neofetch pavucontrol polkit-gnome sddm tldr tmux transmission-gtk viewnior xed
  sleep 2
  arch-chroot /mnt systemctl enable sddm.service
  clear
  echo -e "\n"
  echo "Cinnamon desktop installed..."
  sleep 2
  clear
}

instgnome () {
  clear
  pacstrap /mnt accountsservice adapta-gtk-theme adwaita-icon-theme aisleriot asunder brasero breeze-icons dconf-editor gdm geany gnome gnome-bluetooth gnome-firmware gnome-nettool gnome-packagekit gnome-shell gnome-shell-extensions gnome-software-packagekit-plugin gnome-sound-recorder gnome-todo gnome-tweaks gnome-usage gsound guvcview meld neofetch pavucontrol polkit-gnome tmux transmission-gtk
  sleep 2
  arch-chroot /mnt systemctl enable gdm.service
  clear
  echo -e "\n"
  echo "Gnome desktop installed..."
  sleep 2
  clear
}

invalid () {
  echo -e "\n"
  echo "Invalid answer, Please try again"
  sleep 2
}

make_upht () { while true
do
  clear
  echo "----------------------------------"
  echo " User, Passwords, & Hostname"
  echo "----------------------------------"
  echo ""
  echo "  1) Create user name"
  echo "  2) Make user password"
  echo "  3) Make root password"
  echo "  4) Make hostname"
  echo ""
  echo "  R) Return to menu"
  echo -e "\n"
  read -p "Please enter your choice: " choice2
  case $choice2 in
    1 ) usrname ;;
    2 ) usrpwd ;;
    3 ) rtpwd ;;
    4 ) hstname ;;
    r|R ) main_menu ;;
    * ) invalid ;;
  esac
done
}

sata_drv () { while true
do
  clear
  echo "--------------------------------"
  echo " Partition Drive"
  echo "--------------------------------"
  echo ""
  echo "  1) Enter device name (e.g.sda)"
  echo "  2) Choose Swap partition size"
  echo "  3) Choose Root partition size"
  echo "  ** Remaining space will be /home **"
  echo "  4) Create partitions"
  echo "  5) Format partitions (ext4)"
  echo "  6) Mount partitions"
  echo ""
  echo "  R) Return to menu"
  echo -e "\n"
  read -p "Please enter your choice: " choice3
  case $choice3 in
    1 ) trgtdrvsd ;;
    2 ) swapsize ;;
    3 ) rootsize ;;
    4 ) mkpartsd ;;
    5 ) frmtpartsd ;;
    6 ) mntpartsd ;;
    r|R ) main_menu ;;
    * ) invalid ;;
  esac
done
}

nvme_drv () { while true
do
  clear
  echo "--------------------------------"
  echo " Partition Drive"
  echo "--------------------------------"
  echo ""
  echo "  1) Enter device name (e.g.nvme0n1)"
  echo "  2) Choose Swap partition size"
  echo "  3) Choose Root partition size"
  echo "  ** Remaining space will be /home **"
  echo "  4) Create partitions"
  echo "  5) Format partitions (ext4)"
  echo "  6) Mount partitions"
  echo ""
  echo "  R) Return to menu"
  echo -e "\n"
  read -p "Please enter your choice: " choice4
  case $choice4 in
    1 ) trgtdrvnv ;;
    2 ) swapsize ;;
    3 ) rootsize ;;
    4 ) mkpartnv ;;
    5 ) frmtpartnv ;;
    6 ) mntpartnv ;;
    r|R ) main_menu ;;
    * ) invalid ;;
  esac
done
}

chdrvtype () { while true
do
  clear
  echo "-----------------------------------"
  echo " Choose SATA or NVME Disk"
  echo "-----------------------------------"
  echo ""
  echo "  1) SATA Disk"
  echo "  2) NVME Disk"
  echo ""
  echo "  R) Return to menu"
  echo -e "\n"
  read -p "Please enter your choice: " choice5
  case $choice5 in
    1 ) sata_drv ;;
    2 ) nvme_drv ;;
    r|R ) main_menu ;;
    * ) invalid ;;
  esac
done
}

inst_soft () { while true
do
  clear
  echo "--------------------------------"
  echo " Install Software Categories"
  echo "--------------------------------"
  echo ""
  echo "  1) Xorg"
  echo "  2) General"
  echo "  3) Multimedia"
  echo "  4) Networking"
  echo "  5) Fonts"
  echo "  6) Printing support"
  echo "  7) Calamares dependencies"
  echo ""
  echo "  R) Return to menu"
  echo -e "\n"
  read -p "Please enter your choice: " choice6
  case $choice6 in
    1 ) instxorg ;;
    2 ) instgen ;;
    3 ) instmedia ;;
    4 ) instnet ;;
    5 ) instfonts ;;
    6 ) instprint ;;
    7 ) instcalamdep ;;
    r|R ) main_menu ;;
    * ) invalid ;;
  esac
done
}

inst_desk () { while true
do
  clear
  echo "--------------------------------"
  echo " Choose A Desktop"
  echo "--------------------------------"
  echo ""
  echo "  1) LXQt"
  echo "  2) Plasma"
  echo "  3) XFCE"
  echo "  4) Mate"
  echo "  5) Cinnamon"
  echo "  6) Gnome"
  echo ""
  echo "  R) Return to menu"
  echo -e "\n"
  read -p "Please enter your choice: " choice7
  case $choice7 in
    1 ) instlxqt ;;
    2 ) instkde ;;
    3 ) instxfce ;;
    4 ) instmate ;;
    5 ) instcinn ;;
    6 ) instgnome ;;
    r|R ) main_menu ;;
    * ) invalid ;;
  esac
done
}

main_menu () { while true
do
  clear
  echo "-------------------------------------"
  echo " EZ Arch Installer - UEFI Systems"
  echo "-------------------------------------"
  echo ""
  echo "  1) Username, Passwords, & Hostname"
  echo "  2) Choose Device Type & Partition Drive"
  echo "  3) Install Base System (pacstrap)"
  echo "  4) Configure System Settings"
  echo "  5) Install Broad Categories of Software"
  echo "  6) Choose Desktop"
  echo "  7) Install GRUB"
  echo ""
  echo "  X) Exit"
  echo -e "\n"
  read -p "Enter your choice: " choice1
  case $choice1 in
    1 ) make_upht ;;
    2 ) chdrvtype ;;
    3 ) psbase ;;
    4 ) mkfstab; syshstnm; syslocale; sysusrpwd; systmzone; sysconfig ;;
    5 ) inst_soft ;;
    6 ) inst_desk ;;
    7 ) instgrub ;;
    x|X ) exit;;
    * ) invalid ;;
  esac
done
}

ROOTUSER () {
  if [[ "$EUID" = 0 ]]; then
    continue
  else
    echo "Please Run As Root"
    sleep 2
    exit
  fi
}

ROOTUSER
handlerr
welcome
hrdclck
main_menu

done

# Disclaimer:
# THIS SOFTWARE IS PROVIDED BY EZNIX “AS IS” AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL EZNIX BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# END
