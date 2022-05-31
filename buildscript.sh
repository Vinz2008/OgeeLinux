#!/bin/bash
echo "- Setting General parameters"
    archisoRequiredVersion="archiso 64-1"
    buildFolder=$HOME"/arcolinux-build"
	outFolder=$HOME"/ArcoLinux-Out"
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
	sudo sed -i "s/\(^archiso-version=\).*/\1$archisoVersion/" ../archiso.readme
	echo
	echo "Making mkarchiso verbose"
	sudo sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso
    echo "Deleting the build folder if one exists - takes some time"
	[ -d $buildFolder ] && sudo rm -rf $buildFolder
	echo
    mkdir $buildFolder
	cp -r ../archiso $buildFolder/archiso
