#!/usr/bin/env python3
# Author: Nicolas Pielawski
# Creation date: May 13 2016
import boto3
import json
import sys
import time

client = boto3.client('ec2')
ec2 = boto3.resource('ec2')


def allocate_elastic_ip():
    result = client.allocate_address()
    return (result["PublicIp"], result["AllocationId"])


def associate_elastic_ip(serverid, ip):
    return client.associate_address(InstanceId=serverid, PublicIp=ip)


def disassociate_elastic_ip(ip):
    return client.disassociate_address(PublicIp=ip)


def release_elastic_ip(ip):
    result = client.describe_addresses(PublicIps=[ip])
    alloc_id = result["Addresses"][0]["AllocationId"]
    return client.release_address(AllocationId=alloc_id)


def server_status(server_id):
    result = client.describe_instances(InstanceIds=[server_id])
    if len(result["Reservations"]) == 0:
        return "N/A"
    return result["Reservations"][0]["Instances"][0]["State"]["Name"]


def server_ip(server_id):
    result = client.describe_instances(InstanceIds=[server_id])
    if len(result["Reservations"]) == 0:
        return "N/A"
    if "PublicIpAddress" in result["Reservations"][0]["Instances"][0]:
        return result["Reservations"][0]["Instances"][0]["PublicIpAddress"]
    else:
        return "N/A"


def wait_for_state(waited_state, time_to_wait=1):
    spin = 0
    spins = "-\|/"
    state = server_status(server_id)
    print("[{}] Current server state: {}" % (spins[spin], state), end='\r')
    spin += 1
    while state != waited_state:
        time.sleep(time_to_wait)
        state = server_status(server_id)
        print("[{}] Current server state: {}" % (spins[spin], state), end='\r')
        spin = (spin + 1) % len(spins)
    print()


def server_start(server_id):
    if server_status(server_id) == "stopping":
        print("The server is still stopping! Waiting...")
        wait_for_state("stopped")

    print("Starting Server...", end="")
    client.start_instances(InstanceIds=[server_id])
    print("OK!")

    wait_for_state("running")

    print("Allocating IP Address...", end="")
    (ip, alloc_id) = allocate_elastic_ip()
    print("OK! (ip: " + ip + ")")

    print("Associating server to ip...", end="")
    associate_elastic_ip(server_id, ip)
    print("OK!")

    return (ip, alloc_id)


def server_stop(server_id):
    ip = server_ip(server_id)

    print("Stopping Server...", end="")
    client.stop_instances(InstanceIds=[server_id])
    print("OK!")

    if ip == "N/A":
        print("No IP address associated!")
        return

    print("Disassociating server from ip...", end="")
    disassociate_elastic_ip(ip)
    print("OK!")

    print("Releasing IP Address...", end="")
    release_elastic_ip(ip)
    print("OK!")


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("You have to specify the client-id and"
              "action to perform (start/stop)")
    else:
        action = sys.argv[1]
        server_id = sys.argv[2]
        if action == "start":
            server_start(server_id)
        elif action == "stop":
            server_stop(server_id)
        elif action == "status":
            print(server_status(server_id))
        elif action == "ip":
            print(server_ip(server_id))
        else:
            print("Unknown action...")
