c  11:00 15-jan-92 .../baldur/code/bald/dpellet.f
c/ 12:30 18-dec-89 /11040/bald89/wbaldn1 DPELLET, Bateman, Stotler, PPPL
c  BALDUR  file DPELLET by Bateman, PPPL
c--------1---------2---------3---------4---------5---------6---------7-c
c**********************************************************************c
c
c  To obtain this file, type
c cfs get /11040/bald89/wbaldn1
c end
c lib wbaldn1 ^ x dpellet ^ end
c
c**********************************************************************c
c
c     this file contains the following packages:
c  pdrive - pellet injection package
c
c--------1---------2---------3---------4---------5---------6---------7-c
c
c@pdrive  .../baldur/code/bald/dpellet.f
c  rap 23-feb-00 call ifix(...) changed to call int(...)
c  ahk 24-feb-97 added if(.not.inital) go to 26
c  rgb 14-aug-96 replaced fuzz with rndeps
c  rgb 02-jun-96 save inject and remove if(.not.inital) go to 26
c  rgb 18-dec-89 removed return after go to 10 just before end
c  rgb 16.06 26-jan-89 rewrote iteration used in sbrtn psolth
c  rgb 16.05 26-jan-89 equilibrium harmonics in cm on xbouni grid
c      straight from rc0xbi(jx), rcmxbi(jm,jx), and ysmxbi(jm,jx)
c  rgb 16.01 25-jan-89 preporcess with xstripx before precompiling
c      dps 17-dec-87 add subscripts to beam ion quantities for multiple
c                    beam species; is treatment correct? (from BALDP86m)
c  rgb 12.66 02-sep-87 skip three lines rather than starting a new page
c               when printing summary along pellet path
c      dps 25-feb-87 prevent resetting of logical variable inital when
c                    rmins and/or rmajs change
c      rgb 18-nov-86 reset begini after chi altered by pellet
c               conservation checks start anew after pellet injection
c      dps 22-oct-86 allow for horizontal pellet path above midplane
c                    via ypa array
c      dps 22-oct-86 fix bug for pellet paths not intersecting inner wall
c      ces 23-jun-86 add pellet core source and mixed species pellets
c      rgb 25-nov-85 converted z02 to internal units and replaced
c                    30. eV with   eioniz * 1.e3
c                    as the energy lost with each ionization of Hydrogen
c     rgb 17-nov-85  1 1/2 D upgrade, added common block commhd
c        changed zrmaj to rmids(j,1) + - ahalfs(j,1)
c        changed 2 * volume to 2.0 * vols(mzones,1)
c       drm 4-dec-84 use new routines from ornl
c       drm 28-mar-84 added switch to bypass fast-ion ablation, and factor
c       to multiply the pellet deposition (c-254 and c-255)
c       drm 27-feb-84 cleaned up interface code, pass beam and alpha
c       information, use new pellet package from ornl
c       aes 13-apr-82 added comment: npel is hardwired to 1
c       aes 03-mar-82 add npelou:  control printout freq. via iprint.
c                      also fix cfutz(noprnt) coding
c       fgps 15-nov-81 extended pellet firings by making "tpela(it)"
c                      contain the on-time for the it-th cluster of
c                      successive firings
c       fgps 27-mar-81 expanded allotted space for injection times
c                      in formats 9000 & 9001
c       aes 23-mar-81 allow up to 20 pellets -- see near line 20
c       aes 5-jan-81 update comment lines
c       aes 24-oct-80 eliminate comin3 -- put variables in comin
c       dhfz 29-oct-79 multiple pellets
c       dhfz 11-apr-79 fix tpel bug
c       dhfz 6-apr-79 add message
c       dhfz 2-jan-79 wrote pdrive
c**********************************************************************c
c
        subroutine pdrive
c
cl      2.21    inject the pellet
c
       include 'cparm.m'
       include 'cbaldr.m'
       include 'cfokkr.m'
       include 'commhd.m'
       include 'clintf.m'
c
        logical
     l   inital       , inject       , lfired       , lrpeat
c
        dimension
     r  zchord(220), zdvol(mj), zpden(mj), zte(mj), zdene(mj),
     r  zvcbx(mj), zvcax(mj), zebgx(21), zeagx(2), zntrvl(20),
     r  ztpela(21), zdenb(mj,20), zdena(mj), zpdenc(mj),
     i  imap(220), intrvl(20),
     r  zr0(kjbal),zrm(kjbal,kmhrm),zym(kjbal,kmhrm),
     r  zcosth(kmhrm)
c
c  zr0(jx), zrm(jx,jm), zym(jx,jm) are equilibrium harmonics in cm
c     on the xbouni(jx) BALDUR grid
c
        data    inital,inject /.true.,.true./
        data    iclass/2/,      isub/21/
        data ifiabl, ifract/ 254, 255/
        data ipellt,(intrvl(i),i=1,20),ihance,imaxn0,noprnt
     i      /230,231,232,233,234,235,236,237,238,239,240,241,
     i       242,243,244,245,246,247,248,249,250,251,252,253/
c
      save inject, inital
c
        if(.not.nlomt2(isub)) go to 10
        return
 10     continue
c----------------------------------------------------------------------
c
cinput
c
c   Input variables  for the pellet package used in sbrtn PDRIVE
c   ---------------------------------------
c
c   npel2       --- 1-milora-foster model, 2-unshielded model,
c                   3-gralnick model
c   npelga(it)  --- pellet gas: 1=hydrogen, -2=deuterium, -3=tritium
c   npelgc(it)  --- core gas: 1=hydrogen, -2=deuterium, -3=tritium
c                   of pellets in the it-th cluster
c   npelsa(it)  --- =0 if firings of pellets in it-th cluster have not
c                   yet begun; =0 while firings from the it-th cluster
c                   are underway; =1 once firings from the it-th clus-
c                   ter have been completed
c   rpa(it)     --- shortest distance from pellet path to minor radius
c                   for pellets in the it-th cluster (cm)
c   ypa(it)     --- distance above midplane for horizontal pellet path
c                   in it-th cluster (cm)
c   rpela(it)   --- pellet radius of pellets in the it-th cluster (cm)
c   rpelc(it)   --- core radius of pellets in the it-th cluster (cm)
c   tpela(it)   --- on-time (sec) for the first of successive firings
c                   of pellets in the it-th cluster
c   vpela(it)   --- velocity of pellets in the it-th cluster (cm/sec)
c
c      where
c
c   it          --- pellet-cluster number ( < 21 )
c
c  First BALDUR namelist
c  ---------------------
c
c   cfutz(230)      =0.0 allows only one pellet firing per cluster (that
c                   is to say per value of it).  default is 0.0.
c        "          =1.0 allows multiple successive pellet firings
c                   per cluster (namely per value of it); but, inter-
c                   vals between firings always equal cfutz(intrvl(1))
c                   in secs for all clusters.
c        "          =2.0 allows multiple successive pellet firings
c                   per cluster (namely per value of it); but, inter-
c                   vals between firings must be prescribed separately
c                   for each cluster; i.e., cfutz(intrvl(1)), cfutz(in-
c                   trvl(2)), ---, cfutz(intrvl(20)).  in any case, if
c                   all cfutz(intrvl(i)) are zero, cfutz(ipellt) is re-
c                   set to zero.
c   cfutz(251)      contains the maximum deposition-enhancement factor
c                   employed when intervals between successive firings
c                   are less than the current timestep, "dti".  default
c                   value is 50.0.
c   cfutz(252)      =the maximum allowed number of consecutive pellet
c                   firings per cluster.  defaulted to 100.0.
c   cfutz(253)      =0.0 allows a short print-out each time a pellet
c                   is injected.
c                   >0.0 prevents short pellet print-outs.  default
c                   value is 0.0.
c
c                   note that the number of firings per it-th cluster
c                   equals the minimum of cfutz(imaxn0) and nmax0, where
c                   nmax0 = [tpela(it+1)-tpela(it)]/[interval], and
c                   where  [interval]=max [cfutz(intrvl(it)),dti].  but,
c                   when it=itmax, tpela(itmax+1) is not defined so that
c                   nmax0 = [tpela(itmax)-tpela(itmax-1)]/[interval]
c
c   see subroutine pellet for further explanations
c
cend
c
cpup
c namelist initialzations by Pup Feb 18, 2009
c
c        cfutz(ipellt)=1.0
c        cfutz(231)=1.0
c        cfutz(232)=1.0
cpup

        if(.not.inject) return
c
cl      1)       initializations
c
        zrmins=rmins
        zrmajs=rmajs
c
c pup added the following line on Apr 29, 2009
c cfutz(230) and cfutz(231-250) will be determined by cfz(230) and 
c itvpel(1-20) which declare in the input file
c
        cfutz(230)=cfz230
        do 232 it=1,20
        cfutz(230+it)=itvpel(it)
  232   continue
c pup end
        if(.not.inital) go to 12
c       initialize machine and physics constants 5/6/94 W.A.Houlberg
        call inicon
        call zincon
   12   continue
c
c  ...These lines cause problems if rmins or rmajs changes.
c
cgarb        if(rmins.ne.zrmins) inital=.true.
cgarb        if(rmajs.ne.zrmajs) inital=.true.
c
cbate        if(.not.inital) go to 26
cahk added following line
        if(.not.inital) go to 26
c
        inital=.false.
        inject=.false.
        lfired=.false.
        lrpeat=.false.
        n0=1
        iprint=3
        if(nstep.le.2) ztfire=0.0
        if(nstep.le.2) ztotal=0.0
c
        if(cfutz(ipellt).le.epslon) cfutz(ipellt)=0.0
        do 14 it=1,20
        npelsa(it)=1
        iii=intrvl(it)
        if(cfutz(iii)   .le.epslon) cfutz(iii)=0.0
        if(cfutz(iii)   .gt.epslon) lrpeat=.true.
        if(inject)                  go to 13
        if(iabs(npelga(it)).gt.0)   inject=.true.
        if(inject)                  it1=it
   13   continue
   14   continue
        if(.not.lrpeat)             cfutz(ipellt)=0.0
        if(cfutz(ihance).le.epslon) cfutz(ihance)=50.0
        if(cfutz(imaxn0).le.epslon) cfutz(imaxn0)=100.0
        if(cfutz(noprnt).le.epslon) cfutz(noprnt)=0.0
        n0max1=1+int(cfutz(imaxn0)+.1)
        lrpeat=.false.
c
        if(.not.inject)             go to 114
c
c
c       count the prescribed on-time values
c
        iit=1
        it2=it1+1
        do 22 it=it1,20
        if(it.lt.it2) go to 16
        if(tpela(it).le.epslon) go to 20
   16   continue
        npelga(iit)=npelga(it)
        npelsa(iit)=0
        rpa(iit)=rpa(it)
        ypa(iit)=ypa(it)
        rpela(iit)=rpela(it)
        rpelc(iit)=rpelc(it)
        vpela(iit)=vpela(it)
        zntrvl(iit)=0.0
        if(cfutz(ipellt).le.epslon) go to 18
        iii=intrvl(1)
        if(cfutz(ipellt).gt.1.1) iii=intrvl(it)
        zntrvl(iit)=cfutz(iii)*usit
   18   continue
        ztpela(iit)=tpela(it)*usit
        iit=iit+1
   20   continue
   22   continue
        itmax2=iit
        itmax1=itmax2-1
        itmax0=max0((itmax1-1),1)
        ztpela(itmax2)=2.*ztpela(itmax1)-ztpela(itmax0)
cpup what is tai       
        write(*,*)'itmax2=',itmax2,' itmax0=',itmax0
        write(*,*)'ztpela(itmax2)=',ztpela(itmax2)
        write(*,*)'ztpela(itmax1)=',ztpela(itmax1)
        write(*,*)'ztpela(itmax0)=',ztpela(itmax0)
        write(*,*)'zntrvl(1)=',zntrvl(1)
cpup        ztpela(itmax2)=605.0;
        write(*,*)'ztpela(itmax2)=',ztpela(itmax2)
        write(*,*)'cfz230 = ',cfz230
        write(*,*)'cfutz(230) = ',cfutz(230) 
        do 301 it=1,20
c        write(*,*)'itvpel(',it,') = ',itvpel(it)
        write(*,*)'cfutz(',it+230,') = ',cfutz(230+it) 
  301   continue
cpup
        if(tai.le.ztpela(1)) ztfire=ztpela(1)
        write(*,*)'tai = ',tai,' inject=',inject,' inital=',inital 
        write(*,*)'ztfire=',ztfire
c
c
   26   continue
c
cl      2)  logic for time of firing (ztfire)
c
        it=1
  110   continue
        if(npelsa(it).gt.0) go to 112
        if(.not.lfired) go to 116
        lfired=.false.
        if(.not.lrpeat) ztfire=max(ztfire,ztpela(it))
        if(.not.lrpeat) iprint=3
        if(.not.lrpeat) n0=1
        if(cfutz(ipellt).le.epslon) go to 116
        if(lrpeat) ztfire=max(zntrvl(it),dti)+ztfire
        if(lrpeat) iprint=0
        if(lrpeat) n0=n0+1
        lrpeat=.true.
        if((ztfire.lt.ztpela(it+1)).and.(n0.lt.n0max1)) go to 116
        lfired=.true.
        lrpeat=.false.
        npelsa(it)=1
  112   continue
        it=it+1
        if(it.gt.itmax1) go to 114
        go to 110
  114   continue
        inject=.false.
        return
c
  116   continue
        zhance=1.0
        if(zntrvl(it).lt.rndeps) go to 118
        z0=dti/zntrvl(it)
        zhance=max(z0,1.0)
        zhance=min(zhance,cfutz(ihance))
  118   continue
c
        if(tbi.lt.ztfire) return
c
        lfired=.true.
        ztotal=zhance+ztotal
        if(cfutz(ipellt).le.epslon) npelsa(it)=1
c
        if (((it/npelou)*npelou).ne.it) iprint=0
c
        xrp=rpa(it)  ! shortest distance from pellet path to minor radius
        xyp=abs(ypa(it))  ! distance above midplane for horizontal path
        xrpel=rpela(it)
        xrpelc=rpelc(it)
        xfrcor=frcor(it)
        xfrout=frout(it)
        xvpel=vpela(it)
        xtpel=ztpela(it)*uist
        knpel=1
c               note that knpel is hardwired: does not say,knpel=npel *****
        knpelg=abs(npelga(it))
        knpelc=abs(npelgc(it))
        zamup=float(knpelg)*(1.0-frcor(it)) + (knpelc)*frcor(it)
        zamupc=float(knpelc)*(1.0-frout(it)) + (knpelg)*frout(it)
        knpels=npelsa(it)
        knpel2=npel2
c
c       set up mapping and chord length arrays
c       start at the outer edge of the plasma
c
c  rgb 17-nov-85 using chord parallel to midplane
c     through widest part of plasma
c
c  dps 22-oct-86 generalize to allow displacement of path
c      vertically above midplane. Need flux surface shapes
c      on BALDUR zone boundaries.
c
        do 190 jx=1,mjbal
          zr0(jx) = rc0xbi(jx) * uisl
        do 190 jm=1,mhrms
          zrm(jx,jm) = rcmxbi(jm,jx) * uisl
          zym(jx,jm) = ysmxbi(jm,jx) * uisl
  190   continue
c
c
        zymax=elong(mzones,1)*ahalfs(mzones,1)
        if (xyp.gt.zymax) return
        if (xyp.eq.0.) then
        zrmaj = rmids(mzones,1) + ahalfs(mzones,1)
        else
        zq=0.
        zth0=0.
        call psolth(xyp,zq,zth0,zythp,kjbal,kmhrm,mhrms,
     &    zcosth,zym,mzones)
        zrmaj=zr0(mzones)+sdot(mhrms,zrm(mzones,1),kjbal,zcosth,1)
        end if
c
        if(xrp.ge.zrmaj) return
        zl2=sqrt(zrmaj**2-xrp**2)
        iseg=1
        zchord(1)=0.
        zq=1
        do 205 jz=ledge,lcentr,-1                     
        ljz=jz
        if (xyp.eq.0.) then
        zrmaj=rmids(jz,1)+ahalfs(jz,1)
        else
        if (xyp.ge.elong(jz,1)*ahalfs(jz,1)) go to 207
        call psolth(xyp,zq,zth0,zythp,kjbal,kmhrm,mhrms,
     &    zcosth,zym,jz)
        zrmaj=zr0(jz)+sdot(mhrms,zrm(jz,1),kjbal,zcosth,1)
        end if
        if(zrmaj.gt.xrp) then
        zl1=sqrt(zrmaj**2-xrp**2)
        else
        zl1=0.
        endif
        imap(iseg)=jz
        zchord(iseg+1)=1.0e-2*(zl2-zl1)
        if(zl1.eq.0.) go to 215
        iseg=iseg+1
205     continue
c
c       continue to r < rmajs
c
207     continue
        zq=0.
        zth0=zth0+1.e-4
        do 210 jz=ljz,ledge
        if (xyp.eq.0.) then
        zrmaj=rmids(jz+1,1)-ahalfs(jz+1,1)
        else
        call psolth(xyp,zq,zth0,zythp,kjbal,kmhrm,mhrms,
     &    zcosth,zym,jz+1)
        zq=-1.
        zrmaj=zr0(jz+1)+sdot(mhrms,zrm(jz+1,1),kjbal,zcosth,1)
        end if
        if(zrmaj.gt.xrp) then
        zl1=sqrt(zrmaj**2-xrp**2)
        else
        zl1=0.
        endif
        imap(iseg)=jz
        zchord(iseg+1)=1.0e-2*(zl2-zl1)
        if(zl1.eq.0.) go to 215
        iseg=iseg+1
210     continue
        iseg=iseg-1
        go to 225
c
215     continue
c
c       if the pellet does not strike the inner wall,
c       double the number of segments
c
        do 220 js=1,iseg
        isego=iseg+1-js
        isegn=iseg+js
c  The folowing line helps CFT version 1.13 avoid an infinite loop
cbate cdir$ block
        imap(isegn)=imap(isego)
        zchord(isegn+1)=zchord(isegn)+zchord(isego+1)-zchord(isego)
220     continue
        iseg=2*iseg
225     continue
c
c       pass volumes, densities, temperature, and energies
c
c
c       find active beam and set beam mass
c
        do 234 jb = 1, mhbeam
        ibeam1 = jb
        if (nhbeam(jb).ne.0) go to 236
  234   continue
        ibeam1=0
c
  236   continue
        if(ibeam1.ne.0) then
        zabx=habeam(ibeam1)
        else
        zabx=1.
        endif
c
c
        ibgx=lhemax
        zaax=aalpha
        iagx=1
        zeagx(1)=1.0e-3*efusei*uise*evsinv
        zeagx(2)=0.1*zeagx(1)
        izones=ledge
        zvol = 2.0 * vols(mzones,1)
        do 250 jz=lcentr,ledge
        zpden(jz)=0.
        zpdenc(jz)=0.
        zdvol(jz)=1.0e-6*zvol*dx2i(jz)
        zte(jz)=1.0e-3*evsinv*tes(2,jz)
        zdene(jz)=1.0e6*rhoels(2,jz)
        zvcbx(jz)=1.0e-2*5.e8*sqrt(zte(jz)*1.e-1)
        zvcax(jz)=1.0e-2*5.e8*sqrt(zte(jz)*1.e-1)
        if(lhemax.le.0) go to 246
        do 245 je=1,lhemax
        ie=lhemax+1-je
        zsum=0.
c
c       integrate the fast-ion distribution over pitch-angle
c
        ispc=1
        do 240 jmu=1,nhmu
        zsum=zsum+hdmub(jmu)*hfi(jmu,je,jz,ispc)
240     continue
        zdenb(jz,ie)=1.0e6*zsum*uisd
245     continue
246     continue
        zdena(jz)=1.0e6*alphai(jz)*uisd
250     continue
c
        if(lhemax.le.0) go to 256
        do 255 je=1,lhemax
        ie=lhemax+1-je
        zebgx(ie)=1.0e-3*hei(je,ispc)*uise*evsinv
255     continue
256     continue
        if(lhemax.ge.0) zebgx(lhemax+1)=0.5*zebgx(lhemax)
c
c
        zt0=uist*1000.0
        zt1=zt0*tbi
        zt2=zt0*ztfire
        zt3=zt0*zntrvl(it)
        zt4=zt0*dti
        kclstr=it
        if(cfutz(noprnt).gt.epslon) go to 285
        if(ntty.ne.0) write(ntychl,9010) zt1,n0,kclstr
        if(iprint.gt.0) go to 285
        write(nprint,9010) zt1,n0,kclstr
        go to 290
  285   continue
        if(iprint.eq.0)go to 290
        write(nprint,9000) nstep,zt1,zt2,n0,kclstr,zt3,zt4,zhance
        write(nprint,9020) zt1,ztotal
c
  290   continue
c
 9000 format(1h1//5x,'***pellet injection***',2x,' time-step=',i4,2x,
     & ' current time (tbi)=',0pf9.2,' ms',2x,' release time=',0pf9.2,
     & ' ms'/5x,'pellet number',i4,' in cluster number',i4,2x,
     & ' firing interval=',0pf8.3,' ms',2x,' dti=',0pf8.3,' ms'/
     & 5x,'deposition enhancement factor (when f. interval .lt. dti)=',
     & 0pf8.3)
 9010 format(/1x,'pellet injected at t=',0pf9.2,' ms',2x,
     & ' pellet number',i4,' in cluster number',i4/)
 9020 format(5x,'the effective total number of pellets injected by t=',
     .0pf9.2,' ms is',1pe10.3)
c
cl      4)      deposit pellet
c
        iifiab=0
        if(cfutz(ifiabl).eq.1.) iifiab=1
c     replace with updated PELLET routines 5/6/94 W.A. Houlberg
c     disabled some BALDUR enhancements
c     units changed from (cm,eV) to (m,keV)
c       call pellet(iprint, zamup, zamupc, xrpel, xrpelc,
c    1  xfrcor, xfrout, xvpel, izones, zdvol,
c    2  iseg, imap, zchord, zdene, zte, zabx, ibgx, zebgx, zvcbx,
c    3  zdenb, zaax, iagx, zeagx, zvcax, zdena, zpden, zpdenc,
c    4  nprint,iifiab)
      xrpel=xrpel*1.0e-2
      xvpel=xvpel*1.0e-2
      call sscal(55,1.0e6,zpden,1)
      call pellet(iprint,nprint,zamup,xrpel,xvpel,izones,zdvol,iseg,
     #            imap,zchord,zdene,zte,zabx,ibgx,zebgx,zvcbx,zdenb,
     #            zaax,iagx,zeagx,zvcax,zdena,zpden)
      xrpel=xrpel*1.0e2
      xvpel=xvpel*1.0e2
      call sscal(55,1.0e-6,zpden,1)
c
c                modify chi(*,*)
c
        zpden(mzones)=0.0
        z01=zhance*usid
        z02 = eioniz * 1.e3 * evs * usih ! energy lost each ionization
        zfract=1.     
        if(cfutz(ifract).gt.0.) zfract=cfutz(ifract)
c
c..determine species number for shell (iih) and core (iihc)
c
      iih  = 0
      iihc = 0
      do 302 ih=lhyd1,lhydn
      if (ngas(ih) .eq. npelga(it)) iih = ih
      if (ngas(ih) .eq. npelgc(it)) iihc = ih
 302  continue
c
c..sum over flux surfaces
c
        do 304 jz=lcentr,ledge
        zpden(jz)=zfract*z01*zpden(jz)
        zpdenc(jz)=zfract*z01*zpdenc(jz)
 304  continue
c
c       add deposition effects to chi(ih,jz) and chi(ihc,jz)
c
      if (iih .gt. 0) then
      do 306 jz=lcentr,ledge
      chi(iih,jz)=(1.0-frcor(it))*(zpden(jz)-zpdenc(jz))
     &           +frout(it)*zpdenc(jz) + chi(iih,jz)
 306  continue
      chi(iih,1)=chi(iih,lcentr)
      endif
c
      if (iihc .gt. 0) then
      do 308 jz=lcentr,ledge
      chi(iihc,jz)=(1.0-frout(it))*zpdenc(jz)
     &            +frcor(it)*(zpden(jz)-zpdenc(jz)) + chi(iihc,jz)
 308  continue
      chi(iihc,1)=chi(iihc,lcentr)
      endif
c
c       modify chi(lelec,jz) because of ionization losses
c
      do 310 jz=lcentr,ledge
      chi(lelec,jz)=-z02*zpden(jz)+chi(lelec,jz)
 310  continue
        chi(lelec,1)=chi(lelec,lcentr)
        zpden(1)=zpden(lcentr)
        zpdenc(1)=zpdenc(lcentr)
c
cl      5)    reset begini
c
c
        call resetr(begini,mxchi,0.0)
        call resetr(aflxii,mxchi,0.0)
        call resetr(aflxoi,mxchi,0.0)
        call resetr(asorci,mxchi,0.0)
        call resetr(asordi,mxchi,0.0)
        call resetr(acompi,mxchi,0.0)
c
        zvoli = avi(mzones,12,1)
c zvoli = total volume within plasma in internal units
c
        do 344 jz = lcentr, ledge
cbate   zvolzi = zvoli * 2.0 * dx2i(jz)
      zvolzi = avi(jz,4,1) * (xbouni(jz+1)-xbouni(jz))
c
c zvolzi = volume between zone bndry j and j+1 in internal units
c
        do 342 jp = 1, mchi
        begini(jp) = begini(jp) + chi(jp,jz) * zvolzi
  342   continue
c
 344  continue
c
        do 348 jp = 1, mchi
        totali(jp) = begini(jp)
  348   continue
c
c
        return
        end
c
c       ******************************************************
c
c
c*****************************************************************************
c
      subroutine psolth(yp,zq,thi,ythp,jdim,mdim,mom,costh,ym,jz)
c
c  dps 22-oct-86
c  This subroutine identifies a range in theta, thi -> thp, containing
c  the intersection of the pellet path with the zone boundary,
c  i.e., yth0 < yp < ythp, and then uses an iteration scheme to reach
c  a precise value. The "answer" in this case is the array of 
c  cos(n*theta), costh, needed in computing the major radius of the
c  point of intersection.
c  Note that zq is picked to match the locally expected sign of
c  d y / d theta ( is 0 initially, however).
c
      dimension sinth(20),costh(mdim),ym(jdim,mdim)
      pi=3.14159265358979323846
      ndiv=50
   10 continue
c
      th0=thi
      dth=pi/float(ndiv)
      call sincos(th0,mom,sinth,costh)
      yth0=sdot(mom,ym(jz,1),jdim,sinth,1)
      if (yth0.eq.yp) then
        thp=th0
        ythp=yth0
        return
      end if
      thsgn=1.                         
      if (zq*(yp-yth0).lt.0.) thsgn=-1.  ! 1st guess is in wrong direction
c
   20 continue
      thp=th0+thsgn*dth
      call sincos(thp,mom,sinth,costh)
      ythp=sdot(mom,ym(jz,1),jdim,sinth,1)
      if (ythp.eq.yp) then
        th0=thp
        yth0=ythp
        return
      end if
c
      if ((ythp-yp)*(yth0-yp).lt.0.) go to 30
      if (ythp.lt.0.) go to 50  ! error condition
      if (zq*thsgn*(ythp-yth0).lt.0.) then  ! search has gone over top 
        ndiv=2*ndiv
        if (ndiv.gt.1000) go to 50
        go to 10
      end if
      yth0=ythp
      th0=thp
      go to 20 
c
   30 continue 
      thi=th0
      if (ythp.lt.yth0) then   ! order range properly
        tmp=th0
        thi=thp
        thp=tmp
        tmp=yth0
        yth0=ythp
        ythp=tmp
      end if
c
c  begin iteration scheme midway between range endpoints
c
      it=0 
      ythi = yth0
      thnp1=0.5*(thi+thp)
      y1=ym(jz,1)
c
   40 continue
      it=it+1
      if (it.gt.20) go to 50
      call sincos(thnp1,mom,sinth,costh)
      ynp1=sdot(mom,ym(jz,1),jdim,sinth,1)
c
      if ((it.ne.1).and.(abs(thnp1-thold)/max(0.1,thold).le.1.0e-5))
     1  then                                ! test for end
      if ((thnp1-thi)*(thnp1-thp).gt.0.) go to 50 ! error if out of range
        thi=thnp1
        ythp=ynp1
        return
      end if
c
c  set next guess using linear interpolation
c
      thold=thnp1
      yold = ynp1
c
      if ( (yp-ythi)*(yp-ynp1) .le. 0. 
     &     .and. abs(ynp1-ythi) .gt. 1.e-16 ) then
        thnp1 = ( (yp-ythi)*thnp1 + (ynp1-yp)*thi ) / ( ynp1 - ythi )
        thp   = thold
        ythp  = yold
      elseif ( (yp-ythp)*(yp-ynp1) .le. 0. 
     &         .and. abs(ynp1-ythp) .gt. 1.e-16 ) then
        thnp1 = ( (yp-ythp)*thnp1 + (ynp1-yp)*thp ) / ( ynp1 - ythp )
        thi   = thold
        ythi  = yold
      else
        call prtrs (6,thnp1,'thnp1')
        call prtrs (6,ynp1,'ynp1')
        call prtrs (6,thp,'thp')
        call prtrs (6,ythp,'ythp')
        call prtrs (6,thi,'thi')
        call prtrs (6,ythi,'ythi')
        call abortb (6,'out of range in sbrtn psolth')
      endif
c
cbate      arg=yp/y1+(sinth(1)-ynp1/y1)
cbate      thnp1=asin(arg)
cbate      if (thold.gt.pi/2) thnp1=pi-thnp1  ! get quadrant right ???
c
      go to 40  
c
   50 continue
      call abortb(6,' error in psolth ')
      return
      end   
c
c--------1---------2---------3---------4---------5---------6---------7-c
c
        subroutine sincos(ztheta,jang,snthtk,csthtk)
c
c       this subroutine calculates:
c               sin(ztheta)
c               cos(ztheta)
c               sin(2*ztheta)
c               cos(2*ztheta)
c       etc., up to jang*ztheta
c
c
c               ztheta is input angle
c               jang is highest n*ztheta to calculate
c               snthtk is the array containing sin(n*ztheta)
c               csthtk is the array containing cos(n*ztheta)
c
        dimension snthtk(*),csthtk(*)
c
        snthtk(1)=sin(ztheta)
        csthtk(1)=cos(ztheta)
c
        do 100 i=2,jang
        snthtk(i)=snthtk(i-1)*csthtk(1)+csthtk(i-1)*snthtk(1)
        csthtk(i)=csthtk(i-1)*csthtk(1)-snthtk(i-1)*snthtk(1)
100     continue
c
        return
        end
      subroutine pelabl(newcel,rps,tes,dens,xrhor,tfd,rdot1,rdot2,
     #                  difrdt)
c***********************************************************************
c*****PELABL calculates the rates of recession of the pellet surface   *
c***** from two equations using the cloud thickness as the independent *
c***** parameter.                                                      *
c*****References:                                                      *
c*****Houlberg, Milora, Attenberger, Nucl Fusion 28 (1988) 595.        *
c*****Milora, ORNL/TM-8616 (1983).                                     *
c*****Last Revision: 3/91 W.A.Houlberg and S.E.Attenberger ORNL.       *
c*****Input:                                                           *
c*****newcel-flag to recalculate fast ion fluxes in plasma.            *
c*****      =0 same plasma cell as previous call.                      *
c*****      =1 new plasma cell.                                        *
c*****rps-pellet radius-m.                                             *
c*****tes-electron temperature-keV.                                    *
c*****dens-electron density-/m**3.                                     *
c*****xrhor-cloud thickness / rhosrp-dimensionless.                    *
c*****tfd-collisionless self-limiting parameter-dimensionless.         *
c*****Output:                                                          *
c*****rdot1-dr/dt from energy balance at pellet surface-m/s.           *
c*****rdot2-dr/dt from balance in cloud-m/s.                           *
c*****difrdt-ratio of difference to average of the two dr/dt solutions.*
c*****Internal:                                                        *
c*****qtc-total heat flux at neutral cloud surface-keV/m**2/s.         *
c*****qtp-total heat flux at pellet surface-keV/m**2/s.                *
c*****xmp-molecular mass of pellet species-kg.                         *
c***********************************************************************
c      include 'pamxna.inc'
c*****mxna-maximum number of fast alpha energy groups
      integer        mxna,            mxna1
      parameter      (mxna=1,         mxna1=mxna+1)
c      include 'pamxnb.inc'
      integer        mxnb,            mxnb1
      parameter      (mxnb=20,        mxnb1=mxnb+1)
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
c      include 'compl8.inc'
c*****compl8-pellet cloud parameters
      real           ellipt,          fionc,           rcl,
     #               rclmin
      integer        kplabl,          neg
      common/compl8/ ellipt,          fionc,           rcl,
     #               rclmin,
     #               kplabl,          neg
c      include 'compl9.inc'
c*****compl9-pellet internal
      real           amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag,             denag,           eago,
     #               qago,
     #               ebg,             denbg,           ebgo,
     #               qbgo
      integer        nag,             nbg
      common/compl9/ amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag(mxna1),      denag(mxna),     eago(mxna),
     #               qago(mxna),
     #               ebg(mxnb1),      denbg(mxnb),     ebgo(mxnb),
     #               qbgo(mxnb),
     #               nag,             nbg
      xmp=2.0*amup*promas
c*****Set pellet surface area exposed to each flux.
      areat=4.0*pi*rps**2
      areae=areat/2.0
      areaf=areat/2.0
c*****Get the electron and ion heat fluxes to cloud and pellet surface.
      cloudn=ellipt*xrhor*rhosrp/xmp
      cloudi=fionc*xrhor*rhosrp/xmp
      call pelqe(tes,dens,cloudn,cloudi,tfd,qeo,fqe)
      denbgt=ssum(nbg,denbg,1)
      if(denbgt.gt.0.0) then
c*****  Fast beam ions.
        call pelqf(newcel,1,ebg,denbg,nbg,ab,vcb,cloudn,cloudi,ebgo,
     #             qbgo,qbo,fqb)
      endif
c*****Fast alphas.
      denagt=ssum(nag,denag,1)
      if(denagt.gt.0.0) then
        call pelqf(newcel,2,eag,denag,nag,aa,vca,cloudn,cloudi,eago,
     #             qago,qao,fqa)
      endif
c*****Calculate the pellet surface erosion rate.
      qtp=(qeo*fqe*areae+(qbo*fqb+qao*fqa)*areaf)/areat
      rdot1=-qtp/(evap*denm)
      qtc=qeo*(1.0-fqe)+qbo*(1.0-fqb)+qao*(1.0-fqa)
      if(qtc.lt.0.0) qtc=0.0
      q=qtc/(rhosrp*xrhor)
      xr=rps/rpel
      rdot2=-1.25*xrhor/xr*(xj7kv*q*rps*(gam-1.0)/2.0)**(1.0/3.0)
      difrdt=2.0*(rdot2-rdot1)/(rdot2+rdot1)
      return
      end
      subroutine pellet(kprint,nout,amupx,rpelx,vpelx,n,dvol,nl,lc,sl,
     #                  den,te,abx,nbgx,ebgx,vcbx,denbig,aax,nagx,eagx,
     #                  vcax,denaig,pden)
c***********************************************************************
c*****PELLET calculates the particle deposition profile for frozen     *
c***** hydrogenic pellets injected into an arbitrary plasma.           *
c*****References:                                                      *
c*****Houlberg et al., Nuc Fus 32. (1992) 1951. "Pellet penetration
c***** Experiments on JET"
c*****Houlberg, Milora, Attenberger, Nucl Fusion 28 (1988) 595.        *
c*****Milora, ORNL/TM-8616 (1983).                                     *
c*****Houlberg, Iskra, Howe, Attenberger, ORNL/TM-6549 (1979).         *
c*****Last Revision: 8/93 S.E.Attenberger and W.A.Houlberg ORNL.       *
c*****Input:                                                           *
c*****kprint-option for detail of printout.                            *
c*****      =0 errors in input and solution.                           *
c*****      =1 above plus input values and options.                    *
c*****      =2 above plus radial input and calculated parameters.      *
c*****      =3 above plus parameters along pellet path.                *
c*****nout-output device for printed output.                           *
c*****amupx-atomic mass number of pellet atoms-1<amup<3.               *
c*****rpelx-initial pellet (spherical) radius-m.                       *
c*****vpelx-pellet velocity-m/s.                                       *
c*****n-number of radial cells in plasma.                              *
c*****dvol(i)-volume of plasma cell i-m**3.                            *
c*****nl-number of segments along pellet path.                         *
c*****lc(l)-plasma cell for pellet segment l.                          *
c*****sl(l)-path distance to the beginning of segment l-m.             *
c*****      sl(1) is the entry point and can be non-zero.              *
c*****den(i)-electron density in cell i-/m**3.                         *
c*****te(i)-electron temperature in cell i-keV.                        *
c*****abx-atomic mass number of fast h ions.                           *
c*****nbgx-number of fast h ion energy groups.                         *
c*****ebgx(jg)-fast h ion energy at group boundary jg-keV.             *
c*****        -ebgx(jg) > ebgx(jg+1).                                  *
c*****vcbx(i)-critical velocity in cell i for fast h ions-m/s.         *
c*****denbig(i,jg)-fast h density in cell i and group jg-/m**3.        *
c*****aax-atomic mass number of fast he ions.                          *
c*****nagx-number of fast he ion energy groups.                        *
c*****eagx(jg)-fast he ion energy at group boundary jg-keV.            *
c*****        -eagx(jg) > eagx(jg+1).                                  *
c*****vcax(i)-critical velocity in cell i for fast he ions-m/s.        *
c*****denaig(i,jg)-fast he density in cell i and group jg-/m**3.       *
c*****Output:                                                          *
c*****pden(i)-increase in plasma density in cell i-/m**3.              *
c*****Internal:                                                        *
c*****denm-molecular density of hydrogenic ice-/m**3.                  *
c*****eion-dissociation and ionization energy per atom-keV.            *
c*****evap-evaporation energy per molecule-keV.                        *
c*****gam-ratio of specific heats for hydrogen gas.                    *
c*****kplabl-option for ablation model (standard model = 0)            *
c*****      =0 neutral gas shielding.                                  *
c*****      =1 neutral gas plus plasma shielding.                      *
c*****      =2 Macaulay neutral gas shielding.                         *
c*****ellipt-ellipticity of neutral shield.                            *
c*****rhosrp-pellet mass density x initial radius-kg/m**2.             *
c*****tolplc-tolerance for convergence of cloud solution.              *
c*****tolplr-tolerance for fractional radius of pellet remaining.      *
c*****tolplt-tolerance for fractional change in te per step.           *
c*****Comments:                                                        *
c*****Units are mks with temperatures in keV except where noted.       *
c***********************************************************************
c      include 'pamxna.inc'
c*****mxna-maximum number of fast alpha energy groups
      integer        mxna,            mxna1
      parameter      (mxna=1,         mxna1=mxna+1)
c      include 'pamxnb.inc'
      integer        mxnb,            mxnb1
      parameter      (mxnb=20,        mxnb1=mxnb+1)
c      include 'pamxnc.inc'
c*****mxnc-maximum number of radial cells - transport
      integer        mxnc,            mxnc1,           mx4nc2
      parameter      (mxnc=54,        mxnc1=mxnc+1,    mx4nc2=4*mxnc+8)
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
c      include 'compl1.inc'
c*****compl1-pellet diagnostic
      real           rpplt,           splt,            tplt,
     #               dnwplt,          tnwplt,          radplt
      common/compl1/ rpplt(4*mxnc1),  splt(4*mxnc1),   tplt(4*mxnc1),
     #               dnwplt(mxnc1),   tnwplt(mxnc1),   radplt(4*mxnc1)
c      include 'compl8.inc'
c*****compl8-pellet cloud parameters
      real           ellipt,          fionc,           rcl,
     #               rclmin
      integer        kplabl,          neg
      common/compl8/ ellipt,          fionc,           rcl,
     #               rclmin,
     #               kplabl,          neg
c      include 'compl9.inc'
c*****compl9-pellet internal
      real           amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag,             denag,           eago,
     #               qago,
     #               ebg,             denbg,           ebgo,
     #               qbgo
      integer        nag,             nbg
      common/compl9/ amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag(mxna1),      denag(mxna),     eago(mxna),
     #               qago(mxna),
     #               ebg(mxnb1),      denbg(mxnb),     ebgo(mxnb),
     #               qbgo(mxnb),
     #               nag,             nbg
      dimension      dvol(*),         den(*),          te(*),
     #               vcbx(*),         vcax(*),         pden(*)
      dimension      sl(*),
     #               lc(*)
      dimension      ebgx(*),         denbig(mxnc1,mxnb)
      dimension      eagx(*),         denaig(mxnc1,mxna)
      data tolplt/   0.2/
      data tolplr/   0.10/
      data tolplc/   0.1/
c*****Initialization.
      eion=32.6e-3
      ellipt=15.0
      evap=1.0e-5
      gam=1.4
      rclmin=0.001
      amup=amupx
      denm=-8.6857e26*amup**2+6.3023e27*amup+2.1200e28
      rpel=rpelx
      vpel=vpelx
      rhosrp=(2.0*amup*promas*denm)*rpel
      ab=abx
      nbg=nbgx
      nbg1=nbg+1
      call scopy(nbg1,ebgx,1,ebg,1)
      aa=aax
      nag=nagx
      nag1=nag+1
      call scopy(nag1,eagx,1,eag,1)
      call sscal(n,zero,pden,1)
      call scopy(n,den,1,dnwplt,1)
      call scopy(n,te,1,tnwplt,1)
      t=0.0
      rp=rpel
      xrhoro=0.0
      qbo=0.0
      fqb=0.0
      qao=0.0
      fqa=0.0
      if(kplabl.eq.1) then
        rcl=rp+rclmin
        fionc=1.0
      else
        fionc=0.0
      endif
      if(kprint.ge.1) then
c*****  Optional output.
        parpel=(4.0/3.0)*pi*rpel**3*(2.0*denm)
        write(nout,1110) kprint,n,amup,rpel,vpel,parpel
        if(kprint.ge.3) write(nout,1310)
      endif
c*****Follow the pellet path and determine the ablation rate.
c*****Flag to indicate whether pellet has entered plasma.
      inside=0
c*****Flag to indicate whether pellet has entered and exited plasma.
      inout=0
      do 10 l=1,nl
        tplt(l)=0.0
        splt(l)=0.0
        if(rp.gt.xmachp*rpel) then
          i=lc(l)
          if((i.le.0.or.i.gt.n).and.inside.eq.0) then
c*****      Pellet has not entered plasma yet.
c*****      Increment parameters for path outside plasma.
            dt=(sl(l+1)-sl(l))/vpel
            t=t+dt
            tplt(l)=t
            splt(l)=0.0
            rpplt(l)=rp
          elseif((i.gt.0.and.i.le.n).and.inout.eq.0) then
c*****      Pellet is inside plasma and never exited.
            inside=1
            denold=den(i)+pden(i)
            teold=(den(i)*te(i)-pden(i)*(2.0/3.0)*eion)/denold
            if(teold.lt.eion) teold=eion
            vcb=vcbx(i)
            call scopy(nbg,denbig(i,1),mxnc1,denbg,1)
            vca=vcax(i)
            call scopy(nag,denaig(i,1),mxnc1,denag,1)
            dt=(sl(l+1)-sl(l))/vpel
            rpold=rp
            call pelrk4(nout,tolplr,tolplt,tolplc,dvol(i),dt,t,rp,teold,
     #                  denold,srcp)
            tplt(l)=t
            splt(l)=srcp*dvol(i)/dt
            rpplt(l)=rp
            pden(i)=pden(i)+srcp
            dennew=den(i)+pden(i)
            tenew=(den(i)*te(i)-pden(i)*(2.0/3.0)*eion)/dennew
            if(tenew.lt.eion) tenew=eion
            dnwplt(i)=dennew
            tnwplt(i)=tenew
            if(kprint.gt.2) write(nout,1320) l,lc(l),sl(l),teold,
     #                                       tenew,denold,dennew,rp,
     #                                       srcp,qeo,qbo,qao,xrhoro
          elseif((i.le.0.or.i.gt.n).and.inside.eq.1) then
c*****      Pellet has been in the plasma but is now outside.
            inout=1
          endif
        endif
   10 continue
      if(kprint.ge.2) then
        write(nout,1210)
cjk  Begin do loop with i=2 to avoid problems when den=0
        do 20 i=2,n
          dennew=den(i)+pden(i)
          tenew=(den(i)*te(i)-pden(i)*(2.0/3.0)*eion)/dennew
          if(tenew.lt.eion) tenew=eion
          dsdn=0.0
          if(den(i).gt.0.0) dsdn=pden(i)/den(i)
          write(nout,1220) i,te(i),tenew,den(i),dennew,dvol(i),pden(i),
     #                     dsdn
   20   continue
      endif
      return
 1110 format('1    *** summary of pellet injection ***             ',//,
     #'     kprint--print option              =',i10                 ,/,
     #'     n     --number of mesh points     =',i10                 ,/,
     #'     amup  --ave atomic mass of pellet =',1pe10.3             ,/,
     #'     rpel  --initial pellet radius - m =',1pe10.3             ,/,
     #'     vpel  --pellet velocity - m/s     =',1pe10.3             ,/,
     #'           --total particles in pellet =',1pe10.3              )
 1210 format('1    *** summary of radial pellet profiles ***       ',//,
     #'       rad   initial     final   initial     final      cell',
     #'    source    source',/,
     #'      cell    e temp    e temp   density   density    volume',
     #'   density   density',/,
     #'                 kev       kev       /m3       /m3        m3',
     #'       /m3          ',/)
 1220 format(7x,i3,6(1x,1pe9.2),1x,0pf9.4)
 1310 format('1    *** summary along pellet path ***               ',//,
     #' path  rad path dist   initial     final   initial     final',
     #'     final    source       qeo       qbo       qao  rhor hat',/,
     #' cell cell  at entry    e temp    e temp   density   density',
     #'   pel rad   density',/,
     #'                   m       keV       keV       /m3       /m3',
     #'         m       /m3  kev/m2/s  kev/m2/s  kev/m2/s          ',/)
 1320 format(2(2x,i3),1x,0pf9.4,10(1x,1pe9.2))
      end
c******************
      BLOCK DATA case16
      integer        kplabl,          neg
      common/compl8/ ellipt,          fionc,           rcl,
     #               rclmin,
     #               kplabl,          neg
      data kplabl/   2/ 
      end
      subroutine pelmac(tolplr,rps,tes,dens,rdot)
c***********************************************************************
c*****PELMAC determines the pellet ablation rate using a fit to a 2D   *
c***** simulation by Macaulay.                                         *
c*****References:                                                      *
c*****Macaulay, Nucl Fusion (1993).                                    *
c*****Input:                                                           *
c*****rps-pellet radius-m.                                             *
c*****tolplr-tolerance for fractional radius of pellet remaining.      *
c*****tes-electron temperature-keV.                                    *
c*****dens-electron density-/m**3.                                     *
c*****Output:                                                          *
c*****rdot-rate of change in pellet radius-m/s.                        *
c***********************************************************************
c      include 'pamxna.inc'
c*****mxna-maximum number of fast alpha energy groups
      integer        mxna,            mxna1
      parameter      (mxna=1,         mxna1=mxna+1)
c      include 'pamxnb.inc'
      integer        mxnb,            mxnb1
      parameter      (mxnb=20,        mxnb1=mxnb+1)
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
c      include 'compl9.inc'
c*****compl9-pellet internal
      real           amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag,             denag,           eago,
     #               qago,
     #               ebg,             denbg,           ebgo,
     #               qbgo
      integer        nag,             nbg
      common/compl9/ amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag(mxna1),      denag(mxna),     eago(mxna),
     #               qago(mxna),
     #               ebg(mxnb1),      denbg(mxnb),     ebgo(mxnb),
     #               qbgo(mxnb),
     #               nag,             nbg
      data tesmin/   1.0e-3/
c*****check pellet size and minimum electron temperature.
      if((rps.lt.(tolplr*rpel)).or.(tes.lt.tesmin)) then
        rdot=0.0
        return
      endif
c*****convert from deuterium to arbitrary hydrogenic species.
      amud=2.0
      denmd=-8.6857e26*amud**2+6.3023e27*amud+2.1200e28
      fdens=denm/denmd
      fmass=(amud/amup)**(1.0/3.0)
c*****convert to Macaulay's units of cm and eV.
      tinf=tes*1.0e3
      rpcm=rps*1.0e2
      dninf=dens*1.0e-6
c*****compute the ablation rate, g2dgs, in atoms/s.
      dnstar=1.6e11*tinf**2/rpcm
      testar=1.1e-7*((dninf*rpcm)**2/tinf)**(1.0/3.0)
      corr=1.+0.08*log(dnstar*sqrt(testar)/6.0e18)
      g2dgs=9.0e15*corr
     #      *(1.0+0.09*log(250.0*testar))*(rpcm**4*dninf)**(1.0/3.0)
     #      *tinf**(11.0/6.0)/(log(0.147*tinf))**(2.0/3.0)
c*****compute dr/dt in m/s.
      rdot=-g2dgs/(denm*4.0*pi*rps**2)
      return
      end
      subroutine pelqe(te,den,cloudn,cloudi,tfd,qeo,fqe)
c***********************************************************************
c*****PELQE calculates the electron heat flux incident on the pellet   *
c***** cloud and the heat flux attenuation factor in the cloud.        *
c*****References:                                                      *
c*****Houlberg, Milora, Attenberger, Nucl Fusion 28 (1988) 595.        *
c*****Milora, ORNL/TM-8616 (1983).                                     *
c*****Last Revision: 3/91 W.A.Houlberg and S.E.Attenberger ORNL.       *
c*****Input:                                                           *
c*****te-electron temperature in plasma-keV.                           *
c*****den-electron density in plasma-/m**3.                            *
c*****cloudn-neutral cloud thickness-molecule/m**2.                    *
c*****cloudi-ionized cloud thickness-0.5*electrons/m**2.               *
c*****tfd-collisionless self-limiting parameter-dimensionless.         *
c*****Output:                                                          *
c*****qeo-electron heat flux incident on neutral cloud-keV/m**2/s.     *
c*****fqe=qep/qeo-heat flux attenuation factor.                        *
c*****Internal:                                                        *
c*****es-energy below which elastic scattering is used-keV.            *
c*****qep-electron heat flux at pellet surface-keV/m**2/s.             *
c*****alfe-cross-section for elastic scattering.                       *
c*****ce-mean electron thermal speed in plasma-m/s.                    *
c*****cjeo-random electron particle flux in plasma-keV/m**2/s.         *
c*****neg-number of electron groups.                                   *
c***********************************************************************
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
c      include 'compl8.inc'
c*****compl8-pellet cloud parameters
      real           ellipt,          fionc,           rcl,
     #               rclmin
      integer        kplabl,          neg
      common/compl8/ ellipt,          fionc,           rcl,
     #               rclmin,
     #               kplabl,          neg
      dimension      ae(2),           we(20),          we1(1),
     #               we5(5),          we10(10),        we20(20)
      save           ae,              alfe,            c,
     #               es,              we,              we1,
     #               we5,             we10,            we20
      data ae/       2.35e21,         4.0e21/
      data alfe/     1.8e-20/
      data c/        2.0/
      data es/       0.1/
      data we1/      1.00000/
      data we5/      3.58220,  2.39789,  1.76644,  1.25078,  0.50209/
      data we10/     4.26829,  3.14987,  2.60654,  2.22568,  1.91562,
     #               1.64694,  1.39401,  1.14336,  0.87304,  0.38355/
      data we20/     4.91742,  3.82498,  3.33808,  2.98877,  2.72599,
     #               2.50164,  2.31666,  2.14625,  1.99227,  1.84801,
     #               1.71277,  1.58720,  1.46082,  1.33618,  1.21265,
     #               1.08658,  0.95348,  0.80956,  0.63799,  0.29548/
c*****Set constants.
      neg=10
      if(neg.gt.10) then
        neg=20
        call scopy(neg,we20,1,we,1)
      elseif(neg.gt.5) then
        neg=10
        call scopy(neg,we10,1,we,1)
      elseif(neg.gt.1) then
        neg=5
        call scopy(neg,we5,1,we,1)
      else
        neg=1
        we(1)=we1(1)
      endif
      eo=1.5*te
      tej=te*xj7kv
      ce=sqrt((8.0/pi)*tej/elemas)
      cjeo=den*ce/4.0
      qeo0=(4.0/3.0)*cjeo*eo
      qep=0.0
      c1=ae(1)/ae(2)
      c2=2.0*cloudn/ae(2)
      enlam=10.0
      sgm=enlam*4.0*pi*(coulom/(4.0*pi*epsilo))**2
      ethr2=2.0*cloudi*sgm*(coulom/xj7kv)**2
      qeo=0.0
c*****Calculate parameters incident on the pellet.
      do 10 jg=1,neg
        tfactr=tfd*sqrt(we(jg))
        if(tfactr.gt.0.01) then
          qfactr=(1.0-exp(-tfactr))/tfactr
        else
          qfactr=1.0
        endif
        qeog=qeo0*qfactr/neg
        qeo=qeo+qeog
        eog=eo*we(jg)
        eogp2=eog**2-ethr2
        if(eogp2.lt.0.0) eogp2=0.0
        eogp=sqrt(eogp2)
        qeogp=qeog*eogp/eog
        qesg=qeog*es/eog
        if(eogp.le.es) then
c*****    Set xi2 and incident flux to scattering regime for eogp < es.
          xi2=0.0
          qex=qeogp
        else
c*****    Set xi2 and incident flux to scattering regime for eogp > es.
          xi2=ae(1)*(eogp-es)+ae(2)*(eogp**2-es**2)/2.0
          qex=qesg
        endif
c*****  Check whether epg > es.
        xi=alfe*(cloudn-xi2)
        if(xi.ge.0.0) then
c*****    epg < es.
          explim=log(xmachl)
          if(xi.gt.explim) xi=explim
          qepg=qex*(c+1)/(c+exp(xi))
        else
c*****    epg > es.
          epg=-c1+sqrt((c1+eogp)**2-c2)
          qepg=qeog*epg/eog
        endif
c*****  Add up energy flux at pellet surface.
        qep=qep+qepg
   10 continue
      fqe=qep/qeo
      return
      end
      subroutine pelqf(newcel,izf,efg,denfg,nfg,af,vcf,cloudn,cloudi,
     #                 efgo,qfgo,qfo,fqf)
c***********************************************************************
c*****PELQF calculates the fast ion heat flux incident on the pellet   *
c***** cloud and the heat flux attenuation factor in the cloud for     *
c***** either hydrogenic or helium fast ions.                          *
c*****References:                                                      *
c*****Houlberg, Milora, Attenberger, Nucl Fusion 28 (1988) 595.        *
c*****Milora, ORNL/TM-8616 (1983).                                     *
c*****Last Revision: 3/91 W.A.Houlberg and S.E.Attenberger ORNL.       *
c*****Input:                                                           *
c*****newcel-flag for reevaluating fluxes incident on cloud.           *
c*****      =0 use old values of qfo, efgo and qfgo from earlier call. *
c*****      =1 reset qfo, efgo and qfgo for new cell.                  *
c*****izf-fast ion charge-dimensionless.                               *
c*****   =1 fast hydrogen ions.                                        *
c*****   =2 fast helium ions.                                          *
c*****efg(jg)-fast ion energy at group boundary jg-keV.                *
c*****       -efg(jg) > efg(jg+1).                                     *
c*****denfg(jg)-fast ion density in group jg-/m**3.                    *
c*****         -efg(jg) > e > efg(jg+1).                               *
c*****nfg-number of fast energy groups.                                *
c*****af-atomic mass number of fast ions.                              *
c*****vcf-critical velocity for classical thermalization-m/s.          *
c*****cloudn-neutral cloud thickness-molecule/m**2.                    *
c*****cloudi-ionized cloud thickness-0.5*electrons/m**2.               *
c*****input parameters (newcel=0):                                     *
c*****efgo(jg)-see below.                                              *
c*****qfgo(jg)-see below.                                              *
c*****qfo-see below.                                                   *
c*****Output:                                                          *
c*****fqf=qfp/qfo-heat flux attenuation factor.                        *
c*****Output (newcel=1):                                               *
c*****efgo(jg)-average energy in interval jg-keV.                      *
c*****qfgo(jg)-energy flux in interval jg-keV/m**2/s.                  *
c*****qfo-fast ion heat flux incident on neutral cloud-keV/m**2/s.     *
c*****Internal:                                                        *
c*****ah(i)-parameters for fit to fast h+ energy loss in h2 gas.       *
c*****ahe(i)-parameters for fit to fast he+ energy loss in h2 gas.     *
c*****qfp-fast ion heat flux at pellet surface-kev/m**2/s.             *
c***********************************************************************
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
      dimension      efg(*),          denfg(*),        efgo(*),
     #               qfgo(*)
      dimension      ah(3),           ahe(2)
      save           ah,              ahe
      data ah/       1.0e-20,         30.93,           3.239/
      data ahe/      2.02e-22,        0.325/
      if((izf.lt.1).or.(izf.gt.2)) return
      if(newcel.ne.0) then
c*****  Set constants.
        qfo0=0.0
        sq3=sqrt(3.0)
c*****  Set velocities and integral expressions at low end of group.
        vl=sqrt(2.0*efg(1)*xj7kv/(af*promas))
        xvl=vl/vcf
        xvl2=xvl**2
        xvl3=xvl*xvl2
        tl1=log(1.0+xvl3)
        tl2=log((1.0-xvl+xvl2)/(1.0+xvl)**2)
        tl3=atan((2.0*xvl-1.0)/sq3)
c*****  Sum over energy groups.
        do 10 jg=1,nfg
c*****    Shift expressions to boundaries of next lower energy group.
          vl=sqrt(2.0*efg(jg+1)*xj7kv/(af*promas))
          xvl=vl/vcf
          xvh2=xvl2
          xvl2=xvl**2
          xvh3=xvl3
          xvl3=xvl*xvl2
          th1=tl1
          tl1=log(1.0+xvl3)
          th2=tl2
          tl2=log((1.0-xvl+xvl2)/(1.0+xvl)**2)
          th3=tl3
          tl3=atan((2.0*xvl-1.0)/sq3)
c*****    Calculate mean group energy in plasma.
          cong=3.0/log((1.0+xvh3)/(1.0+xvl3))
          efcon=af*promas*vcf**2/2.0/xj7kv
          xupper=xvh2/2.0-(th2/2.0+sq3*th3)/3.0
          xlower=xvl2/2.0-(tl2/2.0+sq3*tl3)/3.0
          efgo(jg)=efcon*cong*(xupper-xlower)
c*****    Calculate mean group heat flux in plasma.
          qfcon=denfg(jg)*efcon*(vcf/12.0)
          qfgo(jg)=qfcon*cong*((xvh3-th1)-(xvl3-tl1))
          qfo0=qfo0+qfgo(jg)
   10   continue
      endif
c*****Set constants for all energy groups.
      qfo=0.0
      qfp=0.0
      pemr=af*promas/elemas
      enlam=10.0
      sgm=enlam*4.0*pi*pemr*(coulom/(4.0*pi*epsilo))**2
      ethr2=2.0*cloudi*sgm*(coulom/xj7kv)**2
c*****Set threshhold energy to zero for ions normal to ionized cloud.
      ethr2=0.0
c*****Check fast ion species.
      if(izf.eq.1) then
c*****  Fast hydrogenic ions.
        b=ah(2)*sqrt(af)/ah(3)
        bb=b**2
        arhmg=cloudn*ah(1)/ah(3)
c*****  Calculate parameters incident on the pellet.
        do 20 jg=1,nfg
          egp=0.0
          efgop2=efgo(jg)**2-ethr2
          if(efgop2.lt.0.0) efgop2=0.0
          efgop=sqrt(efgop2)
          qfo=qfo+qfgo(jg)*efgop/efgo(jg)
          c=2.0*sqrt(efgop)/b+(efgop-arhmg)/bb
          if(c.gt.0.0) egp=bb*(-1.0+sqrt(1.0+c))**2
          qfp=qfp+qfgo(jg)*egp/efgo(jg)
   20   continue
        fqf=qfp/qfo
      elseif(izf.eq.2) then
c*****  Fast helium ions.
        c1=1.0-ahe(2)
        c2=cloudn*(4.0/af)**ahe(2)*ahe(1)*c1
        ethr2=4.0*ethr2
c*****  Calculate parameters incident on the pellet.
        do 30 jg=1,nfg
          egp=0.0
          efgop2=efgo(jg)**2-ethr2
          if(efgop2.lt.0.0) efgop2=0.0
          efgop=sqrt(efgop2)
          qfo=qfo+qfgo(jg)*efgop/efgo(jg)
          efgot=efgop**c1
          egp=max(efgot-c2,0.0)**(1.0/c1)
          qfp=qfp+qfgo(jg)*egp/efgo(jg)
   30   continue
        fqf=qfp/qfo
      else
c*****  Default calculation for izf > 2.
        qfp=0.0
        fqf=0.0
      endif
      return
      end
      subroutine pelrat(nout,newcel,tolplr,tolplc,rps,tes,dens,tfd,rdot)
c***********************************************************************
c*****PELRAT determines the pellet ablation rate through iterating on  *
c***** the dimensionless cloud thickness.                              *
c*****References:                                                      *
c*****Houlberg, Milora, Attenberger, Nucl Fusion 28 (1988) 595.        *
c*****Milora, ORNL/TM-8616 (1983).                                     *
c*****Forsythe, Malcolm, Moler, Comp Meth for Math Computations,       *
c***** Prentice-Hall (1977) 161.                                       *
c*****Last Revision: 3/91 W.A.Houlberg and S.E.Attenberger ORNL.       *
c*****Input:                                                           *
c*****nout-output device for printed output.                           *
c*****newcel-flag to recalculate fast ion fluxes in plasma.            *
c*****      =0 same plasma cell as previous call.                      *
c*****      =1 new plasma cell.                                        *
c*****tolplr-tolerance for fractional radius of pellet remaining.      *
c*****tolplc-tolerance for convergence of cloud solution.              *
c*****rps-pellet radius-m.                                             *
c*****tes-electron temperature-keV.                                    *
c*****dens-electron density-/m**3.                                     *
c*****tfd-collisionless self-limiting parameter-dimensionless.         *
c*****Output:                                                          *
c*****rdot-rate of change in pellet radius-m/s.                        *
c*****Internal:                                                        *
c*****xrhoro-prior solution to cloud tried first if available.         *
c*****a,b-dimensionless cloud thicknesses.                             *
c*****amin,bmax-range to check for cloud solution.                     *
c*****xrange-check xrhoro/xrange < b < xrhoro*xrange for solution.     *
c*****tesmin-cutoff electron temperature for ablation-kev.             *
c*****Comments:                                                        *
c*****The zeroin procedure from Forsythe, et al., is used to find the  *
c***** simultaneous solution to two equations for dr/dt which are non- *
c***** linear functions of the cloud thickness and plasma parameters.  *
c***********************************************************************
c      include 'pamxna.inc'
c*****mxna-maximum number of fast alpha energy groups
      integer        mxna,            mxna1
      parameter      (mxna=1,         mxna1=mxna+1)
c      include 'pamxnb.inc'
      integer        mxnb,            mxnb1
      parameter      (mxnb=20,        mxnb1=mxnb+1)
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
c      include 'compl9.inc'
c*****compl9-pellet internal
      real           amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag,             denag,           eago,
     #               qago,
     #               ebg,             denbg,           ebgo,
     #               qbgo
      integer        nag,             nbg
      common/compl9/ amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag(mxna1),      denag(mxna),     eago(mxna),
     #               qago(mxna),
     #               ebg(mxnb1),      denbg(mxnb),     ebgo(mxnb),
     #               qbgo(mxnb),
     #               nag,             nbg
      save           amin,            bmax,            tesmin,
     #               xrange
      data amin/     1.0e-10/
      data bmax/     1.0/
      data tesmin/   1.0e-3/
      data xrange/   3.0/
c*****Check pellet size and minimum electron temperature.
      if((rps.lt.(tolplr*rpel)).or.(tes.lt.tesmin)) then
        rdot=0.0
        return
      endif
c*****Begin zeroin procedure.
      if(xrhoro.lt.amin.or.xrhoro.gt.bmax) then
c*****  Use entire range.
        a=amin
        b=bmax
        call pelabl(newcel,rps,tes,dens,a,tfd,rdot1a,rdot2a,difa)
        newcel=0
        call pelabl(newcel,rps,tes,dens,b,tfd,rdot1b,rdot2b,difb)
        if(abs(sign(1.0,difa)+sign(1.0,difb)).gt.10.0*xmachp) then
c*****    Errors encountered - terminate calculation.
          write(nout,1010) difa,difb
          return
        endif
      else
c*****  Evaluate at previous solution.
        b=xrhoro
        call pelabl(newcel,rps,tes,dens,b,tfd,rdot1b,rdot2b,difb)
        newcel=0
        if(abs(difb).lt.tolplc) then
c*****    End of zeroin procedure.
          xrhor=b
          xrhoro=xrhor
          rdot=rdot2b
          return
        endif
        if(abs(difb).gt.(2.0-10.0*xmachp)) then
c*****    Use entire range.
          a=amin
          b=bmax
          call pelabl(newcel,rps,tes,dens,a,tfd,rdot1a,rdot2a,difa)
          newcel=0
          call pelabl(newcel,rps,tes,dens,b,tfd,rdot1b,rdot2b,difb)
          if(abs(sign(1.0,difa)+sign(1.0,difb)).gt.10.0*xmachp) then
c*****      Errors encountered - terminate calculation.
            write(nout,1010) difa,difb
            return
          endif
          go to 10
        endif
c*****  Evaluate at previous solution*xrange.
        a=b
        difa=difb
        rdot2a=rdot2b
        b=xrhoro*xrange
        if(b.gt.bmax) b=bmax
        call pelabl(newcel,rps,tes,dens,b,tfd,rdot1b,rdot2b,difb)
        if(abs(sign(1.0,difa)+sign(1.0,difb)).lt.10.0*xmachp) go to 10
c*****  Check which side to try next.
        if(abs(difb).gt.abs(difa)) then
c*****    Evaluate at previous solution/xrange.
          b=a
          difb=difa
          rdot2b=rdot2a
          a=xrhoro/xrange
          if(a.lt.amin) a=amin
          call pelabl(newcel,rps,tes,dens,a,tfd,rdot1a,rdot2a,difa)
          if(abs(sign(1.0,difa)+sign(1.0,difb)).lt.10.0*xmachp) go to 10
c*****    Evaluate at amin.
          b=a
          difb=difa
          rdot2b=rdot2a
          a=amin
          call pelabl(newcel,rps,tes,dens,a,tfd,rdot1a,rdot2a,difa)
          if(abs(sign(1.0,difa)+sign(1.0,difb)).gt.10.0*xmachp) then
c*****      Errors encountered - terminate calculation.
            write(nout,1010) difa,difb
            return
          endif
        else
c*****    Evaluate at bmax.
          a=b
          difa=difb
          rdot2a=rdot2b
          b=bmax
          call pelabl(newcel,rps,tes,dens,b,tfd,rdot1b,rdot2b,difb)
          if(abs(sign(1.0,difa)+sign(1.0,difb)).gt.10.0*xmachp) then
c*****      Errors encountered - terminate calculation.
            write(nout,1010) difa,difb
            return
          endif
        endif
      endif
c*****Begin step.
   10 c=a
      difc=difa
      rdot2c=rdot2a
      d=b-a
      e=d
   20 if(abs(difc).lt.abs(difb)) then
c*****  Reorder points a, b, and c.
        a=b
        b=c
        c=a
        difa=difb
        rdot2a=rdot2b
        difb=difc
        rdot2b=rdot2c
        difc=difa
        rdot2c=rdot2a
      endif
c*****Convergence test.
      toltst=2.0*xmachp*abs(b)
      fm=0.5*(c-b)
      if(abs(fm).le.toltst.and.abs(difb).ge.tolplc)
     #  write(nout,1020) fm,toltst
      if(abs(fm).le.toltst.or.abs(difb).lt.tolplc) then
c*****  End of zeroin procedure.
        xrhor=b
        xrhoro=xrhor
        rdot=rdot2b
        return
      endif
c*****Check if bisection is necessary.
      if(abs(e).lt.toltst) go to 30
      if(abs(difa).le.abs(difb)) go to 30
c*****Check if quadratic interpolation is possible.
      if(a.eq.c) then
c*****  Linear interpolation.
        s=difb/difa
        p=2.0*fm*s
        q=1.0-s
      else
c*****  Inverse quadratic interpolation.
        q=difa/difc
        r=difb/difc
        s=difb/difa
        p=s*(2.0*fm*q*(q-r)-(b-a)*(r-1.0))
        q=(q-1.0)*(r-1.0)*(s-1.0)
      endif
c*****Adjust signs.
      if(p.gt.0.0) q=-q
      p=abs(p)
c*****Check if interpolation is acceptable.
      if((2.0*p).ge.(3.0*fm*q-abs(toltst*q))) go to 30
      if(p.ge.abs(0.5*e*q)) go to 30
      e=d
      d=p/q
      go to 40
c*****Bisection.
   30 d=fm
      e=d
c*****Complete step.
   40 a=b
      difa=difb
      rdot2a=rdot2b
      if(abs(d).gt.toltst) b=b+d
      if(abs(d).le.toltst) b=b+sign(toltst,fm)
      call pelabl(newcel,rps,tes,dens,b,tfd,rdot1b,rdot2b,difb)
      if((difb*(difc/abs(difc))).gt.0.0) go to 10
      go to 20
 1010 format(' error:pelrat-soln out of range. difa,difb=             ',
     #2(1x,1pe9.2))
 1020 format(' error:pelrat-no convergence. fm,toltst=                ',
     #2(1x,1pe9.2))
      end
      subroutine pelrk4(nout,tolplr,tolplt,tolplc,dvol,dt,t,rp,te,den,
     #                  dden)
c***********************************************************************
c*****PELRK4 is a fourth order Runge-Kutta integration routine which   *
c***** updates the pellet radius and plasma parameters for time dt.    *
c*****References:                                                      *
c*****Houlberg, Milora, Attenberger, Nucl Fusion 28 (1988) 595.        *
c*****Last Revision: 3/91 W.A.Houlberg and S.E.Attenberger ORNL.       *
c*****Input:                                                           *
c*****nout-output device for printed output.                           *
c*****tolplr-tolerance for fractional radius of pellet remaining.      *
c*****tolplt-tolerance for fractional change in te per step.           *
c*****tolplc-tolerance for convergence of cloud solution.              *
c*****dvol-volume of this cell-m**3.                                   *
c*****dt-time pellet spends in this cell-s.                            *
c*****t-initial time since injection-s.                                *
c*****rp-initial pellet radius-m.                                      *
c*****te-initial electron temperature-keV.                             *
c*****den-initial electron density-/m**3.                              *
c*****Output:                                                          *
c*****t-updated time since injection-s.                                *
c*****rp-updated pellet radius-m.                                      *
c*****te-updated electron temperature-keV.                             *
c*****den-updated electron density-/m**3.                              *
c*****dden-incremental electron density-/m**3.                         *
c*****Internal:                                                        *
c*****newcel-flag to recalculate fast ion fluxes in plasma.            *
c*****      =0 same plasma cell as previous call.                      *
c*****      =1 new plasma cell.                                        *
c*****nstep-number of time steps to get through this cell.             *
c*****fte-estimated fractional change in te.                           *
c*****fdts-time step multiplier to keep te change within tolplt.       *
c*****s-function to evaluate density perturbation from ablation.       *
c***********************************************************************
c      include 'pamxna.inc'
c*****mxna-maximum number of fast alpha energy groups
      integer        mxna,            mxna1
      parameter      (mxna=1,         mxna1=mxna+1)
c      include 'pamxnb.inc'
      integer        mxnb,            mxnb1
      parameter      (mxnb=20,        mxnb1=mxnb+1)
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
c      include 'compl8.inc'
c*****compl8-pellet cloud parameters
      real           ellipt,          fionc,           rcl,
     #               rclmin
      integer        kplabl,          neg
      common/compl8/ ellipt,          fionc,           rcl,
     #               rclmin,
     #               kplabl,          neg
c      include 'compl9.inc'
c*****compl9-pellet internal
      real           amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag,             denag,           eago,
     #               qago,
     #               ebg,             denbg,           ebgo,
     #               qbgo
      integer        nag,             nbg
      common/compl9/ amup,            denm,            eion,
     #               evap,            gam,             rhosrp,
     #               rpel,            xrhoro,          vpel,
     #               fqe,             qeo,
     #               aa,              fqa,             qao,
     #               vca,
     #               ab,              fqb,             qbo,
     #               vcb,
     #               eag(mxna1),      denag(mxna),     eago(mxna),
     #               qago(mxna),
     #               ebg(mxnb1),      denbg(mxnb),     ebgo(mxnb),
     #               qbgo(mxnb),
     #               nag,             nbg
      dimension      dr(4)
      save           mstep
      data mstep/    500/
c*****Statement function for ablated particle density.
      s(r1,r2)=(4.0/3.0)*pi*(r2**3-r1**3)*2.0*denm/dvol
c*****Initialize for one step through cell.
      newcel=1
      told=t
      tnew=told+dt
      dts=dt
      nstep=0
      rp0=rp
      dden=0.0
      adcon=25.0
      temin=eion
c*****Set maximum delta(n)/n.
      fnmax=20.0
      fntmax=(te-temin)/(eion*2.0/3.0+temin)
      if(fntmax.le.0.0) fntmax=0.0
      fnmax=min(fnmax,fntmax)
      drp3=(3.0/(8.0*pi))*fnmax*dvol*(den/denm)
      rp3=rp**3
      if(drp3.lt.rp3) then
        rpmin=(rp3-drp3)**(1.0/3.0)
      else
        rpmin=0.0
      endif
      rdotmx=-(rp0-rpmin)/dt
      do 20 istep=1,mstep
c*****  Initialize intermediate runge-kutta parameters.
        rps=rp
        nstep=nstep+1
c*****  Advance pellet through time interval dts.
        do 10 i=1,4
          dden=s(rps,rp0)
c*****    Adiabatic self-limiting ablation for large perturbations.
          adfac=exp(-(dden/(adcon*den))**2)
          dden=(1.0-adfac)*dden
          dens=den+dden
          tes=(den*te-(2.0/3.0)*dden*eion)/dens
          if(tes.lt.eion) tes=eion
          if(neg.eq.1) then
            tfd=0.0
          else
c*****      Collisionless self-limiting ablation for multiple groups.
            dtold=tnew-told
            ce=sqrt(8.0*tes*xj7kv/pi/elemas)
            tfd=dtold*(ce/4.0)*2.0*pi*rcl**2/dvol
          endif
          if(kplabl.ne.2) then
            call pelrat(nout,newcel,tolplr,tolplc,
     #                  rps,tes,dens,tfd,rdot)
          elseif(kplabl.eq.2) then
            call pelmac(tolplr,rps,tes,dens,rdot)
          endif
          if(abs(rdot).gt.abs(rdotmx)) rdot=rdotmx
c*****    Update neutral cloud size.      
          areap=4.0*pi*rps**2
          endot=-2.0*denm*areap*rdot
          if(kplabl.eq.1) then
            rcl=rps+rclmin
            tcl=2.0*rcl/vpel
            areac=2.0*pi*rcl**2
            fioncn=endot*tcl/(areac*2.0*denm*rpel)/xrhoro
            fionc=(fionc+fioncn)/2.0
          endif
          dr(i)=dts*rdot
          if(i.le.2) then
            if((rp+dr(i)/2.0).lt.rpmin) dr(i)=2.0*(rpmin-rp)
            rps=rp+dr(i)/2.0
          else
            if((rp+dr(i)).lt.rpmin) dr(i)=rpmin-rp
            rps=rp+dr(i)
          endif
          if(i.eq.1) then
c*****      Check perturbation on background plasma.
            if(rps.lt.tolplr*rpel/2.0) rps=tolplr*rpel/2.0
            ddens=s(rps,rp)
            dnte=ddens*(2.0/3.0)*eion
            fte=2.0*(ddens+dnte/tes)/(dens+2.0*ddens)
            fdts=1.0
            if(fte.ne.0.0) fdts=tolplt/fte
            if(fdts.lt.1.0) then
c*****        Reduce time step size and try again.
              dts=0.9*fdts*dts
              go to 20
            endif
          endif
   10   continue
c*****  Completed step.
        drav=(dr(1)+2.0*(dr(2)+dr(3))+dr(4))/6.0
        rdotav=drav/dts
        if((rp+drav).lt.(tolplr*rpel))then
          dts=-rp/rdotav
          drav=-rp
        endif
        rp=rp+drav
        dden=s(rp,rp0)
        t=t+dts
        dts=tnew-t
        if((dts.le.xmachp*tnew).or.(rp.le.xmachp*rpel)) return
   20 continue
c*****Exceeded maximum number of steps in cell.
      write(nout,1010) mstep
      return
 1010 format(' error:pelrk4-exceeded max iterations. mstep=           ',
     #6x,i4)
      end
      subroutine inicon
c***********************************************************************
c*****INICON loads the common block containing physical constants and  *
c***** conversion constants.                                           *
c*****Last Revision:12/85 W.A.Houlberg and S.E.Attenberger ORNL.       *
c***********************************************************************
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
c*****Physical constants.
c*****velocity of light - (meter/second).
      clight=2.9979e+08
c*****Elementary charge - (coulomb).
      coulom=1.6022e-19
c*****Electron mass - (kilogram).
      elemas=9.1095e-31
c*****Permittivity of free space - (farad/meter).
      epsilo=8.8419e-12
c*****Proton mass - (kilogram).
      promas=1.6726e-27
c*****Permeability of free space - (henry/meter).
      xmuo=1.2566e-06
c*****Unit conversions.
c*****Joules per keV.
      xj7kv=1.6022e-16
      return
      end
      subroutine zincon
c***********************************************************************
c*****ZINCON loads the common block containing machine constants.      *
c*****Last Revision: 7/89 W.A.Houlberg and S.E.Attenberger ORNL.       *
c***********************************************************************
c      include 'comcon.inc'
c*****comcon-physics and machine constants
      real           clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero
      integer        imachn,          imachp,          lchar,
     #               lword
      common/comcon/ clight,          coulom,          elemas,
     #               epsilo,          pi,              promas,
     #               xj7kv,           xmachl,          xmachp,
     #               xmachs,          xmuo,            zero,
     #               imachn,          imachp,          lchar,
     #               lword
c*****Calculate pi for greatest accuracy.
      pi=acos(-1.0)
c*****Set zero for initializing arrays.
      zero=0.0
c*****Compute the relative machine precision. 
      xmachp=1.0
      test1=2.0
      do while(test1.gt.1)
        xmachp=xmachp/2.0
        test1=1.0+xmachp
      end do
      xmachp=2.0*xmachp
c*****Set the largest floating point number.
      xmachl=3.4e38
c*****Set the smallest floating point number.
      xmachs=1.2e-38
c*****Set the largest positive integer.
      imachp=32768
c*****Set the largest negative integer.
      imachn=-32767
c*****Set the number of bits per character.
      lchar=8
c*****Set the number of characters per word.
      lword=4
      return
      end
