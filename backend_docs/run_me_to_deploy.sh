#!/bin/bash

git remote add backend_doc git@github.com:JI-DeepSleep/DocuSnap-Backend.git
mkdocs gh-deploy  --force --remote-branch gh-pages --remote-name backend_doc