#!/bin/bash
docker build -t myapp .
docker run -d -p 80:80 myapp
