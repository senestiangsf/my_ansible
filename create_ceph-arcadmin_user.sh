#!/bin/bash

ansible haproxy -m user -a "name=ceph-arcadmin password={{ 'redhat123' | password_hash('sha512') }} state=present" -u root -k

ansible haproxy -m authorized_key -a "user=ceph-arcadmin key={{ lookup('file', '/home/ceph-arcadmin/.ssh/id_rsa.pub') }} state=present" -u root -k

ansible haproxy -m copy -a "content='ceph-arcadmin ALL=(root) NOPASSWD: ALL' dest=/etc/sudoers.d/ceph-arcadmin" -u root -k
