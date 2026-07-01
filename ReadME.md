install rokit

rokit add rojo
rojo init
rokit add wally
wally init

wally install
rojo sourcemap default.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages