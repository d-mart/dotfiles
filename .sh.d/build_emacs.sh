#!/bin/bash
# Pull from emacs repo and build

# pre-reqs (debian)
# libxpm-dev libjpeg-dev libtiff-dev libgnutls-dev

# run at low priority
renice 11 -p $$

SRC_PATH="${1:-$(pwd)}"

pushd $SRC_PATH
git reset --hard                                  &&\
git checkout master                               &&\
git pull                                          &&\
./autogen.sh                                      &&\
#./configure --without-makeinfo --with-x-toolkit=no --with-gif=no &&\
./configure --without-makeinfo --with-gif=no &&\
make mostlyclean                                  &&\
make bootstrap                                    &&\
make install                                      &&\
echo "`date` emacs build complete"                &&\
ls -l `which emacs`
popd
