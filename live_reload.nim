import threadpool
import os, times, strutils, osproc, streams

var
  server_running = false
  p: Process
  code_is_new = false
  code_init = true
  cmds = commandLineParams()
  exclude_dir = cmds[0]

proc async_read_process(fd: Stream)  =
  for line in fd.lines:
    echo line

proc main() =
  while true:
    var now_unixtime = getTime().toUnix
   
    for file in walkDirRec ".":
      # if file.endsWith ".go":
      if not file.startsWith exclude_dir:
        if code_is_new == false and (
          now_unixtime - file.getLastModificationTime.toUnix
                ) < 3:
          # echo file
          code_is_new = true
          sleep(1000)

    if code_is_new or code_init:
      while server_running:
        terminate p
        echo ("terminate", running p, processID p)
        sleep(1000)
        server_running = running p
        echo ("terminate end", running p, processID p)

      p = startProcess(cmds[1], options={
        # poEvalCommand,
        poUsePath,
        poInteractive,
        poStdErrToStdOut,
        },
        args = cmds[2..cmds.len - 1]
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
