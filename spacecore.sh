#!/bin/bash
# Author: Nicolas Pielawski
# Creation date: May 13 2016
sv_user="ubuntu"
sv_path="/home/$sv_user/"
sv_key="/home/nicolas/.ssh/MachineLearningKey.pem"
sv_id="i-00000000"

# Is there an argument ?
if [ $# -eq 0 -o "$1" == "help" ]
then
    echo "What would you like to do, sir ?"
    echo "* start: start the instance"
    echo "* stop: stop the instance"
    echo "* run: send and run a python file"
    echo "* send: send a file to the server"
    echo "* send: get a file from the server"
    echo "* status: get the status of the server"
    echo "* ip: get the IP of the server"
    echo "* ssh: start a SSH client"
    echo "* help: print this help"
    exit
fi

case "$1" in
    "start")
        # Starting server
        /opt/spacecore/aws_instance.py start $sv_id
        echo "Done."
        ;;
    "stop")
        # Stopping server
        /opt/spacecore/aws_instance.py stop $sv_id
        echo "Done."
        ;;
    "run")
        if [ -z $2 ]
        then
            echo "You must give the script to compute"
            exit
        elif [ ! -e $2 ]
        then
            echo "File $2 doesn't exist (check your rights, too)"
            exit
        fi
        if [ $(/opt/spacecore/aws_instance.py status $sv_id) != "running" ]
        then
            echo "Server is not running yet!"
            exit
        fi
        sv_address=$(/opt/spacecore/aws_instance.py ip $sv_id)
        echo "Sending file $2 to server ($sv_address)..."
        scp -i $sv_key $2 $sv_user@$sv_address:$sv_path$(basename $2)
        ssh -i $sv_key -t $sv_user@$sv_address "sudo -i python3 $sv_path$(basename $2)"
        ;;
    "send")
        if [ -z $2 ]
        then
            echo "You must give the file to send"
            exit
        elif [ ! -e $2 ]
        then
            echo "File $2 doesn't exist (check your rights, too)"
            exit
        fi
        if [ $(/opt/spacecore/aws_instance.py status $sv_id) != "running" ]
        then
            echo "Server is not running yet!"
            exit
        fi
        sv_address=$(/opt/spacecore/aws_instance.py ip $sv_id)
        echo "Sending file $2 to server ($sv_address)..."
        scp -i $sv_key $2 $sv_user@$sv_address:$sv_path$(basename $2)
        ;;
    "get")
        if [ -z $2 ]
        then
            echo "You must name the file to download"
            exit
        fi
        if [ $(/opt/spacecore/aws_instance.py status $sv_id) != "running" ]
        then
            echo "Server is not running yet!"
            exit
        fi
        sv_address=$(/opt/spacecore/aws_instance.py ip $sv_id)
        echo "Downloading file $2 from server ($sv_address)..."
        scp -i $sv_key $sv_user@$sv_address:$sv_path/$2 .
        ;;
    "status")
        /opt/spacecore/aws_instance.py status $sv_id
        ;;
    "ip")
        /opt/spacecore/aws_instance.py ip $sv_id
        ;;
    "ssh")
        if [ $(/opt/spacecore/aws_instance.py status $sv_id) != "running" ]
        then
            echo "Server is not running yet!"
            exit
        fi
        sv_address=$(/opt/spacecore/aws_instance.py ip $sv_id)
        echo "Trying to connect to $sv_address..."
        ssh -i $sv_key -t $sv_user@$sv_address
        ;;
    "help")
        ;;
    *)
        echo "Invalid argument"
        ;;
esac
