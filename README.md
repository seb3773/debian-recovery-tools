# debian-recovery-tools
recovery tools selectable in grub menu to repair a broken debian install
  
This script will install a "recovery tools" entry in your grub menu; where you can select an emergency menu (run at systemd emergency target) or a rescue menu (run at systemd rescue target) with multiple tools to repair a broken debian install (or other use scenarios). You will have the option to run an instance of clonezilla live too if you want.
  
"Emergency target" is, to make simple, a minimal root shell mode, whithout base services. This mode allows you to perform operations like fsck the root partition for example; and other let's say "low level" operations because very few processes are launched at this stage (that's why it's the 'emergency' target, it have more chances to work even if the system is partially damaged).
If the emergency mode don't boot properly, then you will have no choice but to use an external device to boot an os live in order to do repairs...
  
"Rescue target" is a more "advanced" runlevel, with base services, which allow internet connection and usb storage mounting for example.So it can be usefull to backup some things on an external storage in case of problem, you can even install packages with apt, repair apt or access the web with the w3m terminal browser. Of course this mode is more "sensible" to damages, so there may be cases where only the emergency mode will work.  
  
The aim of all this is to be able to repair things more easily if, for example, the desktop cannot start or you can't log with your account; so you can track the errors and correct them, or manage users from the root account.  
  
![Alt text](/recovtools.png?raw=true "recov tools")
  
To install these grub entries & related scripts, simply download the attached script, set it executable :  

sudo chmod +x setup_recov.sh  
and launch it in root:  
sudo ./setup_recov.sh  
  
The script will take care of installing the recovery menus, and allow you to add 'Clonezilla live' entry too (and will download the iso if needed). It will try to install some packages (w3m, inxi, ncdu, mc etc...) which are needed for all the menu functions to be available (and are very usefull at my opinion, not only for these recovery menus).  
** You can optionnaly setup a password too for the menus as it will give you full root access without asking for password by default, which can be ok if you're the single user of a computer, but not at all if it's a shared computer. (this can be done in grub config too, but it's a bit tricky/risky, that's why I added this feature). The reason behind this, is that sulogin doesn't seem to allow to launch a specific script, so I had to 'bypass' it when a recovery menu is selected; this is done with this modification of emergency.service unit for example (same trick used for rescue.service):  
  
ExecStart=-/bin/sh -c 'grep -q "recovtools" /proc/cmdline && exec /root/recovtools/emergencymenu.sh || exec /lib/systemd/systemd-sulogin-shell emergency'  
As you can see the kernel command line is checked for the string "recovtools" (which is present for the recovery tools grub entries) and if found, the emergencymenu script is launched.

Don't hesitate to tell me if it's usefull for you, and please report any issues/suggestions ;)


