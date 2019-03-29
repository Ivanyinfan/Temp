git init
git config core.autocrlf false
git clone git@github.com:Ivanyinfan/Temp.git
git remote add origin git@github.com:Ivanyinfan/Temp
git branch --set-upstream-to=origin/master master
git branch --set-upstream-to=origin/Python Python
git branch Python
git checkout Python
git rebase master
git fetch
git pull --allow-unrelated-histories
git status
git add --update
git reset
git commit -m
git push -f