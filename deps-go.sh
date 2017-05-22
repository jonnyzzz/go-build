#!/bin/bash

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
set -e -x -u

GOVERSION=1.8.1

LOCAL_DIST="$(pwd)/dist"
LOCAL_GO_HOME="$LOCAL_DIST/go-$(uname)-$GOVERSION"
if [ ! -f $LOCAL_GO_HOME/bin/go ]; then
  GO_PKG=$LOCAL_DIST/go-pkg-$GOVERSION/go-binary.tar.gz
  GO_UNPACK=$LOCAL_DIST/go-pkg-$GOVERSION/unpack

  rm -rf   $GO_UNPACK || true
  mkdir -p $GO_UNPACK || true

  if [[ "$( uname )" =~ .*[Dd]arwin.* ]]; then
    curl -o $GO_PKG https://storage.googleapis.com/golang/go${GOVERSION}.darwin-amd64.tar.gz
  else
    curl -o $GO_PKG https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz
  fi

  tar -xf $GO_PKG -C $GO_UNPACK

  rm -rf $LOCAL_GO_HOME || true
  mkdir -p $LOCAL_GO_HOME || true
  mv $GO_UNPACK/go/** $LOCAL_GO_HOME/

  rm -f $GO_PKG
fi

PATH="$LOCAL_GO_HOME/bin:$PATH"
GOROOT=$LOCAL_GO_HOME
GOPATH=$(pwd)

export PATH
export GOROOT
export GOPATH
export CGO_ENABLED=0

if [[ "$(which go)" != "$LOCAL_GO_HOME/bin/go" ]]; then
  echo "Incorrect go binary is still used: $(which go)"
  exit 1
fi

if [[ ! "$(go version)" =~ "go${GOVERSION} " ]]; then
  echo "Failed to install required Go version. "
  exit 1
fi
