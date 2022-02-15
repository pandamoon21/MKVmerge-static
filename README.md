# MKVMerge static builds
Static builds for MKVMerge from [MKVToolNix](https://mkvtoolnix.download/source.html) using `docker`

## Current Release
* MKVMerge version: 65.0.0 for Linux x64

## Commands
```
docker build -t mkvtoolnix .
docker create -ti --name dummy mkvtoolnix bash
docker cp dummy:/x86_64/mkvmerge .
docker rm -f dummy
docker system prune -a # If you want to delete all unused docker images
```
