!| %
!| %  This is a LaTeX ASCII file.  To typeset document type: latex theory
!| %  To extract the fortran source code, obtain the utility "xtverb" from
!|  0lenn Bateman (bateman@plasma.physics.lehigh.edu) and type:
!| 0tverb < theory.tex > theory.f
!| %
!| % The following lines control how the LaTeX document is typeset
!|
!| \documentstyle{article}
!| \headheight 0pt \headsep 0pt  \topmargin 0pt  \oddsidemargin 0pt
!| \textheight 9.0in \textwidth 6.5in
!| \begin{document}		    0.000000E+00nd of preamble and beginning of text.
!|
!| \begin{center}
!| \Large {\bf Multi-Mode Transport Model mmm99} \\
!| \vspace{1pc} \normalsize
!| Glenn Bateman, Arnold H.~Kritz \\
!|  Lehigh University Physics Department \\
!| 16 Memorial Drive East, Bethlehem PA 18015 \\
!| bateman@plasma.physics.lehigh.edu \\
!| kritz@plasma.physics.lehigh.edu \\
!| Ping Zhu \\
!| UT Austin \\
!| pzhu@physics.utexas.edu
!| \end{center}
!|
!| This file documents a subroutine called {\tt mmm99}, which computes
!| plasma transport coefficients using the Multi-Mode transport model. The routine is a combination of routines {\tt mmm95} and {\tt mmm98d}, which provides switches to the different models contained in those 2 earlier routines. Also introduced is a switch between 2 models of ${\bf E}\times{\bf B}$ flow shear stabilization mechanism.
!|
c@mmm99.tex  .../baldur/code/bald/mmm99.tex
c rgb 2-may-02 added diagnostic arrays thitem ... thzitg to agument list
c  tho  23-jun-00 add weiland18 for ITG
c  pzhu 06-jan-00 add diagnostic output from Weiland model for test14,16,etc.
c  pzhu 23-dec-99 coefficient and exponent of HH parameter are inputed as zcthery(135,136);
c  pzhu 23-dec-99 add transition function profile to drift-alfven mode
c  pzhu 09-dec-99 change lswitch, cswitch to ilthery, zcthery;
c  pzhu 28-oct-99 add ETG mode and Horton's model
c  pzhu 28-sep-99 merge mmm95 and mmm98d; add Upsilons factor to coefficients
c--------1---------2---------3---------4---------5---------6---------7-c
c
        subroutine mmm99 (
     &   rminor,  rmajor,   elong,    delta
     & , dense,   densh,    densimp,  densfe
     & , xzeff,   tekev,    tikev,    q,       btor
     & , avezimp, amassimp, amasshyd, aimass,  wexbs,   yexbs
     & , grdne,   grdni,    grdnh,    grdnz,   grdte,   grdti,  grdq
     & , thiig,   thdig,    theig,    thzig
     & , thirb,   thdrb,    therb,    thzrb
     & , thikb,   thdkb,    thekb,    thzkb
     & ,                    theeg
     & ,                    thetb
     & , thitem,  thdtem,   thetem,   thztem
     & , thiitg,  thditg,   theitg,   thzitg
     & , gamma,   omega,    difthi,   velthi,  vflux
     & , matdim,  npoints,  nprout,   lprint,  iknthe,  nerr
     & , lsuper,  lreset,   lswitch,  cswitch
     & , fig,     frb,      fkb,      feg
     & , lig,     lrb,      lkb,      lexbs,   letg,   ldif
     & , em)
c
c
c    All the following 1-D arrays are assumed to be defined on flux
c    surfaces called zone boundaries where the transport fluxes are
c    to be computed.  The number of flux surfaces is given by npoints
c    (see below).  For example, if you want to compute the transport
c    on only one flux surface, set npoints = 1.
c
c  Input arrays:
c  -------------
c
c  rminor(jz)   = minor radius (half-width) of zone boundary [m]
c  rmajor(jz)   = major radius to geometric center of zone bndry [m]
c  elong(jz)    = local elongation of zone boundary
c  delta(jz)    = local triangularity of zone boundary
c
c  dense(jz)    = electron density [m^-3]
c  densh(jz)    = sum over thermal hydrogenic ion densities [m^-3]
c  densimp(jz)  = sum over impurity ion densities [m^-3]
c  densfe(jz)   = electron density from fast (non-thermal) ions [m^-3]
c
c  xzeff(jz)    = Z_eff
c  tekev(jz)    = T_e (electron temperature) [keV]
c  tikev(jz)    = T_i (temperature of thermal ions) [keV]
c  q(jz)        = magnetic q-value
c  btor(jz)     = ( R B_tor ) / rmajor(jz)  [tesla]
c
c  avezimp(jz)  = average density weighted charge of impurities
c               = ( sum_imp n_imp Z_imp ) / ( sum_imp n_imp ) where
c                 sum_imp = sum over impurity ions with charge state Z_imp
c
c  amassimp(jz) = average density weighted atomic mass of impurities
c               = ( sum_imp n_imp M_imp ) / ( sum_imp n_imp ) where
c                 sum_imp = sum over impurity ions, each with mass M_imp
c
c  amasshyd(jz) = average density weighted atomic mass of hydrogen ions
c               = ( sum_hyd n_hyd M_hyd ) / ( sum_hyd n_hyd ) where
c                 sum_hyd = sum over hydrogenic ions, each with mass M_hyd
c
c  aimass(jz)   = mean atomic mass of thermal ions [AMU]
c               = ( sum_i n_i M_i ) / ( sum_i n_i ) where
c                 sum_i = sum over all ions, each with mass M_i
c
c  wexbs(jz)    = Hahm-Burrel ExB shearing rate in [rad/s]
c  yexbs(jz)    = Hamaguchi-Horton ExB shearing parameter []
c
c    All of the following normalized gradients are at zone boundaries.
c    r = half-width, R = major radius to center of flux surface
c
c  grdne(jz) = -R ( d n_e / d r ) / n_e
c  grdni(jz) = -R ( d n_i / d r ) / n_i
c  grdnh(jz) = -R ( d n_h / d r ) / n_h
c  grdnz(jz) = -R ( d Z n_Z / d r ) / ( Z n_Z )
c  grdte(jz) = -R ( d T_e / d r ) / T_e
c  grdti(jz) = -R ( d T_i / d r ) / T_i
c  grdq (jz) =  R ( d q   / d r ) / q    related to magnetic shear
c
c  where:
c    n_i     = thermal ion density (sum over hydrogenic and impurity)
c    n_h     = thermal hydrogenic density (sum over hydrogenic species)
c    n_Z     = thermal impurity density,  Z = average impurity charge
c                      sumed over all impurities
c
c  Output:
c  -------
c
c    The following effective diffusivities represent contributions
c    to the total diffusivity matrix (difthi and velthi given below)
c    from each of the models that contribute to the Multi-Mode model.
c    Generally, these arrays are used for diagnostic output only.
c
c  thiig(jz) = ion thermal diffusivity from the Weiland model
c  thdig(jz) = hydrogenic ion diffusivity from the Weiland model
c  theig(jz) = elelctron thermal diffusivity from the Weiland model
c  thzig(jz) = impurity ion diffusivity from the Weiland model
c
c  thirb(jz) = ion thermal diffusivity from resistive ballooning modes
c  thdrb(jz) = hydrogenic ion diffusivity from resistive ballooning modes
c  therb(jz) = elelctron thermal diffusivity from resistive ballooning modes
c  thzrb(jz) = impurity ion diffusivity from resistive ballooning modes
c
c  thikb(jz) = ion thermal diffusivity from kinetic ballooning modes
c  thdkb(jz) = hydrogenic ion diffusivity from kinetic ballooning modes
c  thekb(jz) = elelctron thermal diffusivity from kinetic ballooning modes
c  thzkb(jz) = impurity ion diffusivity from kinetic ballooning modes
c
c  thitem(jz) = ion thermal diffusivity from TEM (diagnostic output)
c  thdtem(jz) = hydrogenic ion diffusivity from TEM (diagnostic output)
c  thetem(jz) = elelctron thermal diffusivity from TEM (diagnostic output)
c  thztem(jz) = impurity ion diffusivity from TEM (diagnostic output)
c
c  thiitg(jz) = ion thermal diffusivity from ITG (diagnostic output)
c  thditg(jz) = hydrogenic ion diffusivity from ITG (diagnostic output)
c  theitg(jz) = elelctron thermal diffusivity from ITG (diagnostic output)
c  thzitg(jz) = impurity ion diffusivity from ITG (diagnostic output)
c
c  theeg(jz) = elelctron thermal diffusivity from ETG mode
c
c    The following are growth rates and mode frequencies from the
c    Weiland model for drift modes such as ITG and TEM.
c    These arrays are intended for diagnostic output.
c
c  gamma(jm,jz) = growth rate for mode jm at point jz ( 1/sec )
c  omega(jm,jz) = frequency for mode jm at point jz ( radians/sec )
c
c    All of the transport coefficients are given in the following two
c    matricies for diffusion difthi and convection velthi in MKS units.
c    See the LaTeX documentation for difthi and velthi just below.
c
c    NOTE:  difthi and velthi include all of the anomalous transport.
c    There are no additional contributions to the heat fluxs from
c    charged particle convection.
c
c  difthi(j1,j2,jz) = full matrix of anomalous transport diffusivities
c  velthi(j1,jz)    = convective velocities
c  vflux(j1,jz)     = flux matrix
!|
!| The full matrix form of anomalous transport has the form
!| $$ \frac{\partial}{\partial t}
!|  \left( \begin{array}{c} n_H T_H  \\ n_H \\ n_e T_e \\
!|     n_Z \\ n_Z T_Z \\ \vdots
!|     \end{array} \right)
!|  = - \nabla \cdot
!| \left( \begin{array}{l} {\rm vFlux}_1 \; n_H T_H \\
!|  {\rm vFlux}_2 \; n_H \\
!|  {\rm vFlux}_3 \; n_e T_e \\
!|  {\rm vFlux}_4 \; n_Z \\
!|  {\rm vFlux}_5 \; n_Z T_Z \\
!|  \vdots \end{array} \right)
!|  + \left( \begin{array}{c} S_{T_H} \\ S_{n_H} \\ S_{T_e} \\
!|     S_{n_Z} \\ S_{T_Z} \\ \vdots
!|     \end{array} \right)
!| $$
!| $$
!|  = \nabla \cdot
!| \left( \begin{array}{llll}
!| D_{1,1} n_H & D_{1,2} T_H & D_{1,3} n_H T_H / T_e \\
!| D_{2,1} n_H / T_H & D_{2,2} & D_{2,3} n_H / T_e \\
!| D_{3,1} n_e T_e / T_H & D_{3,2} n_e T_e / n_H & D_{3,3} n_e & \vdots \\
!| D_{4,1} n_Z / T_H & D_{4,2} n_Z / n_H & D_{4,3} n_Z / T_e \\
!| D_{5,1} n_Z T_Z / T_H & D_{5,2} n_Z T_Z / n_H &
!|         D_{5,3} n_Z T_Z / T_e \\
!|  & \ldots & & \ddots
!| \end{array} \right)
!|  \nabla
!|  \left( \begin{array}{c}  T_H \\ n_H \\  T_e \\
!|    n_Z \\  T_Z \\ \vdots
!|     \end{array} \right)
!| $$
!| $$
!|  + \nabla \cdot
!| \left( \begin{array}{l} {\bf v}_1 \; n_H T_H \\ {\bf v}_2 \; n_H \\
!|    {\bf v}_3 \; n_e T_e \\
!|    {\bf v}_4 \; n_Z \\ {\bf v}_5 \; n_Z T_Z \\
!|     \vdots \end{array} \right) +
!|  \left( \begin{array}{c} S_{T_H} \\ S_{n_H} \\ S_{T_e} \\
!|     S_{n_Z} \\ S_{T_Z} \\ \vdots
!|     \end{array} \right) $$
!| Note that all the diffusivities are in units of m$^2$/sec while the
!| convective velocities and vfluxes are in units of m/sec.
!|
!| WARNING:  Do not add separate convective transport terms to this
!| anomalous transport model.  All the anomalous transport
!| predicted by this Multi-Mode model is contained
!| in the diffusion coefficients {\tt difthi} and {\tt velthi} given
!| above.
!|
c
c  Input integers:
c  ---------------
c
c  matdim  = first and second dimension of transport matricies
c            difthi(j1,j2,jz) and velthi(j1,jz) and the first
c            dimension of gamma and omega.  matdim must be at least 5
c
c  npoints = number of values of jz in all of the above arrays
c
c  nprout  = output unit number for long printout
c
c  nerr    = 0 on input; returning with value .ne. 0 indicates error
c
c  Input switches
c  --------------
c
c  lprint      controls the amount of printout (0 => no printout)
c              higher values yield more diagnostic output
c  iknthe      print flag (=3 -> print)
c
c  lsuper  > 0 for supershot simulations
c          = 0 for simulations of all other discharges
c
c  lreset  = 0 to use only internal settings for lswitch, cswitch
c              and for the coefficients fig, frb, and fkb
cap
c  |ldif|  = 5   don't produce transport matrix, only eff.diffusiv.
c                (default)
c            3   only diagonal elements of diffusion matrix
c            1   full diffusion matrix
c            x2   rescale transport matrix with velthi=0
c            x1   don't rescale transport matrix with velthi=0
c                 (default)
c
c    Note that when lreset = 0, the values of the switches and
c    coefficients in the argument list are ignored and all the
c    switches and coefficients are set internally.
c
c    WARNING:  use lreset > 0 only if you want to pass all the switches
c    lswitch, cswitch, fig, frb, and fkb through the argument list.
c
c  Internal control variables:
c  ---------------------------
c
c  lswitch(j), j=1,8   integer control variables:
c
c  cswitch(j), j=1,25   general control variables:
c
c  lswitch(1)  controls which version of the Weiland model is used
c             = 2  2 eqn  Weiland model Hydrogen \eta_i mode only
c             = 4  4 eqn  Weiland model with Hydrogen and trapped electrons
c             = 5  5 eqn  Weiland model with trapped electrons, FLR effects,
c                         and parallel ion motion
c             = 6  6 eqn  Weiland model Hydrogen, trapped electrons,
c                    and one impurity species
c             = 7  7 eqn   Weiland model Hydrogen, trapped electrons,
c                  one impurity species, and collisions
c             = 8  8 eqn  Weiland model Hydrogen, trapped electrons,
c                  one impurity species, collisions, and parallel
c                  ion (hydrogenic) motion
c             = 9  9 eqn  Weiland model Hydrogen, trapped electrons,
c                  one impurity species, collisions, and finite beta
c             = 10 10 eqn Weiland model Hydrogen, trapped electrons,
c                  one impurity species, collisions, parallel
c                  ion (hydrogenic) motion, and finite beta
c             = 11 11 eqn Weiland model Hydrogen, trapped electrons,
c                  one impurity species, collisions, parallel
c                  ion (hydrogenic, impurity) motion, and finite beta
c
c  lswitch(2) = 0  full matrix representation for difthi and velthi
c             = 1  set diagonal matrix elements difthi and velthi
c             = 2  set diagonal matrix elements = effective diffusivities
c
c  lswitch(3) = 1 use (1+\kappa^2)/2 instead of \kappa scaling
c                 otherwise use \kappa scaling
c                 raised to exponents (cthery(12) - ctheory(16))
c
c  lswitch(4) > 0 to replace negative diffusivity with velocity
c
c  lswitch(5) = 1 to limit magnitude of all normalized gradients
c                    to ( major radius ) / ( ion Larmor radius )
c
c  cswitch(1)   0.5  minimum shear
c  cswitch(3)  -4.0  exponent of local elongation multiplying drift waves
c  cswitch(4)  -4.0  exponent of local elongation multiplying resistive
c                     balllooning modes
c  cswitch(5)  -4.0  exponent of local elongation multiplying
c                     kinetic balllooning modes
c  cswitch(6)   0.0  k_y \rho_s (= 0.316 if abs(cswitch(6)) < zepslon)
c  cswitch(9)  0.15  alpha in diamagnetic stabilization in GD model
c  cswitch(10)  0.0  transfer from thigi(jz) to velthi(1,jz)
c  cswitch(11)  0.0  transfer from zddig(jz) to velthi(2,jz)
c  cswitch(12)  0.0  transfer from thige(jz) to velthi(3,jz)
c  cswitch(13)  0.0  transfer from zdzig(jz) to velthi(4,jz)
c
c  cswitch(14)  1.0  include effect of finite beta in weiland14
c                    = cetain(20)
c  cswitch(15)  0.0  min value of impurity charge state zimpz
c  cswitch(16)  0.0  include superthermal ions
c  cswitch(17)  1.0  effect of parallel ion motion in weiland14
c                    = cetain(10)
c  cswitch(18)  0.0  -> 1.0 for effect of collisions in weiland14
c                    = cetain(15)
c  cswitch(19)  0.0  -> 1.0 for v_parallel in strong ballooning limit
c                    = cetain(12)
c  cswitch(20)  0.0  trapping fraction used in weiland14 (when > 0.0)
c                     multiplies electron trapping fraction when < 0.0
c  cswitch(21)  1.0  multiplier for wexbs in weiland14
c  cswitch(22)  0.0  -> 1.0 adds impurity heat flow to total ionic heat
c                     flow for the weiland model
c  cswitch(23)  0.0  controls finite diff to construct the zgm matrix
c                    = cetain(30)
c  cswitch(24)  0.043 fit coefficient of electrostatic electron thermal
c                     diffusivity, indicating fluctuation level
c  cswitch(25)  1.88  coefficient of critical gradient in electrostatic
c                     electron thermal diffusivity formula:3/2*sqrt(pi/2)
c  cswitch(26)  0.082 fit oefficient of electromagnetic electron thermal
c                     diffusivity, indicating fluctuation level
c  cswitch(27)  2.0   exponent of Hamaguchi-Horton parameter in MMM99
c  cswitch(28)  1.0   coefficient of Hamaguchi-Horton parameter in MMM99
c  cswitch(29) = minimum value of magnetic shear
c
c     contributions to vfluxes and interchanges:
c
c  fig(1)   hydrogen particle transport from ITG (eta_i) mode
c  fig(2)   electron thermal  transport from ITG (eta_i) mode
c  fig(3)   ion      thermal  transport from ITG (eta_i) mode
c  fig(4)   impurity particle transport from ITG (eta_i) mode
c
c  frb(1)   hydrogen particle transport from resistive ballooning mode
c  frb(2)   electron thermal  transport from resistive ballooning mode
c  frb(3)   ion      thermal  transport from resistive ballooning mode
c  frb(4)   impurity particle transport from resistive ballooning mode
c
c  fkb(1)   hydrogen particle transport from kinetic ballooning mode
c  fkb(2)   electron thermal  transport from kinetic ballooning mode
c  fkb(3)   ion      thermal  transport from kinetic ballooning mode
c  fkb(4)   impurity particle transport from kinetic ballooning mode
c
c  feg(3)   electron thermal  transport from ETG mode
c
c  Input model switches:
c  --------------------
c  lig = 0 use Weiland14 model from MMM95 for itg modes
c      = 1 use etaw17 model from MMM98d for itg modes
c      = 2 use etaw18 model from MMM99 for itg modes
c
c  lrb = 0 use resistive ballooning mode (Guzda-Drake model) from MMM95
c      = 1 use drift Alfven mode (Scott model) from MMM98d
c
c  lkb = 0 use old kinetic ballooning mode from MMM95
c      = 1 use new kinetic ballooning mode (by Redd) from MMM98d
c
c  lexbs = 0 use Hahm-Burrel ExB shearing rate to substract growth rates
c        = 1 use Hamaguchi-Horton ExB shearing parameter to multiply coeffs.
c
c  letg = 0 do not use any ETG model
c       = 1 use Horton's ETG model
c
c  switch for weiland18:
c  --------------------
c  em   = 0 no E&M effect
c       = 1 apply E&M effect
c
c***********************************************************************
c
c-----------------------------------------------------------------------
c
c  Compile this routine and routines that it calls with a compiler
c  option, such as -r8, to convert real to double precision when used on
c  workstations.
c
c-----------------------------------------------------------------------
c
c  External dependencies:
c
c  Call tree: mmm99 calls the following routines
c
c  WEILAND14       - Computes diffusion matrix and convect velocities
c                        for the Weiland transport model
c    WEILAND14FLUX - Calculates fluxes and effective diffusivities
c      TOMSQZ      - Wrapper for QZ algorithm solving Ax = lambda Bx
c         CQZHES   - First step in QZ algorithm
c         CQZVAL   - Second and third step in QZ algorithm
c         CQZVEeg(*)C   - Fourth step in QZ algorithm
c
c
c  WEILAND18       - Computes diffusion matrix and convect velocities
c                        for the Weiland transport model
c    WEILAND18     - Calculates fluxes and effective diffusivities
c      ETAW18      - Calculates omega and gamma
c        TOMSQZ    - Wrapper for QZ algorithm solving Ax = lambda Bx
c         CQZHES   - First step in QZ algorithm
c         CQZVAL   - Second and third step in QZ algorithm
c         CQZVEeg(*)C   - Fourth step in QZ algorithm
c
c-----------------------------------------------------------------------

      implicit none
c
      integer km, klswitch, kcswitch
c
      parameter ( km = 12, klswitch = 8, kcswitch = 29 )
c
      integer  matdim,  npoints, nprout, lprint, nerr, iknthe
c
      real
     &   rminor(*),  rmajor(*),   elong(*),    delta(*)
     & , dense(*),   densh(*),    densimp(*),  densfe(*)
     & , xzeff(*),   tekev(*),    tikev(*),    q(*),       btor(*)
     & , avezimp(*), amassimp(*), amasshyd(*), aimass(*)
     & , wexbs(*),   yexbs(*)
     & , grdne(*),   grdni(*),    grdnh(*),    grdnz(*)
     & , grdte(*),   grdti(*),    grdq(*)
c
      real
     &   thiig(*),   thdig(*),    theig(*),    thzig(*)
     & , thirb(*),   thdrb(*),    therb(*),    thzrb(*)
     & , thikb(*),   thdkb(*),    thekb(*),    thzkb(*)
     & ,                          theeg(*)
     & ,                          thetb(*)
     & , thitem(*),  thdtem(*),   thetem(*),   thztem(*)
     & , thiitg(*),  thditg(*),   theitg(*),   thzitg(*)
     & , omega(matdim,*),         gamma(matdim,*)
     & , difthi(matdim,matdim,*), velthi(matdim,*)
     & , vflux(matdim,*)
c
      real     cswitch(*)
c
      integer  lsuper,  lreset,  lswitch(*)
c
      integer  lig, lrb, lkb, lexbs, letg, lhh, ldif
c
      real     fig(*),  fkb(*),  frb(*), feg(*)
c
c..physical constants
c
      real zpi,  zcc,  zcmu0,  zceps0,  zckb,  zcme,  zcmp,  zce
c
c  zpi     = pi
c  zcc     = speed of light                  [m/sec]
c  zcmu0   = vacuum magnetic permeability    [henrys/m]
c  zceps0  = vacuum electrical permittivity  [farads/m]
c  zckb    = energy conversion factor        [Joule/keV]
c  zcme    = electron mass                   [kg]
c  zcmp    = proton mass                     [kg]
c  zce     = electron charge                 [Coulomb]
c
c..computer constants
c
      real  zepslon, zlgeps
c
c  zepslon = machine epsilon [smallest number so that 1.0+zepslon>1.0]
c  zlgeps  = ln ( zepslon )
c
c..local variables
c
      integer  jz, j1, j2, jm
c
      real  zelong, zelonf,  zai,    zne,     zni,    zte,    zti
     & ,    zq,     zeff,    zgne,   zgni,    zgnh,   zgnz,   zgte
     & ,    zgth,   zgtz,    zshear, zrmin,   zrmaj,  zbtor,  zep
     & ,    zprth,  zgyrfi,  zvthe,   zvthi,  zsound, zlog
     & ,    zcf,    znuei,   znueff, zlari,   zlarpo, zrhos,  zwn
     & ,    znude,  znuhat,  zdprth, zsgdpr,  zdpdr,  zgpr,   zscyl
     & ,    zsmin,  zshat,   zgmax,  zdelta,  zkappa, znhni,  zshat1
c
      real zbeta(npoints), zbetae(npoints), zbetah(npoints)
     & ,  zbetaz(npoints)
c
c..variables for Weiland model
c
c  iletai(j1) and cetain(j1) are control variables
c
      integer        iletai(32)
c
      real  cetain(32), zomega(km), zgamma(km), zchieff(km)
     &    , zchiefftem(km), zchieffitg(km)
c
      real           zdfthi(km,km),    zvlthi(km),     zflux(km)
c
      integer        idim,    ieq,     imodes
c
      real  zthte,   ztz,     znh,     znz,    zmass,  zimpz
     & ,    ztzte,   zfnzne,  zmzmh,   zfnsne, zftrap, zkyrho
     & ,    zomegde, zwexb,   znormd,  znormv
c
c  zexb    = local copy of ExB shearing rate
c  znormd  = factor to convert normalized diffusivities
c  znormv  = factor to convert normalized convective velocities
c
      real zkparl, zperf(km)
c
c..local variables for resistive ballooning modes
c
      real  zgyrfe, zlare,   zgddia, zgdp
c
c..local variables for the drift Alfven model
c
      integer iswitchda, isdasw(klswitch)
c
      real zsdasw(klswitch), zchrgns
     &   , zfldath, zfldanh, zfldate, zfldanz, zfldatz
     &   , zdfdath, zdfdanh, zdfdate, zdfdanz, zdfdatz
c
      real xtrans, xtrans0, xtrans1, transprof, transfun
c
c..local variables for MMM95 kinetic ballooning modes
c
      real  zbprim, zbcoef1, zbc1,   zelfkb,  zfbthn, zdk
c
c..local variables for MMM98d kinetic ballooning modes
c
      integer ikbmodels(25)
c
      real zkbmodels(25), zbetac1, zbetac2, zchifact
     &  , zchiikb, zchiekb, zdifhkb, zdifzkb, zepm
c
c..local variables for Hamaguchi-Horton model
c
      real zrls2, zwcs2, zhh, zyexbsc
c
c..local variables for Horton's ETG model
c
      real zwpe, zlce(55), zdeltae(55), zgamaeg(55), zgtec(55)
c
c..variable for weiland18
c
      integer ITS, ITERA, em
c
      external transfun
c
c-----------------------------------------------------------------------
c
c..physical constants
c
        zpi     = atan2 ( 0.0, -1.0 )
        zcc     = 2.997925e+8
        zcmu0   = 4.0e-7 * zpi
        zceps0  = 1.0 / ( zcc**2 * zcmu0 )
        zckb    = 1.60210e-16
        zcme    = 9.1091e-31
        zcmp    = 1.67252e-27
        zce     = 1.60210e-19
c
c..computer constants
c
        zepslon = 1.0e-34
        zlgeps  = log ( zepslon )
c
c
c..initialize arrays
c
      do jz = 1, npoints
        thiig(jz)  = 0.
        thdig(jz)  = 0.
        theig(jz)  = 0.
        thzig(jz)  = 0.
        therb(jz)  = 0.
        thirb(jz)  = 0.
        thdkb(jz)  = 0.
        thekb(jz)  = 0.
        thzkb(jz)  = 0.
        thikb(jz)  = 0.
        thdkb(jz)  = 0.
        thekb(jz)  = 0.
        thzkb(jz)  = 0.
        thitem(jz)  = 0.
        thdtem(jz)  = 0.
        thetem(jz)  = 0.
        thztem(jz)  = 0.
        thiitg(jz)  = 0.
        thditg(jz)  = 0.
        theitg(jz)  = 0.
        thzitg(jz)  = 0.
      enddo
c
      do jz = 1, npoints
        do j1 = 1, matdim
          velthi(j1,jz) = 0.0
          vflux(j1,jz) = 0.0
          do j2 = 1, matdim
            difthi(j1,j2,jz) = 0.0
          enddo
        enddo
      enddo
c
c..if lreset < 1, use internal settings for switches and coefficients
c  otherwise, use values passed through the argument list above
c
      if ( lreset .lt. 1 ) then
c
c..initialize switches
c
      do j1=1,kcswitch
        cswitch(j1) = 0.0
      enddo
c
      do j1=1,klswitch
        lswitch(j1) = 0
      enddo
c
c
c  Multi Mode Model in sbrtn THEORY version mmm99 (default is mmm95)
c  for use in the BALDUR transport code
c
      lswitch(1) = 10 ! Weiland ITG model weiland14 (10 eqns, no collisions)
cap   lswitch(2) = 2  ! use effective diffusivities
      lswitch(3) = 0  ! use kappa instead of (1+\kappa^2)/2
      lswitch(4) = 1  ! replace -ve diffusivity with convective velocity
      lswitch(5) = 1  ! limit gradients by major radius / ion Larmor radius
c
c  misc. parameters for sub. theory
c
      cswitch(1)  =  0.5 ! minimum value of shear
      cswitch(2)  =  3.5  ! for fbeta-th in kinetic ballooning
      cswitch(3)  = -4.0  ! elongation scaling for Weiland model
      cswitch(4)  = -4.0  ! elongation scaling for RB model
      cswitch(5)  = -4.0  ! elongation scaling for KB mode
      cswitch(6)  =  0.0  ! k_y \rho_s (= 0.316 if abs(cswitch(6)) < zepslon)
      cswitch(8)  =  1.0  ! coeff of beta_prime_1 in kinetic ballooning mode
      cswitch(9)  = 0.15  ! Diamagnetic stabilization in Guzdar-Drake model
      cswitch(10) =  0.0  ! difthi -> velthi for chi_i
      cswitch(11) =  0.0  ! difthi -> velthi for hydrogen
      cswitch(12) =  0.0  ! difthi -> velthi for chi_e
      cswitch(13) =  0.0  ! difthi -> velthi for impurity
      cswitch(14) =  1.0  ! coeff of finite beta in weiland14 = cetain(20)
      cswitch(15) =  0.0  ! min value of impurity charge state zimpz
      cswitch(16) =  1.0  ! set fast particle fraction for use in weiland14
      cswitch(17) =  1.0  ! coeff of k_\parallel in weiland14 = cetain(10)
      cswitch(18) =  0.0  ! coeff of nuhat in weiland14 = cetain(15)
      cswitch(19) =  0.0  ! 0.0 -> 1.0 for v_parallel in strong balloon limit = cetain(12)
      cswitch(20) =  0.0  ! trapping fraction used in weiland14 (when > 0.0)
                          ! multiplies electron trapping fraction when < 0.0
      cswitch(21) =  1.0  ! multiplier for wexbs
      cswitch(22) =  0.0  ! multiplier to impurity heat flux
      cswitch(23) =  0.0  ! controls finite diff to construct the zgm matrix = cetain(30)
      cswitch(24) = 0.043 !C_e^{ES} in Horton's \chi_e^{ES}
      cswitch(25) = 1.880 !C_L in Horton's \chi_e^{ES}
c      cswitch(25) = 0.000 !C_L in Horton's \chi_e^{ES}
      cswitch(26) = 0.082 !C_e^{EM} in Horton's \chi_e^{EM}
c
c  contributions to hydrogenic particle, elec-energy, ion-energy,
c    and impurity ion fluxes
c
c        fig(1) = 0.80
c        fig(2) = 0.80
c        fig(3) = 0.80
c        fig(4) = 0.80
c
c        fkb(1) = 0.01
c        fkb(2) = 0.01
c        fkb(3) = 0.01
c        fkb(4) = 0.01
c
c        if ( lsuper .eq. 1 ) then
c          fkb(1) = 1.e-6
c          fkb(2) = 1.e-6
c          fkb(3) = 1.e-6
c          fkb(4) = 1.e-6
c        endif
c
c        frb(1) = 1.00
c        frb(2) = 1.00
c        frb(3) = 1.00
c        frb(4) = 1.00
c
cap        feg(3) = 1.00
c
      endif

!|
!| We then enter a loop over the spatial zones, and set the following
!| BALDUR {\tt common} variables to variables local to subroutine {\tt
!| theory}: the mean atomic mass number of the thermal ions, $A_{i}$
!| ({\tt zai}), the electron and ion density and temperature, $n_{e}$
!| ({\tt zne}), $n_{i}=\sum_{a}n_{a}$ ({\tt zni}), $T_{e}$ ({\tt zte}),
!| and $T_{i}$ ({\tt zti}), the safety factor, $q$ ({\tt zq}), the
!| effective charge, $Z_{eff}$ ({\tt zeff}),the midplane halfwidth of a
!| flux surface, $r$ ({\tt zrmin}), the major radius, $R_{o}$ ({\tt
!| zrmaj}), and the toroidal field at $R_0$ major radius, $B_{0}$
!| ({\tt zbtor}).  Therefore, the only variables not defined in
!| subroutine {\tt mmm99} that are needed to complete the rest of the
!| calculation are $\pi$ ({\tt zpi}), the small overflow protection
!| variable {\tt zepslon}.  The points of defining so many local
!| variables are to compact the notation.  The relevant coding for the
!| calculations just described is:
!|
c
c.. start the main do-loop over the radial index "jz"..........
c
c
      do 300 jz = 1, npoints
c
c  transfer common to local variables to compact the notation
c
      zelong = max (zepslon,elong(jz))
      if ( lswitch(3) .eq. 1 ) then
        zelonf = ( 1. + zelong**2 ) / 2.
      else
        zelonf = zelong
      endif
c
      zai    = aimass(jz)
      zne    = dense(jz)
      zni    = densh(jz) + densimp(jz)
      znh    = densh(jz)
      znz    = densimp(jz)
      zte    = tekev(jz)
      zti    = tikev(jz)
      zq     = q(jz)
      zeff   = xzeff(jz)
c
c  normalized gradients
c
      zgne   = grdne(jz)
      zgni   = grdni(jz)
      zgnh   = grdnh(jz)
      zgnz   = grdnz(jz)
      zgte   = grdte(jz)
      zgth   = grdti(jz)
      zgtz   = grdti(jz)

      zrmin  = max( rminor(jz), zepslon )
      zrmaj  = rmajor(jz)
      zdelta = delta(jz)
c
      zshear = grdq(jz) * zrmin / zrmaj
      zbtor  = btor(jz)
c
c  compute inverse aspect ratio
c
      zep    = max( zrmin/zrmaj, zepslon )
c
!|
!| To complete the rest of the calculation we then compute various
!| quantities needed for the transport flux formulas (as in Table 1 of
!| the Comments paper, from which
!| $\omega_{ce}$ was inadvertantly omitted).
!| To begin with, we compute only quantities
!| which do not involve scale heights.
!| In the order in which they are computed, algebraic notation for
!| these quantities is:
!| $$ p=n_e T_e + n_i T_i \ --- \ {\rm (thermal)}\eqno{\tt zprth} $$
!| $$ \omega_{ci}=eB_{o}/(m_{p}A_{i}) \eqno{\tt zgyrfi} $$
!| $$ \beta=(2\mu_{o}k_{b}/B_{o}^{2})(n_{e}T_{e}+n_{i}T_{i})
!|  \eqno{\tt zbeta} $$
!| $$ v_{e}=(2k_{b}T_{e}/m_{e})^{1/2} \eqno{\tt zvthe} $$
!| $$ v_{i}=(2k_{b}T_{i}/m_{p}A_{i})^{1/2} \eqno{\tt zvthi} $$
!| $$ c_{s}=[k_{b}T_{e}/(m_{p}A_{i})]^{1/2} \eqno{\tt zsound} $$
!| $$ \ln (\lambda)=37.8 - \ln (n_{e}^{1/2}T_{e}^{-1}) \eqno{\tt zlog} $$
!| $$ \nu_{ei}=4(2\pi)^{1/2}n_{e}(\ln \lambda)e^{4}Z_{eff}
!|                /[3(4\pi \epsilon_{o})^{2}m_{e}^{1/2}(k_{b}T_{e})^{3/2}]
!|  \eqno{\tt znuei} $$
!| $$ \eta=\nu_{ei}/(2\epsilon_{o}\omega_{pe}^{2}) \eqno{\tt zresis} $$
!| $$ \nu_{eff}=\nu_{ei}/\epsilon \eqno{\tt znueff} $$
!| $$ \nu_{e}^{*}=\nu_{ei}qR_{o}/(\epsilon^{3/2}v_{e}) \eqno{\tt thnust} $$
!| $$ \hat{\nu}=\nu_{eff}/\omega_{De} \eqno{\tt znuhat} $$
!| $$ \rho_{\theta i}=\rho_{i}q/\epsilon \eqno{\tt zlari} $$
!| $$ \rho_{i}=v_{i}/\omega_{ci} \eqno{\tt zlarpo} $$
!| $$ \rho_{s}=c_{s}/\omega_{ci} \eqno{\tt zrhos} $$
!| $$ k_{\perp}=0.3/\rho_{s} \eqno{\tt zwn} $$
!| $$ \omega_{pe}^2=\frac{n_e e^2}{\epsilon_0 m_e} \eqno{\tt zwpe} $$
!| $$ l_{c,e}^{es}=q\rho_e\frac{R}{L_{T_e}} \eqno{\tt zlce} $$
!| $$ \delta_e = \frac{c}{\omega_{pe}} \eqno{\tt zdeltae} $$
!| The corresponding coding is:
!|
c
      zprth  = zne * zte + zni * zti
      zgyrfi = zce * zbtor / (zcmp * zai)
      zbeta(jz)  = (2. * zcmu0 * zckb / zbtor**2) * (zne * zte
     &             + zni * zti)
      zvthe  = sqrt(2. * zckb * zte / zcme)
      zvthi  = sqrt(2. * zckb * zti / (zcmp * zai))
      zsound = sqrt(zckb * zte / (zcmp * zai))
      zlog   = 37.8-log(sqrt(zne) / zte)
      zcf    = (4. * sqrt(zpi) / 3.)
      zcf    = zcf * (zce / (4. * zpi * zceps0))**2
      zcf    = zcf * (zce / zckb) * sqrt( (zce/zcme) * (zce/zckb) )
      znuei  = zcf * sqrt(2.) * zne * zlog * zeff / (zte * sqrt(zte))
c
      znueff = znuei / zep
      zlari  = zvthi / zgyrfi
      zlarpo = max(zlari * zq / zep, zepslon)
      zrhos  = zsound / zgyrfi
      zwn    = 0.3 / zrhos
      znude  = 2 * zwn * zrhos * zsound / zrmaj
      znuhat = znueff / znude
c
c..if lswitch(5) = 1, limit magnitude of normalized gradients
c                    to ( major radius ) / ( ion Larmor radius )
c
      zgmax = zrmaj / zlarpo
c
      if ( lswitch(5) .eq. 1 ) then
c
        zgne = sign ( min ( abs ( zgne ), zgmax ), zgne )
        zgni = sign ( min ( abs ( zgni ), zgmax ), zgni )
        zgnh = sign ( min ( abs ( zgnh ), zgmax ), zgnh )
        zgnz = sign ( min ( abs ( zgnz ), zgmax ), zgnz )
        zgte = sign ( min ( abs ( zgte ), zgmax ), zgte )
        zgth = sign ( min ( abs ( zgth ), zgmax ), zgth )
        zgtz = sign ( min ( abs ( zgtz ), zgmax ), zgtz )
c
      endif
c
c  zgpr = -R ( d p   / d r ) / p    for thermal pressure
c
c  Compute the pressure scale length using smoothed and bounded
c  density and temperature
c
      zgpr = ( zne * zte * ( zgne + zgte )
     &         + zni * zti * ( zgni + zgth ) )
     &         / ( zne * zte + zni * zti )
c
      if ( lswitch(5) .eq. 1 )
     &  zgpr = sign ( min ( abs ( zgpr ), zgmax ), zgpr )
c
c
!|
!| Our formulas for the shear begin with
!| $$ {\hat s}_{cyl}=|(r/q)(\partial q/\partial r)| \eqno{\tt zscyl} $$
!| computed earlier in this subroutine.
!| The minimum prescribed shear is
!| $$ {\hat s}_{min}=max(c_{1},0) \eqno{\tt zsmin} $$
!| where $c_1=$ = {\tt cswitch(1)} so that shear is then given by
!| $$ {\hat s}=max({\hat s}_{min},{\hat s}_{cyl}) \eqno{\tt zshat} $$
!|
!| The relevant coding for the calculations just described is:
!|
c
      zscyl=max(abs(zshear),zepslon)
      zsmin=max(cswitch(1),zepslon)
      zshat=max(zsmin,zscyl)
c
!|
!| %**********************************************************************c
!|
!| \section{Transport Models}
!|
!| The computation of the anomalous transport coefficients is
!| now described.  Please note that all the heat flux is included in the
!| thermal diffusion and velocity coefficients.  There are no additional
!| ``convective velocities''.
!| The mode abbreviations used here are
!| \begin{center}
!| \begin{tabular}{llll}
!|     &             &                                         &        \\
!|     & {\tt ig}    & $\eta_i$-mode and drift wave modes      &        \\
!|     & {\tt rb}    & resistive ballooning                    &        \\
!|     & {\tt kb}    & kinetic ballooning                      &        \\
!|     &             &                                         &
!| \end{tabular}
!| \end{center}
!|
!| %**********************************************************************c
!|
!| \subsection{$\eta_i$ Modes}
!| %
!|
!| The $\eta_i$ and trapped electron mode model
!| by Weiland et al\cite{nord90a} is implemented when
!| ${\tt lswitch(1)}$ is set greater than 1.
!| When $ {\tt lswitch(1)} = 2 $, only the hydrogen equations are used
!| (with no trapped electrons or impurities) to compute only the
!| $ \eta_i $ mode.
!| When $ {\tt lswitch(1)} = 4 $, trapped electrons are included,
!| but not impurities.
!| When $ {\tt lswitch(1)} = 6 $, a single species of impurity ions is
!| included as well as trapped electrons.
!| When $ {\tt lswitch(1)} = 7 $, the effect of collisions is included.
!| When $ {\tt lswitch(1)} = 8 $, parallel ion (hydrogenic) motion and
!| the effect of collisions are included.
!| When $ {\tt lswitch(1)} = 9 $, finite beta effects and collisions are
!| included.
!| When $ {\tt lswitch(1)} = 10 $, parallel ion (hydrogenic) motion,
!| finite beta effects, and the effect of collisions are included.
!| When $ {\tt lswitch(1)} = 11 $, parallel ion (hydrogenic and impurity) motion,
!| finite beta effects, and the effect of collisions are included.
!| Finite Larmor radius corrections are included in all cases.
!| Values of {\tt lswitch(1)} greater than 11 are reserved for extensions
!| of this Weiland model.
!|
!| The mode growth rate, frequency, and effective diffusivities are
!| computed in subroutine {\tt weiland14}.
!| Frequencies are normalized by $\omega_{De}$ and diffusivities are
!| normalized by $ \omega_{De} / k_y^2 $.
!| The order of the diffusivity equations is
!| $ T_H $, $ n_H $, $ T_e $, $ n_Z $, $ T_Z $, \ldots
!| Note that the effective diffusivities can be negative.
!|
!| The diffusivity matrix $ D = {\tt difthi(j1,j2)}$
!| is given above.
!|
!|
!| The impurity density gradient scale length is defined as
!| $$g_{nz}=-R{{d\ }\over {dr}}\left(Zn_z\right)/(Zn_z)$$
!| The electron density gradient scale length is defined as
!| $$g_{ne}=(1-Zf_z-f_s)g_{nH}+Zf_zg_{nz}+f_sg_{ns}$$
!| where $ f \equiv n_Z / n_e $ and $ n_e = n_H + Z n_Z +n_s$.
!| For this purpose, all the impurity species are lumped together as
!| one effective impurity species and all the hydrogen isotopes are lumped
!| together as one effective hydrogen isotope.
!|
!|
c
        do j1=1,32
          iletai(j1) = 0
          cetain(j1) = 0.0
        enddo
c
        thiig(jz) = 0.0
        theig(jz) = 0.0
        thdig(jz) = 0.0
        thzig(jz) = 0.0
c
c..set the number of equations to use in the Weiland model
c
        if ( (lswitch(1) .lt. 2) .or. (lswitch(1) .gt. 11 )) then
          nerr = -10
          return
        elseif (lswitch(1) .eq. 3) then
          nerr = -10
          return
        else
          ieq = lswitch(1)
        endif
c
        cetain(11) = 1.0
c
c.. coefficient of k_parallel for parallel ion motion
c.. cswitch(19) for v_parallel in strong ballooning limit
c.. in 9 eqn model
c
        cetain(10) = cswitch(17)
        cetain(12) = cswitch(19)
        cetain(15) = cswitch(18)
        cetain(20) = cswitch(14)
c
        iletai(10) = 0
c
        idim   = km
c
c  Hydrogen species
c
        zthte  = zti / zte

        zbetae(jz) = 2. * zcmu0 * zckb * zne * zte / zbtor**2
c
c  Impurity species (use only impurity species 1 for now)
c  assume T_Z = T_H throughout the plasma here
c
        ztz    = zti
        znz    = densimp(jz)
        zmass  = amassimp(jz)
        zimpz  = avezimp(jz)
        zimpz  = max ( zimpz, cswitch(15) )
c
        ztzte  = zti / zte
        zfnzne = znz / zne
        zmzmh  = zmass / amasshyd(jz)
c
c  superthermal ions
c
c  zfnsne = ratio of superthermal ions to electrons
c  L_ns   = gradient length of superthermal ions
c
        zfnsne = max ( cswitch(16) * densfe(jz) / dense(jz) , 0.0 )
c
        zftrap = sqrt ( 2. * zrmin / ( zrmaj * ( 1. + zrmin / zrmaj )))
        if ( cswitch(20) .gt. zepslon ) zftrap = cswitch(20)
        if ( cswitch(20) .lt. -zepslon )
     &       zftrap = abs(cswitch(20))*zftrap
c
        if ( abs(cswitch(6)) .lt. zepslon ) then
          zkyrho = 0.316
        else
          zkyrho = cswitch(6)
        endif
c
c
c...Define a local copy of normalized ExB shearing rate : pis
c
        zomegde = 2.0 * zkyrho * zsound / zrmaj
c
        if (lexbs.eq.0) then
          zwexb = cswitch(21) * wexbs(jz) / zomegde
        else if (lexbs.eq.1) then
          zwexb = 0.0
        end if
c
        zbetah(jz) = 0.0
        zbetaz(jz) = 0.0
        zkparl = 1.0
        zperf  = 0.0
c
        cetain(30) = cswitch(23)
        iletai(6)  = 0
cap        if ( lswitch(2) .lt. 1 ) iletai(7) = 1
c
cap (?) if lswitch(2) .lt. 1, compute only the effective diffusivities
c
cap {
        select case (iabs(ldif))
          case (1)
           lswitch(2) = 0
           iletai(7)   = 0
          case (2)
           lswitch(2) = 0
           iletai(7)   = 1
          case (3)
           lswitch(2) = 1
           iletai(7)   = 0
          case (6)
           lswitch(2) = 1
           iletai(7)   = 1
          case (10)
           lswitch(2) = 2
           iletai(7)   = 1
          case default
           lswitch(2) = 2
           iletai(7)   = 0
        end select
cap }
        iletai(9) = lswitch(2)
c
        if (lig.eq.0) then
c
          lswitch(1) = 10 ! Weiland ITG model weiland14 (10 eqns, no collisions)
          cswitch(22) = 0.0     ! multiplier to impurity heat flux
c
          call weiland14 (
     &   iletai,   cetain,   lprint,   ieq,      nprout,   zgne
     & , zgnh,     zgnz,     zgte,     zgth,     zgtz,     zthte
     & , ztzte,    zfnzne,   zimpz,    zmzmh,    zfnsne,   zbetae(jz)
     & , zftrap,   znuhat,   zq,       zshat,    zkyrho,   zwexb
     & , idim,     zomega,   zgamma,   zdfthi,   zvlthi,   zchieff
     & , zchieffitg, zchiefftem, zflux,    imodes,   nerr )
c
        else if(lig.eq.1) then
c
          lswitch(1) = 11 ! Weiland ITG model weiland14 (11 eqns, no collisions)
          cswitch(22) = 1.0     ! multiplier to impurity heat flux
c
           call etaw17diff (
     &   iletai,   cetain,   lprint,   ieq,      nprout,   zgne
     & , zgnh,     zgnz,     zgte,     zgth,     zgtz,     zthte
     & , ztzte,    zfnzne,   zimpz,    zmzmh,    zfnsne,   zbetae(jz)
     & , zbetah(jz), zbetaz(jz), zftrap, znuhat, zq,       zshat
     & , zelong,   zkyrho,   zkparl,   zwexb
     & , idim,     zomega,   zgamma,   zdfthi,   zvlthi,   zchieff
     & , imodes,   zperf,    nerr )

        else if(lig.eq.2) then
c
          lswitch(1)  = 10     ! Weiland ITG model weiland18 (10 eqns)
          cswitch(22) = 0.0    ! multiplier to impurity heat flux
          nerr        = 0.0
c
           call  weiland18 (
     &   iletai,   cetain,   lprint,   ieq,      nprout,   zgne
     & , zgnh,     zgnz,     zgte,     zgth,     zgtz,     zthte
     & , ztzte,    zfnzne,   zimpz,    zmzmh,    zfnsne,  zbetae(jz)
     & , zftrap,   znuhat,   zq,       zshat,    zep,      zelong
     & , amasshyd, zkyrho,   zkparl,   idim,     zomega,   zgamma
     & , zdfthi,   zvlthi,   zchieff,  imodes,   nerr,     ITS
     & , ITERA,    em)
c
           if (nprout .gt. 6) then
c
                if (nerr .ne. 0) then
                	write(6,*) 'The Eigen solver tomsqz fails.'
  		endif
c
           	if (ITS .eq. 1) then
      			write(6,*) 'Non-linear iteration has converged
     &in ',ITERA,' iterations.'
  	   	else
			write(6,*) 'At r =', rminor(jz), 'Non-linear iteration
     & has not converged in 50 iterations'
			write(6,*) 'gnein(1)     = ', zgne,','
 			write(6,*) 'gnhin(1)     = ', zgnh,','
 			write(6,*) 'gnzin(1)     = ', zgnz,','
			write(6,*) 'gtein(1)     = ', zgte,','
			write(6,*) 'gthin(1)     = ', zgth,','
  			write(6,*) 'tauhin(1)    = ', ztzte,','
     			write(6,*) 'fnzin(1)     = ', zfnzne,','
			write(6,*) 'czin(1)      = ', zimpz,','
			write(6,*) 'azin(1)      = ', zmzmh,','
			write(6,*) 'fnsin(1)     = ', zfnsne,','
			write(6,*) 'betaein(1)   = ', zbetae(jz),','
 			write(6,*) 'ftrapein(1)  = ', zftrap,','
			write(6,*) 'qin(1)       = ', zq,','
			write(6,*) 'shearin(1)   = ', zshat,','
			write(6,*) 'vefin(1)     = ', znuhat,','
 			write(6,*) 'ekparlin(1)  = ', zkparl,','
			write(6,*) 'kappain(1)   = ', zelong,','
			write(6,*) 'ekyrhoin(1)  = ', zkyrho,','
			write(6,*) 'hydmass      = ', amasshyd(1),','
			write(6,*) 'zrmin        = ', zrmin,','
			write(6,*) 'zrmaj        = ', zrmaj,','
  	   	endif
	   endif
        end if
c
c  If nerr not equal to 0 an error has occured
c
        if (nerr .ne. 0) return
c
c
c  Growth rates for diagnostic output
c    Note that all frequencies are normalized by \omega_{De}
c      consequently, trapped electron modes rotate in the positive
c      direction (zomega > 0) while eta_i modes have zomega < 0.
c
        jm = 0
        do j1=1,imodes
          if ( zgamma(j1) .gt. zepslon ) then
            jm = jm + 1
            gamma(jm,jz) = zgamma(j1) / zomegde
            omega(jm,jz) = zomega(j1) / zomegde
          endif
        enddo
c
c  conversion factors for diffusion and convective velocity
c
        znormd = zelonf**cswitch(3) *
     &    2.0 * zsound * zrhos**2 / ( zrmaj * zkyrho )
        znormv = zelonf**cswitch(3) *
     &    2.0 * zsound * zrhos**2 / ( zrmaj**2 * zkyrho )
c
c  compute effective diffusivites for diagnostic purposes only
c
c  reduce the thermal transport through the hydrogenic channel
c  by znh / zni if lig > 0
c
        znhni = 1.0
        if ( lig .gt. 0 ) znhni = znh / zni
c
        thdig(jz) = fig(1) * znormd * zchieff(2)
        theig(jz) = fig(2) * znormd * zchieff(3)
        thiig(jz) = fig(3) * znormd * zchieff(1) * znhni
     &  + fig(3) * znormd * zchieff(5) * cswitch(22) * znz / zni
        thzig(jz) = fig(4) * znormd * zchieff(4)
c
c  compute effective diffusivites from TEM for diagnostic purposes only
c
        thdtem(jz) = fig(1) * znormd * zchiefftem(2)
        thetem(jz) = fig(2) * znormd * zchiefftem(3)
        thitem(jz) = fig(3) * znormd * zchiefftem(1)
     &  + fig(3) * znormd * zchiefftem(5) * cswitch(22) * znz / zni
        thztem(jz) = fig(4) * znormd * zchiefftem(4)
c
c  compute effective diffusivites from ITG for diagnostic purposes only
c
        thditg(jz) = fig(1) * znormd * zchieffitg(2)
        theitg(jz) = fig(2) * znormd * zchieffitg(3)
        thiitg(jz) = fig(3) * znormd * zchieffitg(1)
     &  + fig(3) * znormd * zchieffitg(5) * cswitch(22) * znz / zni
        thzitg(jz) = fig(4) * znormd * zchieffitg(4)
c
c  start computing the fluxes
c
        vflux(1,jz) = vflux(1,jz) + thiig(jz) * zgth / zrmaj
        vflux(2,jz) = vflux(2,jz) + thdig(jz) * zgnh / zrmaj
        vflux(3,jz) = vflux(3,jz) + theig(jz) * zgte / zrmaj
        vflux(4,jz) = vflux(4,jz) + thzig(jz) * zgnz / zrmaj
c
c  compute diffusivity matrix
c
        do j1=1,matdim
          velthi(j1,jz) = 0.0
          vflux(j1,jz) = 0.0
          do j2=1,matdim
            difthi(j1,j2,jz) = 0.0
          enddo
        enddo
c
c..set diffthi and velthi
c
        if ( lswitch(2) .gt. 1 ) then
c
c  diagonal elements of matrix = effective diffusivities
c
          difthi(1,1,jz) = difthi(1,1,jz) + thiig(jz)
          difthi(2,2,jz) = difthi(2,2,jz) + thdig(jz)
          difthi(3,3,jz) = difthi(3,3,jz) + theig(jz)
          difthi(4,4,jz) = difthi(4,4,jz) + thzig(jz)
c
        else
c
c..full matrix form of model
c
          if ( ieq .eq. 2 ) then
            difthi(1,1,jz) = difthi(1,1,jz) +
     &        fig(3) * znormd * zdfthi(1,1)
            velthi(1,jz)   = velthi(1,jz) +
     &        fig(3) * znormv * zvlthi(1)
          elseif ( ieq .eq. 4 ) then
            do j2=1,3
              difthi(1,j2,jz) = difthi(1,j2,jz) +
     &          fig(3) * znormd * zdfthi(1,j2)
              difthi(2,j2,jz) = difthi(2,j2,jz) +
     &          fig(1) * znormd * zdfthi(2,j2)
              difthi(3,j2,jz) = difthi(3,j2,jz) +
     &          fig(2) * znormd * zdfthi(3,j2)
              difthi(4,j2,jz) = difthi(4,j2,jz) +
     &          fig(4) * znormd * zdfthi(2,j2)
            enddo
              velthi(1,jz)    = velthi(1,jz) +
     &          fig(3) * znormv * zvlthi(1)
              velthi(2,jz)    = velthi(2,jz) +
     &          fig(1) * znormv * zvlthi(2)
              velthi(3,jz)    = velthi(3,jz) +
     &          fig(2) * znormv * zvlthi(3)
              velthi(4,jz)    = velthi(4,jz) +
     &          fig(4) * znormv * zvlthi(2)
          else
            do j2=1,4
              difthi(1,j2,jz) = difthi(1,j2,jz) +
     &          fig(3) * znormd * zdfthi(1,j2)
              difthi(2,j2,jz) = difthi(2,j2,jz) +
     &          fig(1) * znormd * zdfthi(2,j2)
              difthi(3,j2,jz) = difthi(3,j2,jz) +
     &          fig(2) * znormd * zdfthi(3,j2)
              difthi(4,j2,jz) = difthi(4,j2,jz) +
     &          fig(4) * znormd * zdfthi(4,j2)
            enddo
              velthi(1,jz)    = velthi(1,jz) +
     &          fig(3) * znormv * zvlthi(1)
              velthi(2,jz)    = velthi(2,jz) +
     &          fig(1) * znormv * zvlthi(2)
              velthi(3,jz)    = velthi(3,jz) +
     &          fig(2) * znormv * zvlthi(3)
              velthi(4,jz)    = velthi(4,jz) +
     &          fig(4) * znormv * zvlthi(4)
          endif
c
        endif
c
c
c..transfer from diffusivity to convective velocity
c
        if ( lswitch(4) .gt. 0 ) then
c
          if ( thiig(jz) .lt. 0.0 ) then
            velthi(1,jz) = velthi(1,jz) - thiig(jz) * zgth / zrmaj
            thiig(jz) = 0.0
            do j2=1,4
              difthi(1,j2,jz) = 0.0
            enddo
          endif
c
          if ( thdig(jz) .lt. 0.0 ) then
            velthi(2,jz) = velthi(2,jz) - thdig(jz) * zgnh / zrmaj
            thdig(jz) = 0.0
            do j2=1,4
              difthi(2,j2,jz) = 0.0
            enddo
          endif
c
          if ( theig(jz) .lt. 0.0 ) then
            velthi(3,jz) = velthi(3,jz) - theig(jz) * zgte / zrmaj
            theig(jz) = 0.0
            do j2=1,4
              difthi(3,j2,jz) = 0.0
            enddo
          endif
c
          if ( thzig(jz) .lt. 0.0 ) then
            velthi(4,jz) = velthi(4,jz) - thzig(jz) * zgnz / zrmaj
            thzig(jz) = 0.0
            do j2=1,4
              difthi(4,j2,jz) = 0.0
            enddo
          endif
c
        else if (lig.eq.1) then
c
c..shift from diffusion to convective velocity
c
          if ( abs(cswitch(10)) + abs(cswitch(11)) + abs(cswitch(12))
     &       + abs(cswitch(13)) .gt. zepslon ) then
c
            velthi(1,jz) = velthi(1,jz)
     &       + cswitch(10) * thiig(jz) * zgth / zrmaj
            velthi(2,jz) = velthi(2,jz)
     &       + cswitch(11) * thdig(jz) * zgnh / zrmaj
            velthi(3,jz) = velthi(3,jz)
     &       + cswitch(12) * theig(jz) * zgte / zrmaj
            velthi(4,jz) = velthi(4,jz)
     &       + cswitch(13) * thzig(jz) * zgnz / zrmaj
c
c..alter the effective diffusivities
c  if they are used for more than diagnostic purposes
c
            thiig(jz) = ( 1.0 - cswitch(10) ) * thiig(jz)
            thdig(jz) = ( 1.0 - cswitch(11) ) * thdig(jz)
            theig(jz) = ( 1.0 - cswitch(12) ) * theig(jz)
            thzig(jz) = ( 1.0 - cswitch(13) ) * thzig(jz)
c
            do j2=1,4
              difthi(1,j2,jz) = ( 1.0 - cswitch(10) ) * difthi(1,j2,jz)
              difthi(2,j2,jz) = ( 1.0 - cswitch(11) ) * difthi(2,j2,jz)
              difthi(3,j2,jz) = ( 1.0 - cswitch(12) ) * difthi(3,j2,jz)
              difthi(4,j2,jz) = ( 1.0 - cswitch(13) ) * difthi(4,j2,jz)
            enddo
c
          endif
c
        endif
c
c..end of Weiland model
c
c---:----1----:----2----:----3----:----4----:----5----:----6----:----7-c
c
!| %**********************************************************************c
!| \subsection{Flow Shear Stabilization Models}
!| Two models of the ${\bf E}\times{\bf B}$ flow shear stabilization are implemented, and could be switched to either as needed. One model is to substract the Hahm--Burrel ${\bf E}\times{\bf B}$ flow shear rate
!| \begin{equation}
!| \omega_s=\left|\frac{RB_{\theta}}{B_{\phi}}\ \frac{\partial}{\partial r} \left(\frac{E_r}{RB_{\theta}}\right)\right|
!| \end{equation}
!| from all the linear growth rates. The actual subtraction takes place in routine {\tt weiland14} or {\tt etaw17flux}. The other model is to multiply all the transport coefficients computed (with ${\bf E}\times{\bf B}$ setting to zero in {\tt weiland14} or {\tt etaw17flux}) by the factor
!| \begin{equation}
!| \frac{1}{1+\Upsilon_s^2}\ =\frac{\left(\frac{s}{qR}\ \right)^2}{\left(\frac{s}{qR}\ \right)^2 + \left(\frac{\omega_s}{c_s}\ \right)^2}
!| \end{equation}
!| where
!| \begin{equation}
!| \Upsilon_s=\frac{L_{u_E}^{-1}}{L_s^{-1}}\ =\frac{u_E'}{c_s}\ \frac{qR}{s}\ =\frac{\omega_s}{c_s}\ \frac{qR}{s}\
!| \end{equation}
!| is the Hamaguchi--Horton ${\bf E}\times{\bf B}$ flow shear parameter.
c
c	Hamaguchi-Horton ExB shearing stabilization model
c
	if (lexbs.eq.0) then
	  go to 400
        else if (lexbs.eq.1) then
c
c  cswitch(27)  2.0 exponent of Hamaguchi-Horton parameter in MMM99
c  cswitch(27)  1.0 coefficient of Hamaguchi-Horton parameter in MMM99
c
          zrls2 = (rminor(jz)/rmajor(jz)**2*grdq(jz))**cswitch(27)
          zwcs2 = 1.0364e-11*aimass(jz)/tekev(jz)
     &            *wexbs(jz)**cswitch(27)
          zhh = zrls2/max(zepslon, zrls2+zwcs2/cswitch(28)**2)
          yexbs(jz) = sqrt(zwcs2/max(zepslon, zrls2))
c        ion
          thiig(jz) = thiig(jz)*zhh
          thirb(jz) = thirb(jz)*zhh
          thikb(jz) = thikb(jz)*zhh
c        electron
          theig(jz) = theig(jz)*zhh
          therb(jz) = therb(jz)*zhh
          thekb(jz) = thekb(jz)*zhh
	  do j1 = 1, matdim
	  do j2 = 1, matdim
	    difthi(j1,j2,jz) = difthi(j1,j2,jz)*zhh
	  end do
	    velthi(j1,jz) = velthi(j1,jz)*zhh
	  end do
	end if
c
400     continue
c
!| \subsection{Edge modes}
c       Transport model for edge modes
c
        if (lrb.eq.0) then
!| \subsubsection{Guzdar-Drake Drift-Resistive Ballooning Model}
!|
!| The 1993 $\bf E \times B$ drift-resistive ballooning mode model by
!| Guzdar and Drake \cite{drake93} is selected
!| $$
!|   D^{DB} = -F_1^{RB}
!|   \left( 2\pi q_{a}^2 \right) \rho_e^2 \nu_{ei}\left( {R\over p}
!| \right)\left( {{d p }\over {d r}}\right)$$
!| where $F_1^{RB}=$ {\tt frb(1)}.  Here the normalize presure gradient scale
!| length has been substituted for the density gradient scale
!| given in their paper following a comment made by Drake at the
!| 1995 TTF Workshop\cite{drakecom2}.  Including diamagnetic and
!| elongation effects, the particle diffusivity is
!| $$
!|   D^{DB} =  F_1^{RB}\left( 2\pi q_{a}^2 \right) \rho_e^2 \nu_{ei}
!|   \frac{R_o}{L_p} c_9 \kappa^{c_{4}}  \eqno{\tt zgddb}
!| $$
!| where $\rho_e=v_e/\omega_{ce}$, $c_9 =$ {\tt cswitch(9)} and
!| and $c_4 =$ {\tt cswitch(4)}.
!|
!| The electron  and ion thermal diffusivities are taken equal taken to be
!| an adjustable fraction of the particle diffusivity.
!| $$
!|  \chi_e^{DB} =F_2^{RB} \left( 2\pi q_{a}^2 \right) \rho_e^2 \nu_{ei}
!|   \frac{R_o}{L_p}c_9 \kappa^{c_{4}}
!|   \eqno{\tt therb}
!| $$
!| $$
!|  \chi_i^{DB} = F_3^{RB}\left( 2\pi q_{a}^2 \right) \rho_e^2 \nu_{ei}
!|   \frac{R_o}{L_p} c_9 \kappa^{c_{4}}
!|   \eqno{\tt thirb}
!| $$  where $F_2^{RB}=$ {\tt frb(3)} and $F_3^{RB}=$ {\tt frb(3)}
!|
c
c..Guzdar-Drake theory (Phys Fluids B 5 (1993) 3712
c..L_p used instead of L_n
c
        zgyrfe = zce * zbtor / zcme  ! electron plasma frequency
        zlare = zvthe / zgyrfe    ! electron Larmor radius
c
c..   Diamagnetic stabilization
c
        zgddia = cswitch(9)
c
c..   Diffusivities
c
        zgdp = 2. * zpi * ((zq * zlare)**2.) * znuei
     &    * zgpr * 100. * zgddia

        thdrb(jz) = frb(1) * zgdp * zelonf**cswitch(4)
        therb(jz) = frb(2) * zgdp * zelonf**cswitch(4)
        thirb(jz) = frb(3) * zgdp * zelonf**cswitch(4)
        thzrb(jz) = frb(4) * zgdp * zelonf**cswitch(4)
c
        else if (lrb.eq.1) then
c
!| \subsubsection{Drift Alfv\'en Model from Bruce Scott}
c
c..Bruce Scott's drift Alfven model from 24 Sept 1998
c
      iswitchda = klswitch
c
        do j1=1,iswitchda
          isdasw(j1) = 0
          zsdasw(j1) = 0.0
        enddo
c
        zfldath = 0.0
        zfldanh = 0.0
        zfldate = 0.0
        zfldanz = 0.0
        zfldatz = 0.0
c
        zdfdath = 0.0
        zdfdanh = 0.0
        zdfdate = 0.0
        zdfdanz = 0.0
        zdfdatz = 0.0
c
        idim   = matdim
c
        zchrgns  = 1.0
c
        isdasw(1) = lsuper
c
          call sda05dif ( isdasw, zsdasw, iswitchda, idim
     &   , lprint, nprout
     &   , zgne, zgnh, zgnz, zgte, zgth, zgtz, zthte, ztzte
     &   , zfnzne, zimpz, zmzmh, zfnsne, zchrgns
     &   , zbetae(jz), znuhat, zq, zshat, zelong
     &   , zfldath, zfldanh, zfldate, zfldanz, zfldatz
     &   , zdfdath, zdfdanh, zdfdate, zdfdanz, zdfdatz
     &   , zdfthi, zvlthi
     &   , nerr )
c
c..Set total effective diffusivities
c
        znormd    = zsound * zrhos**2 / zrmaj
        znormv    = zsound * zrhos    / zrmaj
c
c  Note: temporarily we are using abs ( diffusio coeff )
c
        thdrb(jz) = frb(1) * abs(zdfdanh) * znormd * zne / zni
        therb(jz) = frb(2) * abs(zdfdate) * znormd
        thirb(jz) = frb(3) * abs(zdfdath) * znormd
     &    * zne * zte/(zni * zti)
        thzrb(jz) = frb(4) * abs(zdfdanh) * znormd * zne / zni
c
c
c  pzhu 23-dec-99 add polynormial transition function multiplier to th*rb
c
        xtrans0 = 0.7	!inner edge of transition layer
        xtrans1 = 0.8	!outer edge of transition layer
        xtrans = rminor(jz) / rminor(npoints)
        transprof = transfun(xtrans, xtrans0, xtrans1)
        thdrb(jz) = thdrb(jz) * transprof
        therb(jz) = therb(jz) * transprof
        thirb(jz) = thirb(jz) * transprof
        thzrb(jz) = thzrb(jz) * transprof
        end if
c
c  add to the fluxes
c
        vflux(1,jz) = vflux(1,jz) + thirb(jz) * zgth / zrmaj
        vflux(2,jz) = vflux(2,jz) + thdrb(jz) * zgnh / zrmaj
        vflux(3,jz) = vflux(3,jz) + therb(jz) * zgte / zrmaj
        vflux(4,jz) = vflux(4,jz) + thzrb(jz) * zgnz / zrmaj
c
        difthi(1,1,jz) = difthi(1,1,jz) + thirb(jz)
        difthi(2,2,jz) = difthi(2,2,jz) + thdrb(jz)
        difthi(3,3,jz) = difthi(3,3,jz) + therb(jz)
        difthi(4,4,jz) = difthi(4,4,jz) + thzrb(jz)
c
!| %**********************************************************************c
!| %
!| \subsection{Kinetic Ballooning}
c
c       Transport model for kinetic ballooning mode
c
        if (lkb.eq.0) then
!| \subsubsection{Kinetic Ballooning in MMM95}
!| For transport due to the kinetic ballooning mode, we compute $D^{KB}$ and
!| the thermal diffusivities in terms of the pressure gradient $\beta'$.
!| $$  D^{KB} = \frac{c_s \rho_s^2}{L_p} f_{\beta th} \quad
!| {\rm where}\qquad  f_{\beta th} = \exp \left[c_{2}\left( \frac{\beta '}
!| {\beta_{c1}'} -1 \right) \right] \eqno{\tt zdk}$$
!| and where $\beta_{cl}'$ is the ideal pressure gradient threshold for
!| the onset of the ideal ballooning mode in $s-\alpha$ geometry,
!| $$  \beta_{c1}' = c_{8} \hat{s}/(1.7 q^{2}R_{o}) \eqno{\tt zbc1} $$ \\[-2mm]
!| Here, $c_8=$ {\tt cswitch(8)=1}  by default, but is included for flexibility.
!| The coefficent $c_2$ in the expression for $f_{\beta th}$ is set equal to
!| {\tt cswitch(2)}.
!|
!| The diffusivities are then given as:
!| $$ D_{a}^{KB}=D^{KB}F^{KB}_{1}  \kappa^{c_{5}} \eqno{\tt thdkb} $$
!| $$ Q_{e}^{KB}\frac{L_{Te}}{n_{e}T_{e}}=D^{KB}F^{KB}_{2} \kappa^{c_{5}}  \eqno{\tt thekb} $$
!| $$ Q_{i}^{KB}\frac{L_{Ti}}{n_{i}T_{i}}=D^{KB}F^{KB}_{3} \kappa^{c_{5}}
!| \eqno{\tt thikb} $$
!| where $F_1^{KB}=$ {\tt fkb(1)}, $F_2^{KB}=$ {\tt fkb(2)},
!| $F_3^{KB}=$ {\tt fkb(3)}, and $c_5=$ {\tt cswitch(5)}.
!|  Note that the new version does not include
!| the (5/2) factor in the thermal diffusivities.
!|
!| \noindent
!| The relevant coding is:
!|
c ..................................
c .  the kinetic ballooning model  .
c ..................................
c
c       zbprim and zbc1 computed above under drift model
c
        cswitch(2)  =  3.5  ! for fbeta-th in kinetic ballooning
        cswitch(8)  =  1.0  ! coeff of beta_prime_1 in kinetic ballooning mode
c
        if (  abs(cswitch(2)) .gt. zepslon
     &   .and.  zgpr .gt. 0.0  ) then
c
c..Bateman 22 Feb 2002
c
c  cswitch(29) = minimum value of magnetic shear
c
        zshat1 = max ( zshat, cswitch(29) )
c
        zbprim = abs( zbeta(jz) * zgpr / zrmaj )
        zbcoef1 = 1.0
        if ( abs(cswitch(8)) .gt. zepslon ) zbcoef1 = cswitch(8)
        zbc1   = zbcoef1 * abs(zshat1)/(1.7*zq**2*zrmaj)
        zelfkb = zelonf**cswitch(5)
c
        zfbthn = exp( min(abs(zlgeps),
     &     max(-abs(zlgeps),cswitch(2)*(zbprim/zbc1 - 1.))) )
c
        zdk = abs( zsound * zrhos**2 * zfbthn * zgpr / zrmaj )
c
        thdkb(jz) = zdk*fkb(1)*zelfkb
        thekb(jz) = zdk*fkb(2)*zelfkb
        thikb(jz) = zdk*fkb(3)*zelfkb
        thzkb(jz) = zdk*fkb(4)*zelfkb
c
        end if
c
        else if (lkb.eq.1) then
c
!| \subsubsection{Kinetic Ballooning model in MMM98d}
!|
!| Transport driven by the kinetic ballooning mode is computed using
!| a mode developed by Aaron Redd \cite{redd98b}
!| multiplied by coefficients $F_1^{KB}=$ {\tt fkb(1)}, $F_2^{KB}=$ {\tt fkb(2)},
!| $F_3^{KB}=$ {\tt fkb(3)}.
!|
!| The relevant coding is:
!|
c ..................................
c .  the kinetic ballooning model  .
c ..................................
c
        cswitch(2) = 0.0  ! for fbeta-th in kinetic ballooning
        cswitch(8) = 0.0  ! coeff of beta_prime_1 in kinetic ballooning mode
c
      do j1=1,25
        ikbmodels(j1) = 0
        zkbmodels(j1) = 0.0
      enddo
c
      ikbmodels(17) = 2
c
c  zero out zbetac1 and zbetac2 since they are not used in
c    Aaron Redd's kinetic ballooning mode model
c
      zbetac1 = 0.0
      zbetac2 = 0.0
c
c  recompute zthte, zfnsne
c    as they were before calling the Weiland model above
c
      zthte = zti / zte
      zfnsne = max ( cswitch(16) * densfe(jz) / dense(jz) , 0.0 )
      zfnzne = znz / zne
c
      zchifact = zsound * zlari**2 / zrmaj
c
c  Use zshear rather than zshat to avoid minimum shear cthery(1)
c
c  define zepm to avoid radii too close to the magnetic axis
c
      zepm = max ( zep, 0.05 )
c
      call kbmodels(      ikbmodels, zkbmodels,
     &                    zq, zshear, zepm, zelong, zdelta, zgpr,
     &                    zbeta(jz), zbetac1, zbetac2,
     &                    zthte, zfnsne, zfnzne,
     &                    zchifact,
     &                    zchiikb, zchiekb, zdifhkb, zdifzkb,
     &                    nerr)
c
c
        thikb(jz) = fkb(3) * zchiikb
        thekb(jz) = fkb(2) * zchiekb
        thdkb(jz) = fkb(1) * zdifhkb
        thzkb(jz) = fkb(4) * zdifzkb
c
       end if
c
c  add to the fluxes
c
        vflux(1,jz) = vflux(1,jz) + thikb(jz) * zgth / zrmaj
        vflux(2,jz) = vflux(2,jz) + thdkb(jz) * zgnh / zrmaj
        vflux(3,jz) = vflux(3,jz) + thekb(jz) * zgte / zrmaj
        vflux(4,jz) = vflux(4,jz) + thzkb(jz) * zgnz / zrmaj
c
        if ( thikb(jz) .gt. 0.0 ) then
          difthi(1,1,jz) = difthi(1,1,jz) + thikb(jz)
        else
          velthi(1,jz) = velthi(1,jz) - thikb(jz) * zgth / zrmaj
        endif
c
        if ( thdkb(jz) .gt. 0.0 ) then
          difthi(2,2,jz) = difthi(2,2,jz) + thdkb(jz)
        else
          velthi(2,jz) = velthi(2,jz) - thdkb(jz) * zgnh / zrmaj
        endif
c
        if ( thekb(jz) .gt. 0.0 ) then
          difthi(3,3,jz) = difthi(3,3,jz) + thekb(jz)
        else
          velthi(3,jz) = velthi(3,jz) - thekb(jz) * zgte / zrmaj
        endif
c
        if ( thzkb(jz) .gt. 0.0 ) then
          difthi(4,4,jz) = difthi(4,4,jz) + thzkb(jz)
        else
          velthi(4,jz) = velthi(4,jz) - thzkb(jz) * zgnz / zrmaj
        endif
!| %**********************************************************************c
!| \subsection{Electron Temperature Gradient (ETG) Mode Model}
c
c       Transport model for ETG mode
c
        if (letg.eq.0) then
c
c       do nothing
c
        else if (letg.eq.1) then
!| \subsubsection{Horton's ETG mode model}
!| For transport due to the ETG mode, we compute the thermal diffusivities in terms
!| of the temperature gradient $\nabla T_e$. The electron thermal diffusivity $\chi_
!| e$ is electrostatic when the electron mixing length $l^{es}_{c,e}=q\rho_e\,\frac{
!| R}{L_{T_e}}$ is larger than the collisionless skin depth $\delta_e=c/\omega_e$,
!| i.e., $l^{es}_{c,e}>\delta_e$:
!| $$\chi_e^{es}=C_e^{es} q^2\left(\frac{R}{L_{T_e}}\right)^{3/2}\left(\frac{\rho_e^ 2v_{T_e}}{T_e}\right) \left[\nabla T_e-C_L\left(\frac{|s|T_e}{qR}\right)\left(1+\frac{T_e}{T_i}\right)\right]\eqno{\tt theeg}$$
!| and when $l^{es}_{c,e}<\delta_e$, the electron thermal diffusivity $\chi_e$ is electromagnetic:
!| $$\chi_e^{em}=C_e^{em}q^{\nu}\frac{c^2}{\omega_{pe}^2}\frac{v_e}{(L_{T_e} R)^{1/2 }}\quad \quad \beta_{pe}>\beta_{\rm crit}.\eqno{\tt theeg}$$
!| \noindent
!| The relevant coding is:
c
        zgyrfe = zce * zbtor / zcme
        zlare = zvthe / zgyrfe
        zwpe = 56.349 * sqrt(zne)
        zgamaeg (jz) = zvthe * sqrt(zgte) / zrmaj       !ETG max growth rate
        zlce(jz) = zq * zlare * zgte        !electron mixing length
        zdeltae(jz) = zcc / zwpe    !collisionless skin depth
        zgtec(jz) = cswitch(25)         !critical electron temperture gradient
     &                  * abs(zshear) / zq * zte / zrmaj
     &                  * (1. + zte / zti)
          if (zlce(jz) > zdeltae(jz)) then
            theeg(jz) = feg(3) * cswitch(24) * (zq * zlare)**2 * zvthe
     &                  * zgte * sqrt(zgte)
     &                  * max(0., (zgte / zrmaj  - zgtec(jz) / zte))
          else if (zlce(jz) < zdeltae(jz)) then
            theeg(jz) = feg(3) * cswitch(26) * zdeltae(jz)**2 * zvthe
     &                  * sqrt(zgte) / zrmaj
          end if
!| Taroni-Bohm electron thermal diffusivity
!| $$\chi_e^{Taroni}=3.3\times 10^{-4}q^2\frac{a}{L_{pe}}\frac{T_e(keV)}{B_T}\ \eqno{thetb} $$
!| is also computed for comparison (and further option).
!|
c
c       Taroni-Bohm electron thermal diffusivity
c
        thetb(jz) = 3.3e-1 * zq ** 2 * zep * (zgne + zgte) * zte / zbtor
c
        end if
c
        vflux(3,jz) = vflux(3,jz) + theeg(jz) * zgte / zrmaj
c        vflux(3,jz) = theeg(jz) * zgte / zrmaj
c
        difthi(3,3,jz) = difthi(3,3,jz) + theeg(jz)
c        difthi(3,3,jz) = theeg(jz)
c
 300  continue
c
cap {  change sing of convective velocities
cap
cap      do jz = 1, npoints
cap        do j1 = 1, 4
cap          velthi(j1, jz) = -velthi(j1, jz)
cap        enddo
cap      enddo
cap }
c
c
c   end of the main do-loop over the radial index, "jz"----------
c
c       diagnostic output
c
        if (iknthe.ge.3) then
c
        write(nprout, 1000)
        do jz = 1, npoints
        write(nprout, 1010) rminor(jz), wexbs(jz), yexbs(jz)
        end do
c
        write(nprout, 1020)
        do jz = 1, npoints
        write(nprout, 1030) rminor(jz), zlce(jz), zdeltae(jz)
     &  , zgamaeg(jz), zgtec(jz)
        end do
c
        end if
1000    format(/,3x,'radius',3x,'wexbs',3x,'yexbs')
1010    format(3x,0pf6.3,1x,2(1pe10.3,1x))
1020    format(/,3x,'radius',3x,'lce',3x,'deltae',3x,'gamaeg'
     &  ,3x,'gtec')
1030    format(3x,0pf6.3,1x,4(1pe10.3,1x))
c
      return
      end


        function transfun(x, x0, x1)
        implicit none
        real :: x
        real :: x0
        real :: x1
c
        real :: transfun
c
	real :: xi
c
	if (x0 .ge. x1) then
	  write(*,*)'transfun: error: x0 and x1 are not set right!'
        end if
c
        if (x .le. x0) then
          transfun = 0.0
        else if (x .ge. x1) then
          transfun = 1.0
	else
          xi = (x - x0) / (x1 - x0)
          transfun = xi * xi * (3.0 - 2.0 * xi)
	end if
c
      end function transfun
!|
!| %**********************************************************************c
!|
!| \begin{thebibliography}{99}
!|
!| \bibitem{bate98a}
!| Glenn Bateman, Arnold~H. Kritz, Jon~E. Kinsey, Aaron~J. Redd, and Jan Weiland,
!| ``Predicting temperature and density profiles in tokamaks,''
!| {\em Physics of Plasmas,} {\bf 5} (1998) 1793--1799.
!|
!| %\bibitem{Comments} C. E. Singer, ``Theoretical Particle and Energy
!| 0.000000lux Formulas for Tokamaks,'' Comments on Plasma Physics and Controlled
!| 0.000000usion {\bf 11} (1988) 165.
!|
!| \bibitem{nord90a} H. Nordman, J. Weiland, and A. Jarmen,
!| ``Simulation of toroidal drift mode turbulence driven by
!| temperature gradients and electron trapping,''
!| Nucl. Fusion {\bf 30} (1990) 983--996.
!|
!| %\bibitem{Singer} C.E.Singer, G.Bateman, and D.D.Stotler,
!| %``Boundary Conditions for OH, L, and H-mode Simulations,''
!| %Princeton University Plasma Physics Report PPPL-2527 (1988).
!|
!|
!| \bibitem{redd98b} A.~J.~Redd,
!| {\it Pressure-driven Transport in the Core of Tokamak Plasmas},
!| PhD Dissertation, Lehigh University Department of Physics (1998).
!|
!| \end{thebibliography}
!|
!| %**********************************************************************c
!| \end{document}              0.000000E+00nd of document.
!|
