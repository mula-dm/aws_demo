#!/usr/bin/env python3
import sys
import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timedelta

# This check and everything above must remain compatible with Python 2.7.
if sys.version_info[0] < 3:
    sys.stderr.write("""
==========================
Unsupported Python version
==========================
This script requires Python 3, but you're trying to
install it on Python 2.
""")
    sys.exit(1)

# List all Resources in default region
# Usage
# list_all_in_default_region ()
def list_all_in_default_region ():
    try:
        client = boto3.client('resourcegroupstaggingapi')
        for resource in client.get_resources().get('ResourceTagMappingList'):
            print(resource.get('ResourceARN'))
    except ClientError as e:
        warning_message (f'Could not connect to region with error: {e}')

# List ec2 in default region
# Usage
# list_ec2 ()
def list_ec2 ():
    try:
        ec2 = boto3.resource('ec2')
        for instance in ec2.instances.all():
         print(
             "Id: {0}\nPlatform: {1}\nType: {2}\nPublic IPv4: {3}\nAMI: {4}\nState: {5}\n"
             .format(
                instance.id,
                instance.platform,
                instance.instance_type,
                instance.public_ip_address,
                instance.image.id,
                instance.state
             )
         )
    except ClientError as e:
        warning_message (f'Could not connect to region with error: {e}')

# List vpc in default region
# Usage
# list_vpc ()
def list_vpc ():
    try:
        ec2 = boto3.resource('ec2')
        for vpc in ec2.vpcs.all():
         print(
             "\n"
             "Id: {0}\nCidr: {1}\nIsDefault: {2}\nState: {3}\nAssociationSet: {4}\nDhcp: {5}\nTenancy: {6}"
             .format(
                vpc.id,
                vpc.cidr_block,
                vpc.is_default,
                vpc.state,
                vpc.cidr_block_association_set,
                vpc.dhcp_options_id,
                vpc.instance_tenancy
             )
         )
    except ClientError as e:
        warning_message (f'Could not connect to region with error: {e}')


# Print info message to stdout
# Usage
# info_message ("message")
def info_message (message):
    print (datetime.now(), "INFO:", message)


# Print warning message to stdout
# Usage
# warning_message ("message")
def warning_message (message):
    print (datetime.now(), "WARNING:", message)


def main():
    if "all" in sys.argv:
        info_message ("List ALL")
        list_all_in_default_region()
    elif "ec2" in sys.argv:
        info_message ("List EC2")
        list_ec2()
    elif "vpc" in sys.argv:
        info_message ("List VPC")
        list_vpc()
    else:
        info_message ("Nothing to list")


if __name__ == '__main__':
    main()
