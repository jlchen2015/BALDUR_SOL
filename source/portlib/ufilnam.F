C-----------------------------------------------------------------------
C  ufilnam -- form complete unix file specification
C
      subroutine ufilnam(envroot,filnam,fullname)
c
#ifdef __NAGWARE
      use f90_unix_env
#endif
c
      character*(*) envroot     ! input -- directory name
      character*(*) filnam      ! input -- filename
C
      character*(*) fullname	  ! output -- full filename
C
      integer str_length
C
C  this routine essentially concatenates envroot and filnam, inserting
C  an intervening "/" if needed, to create the full filename.
C
C  envroot, or the first word before "/" in envroot, can be an
C  environment variable which gets translated here.
C
C-----------------------------------------------------------------------
C
#ifdef __UNIX
      if(envroot.eq.' ') then
        fullname=filnam
        go to 1000
c
      else if((envroot(1:1).eq.'/').or.(envroot(1:1).eq.'~')) then
        fullname=envroot
        go to 500
c
      else
        fullname=' '
        ilen=str_length(envroot)
        ilenv=index(envroot,'/')-1
        if(ilenv.lt.0) ilenv=ilen
        ist=1
        if(envroot(1:1).eq.'$') ist=2
        call sget_env(envroot(ist:ilenv),fullname)
        if(fullname.eq.' ') then
          fullname=envroot
        else
          if(ilenv.lt.ilen) then
            ilbl=index(fullname,' ')
            fullname(ilbl:)=envroot(ilenv+1:ilen)
          endif
        endif
        go to 500
      endif
C
 500  continue
      ilnb=index(fullname,' ')-1
      if(fullname(ilnb:ilnb).ne.'/') then
        ilnb=ilnb+1
        fullname(ilnb:ilnb)='/'
      endif
C
      fullname(ilnb+1:)=filnam
C
#endif
C
#ifdef __VMS
      if(envroot.eq.' ') then
         fullname=filnam
         go to 1000
      else
         ilenv=str_length(envroot)
         if((envroot(ilenv:ilenv).ne.':').and.
     >      (envroot(ilenv:ilenv).ne.'.').and.
     >      (envroot(ilenv:ilenv).ne.']').and.
     >      (envroot(ilenv:ilenv).ne.'>').and.
     >      (envroot(ilenv:ilenv).ne.'[').and.
     >      (envroot(ilenv:ilenv).ne.'<')) then
            fullname = envroot(1:ilenv)//':'//filnam
         else
            fullname = envroot(1:ilenv)//filnam
         endif
      endif
#endif
 1000 continue
      return
      end
