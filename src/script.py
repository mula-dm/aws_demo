#!/usr/bin/env python3
import sys
import boto3
from pprint import pprint
from botocore.exceptions import ClientError

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

client = boto3.client('resourcegroupstaggingapi', )
regions = boto3.session.Session().get_available_regions('ec2')

def list_all ():
    for region in regions:
        print(region)
        try:
            client = boto3.client('resourcegroupstaggingapi', region_name=region)
            pprint([x.get('ResourceARN') for x in client.get_resources().get('ResourceTagMappingList')])
        except ClientError as e:
            print(f'Could not connect to region with error: {e}')
        print()


def list_by_region ():
    for region in regions:
        print(region)
    region = input ("Enter a region: ")
    print ("You entered: ", region)
    try:
        client = boto3.client('resourcegroupstaggingapi', region_name=region)
        pprint([x.get('ResourceARN') for x in client.get_resources().get('ResourceTagMappingList')])
    except ClientError as e:
        print(f'Could not connect to region with error: {e}')
    print()


def main():
    list_all()

if __name__ == '__main__':
    main()

