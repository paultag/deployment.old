#!/usr/bin/env python3
import subprocess
import urllib.request
import json
import sys

NAMESPACE, REPO = sys.argv[1:]


LOCATION = ("https://index.docker.io/"
            "v1/repositories/{namespace}/{repo}/tags".format(
                namespace=NAMESPACE,
                repo=REPO,
            ))



info = json.loads(urllib.request.urlopen(LOCATION).read().decode('utf-8'))
tags = {x['layer'] for x in info}

curtags = {x.strip()[:8] for x in subprocess.check_output([
    "docker", "images", "-q", "{}/{}".format(NAMESPACE, REPO)
]).decode('utf-8').split("\n") if x}

if curtags == tags:
    print("No")
else:
    print("Yes")
