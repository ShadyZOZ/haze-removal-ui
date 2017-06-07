rm -rf dist
rm -rf ../haze-removal/dist
yarn run build
mv index_prod.html ../haze-removal/templates/advanced.html
mv dist ../haze-removal
