#!/bin/bash
echo;echo;clti="          \e[1m\e[97m\e[44m";
sep="$clti==================================\e[49m"
echo -e "$sep";echo -e "$clti=== 'Recovery tools' installer ===\e[49m"
echo -e "$sep\e[0m";echo "                                  By seb3773";echo
if [ ! "$EUID" -eq 0 ];then echo "           !! This script must be run as root.";echo;exit;fi
osarch=$(dpkg --print-architecture)
uuid=$(lsblk -o MOUNTPOINT,UUID | awk '$1 == "/" {print $2}')
current_locale=$(locale | grep LANG= | cut -d'=' -f2)
lg=$(echo $current_locale | cut -d'_' -f1)
keyboard_layout=$(setxkbmap -query | grep layout | awk '{print $2}')
qver=$(command get-q4os-version 2>/dev/null)
extract_script(){ start_mark="##\\[$1\\]##";end_mark="##\\[END_$1\\]##"
if grep -q "$start_mark" "$0" && grep -q "$end_mark" "$0"; then
echo "  - extracting $1 script to $2"
sed -n "/$start_mark/,/$end_mark/p" "$0" | sed "1d;\$d" > "$2/$1"
chmod +x "$2/$1";fi;}
extract_b64(){ start_mark="##\\[$1\\]##";end_mark="##\\[END_$1\\]##"
if grep -q "$start_mark" "$0" && grep -q "$end_mark" "$0"; then
echo "  - extracting $1 to $2"
sed -n "/$start_mark/,/$end_mark/p" "$0" | sed "1d;\$d" | base64 -d > "$2/$1";fi;}
echo -e "\e[43m\e[97m # detected config:\e[39m\e[49m"
echo -e "  > architecture: \e[92m$osarch\e[39m"
if [ -n "$qver" ];then echo -e "  > q4os version: \e[92m$qver\e[39m";fi
echo -e "  > Root disk (/) UUID: \e[92m$uuid\e[39m"
echo -e "  > locales: \e[92m$current_locale\e[39m"
echo -e "  > keyboard layout: \e[92m$keyboard_layout\e[39m";echo
echo -e "\e[97m\e[100m # needed packages:\e[39m\e[49m"
sizless=300;sizmc=1500;sizinxi=1500;sizduf=2200;sizncdu=120;sizdeborph=300;sizw3m=2900;sizlynis=1700;sizrmlint=400;sizpasteb=330;sizqrenc=80;sizmemtest=60;
appok(){ echo -e -n "\e[92m☑ \e[39m\e[0m";};notok(){ echo -e -n "\e[91m☒ \e[49m\e[39m ";};siztoinst=0;lstapps=""
echo -e -n "  > checking 'less':     ";if [ -f /usr/bin/less ];then appok;else notok;appless=1;((siztoinst+=sizless));lstapps+="  less  ";fi
echo -e -n "    > checking 'mc' :        ";if [ -f /bin/mc ];then appok;else notok;appmc=1;((siztoinst+=sizmc));lstapps+="  mc  ";fi;echo
echo -e -n "  > checking 'inxi':     ";if [ -f /usr/bin/inxi ];then appok;else notok;appinxi=1;((siztoinst+=sizinxi));lstapps+="  inxi  ";fi
echo -e -n "    > checking 'duf':        ";if [ -f /usr/bin/duf ];then appok;else notok;appduf=1;((siztoinst+=sizduf));lstapps+="  duf  ";fi;echo
echo -e -n "  > checking 'ncdu':     ";if [ -f /usr/bin/ncdu ];then appok;else notok;appncdu=1;((siztoinst+=sizncdu));lstapps+="  ncdu  ";fi
echo -e -n "    > checking 'w3m':        ";if [ -f /usr/bin/w3m ];then appok;else notok;appw3m=1;((siztoinst+=sizw3m));lstapps+="  w3m  ";fi;echo
echo -e -n "  > checking 'lynis':    ";if [ -f /usr/sbin/lynis ];then appok;else notok;applynis=1;((siztoinst+=sizlynis));lstapps+="  lynis  ";fi
echo -e -n "    > checking 'deborphan':  ";if [ -f /usr/bin/deborphan ];then appok;else notok;appdeborph=1;((siztoinst+=sizdeborph));lstapps+="  deborphan  ";fi;echo
echo -e -n "  > checking 'rmlint':   ";if [ -f /usr/bin/rmlint ];then appok;else notok;apprmlint=1;((siztoinst+=sizrmlint));lstapps+="  rmlint  ";fi
echo -e -n "    > checking 'pastebinit': ";if [ -f /usr/bin/pastebinit ];then appok;else notok;apppasteb=1;((siztoinst+=sizpasteb));lstapps+="  pastebinit  ";fi;echo
echo -e -n "  > checking 'qrencode': ";if [ -f /usr/bin/qrencode ];then appok;else notok;appqrenc=1;((siztoinst+=sizqrenc));lstapps+="  qrencode  ";fi;
echo -e -n "    > checking 'memtester':  ";if [ -f /sbin/memtester ];then appok;else notok;appmemtest=1;((siztoinst+=sizmemtest));lstapps+="  memtester  ";fi;echo
if [ -n "$lstapps" ]; then echo;echo -e " \e[4mThe following needed package(s) will be installed:\e[0m "
echo -e "\e[93m  $lstapps\e[39m";echo -e " this will use approximatively \e[4m$siztoinst K of disk space\e[0m.";fi
echo;echo -n -e " Proceed ? (\e[92my\e[39m/\e[91mn\e[39m) " && read x
if [ "$x" == "y" ] || [ "$x" == "Y" ];then
echo;echo -e "  > do you want to install 'clonezilla live' or 'rescuezilla live' entry too ?"
echo -e "    This will use ~ \e[93m\e[4m425Mb of disk space\e[0m for \e[93mclonezilla live\e[39m"
echo -e "    or ~ \e[96m\e[4m1,1 Gb of disk space\e[0m for \e[96mrescuezilla live\e[39m."
echo -e -n " Enter '\e[93mc\e[39m' for clonezilla ; '\e[96mr\e[39m' for rescuezilla; '\e[91mn\e[39m' to skip this part:" && read x;echo
if [ "$x" == "c" ] || [ "$x" == "C" ];then clonezi=1;rescuezi=0;echo "  > 'clonezilla live' entry selected"
elif [ "$x" == "r" ] || [ "$x" == "R" ];then clonezi=0;rescuezi=1;echo "  > 'rescuezilla live' entry selected"
else
clonezi=0;rescuezi=0
fi
mkdir -p /root/recovtools
echo;echo -e "  > do you want to protect the menus access with a password ? "
echo -e "    (you can set a password too for the corresponding menu entries"
echo -e "     in grub config afterward if you want, and ignore this step;"
echo -e "     consult grub documentation to understand how to do this). "
echo -e -n " Create a password ? (\e[92my\e[39m/\e[91mn\e[39m) " && read x
if [ "$x" == "y" ] || [ "$x" == "Y" ];then
while true; do
read -sp "Please enter a password: " password;echo;read -sp "Confirm password: " password_confirm;echo
if [ "$password" != "$password_confirm" ]; then echo -e "\e[91mPasswords doesn't match, please try again.\e[39m"
else break;fi
done
password_hash=$(echo -n "$password" | md5sum | awk '{ print $1 }')
echo "$password_hash" | sudo tee "/root/recovtools/phash.txt" > /dev/null
sudo chown root:root "/root/recovtools/phash.txt"
sudo chmod 600 "/root/recovtools/phash.txt"
else rm -f "/root/recovtools/phash.txt";fi
echo;echo " # Copying files to /root/recovtools/"
extract_b64 "spleen-12x24.psfu.gz" "/root/recovtools"
extract_b64 "spleen-8x16.psfu.gz" "/root/recovtools"
extract_script emergencymenu.sh "/root/recovtools"
extract_script rescuemenu.sh "/root/recovtools"
extract_script servmg.sh "/root/recovtools"
extract_script usersmg.sh "/root/recovtools"
extract_script ramtest.sh "/root/recovtools"
sudo chown root:root /root/recovtools/emergencymenu.sh
sudo chmod 700 /root/recovtools/emergencymenu.sh
sudo chown root:root /root/recovtools/rescuemenu.sh
sudo chmod 700 /root/recovtools/rescuemenu.sh
sudo chown root:root /root/recovtools/servmg.sh
sudo chmod 700 /root/recovtools/servmg.sh
sudo chown root:root /root/recovtools/usersmg.sh
sudo chmod 700 /root/recovtools/usersmg.sh
sudo chown root:root /root/recovtools/ramtest.sh
sudo chmod 700 /root/recovtools/ramtest.sh
echo;echo " # Dumping current keymap to /root/recovtools/"
dumpkeys > /root/recovtools/recovmenu.keymap
if [ -n "$lstapps" ]; then echo;echo " # Installing needed packages..."
app_install_error=""
instr(){ echo "  -- installing $1"
apt install -y $1 > /dev/null 2>&1
if [ $? -eq 0 ]; then
echo -e "\e[92m   Ok.\e[39m"
else
echo -e "\e[91m   * $1 didn't install properly.\e[39m"
app_install_error+="  $1  "
fi
}
if [[ $appless -eq 1 ]];then instr less;fi
if [[ $appmc -eq 1 ]];then instr mc;fi
if [[ $appinxi -eq 1 ]];then instr inxi;fi
if [[ $appduf -eq 1 ]];then instr duf;fi
if [[ $appncdu -eq 1 ]];then instr ncdu;fi
if [[ $appdeborph -eq 1 ]];then instr deborphan;fi
if [[ $appw3m -eq 1 ]];then instr w3m;fi
if [[ $applynis -eq 1 ]];then instr lynis;fi
if [[ $apppasteb -eq 1 ]];then instr pastebinit;fi
if [[ $appqrenc -eq 1 ]];then instr qrencode;fi
if [[ $appmemtest -eq 1 ]];then instr memtester;fi
if [[ $apprmlint -eq 1 ]];then
echo "  -- installing rmlint"
apt install -y rmlint --no-install-recommends  > /dev/null 2>&1
if [ $? -eq 0 ]; then echo -e "\e[92m   Ok.\e[39m";else
echo -e "\e[91m   * rmlint didn't install properly.\e[39m"
app_install_error+="  rmlint  ";fi
fi;fi
if [ -n "$app_install_error" ]; then
echo;echo -e "  > Some apps didn't install properly:"
echo -e "\e[91m         $app_install_error \e[39m";echo
echo "   Although this won't prevent the base functions to work, some"
echo "   tools will not be available."
echo -e -n "> Continue anyway or quit ? (c/q) " && read x
if [ "$x" == "q" ] || [ "$x" == "Q" ];then echo;echo "Exited.";echo;fi
echo
fi
if [[ $clonezi -eq 1 ]];then
if [ "$osarch" = "amd64" ]; then
zillaiso="clonezilla-live-3.1.2-22-amd64.iso"
else zillaiso="clonezilla-live-3.1.2-22-i686.iso"
fi
if ! ls /root/recovtools/clonezilla-live-3.1.2-22-*.iso 1> /dev/null 2>&1; then
echo;echo " # downloading clonezilla ISO..."
wget -q --show-progress https://deac-fra.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.1.2-22/$zillaiso
echo;echo " # moving clonezilla ISO to /root/recovtools/"
mv -f $zillaiso /root/recovtools/
fi
fi


if [[ $rescuezi -eq 1 ]];then
if [ "$osarch" = "amd64" ]; then
zillaiso="rescuezilla-2.5-64bit.jammy.iso"
else zillaiso="rescuezilla-2.5-32bit.bionic.iso"
fi
if ! ls /root/recovtools/rescuezilla-2.5-*.iso 1> /dev/null 2>&1; then
echo;echo " # downloading rescuezilla ISO..."
wget -q --show-progress https://github.com/rescuezilla/rescuezilla/releases/download/2.5/$zillaiso
echo;echo " # moving rescuezilla ISO to /root/recovtools/"
mv -f $zillaiso /root/recovtools/
fi
fi


echo;echo " # Creating emergency & rescue system units overrides to /etc/systemd/system/"
echo "   > Creating /etc/systemd/system/emergency.service"
{
echo "# modified version of emergency.service for recovery tools"
echo
echo "[Unit]"
echo "Description=Emergency Shell"
echo "Documentation=man:sulogin(8)"
echo "DefaultDependencies=no"
echo "Conflicts=shutdown.target"
echo "Conflicts=rescue.service"
echo "Before=shutdown.target"
echo "Before=rescue.service"
echo
echo "[Service]"
echo "Environment=HOME=/root"
echo "WorkingDirectory=-/root"
echo "ExecStartPre=-/bin/plymouth --wait quit"
echo "ExecStart=-/bin/sh -c 'grep -q \"recovtools\" /proc/cmdline && exec /root/recovtools/emergencymenu.sh || exec /lib/systemd/systemd-sulogin-shell emergency'"
echo "Type=idle"
echo "StandardInput=tty-force"
echo "StandardOutput=inherit"
echo "StandardError=inherit"
echo "KillMode=process"
echo "IgnoreSIGPIPE=no"
echo "SendSIGHUP=yes"
echo
} > "/etc/systemd/system/emergency.service"
echo "   > Creating /etc/systemd/system/rescue.service"
{
echo "# modified version of rescue.service for recovery tools"
echo
echo "[Unit]"
echo "Description=Rescue Shell"
echo "Documentation=man:sulogin(8)"
echo "DefaultDependencies=no"
echo "Conflicts=shutdown.target"
echo "After=sysinit.target plymouth-start.service"
echo "Before=shutdown.target"
echo
echo "[Service]"
echo "Environment=HOME=/root"
echo "WorkingDirectory=-/root"
echo "ExecStartPre=-/bin/plymouth --wait quit"
echo "ExecStart=-/bin/sh -c 'grep -q \"recovtools\" /proc/cmdline && exec /root/recovtools/rescuemenu.sh || exec /lib/systemd/systemd-sulogin-shell rescue'"
echo "Type=idle"
echo "StandardInput=tty-force"
echo "StandardOutput=inherit"
echo "StandardError=inherit"
echo "KillMode=process"
echo "IgnoreSIGPIPE=no"
echo "SendSIGHUP=yes"
echo
} > "/etc/systemd/system/rescue.service"
echo;echo " # reloading systemd daemons...";echo
systemctl daemon-reload
echo " # Creating /etc/grub.d/39_recoverytools"
{ echo '#!/bin/sh'
echo 'exec tail -n +3 $0'
echo 'submenu "Recovery tools" --class recovery {'
echo 'menuentry "Emergency menu ~ raw shell, no services started" --class recovery {'
echo "search --no-floppy --fs-uuid --set=root $uuid"
echo "insmod gzio"
echo 'if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi'
echo 'insmod part_gpt'
echo 'insmod ext2'
echo "linux /vmlinuz root=UUID=$uuid systemd.unit=emergency.target video=1024x768M recovtools=1"
echo 'initrd /initrd.img';
echo '}'
echo 'menuentry "Rescue menu ~  single user mode shell with base services" --class recovery {'
echo "search --no-floppy --fs-uuid --set=root $uuid"
echo 'insmod gzio'
echo 'if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi'
echo 'insmod part_gpt'
echo 'insmod ext2'
echo "linux /vmlinuz root=UUID=$uuid systemd.unit=rescue.target recovtools=1"
echo 'initrd /initrd.img'
echo '}'
if [[ $clonezi -eq 1 || $rescuezi -eq 1 ]]; then

if [[ $clonezi -eq 1 ]];then
echo 'menuentry "Clonezilla live" --class recovery {'
else
echo 'menuentry "Rescuezilla live" --class recovery {'
fi
[ "$osarch" = "amd64" ] && echo 'rmmod tpm'

echo "search --no-floppy --fs-uuid --set $uuid"
echo 'insmod gzio'
echo 'if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi'
echo 'insmod part_gpt'
echo 'insmod ext2'
echo "set isofile=\"/root/recovtools/$zillaiso\""
echo 'loopback loop $isofile'

if [[ $clonezi -eq 1 ]];then
echo "linux (loop)/live/vmlinuz nomodeset boot=live live-config edd=on ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" keyboard-layouts=\"$keyboard_layout\" ocs_live_batch=\"no\" locales=\"$current_locale\" ip=frommedia toram=filesystem.squashfs findiso=\$isofile"
echo 'initrd (loop)/live/initrd.img'
else
echo "linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=\$isofile quiet noeject fastboot toram fsck.mode=skip noprompt splash console-setup/layoutcode=$lg bootkbd=$lg"
echo 'initrd (loop)/casper/initrd.lz'
fi



echo '}'
fi
echo '}'
} > "/etc/grub.d/39_recoverytools"
chmod +x "/etc/grub.d/39_recoverytools"
echo;echo " # Updating grub...";echo
update-grub > /dev/null 2>&1
#check error code + propose to remove modifications
echo;echo "Done.";echo;exit;else echo;echo "Exited.";echo;exit;fi;echo
#▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
##[emergencymenu.sh]##
#!/bin/bash
export NEWT_COLORS='
root=green,black
border=brightred,black
title=brightred,black
roottext=white,black
window=brightred,black
textbox=white,black
button=black,brightred
compactbutton=white,black
listbox=brightblue,black
actlistbox=black,white
actsellistbox=white,brightred
checkbox=brightred,black
actcheckbox=black,brightred
'
export LESS=-FX
hf="/root/recovtools/phash.txt";if [ -f "$hf" ]; then trap 'echo;echo -n "Password:"' SIGINT
sth=$(cat "$hf");while true; do read -sp "Password: " inppass;echo
input_hash=$(echo -n "$inppass" | md5sum | awk '{ print $1 }')
if [ "$input_hash" != "$sth" ]; then echo "Wrong Password.";read -p "Do you want to retry or quit (reboot) ? (r/q) " choice
case "$choice" in r|R) continue ;; q|Q) echo "Rebooting now...";reboot;exit ;; *) continue ;; esac;else trap SIGINT;break;fi;done;fi
prmpt="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ "
remountroot(){ if findmnt -n -o OPTIONS / | egrep "^ro,|,ro,|,ro$"; then  mount -o rw,remount /;fi;}
taskdone(){ echo;echo "-----------------------------------------------------------------------------------------------------"
echo -e -n "\e[43m\e[97mDone. Press enter to continue.\e[39m\e[49m" && read x;}
itdisp(){ clear;echo;echo -e "++++++   \e[1m\e[97m\e[44m$1\e[0m   ++++++";echo;}
choosefonts() { clear;while true; do
echo "Choose the font size:";echo "1 - Normal fonts";echo "2 - Small fonts";echo "q - Quit"
read choice
case $choice in 1) setfont /root/recovtools/spleen-12x24.psfu.gz; rm -f /root/recovtools/smallfonts;break ;; 2) setfont /root/recovtools/spleen-8x16.psfu.gz; touch /root/recovtools/smallfonts;break ;; q) echo "Exiting font selection."; break ;; *) echo "Invalid choice. Please choose again."; ;; esac;done; }
phymem=$(LANG=C free|awk '/^Mem:/{printf ("%.2f\n",$2/(1024*1024))}')
dskfree=$(df -k / | tail -1 | awk '{print int($4/(1024*1024))}')
osarch=$(dpkg --print-architecture)
ckern=$(uname -r)
partitions=$(lsblk -o NAME,FSTYPE -nr)
ntfs_partitions=$(echo "$partitions" | grep -w ntfs)
if [ -z "$ntfs_partitions" ]; then ntfsdisk=0;else ntfsdisk=1;fi
loadkeys /root/recovtools/recovmenu.keymap
if [ -e "/root/recovtools/smallfonts" ]; then
setfont /root/recovtools/spleen-8x16.psfu.gz;else setfont /root/recovtools/spleen-12x24.psfu.gz;fi
while true; do
dskfree=$(df -k / | tail -1 | awk '{print int($4/(1024*1024))}')
MENU_OPTIONS=(
"font size" "  ++  change current font size"
"fsck" "  ═   fsck all disks"
)
if [ "$ntfsdisk" -eq 1 ]; then
  MENU_OPTIONS+=("ntfsfix" "  ─   try to fix ntfs errors")
fi
MENU_OPTIONS+=(
"inxi" "  ─   system summary"
"mc" "  ═   file manager"
"ncdu" "  ═   disk usage analysis"
"free space" "  ─   try to make free space"
"update-grub" "  ─   update grub bootloader"
"fix perms" "  ─   try to fix permissions"
"memtester" "  ─   test physical ram"
"users/groups" "  ─   users & group management"
"testdisk" "  ─   launch testdisk"
"photorec" "  ─   launch photorec"
"shell" "  ═   root shell prompt"
"rescue mode" "  »   go to rescue mode"
"reboot" "  ×   reboot system now"
)
CHOICE=$(whiptail --title "  Emergency Menu ~ $HOSTNAME ~ $osarch  " --menu "\n■ Ram: $phymem Gb   ■ Disk free: $dskfree Gb\n■ Current kernel: $ckern\n≡ $(date '+%A %d %B %Y')\n\n► Choose an option:" 30 60 16 \
"${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)
case $CHOICE in
"font size")
choosefonts
;;
"fsck")
itdisp "fsck all disks"
echo -e "(if output is larger than the screen height, use \e[4mup & down arrow to scroll\e[0m - \e[4m'q' to quit\e[0m)";echo
read -p " > Press enter to start fsck"
umount -a
/sbin/fsck -f -a -A -V -v -r | less
taskdone
;;
"ntfsfix")
itdisp "Starting ntfsfix"
echo "$ntfs_partitions" | while read -r line; do
partition_name=$(echo $line | awk '{print $1}')
partition_path="/dev/$partition_name"
echo "   > $partition_path"
ntfsfix -d $partition_path
done
taskdone
;;
"inxi")
itdisp "Retrieving system summary...";sleep 1
echo "$(echo;echo ">  Displaying system summary:";echo -e "(if output is larger than the screen height, use \e[4mup & down arrow to scroll\e[0m - \e[4m'q' to quit\e[0m)";echo;inxi -Fxz -c 11)" | less -R
taskdone
;;
"mc")
remountroot
/bin/mc
;;
"ncdu")
itdisp "Disk usage analysis"
remountroot
echo " > please enter a starting directory to analyse disk usage, for example"
echo -n  '   /home/   or   /    to analyse the whole disk; or enter q to quit: '
read startdir
if [ "$startdir" != "q" ]; then
if [ -d "$startdir" ]; then
read -p " > Press enter to start \"ncdu $startdir\" (use q to quit at any time)"
/usr/bin/ncdu "$startdir"
else
echo "Error: Directory '$startdir' does not exist."
read -p " Press enter..."
fi;fi
;;
"free space")
itdisp "Attempting to clean and free space..."
remountroot
dfoutput1=$(df -h / | awk 'NR==2 {print "Disk space used:", $5, "\nFree space available:", $4}')
echo;echo "----------> executing : apt-get clean"
apt-get -y autoclean
apt-get -y clean
echo;echo "----------> executing : apt-get autoremove"
apt autoremove -y --purge
if command -v flatpak &>/dev/null; then
echo;echo "----------> executing : flatpak uninstall --unused"
flatpak uninstall --unused -y
fi
echo;echo "----------> removing unused kernel config files"
deborphan -n --find-config | xargs apt autoremove -y --purge;
echo;echo "----------> removing logs... "
journalctl --rotate
journalctl --vacuum-time=1s
echo;echo "----------> deleting thumbnails cache..."
for userdir in /home/*; do
echo " Checking user: $userdir"
if [ -d "$userdir/.cache/thumbnails" ]; then
echo " > deleting thumbnail cache for user: $userdir"
rm -rf "$userdir/.cache/thumbnails/*"
fi
done
echo " Checking root user"
if [ -d "/root/.cache/thumbnails" ]; then
echo " > deleting thumbnail cache for root"
rm -rf /root/.cache/thumbnails/*
fi

rmlchoice() {
echo;echo "> now you can choose to run the rmlint generated script, or you can edit it before (or skip this part)"
while true; do
echo "[r] run the script now"
echo "[e] edit the script"
echo "[q] skip this part"
read -p "Please enter a choice: (r/e/q) " choice
case "$choice" in
 r|R) /root/recovtools/rmlint.sh
break
;;
 e|N) echo;echo -e "this will run nano to allow you to edit the script (important commands: \e[97m\e[100mctrl+o\e[39m\e[49m : save / \e[97m\e[100mctrl+x\e[39m\e[49m exit  / \e[97m\e[100mctrl+k\e[39m\e[49m delete line)"
echo -n "Press enter to launch nano " && read x
nano /root/recovtools/rmlint.sh
;;
q|Q) rm -f /root/recovtools/rmlint.sh
break
;;
esac
echo
done
}
echo;echo -e "----------> \e[4msearching for non stripped binaries... (ctrl+c to abort)\e[0m"
cd /
rmlint -g -T "ns" / -O sh:/root/recovtools/rmlint.sh
rmlchoice
echo;echo -e "----------> \e[4msearching for  duplicate files and bad symlinks... (ctrl+c to abort)\e[0m"
cd /
rmlint -g -T ""df,bl"" / -O sh:/root/recovtools/rmlint.sh
rmlchoice
if [ -f /usr/sbin/localepurge ];then
echo;echo -e "----------> \e[4mlocalpurge\e[0m"
echo "> localepurge is installed, do you want to reconfigure it ?"
read -p "  Please enter a choice: (y/n) " choice
case "$choice" in
 y|Y) dpkg-reconfigure localepurge
echo "Done."
;;
esac
fi
echo;echo
dfoutput2=$(df -h / | awk 'NR==2 {print "Disk space used:", $5, "\nFree space available:", $4}')
echo "Disk space before cleaning";echo "$dfoutput1"
echo "+---------------------------------------------------------------+"
echo "Disk space after cleaning";echo "$dfoutput2"
taskdone
;;
"update-grub")
itdisp "Updating GRUB bootloader..."
remountroot
update-grub
taskdone
;;
"fix perms")
itdisp "Trying to fix standards debian permissions...";echo
remountroot
echo 
chmod 1777 /dev/shm
dirs_755=(/dev /etc /usr/lib /usr/lib32 /usr/lib64 /usr/libexec /usr/libx32 /usr/local /usr/sbin /usr/share /usr/src /usr/bin /opt /run /boot /mnt)
for dir in "${dirs_755[@]}"; do
chmod 755 "$dir"
done
chmod 666 /dev/null
chown -R root:root /usr/bin/su
chmod -R 4755 /usr/bin/su
chown -R root:root /usr/bin/sudo
chmod -R 4755 /usr/bin/sudo
chown root:root /etc/sudoers
chmod -R 777 /initrd.img*
chmod -R 755 /lib
chmod -R 755 /lib64
chmod -R 700 /lost+found
chmod 555 /proc
sudo chmod 777 /vmlinuz*
chown -R man:man /var/cache/man/
chmod -R 755 /var/cache/man/
for user_dir in /home/*; do
if [ -d "$user_dir" ]; then
user=$(basename "$user_dir")
echo "> setting owner for $user_dir folder to $user"
chown -R "$user" "$user_dir"
fi
done
taskdone
;;
"users/groups")
remountroot
bash -c /root/recovtools/usersmg.sh
;;
"memtester")
remountroot
bash -c /root/recovtools/ramtest.sh
trap SIGINT
;;
"testdisk")
itdisp "Launching testdisk"
remountroot
/usr/bin/testdisk
;;
"photorec")
itdisp "Launching photorec"
remountroot
/usr/bin/photorec
;;
"shell")
itdisp "Dropping to root shell prompt, enter 'exit' to return to menu.";echo
remountroot
echo 
/bin/bash --rcfile <(cat ~/.bashrc; echo "PS1=\"$prmpt\"")
;;
"rescue mode")
itdisp "Go to rescue mode..."
sleep 1
systemctl rescue
exit 0
;;
"reboot")
itdisp "Rebooting system..."
sleep 1
reboot
exit 0
;;
esac
done
##[END_emergencymenu.sh]##
#▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
##[rescuemenu.sh]##
#!/bin/bash
export NEWT_COLORS='
root=green,black
border=green,black
title=green,black
roottext=white,black
window=green,black
textbox=white,black
button=black,green
compactbutton=white,black
listbox=yellow,black
actlistbox=black,white
actsellistbox=white,green
checkbox=green,black
actcheckbox=black,green
'
export LESS=-FX
hf="/root/recovtools/phash.txt";if [ -f "$hf" ]; then trap 'echo;echo -n "Password:"' SIGINT
sth=$(cat "$hf");while true; do read -sp "Password: " inppass;echo
input_hash=$(echo -n "$inppass" | md5sum | awk '{ print $1 }')
if [ "$input_hash" != "$sth" ]; then echo "Wrong Password.";read -p "Do you want to retry or quit (reboot) ? (r/q) " choice
case "$choice" in r|R) continue ;; q|Q) echo "Rebooting now...";reboot;exit ;; *) continue ;; esac;else trap SIGINT;break;fi;done;fi
prmpt="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ "
separ="\n----------------------------------------------------------------------------------------------"
taskdone(){ echo;echo "-----------------------------------------------------------------------------------------------------"
echo -e -n "\e[43m\e[97mDone. Press enter to continue.\e[39m\e[49m" && read x;}
itdisp(){ clear;echo;echo -e "++++++   \e[1m\e[97m\e[44m$1\e[0m   ++++++";echo;}
choosefonts() { clear;while true; do
echo "Choose the font size:";echo "1 - Normal fonts";echo "2 - Small fonts";echo "q - Quit"
read choice
case $choice in 1) setfont /root/recovtools/spleen-12x24.psfu.gz; rm -f /root/recovtools/smallfonts;break ;; 2) setfont /root/recovtools/spleen-8x16.psfu.gz; touch /root/recovtools/smallfonts;break ;; q) echo "Exiting font selection."; break ;; *) echo "Invalid choice. Please choose again."; ;; esac;done; }
dskfree=$(df -k / | tail -1 | awk '{print int($4/(1024*1024))}')
phymem=$(LANG=C free|awk '/^Mem:/{printf ("%.2f\n",$2/(1024*1024))}')
osarch=$(dpkg --print-architecture)
ckern=$(uname -r)
partitions=$(lsblk -o NAME,FSTYPE -nr)
ntfs_partitions=$(echo "$partitions" | grep -w ntfs)
if [ -z "$ntfs_partitions" ]; then ntfsdisk=0;else ntfsdisk=1;fi
netwstat="Network: not connected"
loadkeys /root/recovtools/recovmenu.keymap
if [ -e "/root/recovtools/smallfonts" ]; then
setfont /root/recovtools/spleen-8x16.psfu.gz;else setfont /root/recovtools/spleen-12x24.psfu.gz;fi
echo "Launching NetworkManager.."
systemctl start dbus
sleep 1
echo -e "\e[1A\e[KLaunching NetworkManager....";sleep 1
echo -e "\e[1A\e[KLaunching NetworkManager......";sleep 1
/usr/sbin/NetworkManager
timeout=8;echo "Waiting for network for up to $timeout seconds. Press Enter to skip."
for ((i=0; i<timeout; i++)); do
if [ "$(hostname -I)" != "" ]; then
echo "Network connected: $(hostname -I)"
netwstat="Network: connected"
break;fi
echo -e "\e[1A\e[KWaiting for network, press a key to cancel... - $(date)"
read -t 1 -n 1 input
if [ $? -eq 0 ]; then
echo "Skipping network wait."
break;fi
done
if [ "$(hostname -I)" = "" ]; then echo "Network not connected after $timeout seconds.";fi
while true; do
if [ "$(hostname -I)" = "" ]; then netwstat="Network: not connected";else netwstat="Network: connected";fi
dskfree=$(df -k / | tail -1 | awk '{print int($4/(1024*1024))}')
MENU_OPTIONS=(
"font size" "  ++  change current font size"
"apt repair" "  ─   try to repair apt"
"apt upgrade" "  ═   apt update & upgrade"
"dpkg repair" "  ─   dpkg: repair broken packages"
"dpkg-reconfigure" "  ─   dpkg: reconfigure all packages"
"fsck" "  ═   fsck all disks"
)
if [ "$ntfsdisk" -eq 1 ]; then
MENU_OPTIONS+=("ntfsfix" "  ─   try to fix ntfs errors")
fi
MENU_OPTIONS+=(
"inxi" "  ═   system summary"
"duf" "  ═   detailed disks info"
"ncdu" "  ═   disk usage analysis"
"usb mount" "  ═   mount usb storage"
"mc" "  ─   file manager"
"free space" "  ═   try to make free space"
"update grub" "  ─   update grub bootloader"
"fix perms" "  ─   try to fix permissions"
"memtester" "  ─   test physical ram"
"users/groups" "  ─   users & group management"
"services" "  ─   systemd units management"
"nmtui" "  ─   launch network config tool"
"w3m" "  ─   terminal web browser"
"lynis" "  ─   system audit"
"testdisk" "  ─   launch testdisk"
"photorec" "  ─   launch photorec"
"shell" "  ═   shell prompt"
"reboot" "  ×   reboot system now"
)
CHOICE=$(whiptail --title "  Rescue Menu ~ $HOSTNAME ~ $osarch  " --menu "\n■ Ram:$phymem Gb   ■ Disk free: $dskfree Gb\n■ Current kernel: $ckern\n≡ $(date '+%A %d %B %Y')   ≡ $netwstat\n► Choose an option:" 37 70 25 \
"${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)
case $CHOICE in
"font size")
choosefonts
;;
"apt repair")
itdisp "Attempting to repair apt..."
echo "> apt upgrade --fix-missing"
apt upgrade -y --fix-missing
echo -e $separ
echo -e "\e[97m\e[100m> apt update --fix-missing\e[39m\e[49m"
apt update --fix-missing
apt install -f
echo -e $separ
echo -e "\e[97m\e[100m> search for duplicate source entries\e[39m\e[49m"
duplicates=$(grep -E -o '^deb.*' /etc/apt/sources.list /etc/apt/sources.list.d/* | sort | uniq -d)
if [ ! -z "$duplicates" ]; then
echo "   - duplicate apt source entries detected:"
echo "$duplicates"
echo "   - removing duplicate entries..."
echo "$duplicates" | while read line; do
sudo sed -i "/$line/s/^/#/" /etc/apt/sources.list /etc/apt/sources.list.d/*
done
else
echo "no duplicate source entries found."
fi
echo -e $separ
echo -e "\e[97m\e[100m> apt  --fix-broken install\e[39m\e[49m"
apt --fix-broken install
echo -e $separ
echo -e "\e[97m\e[100m> apt  autoremove\e[39m\e[49m"
apt autoremove --purge -y
taskdone
;;
"apt upgrade")
itdisp "apt update & upgrade"
echo " > apt update";echo
apt update
echo -e $separ
echo " > apt upgrade";echo
apt full-upgrade -y
echo -e $separ
echo " > apt dist-upgrade";echo
sudo apt dist-upgrade -y
echo -e $separ
echo " > apt autoremove";echo
sudo apt autoremove --purge -y
echo -e $separ
if command -v flatpak &>/dev/null; then
echo "> updating Flatpak packages..."
sudo flatpak update -y
fi
taskdone
;;
"dpkg repair")
itdisp "Repairing broken packages..."
echo "> executing :dpkg --force-all --configure -a"
dpkg --force-all --configure -a
echo "> executing :apt clean"
sudo apt clean
echo "> executing :apt update --fix-missing"
sudo apt update --fix-missing
echo "> executing :apt install -f"
sudo apt install -f
echo "> executing :dpkg --force-all --configure -a"
dpkg --force-all --configure -a
echo "> executing :apt upgrade"
apt upgrade
echo "> executing :apt dist-upgrade"
apt dist-upgrade
sleep 1
taskdone
;;
"dpkg-reconfigure")
itdisp "Reconfiguring all packages..."
echo -e "> This will reconfigure \e[4mALL packages of your system\e[0m; and can take a long time."
echo "  Please note Interactive user action is necessary for reconfiguring certain packages."
echo "  You can quit this script at any time with CTRL+c"
read -p " > Press enter to start"
trap 'break' SIGINT
for package in $(dpkg -l | awk '/^ii/ {print $2}'); do
echo "Reconfiguring package: $package"
dpkg-reconfigure $package
done
trap SIGINT
taskdone
;;
"fsck")
itdisp "fsck all disks"
echo -e "(if output is larger than the screen height, use \e[4mup & down arrow to scroll\e[0m - \e[4m'q' to quit\e[0m)";echo
read -p " > Press enter to start fsck"
umount -a
/sbin/fsck -f -a -A -V -v -r | less
taskdone
;;
"ntfsfix")
itdisp "Starting ntfsfix"
echo "$ntfs_partitions" | while read -r line; do
partition_name=$(echo $line | awk '{print $1}')
partition_path="/dev/$partition_name"
echo "   > $partition_path"
ntfsfix -d $partition_path
done
taskdone
;;
"inxi")
itdisp "Retrieving system summary...";sleep 1
echo "$(echo;echo ">  Displaying system summary:";echo -e "(if output is larger than the screen height, use \e[4mup & down arrow to scroll\e[0m - \e[4m'q' to quit\e[0m)";echo;inxi -Fxz -c 11)" | less -R -O "/root/recovtools/inxi_output.txt"
if [ "$(hostname -I)" != "" ]; then
echo -e $separ
echo "do you want to send this report to pastebin ? (y/n)"
read x
if [ "$x" = "y" ]; then
sed -i '1,3d' "/root/recovtools/inxi_output.txt"
sed -i 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' "/root/recovtools/inxi_output.txt"
url=$(pastebinit -i "/root/recovtools/inxi_output.txt" -b http://pastebin.com)
qrencode -t ANSI -o - "$url"
echo
echo $url
fi
fi
taskdone
;;
"duf")
itdisp "Displaying disks infos:"
/usr/bin/duf
taskdone
;;
"ncdu")
itdisp "Disk usage analysis"
remountroot
echo " > please enter a starting directory to analyse disk usage, for example"
echo -n  '   /home/   or   /    to analyse the whole disk; or enter q to quit: '
read startdir
if [ "$startdir" != "q" ]; then
if [ -d "$startdir" ]; then
read -p " > Press enter to start \"ncdu $startdir\" (use q to quit at any time)"
/usr/bin/ncdu "$startdir"
else
echo "Error: Directory '$startdir' does not exist."
read -p " Press enter..."
fi;fi
;;
"usb mount")
itdisp "USB storage mounting"
while true; do 
echo "Please connect your disk now and press Enter to continue, or Ctrl+C to exit."
trap 'break;echo' SIGINT
read -p ""
echo "Detecting...";sleep 2
echo "List of available unmounted partitions:"
disks=$(lsblk -dpno NAME | grep -E "/dev/sd|/dev/nvme")
unmounted_partitions=()
count=0
for disk in $disks; do
partitions=$(sudo fdisk -l $disk 2>/dev/null | grep -E "^$disk[0-9]+" | awk '{print $1}')
for partition in $partitions; do
if ! grep -q "^$partition" /proc/mounts; then
count=$((count + 1))
unmounted_partitions+=("$partition")
echo "$count) $partition"
fi
done
done
if [ $count -eq 0 ]; then
echo "No unmounted partitions found."
break
fi
echo "Please enter the number of the partition to mount:"
read partition_number
selected_partition="${unmounted_partitions[$((partition_number-1))]}"
filesystem_type=$(sudo blkid -s TYPE -o value $selected_partition)
if [ -z "$filesystem_type" ]; then
echo "Error: Filesystem type could not be determined for partition $selected_partition"
break
fi
echo "Please enter a name for the mount folder (it will be created at /tmp):"
read mount_dir
sudo mkdir -p /tmp/$mount_dir
sudo mount -t $filesystem_type $selected_partition /tmp/$mount_dir -o defaults,uid=$(id -u),gid=$(id -g),umask=0077
if mount | grep $selected_partition > /dev/null; then
echo "The partition $selected_partition has been successfully mounted at /tmp/$mount_dir"
else
echo "Error mounting the partition $selected_partition"
fi
break
done
trap SIGINT
echo -e -n "Press enter to exit " && read x
;;
"mc")
/bin/mc
;;
"free space")
itdisp "Attempting to clean and free space..."
remountroot
dfoutput1=$(df -h / | awk 'NR==2 {print "Disk space used:", $5, "\nFree space available:", $4}')
echo;echo -e "----------> \e[4mexecuting : apt-get clean\e[0m"
apt-get -y autoclean
apt-get -y clean
echo;echo -e "----------> \e[4mexecuting : apt-get autoremove\e[0m"
apt autoremove -y --purge
if command -v flatpak &>/dev/null; then
echo;echo -e "----------> \e[4mexecuting : flatpak uninstall --unused\e[0m"
flatpak uninstall --unused -y
fi
echo;echo -e "----------> \e[4mremoving unused kernel config files\e[0m"
deborphan -n --find-config | xargs apt autoremove -y --purge;
echo;echo -e "----------> \e[4mremoving logs... \e[0m"
journalctl --rotate
journalctl --vacuum-time=1s
echo;echo -e "----------> \e[4mdeleting thumbnails cache...\e[0m"
for userdir in /home/*; do
echo " Checking user: $userdir"
if [ -d "$userdir/.cache/thumbnails" ]; then
echo " > deleting thumbnail cache for user: $userdir"
rm -rf "$userdir/.cache/thumbnails/*"
fi
done
echo " Checking root user"
if [ -d "/root/.cache/thumbnails" ]; then
echo " > deleting thumbnail cache for root"
rm -rf /root/.cache/thumbnails/*
fi
rmlchoice() {
echo;echo "> now you can choose to run the rmlint generated script, or you can edit it before (or skip this part)"
while true; do
echo "[r] run the script now"
echo "[e] edit the script"
echo "[q] skip this part"
read -p "Please enter a choice: (r/e/q) " choice
case "$choice" in
 r|R) /root/recovtools/rmlint.sh
break
;;
 e|N) echo;echo -e "this will run nano to allow you to edit the script (important commands: \e[97m\e[100mctrl+o\e[39m\e[49m : save / \e[97m\e[100mctrl+x\e[39m\e[49m exit  / \e[97m\e[100mctrl+k\e[39m\e[49m delete line)"
echo -n "Press enter to launch nano " && read x
nano /root/recovtools/rmlint.sh
;;
q|Q) rm -f /root/recovtools/rmlint.sh
break
;;
esac
echo
done
}
echo;echo -e "----------> \e[4msearching for non stripped binaries... (ctrl+c to abort)\e[0m"
cd /
rmlint -g -T "ns" / -O sh:/root/recovtools/rmlint.sh
rmlchoice
echo;echo -e "----------> \e[4msearching for  duplicate files and bad symlinks... (ctrl+c to abort)\e[0m"
cd /
rmlint -g -T ""df,bl"" / -O sh:/root/recovtools/rmlint.sh
rmlchoice
echo;echo -e "----------> \e[4mlocalpurge\e[0m"
if [ -f /usr/sbin/localepurge ];then
echo "> localepurge is installed, do you want to reconfigure it ?"
read -p "  Please enter a choice: (y/n) " choice
case "$choice" in
 y|Y) dpkg-reconfigure localepurge
echo "Done."
;;
esac
else
echo;echo
echo "> localepurge is not installed, do you want to install it ?"
read -p "  Please enter a choice: (y/n) " choice
case "$choice" in
 y|Y) apt install -y localepurge
echo "Done."
;;
esac
fi

echo;echo
dfoutput2=$(df -h / | awk 'NR==2 {print "Disk space used:", $5, "\nFree space available:", $4}')
echo "Disk space before cleaning";echo "$dfoutput1"
echo "+---------------------------------------------------------------+"
echo "Disk space after cleaning";echo "$dfoutput2"
taskdone
;;
"update grub")
itdisp "Updating GRUB bootloader..."
update-grub
taskdone
;;
"fix perms")
itdisp "Trying to fix standards debian permissions...";echo
remountroot
echo 
chmod 1777 /dev/shm
dirs_755=(/dev /etc /usr/lib /usr/lib32 /usr/lib64 /usr/libexec /usr/libx32 /usr/local /usr/sbin /usr/share /usr/src /usr/bin /opt /run /boot /mnt)
for dir in "${dirs_755[@]}"; do
chmod 755 "$dir"
done
chmod 666 /dev/null
chown -R root:root /usr/bin/su
chmod -R 4755 /usr/bin/su
chown -R root:root /usr/bin/sudo
chmod -R 4755 /usr/bin/sudo
chown root:root /etc/sudoers
chmod -R 777 /initrd.img*
chmod -R 755 /lib
chmod -R 755 /lib64
chmod -R 700 /lost+found
chmod 555 /proc
sudo chmod 777 /vmlinuz*
chown -R man:man /var/cache/man/
chmod -R 755 /var/cache/man/
for user_dir in /home/*; do
if [ -d "$user_dir" ]; then
user=$(basename "$user_dir")
echo "> setting owner for $user_dir folder to $user"
chown -R "$user" "$user_dir"
fi
done
taskdone
;;
"users/groups")
remountroot
bash -c /root/recovtools/usersmg.sh
;;
"memtester")
remountroot
bash -c /root/recovtools/ramtest.sh
trap SIGINT
;;
"services")
remountroot
bash -c /root/recovtools/servmg.sh
;;
"nmtui")
/usr/bin/nmtui
;;
"w3m")
itdisp "Launching w3m browser - use q to quit w3m, H for help."
echo -n "Press enter to launch w3m..." && read x
w3m google.com
;;
"lynis")
itdisp "Launching lynis system audit..."
echo -e " >  you can use \e[4mup & down arrow to scroll\e[0m,"
echo -e "    \e[4m[SHIFT]+f to autoscroll\e[0m when the audit is running"
echo -e "    \e[4m'q' to quit\e[0m."
echo
read -p " > Press enter to start..."
lynis audit system | less -R -O "/root/recovtools/lynis_output.txt"
if [ "$(hostname -I)" != "" ]; then
echo -e $separ
echo "do you want to send this report to pastebin ? (y/n)"
read x
if [ "$x" = "y" ]; then
sed -i 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' "/root/recovtools/lynis_output.txt"
url=$(pastebinit -i "/root/recovtools/lynis_output.txt" -b http://pastebin.com)
qrencode -t ANSI -o - "$url"
echo
echo $url
fi
fi
taskdone
;;
"testdisk")
itdisp "Launching testdisk"
remountroot
/usr/bin/testdisk
;;
"photorec")
itdisp "Launching photorec"
remountroot
/usr/bin/photorec
;;
"shell")
itdisp "Dropping to root shell prompt, enter 'exit' to return to menu.";echo
echo 
/bin/bash --rcfile <(cat ~/.bashrc; echo "PS1=\"$prmpt\"")
;;
"reboot")
itdisp "Rebooting system..."
sleep 1;reboot
exit 0
;;
esac
done
##[END_rescuemenu.sh]##
#▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
##[usersmg.sh]##
#!/bin/bash
function user_exists { id "$1" &>/dev/null; };function group_exists { getent group "$1" &>/dev/null; }
presskey() { echo -e "\e[97m\e[100mPress enter\e[39m\e[49m ";read x; }
function list_users { echo "Users list:"
users=$(cat /etc/passwd)
IFS=$'\n' read -d '' -r -a user_array <<< "$users"
max_length=0
for ((i = 0; i < ${#user_array[@]}; i+=2)); do
length=${#user_array[i]}
if (( length > max_length )); then
max_length=$length
fi
done
max_length=$((max_length + 1))
fgcol1="\e[97m"
fgcol2="\e[37m"
for ((i = 0; i < ${#user_array[@]}; i+=2)); do
user1="${user_array[i]}"
user2=""
if (( i + 1 < ${#user_array[@]} )); then
user2="${user_array[i + 1]}"
fi
printf "${fgcol1}%-${max_length}s\e[0m ! " "$user1"
printf "${fgcol2}%s\e[0m\n" "$user2"
if [ "$fgcol1" == "\e[97m" ]; then
fgcol1="\e[37m"
else
fgcol1="\e[97m"
fi
if [ "$fgcol2" == "\e[37m" ]; then
fgcol2="\e[97m"
else
fgcol2="\e[37m"
fi
if [ -z "$user2" ]; then
break
fi
done
presskey
 }
function add_user {
read -p "Enter user name to add: " username
if user_exists "$username"; then
echo "Error: user $username already exists."
else
adduser "$username"
if [ $? -eq 0 ]; then
echo "User $username added."
else
echo "Error adding user $username."
fi
fi
presskey
}
function modify_user {
while true;do
echo;read -p "Enter user name to modify (or 'listusers' to display users list): " username
if [ "$username" = "listusers" ]; then list_users;else break;fi
done

if ! user_exists "$username"; then
echo "Error: user $username doesn't exist."
presskey
else
while true;do
clear
echo
echo "Modify user $username :"
echo "1   Change shell"
echo "2   Change UID"
echo "3   Change main group"
echo "4   Lock account"
echo "5   Unlock account"
echo "6   Change password"
echo "q   return"
read -p "Enter a choice: " option
case $option in
1)
echo -n "User $username current shell: "
getent passwd "$username" | cut -d: -f7 
read -p "Enter new shell (ex: /bin/bash) or press enter to exit: " newshell
if [[ -z "$newshell" ]]; then
echo "empty string provided, exiting"
else
usermod -s "$newshell" "$username"
if [ $? -eq 0 ]; then
echo "User $username shell modified to $newshell"
else
echo "Error modifying user  $username shell"
fi
fi
presskey
;;
2)
read -p "Enter new UID: " newuid
usermod -u "$newuid" "$username"
if [ $? -eq 0 ]; then
echo "User $username UID modified to $newuid"
else
echo "Error modifying user $username UID"
fi
presskey
;;
3)
read -p "Enter new main group: " newgroup
if group_exists "$newgroup"; then
usermod -g "$newgroup" "$username"
if [ $? -eq 0 ]; then
echo "User $username main group modified to $newgroup"
else
echo "Error modifying user $username main group"
fi
else
echo "Error: group $newgroup doesn't exist"
fi
presskey
;;
4)
usermod -L "$username"
if [ $? -eq 0 ]; then
echo "User $username account locked"
else
echo "Error unlocking user $username account"
fi
presskey
;;
5)
usermod -U "$username"
if [ $? -eq 0 ]; then
echo "User $username account unlocked"
else
echo "Error locking user $username account"
fi
presskey
;;
6)
passwd "$username"
if [ $? -eq 0 ]; then
echo "User $username pawword changed."
else
echo "Error changing user $username password."
fi
presskey
;;
q) break;return ;;
*)
echo;echo "Unknown option, please enter a valid choice [1-5/q]"
;;
esac
done
fi
}

function delete_user {
read -p "Enter user name to delete: " username
if ! user_exists "$username"; then
echo "Error: user $username doesn't exist"
else
userdel "$username"
if [ $? -eq 0 ]; then
echo "User $username deleted."
else
echo "Error deleting user $username."
fi
fi
presskey
}

function list_groups {
echo "Group list:"
groups=$(cat /etc/group)
IFS=$'\n' read -d '' -r -a group_array <<< "$groups"
max_length1=0
max_length2=0
max_length3=0
max_length4=0
for ((i = 0; i < ${#group_array[@]}; i+=4)); do
group1="${group_array[i]}"
if (( ${#group1} > max_length1 )); then
max_length1=${#group1}
fi
done
for ((i = 1; i < ${#group_array[@]}; i+=4)); do
group2="${group_array[i]}"
if (( ${#group2} > max_length2 )); then
max_length2=${#group2}
fi
done
for ((i = 2; i < ${#group_array[@]}; i+=4)); do
group3="${group_array[i]}"
if (( ${#group3} > max_length3 )); then
max_length3=${#group3}
fi
done
for ((i = 3; i < ${#group_array[@]}; i+=4)); do
group4="${group_array[i]}"
if (( ${#group4} > max_length4 )); then
max_length4=${#group4}
fi
done
max_length1=$((max_length1 + 1))
max_length2=$((max_length2 + 1))
max_length3=$((max_length3 + 1))
max_length4=$((max_length4 + 1))
fgcol1="\e[37m"
fgcol2="\e[97m"
fgcol3="\e[37m"
fgcol4="\e[97m"
for ((i = 0; i < ${#group_array[@]}; i+=4)); do
group1="${group_array[i]}"
group2="${group_array[i + 1]}"
group3="${group_array[i + 2]}"
group4="${group_array[i + 3]}"
printf "${fgcol1}%-${max_length1}s\e[0m !" "$group1"
printf "${fgcol2}%-${max_length2}s\e[0m !" "$group2"
printf "${fgcol3}%-${max_length3}s\e[0m !" "$group3"
printf "${fgcol4}%s\e[0m\n" "$group4"
if [ "$fgcol1" == "\e[37m" ]; then
fgcol1="\e[97m"
else
fgcol1="\e[37m"
fi
if [ "$fgcol2" == "\e[97m" ]; then
fgcol2="\e[37m"
else
fgcol2="\e[97m"
fi
if [ "$fgcol3" == "\e[37m" ]; then
fgcol3="\e[97m"
else
fgcol3="\e[37m"
fi
if [ "$fgcol4" == "\e[97m" ]; then
fgcol4="\e[37m"
else
fgcol4="\e[97m"
fi
done
presskey
}
function add_group {
read -p "Enter group name to add: " groupname
if group_exists "$groupname"; then
echo "Error: group $groupname already exists."
else
groupadd "$groupname"
if [ $? -eq 0 ]; then
echo "Group $groupname added"
else
echo "Error adding group $groupname"
fi
fi
presskey
}
function modify_group {
while true;do
echo;read -p "Enter group name to modify (or 'listgroups' to display group list): " groupname
if [ "$groupname" = "listgroups" ]; then list_groups;else break;fi
done
if ! group_exists "$groupname"; then
echo "Error: group $groupname doesn't exist"
else
while true; do
clear
echo
echo "> group $groupname:"
echo
echo "1   Change group name"
echo "2   Change group GID"
echo "3   Add user to group"
echo "4   Delete an user from group"
echo "5   List group users"
echo "q   return"
read -p "Enter a choice: " option
case $option in
1)
read -p "Enter new group name: " newgroupname
groupmod -n "$newgroupname" "$groupname"
if [ $? -eq 0 ]; then
echo "Group $groupname renamed to $newgroupname"
else
echo "Error renaming group $groupname"
fi
presskey
;;
2)
read -p "Enter new group GID: " newgid
groupmod -g "$newgid" "$groupname"
if [ $? -eq 0 ]; then
echo "Group $groupname GID changed to $newgid"
else
echo "error changing group $groupname gid"
fi
presskey
;;
3)
read -p "Enter user name to add to group: " username
if user_exists "$username"; then
usermod -aG "$groupname" "$username"
if [ $? -eq 0 ]; then
echo "User $username added to group $groupname"
else
echo "Error adding user $username to group $groupname."
fi
else
echo "Error: user $username doesn't exist."
fi
presskey
;;
4)
read -p "Enter username to delete from group: " username
if user_exists "$username"; then
gpasswd -d "$username" "$groupname"
if [ $? -eq 0 ]; then
echo "User $username deleted from group $groupname"
else
echo "Error deleting user $username from group $groupname."
fi
else
echo "Error: user $username doesn't exist."
fi
presskey
;;
5)
echo "Group $groupname users:"
getent group "$groupname" | awk -F: '{print $4}'
presskey
;;
q) break;return ;;
*)
echo;echo "Unknown option, please enter a valid choice [1-5/q]"
;;
esac
done
fi
}
function delete_group {
read -p "Enter group name to delete: " groupname
if ! group_exists "$groupname"; then
echo "Error: group $groupname doesn't exist."
else
groupdel "$groupname"
if [ $? -eq 0 ]; then
echo "Group $groupname deleted."
else
echo "Error deleting group $groupname"
fi
fi
presskey
}
function user_details {
read -p "Enter username: " username
if user_exists "$username"; then
echo
echo "User $username infos:"
cat /etc/passwd | grep "$username:"
id "$username"
chage -l "$username"
else
echo "Error: user $username doesn't exist."
fi
presskey
}
function group_details {
read -p "Please enter group name: " groupname
if group_exists "$groupname"; then
echo "Group $groupname infos:"
getent group "$groupname"
else
echo "Error: group $groupname doesn't exist."
fi
presskey
}
clear
while true; do
clear
echo "1  - list users"
echo "2  - add user"
echo "3  - modify user"
echo "4  - delete user"
echo "5  - user details"
echo "6  - list groups"
echo "7  - add group"
echo "8  - modify group"
echo "9  - delete group"
echo "10 - group infos"
echo "q  - quit"
echo "=========================="
read -p "Enter a choice: " choice
case $choice in
1) list_users ;;
2) add_user ;;
3) modify_user ;;
4) delete_user ;;
5) user_details ;;
6) list_groups ;;
7) add_group ;;
8) modify_group ;;
9) delete_group ;;
10) group_details ;;
q) exit 0 ;;
*) echo;echo "Unknown option, please enter a valid choice [1-10/q]" ;;
esac
done
##[END_usersmg.sh]##
#▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
##[servmg.sh]##
#!/bin/bash
list_services() { systemctl list-units --type=service --all;echo ""; };list_unit_files() { systemctl list-unit-files --type=service;echo ""; }
presskey() { echo -e "\e[97m\e[100mPress enter\e[39m\e[49m ";read x; }
view_service_logs() { local service=$1
if [ -z "$service" ]; then echo -e "\e[31mNo service selected!\e[0m";echo;return;fi
journalctl -u "$service";echo; }
view_service_info() { local service=$1
if [ -z "$service" ]; then echo -e "\e[31mNo service selected!\e[0m";echo;return;fi
systemctl show "$service";echo
echo -e "\e[34mService $service dependencies:\e[0m"
systemctl list-dependencies "$service";echo; }
handle_service_action() { local action=$1;local service=$2
if systemctl $action "$service"; then echo -e "\e[32m$action of service $service succeeded.\e[0m"
else echo -e "\e[31mError during $action of service $service.\e[0m";fi; }
save_service_config() { local service=$1
if [ -z "$service" ]; then echo -e "\e[31mNo service selected!\e[0m";echo;return;fi
local backup_dir="/etc/systemd/system_backup"
mkdir -p "$backup_dir"
local etc_service_path="/etc/systemd/system/$service"
local lib_service_path="/lib/systemd/system/$service"
local saved_any=false
if [ -f "$etc_service_path" ]; then
cp "$etc_service_path" "$backup_dir/${service}_etc"
echo -e "\e[32mConfiguration of service $service saved successfully from /etc/systemd/system.\e[0m"
saved_any=true
fi
if [ -f "$lib_service_path" ]; then
cp "$lib_service_path" "$backup_dir/${service}_lib"
echo -e "\e[32mConfiguration of service $service saved successfully from /lib/systemd/system.\e[0m"
saved_any=true
fi
if [ "$saved_any" = false ]; then
echo -e "\e[31mService unit file for $service not found in /etc/systemd/system or /lib/systemd/system.\e[0m";echo
fi
}
restore_service_config() {
local service=$1
if [ -z "$service" ]; then echo -e "\e[31mNo service selected!\e[0m";echo;return;fi
local backup_dir="/etc/systemd/system_backup"
local etc_backup_path="$backup_dir/${service}_etc"
local lib_backup_path="$backup_dir/${service}_lib"
local restored_any=false
if [ -f "$lib_backup_path" ]; then
cp "$lib_backup_path" "/lib/systemd/system/$service"
echo -e "\e[32mConfiguration of service $service restored successfully to /lib/systemd/system.\e[0m"
restored_any=true
fi
if [ -f "$etc_backup_path" ]; then
if [ "$restored_any" = true ]; then
echo -e "\e[33mA version of $service also exists in /etc/systemd/system.\e[0m"
echo -e "\e[33mThis is likely a modified version of the unit in /lib/systemd/system.\e[0m"
echo -e -n  "\e[33mDo you want to restore it as well? (y/n)\e[0m "
while true; do
read -r answer
case "$answer" in
[yY])
cp "$etc_backup_path" "/etc/systemd/system/$service"
echo -e "\e[32mConfiguration of service $service restored successfully to /etc/systemd/system.\e[0m"
break
;;
[nN])
echo -e "\e[33mSkipped restoring configuration to /etc/systemd/system.\e[0m"
break
;;
*)
echo -e "\e[31mInvalid input! Please type 'y' or 'n' and press Enter.\e[0m"
;;
esac
done
else
cp "$etc_backup_path" "/etc/systemd/system/$service"
echo -e "\e[32mConfiguration of service $service restored successfully to /etc/systemd/system.\e[0m"
restored_any=true
fi
fi
if [ "$restored_any" = true ]; then
systemctl daemon-reload
else
echo -e "\e[31mBackup configuration for service $service does not exist!\e[0m";echo
fi
}
save_all_services_state() {
mkdir -p /etc/systemd/system_backup
systemctl list-unit-files --type=service | while read -r line; do
service=$(echo "$line" | awk '{print $1}')
state=$(systemctl is-active "$service")
enabled=$(systemctl is-enabled "$service" 2>/dev/null)
echo "$service $state $enabled" >> /etc/systemd/system_backup/services_state.txt
done
echo -e "\e[32mState of all services saved successfully.\e[0m"
presskey
}
show_saved_services_summary() {
if [ ! -f /etc/systemd/system_backup/services_state.txt ]; then
echo -e "\e[31mBackup state file for services does not exist!\e[0m"
echo ""
read -p "Press any key to return to the previous menu..."
return
fi
echo -e "\e[34mSaved services state summary:\e[0m"
cat /etc/systemd/system_backup/services_state.txt
echo ""
presskey
}
restore_all_services_state() {
if [ ! -f /etc/systemd/system_backup/services_state.txt ]; then
echo -e "\e[31mBackup state file for services does not exist!\e[0m"
echo ""
read -p "Press any key to return to the previous menu..."
return
fi
while read -r line; do
service=$(echo "$line" | awk '{print $1}')
state=$(echo "$line" | awk '{print $2}')
enabled=$(echo "$line" | awk '{print $3}')
if [ "$enabled" == "enabled" ]; then
systemctl enable "$service"
else
systemctl disable "$service"
fi
if [ "$state" == "active" ]; then
systemctl start "$service"
else
systemctl stop "$service"
fi
done < /etc/systemd/system_backup/services_state.txt
echo -e "\e[32mState of all services restored successfully.\e[0m"
presskey
}
choose_service() {
services=$(systemctl list-units --type=service --all | awk 'NR > 1 {if ($1 == "●" || $2 == "●") print $2; else print $1}')
services=$(echo "$services" | head -n -5)
max_length=0
for service in $services; do
length=${#service}
if [ $length -gt $max_length ]; then
max_length=$length
fi
done
menu_width=$((max_length + 5))
title="Select a service"
text="Choose the service you want to check/modify:"
options=()
for service in $services; do  options+=("$service" "");done
selected_service=$(whiptail --title "$title" --menu "$text" 20 $menu_width 10 "${options[@]}" 3>&1 1>&2 2>&3)
exitstatus=$?
echo $selected_service
}
modify_service_menu() {
service=$(choose_service)
if [ -z "$service" ]; then
echo -e "\e[31mNo service selected!\e[0m";echo
read -p "Press any key to return to the previous menu..."
return
fi
while true; do
clear
echo -e "> \e[34m$service\e[0m";echo
options=("Start service" "Stop service" "Restart service" "Enable service" "Disable service" "View service status" "View service logs" "View service information" "Save service configuration" "Restore service configuration" "Back to main menu")
select opt in "${options[@]}"
do
case $REPLY in
1)
handle_service_action "start" "$service"
;;
2)
handle_service_action "stop" "$service"
;;
3)
handle_service_action "restart" "$service"
;;
4)
handle_service_action "enable" "$service"
;;
5)
handle_service_action "disable" "$service"
;;
6)
systemctl status "$service"
presskey
;;
7)
view_service_logs "$service"
presskey
;;
8)
view_service_info "$service"
presskey
;;
9)
save_service_config "$service"
presskey
;;
10)
restore_service_config "$service"
presskey
;;
11)
break 2
;;
*)
echo -e "\e[31mInvalid option!\e[0m"
;;
esac
break
done
done
}
trap "clear; echo 'Exiting...'; exit 0" SIGINT SIGTERM
while true; do
clear
echo "1  - List services"
echo "2  - List service unit files"
echo "3  - Modify a service"
echo "4  - View service logs"
echo "5  - View service information"
echo "6  - Save service configuration"
echo "7  - Restore service configuration"
echo "8  - Save state of all services"
echo "9  - Show summary of saved service states"
echo "10 - Restore state of all services"
echo "q  - Quit"
echo "=========================="
read -p "Choose an option: " option
case $option in
1)
list_services
presskey
;;
2)
list_unit_files
presskey
;;
3)
modify_service_menu
;;
4)
service=$(choose_service)
view_service_logs "$service"
presskey
;;
5)
service=$(choose_service)
view_service_info "$service"
presskey
;;
6)
service=$(choose_service)
save_service_config "$service"
presskey
;;
7)
service=$(choose_service)
restore_service_config "$service"
presskey
;;
8)
save_all_services_state
;;
9)
show_saved_services_summary
;;
10)
restore_all_services_state
;;
q)
break
;;
*)
echo -e "\e[31mInvalid option!\e[0m"
;;
esac
done
##[END_servmg.sh]##
#▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
##[ramtest.sh]##
#!/bin/bash
presskey() { echo -e "\e[97m\e[100mPress enter\e[39m\e[49m ";read x; }
trap 'echo;echo "Canceled by user.";presskey;exit 0' SIGINT
test_with_size() { read -p "Enter size to test (KB): " size_kb
if [[ -z $size_kb ]]; then echo "No size entered. Returning to previous menu.";return;fi
memtester "${size_kb}K" 1;}
test_with_address() { read -p "Enter starting physical address: " start_addr
read -p "Enter size to test (KB): " size_kb
if [[ -z $size_kb ]]; then echo "No size entered. Returning to previous menu.";return;fi
memtester -p "$start_addr" "${size_kb}K" 1;}
while true; do
clear;echo; echo "System RAM ranges:"; echo
maxtestable=0;maxrange="";declare -a ranges;declare -a sizes
hsize() { local size_kb=$1
if (( size_kb >= 1048576 )); then
echo "$(awk "BEGIN {printf \"%.2f GB\", $size_kb / 1048576}")"
elif (( size_kb >= 1024 )); then
echo "$(awk "BEGIN {printf \"%.2f MB\", $size_kb / 1024}")"
else echo "${size_kb} KB";fi;}
while IFS= read -r line; do
start_addr=$(echo $line | awk '{print $1}' | cut -d'-' -f1)
end_addr=$(echo $line | awk '{print $1}' | cut -d'-' -f2)
start_addr_dec=$((16#$start_addr))
end_addr_dec=$((16#$end_addr))
size_bytes=$((end_addr_dec - start_addr_dec + 1))
size_kb=$((size_bytes / 1024))
ranges+=("$start_addr-$end_addr")
sizes+=("$size_kb")
done < <(grep -i "System RAM" /proc/iomem)
for i in "${!ranges[@]}"; do
size_kb="${sizes[i]}";human_readable=$(hsize "$size_kb")
if (( size_kb >= 1024 )); then printf "Range: %s\t - Size: %dKb (%s)\n" "${ranges[i]}" "$size_kb" "$human_readable"
else printf "Range: %s\t - Size: %dKb\n" "${ranges[i]}" "$size_kb";fi
done
for i in "${!sizes[@]}"; do
if (( sizes[i] > maxtestable )); then maxtestable=${sizes[i]};maxrange=${ranges[i]};fi
done
echo "--------------------------------------------------------------"
echo "The largest memory range is: $maxrange with a size of ${maxtestable}Kb ($(hsize $maxtestable))"; echo
echo
echo "1. Test max testable RAM"
echo "2. Enter a size to test"
echo "3. Enter a starting physical address and size to test"
echo "q. Quit"
echo "-------------------"
read -p "Enter your choice: " choice
case "$choice" in
1)
echo "Testing max testable RAM..."
memtester "${maxtestable}K" 1
presskey
;;
2)
echo "Testing with a specified size..."
test_with_size;presskey
;;
3)
echo "Testing with a specified start address and size..."
test_with_address;presskey
;;
q|Q)
echo "Exiting..."
exit 0
;;
*)
echo "Invalid choice. Please enter 1, 2, 3, or q."
;;
esac
done
##[END_ramtest.sh]##
#▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
##[spleen-12x24.psfu.gz]##
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
##[END_spleen-12x24.psfu.gz]##
#▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
##[spleen-8x16.psfu.gz]##
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
u/n/9H9P/wXIa7vkxCgAAA==
##[END_spleen-8x16.psfu.gz]##

