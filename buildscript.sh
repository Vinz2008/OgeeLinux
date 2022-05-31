#!/bin/bash
echo "- Setting General parameters"
    archisoRequiredVersion="archiso 64-1"
	dmDesktop="xfce"
    buildFolder=$HOME"/ogeeos-build"
	outFolder=$HOME"/ogeeos-Out"
    if [ "$archisoVersion" == "$archisoRequiredVersion" ]; then
		tput setaf 2
		echo "Archiso has the correct version. Continuing ..."
		tput sgr0
    else
	tput setaf 1
	echo "You need to install the correct version of Archiso"
	echo "Use 'sudo downgrade archiso' to do that"
	echo "or update your system"
	tput sgr0
	fi
    if pacman -Qi $package &> /dev/null; then

			echo "Archiso is already installed"

	else

		#checking which helper is installed
		if pacman -Qi yay &> /dev/null; then

			echo "Installing with yay"
			yay -S --noconfirm $package

		elif pacman -Qi trizen &> /dev/null; then
			echo "Installing with trizen"
			trizen -S --noconfirm --needed --noedit $package

		fi

		# Just checking if installation was successful
		if pacman -Qi $package &> /dev/null; then
			echo " "$package" has been installed"
		else

			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			echo "!!!!!!!!!  "$package" has NOT been installed"
			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			exit 1
		fi

	fi
    echo
	echo "Saving current archiso version to readme"
	sudo sed -i "s/\(^archiso-version=\).*/\1$archisoVersion/" ./archiso.readme
	echo
	echo "Making mkarchiso verbose"
	sudo sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso
    echo "Deleting the build folder if one exists - takes some time"
	[ -d $buildFolder ] && sudo umount $buildFolder/x86_64/airootfs/proc && sudo rm -rf $buildFolder
	echo
    mkdir $buildFolder
	cp -r ./archiso $buildFolder/archiso
	echo "Deleting any files in /etc/skel"
	sudo rm -rf $buildFolder/archiso/airootfs/etc/skel/.* 2> /dev/null
	echo

	echo "Getting the last version of bashrc in /etc/skel"
	echo
	wget https://raw.githubusercontent.com/arcolinux/arcolinux-root/master/etc/skel/.bashrc-latest -O $buildFolder/archiso/airootfs/etc/skel/.bashrc

	echo "Removing the old packages.x86_64 file from build folder"
	rm $buildFolder/archiso/packages.x86_64
	rm $buildFolder/archiso/packages-personal-repo.x86_64
	echo

	echo "Copying the new packages.x86_64 file to the build folder"
	cp -f ./archiso/packages.x86_64 $buildFolder/archiso/packages.x86_64
	echo
	
	oldname1='iso_name="ogeeos'
	newname1='iso_name="ogeeos'

	oldname2='iso_label="ogeeos'
	newname2='iso_label="ogeeos'

	oldname3='OgeeOS'
	newname3='OgeeOS'

	#hostname
	oldname4='OgeeOS'
	newname4='OgeeOS'

	#sddm.conf user-session
	oldname5='Session=xfce'
	newname5='Session='$dmDesktop

	echo "Changing all references"
	echo
	sed -i 's/'$oldname1'/'$newname1'/g' $buildFolder/archiso/profiledef.sh
	sed -i 's/'$oldname2'/'$newname2'/g' $buildFolder/archiso/profiledef.sh
	sed -i 's/'$oldname3'/'$newname3'/g' $buildFolder/archiso/airootfs/etc/dev-rel
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/airootfs/etc/hostname
	sed -i 's/'$oldname5'/'$newname5'/g' $buildFolder/archiso/airootfs/etc/sddm.conf


	echo "Adding time to /etc/dev-rel"
	date_build=$(date -d now)
	echo "Iso build on : "$date_build
	sudo sed -i "s/\(^ISO_BUILD=\).*/\1$date_build/" $buildFolder/archiso/airootfs/etc/dev-rel
	echo "Cleaning the cache from /var/cache/pacman/pkg/"
	yes | sudo pacman -Scc
	[ -d $outFolder ] || mkdir $outFolder
	cd $buildFolder/archiso/
	sudo mkarchiso -v -w $buildFolder -o $outFolder $buildFolder/archiso/
	echo "Deleting the build folder if one exists - takes some time"
	[ -d $buildFolder ] && sudo umount $buildFolder/x86_64/airootfs/proc && sudo rm -rf $buildFolder
	echo "- Check your out folder :"$outFolder
