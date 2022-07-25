# Data-Check-Sum-Scripts
Used to generate checksums of files within a directory. Can be added to cron, or task scheduler.


Bash/Linux 
_____________________________________________________________
Save the file "generateSHA256Dir.sh" and setup a cron job to automatically execute the periodically

    sudo crontab -l > cron_bkp
    sudo echo "0 22 * * * sudo /changmepath/generateSHA256Dir.sh >/dev/null 2>&1" >> cron_bkp
    sudo crontab cron_bkp
    sudo rm cron_bkp


Windows
____________________________________________________________
Save the "generateSHA256Dir.ps1" and add a task scheduler job to execute the powershell script.
