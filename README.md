# SpaceCore

Spacecore is a script allowing to start, stop and execute script on a
aws instance of amazon.

# Example
```
$ spacecore start
Starting Server...OK!
[-] Current server state: running
Allocating IP Address...OK! (ip: 42.42.42.42)
Associating server to ip...OK!
Done.

$ spacecore run keras-mnist-gpu.py
Sending file keras-mnist-gpu.py to server (42.42.42.42)...
The authenticity of host '42.42.42.42 (42.42.42.42)' can't be established.
ECDSA key fingerprint is SHA256:______________________________.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '42.42.42.42' (ECDSA) to the list of known hosts.
keras-mnist-gpu.py                                                     100% 2073    65.3KB/s   00:00    
Using TensorFlow backend.
I tensorflow/stream_executor/dso_loader.cc:128] successfully opened CUDA library libcublas.so locally
I tensorflow/stream_executor/dso_loader.cc:128] successfully opened CUDA library libcudnn.so locally
I tensorflow/stream_executor/dso_loader.cc:128] successfully opened CUDA library libcufft.so locally
I tensorflow/stream_executor/dso_loader.cc:128] successfully opened CUDA library libcuda.so.1 locally
I tensorflow/stream_executor/dso_loader.cc:128] successfully opened CUDA library libcurand.so locally
...

$ spacecore stop
Stopping Server...OK!
Disassociating server from ip...OK!
Releasing IP Address...OK!
Done.
```

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

The final step is to configure the spacecore.cfg file. First, you will need to
copy or rename spacecore.cfg.default into spacecore.cfg. There are several
variables that you can configure:
* _sv_user_ User name of the aws instance
* _sv_path_ Path to the workspace of the script
* _sv_key_ Link to the key file (extension .pem)
* _sv_id_ Instance ID that you just wrote down

It is done, have fun!

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
