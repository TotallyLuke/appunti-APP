for line in $(find imgs/ -iname '*.svg'); do 
	inkscape --without-gui $line -o `echo $line | sed -e 's/svg$/png/'`
done

