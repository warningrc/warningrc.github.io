#!/bin/bash
rm -rf ./_site

jekyll build

rsync -artvz --delete ./_site/ aliyun:/data/webroot/blog/
