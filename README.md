# Installation Displacement

Also Known as: VHDXFolders, Virtual Disk - Application Installation Compartmentalization
Features as seen in OneDrive Personal Vault and other symbolic link applications.

Please Note, this process does NOT include the ability to bit-locker or encrypt the Virtual Drives.

> ! USE AT YOUR OWN RISK. !

> IMPORTANT | WARNING
>> Windows and the Windows Virtual Disk Service have safeguards but this doesn't limit the possibility of corruption or data loss.
>> Test on no-risk systems and folders PRIOR to executing this module or any scripts contained within.

> YOU HAVE BEEN WARNED.

> I nor github nor microsoft accept responsibility for any damage or data loss.

> In may cases the mounting and assigning process can be undone with a full system restart (reboot) but this hasn't been proven to be true or false. Use at your own risk. Understand the scripts BEFORE you run them. You should understand how to manually undo the processes discussed prior to execution.

> A GREAT place to start is ~/Mount/Method Script Test/ Folder as it contains a test for all scripts within the module.

## Project Description

This project starts as a functionless script (meaning you have to edit the script to get it to work with your specific parameters)

The purpose of this script is to generate a VHDX File and mount the VHDX Drive in place of the selected folder and copy the contents (if any) to the new Folder Mounted Drive that can be on the main Drive or secondary drive.

Included with this project is an example of the scheduled tasks for mounting these drives at system startup/ user loggon or can allow the user to mount the drive at any time by double clicking the file.

Powershell scripts and design for using VHDX Files backing folders for moving data off a performance based HD such as an SSD. This method will allow you to download and store all files logically in the same folder structure but have the actual data residing on different hard drives. you can move the files around to different hard drives when performance considerations are required.

## Script Source Store Structure

I've split the contents of this module into standard pieces Classes, Method (Powershell Functions), Module Variables, Types (Strong Powershell Types)
|Name / Type| Description |
|:----|----|
|Classes|Custom Classes designed to facilitate the transformation of a single folder, rename, create VHDX Drive of default or specified Size, Mounting of the created drive, Formatting, and Manage the move of data from the folder to the new drive. > (It was chosen to move the collection of method calls to a class that was best suited for collection and validation prior to starting the execution of the process.)|
|Methods|Individual Methods of the given process called by the classes|
|Module Variables|objects that hold defaults that can be loaded from profile configuration files or altered prior to the execution of the command or set at runtime.|
|Types|Other Object types that did not fit within the classes or are shared across classes and methods.|

All parts can be found within these folders and ones that are used are listed in the "~/src/MasterScript.ps1"
The Script "Test-MasterFunctionList.ps1" will ensure that once the master script is run in a clean profileless window that the parts expected to be loaded will be infact available.

## Known Issues

1. Drive mounts to folder WITHOUT using the Disk Management tool in windows has not been tested and may not work as expected.
    * To avoid this issue, Always use the Disk Management tool to mount the drive to the folder FIRST (First mount should be with the disk mounting tool)
1. Drive Sizes can exceed physical storage of storage disk's, it has not been tested using Fixed Size or Physical Disks in place of the VHDX. 
    * Though theory suggests (Virtual Disks) if you can reference the drive within the disk management tool for mounting, you can do the same when mounting via the script.
    * Physical disks are capable of being mounted in a similar way but the scripts do not account for this process. These scripts focus solely on the Virtual Hard Disk (VHD|VHDX). Thus Physical Disk Mounting is out of scope for this module at this time.
1. This scirpt does not have a fall back failure point. meaning if it runs and fails you will need to manually undo the things it did up until the failure.
    * !!!! IMPORTANT !!! : In other words, understand how to undo what the scripts are doing when testing.  In may cases the mounting and assigning process can be undone with a restart but this hasn't been proven to be true or false. Use at your own risk 

## Project Outline : Defined in a Gist
[Project Definition - Gist](https://gist.github.com/skyhoshi/dab7d6d3812428dbf5bb652c6c00b965)
