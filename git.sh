#! /bin/bash

git add -- . ':!job-outs' ':!bash' ':!plotly'
git commit -m 'new commit'
git push

