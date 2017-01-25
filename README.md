# SpaceCore

Spacecore is a script allowing to start, stop and execute script on a
aws instance of amazon.

## Dependencies
You will need to install the aws command line (http://docs.aws.amazon.com/cli/latest/userguide/installing.html) and boto3 python lib:
```
sudo pip3 install boto3
```

## Installation
Copy the folder spacecore in /opt and add the following line to your .bashrc
```
alias spacecore=/opt/spacecore/spacecore.sh
```
Also, don't forget to save your aws credentials for the api with
```
aws configure
```
Now, you will have to create an aws instance (g2.2xlarge for instance), and there
is no need to associate an IP address, the script will create an elastic IP and
destroy it when you shutdown the instance. Also, write down the Instance ID.

The final step is to configure the spacecore.sh file. There are several variables
that you can configure:
* _sv_user_ User name of the aws instance
* _sv_path_ Path to the workspace of the script
* _sv_key_ Link to the key file (extension .pem)
* _sv_id_ Instance ID that you just wrote down

## Usage
### Starting the instance
```
spacecore start
```
Starts the server, create the elastic IP and associate it.

Takes some time, no worries ;)

### Stopping the instance
```
spacecore stop
```
Stops the server and deletes the elastic IP so you don't have to pay for it.

### Sending a file
```
spacecore send <file>
```
Uploads a file in the workspace.

### Downloading a file
```
spacecore get <file>
```
Download a file from the workspace.

### Running a script
```
spacecore run <script.py>
```
Uploads a python script and executes it with the command:
```
sudo -i python3 <script.py>
```
If you are unsatisfied with this command you can edit it in the spacecore.sh file.
The sudo part of the command allows the script to use cuda on the instance.

### Getting the IP address
```
spacecore ip
```
Returns the IP address only. If you program anything related to the instance,
you should use this command as the IP is going to change at every restart.

For example (ping):
```
ping $(spacecore ip)
```

### Getting the status of the instance
```
spacecore status
```
Returns the current status of the instance.
The output is only one word, so this can be easily used in other scripts.

### Starting a SSH session
```
spacecore ssh
```
Starts a SSH session directly in the terminal.
