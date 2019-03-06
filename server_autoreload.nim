import threadpool
import os, times, strutils, osproc, streams

proc async_read_process(fd: Stream)  =
  for line in fd.lines:
    echo line
  # echo fd.readAll
  # return fd.readAll
setMaxPoolSize(1)
setMinPoolSize(1)

var
  server_running = false
  p: Process
  code_is_new = false
  code_init = true

proc main() =
  while true:
    var now_unixtime = getTime().toUnix
   
    for file in walkDirRec ".":
      if file.endsWith ".go":
        if (
          now_unixtime - file.getLastModificationTime.toUnix
                ) < 3:
          # echo file
          code_is_new = true

    # echo (now_unixtime, code_is_new)

    if code_is_new or code_init:
      while server_running:
        terminate p
        echo ("terminate", running p, processID p)
        sleep(1000)
        server_running = running p
        echo ("terminate end", running p, processID p)

      var cmds = commandLineParams()
      # for i in commandLineParams():
        # if
        # echo i
      # var cmd = join(cmds, " ")
      # p = startProcess(cmd, options={
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
