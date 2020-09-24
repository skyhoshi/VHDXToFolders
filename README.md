# VHDXFolders

Also Known as: Installation Displayment, Virtual Disk - Application Installation Compartmentalization

## Project Description

This project starts as a functionless script (meaning you have to edit the script to get it to work with your specific parameters)

The purpose of this script is to generate a VHDX File and mount the VHDX Drive in place of the selected folder and copy the contents (if any) to the new Folder Mounted Drive that can be on the main Drive or secondary drive.

Included with this project is an example of the scheduled tasks for mounting these drives at system startup/ user loggon or can allow the user to mount the drive at any time by double clicking the file.

Powershell scripts and design for using VHDX Files backing folders for moving data off a performance based HD such as an SSD. This method will allow you to download and store all files logically in the same folder structure but have the actual data residing on different hard drives. you can move the files around to different hard drives when performance considerations are required.

## Known Issues

1. Drive mounts to folder WITHOUT using the Disk Management tool in windows has not been tested and may not work as expected.
    * To avoid this issue, Always use the Disk Management tool to mount the drive to the folder FIRST (First mount should be with the disk mounting tool)
1. Drive Sizes can exceed physical storage of storage disk's, it has not been tested using Fixed Size or Physical Disks in place of the VHDX. Though theory suggests (Virtual Disks, not including physical disks) if you can reference the drive within the disk management tool for mounting, you can do the same when mounting via the script.
1. This scirpt does not have a fall back failure point. meaning if it runs and fails you will need to manually undo the things it did up until the faiure.

## Project Outline : Defined in a Gist
[Project Definition - Gist](https://gist.github.com/skyhoshi/dab7d6d3812428dbf5bb652c6c00b965)
