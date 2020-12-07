#!/bin/bash
set -e


sudo -E yum remove intel-hpckit intel-basekit


tee > /tmp/oneAPI.repo << EOF
[oneAPI]
name=Intel(R) oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB
EOF

sudo mv /tmp/oneAPI.repo /etc/yum.repos.d

sudo yum install intel-basekit

sudo -E yum --disablerepo="*" --enablerepo="oneAPI" list available

echo "Done."


