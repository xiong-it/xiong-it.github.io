#!/bin/bash
hexo cl
hexo g
hexo d
cd public
pwd
echo 'push urls to baidu start...'
curl -H 'Content-Type:text/plain' --data-binary @baidu_urls.txt "http://data.zz.baidu.com/urls?site=blog.michaelx.tech&token=2ymhvQFYzqINEu0C"
echo 'push urls to baidu end.'
# echo $resultJson
cd ..
pwd
