#!/bin/sh

set -e
. ./env.sh

## Only make sense for dev 
make js_map.ml js_fold.ml lam_map.ml lam_fold.ml >> build.compile
## Disable it when make a release 

ocamlbuild  -no-hygiene -cflags -g,-w,-40-30,-warn-error,+a-40-30,-keep-locs,-I,+compiler-libs  compiler.cmxa > build.compile

make -r bin/ocamlscript
# TODO: this quick test is buggy, 
# since a.ml maybe depend on another module 
# we can not just comment it, it will also produce jslambda

# echo "LINKING FINISHED\n" >> build.compile
# make -S  -j1 quicktest 2>> build.compile
# cat stdlib/a.js >> ./build.compile

echo "Making runtime" >> build.compile

cd ./runtime; gmake all 2>> ../build.compile ; gmake depend;  cd ..
echo "Making runtime Finished" >> build.compile

echo "Remaking standard library" >> build.compile
cd ./stdlib; ./build.sh ; cd ../
echo "Remaking standard library Finished" >> build.compile


TARGET=a

# Building files in stdlib
echo ">>EACH FILE TESTING" >> build.compile
cd ./test/
# ./build.sh 2>> ../build.compile
gmake $TARGET.cmo 2>> ../build.compile

cat $TARGET.js >> ../build.compile
gmake -j30 all 2>>../build.compile
gmake depend 2>>../build.compile
echo "<<Test finished" >> ../build.compile
cd ..


