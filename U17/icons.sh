#!/bin/sh

CUR_DIR=
get_cur_dir() {
    # Get the fully qualified path to the script
    case $0 in
        /*)
            SCRIPT="$0"
            ;;
        *)
            PWD_DIR=$(pwd);
            SCRIPT="${PWD_DIR}/$0"
            ;;
    esac
    # Resolve the true real path without any sym links.
    CHANGED=true
    while [ "X$CHANGED" != "X" ]
    do
        # Change spaces to ":" so the tokens can be parsed.
        SAFESCRIPT=`echo $SCRIPT | sed -e 's; ;:;g'`
        # Get the real path to this script, resolving any symbolic links
        TOKENS=`echo $SAFESCRIPT | sed -e 's;/; ;g'`
        REALPATH=
        for C in $TOKENS; do
            # Change any ":" in the token back to a space.
            C=`echo $C | sed -e 's;:; ;g'`
            REALPATH="$REALPATH/$C"
            # If REALPATH is a sym link, resolve it.  Loop for nested links.
            while [ -h "$REALPATH" ] ; do
                LS="`ls -ld "$REALPATH"`"
                LINK="`expr "$LS" : '.*-> \(.*\)$'`"
                if expr "$LINK" : '/.*' > /dev/null; then
                    # LINK is absolute.
                    REALPATH="$LINK"
                else
                    # LINK is relative.
                    REALPATH="`dirname "$REALPATH"`""/$LINK"
                fi
            done
        done

        if [ "$REALPATH" = "$SCRIPT" ]
        then
            CHANGED=""
        else
            SCRIPT="$REALPATH"
        fi
    done
    # Change the current directory to the location of the script
    CUR_DIR=$(dirname "${REALPATH}")
}

get_cur_dir
AppIcon_DIR=$CUR_DIR/Assets.xcassets/AppIcon.appiconset

ls -alh $AppIcon_DIR/AppIcon20x20@2x-1.png


sips -z 1024 1024   $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon1024*1024.png 
sips -z 40 40       $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon20x20@2x-1.png
sips -z 60 60       $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon20x20@3x-1.png
sips -z 58 58       $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon29x29@2x-1.png
sips -z 87 87       $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon29x29@3x-1.png
sips -z 80 80       $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon40x40@2x.png
sips -z 120 120       $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon40x40@3x.png
sips -z 120 120       $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon60x60@2x-1.png
sips -z 180 180       $AppIcon_DIR/AppIcon1024*1024.png --out $AppIcon_DIR/AppIcon60x60@3x-1.png


