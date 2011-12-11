#!/bin/sh
# http://hints.macworld.com/article.php?story=20011108211802830
#
####################################
# iTunes Command Line Control v1.0
# written by David Schlosnagle
# created 2001.11.08
# adapted by Riccardo Carlesso
####################################
VER="1.1"

usage () {
    echo "------------------------------------";
    echo "iTunes Command Line Interface (v$VER)";
    echo "------------------------------------";
    echo "Usage: `basename $0` <option>";
    echo;
    echo "Options:";
    echo " [m]ute     = Mute iTunes' volume.";
    echo " [n]ext     = Go to the next track.";
    echo " noshuf   = Do not shuffle current playlist";
    echo " [p]ause    = Pause iTunes.";
    echo " pl[a]y     = Start playing iTunes.";
    echo " [pl]aylist = Show playlists saved in iTunes.";
    echo " prev     = Go to the previous track.";
    echo " [q]uit     = Quit iTunes.";
    echo " shuf     = Shuffle current playlist"; 
    echo " [st]atus   = Shows iTunes' status, current artist and track.";
    echo " stop     = Stop iTunes.";
    echo " [u]nmute   = Unmute iTunes' volume.";
    echo " [v]ol <NN> = Set iTunes' volume to NN [0-100]";
    echo " [v]ol down = Increase iTunes' volume by 10%";
    echo " [v]ol up   = Increase iTunes' volume by 10%";
}

if [ $# = 0 ]; then
    usage;
fi

while [ $# -gt 0 ]; do
    arg=$1;
    case $arg in
        st|"status" ) state=`osascript -e 'tell application "iTunes" to player state as string'`;
            echo "iTunes is currently $state.";
            if [ $state = "playing" ]; then
                artist=`osascript -e 'tell application "iTunes" to artist of current track as string'`;
                track=`osascript -e 'tell application "iTunes" to name of current track as string'`;
                echo "Current track $artist:  $track";
            fi
            break ;;

        a|"play"    ) echo "Playing iTunes.";
            osascript -e 'tell application "iTunes" to play';
            break ;;

        p|"pause"    ) echo "Pausing iTunes.";
            osascript -e 'tell application "iTunes" to pause';
            break ;;

        n|"next"    ) echo "Going to next track." ;
            osascript -e 'tell application "iTunes" to next track';
            break ;;

        "prev"    ) echo "Going to previous track.";
            osascript -e 'tell application "iTunes" to previous track';
            break ;;

        m|"mute"    ) echo "Muting iTunes volume level.";
            osascript -e 'tell application "iTunes" to set mute to true';
            break ;;

        u|"unmute" ) echo "Unmuting iTunes volume level.";
            osascript -e 'tell application "iTunes" to set mute to false';
            break ;;

        v|"vol"    ) echo "Changing iTunes volume level.";
            vol=`osascript -e 'tell application "iTunes" to sound volume as integer'`;
            if [ "$2" = '' ]; then
              usage
              break 
            fi
            if [ $2 = "up" ]; then
                newvol=$(( vol+10 ));
             else if [ $2 = "down" ]; then
                newvol=$(( vol-10 ));
              else if [ $2 -gt 0 ]; then
                newvol=$2;
              fi
             fi
            fi
            #if [ $2 = "down" ]; then
            #    newvol=$(( vol-10 ));
            #fi

            #if [ $2 -gt 0 ]; then
            #    newvol=$2;
            #fi
            osascript -e "tell application \"iTunes\" to set sound volume to $newvol";
            break ;;

        "stop"    ) echo "Stopping iTunes.";
            osascript -e 'tell application "iTunes" to stop';
            break ;;
            
        q|"quit" ) echo "Quitting iTunes.";
            osascript -e 'tell application "iTunes" to quit';
            exit 1 ;;
            
            #And the code for showing available playlists, if there is no parameter given.
            
            ## addition playlist of choice
        "pl"|"playlist" )
            if [ -n "$2" ]; then
              echo "Changing iTunes playlists to '$2'.";
              osascript -e 'tell application "iTunes"' -e "set new_playlist to \"$2\" as string" -e "play playlist new_playlist" -e "end tell"; 
              break ;
            else
              # Show available iTunes playlists.
              echo "Playlists:";
              osascript -e 'tell application "iTunes"' -e "set allPlaylists to (get name of every playlist)" -e "end tell";
              break;
            fi
            break;;

         "shuf" ) echo "Shuffle is ON."; 
           osascript -e 'tell application "iTunes" to set shuffle of current playlist to 1'; 
           break ;;
         
         "noshuf" ) echo "Shuffle is OFF."; 
           osascript -e 'tell application "iTunes" to set shuffle of current playlist to 0'; 
           break ;;

        "help" | * ) echo "help:";
            usage;
            break ;;
    esac
done
