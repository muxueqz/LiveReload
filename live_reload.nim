import re
import threadpool
import os, times, osproc, streams
import docopt
import psutil, posix

let doc = """
Live Reload.

Usage:
  live_reload (--exclude=<path>)... <cmd> ...
  live_reload (-h | --help)
  live_reload --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --exclude PATH   Exclude Path, Support Regex
"""


let args = docopt(doc, version = "Live Reload 1.0")


var
  server_running = false
  p: Process
  code_is_new = false
  code_init = true
  exclude_paths = args["--exclude"]
  cmds = newSeq[string]()

echo "Exclude Paths:":exclude_paths

for c in args["<cmd>"]:
  cmds.add c

echo "cmd:":cmds

proc kill_childpids_by_pgid() =
  var pgid = getCurrentProcessId()
  for p in psutil.pids():
    var p_pgid = getpgid p.Pid
    if p_pgid == pgid and p.Pid != pgid:
      discard kill(p.Pid, SIGTERM)

proc async_read_process(fd: Stream)  =
  for line in fd.lines:
    echo line

proc main() =
  while true:
    var now_unixtime = getTime().toUnix
   
    for file in walkDirRec ".":
      # if file.endsWith ".go":
      var skip_file = false
      for i in exclude_paths:
        if match(file, re i):
        # if file.startsWith i:
          skip_file = true
      if code_is_new == false and
        skip_file == false and 
          (
        now_unixtime - file.getLastModificationTime.toUnix
              ) < 3:
        echo file, " is update"
        code_is_new = true
        sleep(1000)

    if code_is_new or code_init:
      while server_running:
        kill_childpids_by_pgid()
        terminate p
        echo ("terminate", running p, processID p)
        sleep(1000)
        server_running = running p
        echo ("terminate end", running p, processID p)

      p = startProcess(cmds[0], options={
        # poEvalCommand,
        poUsePath,
        poInteractive,
        poStdErrToStdOut,
        },
        args = cmds[1..cmds.len - 1]
        )
      var fd = p.outputStream
      spawn async_read_process(fd)
      echo ("running", running p, processID p)
      server_running = running p
      code_is_new = false
      code_init = false
      echo cmds
    sleep(1000)
main()
