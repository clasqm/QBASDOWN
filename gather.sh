#!/bin/bash
cd /home/michel/Dropbox/Debian/git/QBASDOWN
read -p "Version? " version
mkdir -p ./binaries/$version
mkdir -p ./src/$version
cp -f "/home/michel/.dosemu/drive_c/FDOS/DEVEL/QB45/PROGRAMS/qbasdown.bas" ./src/$version
fbc -lang qb -x ./tmp/qbasdown "/home/michel/Dropbox/DOS Data/MS_QB/QB45/qbasdown.bas"
cp -f  ./tmp/qbasdown /home/michel/Dropbox/bin/
mv -f /home/michel/.dosemu/drive_c/FDOS/DEVEL/QB45/qbasdown.exe ./tmp
cd ./tmp
zip -9 qbasdown_lnx_x86_64_$version.zip qbasdown
zip -9 qbasdown_dos_$version.zip qbasdown.exe
mv *.zip ../binaries/$version
rm *
cd ..
rm -f /home/michel/.dosemu/drive_c/FDOS/DEVEL/QB45/qbasdown.obj
cp -f /home/michel/.dosemu/drive_c/FDOS/DEVEL/QB45/test.md .
cp -f /home/michel/.dosemu/drive_c/FDOS/DEVEL/QB45/incl.txt .
touch ./CHANGES
echo "Version $version" >> ./CHANGES
echo $(date)  >> ./CHANGES
tilde ./CHANGES 
tilde ./README.md
