#!/bin/bash

git remote add frontend_doc git@github.com:JI-DeepSleep/DocuSnap-Frontend.git
mkdocs gh-deploy  --force --remote-branch gh-pages --remote-name frontend_doc