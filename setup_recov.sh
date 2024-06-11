#!/bin/bash
echo;echo;clti="     \e[1m\e[97m\e[44m";
sep="$clti===============================================\e[49m"
echo -e "$sep";echo -e "$clti=== 'Recovery tools' grub entries installer ===\e[49m"
echo -e "$sep\e[0m";echo "                                          By seb3773";echo
if [ ! "$EUID" -eq 0 ];then echo "           !! This script must be run as root.";echo;exit;fi
osarch=$(dpkg --print-architecture)
uuid=$(lsblk -o MOUNTPOINT,UUID | awk '$1 == "/" {print $2}')
current_locale=$(locale | grep LANG= | cut -d'=' -f2)
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
sizless=300;sizmc=1500;sizinxi=1500;sizduf=2200;sizncdu=120;sizdeborph=300;sizw3m=2900;sizlynis=1700;sizrmlint=400
appok(){ echo -e -n "\e[92m\e[4mOk\e[39m\e[0m";};notok(){ echo -e -n "\e[41m\e[97mX\e[49m\e[39m ";};siztoinst=0;lstapps=""
echo -e -n "  > checking 'less':  ";if [ -f /usr/bin/less ];then appok;else notok;appless=1;((siztoinst+=sizless));lstapps+="  less  ";fi
echo -e -n "      > checking 'mc' : ";if [ -f /bin/mc ];then appok;else notok;appmc=1;((siztoinst+=sizmc));lstapps+="  mc  ";fi;echo
echo -e -n "  > checking 'inxi':  ";if [ -f /usr/bin/inxi ];then appok;else notok;appinxi=1;((siztoinst+=sizinxi));lstapps+="  inxi  ";fi
echo -e -n "      > checking 'duf': ";if [ -f /usr/bin/duf ];then appok;else notok;appduf=1;((siztoinst+=sizduf));lstapps+="  duf  ";fi;echo
echo -e -n "  > checking 'ncdu':  ";if [ -f /usr/bin/ncdu ];then appok;else notok;appncdu=1;((siztoinst+=sizncdu));lstapps+="  ncdu  ";fi
echo -e -n "      > checking 'w3m': ";if [ -f /usr/bin/w3m ];then appok;else notok;appw3m=1;((siztoinst+=sizw3m));lstapps+="  w3m  ";fi;echo
echo -e -n "  > checking 'lynis': ";if [ -f /usr/sbin/lynis ];then appok;else notok;applynis=1;((siztoinst+=sizlynis));lstapps+="  lynis  ";fi
echo -e -n "      > checking 'deborphan': ";if [ -f /usr/bin/deborphan ];then appok;else notok;appdeborph=1;((siztoinst+=sizdeborph));lstapps+="  deborphan  ";fi;echo
echo -e -n "  > checking 'rmlint': ";if [ -f /usr/bin/rmlint ];then appok;else notok;apprmlint=1;((siztoinst+=sizrmlint));lstapps+="  rmlint  ";fi;echo
if [ -n "$lstapps" ]; then echo;echo -e " \e[4mThe following needed package(s) will be installed:\e[0m "
echo -e "\e[93m  $lstapps\e[39m";echo -e " this will use approximatively \e[4m$siztoinst K of disk space\e[0m.";fi
echo;echo -n -e " Proceed ? (\e[92my\e[39m/\e[91mn\e[39m) " && read x
if [ "$x" == "y" ] || [ "$x" == "Y" ];then
echo -e "  > do you want to install 'clonezilla live' entry too ?"
echo -e -n "    this will use ~ \e[4m430Mb of disk space\e[0m. (\e[92my\e[39m/\e[91mn\e[39m) " && read x
if [ "$x" == "y" ] || [ "$x" == "Y" ];then clonezi=1;else clonezi=0;fi
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
extract_script emergencymenu.sh "/root/recovtools"
extract_script rescuemenu.sh "/root/recovtools"
sudo chown root:root /root/recovtools/emergencymenu.sh
sudo chmod 700 /root/recovtools/emergencymenu.sh
sudo chown root:root /root/recovtools/rescuemenu.sh
sudo chmod 700 /root/recovtools/rescuemenu.sh
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
if ! ls /root/recovtools/clonezilla-live-3.1.2-22-*.iso 1> /dev/null 2>&1; then
echo;echo " # downloading clonezilla ISO..."
if [ "$osarch" = "amd64" ]; then
zillaiso="clonezilla-live-3.1.2-22-amd64.iso"
wget -q --show-progress https://deac-riga.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.1.2-22/$zillaiso
else zillaiso="clonezilla-live-3.1.2-22-i686.iso"
wget -q --show-progress https://deac-fra.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.1.2-22/$zillaiso;fi
echo;echo " # moving clonezilla ISO to /root/recovtools/"
mv -f $zillaiso /root/recovtools/;fi
fi
echo;echo " # Creating emergency & rescue system units overrides to /etc/systemd/system/"
echo;echo "   > Creating /etc/systemd/system/emergency.service";echo
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
echo;echo "   > Creating /etc/systemd/system/rescue.service";echo
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
echo;echo " # Creating /etc/grub.d/39_recoverytools"
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
if [[ $clonezi -eq 1 ]];then
echo 'menuentry "Clonezilla live" --class recovery {'
[ "$osarch" = "amd64" ] && echo 'rmmod tpm'
echo "search --no-floppy --fs-uuid --set $uuid"
echo 'insmod gzio'
echo 'if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi'
echo 'insmod part_gpt'
echo 'insmod ext2'
echo "set isofile=\"/root/recovtools/$zillaiso\""
echo 'loopback loop $isofile'
echo "linux (loop)/live/vmlinuz nomodeset boot=live live-config edd=on ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" keyboard-layouts=\"$keyboard_layout\" ocs_live_batch=\"no\" locales=\"$current_locale\" ip=frommedia toram=filesystem.squashfs findiso=\$isofile"
echo 'initrd (loop)/live/initrd.img'
echo '}'
fi
echo '}'
} > "/etc/grub.d/39_recoverytools"
chmod +x "/etc/grub.d/39_recoverytools"
echo " # reloading systemd daemons..."
systemctl daemon-reload
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
phymem=$(LANG=C free|awk '/^Mem:/{printf ("%.2f\n",$2/(1024*1024))}')
dskfree=$(df -k / | tail -1 | awk '{print int($4/(1024*1024))}')
osarch=$(dpkg --print-architecture)
ckern=$(uname -r)
partitions=$(lsblk -o NAME,FSTYPE -nr)
ntfs_partitions=$(echo "$partitions" | grep -w ntfs)
if [ -z "$ntfs_partitions" ]; then ntfsdisk=0;else ntfsdisk=1;fi
loadkeys /root/recovtools/recovmenu.keymap
setfont /root/recovtools/spleen-12x24.psfu.gz
while true; do
dskfree=$(df -k / | tail -1 | awk '{print int($4/(1024*1024))}')
MENU_OPTIONS=(
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
  "testdisk" "  ─   launch testdisk"
  "photorec" "  ─   launch photorec"
  "shell" "  ═   root shell prompt"
  "rescue mode" "  »   go to rescue mode"
  "reboot" "  ×   reboot system now"
)
CHOICE=$(whiptail --title "  Emergency Menu ~ $HOSTNAME ~ $osarch  " --menu "\n■ Ram: $phymem Gb   ■ Disk free: $dskfree Gb\n■ Current kernel: $ckern\n≡ $(date '+%A %d %B %Y')\n\n► Choose an option:" 28 60 14 \
"${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)
case $CHOICE in
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
echo;echo "> now you can choose to run the rmlint script to strip binaries, or you can edit it before (or skip this part)"
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
dskfree=$(df -k / | tail -1 | awk '{print int($4/(1024*1024))}')
phymem=$(LANG=C free|awk '/^Mem:/{printf ("%.2f\n",$2/(1024*1024))}')
osarch=$(dpkg --print-architecture)
ckern=$(uname -r)
partitions=$(lsblk -o NAME,FSTYPE -nr)
ntfs_partitions=$(echo "$partitions" | grep -w ntfs)
if [ -z "$ntfs_partitions" ]; then ntfsdisk=0;else ntfsdisk=1;fi
netwstat="Network: not connected"
loadkeys /root/recovtools/recovmenu.keymap
setfont /root/recovtools/spleen-12x24.psfu.gz
echo "Launching NetworkManager..";sleep 1
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
  "nmtui" "  ─   launch network config tool"
  "w3m" "  ─   terminal web browser"
  "lynis" "  ─   system audit"
  "testdisk" "  ─   launch testdisk"
  "photorec" "  ─   launch photorec"
  "shell" "  ═   shell prompt"
  "reboot" "  ×   reboot system now"
)
CHOICE=$(whiptail --title "  Rescue Menu ~ $HOSTNAME ~ $osarch  " --menu "\n■ Ram:$phymem Gb   ■ Disk free: $dskfree Gb\n■ Current kernel: $ckern\n≡ $(date '+%A %d %B %Y')   ≡ $netwstat\n► Choose an option:" 34 70 22 \
"${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)
case $CHOICE in
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
echo "$(echo;echo ">  Displaying system summary:";echo -e "(if output is larger than the screen height, use \e[4mup & down arrow to scroll\e[0m - \e[4m'q' to quit\e[0m)";echo;inxi -Fxz -c 11)" | less -R
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
echo;echo "> now you can choose to run the rmlint script to strip binaries, or you can edit it before (or skip this part)"
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
lynis audit system | less -R
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
##[spleen-12x24.psfu.gz]##
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
##[END_spleen-12x24.psfu.gz]##
#▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

