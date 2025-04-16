#!/bin/bash
scp -r * user@yourserver:/path/to/deploy/
ssh user@yourserver 'cd /path/to/deploy && ./start.sh'
