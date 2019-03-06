# server_autoreload
Live reload utility for Go web servers 

## Install
```bash
nim c --threads:on live_reload.nim
```

## Use
```bash
#exclude ./build/
./live_reload ./build/ go run
```
