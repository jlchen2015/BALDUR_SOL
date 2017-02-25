c@crplot.m
c
C*************** START FILE CPLOTR.BLK ; GROUP CPLOTR *************
C==============================================================
C  RECOPIED BY TBT 8/15/89
C  REV DMC NOV 1988
C   ADDED NTCORR AND LTWRIT
C   TO ALLOW POPLT2 TO CORRECT FOR TRANSP OUTPUTTING A FILE WITH
C   A NON-MONOTONIC TIME BASE
C
C  REV DMC JUNE 1988
C
C   EXPANDING LABELS:  32 CHARACTERS FOR LABEL FIELD,
C                      16 CHARACTERS FOR UNITS FIELD
C                      10 CHARACTERS FOR ITEM ABBREVIATION
C
C   NEW COMMON STRUCTURE NOT COMPATIBLE WITH THE OLD STRUCTURE
C   MOST ROUTINES IN RPLOT WILL HAVE TO CHANGE TO ACCOMODATE THE
C   LONGER LABELS.  ALSO, PREVIOUSLY, LABEL AND UNITS FIELDS WERE
C   COMBINED, I.E.
C            CHARACTER*10 LABELT(3,xxx)
C        ! FOR FUNCTION J:
C     (OLD)  LABELT(1,J)//LABELT(2,J)  LABEL FIELD, 20 CHARACTERS
C            LABELT(3,J)               UNITS FIELD, 10 CHARACTERS
C
C   NOW:
C            CHARACTER*32 LABELT(xxx)
C            CHARACTER*16 UNITST(xxx)
C        ! FOR FUNCTION J:
C     (NEW)  LABELT(J)                 LABEL FIELD, 32 CHARACTERS
C            UNITST(J)                 UNITS FIELD, 16 CHARACTERS
C
C   MANY SUBROUTINE CALLING ARGUMENTS WILL HAVE TO BE RECODED AS
C   A RESULT...
C
C--------------------------------------
C  REV D. MC CUNE  25 JUNE 1985
C     MODS TO SUPPORT ADAPTATION OF RPLOT TO BALDUR AS WELL AS
C  TRANSP.
C     USE OF 6 CHAR RUN IDS INSTEAD OF 4 CHAR RUN NUMBERS.
C     LONGER DATA FILENAMES.
C--------------------------------------------------------------
C  REV D. MC CUNE  24 JULY 1981
C     STARTED ADDING VARIABLES TO GENERALIZE NON-TIME 
C  COORDINATE OF PLOTTING VARIABLES TO HAVE NOT ONLY VARIABLE
C  LABELS/VALUES BUT VARIABLE NUMBER OF ZONES AS WELL.  ALSO
C  AN ASSOCIATION OF X-AXIS INDEX WITH A TIME-VARYING X-AXIS
C  VARIABLE FROM THE PLOT FILE WILL BE SUPPORTED
C  THE MEANING OF SOME OLD COMMON VARIABLES SHALL CHANGE.
C
C  PLOTR    D. MC CUNE    OCT 12 1979   PPPL
C        PLOTTING ROUTINE FOR TRANSP GRAPHICS OUTPUT
C           *VAX-11  VERSION #01**
C
C    *******    COMMON BLOCKS    ******
C
C    THIS FILE CONTAINS COMMON BLOCKS FOR TRANSP GRAPHICS 
C     OUTPUT SYSTEM, 
C
C    PROGRAMS:  RPLOT -- INTERACTIVE/BATCH TRANSP DATA ACCESS + PLOTTING
C              POPLOT -- POST-PROCESS ASCII TRANSP OUTPUT TO BINARY 
C                        FORMAT READABLE BY RPLOT
C              PLABEL -- GENERATE LABEL/MAP FILE FOR TRANSP OUTPUT
C              PLTRGN -- GENERATE CODE USED BY PLABEL AND TRANSP TO
C                        CREATE LABELED TRANSP OUTPUT
C
C    FILES:
C     ####TF.PLN    LABELING AND FILE ORGANIZATION INFORMATION
C                   (SEQUENTIAL ACCESS ASCII)
C     ####NF.PLN    SCALAR FUNCTIONS OF TIME OUTPUT BY TRANSP
C		    (SEQUENTIAL ACCESS BINARY, CONTAINING TIMES
C                   AND A VARIABLE NUMBER OF SCALAR FUNCTIONS)
C     ####MF.PLN    PROFILE FUNCTIONS OF TIME AND ADDITIONAL COORDINATE
C                   OUTPUT BY TRANSP, REFORMATTED BY POPLOT.  (DIRECT 
C                   ACCESS BINARY).
C
C=======================================================================
C  ALPHABETIZED DMC NOV 1988
C  INDEX OF COMMON VARIABLES:
C
C   ABB    10 CHARACTER ABBREVIATIONS FOR MULTIGRAPH PACKAGES
C   ABR    10 CHARACTER ABBREVIATIONS FOR PROFILE FUNCTIONS OF TIME
C          AND 1 ADDITIONAL COORDINATE
C   ABT    10 CHARACTER ABBREVIATIONS FOR SCALAR FCNS OF TIME
C
C   ADELT     IF KATFLG=1, AND THIS IS A MULTIPLOT VS. X (NOT TIME),
C             PLOT PROFILES AVERAGED OVER +/- ADELT SECONDS FROM THE
C             USER-SPECIFIED PLOTTING TIME
C
C------------------
C FOR VERY OLD TRANSP RUNS WITH TIME INDEPENDENT GEOMETRY, THE FOLLOWING
C 3 QUANTITIES ARE COMPUTED FROM RADIUS DATA READ IN FROM THE TF.PLN 
C FILE...
C
C   DAREA  CROSS-SECTIONAL AREA OF ZONE  CM**2
C   DRAV   WIDTH OF ZONE  CM
C   DVOL   VOLUME OF ZONE  CM**3
C
C IN NEWER RUNS, SUCH GEOMETRIC INFORMATION IS COMPUTED IN TRANSP AND
C WRITTEN TO OUTPUT AS RPLOT DATA FUNCTIONS WITH NAMES SUCH AS 'DVOL'
C 
C SEVERAL OTHER QUANTITIES FALL INTO THIS CATEGORY:  FORMERLY ASSUMED
C TIME INDEPENDENT, NOW CONSIDERED TIME DEPENDENT.  SEE NLTGEO LOGICAL
C SWITCH.
C------------------
C
C   FDIR   DIRECTORY WHERE RPLOT INPUT DATA (.PLN FILES) ARE LOCATED
C          OR BLANK IF THESE ARE IN THE CURRENT DEFAULT DIRECTORY
C          SEE ALSO LFDIR
C   FDISK  DISK WHERE RPLOT INPUT DATA FILES (.PLN FILES) ARE LOCATED
C          OR BLANK IF THESE ARE ON THE CURRENT DEFAULT DEVICE
C          SEE ALSO LFDISK
C
C   FILNC  FLAG WHETHER OR NOT FILENAMES ARE KNOWN-- POPLOT WORKS
C          BY EXTERNALLY ASSIGNING FILES TO LOGICAL UNIT NUMBERS
C
C   IDABS  PLOT SCALING CONTROLS -- ABSCISSAE
C   IDATE  CURRENT DATE (FORTRAN FORMAT)
C   IDORD  PLOT SCALING CONTROLS -- ORDINATE
C
C   IFUNB   LIST OF FUNCTION NUMBERS ASSOCIATED WITH EACH
C           MULTI-GRAPH.
C   IINTB   IINTB(IB)=0 MEANS MULTIGRAPH IB IS A PROFILE MULTIGRAPH
C                    =1 MEANS MULTIGRAPH IB IS A SCALAR MULTIGRAPH
C   INFB    INFB(J)= # OF CURVES ASSOCIATED WITH MULTI-GRAPH
C           PACKAGE NO. J
C
C   ITITLE  GENERIC PLOT LABEL
C
C   ITYPR   FCNS OF TIME AND RADIUS FLAG (ARRAY) INDICATING
C           WHETHER FCN IS DEFINED AT TRANSP ZONES OR AT
C           TRANSP BOUNDARIES
C           ... OR OTHER NON-TEMPORAL COORDINATE
C
C   KATFLG--  =1 ==> CALCULATE TIME AVERAGE FOR MULTIPLOTS
C                    VS. RADIUS; AVERAGE SEVERAL PROFILES
C                    TO GENERATE THE PROFILES GRAPHED
C             =0 ==> STANDARD OPERATION (JUST FETCH DATA AT
C                    REQUESTED TIME
C   
C   LABELR  32 CHARACTER LABEL, FCNS OF TIME AND ADDL COORD. (ARRAY)
C   LABELT   DITTO, SCALAR FCNS OF TIME
C   LABELB  32 CHARACTER LABEL 
C           FOR MULTI-GRAPH PACKAGES  (PACKAGES ENABLE THE
C           PLOTTING OF SEVERAL CURVES ON ONE SET OF AXES)
C
C THE FOLLOWING 3 ARE DEFINED IF NLTGEO=.TRUE., I.E. IF GEOMETRY
C IS TIME DEPENDENT:
C   LDAREA  FUNCTION NUMBER OF DATA FUNCTION CONTAINING D(AREA) VS
C           TIME AND FLUX ZONE INDEX
C   LDRAV   FUNCTION NUMBER OF DATA FUNCTION CONTAINING D(R)
C   LDVOL   FUNCTION NUMBER OF DATA FUNCTION CONTAINING D(VOLUME)
C
C   LFDIR   (SEE FDIR) LENGTH OF DIRECTORY NAME WHERE RPLOT INPUT FILES
C           ARE TO BE FOUND; 0 FOR CURRENT DEFAULT DIRECTORY
C   LFDISK  (SEE FDISK) LENGTH OF DISK NAME WHERE RPLOT INPUT FILES
C           ARE TO BE FOUND; 0 FOR CURRENT DEFAULT DISK
C   LRUNID  LENGTH OF RUN ID (NO. OF CHARACTERS)
C
C   (SEE ALSO NLSENT= NUMBER OF INDEXED PLOTS SO FAR)...
C   (THIS IS TO SUPPORT THE RPLOT PLOT INDEXING FEATURE:  ALL RPLOT
C   PLOTS HAVE PAGE NUMBERS.  AT THE END OF AN RPLOT SESSION AN INDEX
C   CORRELATING PLOT LABELS WITH PAGE NUMBERS MAY BE GENERATED)
C
C    LSINDX(NLSIZ)-- ALPHABETIC-ORDERING ARRAY OF LABELS OF PLOTTED DATA
C           FOR GENERATING INDEX OF RPLOT GENERATED PLOTS FOR DISPLAY
C    LSLABL(NLSIZ)-- LABELS OF PLOTS MADE SO FAR (=NLSENT)
C    LSUNTS(NLSIZ)-- UNITS OF PLOTS MADE SO FAR (=NLSENT)
C    LSPAGI(NLSIZ)-- FIRST PAGE LABELED LSLABL(J) IS # LSPAGI(J)
C    LSPAGL(NLSIZ)-- PAGES LSPAGI(J) -- LSPAGI(J)+LSPAGL(J)-1 HAVE
C            LABEL LSLABL(J)
C
C    LSURF (IF NLTGEO IS .TRUE.) INDEX TO DATA FUNCTION CONTAINING
C           FLUX SURFACES VS FLUX SURFACE INDEX AND TIME
C
C    LTWRIT  (POPLOT PROGRAM ONLY) INTERNAL COMMUNICATIONS FOR
C           DESELECTING OUT-OF-SEQUENCE TIME RECORDS
C           SEE ALSO NTCORR=NO. OF OUT-OF-SEQUENCE RECORDS TO DROP
C
C    MAXFOT,MAXFXT,MAXMGP,MAXXVR,MAXXPT,MAXTPT -- ARRAY LIMITS:
C       MAX FCNS OF TIME, MAX PROFILE FCNS, MULTIGRAPHS, X AXES,
C       X AXIS POINTS, TIME PTS.
C
C   MFILN   'MF' FILE NAME
C
C   NBAL NUMBER OF MULTI-GRAPH PACKAGES AVAILABLE
C
C   NBLIM    BUFFER SIZE LIMIT-- DATA BUFFER IN MEMORY WHERE ALL DATA
C    FUNCTIONS WHICH HAVE BEEN READ FROM DISK ARE STORED
C
C   NFILN   'NF' FILE NAME
C
C   NFR  *USE IS HISTORICAL* NUMBER OF PROFILE FUNCTION "RECORDS"
C   NFT  NUMBER OF SCALAR FCNS OF TIME
C   NFT0  "ORIGINAL" NUMBER OF SCALAR FCNS OF TIME
C    DIFFERENCE BETWEEN NFT AND NFT0 INDICATES PRESENCE OF USER DEFINED
C    FUNCTIONS
C   NFTX  NUMBER USED IN GATHERING USER DEFINED SCALAR FUNCTIONS:
C    THESE ARE DEFINED OUTSIDE THE RPLOT SCALAR FUNCTION PLOTTING
C    CODE; EACH TIME THE SCALAR PLOTTING CODE IS ENTERED, ANY NEW
C    USER DEFINED FUNCTIONS ARE "GATHERED" AND NFTX IS RESET.  USER
C    DEFINED FUNCTIONS ARE GOTTEN OUTSIDE OF THE SCALAR CODE EITHER
C    BY READING A DATA UFILE OR BY EXTRACTING A SLICE FROM A PROFILE
C    FUNCTION, OR, WITH THE RPLOT CALCULATOR
C
C   NFX ... (PLTRGN) THE NUMBER OF FUNCTIONS DEFINED FOR EACH X
C    AXIS DEFINITION
C       ... (RPLOT) ID NO. OF DATA FUNCTION CONTAINING THE X
C    COORDINATE
C
C   NFXT ... TOTAL # OF FCNS OF TIME + 1 ADDL. COORD.
C   NFXT0 ... ORIGINAL TOTAL NFXT IN RUN RESULTS DATABASE.  IF NFXT
C    .GT. NFXT0, USER DEFINED PROFILE FUNCTIONS ARE PRESENT.  THESE
C    ARE READ FROM UFILES WRITTEN BY RPLOT E.G. FROM OTHER RELATED 
C    TRANSP RUN DATABASES, OR, COMPUTED WITH THE RPLOT CALCULATOR
C
C    NLSENT-- # OF DISTINCT-LABELED GRAPH GROUPS, SAVED SO THAT
C      AN INDEX OF PLOTS MADE CAN OPTIONALLY BE GENERATED AT THE END
C      OF THE RPLOT SESSION.  SEE LSPAGI, ET AL.
C
C-------
C   NLTGEO
C
C  SUPPORT TIME VARYING GEOMETRY
C  NLTGEO = .TRUE. TO INDICATE TIME VARYING GEOMETRY
C  DVOL,DAREA,DRAV,SURF-- DV,DA,DL, SURF AREAS TO USE IN GEOMETRIC
C    OPERATIONS IF NLTGEO=.FALSE.; IF NLTGEO=.TRUE. CORRESPONDING
C    QUANTITIES ARE READ FROM DATA FILE
C  IF NLTGEO=.TRUE. LDVOL,...,LSURF GIVE LOCATION IN MF FILE
C
C--------
C---
C  NLXFOT(J)=.TRUE. INDICATES THAT THE JTH NONTEMPORAL COORDINATE
C    IS INDEED A FCN OF TIME -- AND MUST BE READ FROM THE MF FILE
C     NLXFOT(J)=.FALSE. MEANS X AXIS IS CONSTANT, STORED IN XARRY
C  NLXFTD(J)=.TRUE. MEANS THE ORIGINAL (DEFAULT) X AXIS IS A FCN OF
C    TIME AND MUST BE READ FROM THE MF FILE
C           =.FALSE. MEANS THE ORIGINAL IS CONSTANT, STORED IN XARRY
C  NLXMON(J)=.TRUE. VERIFIES THAT JTH NONTEMPORAL COORDINATE IS 
C    A MONOTONICALLY INCREASING FUNCTION AT ALL TIMES
C  
C  THE X AXIS MAY BE INTERACTIVELY REDEFINED BY THE USER TO BE
C    ANY FCN DEFINED WITH RESPECT TO THE ORIGINAL (DEFAULT) X AXIS.
C
C  SEE XNDABB,XF,XFLAB,XFLABU ...
C
C  NLXVAR FLAGS POSSIBLE TIME VARYING GEOMETRY (CF FIXGEO ROUTINE)
C---
C  NOWNRS IS THE NUMBER OF PRIVELAGED "OWNERS" OF TRANSP RUNS
C  WHO MAY SAVE MODIFIED TF.PLN FILES
C
C    NPAGEG-- CURRENT PAGE # FOR PLOT OUTPUT -- REFERRED TO IN
C      RPLOT GENERATED DISPLAY INDEX
C
C     INTEGER NRECX(1...NXR)  # OF MF FILE RECORDS PER FUNCTION
C      DEFINED WITH RESPECT TO SPECIFIED X-AXIS ... SEE NZONEX
C      AND NFR ... PERTAINS TO "OLD" MF FILE FORMAT--
C ... DMC 1988 ... THE TRANSP PLOT DATA POSTPROCESSING PROGRAM
C CONVERTS TRANSP ASCII OUTPUT TO AN INTERMEDIATE FILE FORMAT
C A BINARY FILE WITH FIXED LENGTH RECORDS STORING ALL PROFILE DATA
C AT TIME T1, THEN TIME T2, ETC.  THIS IS THE **OLD** MF FILE FORMAT
C STILL IN THE ARCHIVES FOR OLDER TRANSP RUNS.  THEN ON A SECOND PASS
C THIS DATA IS CONVERTED TO A REFORMATTED BINARY FILE, THE **NEW** MF
C FILE FORMAT, WITH LARGER FIXED LENGTH RECORDS, ORGANIZED CONTAINING
C THE FILE RECORD TIMES T1, T2, ... TN, THEN THE COMPLETE TIME-X 
C VARIATION OF PROFILE FUNCTION F1, THEN F2, ... UP TO NFXT0'TH F
C PROFILE FUNCTION IN THE FILE, THE RUN RESULT DATABASE.
C  RPLOT WILL WORK FOR BOTH OLD AND NEW FORMAT MF FILES BUT THE
C  NEW FORMAT YIELDS FASTER ACCESS TIMES.  SEE ALSO VARIABLES NFR
C  AND NZONEX WHICH ARE USED ESPECIALLY IN ACCESSING THE OLD FORMAT
C  MF FILE (STILL USED TODAY IN THE PLOT POSTPROCESSING PROGRAM)
C
C    NRLIM --- MAX NO. OF PTS IN NON-TEMPORAL INDEPENDENT COORDINATE
C---
C    NROFFF -- ADDRESSING IN OLD MF FILE FORMAT
C  TO ACCOMODATE VARIABLE-SIZE X-AXIS, THE OFFSET OF RECORDS
C  FOR A GIVEN FCN OF (X,T) IS NO LONGER GIVEN BY THE FCN NUMBER.
C  SO THE FOLLOWING ARRAYS ARE PROVIDED TO SPECIFY THE OFFSET
C   NROFFF(J)-- OFFSET FOR FIRST RECORD FOR FCN J
C     THE JTH FCN'S VARIATION WITH RESPECT TO ITS INDEPENDANT
C    NONTEMPORAL COORDINATE, AT THE KTH TIME, IS LOCATED IN
C    THE MF FILE, STARTING AT RANDOM ACCESS RECORD
C    IREC1=(K-1)*(NRF+1) + NROFFF(J)
C    AND CONTINUING TO 
C    IREC2=IREC1+NRECX(ITYPR(J)) -1
C  THE NUMBER OF RECORDS BEING CHARACTERISTIC OF THE NUMBER OF
C  PTS IN THE NONTEMPORAL COORDINATE
C    NROFFX -- SIMILAR ADDRESSING FOR X AXIS DATA
C---
C   NRUN    TRANSP RUN NUMBER ** SUPERSEDED BY 6 CHAR RUNID **
C
C   NSCALE  NO. OF SCALING DEFAULT RULES SAVED
C   NSCALC  SCALING DEFAULTS SWITCH ARRAY
C
C   NSHOT   TRANSP RUN DATA SHOT NUMBER
C
C   NTCORR (POPLOT) NUMBER OF OUT OF SEQUENCE TIME RECORDS TO DROP
C
C   NTLIM   MAX NO. OF TIME PTS.
C
C   NTR  NUMBER OF TIME PTS, FCNS OF RADIUS AND TIME
C   NTT  NUMBER OF TIME PTS, FCNS OF TIME
C
C   NXR  NUMBER OF KNOWN NON-TEMPORAL INDEPENDENT COORDINATES
C
C   NZONES  NUMBER OF RADIAL ZONES
C        *7-24-81 NUMBER OF WORDS IN MF RANDOM ACCESS FILE
C        RECORDS (RECORDSIZE) FOR OLD MF FILE FORMAT
C   NZONEX
C     INTEGER NZONEX(1...NXR) # OF PTS IN FUNCTION FOR SPEC.
C      X AXIS.  NOTE NRECX=(NZONEX-1)/NFR  + 1
C
C   OWNER
C   OWNERS
C   OWNUIC  SYMBOLS USED TO DETERMINE IF CURRENT USER OF RPLOT
C     IS "PRIVELEGED" TO HAVE WRITE ACCESS TO THE TF.PLN FILE
C     E.G. TO PERMANENTLY DEFINE A NEW MULTIGRAPH ASSOCIATION OR
C     LABEL CHANGE
C
C  PFLAB, PFLABU USED TO SET THE CORRECT PLOT LABEL -- E.G. WITH UNITS
C    TRANSFORM DUE TO INTEGRAL OPERATORS -- FOR THE UPCOMING PLOT
C
C  PLTABB -- ABBREVIATION (RPLOT DATA/MULTIGRAPH ID) FOR UPCOMING PLOT
C
C----------------
C   SOME STUFF BEING PHASED OUT DUE TO INTRODUCTION OF TIME-VARYING
C    GEOMETRY.  SEE FIXGEO SUBROUTINE
C
C   RBOUN   TRANSP RADIAL ZONE BOUNDARIES (ARRAY)
C      *7-24-81  NOT USED
C   RMINOR  PLASMA MINOR RADIUS OF TRANSP RUN
C   RMAJOR  PLASMA MAJOR RADIUS
C   RZON    TRANSP RADIAL ZONE CENTERS (ARRAY)
C      *7-24-81  NOT USED
C----------------
C   RSCALC  PLOT SCALING DEFAULTS INFORMATION VECTOR
C
C   RUNID   6 CHAR RUN ID OF RUN BEING EXAMINED WITH RPLOT
C   RUNLB2  EXTENDED LABEL "TOK.YY NNNN" FOR PLOTS
C
C   SSELEC  SUBSTRING SELECTOR OPTIONALLY USED WHEN GENERATING LISTS
C     OF RPLOT NAMES
C
C   SURF    FLUX SURFACE SURFACE AREAS *TIME INDEPENDENT GEOMETRY RUNS*
C           SEE NLTGEO, AND DVOL, ETC.
C
C   SXMIN,SXMAX  PLOT SCALE DEFAULT DATA
C   SYMIN,SYMAX  MORE PLOT SCALE DEFAULT DATA
C 
C   TFILN   'TF' FILE NAME
C
C   TIME     ARRAY FOR TIME VALUES-- FCNS OF TIME
C   TIME3    ARRAY FOR TIME VALUES-- FCNS OF TIME AND ADDL COORDINATE
C
C   TIMLAB   ASCII LABEL FOR TIME
C   TIMUNS   UNITS FOR TIME
C
C   UNITSB   PHYSICAL UNITS LABEL 16 CHARACTERS FOR MULTIGRAPHS
C   UNITSR   PHYSICAL UNITS LABEL 16 CHARS FOR PROFILE FUNCTIONS
C   UNITST   PHYSICAL UNITS LABEL 16 CHARS FOR SCALAR FUNCTIONS
C
C   WORK1,WORK2  ... WORK ARRAYS
C
C    XARRY(--,--)  VALUES OF INDEPENDANT VARIABLES FOR 
C                  PLOTTING-- IF TIME INDEPENDENT
C
C  ARRAY XF AND LABEL ARRAY XFLAB, XFLABU ARE USED TO SPECIFY THE 
C    (CURRENTLY IN USE) X AXIS TO PLOTTING ROUTINES,
C    XFABB IS THE ABBREVIATION DISPLAYED AS A PLOT LABEL
C    XFPABB IS ANOTHER ABBREVIATION PLOT LABEL
C
C    XLAB(--)  32 CHAR LABEL FOR EACH INDEPENDANT VARIABLE
C    XLABU(--) 16 CHAR PHYSICAL UNITS LABEL FOR EACH INDEP. COORD.
C
C    XLABD,XLABDU  ARE UTILITY LABELS FOR PASSING TO PLOT ROUTINES
C
C     CHARACTER*5 XNDABB(1...NXR) -- 10 CHARACTER ABBREVIATION
C       GIVING ASSOCIATION OF X AXIS TO FUNCTION IN MF FILE
C       WHICH DEFINES THE X AXIS IN PHYS. UNITS AS A FCN OF TIME
C
C  THE CHARACTER ARRAY XNDABB STORES THE ABBREVIATION ID OF THE 
C    DEFAULT X AXIS
C
C-------------------------------------------------------------------
C
C  CPLOTR LIMITATIONS HAVE BEEN QUANTIZED IN BLOCK TRPLIM
C   VARIABLES MAXFOT ETC.  SEE BLOCK-DATA SUBROUTINE CPLSET *****
C     THESE MAXIMA ARE DETERMINED BY THE SIZES OF ARRAYS 
C   DECLARED IN THIS FILE ****
C
C
C-------------------------------------------------------------------
C  DECLARATIONS
C  INDEX BUFFER SIZE
	PARAMETER (NLSIZ=1000)
C  PLOTTING BUFFER SIZE--
	PARAMETER (NR0=200)    ! MAX NO. NON-TEMPORAL AXIS POINTS
	PARAMETER (NTIME=4096) ! MAX NO. OF TIME POINTS
C  NUMBER OF FCNS AND PACKAGES LIMITS
	PARAMETER (NAXFOT=750)    ! MAX NO. OF SCALAR FUNCTIONS
	PARAMETER (NAXFXT=1500)   ! MAX NO. OF PROFILE FUNCTIONS
	PARAMETER (NAXMGP=500)    ! MAX NO. OF MULTIGRAPH GROUPINGS
	PARAMETER (NAXXVR=50)     ! MAX NO. OF NON-TIME COORDS DEFINED
	PARAMETER (NAXXVT=NAXXVR+2)    ! MAX NO. OF COORDS INCL. TIME
C  MAX NO OF MOMENTS AND NUMBER OF CONTOUR PTS, MOMENTS PLOTTING
	PARAMETER (NAXMOM=20)
	PARAMETER (NAXMMP=80)
C  NO OF FIXED PTS FOR 3D PLOTS REQUIRING INTERPOLATED FIXED X AXIS
	PARAMETER (NAXFIX=41)
C
	COMMON/TRPL01/LABELR,LABELT,LABELB,UNITSR,UNITST,UNITSB,
     >        ABR,ABT,ABB,RUNID
C
	COMMON/TRPL02/ITYPR,NBAL,IINTB,INFB,IFUNB,
     >        RZON,RBOUN,NRUN,NSHOT,NZONES,RMINOR,RMAJOR,
     >        NFT0,NFT,NFTX,NFR,NTT,NTR,NROFFF,NOWNRS,
     >        LRUNID,LFDISK,LFDIR
C
	COMMON/TRPL03/ TFILN,MFILN,NFILN,FDISK,FDIR
     >                ,TIMLAB,TIMUNS,RUNLB2,OWNER,FILNC
C
	COMMON/TRPL04/ TIME,TIME3,NTLIM,NBLIM,NRLIM,WORK1,WORK2
C
	COMMON/TRPL05/ IDATE,ITITLE
C
	COMMON/TRPL07/IDORD(NAXXVT),IDABS(NAXXVT),NSCALE,
     >     SXMIN(NAXXVT),SXMAX(NAXXVT),SYMIN(NAXXVT),SYMAX(NAXXVT),
     >     NSCALC(2,NAXXVT),RSCALC(4,NAXXVT),NAXISC(NAXXVT)
C
	COMMON/TRPL08/KATFLG,ADELT
C
	COMMON/TRPL09/NXR,XARRY,XF,NROFFX,NLXFOT,NLXMON,NLXFTD,
     >     NLXVAR,NFX,NFXT,NFXT0,NRECX,NZONEX
C
	COMMON/TRPL10/XLAB,XLABD,XNDABB,XFLAB,XFABB,XFPABB,PLTABB,
     >     XLABU,XLABDU,XFLABU,PFLAB,PFLABU
C
	COMMON/TRPL11/NPAGEG,NLSENT,LSPAGI,LSPAGL,LSINDX
C
	COMMON/TRPL12/LSLABL,LSUNTS
C
	COMMON/TRPLIM/MAXFOT,MAXFXT,MAXMGP,MAXXVR,MAXXPT,MAXTPT
C
	COMMON/TRPLGO/NLTGEO,DVOL,DAREA,DRAV,SURF,LDVOL,LDAREA,
     >     LDRAV,LSURF
C
	COMMON/TRPLCL/ SSELEC
C
	COMMON/TRPRIV/ OWNERS,OWNUIC
C
	COMMON/TRPFUJ/ LTWRIT,NTCORR
C
C---------------
	CHARACTER*32 XLAB(NAXXVR),XLABD(NAXXVR),XFLAB,PFLAB
C
	CHARACTER*16 XLABU(NAXXVR),XLABDU(NAXXVR),XFLABU,PFLABU
C
	CHARACTER*20 OWNERS(10),OWNUIC(2,5,10)
C
	CHARACTER*10 XNDABB(NAXXVR),XFABB,XFPABB,PLTABB
C
	CHARACTER*6 RUNID
	CHARACTER*9 IDATE
	CHARACTER*60 ITITLE
C
	CHARACTER*32 TIMLAB
	CHARACTER*16 TIMUNS
	CHARACTER*64 TFILN,MFILN,NFILN,FDISK,FDIR
	CHARACTER*12 RUNLB2
	CHARACTER*20 OWNER
	CHARACTER*1 FILNC
C
	CHARACTER*32 LABELR(NAXFXT),LABELT(NAXFOT),
     >             LABELB(NAXMGP)
	CHARACTER*16 UNITSR(NAXFXT),UNITST(NAXFOT),
     >             UNITSB(NAXMGP)
	CHARACTER*10 ABR(NAXFXT),ABT(NAXFOT),ABB(NAXMGP)
C
	CHARACTER*32 LSLABL(NLSIZ)
	CHARACTER*16 LSUNTS(NLSIZ)
C  FCN/MG NAME LISTING SELECTOR SUBSTRING
	CHARACTER*10 SSELEC
C
	REAL RZON(NR0),RBOUN(NR0)
	REAL XARRY(NR0,NAXXVR),XF(NR0)
	REAL DVOL(NR0),DAREA(NR0),DRAV(NR0),SURF(NR0)
C
	REAL TIME(NTIME),TIME3(NTIME),WORK1(NTIME),WORK2(NTIME)
C
	INTEGER NFX(NAXXVR)
     >     ,NRECX(NAXXVR),NZONEX(NAXXVR),NROFFX(NAXXVR),
     >     NROFFF(NAXFXT)
C
	INTEGER ITYPR(NAXFXT)
     >     ,IINTB(NAXMGP),INFB(NAXMGP),IFUNB(15,NAXMGP)
C
	INTEGER LSPAGI(NLSIZ),LSPAGL(NLSIZ),LSINDX(NLSIZ)
C
	LOGICAL NLTGEO
	LOGICAL NLXFOT(NAXXVR),NLXMON(NAXXVR),NLXFTD(NAXXVR)
	LOGICAL NLXVAR
	LOGICAL LTWRIT(NTIME)
C
C*************** END FILE CPLOTR.BLK ; GROUP CPLOTR *************
c
c--------1---------2---------3---------4---------5---------6---------7-c