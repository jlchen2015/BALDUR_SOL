      subroutine cptimer(ztime)
      real ztime
C
C  this routine returns the elapsed CPU time.  Valid for UNIX or VMS
C
      call cptimi(ztime)
      ztime=0.01*ztime
C
      return
      end
