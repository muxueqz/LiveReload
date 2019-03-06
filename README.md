# Live Reload
Live reload utility for Go/Nim web servers 

Watch Files -> Restart Process

## Install
```bash
nim c --threads:on live_reload.nim
```

## Use
```bash
#exclude ./build/
./live_reload ./build/ go run
```
