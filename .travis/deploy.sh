#!/bin/bash
scp -o StrictHostKeyChecking=no -i "~/.ssh/id_rsa" -r public/. hugo@47.91.224.140:pages/