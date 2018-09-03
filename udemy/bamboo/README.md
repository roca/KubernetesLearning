
***Checkout a subdirectory of a git repo***

*Example:* Pulling camera folder from GO repo

`
mkdir GO
cd GO
git init
git remote add -f origin https://github.com/roca/GO.git
git config core.sparseCheckout true
echo "camera" >> .git/info/spare-checkout
git pull origin staging
`