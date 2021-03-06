!| %
!| % 21:00 30-Mar-98  Glenn Bateman and Jon Kinsey, Lehigh University
!| %
!| %  This is a LaTeX ASCII file.  To typeset document type: latex theory
!| %  To extract the fortran source code, obtain the utility "xtverb" from
!|  0lenn Bateman (bateman@pppl.gov) and type:
!| 0tverb < theory.tex > theory.f
!| %
!| \documentstyle{article}    % Specifies the document style.
!| \headheight 0pt \headsep 0pt  \topmargin 0pt  \oddsidemargin 0pt
!| \textheight 9.0in \textwidth 6.5in
!| 
!| \title{ {\tt theory}: a BALDUR Subroutine \\ % The preamble begins here.
!|  for Computing Theory-based Tokamak \\
!|  Particle and Energy Fluxes}     % title.
!| \author{E. S. Ghanem, C. E. Singer, \\ University of Illinois \\ \\
!|         Jon Kinsey, Glenn Bateman,  \\ Lehigh University
!|         }
!|                             0eclares the author's name.
!|                             0eleting the \date{} produces today's date.
!| \begin{document}            0.000000E+00nd of preamble and beginning of text.
!| \maketitle                 % Produces the title.
!| 
!| This report documents a subroutine called {\tt theory}, which computes plasma
!| transport coefficients using various microinstability theory-based models.
!| The default model used in subroutine {\tt theory} was developed by
!| C.~E. Singer as documented in
!| ``Theoretical Particle and Energy Flux Formulas for Tokamaks,''
!| Comments on Plasma Physics and Controlled Fusion, {\bf 11}, 165 (1988)
!| (\cite{Comments}, hereafter referred to as the Comments paper).
!| 
c@theory.tex
c--------1---------2---------3---------4---------5---------6---------7-c
c
      subroutine theory( lthery, cthery
     & , maxis, medge, mseprtx, matdim
     & , rminor, rmajor, elong, triang
     & , dense, densi, densh, densimp, densf, densfe
     & , xzeff, tekev, tikev, tfkev, q, vloop, btor, resist
     & , avezimp, amassimp, amasshyd, aimass, wexbs
     & , grdne, grdni, grdnh, grdnz, grdte, grdti, grdpr, grdq
     & , fdr, fig, fti, frm, fkb, frb, fhf, fec, fmh, fdrint
     & , dhtot, vhtot, dztot, vztot, xetot, xitot, weithe
     & , difthi, velthi
     & , nstep, time, nprint, lprint)
c
c  lthery(jc), j=1,50    integer control variables (see below)
c  cthery(jc), jc=1,150  general control variables (see below)
c  maxis   = zone boundary at magnetic axis
c  medge   = zone boundary at edge of plasma
c  mseprtx = zone boundary at separatrix
c
c  matdim  = first and second dimension of transport matricies
c              difthi(j1,j2,jz) and velthi(j1,jz)
c
cbate     & , slne, slni, slnh, slnz, slte, slti, slpr, sshr
c
c    All the following 1-D arrays are assumed to be on zone boundaries
c    including the densities (in m^-3) and temperatures (in keV).
c
c  rminor(jz) = minor radius (half-width) of zone boundary (m)
c  rmajor(jz) = major radius to geometric center of zone bndry (m)
c  elong(jz)  = local elongation of zone boundary
c  triang(jz) = triangularity of zone boundary
c
c  aimass(jz) = mean atomic mass of thermal ions (AMU)
c  dense(jz)  = electron density (m^-3)
c  densi(jz)  = thermal ion density (m^-3)
c  densh(jz)  = thermal hydrogen ion density (m^-3)
c  densimp(jz) = sum over impurity ion densities (m^-3)
c  densf(jz)  = fast (non-thermal) ion density (m^-3)
c  densfe(jz) = electron density from fast (non-thermal) ions (m^-3)
c  xzeff(jz)  = Z_eff
c  tekev(jz)  = T_e (keV)  (electron temperature)
c  tikev(jz)  = T_i (keV)  (temperature of thermal ions)
c  tfkev(jz)  = T_f (keV)  (effective temperature of fast ions)
c  q(jz)      = magnetic q-value
c  vloop(jz)  = loop voltage  (volts)
c  btor(jz)   = ( R B_tor ) / rmajor(jz)  (tesla)
c  resist(jz) = plasma resistivity ( Ohm m )
c
c  avezimp(jz) = average density weighted charge of impurities
c  amassimp(jz) = average density weighted atomic mass of impurities
c  amasshyd(jz) = average density weighted atomic mass of hydrogen ions
c
c  wexbs(jz)   = ExB shearing rate in [rad/s]
c
c    All of the following normalized gradients are at zone boundaries.
c    r = half-width, R = major radius to center of flux surface
c    carry out any smoothing before calling sbrtn theory
c
c  grdne(jz) = R ( d n_e / d r ) / n_e
c  grdni(jz) = R ( d n_i / d r ) / n_i
c     n_i = thermal ion density (sum over hydrogenic and impurity)
c  grdnh(jz) = R ( d n_h / d r ) / n_h
c     n_h = thermal hydrogenic density (sum over hydrogenic species)
c  grdnz(jz) = R ( d Z n_Z / d r ) / ( Z n_Z )
c     n_Z = thermal impurity density,  Z = average impurity charge
c           sumed over all impurities
c  grdte(jz) = R ( d T_e / d r ) / T_e
c  grdti(jz) = R ( d T_i / d r ) / T_i
c  grdpr(jz) = R ( d p   / d r ) / p    for thermal pressure
c  grdq (jz) = R ( d q   / d r ) / q    related to magnetic shear
c
c  fdr,..., fmh  coefficients for transport contributions (see below)
c
c  dhtot(jz)   = hydrogenic diffusivity ( m^2/sec )  (output)
c  vhtot(jz)   = hydrogenic convective velocity ( m/sec )  (output)
c  dztot(jz)   = impurity diffusivity ( m^2/sec )  (output)
c  vztot(jz)   = impurity convective velocity ( m/sec )  (output)
c  xetot(jz)   = electron thermal diffusivity ( m^2/sec ) (output)
c  xitot(jz)   = ion thermal diffusivity ( m^2/sec )  (output)
c  weithe(jz)  = anomalous electron-ion equipartition (output)
c
c  nstep  = current time-step
c  time   = current time (sec)
c
c  nprint = output unit number for long printout
c  lprint controls the amount of printout ( 0 -> no printout)
c           higher values yield more diagnostic printout
c  mprint = 0 no printout from etaw14.f
c
c   The input control variables are documented on the following lines:
c
c  Input control variables:
c  ------------------------
c
c     contributions to fluxes and interchanges: (all defaults = 0.0)
c
c  fdr(1)   particle transport from drift modes (trapped electron)
c  fdr(2)   electron thermal transport from drift modes (trapped electron)
c  fdr(3)   ion      thermal transport from drift modes (trapped electron)
c
c  fig(1)   particle transport from ITG (eta_i) mode
c  fig(2)   electron thermal transport from ITG (eta_i) mode
c  fig(3)   ion      thermal transport from ITG (eta_i) mode
c
c  fti(1)   particle transport from trapped ion modes
c  fti(2)   electron thermal transport from trapped ion modes
c  fti(3)   ion      thermal transport from trapped ion modes
c
c  frm(1)   particle transport from rippling mode
c  frm(2)   electron thermal transport from rippling mode
c  frm(3)   ion      thermal transport from rippling mode
c
c  frb(1)   particle transport from resistive ballooning mode
c  frb(2)   electron thermal transport from resistive ballooning mode
c  frb(3)   ion      thermal transport from resistive ballooning mode
c
c  fkb(1)   particle transport from kinetic ballooning mode
c  fkb(2)   electron thermal transport from kinetic ballooning mode
c  fkb(3)   ion      thermal transport from kinetic ballooning mode
c
c  fhf(1)   particle transport from the eta_e mode
c  fhf(2)   electron thermal transport from the eta_e mode
c  fhf(3)   ion      thermal transport from the eta_e mode
c
c  fmh(1)   particle transport from the neoclassical mhd mode
c  fmh(2)   electron thermal transport from the neoclassical mhd mode
c  fmh(3)   ion thermal transport from the neoclassical mhd mode
c
c  fec(1)   particle transport from the circulating electron mode
c  fec(2)   electron thermal transport from the circulating electron mode
c  fec(3)   ion thermal transport from the circulating electron mode
c
c  fdrint   electron-ion energy interchange coefficient
c
c
c     lthery(j), j=1,50   integer control variables: (all defaults = 0)
c
c  lthery(1)  = 0 for the original shear scale length model
c
c  lthery(2)  = 1 to extrapolate density * diffusivity to edge grid point
c
c  lthery(3)  = 0 to set zln = zlnj = zlne (electron density scale length)
c             = 1   set zln = zlne and zlnj = zlni
c             = 2   set zln = zlnj = zlni (thermal ion density scale length)
c             = 3   use zlnh in sbrtn etaw14
c             = 4   use zlnh and zlnz in sbrtn etaw14
c
c  lthery(4)  = 0 to use Spitzer resistivity throughout (default)
c             = 1 to use neoclassical resistivity computed elsewhere
c
c  lthery(5)  < 0 for no model
c             = 0 for the original dissipative trapped electron mode
c             = 1 for the Hahm-Tang trapped electron mode theories
c                   implemented by Bateman (1990)
c  lthery(6)  < 0 for no model
c             = 0 for the original collisionless trapped electron mode
c             = 1 for min [ c_{20}, c_{21} 0.1 / \nu_e^* ] transition
c                     suggested by Greg Rewoldt
c                   Implementations by M. Redi and J. Cummings (1990):
c             = 2 for the Hahm-Tang CTEM/DTEM model (IAEA 1990).
c             = 3 for original CTEM with no transition
c             = 4 for Hahm-Tang CTEM only
c             = 5 for Kadomtsev-Pogutse DTEM model
c             = 6 for K-P model with Rewoldt transition
c             = 7 for Hahm-Tang CTEM with Rewoldt transition
c             = 8 for Hahm-Tang CTEM with K-P DTEM
c  lthery(7)  < 0 for no model
c             = 0 for the original eta_i mode
c             = 1 for Lee-Diamond eta_i mode transport
c             = 2 for Hamaguchi-Horton eta_i mode
c             = 4 for Ottaviani-Horton-Erba ``Santa Barbara'' eta_i mode
c             = 6 for Kim-Horton eta_i mode
c             = 10 for Weiland-Nordman NF 30 (1990) 983 eta_i model
c             = 11 for both eta_i and TEM models from NF 30 (1990) 983
c                  Note: this option overrides previous TEM models
c             = 12 Full matrix form of Weiland-Nordman model
c                  Note: effective diffusivities are computed only for
c                    diagnostic purposes
c             = 21 Weiland model Hydrogen \eta_i mode only
c             = 22 Weiland model with Hydrogen and trapped electrons
c             = 23 Weiland model Hydrogen, trapped electrons,
c                    and one impurity species
c             = 24 Weiland model Hydrogen, trapped electrons,
c                  one impurity species, and collisions
c             = 25 Weiland model Hydrogen, trapped electrons,
c                  one impurity species, collisions, and parallel
c                  ion (hydrogenic) motion
c             = 26 Weiland model Hydrogen, trapped electrons,
c                  one impurity species, collisions, and finite beta
c             = 27 Weiland model Hydrogen, trapped electrons,
c                  one impurity species, collisions, parallel
c                  ion (hydrogenic) motion, and finite beta
c             = 28 Weiland model Hydrogen, trapped electrons,
c                  one impurity species, collisions, parallel
c                  ion (hydrogenic, impurity) motion, and finite beta
c
c  lthery(8)  < 0 for no model
c             = 0 for the original threshold for the eta_i mode
c             = 1 for Mattor-Diamond, Hahm-Tang threshold
c             = 2 for Dominguez-Rosenbluth threshold
c             = 20 normalize diffusivity matrix with velthi = 0.0
c             > 20 use effective diffusivities and set difthi=velthi=0.0
c
c  lthery(9)  < 0 for no model
c             = 0 for the original form of f_{ith}
c             = 1 for (\eta_i-\eta_i^{th})/\eta_i^{th}
c             = 2 for linear ramp form of f_{ith}
c
c  lthery(10) = 0 for the original rippling mode
c  lthery(11) = 0 for the original \chi_e^{RM} rippling mode
c             = 1 for estimate of \chi_e^{RM} from Hahm, Diamond, et al
c                   PF 30 (1987) 1452 [Eq (53]
c
c  lthery(12) = 1 use (1+\kappa^2)/2 instead of \kappa scaling
c                 otherwise use \kappa scaling
c                 raised to exponents (cthery(12) - ctheory(16))
c
c  lthery(13) = 0 for the original resistive ballooning mode
c             = 1 Carreras-Diamond PF B 1 (1989) 1011-1017
c                   model for resistive ballooning modes
c             = 2 hybrid of new and old resistive ballooning mode models
c             = 3 Guzdar-Drake drift/resistive ballooning model
c             = 4 Bruce Scott's Drift Alfven model
c
c  lthery(14) = 0 single iteration approximation for lambda
c                   in the Carreras-Diamond resistive ballooning mode
c             = n for n iterations for lambda in RB mode
c
c  lthery(15) = 1 for neoclassical MHD driven transport
c             = 2 for neoclassical MHD with Callen corrections
c
c  lthery(16) = 1 for the circulating electron/high-m tearing modes
c                 cthery(82) multiplies contribution from high-m tearing
c
c  lthery(17) = 0 for the original kinetic ballooning mode
c             = 1 for 1995 kinetic ballooning mode
c
c  lthery(19) > 1 to smooth fast ion relative density lthery(19) times
c
c  lthery(20) = 0 for the original eta_e mode
c
c  lthery(21) < 1 to call sbrtn theory
c             = 1 for sbrtn mmm95 rather than sbrtn theory
c             = 2 for sbrtn mmm98
c             = 3 for sbrtn mmm98b
c             = 4 for sbrtn mmm98c
c             = 5 for sbrtn mmm98d
c             = 6 for sbrtn ohe model
c             = 7 for sbrtn mixed_merba
c             = 8 for sbrtn mixed_model (Mixed Bohm/gyro-Bohm model)
c             = 9 for sbrtn mmm99
c             = 10 for sbrtn mmm95a
c
c  lthery(22) = 0 for the default Weiland model in sbrtn theory
c             = -1 weiland14 called from sbrtn theory
c             = -2 etaw14diff called from sbrtn theory
c             = -3 etaw14a called from sbrtn theory
c             = -4 etaw17diff called from sbrtn theory
c             = -5 etaw17a called from sbrtn theory
c
c  lthery(23) = 0 use major radius to geometric center of flux surfaces
c             = 1 use major radius to outboard edge of flux surfaces
c
c  lthery(24) = 1  to set desnsi = densh + densimp
c                    and grdni = grdnh + grdnz
c                    and grdpr = grdti + grdni + grdte + grdne
c
c  lthery(25) = 1 for the Rebut-Lallia-Watkins model
c
c  lthery(26) =   timestep for diagnostic output for etaw* model
c
c  lthery(27) > 0 to replace negative diffusivity with velocity
c
c  lthery(28) > 0 to smooth diffusivities lthery(28) times
c
c  lthery(29) = 0 to minimize diagnostic printout
c             > 0 larger values produce more diagnostic printout
c
c  lthery(30) = 0 take absolute value of gradient scale lengths
c             = 1 to retain sign of gradient scale lengths
c
c  lthery(31) = 1 to make r * ( gradient scale lengths ) monotonic
c                   near the magnetic axis by changing value at maxis+1
c
c  lthery(32) = 0 for the original gradient scale lengths
c             .gt. 0 for smoothing over lthery(32) orders (like lsmord)
c             .lt. 0 to smooth 1 / gradient scale lengths
c
c  lthery(33) = 0 print unsmoothed gradient scale lengths
c             .gt. 0 to print smoothed values
c
c    The following switches control mmm99, called when lthery(21) = 9
c
c  lthery(34) = 0 use sbrtn weiland14 from mmm95 for ITG mode in mmm99
c             = 1 use etaw17 from mmm98d for ITG in mmm99
c
c  lthery(35) = 0 use Guzdar-Drake resistive balloong mode
c                   from mmm95 in mmm99
c             = 1 use drift Alfven mode (Scott model) from MMM98d
c                   in mmm99
c
c  lthery(36) = 0 use old kinetic ballooning mode from MMM95 in mmm99
c             = 1 use new kinetic ballooning mode (by Redd) from MMM98d
c                   in mmm99
c
c  lthery(37) = 0 use Hahm-Burrel ExB shearing rate to substract
c                   from weiland model growth rates in mmm99
c             = 1 use Hamaguchi-Horton ExB shearing parameter
c                   to multiply all long-wavelength transport coeffs
c                   in mmm99
c
c  lthery(38) = 0 do not use any ETG model in mmm99
c             = 1 use Horton's ETG model in mmm99
cap
c  lthery(39) >=0 use zxithe, zvithe ... rather than difthi/velthi
c             < 0 use difthi/velthi rather than zxithe, zvithe ...
c
c             |...| 5   don't produce transport matrix, only eff.diffusiv.
c                       (default)
c                   3   only diagonal elements of diffusion matrix
c                   1   full diffusion matrix
c                  x2   rescale transport matrix with velthi=0
c                  x1   don't rescale transport matrix with velthi=0
c                       (default)
c
c  lthery(40)  = 0  (default) do not include E&M effects in Weiland model
c                1  include E&M effects in Weiland model
c
c  lthery(41)  = 0  (default) do not multiply zchieff(1) by znh/zni
c                1  multiply zchieff(1) by znh/zni in mmm99.tex
c
c  lthery(46)       poloidal velocity model
c              = 0/3 (default) ZHS model
c                1  Strand model
c                2  Erba model
c
c  lthery(47)       LH transition criteria
c              = 0  power criteria
c                1  electron temperature criteria
c
c
c*************
c
c     cthery(j), j=1,150  general control variables:
c
c  variable  default  meaning
c  --------  -------  -------
c
c  cthery(1)  0.0  divertor shear
c  cthery(2)  1.0  radius of artificial separatrix relative to BALDUR
c                    separatrix
c  cthery(3)  0.5  minimum shear
c  cthery(4)  0.0  logarithmic gradient of Zeff
c  cthery(5)  6.0  fully charged state of impurity
c  cthery(6)  1.0  coefficient of f_{ith} used to cut off \eta_i mode
c  cthery(7)  6.0  f_{ith} = 1./(1. + exp[-cthery(7)*(\eta_i-\eta_i^{th})])
c                  or when lthery(9)=2, cthery(7) controls the width
c                  of the linear ramp starting from \eta_i^{th}
c  cthery(8)  6.0  coeff cutoff of kinetic ballooning mode in CPP Eq. (58)
c  cthery(9)  6.0  coeff in cutoff of \eta_e mode in CPP Eq. (63)
c  cthery(10) 0.0
c  cthery(11) 1.0  minimum value of \eta_i^{th} CPP (34) when lthery(8)=0
c  cthery(12) 0.0  exponent of local elongation multiplying drift waves
c  cthery(13) 0.0  exponent of local elongation multiplying rippling mode
c  cthery(14) 0.0  exponent of local elongation multiplying resistive
c                    balllooning modes
c  cthery(15) 0.0  exponent of local elongation multiplying
c                    kinetic balllooning modes
c  cthery(16) 0.0  exponent of local elongation multiplying eta_e mode
c  cthery(17) 1.0  coef of convective flux subtracted from thermal flux
c  cthery(19) -1.5 coefficient of f_ith added to 5/2 in drift wave
c                    electron thermal diffusivity
c  cthery(20) 1.0  transition from collisional to collisionless
c                    trapped electron mode in CPP Eq. 37 in \hat{D}_{te}
c  cthery(21) 1.0  coef of \omega^*_e/\nu_{eff} in \hat{D}_{te}
c                  or 0.1 / \nu_{e*} in \hat{D}_{te} when lthery(6)=1
c  cthery(22) 0.0  exp[-cthery(22)*(Ti/Te-1)**2] multiplying TEM
c  cthery(23) 0.95 Numerical correction in D^{DR} in Rewoldt TEM model
c
c  cthery(24) 0.0  multiplies $D_i^{RLW}$ Rebut-Lallia-Watkins model
c  cthery(25) 0.0  multiplies $\chi_e^{RLW} Rebut-Lallia-Watkins model
c  cthery(26) 0.0  multiplies $\chi_i^{RLW} Rebut-Lallia-Watkins model
c  cthery(27) 0.0  exponent of local elongation multiplying RLW model
c
c  cthery(29) 0.0  multiplies threshold \eta_i in OHE model
c
c  cthery(30) 1.0  baseline \eta_i^{th} when lthery(8)=1
c  cthery(31) 1.9  coeff of (1+T_i/T_e) L_n/L_s when lthery(8)=1
c                    \eta_i threshhold by Mattor-Diamond, Hahm-Tang
c  cthery(33) 0.0  collisional cutoff in Lee-Diamond \chi_e^{IG} \eta_i-mode
c
c  cthery(34) 0.0  exp[-cthery(34)*(Ti/Te-1)**2] multiplying eta_i mode
c                   (suggested by R. Dominguez, 24 April 1990)
c  cthery(35) 0.0  exp[ - min ( cthery(35) * Ln , cthery(36) * L_Ti ) / Ls ]
c  cthery(36) 0.0    in Hamaguchi-Horton theory \eta_i mode theory
c  cthery(37) 0.0  eta_i mode diffusivities multiplied by q(jz)**cthery(37)
c  cthery(38) 0.0  k_y \rho_s (= 0.316 if abs(cthery(38)) < zepslon)
c  cthery(39) 0.0  gammain for sbrtn e3bsub
c
c  cthery(41) 5.0  toroidal mode number for resistive ballooning modes
c  cthery(42) 0.0  coeff of f_\star in resistive ballooning mode CPP (52-53)
c  cthery(43) 0.0  exponential used in diamagnetic res ball mode stabilization
c                    zfdias = ( 1. + cthery(42) * zfstar )**(-cthery(43))
c                    should be 1./4. (old theory) to 1./6. (new theory)
c  cthery(44) 0.0  \chi_e = \chi_e^{RB} + cthery(44) * D^{RB} + ...
c  cthery(45) 0.0  correction applied to resistive ballooning mode
c                    diffusivity to more closely match analytic solution
c                    (use cthery(45) = 1.0 for normal correction)
c  cthery(47) 8.0  exponent of q in denominator of lambda in RB model'
c  cthery(48) 0.69135 used to approximate lambda with single iteration
c  cthery(49) 1.0  exponent of shear in D^{RB} in RB model
c
c     The following effects are turned on only when cthery(*) .gt. zepslon
c  cthery(50) 0.0  upper bound on L_{ne} / R_{major}
c  cthery(51) 0.0  upper bound on L_{ni} / R_{major}
c  cthery(52) 0.0  upper bound on L_{Te} / R_{major}
c  cthery(53) 0.0  upper bound on L_{Ti} / R_{major}
c  cthery(54) 0.0  upper bound on L_{p } / R_{major}
c
c  cthery(56) 0.0  upper bound on eta_e
c  cthery(57) 0.0  upper bound on eta_i
c
c  cthery(60) 0.0  limits local rate of change of ITG mode diffusities
c  cthery(61) 0.0  limits local rate of change of TEM mode diffusities
c
c  cthery(68) 0.0  convective coefficient for electron thermal transport
c  cthery(69) 0.0  convective coefficient for ion thermal transport
c     Note:  many theories have convection built into the total thermal
c     diffusivities.  cthery(68) and cthery(69) are the coefficients of
c     any additional convective thermal transport (ie, 3/2 or 5/2).
c
c  cthery(70) 1.0  Multiplier in neoclassical mhd - zgammh
c  cthery(71) 0.0  Elongation exponent in neoclassical mhd
c  cthery(72) 0.0  coef of chi_e^{NM} added to D^{NM}
c  cthery(73) 0.0  coef of D_p^{NM} added to \chi_e^{NM}
c  cthery(74) 0.0  coef of chi_e^{NM} added to \chi_i^{NM}
c  cthery(75) 1.0  coeff of \omega_*^2/\gamma^2 in diamagnetic stabilization
c  cthery(76) 0.0  exponential used in diamagnetic stabilization
c                  zfdia3 = (1.+cthery(75)*\omega_*^2/\gamma^2)^cthery(76)
c  cthery(77) 1.0  toroidal mode number = max [ 1.0, cthery(77) ]
c
c  cthery(78) 1.0  coeff of beta_prime_1 in kinetic ballooning mode
c  cthery(79) 1.0  coeff of beta_prime_2 in kinetic ballooning mode
c  cthery(80) 0.0  multiplier in D^{CE}
c  cthery(81) 0.0  elongation exponent in circulating electron mode
c  cthery(82) 0.0  multiplier in high-m tearing
c  cthery(83) 0.0  elongation exponent in high-m tearing
c
c  cthery(85) 2.0  diamagnetic correction to Guzdar-Drake model
c                  = 1.0 analytic expression for alpha
c                  = 2.0 to prescribe alpha using c_86
c  cthery(86) 0.15 alpha in diamagnetic stabilization in GD model
c
c  cthery(87)  0.0 ( normalized gradient pressure )**cthery(87)
c                  in the drift Alfven mode from Bruce Scott
c  cthery(88)  0.0 diagnostic printout time
c
c  cthery(111) 0.0 transfer from thigi(jz) to velthi(1,jz)
c  cthery(112) 0.0 transfer from zddig(jz) to velthi(2,jz)
c  cthery(113) 0.0 transfer from thige(jz) to velthi(3,jz)
c  cthery(114) 0.0 transfer from zdzig(jz) to velthi(4,jz)
c
c  cthery(119) 1.0 include effect of finite beta in etaw14
c  cthery(120) 0.0 min value of impurity charge state zimpz
c  cthery(121) 0.0 include superthermal ions
c  cthery(122) 0.0 -> 1.0 for effect of elongation in etaw16
c  cthery(123) 1.0 effect of parallel ion motion in etaw14
c  cthery(124) 0.0 -> 1.0 for effect of collisions in etaw14
c  cthery(125) 0.0 -> 1.0 for v_parallel in strong ballooning limit
c  cthery(126) 0.0 trapping fraction used in etaw14 (when > 0.0)
c                  multiplies electron trapping fraction when < 0.0
c  cthery(127) 0.0 fraction of computed diffusivities to be mixed with
c                    smoothed diffusivities
c  cthery(128) 0.0 tolerance used in eigenvalue finder in sbrtn etaw14
c  cthery(129) 0.0 multiplier for flow shear rate wexbs
c  cthery(130) 0.0 -> 1.0 adds impurity heat flow to total ionic heat
c                  flow for the weiland model
c***********************************************************************
c
c
      include 'cparm.m'
      integer kr, kn, kd, kc
c
      parameter ( kr = mj, kn = 6, kd = 9, kc = 150 )
c
c  kr = max number of radial grid points
c  kn = max number of charged particle species
c  kd = max number of transport matrix elements (transport channels)
c  kc = max number of elements in conrol arrays cthery and lthery
c
      real  cthery(*)
     & , rminor(*), rmajor(*), elong(*), triang(*)
     & , aimass(*), dense(*), densi(*), densh(*), densimp(*)
     & , densf(*), densfe(*)
     & , xzeff(*), tekev(*), tikev(*), tfkev(*)
     & , q(*), vloop(*), btor(*), resist(*)
     & , avezimp(*), amassimp(*), amasshyd(*), wexbs(*)
     & , grdne(*), grdni(*), grdnh(*), grdnz(*)
     & , grdte(*), grdti(*), grdpr(*), grdq(*)
cbate     & , slne(*), slni(*), slnh(*), slnz(*)
cbate     & , slte(*), slti(*), slpr(*), sshr(*)
c
      real
     &   fdr(*), fig(*), fti(*), frm(*), fkb(*), frb(*)
     & , fhf(*), fec(*), fmh(*)
     & , dhtot(*), vhtot(*), dztot(*), vztot(*)
     & , xetot(*), xitot(*)
     & , weithe(*)
     & , difthi(matdim,matdim,*), velthi(matdim,*)
c
      real time
c
      integer lthery(*), maxis, medge, mseprtx, matdim
     &  , nstep, nprint, lprint, mprint
c
c..physical and computer constants
c
      real zpi, zcc, zcmu0, zceps0, zckb, zcme, zcmp, zce
     &  , zepslon, zepsinv, zlgeps, zepsqrt
c
      save zpi, zcc, zcmu0, zceps0, zckb, zcme, zcmp, zce
     &  , zepslon, zepsinv, zlgeps, zepsqrt
c
c  zpi    = pi
c  zcc    = speed of light ( m / sec )
c  zcmu0  = vacuum magnetic permeability   ( henrys / m )
c  zceps0 = vacuum electrical permittivity ( farads / m )
c  zckb   = Joule / keV
c  zcme   = electron mass ( kg )
c  zcmp   = proton mass ( kg )
c  zce    = electron charge ( Coulomb )
c  zepslon = machine epsilon ( smallest number st 1.0+zepslon > 1.0 )
c  zepsinv = 1.0 / zepslon
c  zlgeps  = ln ( zepslon )
c  zepsqrt = sqrt ( zepslon )
c
      real
     &   thdre(mj) , thrme(mj) , thrbe(mj) , thkbe(mj) , thhfe(mj)
     & , thdri(mj) , thrmi(mj) , thrbi(mj) , thkbi(mj) , thhfi(mj)
     & , thige(mj) , thigi(mj) , thtie(mj) , thtii(mj)
     & , threti(mj), thdinu(mj), thfith(mj), thdte(mj) , thdi(mj)
     & , thbeta(mj), thlni(mj) , thlti(mj) , thdia(mj) , thnust(mj)
     & , thlsh(mj),  thlpr(mj),  thlarp(mj), thrhos(mj), thrstr(mj)
     & , thvthe(mj), thvthi(mj), thsoun(mj), thalfv(mj), thtau(mj)
     & , thbpbc(mj), thetth(mj), thsrhp(mj), thdias(mj), thlamb(mj)
     & , thrlwe(mj), thrlwi(mj), thnme(mj),  thnmi(mj), thhme(mj)
     & , thcee(mj), thcei(mj)
     & , thrbgb(mj), thrbb(mj),  thvalh(mj)
c
c
c..variables in common blocks /comth*/
c
c                 electron/ion thermal diffusivity from:
c  thdre/i(j)   drift waves (trapped electron modes)
c  thige/i(j)   ion temperature gradient (eta_i) modes
c  thtie/i(j)   trapped ion modes
c  thrme/i(j)   rippling modes
c  thrbe/i(j)   resistive ballooning modes
c  thrbgb,thrbb(j)   gyro-Bohm and Bohm contributions to res. ball.
c  thkbe/i(j)   kinetic ballooning modes
c  thhfe/i(j)   eta_e mode
c  thrlwe/i(j)  Rebut-Lallia-Watkins model
c
c  thdte(j)  = D_{te}
c  thdi(j)   = D_i
c
c    Lengths:
c  thlni(j)  = L_{ni}
c  thlti(j)  = L_{T_i}
c  thlsh(j)  = L_s = R q / s\hat
c  thlpr(j)  = L_p
c  thlarp(j) = \rho_s
c  thrhos(j) = \rho_{\theta i}
c
c    Velocities:
c  thvthe(j) = v_{the}
c  thvthi(j) = v_{thi}
c  thsoun(j) = c_s
c  thalfv(j) = v_A
c
c     Dimensionless:
c  thnust(j) = \nu_e^*
c  thrstr(j) = \rho_* = \rho_s/a
c  thbeta(j) = \beta
c  threti(j) = \eta_i
c  thsrhp(j) = S = \tau_R / \tau_{hp} = r^2 \mu_0 v_A / ( \eta R_0 )
c
c  thdinu(j) = \omega_e^\ast / \nu_{eff}
c  thetth(j) = \eta_i^{th}  threshold for \eta_i mode
c  thfith(j) = f_{ith} as in eq (35)
c  thbeta(j) = thbpbc(j) = \beta^{\prime} / \beta_{c1}^{\prime}
c  thdia(j)  = \omega_e^\ast / k_\perp^2
c  thdias(j) = resistive ballooning mode diamagnetic stabilization factor
c  thlamb(j) = \Lambda in Carreras-Diamond resistive ballooning mode
c              model PF B1 (1989) 1011-1017.
c  thvalh(j) = array of Hahm model criterion values
c
c
      dimension zfstarrb(mj), zfdiarb(mj), zgdtot(mj), zgdlp(mj)
     & , zalphz(mj), zdelez(mj), zlambz(mj), zflamz(mj)
     & , znuiz(mj), zcmiz(mj), zgammz(mj), zfgamz(mj), zfdiaz(mj)
     & , zxnmz(mj), zexbnz(mj), zwstrnm(mj), zprfmx(mj), zfnsnea(mj)
c
      dimension  zrhois(mj), zrsist(mj), ztcrit(mj)
     & , zmlne(mj), zmlni(mj), zmlte(mj), zmlti(mj), zmshr(mj)
     & , zslne(mj), zslni(mj), zslte(mj), zslti(mj), zsshr(mj)
     & , zmlnh(mj), zlnhs(mj), zslnh(mj), zslpr(mj)
     & , zrhozs(mj), zlnzs(mj), zmlnz(mj), zslnz(mj)
c
      save zslne, zslni, zslnh, zslnz, zslte, zslti, zslpr, zsshr
c
      dimension zh1tem(mj), zk1tem(mj), zhdtem(mj), zhctem(mj)
     & , zddtem(mj), zdztem(mj), zd1tem(mj), zddig(mj), zdzig(mj)
     & , zchie(mj), zchii(mj), zdifh(mj), zdifz(mj)
     & , zdshat(mj), zdnuhat(mj), zdbetae(mj)
     & , zdbetah(mj), zdbetaz(mj), zkpar(mj)
c
c zddig(jz) = hydrogen diffusivity from eta_i mode
c zdzig(jz) = impurity diffusivity from eta_i mode
c zchie(jz) = total effective electron thermal diffusivity for printout
c zchii(jz) = total effective ion      thermal diffusivity for printout
c zdifh(jz) = total effective hydrogen diffusivity for printout
c zdifz(jz) = total effective impurity diffusivity for printout
c zprfmx(jz) = maximum performance index
c zfnsnea(jz) = densfe(jz) / dense(jz)
c
      dimension  zgmitg(mj), zomitg(mj), zgm2nd(mj), zom2nd(mj)
     &  , zgmtem(mj), zomtem(mj), zomegde(mj), zomegse(mj)
     &  , zkinvsq(mj)
c
c zgmitg(jz) = growth rate of ITG mode (sec^{-1})
c zomitg(jz) = frequency of ITG mode (sec^{-1})
c zgm2nd(jz) = growth rate of mode after ITG and TEM (sec^{-1})
c zom2nd(jz) = frequency of mode after ITG and TEM (sec^{-1})
c zgmtem(jz) = growth rate of trapped electron mode (sec^{-1})
c zomtem(jz) = frequency of trapped electron mode (sec^{-1})
c zomegde(jz) = omega_{De} (sec^{-1})
c zomegse(jz) = omega_{*e} (sec^{-1})
c zkinvsq(jz) = 1.0 / k_perp^2 (m^{-2})
c
      dimension  zbprima(mj), zbc1a(mj), zbc2a(mj), zdka(mj)
c
c  arrays associated with the kinetic ballooning mode
c
c  arrays z**tem(jz) are contributions to the Hahm-Tang trapped electron
c  mode calculation (see below)
c
      dimension zoetai(mj), zdleti(mj)
     &        , zoetae(mj), zdlete(mj)
     &        , zoetad(mj), zdletd(mj)
     &        , zoetaz(mj), zdletz(mj)
c
c  zoetai(jz) = thigi(jz) at the last time step
c  zdleti(jz) = thigi(jz) - zoetai(jz)
c  zdaeti(jz) = spatial average of zdleti(jz) ...
c
      dimension zotmai(mj), zdltmi(mj)
     &        , zotmae(mj), zdltme(mj)
     &        , zotmad(mj), zdltmd(mj)
     &        , zotmaz(mj), zdltmz(mj)
c
c  zotmai(jz) = xtmhes(jz) at the last time step
c  zdltmi (jz) = xtmhes(jz) - zotmai(jz)
c  zdatmi(jz) = spatial average of zdltmi(jz) ...
c
      dimension ztemp1(mj), ztemp2(mj), ztemp3(mj), ztemp4(mj)
c
      dimension zdfthi(12,12), zvlthi(12)
     &  , zchieff(12), zomega(12), zgamma(12), zperf(12), znerr(12)
     &  , zflux(12)
c
c  zdfthi(j1,j2) = full matrix of anomalous transport diffusivities
c  zvlthi(j1)    = convective velocities
c  zchieff(j1)   = effective diffusivities corresponding to zdifthi
c  zperf(j1)     = performance index
c  znerr(j1)     = error index
c  zflux(j1)     = normalized flux from Weiland model
c
c..control variables for eta_i mode models
c
      dimension iletai(32), zcetai(32)
c
c..hydrogen particle diffusivities
c
      dimension zdti(mj), zdrm(mj), zdrb(mj), zdkb(mj)
     &  , zdnm(mj), zdhf(mj)
c
      real zlastime, znormd, znormv
c
      save zlastime
c
c  zlastime     time at previous call to sbrtn theory
c  znormd       factor to convert normalized diffusivities
c  znormv       factor to convert normalized convective velocities
c
c..variables in common blocks /comth*/
c
c                 electron/ion thermal diffusivity from:
c  thdre/i(j)   drift waves (trapped electron modes)
c  thtie/i(j)   ion temperature gradient (eta_i) modes
c  thrme/i(j)   rippling modes
c  thrbe/i(j)   resistive ballooning modes
c  thrbgb,thrbb(j)   gyro-Bohm and Bohm parts of thrbe(j)
c  thnme/i(j)   neoclassical MHD modes
c  thkbe/i(j)   kinetic ballooning modes
c  thhfe/i(j)   eta_e mode
c  thrlwe/i(j)  Rebut-Lallia-Watkins model
c
c  thdte(j)  = D_{te}
c  thdi(j)   = D_i
c
c  difthi(j1,j2,jz) = full matrix of anomalous transport diffusivities
c  velthi(j1,jz)    = convective velocities
c
      integer isdasw(8), iswitch, idim, iprint
c
      real zsdasw(8)
     & , zfldath, zfldanh, zfldate, zfldanz, zfldatz
     & , zdfdath, zdfdanh, zdfdate, zdfdanz, zdfdatz
c
c Local copy of ExB shearing rate
c
      real zwexb
c

!| 
!| The full matrix form of anomalous transport has the form
!| $$ \frac{\partial}{\partial t}
!|  \left( \begin{array}{c} n_H T_H  \\ n_H \\ n_e T_e \\
!|     n_Z \\ n_Z T_Z \\ \vdots
!|     \end{array} \right)
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
!| \left( \begin{array}{l} {\bf v}_1 n_H T_H \\ {\bf v}_2 n_H \\
!|    {\bf v}_3 n_e T_e \\
!|    {\bf v}_4 n_Z \\ {\bf v}_5 n_Z T_Z \\ \vdots \end{array} \right) +
!|  \left( \begin{array}{c} S_{T_H} \\ S_{n_H} \\ S_{T_e} \\
!|     S_{n_Z} \\ S_{T_Z} \\ \vdots
!|     \end{array} \right) $$
!| Note that all the diffusivities in this routine are normalized by
!| $ \omega_{De} / k_y^2 $,
!| convective velocities are normalized by $ \omega_{De} / k_y $,
!| and all the frequencies are normalized by $ \omega_{De} $.
!| 
c
c    Lengths:
c  thlni(j)  = L_{ni}
c  thlti(j)  = L_{T_i}
c  thlsh(j)  = L_s = R q / s\hat
c  thlpr(j)  = L_p
c  thlarp(j) = \rho_s
c  thrhos(j) = \rho_{\theta i}
c
c    Velocities:
c  thvthe(j) = v_{the}
c  thvthi(j) = v_{thi}
c  thsoun(j) = c_s
c  thalfv(j) = v_A
c
c     Dimensionless:
c  threti(j) = \eta_i
c  thdias(j) = resistive ballooning mode diamagnetic stabilization factor
c  thdinu(j) = \omega_e^\ast / \nu_{eff}
c  thfith(j) = f_{ith} as in eq (35)
c  thbpbc(j) = \beta^{\prime} / \beta_{c1}^{\prime}
c  thdia(j)  = \omega_e^\ast / k_\perp^2
c  thnust(j) = \nu_e^*
c  thrstr(j) = \rho_* = \rho_s/a
c  thlamb(j) = \Lambda multiplier for resistive ballooning modes
c
c  thbeta(j) = \beta
c  thetth(j) = \eta_i^{th}  threshold for \eta_i mode
c  thsrhp(j) = S = \tau_R / \tau_{hp} = r^2 \mu_0 v_A / ( \eta R_0 )
c  thvalh(jz)= Parameter determining validity of Hahm-Tang CTEM model
c
c-----------------------------------------------------------------------
!| 
!| The coding continues with the
!| OLYMPUS  ({\it cf.} \cite{BALDUR}) number (2.21),
!| and use of the OLYMPUS form for bypassing subroutines,
!| and comments on the common blocks and variables modified.
c
      logical initial
      data    initial /.true./
      save    initial
c
      integer istep, iclass, isub
      data    istep /1/,   iclass /2/   , isub /21/
      save    istep, iclass, isub
c
c-----------------------------------------------------------------------
c
c..physical and computer constants
c
      if ( initial ) then
        zpi     = atan2 ( 0.0, -1.0 )
        zcc     = 2.997925e+8
        zcmu0   = 4.0e-7 * zpi
        zceps0  = 1.0 / ( zcc**2 * zcmu0 )
        zckb    = 1.60210e-16
        zcme    = 9.1091e-31
        zcmp    = 1.67252e-27
        zce     = 1.60210e-19
        zepslon = 1.0e-34
        zepsinv = 1.0 / zepslon
        zlgeps  = log ( zepslon )
        zepsqrt = sqrt ( zepslon )
        zlastime = time
        initial = .false.
      endif
c
c
c..skip directly to printout if lprint < 0
c
      if ( lprint .lt. 0 ) go to 900
c
c..initialize arrays
c
      do 10 jz=1,medge
        xetot(jz) = 0.
        xitot(jz) = 0.
        weithe(jz) = 0.
        thdre(jz)  = 0.
        thdri(jz)  = 0.
        thige(jz)  = 0.
        thigi(jz)  = 0.
        thtie(jz)  = 0.
        thtii(jz)  = 0.
        thrme(jz)  = 0.
        thrmi(jz)  = 0.
        thrbgb(jz) = 0.
        thrbb(jz)  = 0.
        thrbe(jz)  = 0.
        thnme(jz)  = 0.
        thnmi(jz)  = 0.
        thcee(jz)  = 0.
        thcei(jz)  = 0.
        thhme(jz)  = 0.
        thrbi(jz)  = 0.
        thkbe(jz)  = 0.
        thkbi(jz)  = 0.
        thhfe(jz)  = 0.
        thhfi(jz)  = 0.
        thrlwe(jz) = 0.
        thrlwi(jz) = 0.
        zddtem(jz) = 0.
        zdztem(jz) = 0.
        zddig(jz)  = 0.
        zdti(jz)   = 0.
        zdrm(jz)   = 0.
        zdrb(jz)   = 0.
        zdkb(jz)   = 0.
        zdnm(jz)   = 0.
        zdhf(jz)   = 0.
        zfnsnea(jz) = 0.
        ztemp1(jz) = 0.
        ztemp2(jz) = 0.
        ztemp3(jz) = 0.
        ztemp4(jz) = 0.
  10  continue
c
      do jz=1,medge
        dhtot(jz) = 0.
        vhtot(jz) = 0.
        dztot(jz) = 0.
        vztot(jz) = 0.
      enddo
c
c
c..set up gradient scale length arrays
c
c      do jz=1,medge
c        zslne(jz) = slne(jz)
c        zslni(jz) = slni(jz)
c        zslnh(jz) = slnh(jz)
c        zslnz(jz) = slnz(jz)
c        zslte(jz) = slte(jz)
c        zslti(jz) = slti(jz)
c        zslpr(jz) = slpr(jz)
c        zsshr(jz) = sshr(jz)
c        zslne(jz) = slne(jz)
c      enddo
c
      do jz=1,medge
        zslne(jz) = rmajor(jz)
     &    / sign(max(abs(grdne(jz)),zepslon),grdne(jz)+zepsqrt)
        zslni(jz) = rmajor(jz)
     &    / sign(max(abs(grdni(jz)),zepslon),grdni(jz)+zepsqrt)
        zslnh(jz) = rmajor(jz)
     &    / sign(max(abs(grdnh(jz)),zepslon),grdnh(jz)+zepsqrt)
        zslnz(jz) = rmajor(jz)
     &    / sign(max(abs(grdnz(jz)),zepslon),grdnz(jz)+zepsqrt)
        zslte(jz) = rmajor(jz)
     &    / sign(max(abs(grdte(jz)),zepslon),grdte(jz)+zepsqrt)
        zslti(jz) = rmajor(jz)
     &    / sign(max(abs(grdti(jz)),zepslon),grdti(jz)+zepsqrt)
        zslpr(jz) = rmajor(jz)
     &    / sign(max(abs(grdpr(jz)),zepslon),grdpr(jz)+zepsqrt)
        zsshr(jz) = grdq(jz) * rminor(jz) / rmajor(jz)
      enddo
c
c  zsshr(jz) = ( r / q ) ( d q / d r )
c
c..smooth the relative superthermal ion density
c
      do jz=maxis, medge
        zfnsnea(jz) = cthery(121) * densfe(jz) / dense(jz)
      enddo
c
      if ( lthery(19) .gt. 0  .and. cthery(121) .gt. zepslon ) then
c
        ismooth = lthery(19)
        zsmooth = 0.0
        ilower  = maxis + 1
        iupper  = medge
c
        call smooth2 ( zfnsnea, 1, ztemp1, ztemp2, 1
     &    , ilower, iupper, ismooth, zsmooth )
c
      endif
c
!| 
!| There are continuing numerical problems that can be traced back to noisy
!| gradient scale lengths.  To help combat these problems, apply smoothing
!| directly to the gradient scale lengths whenever ${\tt lthery(32)} > 0 $.
!| The numerical value of {\tt lthery(32)} will determine the order of
!| smoothing.
!| Note that the gradient scale lengths vary like $1/r$ near the magnetic axis.
!| Hence, before smoothing, the gradient scale lengths will be pre-conditioned
!| by multiplying them by the minor radius.
!| The output of this section will be the gradient scale lengths
!| {\tt zslne(jz)}, {\tt zslni(jz)}, {\tt zslte(jz)}, {\tt zslti(jz)},
!| all in meters.
!| 
!| Whenever ${\tt lthery(32)} < 0 $, the smoothing is applied to the
!| reciprocal of the gradient scale lengths.
!| 
c
      if ( lthery(32) .ne. 0 ) then
c
        i1     = maxis + 1
        izones = medge + 1 - i1
        ismord = abs( lthery(32) )
        zlmin  = 1.e-4
c
c  ismord = number of times smoothing is applied
c  zlmin  = minimum gradient scale length
c
        do 33 jz=i1,medge
          zmlne(jz) = zslne(jz) * rminor(jz)
          zmlni(jz) = zslni(jz) * rminor(jz)
          zmlnh(jz) = zslnh(jz) * rminor(jz)
          zmlnz(jz) = zslnz(jz) * rminor(jz)
          zmlte(jz) = zslte(jz) * rminor(jz)
          zmlti(jz) = zslti(jz) * rminor(jz)
          zmshr(jz) = zsshr(jz) / rminor(jz)
  33    continue
c
c  change the values at jz=maxis+1 in order to make sure zml** arrays
c    are monotonic near the magnetic axis
c
        if ( lthery(31) .eq. 1 ) then
          zmlne(i1) = 2. * zmlne(i1+1) - zmlne(i1+2)
          zmlni(i1) = 2. * zmlni(i1+1) - zmlni(i1+2)
          zmlnh(i1) = 2. * zmlnh(i1+1) - zmlnh(i1+2)
          zmlnz(i1) = 2. * zmlnz(i1+1) - zmlnz(i1+2)
          zmlte(i1) = 2. * zmlte(i1+1) - zmlte(i1+2)
          zmlti(i1) = 2. * zmlti(i1+1) - zmlti(i1+2)
          zmshr(i1) = 2. * zmshr(i1+1) - zmshr(i1+2)
        endif
c
c  reciprocal of the gradient scale lengths
c
        if ( lthery(32) .lt. 0 ) then
          do jz=1,medge
            zmlne(jz) = 1.0
     &        / sign ( max ( abs( zmlne(jz) ), zlmin ), zmlne(jz) )
            zmlni(jz) = 1.0
     &        / sign ( max ( abs( zmlni(jz) ), zlmin ), zmlni(jz) )
            zmlnh(jz) = 1.0
     &        / sign ( max ( abs( zmlnh(jz) ), zlmin ), zmlnh(jz) )
            zmlnz(jz) = 1.0
     &        / sign ( max ( abs( zmlnz(jz) ), zlmin ), zmlnz(jz) )
            zmlte(jz) = 1.0
     &        / sign ( max ( abs( zmlte(jz) ), zlmin ), zmlte(jz) )
            zmlti(jz) = 1.0
     &        / sign ( max ( abs( zmlti(jz) ), zlmin ), zmlti(jz) )
            zmshr(jz) = 1.0
     &        / sign ( max ( abs( zmshr(jz) ), zlmin ), zmshr(jz) )
          enddo
        endif
c
c  apply smoothing
c
        do 37 js=1,ismord
c
           do 34 jz=1,medge
             zslne(jz) = zmlne(jz)
             zslni(jz) = zmlni(jz)
             zslnh(jz) = zmlnh(jz)
             zslnz(jz) = zmlnz(jz)
             zslte(jz) = zmlte(jz)
             zslti(jz) = zmlti(jz)
             zsshr(jz) = zmshr(jz)
  34       continue
c
           znorm = 0.25
           do 35 jz=i1+1,medge-1
             zmlne(jz) = znorm*(zslne(jz-1)+2.0*zslne(jz)+zslne(jz+1))
             zmlni(jz) = znorm*(zslni(jz-1)+2.0*zslni(jz)+zslni(jz+1))
             zmlnh(jz) = znorm*(zslnh(jz-1)+2.0*zslnh(jz)+zslnh(jz+1))
             zmlnz(jz) = znorm*(zslnz(jz-1)+2.0*zslnz(jz)+zslnz(jz+1))
             zmlte(jz) = znorm*(zslte(jz-1)+2.0*zslte(jz)+zslte(jz+1))
             zmlti(jz) = znorm*(zslti(jz-1)+2.0*zslti(jz)+zslti(jz+1))
             zmshr(jz) = znorm*(zsshr(jz-1)+2.0*zsshr(jz)+zsshr(jz+1))
  35       continue
c
  37     continue
c
c  go from reciprocals back to the gradient scale lengths
c
        if ( lthery(32) .lt. 0 ) then
          do jz=1,medge
            zmlne(jz) = 1.0
     &        / sign ( max ( abs( zmlne(jz) ), zlmin ), zmlne(jz) )
            zmlni(jz) = 1.0
     &        / sign ( max ( abs( zmlni(jz) ), zlmin ), zmlni(jz) )
            zmlnh(jz) = 1.0
     &        / sign ( max ( abs( zmlnh(jz) ), zlmin ), zmlnh(jz) )
            zmlnz(jz) = 1.0
     &        / sign ( max ( abs( zmlnz(jz) ), zlmin ), zmlnz(jz) )
            zmlte(jz) = 1.0
     &        / sign ( max ( abs( zmlte(jz) ), zlmin ), zmlte(jz) )
            zmlti(jz) = 1.0
     &        / sign ( max ( abs( zmlti(jz) ), zlmin ), zmlti(jz) )
            zmshr(jz) = 1.0
     &        / sign ( max ( abs( zmshr(jz) ), zlmin ), zmshr(jz) )
          enddo
        endif
c
c  undo preconditioning with minor radius
c
        do 38 jz=i1,medge
          zslne(jz) = zmlne(jz) / rminor(jz)
          zslni(jz) = zmlni(jz) / rminor(jz)
          zslnh(jz) = zmlnh(jz) / rminor(jz)
          zslnz(jz) = zmlnz(jz) / rminor(jz)
          zslte(jz) = zmlte(jz) / rminor(jz)
          zslti(jz) = zmlti(jz) / rminor(jz)
          zsshr(jz) = zmshr(jz) * rminor(jz)
  38    continue
c
      endif
!| 
!| We then enter a loop over the spatial zones,
!| and set the following BALDUR {\tt common} variables
!| to variables local to subroutine {\tt theory}: the
!| mean atomic mass number of the thermal ions, $A_{i}$ ({\tt zai}),
!| the electron
!| and ion density and temperature, $n_{e}$ ({\tt zne}),
!| $n_{i}=\sum_{a}n_{a}$ ({\tt zni}),
!| $T_{e}$ ({\tt zte}), and $T_{i}$ ({\tt zti}),
!| the safety factor, $q$ ({\tt zq}),
!| the effective charge, $Z_{eff}$ ({\tt zeff}),
!| the scale lengths $L_{ne}$, $L_{ni}$, $L_{Te}$, $L_{Ti}$, $L_{p}$
!| ({\tt zlne}, {\tt zlni}, {\tt zlte}, {\tt zlti}, {\tt zlpr}, which
!| are modified below after the poloidal gyroradius is calculated),
!| a quantity, $\theta_{shear}$ ({\tt zslbps},
!| discussed below and related to the shear),
!| the midplane halfwidth of the separatrix
!| (which BALDUR sets to the midplane halfwidth
!| of the outermost computational zone
!| if no scrapeoff zones are active), $r_{sep}$ ({\tt zrsep}),
!| the midplane halfwidth of a flux surface, $r$ ({\tt zrmin}),
!| the major radius, $R_{o}$ ({\tt zrmaj}), and
!| the toroidal field at a reference major radius, $B_{0}$ ({\tt zb}).
!| Additional variables local to subroutine {\tt theory} computed
!| from BALDUR {\tt common} variables are the inverse aspect
!| ratio for a flux surface, $\epsilon=r/R_{0}$ ({\tt zep})
!| and the local toroidal
!| electric field which is calculated using the variable VLOOPI
!| defined in BALDUR as $VLOOPI=2 \pi R_{O}*E_{O}.$
!| Therefore, the only variables not defined in subroutine
!| {\tt theory} that are needed to complete the rest of the
!| calculation are $\pi$ ({\tt zpi}), the small overflow
!| protection variable {\tt zepslon}, and the convection
!| constants $C_{pv}^{e}$ ({\tt cthery(68)})
!| and $C_{pv}^{i}$ ({\tt ctheory(69)}),
!| which are specified by BALDUR's preexisting {\tt namelist}
!| input (and defaulted to 1.5 if the inputs are zero.)
!| The points of defining so many local variables
!| are to compact the notation and to make it easier for other
!| transport code programmers to understand and possibly use
!| the main body of this subroutine without using BALDUR's
!| notation or array structure for various {\tt common} variables.
!| The relevant coding for the calculations just described is:
!| 
c
c.. start the main do-loop over the radial index "jz"..........
c
      jzmin = maxis + 1
c
c..diagnostic printout header
c
cbate      write (nprint,*) '#zz1   rminor    grdti     zgth'
c
      do 300 jz=jzmin,medge
c
c  transfer common to local variables to compact the notation
c
      zelong = max (zepslon,elong(jz))
      if ( lthery(12) .eq. 1 ) then
        zelonf = ( 1. + zelong**2 ) / 2.
      else
        zelonf = zelong
      endif
c
      zai = aimass(jz)
      zne = dense(jz)
      zni = densi(jz)
      znh = densh(jz)
      zte = tekev(jz)
      zti = tikev(jz)
      ztf = tfkev(jz)
      zq  = q(jz)
      zeff = xzeff(jz)
      zlne = zslne(jz)
      zlni = zslni(jz)
      zlnh = zslnh(jz)
      zlnz = zslnz(jz)
      zlte = zslte(jz)
      zlti = zslti(jz)
ces   temporary numerical overflow protection, cf. statement 22 below
      zlpr = zslpr(jz)
      zshear = zsshr(jz)
      zrsep = max( rminor(mseprtx), zepslon )
      zrmin = max( rminor(jz), zepslon )
      zrmaj = rmajor(jz)
      zvloop = abs(vloop(jz))
      zb    = btor(jz)
c
c  compute inverse aspect ratio
c
      zep = max( zrmin/zrmaj, zepslon )
c
      znfi = densf(jz)
      znfe = densfe(jz)
c
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
!| $$ \omega_{pe}=[n_{e}e^{2}/(m_{e}\epsilon_{o})]^{1/2} \eqno{\tt zfpe} $$
!| $$ v_{e}=(2k_{b}T_{e}/m_{e})^{1/2} \eqno{\tt zvthe} $$
!| $$ v_{i}=(2k_{b}T_{i}/m_{p}A_{i})^{1/2} \eqno{\tt zvthi} $$
!| $$ c_{s}=[k_{b}T_{e}/(m_{p}A_{i})]^{1/2} \eqno{\tt zsound} $$
!| $$ v_{A}=B_{o}/(\mu_{o}n_{e}m_{p}A_{i})^{1/2} \eqno{\tt zvalfv} $$
!| $$ \beta_{\theta}=\beta (q/\epsilon )^2 \eqno{\tt zbetap} $$
!| $$ \ln (\lambda)=37.8 - \ln (n_{e}^{1/2}T_{e}^{-1}) \eqno{\tt zlog} $$
!| $$ \nu_{ei}=4(2\pi)^{1/2}n_{e}(\ln \lambda)e^{4}Z_{eff}
!|                /[3(4\pi \epsilon_{o})^{2}m_{e}^{1/2}(k_{b}T_{e})^{3/2}]
!|  \eqno{\tt znuei} $$
!| $$ \nu_{ii}=4\pi ^{1/2}n_{e}(\ln \lambda)e^{4}
!|                /[3(4\pi \epsilon_{o})^{2}(m_{p}A_{i})^{1/2}
!|                  (k_{b}T_{i})^{3/2}] \eqno{\tt znuii} $$
!| $$ \eta=\nu_{ei}/(2\epsilon_{o}\omega_{pe}^{2}) \eqno{\tt zresis} $$
!| If $ {\tt lthery(4)} = 1 $, {\tt zresis} is set equal to the neoclasssical
!| resistivity {\tt eta(1,jz)} computed in BALDUR (in subroutine GETCHI).
!| $$ \nu_{eff}=\nu_{ei}/\epsilon \eqno{\tt znueff} $$
!| $$ \nu_{e}^{*}=\nu_{ei}qR_{o}/(\epsilon^{3/2}v_{e}) \eqno{\tt thnust} $$
!| $$ \nu_{i}^{*}=\nu_{ii}qR_{o}/(\epsilon^{3/2}v_{i}) \eqno{\tt znusti} $$
!| $$ \hat{\nu}=\nu_{eff}/\omega_{De} \eqno{\tt znuhat} $$
!| $$ \rho_{i}=v_{i}/\omega_{ci} \eqno{\tt zlarpo} $$
!| $$ \rho_{\theta i}=\rho_{i}q/\epsilon \eqno{\tt zlari} $$
!| $$ \rho_{s}=c_{s}/\omega_{ci} \eqno{\tt zrhos} $$
!| $$ \rho_{*}=\rho_{s}/a \eqno{\tt thrstr} $$
!| $$ k_{\perp}=0.3/\rho_{s} \eqno{\tt zwn} $$
!| 
!| The corresponding coding is:
!| 
c  start calculating table (1) of the comments paper
c
      zprth=zne*zte+zni*zti
      zgyrfi=zce*zb/(zcmp*zai)
      zbeta=(2.*zcmu0*zckb/zb**2)*(zne*zte+zni*zti)
      zfpe=zce*sqrt(zne/(zcme*zceps0))
      zvthe=sqrt(2.*zckb*zte/zcme)
      zvthi=sqrt(2.*zckb*zti/(zcmp*zai))
      zsound=sqrt(zckb*zte/(zcmp*zai))
      zvalfv=zb/sqrt(zcmu0*zne*zcmp*zai)
      zbetap=zbeta*(zq/zep)**2
      zlog=37.8-log(sqrt(zne)/zte)
       zcf=(4.*sqrt(zpi)/3.)
       zcf=zcf*(zce/(4.*zpi*zceps0))**2
      zcf=zcf*(zce/zckb)*zce/sqrt(zcme*zckb)
      znuei=zcf*sqrt(2.)*zne*zlog*zeff/(zte*sqrt(zte))
      znuii=zcf*zne*zlog/(sqrt(zcmp*zai/zcme)*zti**1.5)
      znustar=znuei*zq*zrmaj / ( zvthe*zep**1.5 )
      zresis=znuei/(2.*zceps0*zfpe**2)
c
      if ( lthery(4) .eq. 1 ) zresis = resist(jz)
c
      znueff=znuei/zep
      thnust(jz)=znuei*zq*zrmaj/(zvthe*zep**1.5)
      znusti = znuii * zq * zrmaj / ( zvthi * zep**1.5 )
      zlari=zvthi/zgyrfi
      zlarpo=max(zlari*zq/zep,zepslon)
      zrhos=zsound/zgyrfi
      thrstr(jz)=zrhos/ rminor(medge)
      zwn=0.3/zrhos
      znude=2*zwn*zrhos*zsound/zrmaj
      znuhat=znueff/znude
c
c
!| 
!| Next we use the poloidal gyroradius to avoid singularities
!| associated with the scale lengths:
!| 
!| $$ L_{ne}=max(|-n_{e}/(\partial n_{e}/\partial r)|,\rho_{\theta i})
!|  \eqno{\tt zlne} $$
!| $$ L_{ni}=max(|-n_{i}/(\partial n_{i}/\partial r)|,\rho_{\theta i})
!|  \eqno{\tt zlni} $$
!| $$ L_{T_{e}}=max(|-T_{e}/(\partial T_{e}/\partial r|,\rho_{\theta i})
!|  \eqno{\tt zlte} $$
!| $$ L_{T_{i}}=max(|-T_{i}/(\partial T_{i}/\partial r|,\rho_{\theta i})
!|  \eqno{\tt zlti} $$
!| $$ L_{p}=max(|-\beta /(\partial \beta/\partial r)|,\rho_{\theta i})
!|  \eqno{\tt zlpr} $$
!| Here we are constructing the $L_p$ from the smoothed density and temperature
!| scale lengths.
!| 
!| If {\tt lthery(30)} = 0 (default), use only the absolute values
!| of the gradient scale lengths.
!| 

c  the following is to avoid singularities associated with
c  the scale lengths
c
      zsglne = 1.0
      zsglni = 1.0
      zsglnh = 1.0
      zsglnz = 1.0
      zsglte = 1.0
      zsglti = 1.0
      zsglpr = 1.0
c
      if ( lthery(30) .eq. 1 ) then
        zsglne = sign ( 1.0, zlne )
        zsglni = sign ( 1.0, zlni )
        zsglnh = sign ( 1.0, zlnh )
        zsglnz = sign ( 1.0, zlnz )
        zsglte = sign ( 1.0, zlte )
        zsglti = sign ( 1.0, zlti )
        zsglpr = sign ( 1.0, zlpr )
      endif
c
      zlne = max(abs(zlne),zlarpo) * zsglne
      zlni = max(abs(zlni),zlarpo) * zsglni
      zlnh = max(abs(zlnh),zlarpo) * zsglnh
      zlnz = max(abs(zlnz),zlarpo) * zsglnz
      zlte = max(abs(zlte),zlarpo) * zsglte
      zlti = max(abs(zlti),zlarpo) * zsglti
c      zlpr = max(abs(zlpr),zlarpo) * zsglpr
c
c  Compute the pressure scale length using smoothed and bound
c  density and temperature
c
      zdprth = zne*zte*(1./zlne+1./zlte) + zni*zti*(1./zlni+1./zlti)
      zsgdpr = sign ( 1.0, zdprth)
      zdpdr = max(abs(zdprth),zlarpo) * zsgdpr
      zlpr = zprth / zdpdr
c
c
!| 
!| When any of the coefficients $c_{5*}$ are greater than {\tt zepslon},
!| upper bounds are placed on the scale lengths relative to the major radius
!| $$ L_{ne} = min ( |L_{ne}|, c_{50} R) \eqno{\tt zlne} $$
!| $$ L_{ni} = min ( |L_{ni}|, c_{51} R) \eqno{\tt zlni} $$
!| $$ L_{nh} = min ( |L_{nh}|, c_{51} R) \eqno{\tt zlnh} $$
!| $$ L_{nz} = min ( |L_{nz}|, c_{51} R) \eqno{\tt zlnz} $$
!| $$ L_{Te} = min ( |L_{Te}|, c_{52} R) \eqno{\tt zlte} $$
!| $$ L_{Ti} = min ( |L_{Ti}|, c_{53} R) \eqno{\tt zlti} $$
!| $$ L_{p } = min ( |L_{p }|, c_{54} R) \eqno{\tt zlp } $$
      if ( cthery(50) .gt. zepslon )
     &  zlne = min ( abs(zlne), cthery(50) * zrmaj ) * zsglne
      if ( cthery(51) .gt. zepslon )
     &  zlni = min ( abs(zlni), cthery(51) * zrmaj ) * zsglni
      if ( cthery(51) .gt. zepslon )
     &  zlnh = min ( abs(zlnh), cthery(51) * zrmaj ) * zsglnh
      if ( cthery(51) .gt. zepslon )
     &  zlnz = min ( abs(zlnz), cthery(51) * zrmaj ) * zsglnz
      if ( cthery(52) .gt. zepslon )
     &  zlte = min ( abs(zlte), cthery(52) * zrmaj ) * zsglte
      if ( cthery(53) .gt. zepslon )
     &  zlti = min ( abs(zlti), cthery(53) * zrmaj ) * zsglti
      if ( cthery(54) .gt. zepslon )
     &  zlpr = min ( abs(zlpr), cthery(54) * zrmaj ) * zsglpr
!| 
!| In order to ensure backward compatibility, define $ {\tt zln} = {\tt zlne} $
!| if $ {\tt lthery(3)} \leq 1 $ and $ {\tt zln} = {\tt zlni} $ otherwise.
!| Also, define $ {\tt zlnj} = {\tt zlne} $ if $ {\tt lthery(3)} \leq 0 $
!| and $ {\tt zlnj} = {\tt zlni} $ otherwise.  The variable {\tt zlnj} is used
!| in the definition of $\eta_i$ {\tt zetai} and in formulae for the threshold
!| $\eta_{ith}$ {\tt zetith} below.
        zln  = zlni
        zlnj = zlni
      if ( lthery(3) .le. 1 ) zln  = zlne
      if ( lthery(3) .le. 0 ) zlnj = zlne
!| 
!| Our formulas for the shear begin with
!| $$ {\hat s}_{cyl}=|(r/q)(\partial q/\partial r)| \eqno{\tt zscyl} $$
!| computed earlier in this subroutine.
!| We then provide an option
!| to accomodate users who want to simulate the effect of high
!| shear on transport
!| near a separatrix but find it inconvenient to specify
!| the boundary shape and use enough moments in the equilibrium
!| calculation to obtain a large shear there.  This is done by
!| defining
!| $$  k'=|1-\frac{r}{c_{2}r_{sep}}|^{1/2} \eqno{\tt zkprim} $$
!| and
!| $$ {\hat s}_{div}={\hat s}_{cyl}
!|    +c_{1}\left( \frac{1}{(k')^{2}|\ln (4/k')|} -\frac{1}{\ln 4} \right)
!|  \eqno{\tt zsdiv} $$
!| The function of $k'$
!| inside the parantheses here approximates the expression
!| $\frac{{\bf E}(\rho )}{{\bf K}(\rho )(1 - \rho^{2})} - 1$
!| ({\it eg.} given
!| in the Comments paper
!| ({\it cf.} \cite{HD} to within 2\ 0.000000or $\rho \equiv r/(c_{2}r_{sep})=.96$)
!| for the expected situation where $k'\le 1$
!| Here ${\bf E}$ and ${\bf K}$ are complete elliptic integrals.
!| (When the user wants to
!| set the computational boundary inside the separatrix
!| location for a divertor simulation, then $c_{2}$ should
!| be set to the ratio of the outermost computational zone
!| location to the physical midplane halfwidth at the separatrix.)
!| The shear is then limited to be no larger than $r/\rho_{\theta_{i}}$
!| $$ {\hat s}_{lim}=min({\hat s}_{div},r/\rho_{\theta i}) \eqno{\tt zslim} $$
!| 
!| unless $r/\rho_{\theta_{i}}$ is less than a minimum prescribed shear
!| $$ {\hat s}_{min}=max(c_{3},0) \eqno{\tt zsmin} $$
!| since we use this to set a minimum on the shear of the form
!| $$ {\hat s}=max({\hat s}_{min},{\hat s}_{lim}) \eqno{\tt zshat} $$
!| Following the literature conventions used in the Comments paper,
!| the shear length is defined somewhat differently
!| than the other scale lengths, as
!| $$ L_{s}=R_{o}q/{\hat s} \eqno{\tt zlsh} $$
!| The default values, $c_{1}=0.0$, $c_{2}=1.0$, and $c_{3}=0.5$,
!| are set up so they can be modified by {\tt namelist} input.
!| 
!| The $Z_{eff}$ gradient is not presently calculated in BALDUR
!| and might not be very accurately modelled
!| in most simulations even if it were.
!| The effects of impurities are, in any case,
!| undergoing theoretical reexamination.
!| We, therefore, include the (normalized)
!| $Z_{eff}$ gradient $c_{4}=(\partial Z_{eff}/\partial r)/Z_{eff}$
!| for the time being merely as an input constant
!| (with default =0) when computing
!| the electrical conductivity scale height:
!| $$ L_{\sigma}=[1.5L_{T_{e}}^{-1}+c_{4}]^{-1} \eqno{\tt zlsig} $$
!| 
!| Some other generally useful quantities dependent on scale heights are:
!| $$ \eta_{e}=L_{ne}/L_{T_{e}} \eqno{\tt zetae} $$
!| $$ \mbox{if} \; \; c_{56} > \epsilon \; \; \mbox{then} \; \;
!|    \eta_e = \min ( \eta_e , c_{56} R ) \eqno{\tt zetae} $$
!| $$ \eta_{i}=L_{n}/L_{T_{i}} \eqno{\tt zetai} $$
!| $$ \mbox{if} \; \; c_{57} > \epsilon \; \; \mbox{then} \; \;
!|    \eta_i = \min ( \eta_i , c_{57} R ) \eqno{\tt zetae} $$
!| $$ \omega_{e}^{*}=k_{\perp}\rho_{s}c_{s}/L_{ne} \eqno{\tt zdiafr} $$
!| 
!| Note that
!| BALDUR already calculates $\ln (\lambda)$ and $\nu_{e}^{*}$
!| (and stores at least $\nu_{e}^{*}$ in {\tt common} as {\tt xnuel}).
!| Each of these existing calculations should only be used if and only if
!| they are identical to the formulas in Table 1 of the Comments paper,
!| in order to avoid unnecessary minor difficulties in communicating to
!| non-BALDUR users exactly what formulas were used.  (The idea
!| is that other people should, at least in principle,
!| be able to reproduce the transport flux formulas we use
!| in work based on the Comments paper
!| by referring only to the Comments paper, insofar as possible.)
!| 
!| The relevant coding for the calculations just described is:
!| 
c
      zscyl=max(abs(zshear),zepslon)
      zkprim=max(sqrt(abs(1.-zrmin/(cthery(2)*zrsep))),zepslon)
c       parentheses in the next line are OK in versions 15.06...
      zsdiv=zscyl
     & + cthery(1)*(1./(zkprim**2*abs(log(4./zkprim))) -1./log(4.))
      zslim=min(zsdiv,zrmin/zlarpo)
      zsmin=max(cthery(3),zepslon)
      zshat=max(zsmin,zsdiv)
      zlsh=zrmaj*zq/zshat
      zlsig=1./(1.5/zlte + cthery(4))
      zetae  = zlne/zlte
      if ( cthery(56) .gt. zepslon )
     &  zetae = min ( zetae, cthery(56) * zrmaj )
      zetai  = zlnj / zlti
      if ( cthery(57) .gt. zepslon )
     &  zetai = min ( zetai, cthery(57) * zrmaj )
      zdiafr = zwn * zrhos * zsound / zlne
c
!| The magnetic Reynold's number is defined by
!| $$ S = \tau_R / \tau_{hp}  \eqno{\tt zsrhp} $$
!| $$ \tau_R = r^2 \mu_0 / \eta \equiv \mbox{local restive time},
!|       \eqno{\tt ztaur} $$
!| For the moment, we use the local Spitzer resistivity {\tt zresis},
!| although I think the neoclassical resistivity (which may be 3 times larger)
!| should be used in the future.
!| $$ \tau_{hp} = R_0 / v_A \equiv \mbox{local poloidal Alfven time}.
!|       \eqno{\tt ztauhp} $$
c
        ztaur  = zrmin**2 * zcmu0 / zresis
        ztauhp = zrmaj / zvalfv
        zsrhp  = ztaur / ztauhp
c
c  this is the end of calculating parameters in table (1) of
c  the comment paper.
!| 
!| %**********************************************************************c
!| 
!| \section{Transport Models}
!| 
!| The computation of the anomalous transport coefficients is
!| now described.  We do this for the energy fluxes by computing
!| thermal diffusivities, despite the fact that the Comments
!| paper directly gives energy fluxes.  This is done
!| to maintain parallelism with previous methods of
!| computing anomalous energy fluxes in BALDUR.  It should be
!| noted that, for convenience in subtracting out what
!| are traditionally called convective energy fluxes, we
!| assume quasineutrality in a pure hydrogen plasma.  The
!| user can (and should) set the input parameters
!| ${\tt cthery(68)}={\tt cthery(69)}=0.0$
!| when precise modelling of
!| other types of plasma is desired ({\it cf.} Section 3.7, below).
!| 
!| %**********************************************************************c
!| 
!| \subsection{Trapped Electron Modes}
!| 
!| Here, ``drift wave fluxes'' include dissipative trapped electron modes
!| and collisionless trapped electron modes.
!| (Note that $\eta_i$ modes have been moved to a separate section below.)
!| 
!| To begin with, allow all trapped electron mode contributions to be
!| multiplied by
!| $$ \exp^{-c_{22}(T_i/T_e - 1)^2}.  \eqno{\tt zdtite} $$
!| as suggested by R. Dominguez.
!| By default, $c_{22} = 0.0$, so this factor has no effect.
!| Dominguez suggests the value $c_{22} = 1.0$.
!| 
c
c .......................................
c . trapped electron mode calculations  .
c .......................................
c
      zdtite = 1.0
      if ( abs(cthery(22)) .gt. zepslon )
     &  zdtite = exp( -cthery(22) * ((zti/zte)-1.)**2 )
c
!| 
!| If ${\tt lthery(5)} = 1$, we use the collisionless trapped electron mode
!| transport theory by Hahm and Tang\cite{hahm90a}
!| together with an extension of the theory to include dissipative
!| trapped electron modes by Hahm and Tang.\cite{hahm90b}
!| First define some convenient factors used in these expressions:
!| $$ F_{\beta} = 1.0 \eqno{\tt zfbeta} $$
!| ($F_{\beta}$ is a finite beta correction to be added later.)
!| $$ G = 1.2 \eqno{\tt zgtem} $$
!| (Note that $G$ is actually a function of magnetic shear and an average
!| over the particle pitch angle.
!| It will need to be generalized for noncircular geometry
!| and high $\beta_{pol}$.)
!| The following factor is bounded by unity as a condition for the validity
!| of the weak turbulence theory:
!| $$ H_1 = \min \left[ 4 \frac{2 \pi r}{R} \eta_e^2
!| \left( \frac{R}{G L_n} \right)^3
!|         \left( \frac{R}{G L_n} - \frac{3}{2} \right)^2
!|         \exp \left( - \frac{2R}{G L_n} \right) , 1.0 \right]
!|         \eqno{\tt zh1tem} $$
!| $$ K_1 = max [ 1.0, 1. / \sqrt{ G L_n / R} ]  \eqno{\tt zk1tem} $$
!| (Here $ K_1 \equiv K_M / K_L $ in the Hahm-Tang paper.)
!| $$ H_2 =  K_1 - \ln(K_1) - 1.0   \eqno{\tt zh2tem} $$
!| $$ H^{DTEM} = 3 (r/R)^3 (c_s/L_{T_e} \nu_{ei})^2 (1 + (T_i/T_e)(1+\eta_i))
!|                  \eqno{\tt zhdtem} $$
!| $$ H^{CTEM} = (2/3) H_1 H_2  \eqno{\tt zhctem} $$
!| $$ D_1 = \frac{8}{5 \pi} \frac{\rho_s^2 c_s}{L_n} \frac{q^2}{\hat{s}^2}
!|          \frac{T_e}{T_i} \frac{R^2}{L_n^2}
!|          \frac{\sqrt{1+(T_i/T_e)(1+\eta_i)}}{1+5\eta_i/4}. \eqno{\tt zd1tem}
!| $$
!| Then the particle diffusivity produced by either the dissipative or
!| collisionless trapped electron mode is
!| $$ D^{TEM} = F_a^{DR} F_{\beta} \kappa^{c_{12}} {\tt zdtite}
!|                D_1 \min [ H^{DTEM} , c_{20} H^{CTEM} ].  \eqno{\tt zddtem} $$
!| The effective electron thermal diffusivity is
!| $$ \chi_e^{TEM} = F_e^{DR} F_{\beta} \kappa^{c_{12}} {\tt zdtite}
!|      ( D_1 / \eta_e ) \min [ 5 H^{DTEM} , c_{20} \frac{R}{G L_n} H^{CTEM} ].
!|      \eqno{\tt thdre} $$
!| The effective ion thermal diffusivity is
!| $$ \chi_i^{TEM} = F_i^{DR} F_{\beta} \kappa^{c_{12}} {\tt zdtite}
!|       2.75 \frac{1+1.93 \eta_i}{1+1.25 \eta_i} \frac{D_1}{\eta_i}
!|       \min [ H^{DTEM} , c_{20} H^{CTEM} ].  \eqno{\tt thdri} $$
!| The anomalous electron to ion energy exchange is
!| $$ \Delta^{DR} = F_{\Delta}^{DR} \frac{n_e T_e}{L_n^2} {\tt zdtite}
!|        D_1 \min [ H^{DTEM} , c_{20} H^{CTEM} ].  \eqno{\tt weithe} $$
!| Here $c_{20} = {\tt cthery(20)}$ is an adjustable coefficient
!| defaulted to 1.0.
!| 
c
      if ( lthery(5) .eq. 1 ) then
        zfbeta = 1.0
        zgtem  = 1.2
        zrgln  = zrmaj / ( zgtem * abs(zlne) )
        zh1tem(jz) = min ( 1.0,
     &    (8.*zpi*zrmin/zrmaj) * zetae**2
     &     * zrgln**3 * ( zrgln - 1.5 )**2 * exp( - 2. * zrgln) )
        zk1tem(jz) = max ( 1.0, 1. / sqrt ( max(zepslon, 1./zrgln) ) )
        zh2tem = zk1tem(jz) - log( zk1tem(jz) ) - 1.0
        zhdtem(jz) = 3. * (zrmin/zrmaj)**3 * (zsound/(zlte*znuei))**2
     &    * ( 1.0 + (zti/zte)*(1.0+zetai) )
        zhctem(jz) = 2.0 * zh1tem(jz) * zh2tem / 3.0
        zd1tem(jz) = 8.0 * zrhos**2 * zsound * zq**2 * zte * zrmaj**2
     &    * sqrt ( 1.0 + (zti/zte)*(1.0+zetai) )
     &    / ( 5.0 * zpi * abs(zlne)**3 * zshat**2 * zti
     &      * ( 1.0 + 5.0*zetai/4.0 ) )
c
        zddtem(jz) = fdr(1) * zfbeta * zelonf**cthery(12) * zdtite
     &    * zd1tem(jz) * min ( zhdtem(jz) , cthery(20) * zhctem(jz) )
        thdre(jz) = fdr(2) * zfbeta * zelonf**cthery(12) * zdtite
     &    * ( zd1tem(jz) / zetae )
     &    * min ( 5.0 * zhdtem(jz) , cthery(20) * zrgln * zhctem(jz) )
        thdri(jz) = fdr(3) * zfbeta * zelonf**cthery(12) *zdtite
     &    * 2.75 * ( (1.0+1.93*zetai)/(1.0+1.25*zetai) )
     &    * ( zd1tem(jz) / zetai )
     &    * min ( zhdtem(jz) , cthery(20) * zhctem(jz) )
        weithe(jz) = fdrint * zfbeta * zelonf**cthery(12) * zdtite
     &    * ( zne * zte / abs(zlne)**2 ) * zd1tem(jz)
     &    * min ( zhdtem(jz) , cthery(20) * zhctem(jz) )
c
      endif
!| 
!| If $ {\tt lthery(6)} = 2 $, the Hahm-Tang toroidal collisionless trapped
!| electron drift wave model is calculated (IAEA, Washington, 1990),
!| as implemented by M. Redi and J. Cummings.
!| 
!| The following are the Hahm formulae for the anomalous fluxes:
!| \[
!| \Gamma_e = - \frac{C_{e}\epsilon}{G^{3}}
!| \left(\frac{R}{L_{n}}\right)^5
!| \left(\frac{R}{GL_{n}}-\frac{3}{2}\right)^{2}
!| exp\left(-\frac{2R}{GL_{n}}\right)
!| \frac{\eta_{e}\frac{T_{e}}{T_{i}}
!| \frac{q^{2}}{\hat{s}^{2}}((\frac{R}{L_{n}})^{\frac{1}{2}} -
!| ln(\frac{R}{L_{n}})^{\frac{1}{2}} - 1)}
!| {(1 + \frac{5}{4}\eta_{i})(1 + \frac{T_{i}}{T_{e}}(1 +
!| \eta_{i}))^{\frac{1}{2}} }
!| \frac{cT_{e}}{eB_{0}}
!| \frac{\rho_{s}}{L_{Te}}
!| \left(\frac{\partial n_{e}}{\partial r}\right)
!| \]
!| 
!| \[
!| Q_{e} = \left(\frac{R}{GL_{n}}\right)T_{e}\Gamma_{e}
!| \]
!| \[
!| Q_{i} = \left(\frac{85 \eta_{i} + 44}{20 \eta_{i} + 16}\right) T_{i}\Gamma_{e}
!| \]
!| 
!| $G = 1.2$ typically, but it is a function of $q(r)$ and $\hat{s}.$
!| $C_{e}$ is almost a constant $(C_{e} \sim 10).$
!| It is a very weak function of various parameters.
!| 
!| The anomalous electron$\rightarrow$ion energy exchange is
!| \[
!| \Delta^{DR} = \frac{T_{e}}{L_{n}}\Gamma_{e}
!| \]
!| 
!| 
!| The validity regime of the Hahm weak turbulence theory is
!| \[
!| 2
!| \left(\frac{2\pi
!| r}{R}\right)^\frac{1}{2}\eta_{e}\left(\frac{R}{L_{n}G}\right)^\frac{3}{2}\left(\frac{R}{L_{n}G}
!| - \frac{3}{2}\right)exp\left(-\frac{R}{L_{n}G}\right) < 1 ,\]
!| where $G\approx 1.2$ and r is the local minor radius. This condition
!| depends primarily on profile broadness.
!| 
!| When $\nu_{e}^{*}$ exceeds 0.1, these formulae are replaced by the
!| Hahm-Tang toroidal dissipative trapped electron drift wave model.
!| The new anomalous fluxes as predicted by the Hahm-Tang DTEM model are:
!| 
!| \[
!| \Gamma_{e}=-\frac{24}{5\pi}\epsilon^{3}\left(\frac{R}{L_{n}}\right)^{2}
!|            \left(\frac{c_{s}}{L_{Te}\nu_{ei}}\right)^{2}
!|            \frac{\frac{T_{e}}{T_{i}}\frac{q^{2}}{\hat s^{2}}}
!|            {(1+\frac{5}{4}\eta_{i})(1+\frac{T_{i}}{T_{e}}
!|            (1+\eta_{i}))^{\frac{3}{2}}}\frac{cT_{e}}{eB_{0}}
!|            \frac{\rho_{s}}{L_{n}}\left(\frac{\partial{n_{e}}}
!|            {\partial{r}}\right)
!| \]
!| 
!| \[
!| Q_{e}=5T_{e}\Gamma_{e}
!| \]
!| 
!| The diffusivity computed from the DTEM model is multiplied by the
!| constant $c_{45}$ in an effort to make it match the predicted diffusivity
!| of the CTEM model at the $ \nu_{e}^{*}=0.1 $ threshold.  The formulae
!| for $Q_{i}$ and $\Delta^{DR}$ remain unchanged from the CTEM model.
!| 
!| If $ {\tt lthery(6)} = 3 $, the original CTEM formula is used, without any
!| transition to the dissipative regime.  If $ {\tt lthery(6)} = 4 $,
!| the Hahm CTEM model is used with no dissipative transition.
!| 
!| If $ {\tt lthery(6)} = 5 $, the Kadomtsev-Pogutse DTEM model is used,
!| with no transition to CTEM.  The Kadomtsev-Pogutse DTEM formula is
!| \[
!| {\hat D}_{te}=\epsilon^{3/2}\eta_{e}\frac{\omega_{e}^{*}}{k_{\perp}^{2}}
!| \frac{\omega_{e}^{*}}{\nu_{ei}}
!| \]
!| If $ {\tt lthery(6)} = 6 $, the Kadomtsev-Pogutse DTEM model is
!| switched on with the Rewoldt transition.
!| 
!| If $ {\tt lthery(6)} = 7 $, the Hahm-Tang CTEM model is used with the
!| Rewoldt transition to the dissipative regime.
!| 
!| If $ {\tt lthery(6)} = 8 $, the Hahm-Tang CTEM model is used, with the
!| Kadomtsev-Pogutse DTEM model for the dissipative regime.
!| 
!| The relevant coding is:
!| 
c
c  start calculating the diffusivities using the transport
c  formulae given in the comments paper.
c
c ......................................
c . the drift wave model calculations  .
c ......................................
c
      if ( lthery(6) .lt. 0 ) then
        zddtem(jz) = 0.0
        thdre(jz) = 0.0
        thdri(jz) = 0.0
      else
c
c  For Hahm CTEM model, calculate validity condition parameter.
c  If zvhahm < 1, plasma is in collisionless regime.
c
      if ( lthery(6) .eq. 2 .or. lthery(6) .eq. 4 .or. lthery(6) .eq. 7
     &    .or. (lthery(6) .eq. 8 .and. thnust(jz) .le. 0.1) ) then
        zvhahm = 2.0 * sqrt(2.0 * zpi * zep) * abs(zetae) *
     &       (zrmaj / abs(zln*1.2))**1.5 * (zrmaj/ abs(zln*1.2) - 1.5)
     &          * exp(-1.0 * zrmaj / abs( zln * 1.2 ))
      else
        zvhahm = 0.0
      endif
c
c  drift wave model options controlled by lthery(6).
c
c  The standard MMM drift wave model with Rewoldt transition.
c
      if ( lthery(6) .eq. 1 ) then
        zdte=(sqrt(zep)*zdiafr/zwn**2)
     &    * min ( cthery(20),
     &              cthery(21) * 0.1 / max(thnust(jz),zepslon) )
c
c  New formulae for Dte from Hahm DTEM model.
c
      elseif ( lthery(6) .eq. 2 ) then
        if ( thnust(jz) .gt. 0.1) then
          zdte = (24.0/5.0/zpi) * abs(zln*zdiafr/zwn) * (zq/zshat)**2
     &           * zep**3 * (zsound/zlte/znuei)**2 * (zte/zti)
     &           / (1.0+1.25*abs(zetai))
     &           / (1.0+(zti/zte)*(1.0+abs(zetai)))**1.5 *
     &           (zrmaj/zln)**2 * abs(zrhos/zln) * cthery(45)
c
c  Hahm CTEM model.
c
        else
          zdte = (2.0**7/15.0) * (sqrt(abs(zrmaj/zln)) -
     &           log(sqrt(abs(zrmaj/zln))) -
     &           1.0) * (zrmaj/zln)**2 *
     &           abs(zvhahm**2/8.0/zpi/zetae) *
     &           (zte/zti) * ( (zq/zshat)**2
     &           / (1.0 + 1.25*abs(zetai)) /
     &           sqrt(1.0 + (zti/zte)*(1.0 + abs(zetai))) ) *
     &           abs(zln*zdiafr/zwn) * (zrhos/zlte)
        endif
c
c  The standard MMM drift wave model with no dissipative transition.
c
      elseif (lthery(6) .eq. 3 ) then
        zdte=(sqrt(zep)*abs(zdiafr)/zwn**2)
c
c  Hahm CTEM model only.
c
      elseif (lthery(6) .eq. 4 ) then
        zdte = (2.0**7/15.0) * (sqrt(abs(zrmaj/zln)) -
     &         log(sqrt(abs(zrmaj/zln))) -
     &         1.0) * (zrmaj/zln)**2 *
     &         abs(zvhahm**2/(8.0*zpi*zetae)) *
     &         (zte/zti) * ( (zq/zshat)**2 / (1.0 + 1.25*abs(zetai)) /
     &         sqrt(1.0 + (zti/zte)*(1.0 + abs(zetai))) ) *
     &         abs(zln*zdiafr/zwn) * abs(zrhos/zlte)
c
c  Kadomtsev-Pogutse DTEM model with no collisionless transition.
c
      elseif (lthery(6) .eq. 5 ) then
        zdte=zep**1.5 * zdiafr**2 * abs(zetae) / ( zwn**2 * znuei )
c
c  Kadomtsev-Pogutse DTEM model with "inverse" Rewoldt transition
c  to the collisionless regime.
c
      elseif (lthery(6) .eq. 6 ) then
        zdte=(zep**1.5 * zdiafr**2 * abs(zetae) / zwn**2 / znuei)
     &       * thnust(jz)/0.1
     &       * min ( cthery(20),
     &       cthery(21) * 0.1 / max(thnust(jz),zepslon) )
c
c  Hahm-Tang CTEM model with Rewoldt transition.
c
      elseif (lthery(6) .eq. 7) then
          zdte = (2.0**7/15.0) * (sqrt(abs(zrmaj/zln)) -
     &           log(sqrt(abs(zrmaj/zln))) -
     &           1.0) * (zrmaj/zln)**2 *
     &           abs(zvhahm**2/8.0/zpi/zetae) *
     &           (zte/zti) * ( (zq/zshat)**2 / (1.0 + 1.25*abs(zetai))
     &           / sqrt(1.0 + (zti/zte)*(1.0 + abs(zetai))) ) *
     &           abs(zln*zdiafr/zwn) * abs(zrhos/zlte)
     &           * min ( cthery(20),
     &           cthery(21) * 0.1 / max(thnust(jz),zepslon) )
c
c  Hahm-Tang CTEM model and Kadomtsev-Pogutse DTEM model.
c
      elseif (lthery(6) .eq. 8) then
        if (thnust(jz) .gt. 0.1) then
          zdte=zep**1.5 * zdiafr**2 * abs(zetae) / zwn**2 / znuei
     &         * cthery(46)
        else
          zdte = (2.0**7/15.0) * (sqrt(abs(zrmaj/zln)) -
     &           log(sqrt(abs(zrmaj/zln))) -
     &           1.0) * (zrmaj/zln)**2 *
     &           abs(zvhahm**2/8.0/zpi/zetae) *
     &           (zte/zti) * ( (zq/zshat)**2 / (1.0 + 1.25*abs(zetai))
     &           / sqrt(1.0 + (zti/zte)*(1.0 + abs(zetai))) ) *
     &           abs(zln*zdiafr/zwn) * abs(zrhos/zlte)
        endif
c
c  lthery(6)=0, so use original formula from Comments paper.
c
      else
        zdte = abs(sqrt(zep)*zdiafr/zwn**2)
     &    * min ( cthery(20), cthery(21) * abs(zdiafr) / znueff )
      endif
c
c  Hahm model: don't include beta ratio or elongation in drift wave D.
c
      zelfdr = zelong**cthery(12)
      zbprim = abs(zbeta/zlpr)
      zbc1   = abs(zshat/(1.7*zq**2*zrmaj))
      zbpbc1 = zbprim/zbc1
      zratio = (1.0+zbpbc1)/(1.0+zbpbc1**3)
      if ( lthery(6) .eq. 2 .or. lthery(6) .eq. 4 .or. lthery(6) .eq. 7
     &    .or. (lthery(6) .eq. 8 .and. thnust(jz) .le. 0.1) ) then
        zdd = zdte
        zddtem(jz) = zdd * fdr(1) * zdtite
      else
        zdd = zratio * zdte
        zddtem(jz) = zdd * fdr(1) * zelfdr * zdtite
      endif
c
c  if lthery(6) = 2,4,7 or 8 use Hahm formulae for Xe, Xi.
c
      if ( lthery(6) .eq. 2 .or. lthery(6) .eq. 4 .or. lthery(6) .eq. 7
     &    .or. (lthery(6) .eq. 8 .and. thnust(jz) .le. 0.1) ) then
        if ( lthery(6) .eq. 2 .and. thnust(jz) .gt. 0.1) then
          thdre(jz) = fdr(2) * 5.0 * abs(zdte/zetae) * zdtite
        else
          thdre(jz) = fdr(2) * abs(zrmaj/ (1.2*zln))
     &                * abs(zdte/zetae) * zdtite
        endif
        thdri(jz) = fdr(3) * (85.0*abs(zetai) + 44.0)
     &              /(20.0*abs(zetai) + 16.0) *
     &              abs(zdte*zne*zlti/zni/zlne) * zdtite
      else
        thdre(jz) = 2.5 * fdr(2) * zratio * zdte * zelfdr * zdtite
        thdri(jz) = 2.5 * fdr(3) * zratio * zdte * zelfdr * zdtite
      endif
c
c..end of trapped electron mode section
c
      endif
c
!| 
!| The drift wave contributions cited in the Comments paper\cite{Comments}
!| have been moved to the end of the section on $\eta_i$ modes because
!| the original drift wave and $\eta_i$ models were intertwined.
!| 
!| %**********************************************************************c
!| 
!| \subsection{$\eta_i$ Modes}
!| 
!| First consider the threshold for $\eta_i$ modes given by $\eta_{i}^{th}$:
!| For the default model, we use a form given by Romanelli:\cite{Romanelli}
!| $$ \eta_{i}^{th} = max [ c_{11}, c_{11}+2.5( \frac{L_{n}}{R_{o}}-.2)]
!|  \eqno{\tt zetith} $$
!| (This makes quantitative
!| a similar suggestion which Dominguez and Waltz noted to be
!| important at the 1988 Sherwood theory meeting \cite{Sherwood}.
!| It constitutes
!| the most significant difference from the Comments paper to be incorporated
!| in the default model.)
!| 
!| If ${\tt lthery(8)} = 1$, the $\eta_i$ threshold by
!| Mattor-Diamond\cite{matt89a}
!| and by Hahm-Tang\cite{hahm89a} [Eq(13a)] is used,
!| with coefficients controlled by ${\tt cthery(30)} = 1.0$ and
!| ${\tt cthery(31)} = 1.9$:
!| $$ \eta_i^{th} = c_{30} + c_{31} | (1+T_i/T_e) ( L_n / L_s) |.
!|       \eqno{\tt zetith} $$
!| 
!| If ${\tt lthery(8)} = 2$, forms of the $\eta_i$ threshold suggested by
!| Dominguez-Rosenbluth\cite{domn89a} are used
!| $$ \eta_i^{th} = max [ c_{30}, c_{31} L_n / R, c_{32} L_n / ( R q ) ].
!|       \eqno{\tt zetith} $$
!| Recommended values are ${\tt cthery(30)} = 1.0$ (the default value)
!| and ${\tt cthery(31)} = 5.0$
!| (diferent from the default value ${\tt cthery(31)} = 1.9$)
!| or ${\tt cthery(32)} = 20.0$.
!| 
!| The function that turns the $\eta_i$ mode on or off $f_{ith}$
!| is the same as the form used by Dominguez and Waltz:
!| $$  f_{ith}=c_{6}\{1+\exp[-c_{7}(\eta_{i}-\eta_{i}^{th})]\}^{-1}
!|  \eqno{\tt zfith} $$
!| If ${\tt lthery(9)} = 1$, the argument of the exponent is normalized
!| by $\eta_{i}^{th}$ in order to avoid excessively large swings in
!| $f_{ith}$ in regions of flat density profile where $\eta_{i}^{th}$
!| is very large:
!| $$ f_{ith}=c_{6}\{1+\exp[-c_{7}(\eta_{i}-\eta_{i}^{th})/\eta_{i}^{th}
!|     ]\}^{-1}   \eqno{\tt zfith}$$
!| If ${\tt lthery(9)} = 2$, a linear ramp form is used for $f_{ith}$:
!| \[ f_{ith} = \left\{ \begin{array}{ll}
!| 0. & \mbox{ if $\eta_i < \eta_i^{th}$} \\
!| c_6 ( \eta_i / \eta_i^{th} - 1 ) / c_7
!|      & \mbox{if $\eta_i^{th} \leq \eta_i \leq (1+c_7) \eta_i^{th}$ } \\
!| c_6 & \eta_i > \mbox{if $ (1+c_7) \eta_i^{th}$ }  \end{array}  \right. \]
!| If the input value of $c_7$ is less than {\tt zepslon}, then 1.0 is used.
!| 
c
c..threshold eta_i
c
      if ( lthery(8) .lt. 0 ) then
        zetith = 0.0
c
      elseif ( lthery(8) .eq. 2 ) then
        zetith = max ( cthery(30), cthery(31) * zlnj / zrmaj,
     &    cthery(32) * zlnj / ( zrmaj * zq ) )
c
      elseif ( lthery(8) .eq. 1 ) then
        zetith = cthery(30) + cthery(31) * abs( ( 1.0 + zti / zte )
     &           * ( zlnj / max ( zlsh, zepslon ) ) )
c
      else
        zetith = max ( cthery(11)
     &    , cthery(11) + 2.5 * ( zlnj / zrmaj - 0.2 ) )
      endif
c
c..onset function
c
      if ( lthery(9) .lt. 0 ) then
        zfith = 0.0
      elseif ( lthery(9) .eq. 1 ) then
        zexdr = -cthery(7) * (zetai-zetith) / zetith
        zovfdr = min( max(zexdr,zlgeps), -zlgeps )
        zfith = cthery(6) / ( 1.0 + exp( zovfdr ) )
      else if ( lthery(9) .eq. 2 ) then
        z7 = cthery(7)
        if ( z7 .lt. zepslon ) z7 = 1.0
          zfith = 0.0
        if ( zetai .gt. (1. + z7)*zetith ) then
          zfith = cthery(6)
        else if ( zetai .gt. zetith ) then
          zfith = cthery(6) * (zetai-zetith) / ( z7 * zetith )
        endif
      else
        zexdr = -cthery(7) * (zetai-zetith)
        zovfdr = min( max(zexdr,zlgeps), -zlgeps )
        zfith = cthery(6) / ( 1.0 + exp( zovfdr ) )
      endif
!| 
!| On 24 April 1990, it was suggested by R. Dominguez that the transport from
!| $eta_i$ modes sould be reduced by the factor
!| $$ \exp^{-c_{34}(T_i/T_e - 1)^2}.  \eqno{\tt zftite} $$
!| By default, $c_{34} = 0.0$, so this factor has no effect.
!| Dominguez suggests the value $c_{34} = 1.0$.
!| 
      zftite = 1.0
      if ( abs(cthery(34)) .gt. zepslon )
     &  zftite = exp( -cthery(34) * ((zti/zte)-1.)**2 )
!| 
!| %**********************************************************************c
!| 
!| \subsubsection{The Ottoviani-Horton-Erba ``Santa Barbara'' $\eta_i$ model}
!| 
!| The 1996 Ottoviani-Horton-Erba ITG/TEM mode transport model \cite{hortoncomm}
!| is selected by setting {\tt lthery(7) = 4}.
!| This model is derived from the assumption that the ion thermal diffusivity
!| will be related to the radial correlation length $\lambda_c$ and
!| correlation time $\tau_c$ for ITG-driven turbulence:
!| \[ \chi_i^{\rm ITG} \propto \frac{\lambda_c^2}{\tau_c} \]
!| 
!| The correlation length $\lambda_c$ is estimated from the large-scale
!| poloidal cutoff ($k_{\theta c}$) of the turbulent spectrum:
!| \[ \lambda_c \simeq \frac{1}{k_{\theta c}} \simeq
!|    \frac{q R \rho_s}{L_{T_i}} \]
!| where $\rho_s$ is a quantity that has units of length and is related
!| to the electron and ion Larmor radii ($\rho_e$ and $\rho_i$, respectively):
!| \[ \rho_s = \frac{ \sqrt{m_i T_e}}{eB} =
!|    \sqrt{ \frac{m_i}{m_e} } \rho_e =
!|    \sqrt{ \frac{T_e}{T_i} } \rho_i \]
!| 
!| In order to give the correct scaling with plasma current, the
!| correlation time $\tau_c$ is not simply the growth rate of the
!| fastest-growing ITG-driven instability.
!| Instead, $\tau_c$ is given by:
!| \[ \tau_c \simeq \frac{ \sqrt{ R L_{T_i} } }{v_i} \]
!| where $v_i$ is the ion thermal velocity.
!| 
!| Putting these estimates together, we find that the ion thermal diffusivity
!| is (in MKS units):
!| \[ \chi_i^{\rm ITG} = C_i \left( \frac{T_e}{eB} \right) q^2
!|    \left( \frac{\rho_i}{L_{T_i}} \right)
!|    max \left[ 0, \frac{R}{L_{T_i}} \right] \]
!| where $C_i$ is a constant to be calibrated (see below).
!| 
!| Notice that the OHE model does not include a critical gradient or any other
!| mechanism for ``shutting off'' the ITG-driven transport.
!| The derivation of this model assumes that the plasma is not near
!| marginal stability, so that neglecting the critical gradient is a
!| good approximation.
!| If the plasma is near marginal stability, however, the ITG-driven flux
!| will decrease linearly with the difference
!| \[ \frac{R}{L_{T_i}} - \frac{R}{L_{T_i}^{\rm crit}} \]
!| where $L_{T_i}^{\rm crit}$ denotes the critical ion temperature scale
!| length.
!| So, the ITG-driven flux will have the form:
!| $$ \chi_i^{\rm ITG} = C_i \left( \frac{T_e}{eB} \right) q^2
!|   \left( \frac{\rho_i}{L_{T_i}} \right)
!|   \left( \frac{R}{L_{T_i}} -
!|                   c_{29} \frac{R}{L_{T_i^{\rm crit}}} \right)
!|   \eqno{\tt thigi} $$
!| where selecting {\tt cthery(29) = 0} would make the critical gradient term
!| vanish.
!| Ottoviani, {\it et al} do not provide a method for calculating the critical
!| $T_i$ gradient.
!| However, there are many models included in the BALDUR code for finding
!| threshold $\eta_i$'s, and any of these could be used.
!| 
!| With regards to the electron thermal diffusivity $\chi_e^{\rm ITG}$,
!| Ottoviani, {\it et al} \cite{hortoncomm} simplify the situation considerably
!| by assuming that
!| the electron heat energy will be conducted only by the trapped electrons.
!| Then, simplify further by assuming that $\chi_e^{\rm ITG}$ will be equal
!| to $\chi_i^{\rm ITG}$ multiplied by the trapped particle fraction
!| ($\sqrt{\epsilon}$, where $\epsilon$ is the inverse aspect ratio r/R):
!| $$ \chi_e^{\rm ITG} = C_e \left( \frac{T_e}{eB} \right) q^2
!|   \sqrt{\epsilon}
!|   \left( \frac{\rho_i}{L_{T_i}} \right)
!|   max \left[ 0, \frac{R}{L_{T_i}} - \frac{R}{L_{T_i}^{\rm crit}} \right]
!|   \eqno{\tt thige} $$
!| where $C_e$ is a constant.
!| These expressions were calibrated against the medium power L-mode JET
!| discharge \#19649.
!| The optimum fit between the JETTO runs and the experimental data were
!| acheived when:
!| \[ C_i = C_e = 0.014 \]
!| 
!| The OHE model, in its given form, does not include particle transport,
!| as it assumes an adiabatic electron response.
!| However, in the BALDUR code, we are following four transport channels:
!| ion and electron thermal, and hydrogenic and impurity particles.
!| Therefore, we extend this model by obtaining a particle diffusivity
!| $D^{\rm ITG}$ that is equal to the ion thermal diffusivity $\chi_i^{\rm ITG}$:
!| $$ D^{\rm ITG} = \chi_i^{\rm ITG} = C_i \left( \frac{T_e}{eB} \right) q^2
!|   \left( \frac{\rho_i}{L_{T_i}} \right)
!|   max \left[ 0, \frac{R}{L_{T_i}} - \frac{R}{L_{T_i}^{\rm crit}} \right]
!|   \eqno{\tt zddig,zdzig} $$
!| 
!| The relevant coding is:

c     *
c     * The Ottoviani-Horton-Erba ITG/TEM model
c     *
      if ( lthery(7) .eq. 4) then
c
c        First, include the critical gradient effects
c
         if ( cthery(29) .gt. zepslon) then
            zdig = max(0.0,
     &         zrmaj/zslti(jz) - cthery(29)*zrmaj*zetith/zslne(jz))
         else
            zdig = max(0.0,zrmaj/zslti(jz))
            zdig = zdig**(1.5)
          end if
c
c        Calculate chi_i according to Ottoviani, et al
c
         zdig = (0.014)*zq*zq*zlari*zdig/zslti(jz)
         zdig = (zckb*zte*zdig)/(zce*zb)
c
c        Now find the actual diffusivities
c
         zddig(jz) = fig(1)*zdig*zftite*zelonf**cthery(14)
         zdzig(jz) = fig(1)*zdig*zftite*zelonf**cthery(14)
         thigi(jz) = fig(2)*zdig*zftite*zelonf**cthery(14)
         thige(jz) = fig(3)*sqrt(zep)*zdig*zftite*zelonf**cthery(14)
c
      end if

!| 
!| Note that the coding includes two additional modifiers to the diffusivities:
!| {\tt zftite} and {\tt zelonf**cthery(14)}.
!| The first factor reduces
!| the transport to take account of $T_i/T_e$, but will be equal to unity
!| when {\tt cthery(34) = 0.0}.
!| The second factor modifies the diffusivity based upon the elongation.
!| Normally, {\tt cthery(14) = -4}, giving a $\kappa^{-4}$ dependence.
!| 
!| Good results have been obtained with the OHE model thermal transport
!| when the particle transport is given by BALDUR's empirical model
!| (described elsewhere).
!| 
!| %**********************************************************************c
!| 
!| The $\eta_i$-mode model by Kim and Horton\cite{kim92a} is implemented
!| when ${\tt lthery(7)} = 6$.
!| Note that the diffusivity from this model is normalized by
!| $ \rho_s^2 c_s q^2 / L_n $ and it is computed only when $ L_n > 0 $.
!| The frequencies are normalized by $ c_s / L_n $.
!| 
c
c..no eta_i mode model if lthery(7) < 0
c
      if ( lthery(7) .lt. 0 ) then
c
        zddig(jz) = 0.0
        zdzig(jz) = 0.0
        thige(jz) = 0.0
        thigi(jz) = 0.0
c
c..Kim-Horton-Coppi eta_i mode model if lthery(7) =6
c
      elseif ( lthery(7) .eq. 6 ) then
c
        do jc=1,32
          iletai(jc) = 0
          zcetai(jc) = 0.0
        enddo
c
        iletai(3)  = 1
        iprint  = 0
        ztauie  = zti / zte
        zepsn  = zln / zrmaj
        zbetai = 2. * zcmu0 * zckb * zni * zti / zb**2
        zftrap = sqrt ( 2. * zrmin / ( zrmaj * ( 1. + zrmin / zrmaj )))
c
        zqprr  = 0.0
        if ( abs(cthery(38)) .lt. zepslon ) then
          zkyrho = 0.5
        else
          zkyrho = cthery(38)
        endif
        zkparl = zln / ( zq * zrmaj )
c
        zomegain  = 0.2
        zgammain  = 0.04
        if ( cthery(39) .gt. zepslon ) zgammain = cthery(39)
c
        zwnprin = 0.5
        zwnpdel = 0.1
        zerrabs = 0.01
        imaxfun = 20
c
        zxmr    = 10.0
        insig   = 7
        iitmax  = 20
        zdel    = 0.01
        zftest  = 1.e-7
c
        write (nprint,*)
     &    'sbrtn e3bsub not available at present'
c
cbate        call e3bsub ( iletai, zcetai, iprint
cbate     &   , zetai, zetae, ztauie, zepsn, zbetai
cbate     &   , zftrap, zqprr, zkyrho, zkparl, zomegain, zgammain
cbate     &   , zwnprin, zwnpdel, zerrabs, imaxfun
cbate     &   , zxmr, insig, iitmax, zdel, zftest
cbate     &   , zomegab, zgammab, zdifetai )
c
cahk        zgmeti(jz) = zgammab
c
        if ( zln .lt. zepslon ) then
c
          zddig(jz) = 0
          zdzig(jz) = 0
          thige(jz) = 0
          thigi(jz) = 0
c
        else
c
          znorm = zelonf**cthery(12) *
     &      zrhos**2 * zsound * zq**2 / zln
c
cahk          zddig(jz) = fig(1) * znorm * zdifetai
cahk          zdzig(jz) = fig(1) * znorm * zdifetai
cahk          thige(jz) = fig(2) * znorm * zdifetai
cahk          thigi(jz) = fig(3) * znorm * zdifetai
c
        endif
c
!| 
!| %**********************************************************************c
!| 
!| The $\eta_i$ and trapped electron mode model
!| by Weiland et al\cite{nord90a} is implemented when
!| ${\tt lthery(7)}$ is set between 21 and 28.
!| When $ {\tt lthery(7)} = 21 $, only the hydrogen equations are used
!| (with no trapped electrons or impurities) to compute only the
!| $ \eta_i $ mode.
!| When $ {\tt lthery(7)} = 22 $, trapped electrons are included,
!| but not impurities.
!| When $ {\tt lthery(7)} = 23 $, a single species of impurity ions is
!| included as well as trapped electrons.
!| When $ {\tt lthery(7)} = 24 $, the effect of collisions is included.
!| When $ {\tt lthery(7)} = 25 $, parallel ion (hydrogenic) motion and
!| the effect of collisions are included.
!| When $ {\tt lthery(7)} = 26 $, finite beta effects and collisions are
!| included.
!| When $ {\tt lthery(7)} = 27 $, parallel ion (hydrogenic) motion,
!| finite beta effects, and the effect of collisions are included.
!| When $ {\tt lthery(7)} = 28 $, parallel ion (hydrogenic and impurity) motion,
!| finite beta effects, and the effect of collisions are included.
!| Finite Larmor radius corrections are included in all cases.
!| Values of {\tt lthery(7)} between 21 and 35 are reserved for extensions
!| of this Weiland model.
!| 
!| The mode growth rate, frequency, and effective diffusivities are
!| computed in subroutine {\tt etaw14}.
!| Frequencies are normalized by $\omega_{De}$ and diffusivities are
!| normalized by $ \omega_{De} / k_y^2 $.
!| The order of the diffusivity equations is
!| $ T_H $, $ n_H $, $ T_e $, $ n_Z $, $ T_Z $, \ldots
!| Note that the effective diffusivities can be negative.
!| 
!| The diffusivity matrix $ D = {\tt difthi(j1,j2)}$
!| is given in the following form:
!| $$ \frac{\partial}{\partial t}
!|  \left( \begin{array}{c} n_H T_H  \\ n_H \\ n_e T_e \\
!|     n_Z \\ n_Z T_Z \\ \vdots
!|     \end{array} \right)
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
!| \left( \begin{array}{l} {\bf v}_1 n_H T_H \\ {\bf v}_2 n_H \\
!|    {\bf v}_3 n_e T_e \\
!|    {\bf v}_4 n_Z \\ {\bf v}_5 n_Z T_Z \\ \vdots \end{array} \right) +
!|  \left( \begin{array}{c} S_{T_H} \\ S_{n_H} \\ S_{T_e} \\
!|     S_{n_Z} \\ S_{T_Z} \\ \vdots
!|     \end{array} \right) $$
!| Note that all the diffusivities in this routine are normalized by
!| $ \omega_{De} / k_y^2 = 2 \rho_s c_s / ( R k_y ) $,
!| convective velocities are normalized by
!| $ \omega_{De} / R k_y^2 = 2 \rho_s c_s / ( R^2 k_y ) $,
!| and all the frequencies are normalized by $ \omega_{De} $.
!| 
!| For the moment, consider only the first impurity species.
!| 
!| Define the impurity density gradient scale length to be
!| \[ L_{nZ} \equiv Z n_Z / \frac{d Z n_Z}{d x}. \]
!| Then, it follows from charge neutrality that
!| \[ \frac{1}{L_{ne}} = \frac{ 1 - f Z }{L_{nH}} + \frac{ f Z }{L_{nZ}} \]
!| where $ f \equiv n_Z / n_e $ and $ n_e = n_H + Z n_Z $.
!| For this purpose, all the impurity species are lumped together as
!| one effective impurity species and all the hydrogen isotopes are lumped
!| together as one effective hydrogen isotope.
!| 
      elseif ( lthery(7) .ge. 21 .and. lthery(7) .le. 35 ) then
c
        do jc=1,32
          iletai(jc) = 0
          zcetai(jc) = 0.0
        enddo
c
        zcetai(11) = 1.0
c
c.. coefficient of k_parallel for parallel ion motion
c.. cthery(125) for v_parallel in strong ballooning limit
c.. in 9 eqn model
c
        zcetai(10) = cthery(123)
        zcetai(12) = cthery(125)
        zcetai(15) = cthery(124)
        zcetai(20) = cthery(119)
        zcetai(25) = cthery(122)
c
c  Use complex NAG routine f02gje - this is obsolete as of etaw17
c
        iletai(10) = 0
c
        iprint = lthery(29) - 10
c
c       For up to 6 equations
c
        if ( lthery(7) .le. 23 ) then
          ieq = (lthery(7) - 20) * 2
        endif
c
        if ( lthery(7) .eq. 24 ) ieq = 7
        if ( lthery(7) .eq. 25 ) ieq = 8
        if ( lthery(7) .eq. 26 ) ieq = 9
        if ( lthery(7) .eq. 27 ) ieq = 10
        if ( lthery(7) .eq. 28 ) ieq = 11
c
        idim   = matdim
        idim2  = idim**2
c
c  Hydrogen species
c
        zthte  = zti / zte
        zepsnh = zlni / zrmaj
        if ( lthery(3) .ge. 3 ) zepsnh = zlnh / zrmaj
        zepsth = zlti / zrmaj
        zbetah = 2. * zcmu0 * zckb * zni * zti / zb**2
        zbetae = 2. * zcmu0 * zckb * zne * zte /   zb**2
c
        zepste = zlte / zrmaj
c
c  Impurity species (use only impurity species 1 for now)
c  assume T_Z = T_H throughout the plasma here
c
        ztz    = zti
        znz    = densimp(jz)
        zmass  = amassimp(jz)
        zimpz  = avezimp(jz)
        zimpz  = max ( zimpz, cthery(120) )
c
        ztzte  = zti / zte
        zepstz = zepsth
        zfnzne = znz / zne
        zmzmh  = zmass / amasshyd(jz)
        zbetaz = 2. * zcmu0 * zckb * znz * ztz / zb**2
c
c  compute zepsnz from zepsnh and zepsne or from zlnz directly
c
        if ( lthery(3) .ge. 4 ) then
          zepsnz = zlnz / zrmaj
        else
          zepsne = zlne / zrmaj
          zepsnz = zfnzne * zimpz * zepsnh
     &      / ( zfnzne * zimpz - 1.0 + zepsnh   / zepsne )
        endif
c
c  superthermal ions
c
c  zfnsne = ratio of superthermal ions to electrons
c  L_ns   = gradient length of superthermal ions
c  zepsne = L_ns / R
c
        zfnsne = max ( zfnsnea(jz), 0.0 )
c
        zgrdns = zrmaj * ( 1.0 / zlne
     &    - ( 1.0 - zimpz * zfnzne - zfnsne ) / zlnh
     &    - zimpz * zfnzne / zlnz ) / max ( zfnsne, 1.e-6 )
c
        zftrap = sqrt ( 2. * zrmin / ( zrmaj * ( 1. + zrmin / zrmaj )))
        if ( cthery(126) .gt. zepslon ) zftrap = cthery(126)
        if ( cthery(126) .lt. -zepslon )
     &       zftrap = abs(cthery(126))*zftrap
c
        if ( abs(cthery(38)) .lt. zepslon ) then
          zkyrho = 0.316
        else
          zkyrho = cthery(38)
        endif
        zkparl = zln / ( zq * zrmaj )
        zcetai(32) = cthery(128)
c
c...Define a local copy of normalized ExB shearing rate : pis
c
        zomegde(jz) = 2.0 * zkyrho * zsound / zrmaj
        wexbs(jz) = cthery(129)*wexbs(jz)
        zwexb = wexbs(jz) / zomegde(jz)
c
c
c  normalized gradients
c
        zgne = zrmaj / zlne
        zgnh = zrmaj / zlnh
        zgnz = zrmaj / zlnz
        zgns = zgrdns
        zgte = zrmaj / zlte
        zgth = zrmaj / zlti
        zgtz = zrmaj / zlti
c
c..diagnostic printout
c
cbate        write (nprint,199) zrmin, grdti(jz), zgth
 199    format ('#zz1',1p8e12.4)
c
c  Use NAG14 rather than IMSL routine - this is obsolete as of etaw17
c
        iletai(6)  = 0
        if ( lthery(8) .eq. 20 ) iletai(7) = 1
c
cbate        if ( nstep .eq. lthery(26) ) then
cbate          mprint = nprint
cbate        else
cbate          mprint = 99
cbate        endif
c
        if ( iprint .gt. 0 ) write (nprint,191) jz, nstep
 191    format (/' jz = ',i4,'  nstep = ',i5,' call etaw17a')
c
        if (lthery(22) .eq. -1 ) then

          iletai(9) = 2  ! to compute only the effective diffusivities

          call weiland14 (
     &     iletai,   zcetai,   iprint,   ieq,      nprint,   zgne
     &   , zgnh,     zgnz,     zgte,     zgth,     zgtz,     zthte
     &   , ztzte,    zfnzne,   zimpz,    zmzmh,    zfnsne,   zbetae
     &   , zftrap,   znuhat,   zq,       zshat,    zkyrho,   zwexb
     &   , idim,     zomega,   zgamma,   zdfthi,   zvlthi,   zchieff
     &   , zflux,    imodes,   inerr )

c
        else if (lthery(22) .eq. -2 ) then

           call etaw14diff ( iletai, zcetai, iprint, ieq, nprint
     &    , zgne, zgnh, zgnz, zgte, zgth, zgtz, zthte, ztzte
     &    , zfnzne, zimpz, zmzmh, zfnsne, zbetae, zbetah, zbetaz
     &    , zftrap, znuhat, zq, zshat, zkyrho, zkparl, zwexb
     &    , idim, zomega, zgamma, zdfthi, zvlthi
     &    , zchieff, imodes, zperf, inerr )
c
        else if (lthery(22) .eq. -3 ) then

           call etaw14a ( iletai, zcetai, iprint, ieq, nprint
     &    , zgne, zgnh, zgnz, zgte, zgth, zgtz, zthte, ztzte
     &    , zfnzne, zimpz, zmzmh, zfnsne, zbetae, zbetah, zbetaz
     &    , zftrap, znuhat, zq, zshat, zkyrho, zkparl, zwexb
     &    , idim, zomega, zgamma, zdfthi, zvlthi
     &    , zchieff, imodes, zperf, inerr )
c
        else if (lthery(22) .eq. -4 ) then

           call etaw17diff ( iletai, zcetai, iprint, ieq, nprint
     &    , zgne, zgnh, zgnz, zgte, zgth, zgtz, zthte, ztzte
     &    , zfnzne, zimpz, zmzmh, zfnsne, zbetae, zbetah, zbetaz
     &    , zftrap, znuhat, zq, zshat, zelong, zkyrho, zkparl, zwexb
     &    , idim, zomega, zgamma, zdfthi, zvlthi
     &    , zchieff, imodes, zperf, inerr )

        else

           call etaw17a ( iletai, zcetai, iprint, ieq, nprint
     &    , zgne, zgnh, zgnz, zgte, zgth, zgtz, zthte, ztzte
     &    , zfnzne, zimpz, zmzmh, zfnsne, zbetae, zbetah, zbetaz
     &    , zftrap, znuhat, zq, zshat, zelong, zkyrho, zkparl, zwexb
     &    , idim, zomega, zgamma, zdfthi, zvlthi
     &    , zchieff, imodes, zperf, inerr )

        endif
c
c  Find maximum performance index
c
c      DO jm = 1, 5
c          write(54, '(5e12.4,A3,e12.4)')
c     &    (zdfthi(jm,j1),j1=1,5) ,' | ', zvlthi(jm)
c      END DO
c      write(54,*)
c      write(54,'(5e12.4)') (zchieff(jm),jm=1,5)
c      write(54,*)
      zprfmx(jz) = 0.0
      do jm=1,ieq
        if ( zperf(jm) .gt. abs ( zprfmx(jz) ) )
     &    zprfmx(jz) = zperf(jm)
      enddo
c
c  Growth rates for diagnostic output
c    Note that all frequencies are normalized by \omega_{De}
c      consequently, trapped electron modes rotate in the positive
c      direction (zomega > 0) while eta_i modes have zomega < 0.
c
        zomegse(jz) = zomegde(jz) * 0.5 * zgne
        zkinvsq(jz) = zrhos**2 / zkyrho**2
c
        zgmitg(jz) = 0.0
        zomitg(jz) = 0.0
        zgmtem(jz) = 0.0
        zomtem(jz) = 0.0
        zgm2nd(jz) = 0.0
        zom2nd(jz) = 0.0
c
        do jm=1,ieq
          if ( zomega(jm) .gt. 0.0 ) then
            if ( zgamma(jm) .gt. zgmtem(jz) ) then
              zgmtem(jz) = zgamma(jm)
              zomtem(jz) = zomega(jm)
            else if ( zgamma(jm) .gt. zgm2nd(jz) ) then
              zgm2nd(jz) = zgamma(jm)
              zom2nd(jz) = zomega(jm)
            endif
          else
            if ( zgamma(jm) .gt. zgmitg(jz) ) then
              zgmitg(jz) = zgamma(jm)
              zomitg(jz) = zomega(jm)
            else if ( zgamma(jm) .gt. zgm2nd(jz) ) then
              zgm2nd(jz) = zgamma(jm)
              zom2nd(jz) = zomega(jm)
            endif
          endif
        enddo
c
c..convert growth rates and frequencies to (sec)^{-1}
c
        zgmitg(jz) = zgmitg(jz) * zomegde(jz)
        zomitg(jz) = zomitg(jz) * zomegde(jz)
        zgmtem(jz) = zgmtem(jz) * zomegde(jz)
        zomtem(jz) = zomtem(jz) * zomegde(jz)
        zgm2nd(jz) = zgm2nd(jz) * zomegde(jz)
        zom2nd(jz) = zom2nd(jz) * zomegde(jz)
c
c  compute diffusivity matrix
c
        znormd = zelonf**cthery(12) *
     &    2.0 * zsound * zrhos**2 / ( zrmaj * zkyrho )
        znormv = zelonf**cthery(12) *
     &    2.0 * zsound * zrhos**2 / ( zrmaj**2 * zkyrho )
c
c        call resetr ( difthi(1,1,jz), idim2, 0.0 )
c        call resetr ( velthi(1,jz), idim, 0.0 )
c
        do j1=1,matdim
          velthi(j1,jz) = 0.0
          do j2=1,matdim
            difthi(j1,j2,jz) = 0.0
          enddo
        enddo
c
c..full matrix form of model
c
        if ( lthery(8) .lt. 21 ) then
c
          if ( lthery(7) .eq. 21 ) then
            difthi(1,1,jz) = fig(3) * znormd * zdfthi(1,1)
            velthi(1,jz)   = fig(3) * znormv * zvlthi(1)
          elseif ( lthery(7) .eq. 22 ) then
            do j2=1,3
              difthi(1,j2,jz) = fig(3) * znormd * zdfthi(1,j2)
              difthi(2,j2,jz) = fig(1) * znormd * zdfthi(2,j2)
              difthi(3,j2,jz) = fig(2) * znormd * zdfthi(3,j2)
              difthi(4,j2,jz) = fig(1) * znormd * zdfthi(2,j2)
            enddo
              velthi(1,jz)    = fig(3) * znormv * zvlthi(1)
              velthi(2,jz)    = fig(1) * znormv * zvlthi(2)
              velthi(3,jz)    = fig(2) * znormv * zvlthi(3)
              velthi(4,jz)    = fig(1) * znormv * zvlthi(2)
          else
            do j2=1,4
              difthi(1,j2,jz) = fig(3) * znormd * zdfthi(1,j2)
              difthi(2,j2,jz) = fig(1) * znormd * zdfthi(2,j2)
              difthi(3,j2,jz) = fig(2) * znormd * zdfthi(3,j2)
              difthi(4,j2,jz) = fig(1) * znormd * zdfthi(4,j2)
            enddo
              velthi(1,jz)    = fig(3) * znormv * zvlthi(1)
              velthi(2,jz)    = fig(1) * znormv * zvlthi(2)
              velthi(3,jz)    = fig(2) * znormv * zvlthi(3)
              velthi(4,jz)    = fig(1) * znormv * zvlthi(4)
          endif
c
        endif
c
c  compute effective diffusivites for diagnostic purposes only
c
        zddig(jz) = fig(1) * znormd * zchieff(2)
        zdzig(jz) = fig(1) * znormd * zchieff(4)
        thige(jz) = fig(2) * znormd * zchieff(3)
        thigi(jz) = fig(3) * znormd * zchieff(1)
     &  + fig(3)*znormd*zchieff(5) * densimp(jz)/densi(jz)*cthery(130)
c
c
c..transfer from diffusivity to convective velocity
c
        if ( lthery(27) .gt. 0 ) then
c
          if ( thigi(jz) .lt. 0.0 ) then
            velthi(1,jz) = velthi(1,jz) - thigi(jz) / zlti
            thigi(jz) = 0.0
            do j2=1,4
              difthi(1,j2,jz) = 0.0
            enddo
          endif
c
          if ( zddig(jz) .lt. 0.0 ) then
            velthi(2,jz) = velthi(2,jz) - zddig(jz) / zlnh
            zddig(jz) = 0.0
            do j2=1,4
              difthi(2,j2,jz) = 0.0
            enddo
          endif
c
          if ( thige(jz) .lt. 0.0 ) then
            velthi(3,jz) = velthi(3,jz) - thige(jz) / zlte
            thige(jz) = 0.0
            do j2=1,4
              difthi(3,j2,jz) = 0.0
            enddo
          endif
c
          if ( zdzig(jz) .lt. 0.0 ) then
            velthi(4,jz) = velthi(4,jz) - zdzig(jz) / zlnz
            zdzig(jz) = 0.0
            do j2=1,4
              difthi(4,j2,jz) = 0.0
            enddo
          endif
c
        else
c
c  Note that the gradient scale lengths
c  zlti, zlnh, zlte, and zlnz must all be non-zero
c
        velthi(1,jz) = velthi(1,jz)
     &     + cthery(111) * thigi(jz) / zlti
        velthi(2,jz) = velthi(2,jz)
     &     + cthery(112) * zddig(jz) / zlnh
        velthi(3,jz) = velthi(3,jz)
     &     + cthery(113) * thige(jz) / zlte
        velthi(4,jz) = velthi(4,jz)
     &     + cthery(114) * zdzig(jz) / zlnz
c
c..alter the effective diffusivities
c  if they are used for more than diagnostic purposes
c
        if ( lthery(8) .gt. 20 ) then
          thigi(jz) = ( 1.0 - cthery(111) ) * thigi(jz)
          zddig(jz) = ( 1.0 - cthery(112) ) * zddig(jz)
          thige(jz) = ( 1.0 - cthery(113) ) * thige(jz)
          zdzig(jz) = ( 1.0 - cthery(114) ) * zdzig(jz)
        endif
c
        do j1=1,4
          ii = 110 + j1
          do j2=1,4
            difthi(j1,j2,jz) = ( 1.0 - cthery(ii) ) * difthi(j1,j2,jz)
          enddo
        enddo
c
        endif
c
c---:----1----:----2----:----3----:----4----:----5----:----6----:----7-c
c
      if ( ( lprint .gt. 0 .or. nstep .eq. lthery(26) )
     &  .or. ( zlastime .lt. cthery(88) .and. cthery(88) .le. time ) )
     &  then
c
      if ( jz .eq. jzmin ) then
c
        write (nprint,150) nstep, znormd, znormv, zkyrho, zmzmh
     &    , zcetai(10), zcetai(12), zcetai(15), zcetai(20)
     &    , zcetai(32), ieq
 150    format (/' Diagnostic output from sbrtn theory at nstep',i6
     &    ,/' znormd =',1pe11.3,/' znormv =',1pe11.3
     &    ,/' zkyrho =',1pe11.3
     &    ,/' zmzmh  =',1pe11.3
     &    ,/' zcetai(10) =',1pe11.3,2x,'parallel ion motion'
     &    ,/' zcetai(12) =',1pe11.3,2x,'par. ion motion (9 eqns)'
     &    ,/' zcetai(15) =',1pe11.3,2x,'collisions'
     &    ,/' zcetai(20) =',1pe11.3,2x,'finite beta'
     &    ,/' zcetai(32) =',1pe11.3
     &    ,/' ieq =',i5)
c
        write (nprint,154)
 154    format (
     &    /t4,'radius',t15,'zgne',t26,'zgnh',t37,'zgnz'
     &    ,t48,'zgte',t59,'zgth',t70,'zthte',t81,'zfnzne'
     &    ,t92,'zimpz',t103,'zfnsne',t114,'zftrap',t125,'#e')
c
        write (nprint,155)
 155    format (t4,'radius',t15,'zchieff'
     &    ,t59,'thigi',t70,'zddig',t81,'thige',t92,'zdzig'
     &    ,t125,'#c')
c
        write (nprint,156)
 156    format (
     &    t4,'radius',t15,'zq',t26,'zshat',t37,'znuhat'
     &    ,t48,'zbetae',t59,'zbetah',t70,'zbetaz',t81,'zkparl'
     &    ,t92,'zelong',t125,'#b')
c
      endif
c
        write (nprint,165) zrmin, zgne, zgnh, zgnz, zgte, zgth
     &    , zthte, zfnzne, zimpz, zfnsne, zftrap
 165    format (1p11e11.3,4x,'#e')
c
        write (nprint,166) zrmin, (zchieff(jm),jm=1,4)
     &    , thigi(jz), zddig(jz), thige(jz), zdzig(jz)
 166    format (1p9e11.3,4x,'#c')
c
        write (nprint,167) zrmin, zq, zshat
     &    , znuhat, zbetae, zbetah, zbetaz, zelong, zkparl
 167    format (1p9e11.3,4x,'#b')
c
      endif
c
!| 
!| %**********************************************************************c
!| 
!| xoAn early form  of the Hamaguchi-Horton theory\cite{hama89a}
!| of $\eta_i$ mode transport
!| is implemented when ${\tt lthery(7)} = 2$.  Here
!| $$ D_{\eta_i} = \frac{\rho_s^2 c_s}{L_n} (\eta_i - \eta_i^{th})
!|         \exp [ - \min ( c_{35} L_n , c_{36} L_{Ti} ) / L_s ]
!|    f_{ith} \exp^{-c_{34}(T_i/T_e - 1)^2} \kappa^{c_{12}}
!|    q^{c_{37}}                          \eqno{\tt zdetai} $$
!| $$ D^{IG} = fig(1) D_{\eta_i}  \eqno{\tt zddig(jz)} $$
!| $$ \chi_e^{IG} = F_e^{IG} D_{\eta_i}   \eqno{\tt thige} $$
!| $$ \chi_i^{IG} = F_i^{IG} D_{\eta_i}.  \eqno{\tt thigi} $$
!| The recommended values are $ c_{35} = 5.0 $ and $ c_{36} = 4.0 $.
!| (Note: at present, they are defaulted to 0.0).
!| 
      elseif ( lthery(7) .eq. 2 ) then
        zdetai = zfith * zftite * zelonf**cthery(12) * zq**cthery(37)
     &    * abs( zrhos**2 * zsound / zln ) * ( zetai - zetith )
     &    * exp ( - min (cthery(35) * abs(zln), cthery(36) * abs(zlti))
     &    / abs(zlsh) )
        zddig(jz) = fig(1) * zdetai
        zdzig(jz) = fig(1) * zdetai
        thige(jz) = fig(2) * zdetai
        thigi(jz) = fig(3) * zdetai
!| 
!| %**********************************************************************c
!| 
!| The Lee and Diamond 1986 theory\cite{lee86a} of transport due to
!| ion temperature gradient driven turbulence ($\eta_i$-mode) is used
!| when ${\tt lthery(7)} = 1$.
!| When $\eta_i > \eta_i^{th}$, the effective ion thermal diffusivity is
!| given by equation (92) in the Lee-Diamond paper
!| $$ \chi_i^{IG} = 0.4 F_i^{IG} f_{ith}
!|    \left[ \frac{\pi}{2} \ln ( 1+\eta_i) \right]^2
!|    \left[ \frac{1+\eta_i}{T_e/T_i} \right]^2 \frac{\rho_s^2 c_s}{L_s}
!|    \kappa^{c_{12}}.
!|    \eqno{\tt thigi} $$
!| The effective electron thermal diffusivity results from the
!| dissipative trapped electron response to $\eta_i$-mode turbulence
!| given by equation (96) in the Lee-Diamond paper
!| $$ \chi_e^{IG} = 3.394 F_e^{IG} f_{ith} \epsilon^{1.5}
!|    \left[ \frac{\pi}{2} \ln ( 1+\eta_i) \right]^4
!|    \left[ \frac{1+\eta_i}{T_e/T_i} \right]^3
!|    \frac{1}{[\nu_{ei},c_{33} \epsilon v_e / q R ]_{max}}
!|    \frac{c_s^2 \rho_s^2}{L_s^2} \kappa^{c_{12}}.   \eqno{\tt thige} $$
!| Note that there is a cutoff when the effective electron-ion
!| collisionality becomes larger than the electron transit frequency,
!| with adjustable coefficient $c_{33}$.
c
c..Lee-Diamond theory
c
      elseif ( lthery(7) .eq. 1 ) then
c
        zddig(jz) = 0.
        zdzig(jz) = 0.
c
        if ( zetai .gt. 0. ) then
c
          thigi(jz) = 0.4 * fig(3) * zfith * zftite *
     &      zq**cthery(37) *
     &      ( (zpi/2.) * log(1.+abs(zetai)) )**2
     &      * zelonf**cthery(12) *
     &      ( ( 1. + abs(zetai) ) / ( zte / zti ) )**2 *
     &      zrhos**2 * zsound / abs(zlsh)
c
          thige(jz) = 3.3942 * fig(2) * zfith * zep**1.5 * zftite *
     &      zq**cthery(37) *
     &      ( (zpi/2.) * log(1.+abs(zetai)) )**4
     &      * zelonf**cthery(12) *
     &      ( ( 1. + abs(zetai) ) / ( zte / zti ) )**3 *
     &      zrhos**2 * zsound**2 / ( zlsh**2 *
     &        max ( znuei, cthery(33) * zep*zvthe/(zq*zrmaj) ) )
c
        endif
c
      endif
c
!| 
!| The default models ({\tt lthery(5) = 0} for trapped electron modes
!| and {\tt lthery(7) = 0} for $\eta_i$ modes)
!| follow the Comments paper\cite{Comments}.
!| 
!| From the Comments paper\cite{Comments} (denoting its equations
!| as (C13) \ldots to distinguish them form
!| equation numbers in the present document), we then
!| compute (C13), (C12), (C11),
!| $\beta '/\beta_{c1}'$,
!| $(1+\beta '/\beta_{c1}')/[1+(\beta '/\beta_{c1}')^{3}]$, and
!| (C7).  We then use (C8)
!| to compute $Q_{e}^{DR}L_{Te}/(n_{e}T_{e})$
!| and (C10) to compute $Q_{i}^{DR}L_{Ti}/(n_{i}T_{i})$.  Algebraic
!| notation for these formulas is
!| $$  {\hat D}_{i}=\frac{\omega_{e}^{*}}{k_{\perp}^{2}}
!|   \left(\frac{2T_{i}}{T_{e}}
!|      \frac{L_{ni}}{L_{T_{i}}}\frac{L_{ni}}{R_{o}}\right)^{1/2}
!|      \kappa^{c_{12}} \eqno{\tt zdi} $$
!| $$  {\hat D}_{te}=\epsilon^{1/2}\frac{\omega_{e}^{*}}{k_{\perp}^{2}}
!|   \left[ c_{20}, c_{21}\frac{\omega_{e}^{*}}{\nu_{eff}}\right]_{min}
!|  \eqno{\tt zdte} $$
!| If $ {\tt lthery(6)} = 1 $, then use the form
!| for collisionless trapped electron modes suggested by Greg Rewoldt
!| \[
!|   {\hat D}_{te}=\epsilon^{1/2}\frac{\omega_{e}^{*}}{k_{\perp}^{2}}
!|   \left[ c_{20}, c_{21}\frac{0.1}{\nu_e^*}\right]_{min}
!| \]
!| Defining
!| $$ \beta ' = \beta /L_{p} \eqno{\tt zbprim} $$
!| $$ \beta_{c1}'=\hat{s}/(1.7 q^{2}R_{o}) \eqno{\tt zbc1} $$
!| $$ \beta_{1}=\beta '/\beta_{c1}' \eqno{\tt zbpbc1} $$
!| gives
!| $$  D^{DR} =
!|     \frac{1 + \beta_{1}}{1 + \beta_{1}^{3}}
!|     \left(1 - \frac{f_{ith}}{c_{23}+\nu_e^*}\right)
!|     \hat{D}_{te} \eqno{\tt zdd} $$
!| 
!| Quantities need to compute thermal diffusivities are approximated as
!| $$ D_{a}^{DR}=D^{DR}F_{a}^{DR} \kappa^{c_{12}} {\tt zdtite}
!|    \eqno{\tt zddtem} $$
!| $$  Q_{e}^{DR}\frac{L_{T_{e}}}{n_{e}T_{e}} = \frac{5}{2}
!|   \frac{1 + \beta_1}{1 + \beta_1^{3}}\hat{D}_{te}
!|   F_{e}^{DR} \kappa^{c_{12}} {\tt zdtite} \eqno{\tt thdre} $$
!| $$  Q_{i}^{DR}\frac{L_{T_{i}}}{n_{i}T_{i}}
!|   = \frac{5}{2} \hat{D}_{te}
!|   \frac{1 + \beta_{1}}{1 + \beta _{1}^{3}}
!|  F_{i}^{DR} \kappa^{c_{12}} {\tt zdtite} \eqno{\tt thdri} $$
!| The anomalous electron$\rightarrow$ion energy exchange
!| is also computed in subroutine {\tt theory} for transfer
!| to BALDUR subroutine {\tt trcoef}.
!| $$  \Delta^{DR} = (.89 - .54\eta_{i} -.6\beta '/\beta_{c1}')D^{DR}
!|   \frac{n_{e}T_{e}}{L_{ni}^{2}}F_{\Delta}^{DR} {\tt zdtite}
!|    \eqno{\tt weithe} $$
!| 
!| In this default model, the ``drift wave'' coefficients $F_{e}^{DR}$
!| and $F_{i}^{DR}$ are used to control
!| even the $\eta_i$ contributions to
!| the electron and ion thermal flux effective diffusivities
!| when {\tt lthery(7) = 0}:
!| $$  Q_{e}^{DR}\frac{L_{T_{e}}}{n_{e}T_{e}} =  c_{19} f_{ith}
!|   \frac{1 + \beta '/\beta_{c1}'}{1 + (\beta '/\beta_{c1}')^{3}}\hat{D}_{te}
!|   F_{e}^{DR}  \kappa^{c_{12}} {\tt zdtite} \eqno{\tt thige} $$
!| (The default for $c_{19} = - 3/2$.)
!| $$  Q_{i}^{DR}\frac{L_{T_{i}}}{n_{i}T_{i}}
!|   = \frac{5}{2}(f_{ith}\hat{D}_{i})
!|   \frac{1 + \beta_{1}}{1 + \beta _{1}^{3}}
!|    F_{i}^{DR} \kappa^{c_{12}} {\tt zdtite} \eqno{\tt thigi} $$
!| 
!| The relevant coding is:
!| 
c
c..original default theory
c
      if ( lthery(6) .lt. 2 .and.
     &  ( lthery(5) .eq. 0 .or. lthery(7) .eq. 0 ) ) then
c
        zdi=(zdiafr/zwn**2)*zln*sqrt(2*zti/(zte*zlti*zrmaj))
c
        if ( lthery(6) .eq. 1 ) then
          zdte=(sqrt(zep)*abs(zdiafr)/zwn**2)
     &      * min ( cthery(20),
     &                cthery(21) * 0.1 / max(thnust(jz),zepslon) )
        else
          zdte=(sqrt(zep)*abs(zdiafr)/zwn**2)
     &      * min ( cthery(20), cthery(21) * abs(zdiafr) / znueff )
        endif
c
        zbprim = abs(zbeta/zlpr)
        zbc1   = abs(zshat)/(1.7*zq**2*zrmaj)
        zbpbc1 = zbprim/zbc1
        zratio = (1.+zbpbc1)/(1.+zbpbc1**3)
        zdd    = zratio*(1.-zfith/(cthery(23)+thnust(jz)))*zdte
          zelfdr=zelonf**cthery(12)
        zddtem(jz) = zdd * fdr(1) * zelfdr * zdtite
c
c  trapped electron mode contributions
c
        if ( lthery(5) .eq. 0 ) then
          thdre(jz) = 2.5 * fdr(2) * zratio * zdte * zelfdr * zdtite
          thdri(jz) = 2.5 * fdr(3) * zratio * zdte * zelfdr * zdtite
        endif
c
c  eta_i mode contributions
c
        if ( lthery(7) .eq. 0 ) then
          thige(jz) = fdr(2) * cthery(19) * zfith * zratio
     &      * zdte * zelfdr * zftite
          thigi(jz) = 2.5 * fdr(3) * zfith * zratio
     &       * zdi * zelfdr * zftite
        endif
c
c..original expression for anomalous energy interchange
c
          weithe(jz) = fdrint * (0.89-0.54*abs(zetai)-0.6*zbpbc1)
     &      * zdd * zne * zte * zelfdr / zln**2
c
      endif
c
c  T.S. Hahm's formula for energy exchange.
c
      if ( lthery(6) .eq. 2 .or. lthery(6) .eq. 4 .or. lthery(6) .eq. 7
     &    .or. (lthery(6) .eq. 8 .and. thnust(jz) .le. 0.1) ) then
c
          weithe(jz) = abs((zte/zln)*abs(zdte*zne/zlne))*fdrint
c
      endif
c
!| 
!| %**********************************************************************c
!| 
!| \subsection{Trapped Ion Modes}
!| 
c
      zdti(jz) = 0.
c
!| 
!| %**********************************************************************c
!| 
!| \subsection{Rippling}
!| 
!| For rippling modes, we compute
!| $$  D_{\nabla \eta}=\left( \frac{E_{o}L_{s}}{B_{o}L_{\sigma}}\right) ^{4/3}
!|    \left( \frac{r^{2}L_{s}^{2}Z_{imp}^{2}\nu_{ii}}
!|    {25v_{i}^{2}}\right) ^{1/3} \eqno{\tt zdgret} $$
!| Before subtracting convective energy losses,
!| the diffusivities are approximated as
!| $$ D^{RM}_{a}=D_{\nabla \eta}F^{RM}_{a} \eqno{\tt zdrm(jz)} $$
!| $$  Q_{e}^{RM}\frac{L_{T_{e}}}{n_{e}T_{e}} = D_{\nabla \eta}F_{e}^{RM}
!|  \eqno{\tt thrme} $$
!| $$  Q_{i}^{RM}\frac{L_{T_{i}}}{n_{i}T_{i}} = D_{\nabla \eta}F_{i}^{RM}
!|  \eqno{\tt thrmi} $$
!| (Note that appropriate choices of input will zero the diffusivities
!| and make the numerical calculation of the resultant fluxes
!| purely convective.  However, there is no known numerical necessity
!| for doing this, and it will lead to the above-mentioned small
!| difficulties for plasmas with electrons due to impurities or
!| fast ions.)
!| 
!| If ${\tt lthery(11)} = 1$, the form for $\chi_e$ suggested by
!| Hahm et al\cite{hahm87a} [Eq(53)] is used
!| $$ \chi_e = (m_e/M_i)^{1/6} (L_T / L_n) D_{\nabla \eta}.
!|      \eqno{\tt thrme(jz)} $$
!| 
!| The relevant coding is:
!| 
c ......................
c . the rippling model .
c ......................
c
c
c  note that a typsetting error in the comments paper
c  for the resistivity scale height is corrected here
c
      zdgret=((zrmin*zlsh*cthery(5))**2*znuii/(25*zvthi**2))**(1./3.)
c
      zeloop=zvloop/(2*zpi*zrmaj)
c
      zdgret=zdgret*abs(zeloop*zlsh/(zb*zlsig))**(4./3.)
        zelfrm=zelonf**cthery(13)
      zdrm(jz) = zdgret*frm(1)*zelfrm
c
      if ( lthery(11) .eq. 1 ) then
        thrme(jz) = zdgret*frm(2)*zelfrm
     &    * abs ( (zcme/(zcmp*zai))**(1./6.) * abs(zlte/zln) )
      else
        thrme(jz)=zdgret*frm(2)*zelfrm
      endif
c
      thrmi(jz)=zdgret*frm(3)*zelfrm
c
!| 
!| %**********************************************************************c
!| 
!| \subsection{Resistive Ballooning}
!| 
!| \subsubsection{Analytic correction to resistive ballooning modes}
!| 
!| Apply a correction to the resistive ballooning mode diffusivities in an
!| effort to make the finite difference solution more closely match the
!| local analytic solution.
!| Consider the diffusion equation in a plane slab region
!| region with uniform flux and locally no sources.
!| Integrate once to get
!| \[ \chi \partial T / \partial x = - F_0. \]
!| Assuming the density profile is locally flatter than the temperature
!| profile, the thermal diffusivity may be approximated by
!| \[ \chi = \chi_0 |\partial T / \partial x | a \sqrt{T_0} / T^{3/2}. \]
!| Then, locally, the analytic solution between $x=a$ and $x=b$ is
!| \[ 16 \chi_0 a T_0 [ (T_a/T_0)^{1/4} - (T_b/T_0)^{1/4} ]^2
!|     = F_0 (b-a)^2. \]
!| In finite difference form, the solution is
!| \[ \chi_0 a \sqrt{T_0} \left( \frac{2}{T_a + T_b} \right)^{3/2}
!|    \left( \frac{T_a - T_b}{b-a} \right)^2 = F_0. \]
!| In order to make $T_a$, $T_b$, $a$, $b$, and $F_0$ the same
!| we need to multiply the finite difference diffusivity by
!| $$ {\tt zrbfac} = \frac{8 (T_a + T_b)^{3/2}}{\sqrt{2}}
!|   \left[ \frac{ T_a^{1/4} - T_b^{1/4} }{T_a - T_b} \right]^2.
!|   \eqno{\tt zrbfac} $$
!| This factor is controlled by {\tt cthery(45)} by setting
!| $$ {\tt zrbfac} = 1.0 + {\tt cthery(45)} * ( {\tt zrbfac} - 1.0 ). $$
!| By default $({\tt cthery(45)} = 0.0)$, there is no correction.
!| For the full normal correction, set ${\tt cthery(45)} = 1.0$.
c
      zte2  = 0.5 * ( tekev(jz) + tekev(jz+1) )
      zte2m = 0.5 * ( tekev(jz-1) + tekev(jz) )
c
      if ( abs( cthery(45) * (zte2m - zte2) ) .gt.
     &         abs( zepslon * (zte2m + zte2) ) ) then
        zrbfac = 1.0 + cthery(45) * ( -1.0 +
     &    ( (zte2m**0.25 - zte2**0.25)
     &    / (zte2m - zte2) )**2
     &    * (zte2m + zte2)**1.5 * 8.0 / sqrt(2.0) )
      else
        zrbfac = 1.0
      endif
c
!| 
!| For the original resistive ballooning mode model\cite{Comments}
!| $({\tt lthery(13)} = 0)$,
!| we compute (C20), (C21), (C19), and
!| then use (C18) to set up the thermal diffusivities.  In algebraic notation,
!| the required equations are:
!| $$  \chi_{e,res.ball}=\frac{3v_{e}\eta}{2\mu_{o}(2q)^{1/2}v_{A}}
!|          \left(\frac{\beta_{\theta}\epsilon^{2}L_{s}}{L_{p}}\right)^{3/2}
!|          \eqno{\tt zoldrb} $$
!| $$  \Lambda_{S} = \frac{4}{3\pi}\ln (\beta^{-1/2}R_{o}v_{A}\mu_{o}/\eta )
!|  \eqno{\tt thlamb} $$
!| $$  f_{*}=\left( \frac{\mu_{o}\omega_{ci}\rho_{i}^{3}}
!|   {\eta \beta q^{2}L_{ni}} \right) ^{2} \eqno{\tt zfstar} $$
!| $$  \chi^{RB} =
!|   (1 + c_{42} f_{*})^{-c_{43}}
!|   \Lambda_{S}^{2}\, \chi_{e,res.ball} \kappa^{c_{14}} \eqno{\tt zxrb} $$
!| where $c_{42} = 1.$ and $c_{43} = 1/4$.
!| 
!| To accomodate users who might want it, we
!| include an option for an associated particle
!| and ion energy diffusion coefficients
!| proportional to that for electron energy; but we note
!| that the present theory predicts much smaller values for the related fluxes.
!| Thus, we compute
!| $$ D_{a}^{RB}=\chi^{RB}F^{RB}_{a} \eqno{\tt zdrb(jz)} $$
!| $$ Q_{e}^{RB}\frac{L_{Te}}{n_{e}T_{e}}=\chi^{RB}F_{e}^{RB}
!|  \eqno{\tt thrbe} $$
!| $$ Q_{i}^{RB}\frac{L_{Ti}}{n_{i}T_{i}}=\chi^{RB}F_{i}^{RB}
!|  \eqno{\tt thrbi} $$
!| where $F^{RB}_{e}$ is identical to $F^{RB}$ of
!| the comments paper.
!| 
!| The relevant coding is:
!| 
c ..................................
c . the resistive ballooning model .
c ..................................
c
      zfstar=((zcmu0*zgyrfi*zlari**3)/(zresis*zbeta*zq**2*zln))**2
      zfdias = ( 1. + abs ( cthery(42) * zfstar ) )**( - cthery(43) )
c
      if ( lthery(13) .eq. 0 .or. lthery(13) .eq. 2 ) then
c
       zoldrb= (3.*zvthe*zresis)/(2.*zcmu0*sqrt(2*zq)*zvalfv)
      zoldrb = zoldrb*abs(zbetap*zep**2*zlsh/zlpr)**1.5
      zls    = 4.*log(zrmaj*zvalfv*zcmu0/(zresis*sqrt(zbeta)))/(3*zpi)
      thlamb(jz) = zls
      zxrb = zls**2 * zoldrb * abs(zfdias)
        zelfrb = zelonf**cthery(14)
      if ( lthery(13) .ne. 2 )
     &   zdrb(jz) = zxrb * frb(1) * zelfrb * zrbfac
      thrbe(jz) = zxrb * frb(2) * zelfrb * zrbfac
      thrbi(jz) = zxrb * frb(3) * zelfrb * zrbfac
c
      endif
!| 
!| The 1989 resistive ballooning mode model by Carreras and Diamond \cite{carr89a}
!| is selected by setting
!| $({\tt lthery(13)} \ne 0)$,
!| $$ D^{RB} = F_a^{RB}
!|   \frac{\beta R_0^2 q^2}{\sqrt{2} L_p R_c \hat{S}^{c_{49}} }
!|   \frac{r^2}{\tau_R} \Lambda^2 f_{dia} \kappa^{c_{14}}. \eqno{\tt zdrb} $$
!| The electron thermal diffusivity is a sum of the magnetic flutter and
!| $\bf E \times B$ contributions, respectively.
!| $$ \chi_e^{RB} = \left[ F_e^{RB}
!|   \frac{1}{2^{13/6} \langle n \rangle ^{2/3} S^{2/3} \hat{S} }
!|   \left( \beta \frac{R_0^2}{L_p R_c} q^2 \right)^{4/3}
!|   \frac{v_e r^2}{R_0}  \Lambda ^{4/3} \\
!|    + c_{44} \frac{\beta R_0^2 q^2}{\sqrt{2} L_p R_c \hat{S}^{c_{49}} }
!|             \frac{r^2}{\tau_R} \Lambda^2 \right] f_{dia}. \eqno{\tt thrbe} $$
!| For the moment, the ion thermal diffusivity will be taken to be
!| an adjustable fraction of the particle diffusivity
!| $$ \chi_i^{RB} = F_i^{RB}
!|   \frac{\beta R_0^2 q^2}{\sqrt{2} L_p R_c \hat{S}^{c_{49}} }
!|   \frac{r^2}{\tau_R} \Lambda^2 f_{dia} \kappa^{c_{14}}. \eqno{\tt thrbi} $$
!| Here, $c_{49}=1.0$,
!| and the diamagnetic stabilization term is approximated by
!| $$ f_{dia} = ( 1 + c_{42} f_\ast )^{-c_{43}}.  \eqno{\tt zfdias} $$
!| $$      f_{*}=\left(    \frac{\mu_{o}\omega_{ci}\rho_{i}^{3}}
!|         {\eta   \beta   q^{2}L_{ni}}    \right) ^{2}    $$
!| where $c_{42}=1.0$ and $c_{43}=1/6$. Also,
!| \begin{displaymath}
!| \langle n \rangle =
!| \mbox{rms value of the toroidal mode number}.
!| \end{displaymath}
!| Based upon Mirnov measurements on ISX-B, this should be in the range
!| $ \langle n \rangle \simeq 5 \rightarrow 10$. However, g-mode calculations
!| near low-q surfaces indicate that $ \langle n \rangle = 2 $ is more appropriate
!| \cite{rosscom}.
!| Until an appropriate theoretical formula is developed for $ \langle n
!| \rangle$, it will be adjustable by input data and bounded above 1 by the expression
!| \begin{displaymath}
!| {\tt znmode} = \max ( {\tt cthery(21)}, 2 ).
!| \end{displaymath}
!| The variable $S=\tau_R/\tau_{hp}$ is defined in the preamble.
!| $$ R_c = {\tt zrcurv} \equiv \mbox{radius of curvature}. \eqno{\tt zrcurv} $$
!| For now, $R_c = R_0$, the radius of curvature is taken to be the major radius. \\
!| If ${\tt lthery(14)} \ne 0$, then $\Lambda$ is solved making $n$ iterations
!| on the equation
!| $$
!| \Lambda = \frac{2}{3 \pi} \ln \left[ \frac{256 S^2 L_p}{\beta R_0
!|                  \Lambda^3 q^{c_{47}} }
!|                  \left( \frac{\hat{S}}{\langle n \rangle} \right)^4 \right].
!|                   \eqno{\tt zlambd} $$
!| When ${\tt lthery(14)} = 0$, then $\Lambda$ is approximated by a single
!| iteration formula given by
!|  $$
!|  \Lambda = \frac{2}{3 \pi} \ln \left[ \frac{S^2 L_p}{\beta R_0 q^{c_{47}} }
!|                    \left( \frac{\hat{S}}{\langle n \rangle} \right)^4+ c_{48} \right] $$
!| Here, $c_{47}=8.0$ and $c_{48}= \ln (256/ \Lambda^{3}) \approx 0.7$ for TFTR.
!| \small
c
c..Carreras-Diamond theory (PF B 1 (1989) 1011-1017
c
      if ( lthery(13) .eq. 1 .or. lthery(13) .eq. 2 ) then
c
        znmode = max ( cthery(41), 2.0 )
        zrcurv = zrmaj
c
        zlambd = max ( thlamb(jz), 1.0 )

c     Single iteration approximation for lambda if lthery(14) = 0

        if ( lthery(14) .eq. 0 ) then
          zlambd = (2./(3.*zpi)) *
     &      log (abs( (zshat/znmode)**4 * abs(zsrhp**2*zlpr)
     &        / abs(zbeta*zrmaj*zq**cthery(47))
     &        + cthery(48) ) )
        else
          do 81 jt=1,lthery(14)
            zlamb1 = zlambd
            zlambd = (2./(3.*zpi)) *
     &        log ( (zshat/znmode)**4 * abs(256. * zsrhp**2 * zlpr)
     &          / abs(zbeta*zrmaj*zq**cthery(47)*zlambd**3) )
          if ( abs(zlambd-zlamb1) .lt. 1.e-5 ) go to 82
 81     continue
         endif
c
 82     continue
          thlamb(jz) = zlambd
          zfstarrb(jz) = zfstar
          zfdiarb(jz) = zfdias
c
          zxrb   = ( zbeta * zrmaj**2 * zq**2 * zrmin**2 * zlambd**2 )
     &           * zelonf**cthery(14)
     &           / ( sqrt(2.) * zlpr * zrcurv * zshat ** cthery(49)
     &           * ztaur )
c
         zdrb(jz) = frb(1) * zxrb * zfdias * zrbfac
         thrbi(jz) = frb(3) * zxrb * zfdias * zrbfac
c
         thrbb(jz) = frb(2) * zvthe * zrmin**2 * zrbfac
     &  * zfdias * zelonf**cthery(14) *
     &  ( zbeta * zrmaj**2 * zq**2 * zlambd / (zlpr * zrcurv) )**(4./3.)
     &  / ( 2.**(13./6.) * ( znmode * zsrhp )**(2./3.) * zshat * zrmaj )
         thrbgb(jz) = cthery(44) * zxrb * zfdias * zrbfac
         thrbe(jz) = thrbb(jz) + thrbgb(jz)
c
      endif

!| 
!| 
!| For the hybrid resistive ballooning model combining the energy
!| transport from the old model and the energy transport from the
!| 1989 Carreras-Diamond model, lthery(13) = 2. This yields: \\
!| $$ D^{RB} = F_a^{RB}
!|  \frac{\beta R_0^2 q^2}{\sqrt{2} L_p R_c \hat{S} }
!|  \frac{r^2}{\tau_R} \Lambda^2 f_{dia} \kappa^{c_{14}}. \eqno{\tt zdrb} $$
!| $$ Q_{e}^{RB}\frac{L_{Te}}{n_{e}T_{e}}=\chi_{old}^{RB}F_{e}^{RB}
!|  \eqno{\tt thrbe} $$
!| $$ Q_{i}^{RB}\frac{L_{Ti}}{n_{i}T_{i}}=\chi_{old}^{RB}F_{i}^{RB}
!|  \eqno{\tt thrbi} $$
!| 
!| %**********************************************************************c
!| 
!| \subsubsection{Guzdar-Drake Drift-Resistive Ballooning Model}
!| 
!| The 1993 $\bf E \times B$ drift-resistive ballooning mode model by
!| Guzdar and Drake \cite{drake93} is selected by setting
!| ${\tt lthery(13)}= 3$,
!| $$
!|   D^{DB} = F_a^{DB}
!|   \left( 2\pi q_{a}^2 \right) \rho_e^2 \nu_{ei} \frac{R_o}{L_p}
!| $$
!| Here, $L_p$ has been substituted for $L_n$ given in their paper following
!| a comment made by Drake at the 1995 TTF Workshop\cite{drakecom2}.
!| Including diamagnetic and elongation effects, the particle diffusivity is
!| $$
!|   D^{DB} = \left( 2\pi q_{a}^2 \right) \rho_e^2 \nu_{ei}
!|   \frac{R_o}{L_p} \left( \frac{1}{1 + \alpha^2} \right) \kappa^{c_{14}}  \eqno{\tt zgddb}
!| $$
!| where $\rho_e=v_e/\omega_{ce}$ and
!| $\alpha$ is the ratio of the diamagnetic frequency to the
!| characteristic growth time,
!| $$
!|   \alpha = \frac{\rho_s c_s t_o}{L_p L_o} \eqno{\tt zgdalf}
!| $$
!| It can be calculated analytically by setting ${\tt cthery(85)}=1$ or
!| it can be numerically prescribed by setting ${\tt cthery(85)}=2$ and
!| ${\tt cthery(86)}$ to the desired value.
!| Results from their 3-dimensional fluid simulations show that this
!| parameter ranges from $\alpha = 0.3-0.6$ for L-mode discharges
!| to $\alpha = 0.7-2.0$ for H-mode discharges~\cite{guzcomm}.
!| Here, $L_o$ is the characteristic scale length,
!| $$
!|   L_o = 2\pi q_a \left( \frac{\nu_{ei}R \rho_s}{2 \Omega_e} \right)^{1/2}
!|         \left( \frac{R}{L_p} \right)^{1/4} \eqno{\tt zgdln}
!| $$
!| and $t_o$ is growth rate,
!| $$
!|   t_o = \left( \frac{R L_p}{2} \right)^{1/2} \frac{1}{c_s} \eqno{\tt zgdtime}
!| $$
!| This is the ideal growth rate, but applied to shorter wavelength turbulence.
!| 
!| The electron  and ion thermal diffusivities are taken equal taken to be
!| an adjustable fraction of the particle diffusivity.
!| $$
!|  \chi_e^{DB} = \left( 2\pi q_{a}^2 \right) \rho_e^2 \nu_{ei}
!|   \frac{R_o}{L_p} \left( \frac{1}{1 + \alpha^2} \right) \kappa^{c_{14}}
!|   \eqno{\tt thrbe}
!| $$
!| $$
!|  \chi_i^{DB} = \left( 2\pi q_{a}^2 \right) \rho_e^2 \nu_{ei}
!|   \frac{R_o}{L_p} \left( \frac{1}{1 + \alpha^2} \right) \kappa^{c_{14}}
!|   \eqno{\tt thrbi}
!| $$
!| 
c
c..Guzdar-Drake theory (Phys Fluids B 5 (1993) 3712
c..L_p used instead of L_n
c
      if ( lthery(13) .eq. 3 ) then
c
c..   Compute pressure scale length w/o fast ions
c
        zgdtot1 = zne * zte * (1 / zlte + 1 / zlne)
     &  + zlti + znh * (1 / zlnh + 1 / zlti)
        zgdtot(jz) = zgdtot1 + zlti * znz
     &  * (1 / zlnz + 1 / zlti)
        if ( zgdtot(jz) .gt. zepslon ) then
        zgdlp(jz) = (zne * zte + znh * zti
     &   + znz * zti) / zgdtot(jz)
        endif
c
        zgyrfe = zce * zb / zcme  ! electron plasma frequency
        zlare = zvthe / zgyrfe    ! electron Larmor radius
c
        zgdtime = sqrt ( zrmaj*zlpr/2. ) / zsound  ! ideal growth rate
        zgdrlp = (zrmaj/zlpr)**.25                 ! (R/L_p)^.25
        zgdlna = 2. * zpi * zq * zgdrlp
        zgdln = zgdlna*sqrt((znuei*zrmaj*zrhos)/(2.*zgyrfe)) ! char length
        zgdalf = (zrhos*zsound*zgdtime) / ( zlpr*zgdln ) ! alpha
c
c..   Diamagnetic stabilization
c
        if ( nint(cthery(85)) .eq. 1 ) then
          zgddia = 1 / ( 1 + zgdalf**2 )
        elseif ( nint(cthery(85)) .eq. 2 ) then
          zgddia = cthery(86)
        else
          zgddia = 1.0
        endif
c
c..   Diffusivities
c
        zgdp = 2. * zpi * ((zq * zlare)**2.) * znuei
     &  * ( zrmaj / zlpr ) * 100. * zgddia
        zdrb(jz) = frb(1) * zgdp * zelonf**cthery(14) * zdtite
c        thrbgb(jz) = frb(2) * zgdp * zelonf**cthery(14) * zdtite
        thrbe(jz) = frb(2) * zgdp * zelonf**cthery(14) * zdtite
        thrbi(jz) = frb(3) * zgdp * zelonf**cthery(14) * zdtite
        thrbgb(jz) = thrbe(jz)
      endif
!| 
!| Bruce Scott's 1998 Drift Alfven transport model is selected by setting
!| ${\tt lthery(13)}= 4$.
!| See documentation in file {\tt sda01flx.tex}.
!| 
      if ( lthery(13) .eq. 4 .or. lthery(13) .eq. 5 ) then
c
        iswitch = 8
c
        do jc=1,iswitch
          isdasw(jc) = 0
          zsdasw(jc) = 0.0
        enddo
c
        iprint = lthery(29) - 10
c
        idim   = matdim
c
c  normalized gradients
c
        zgne = zrmaj / zlne
        zgnh = zrmaj / zlnh
        zgnz = zrmaj / zlnz
        zgns = zgrdns
        zgte = zrmaj / zlte
        zgth = zrmaj / zlti
        zgtz = zrmaj / zlti
c
c  ratios of temperatures
c
        zthte  = zti / zte
        ztzte  = zti / zte
        zbetae = 2. * zcmu0 * zckb * zne * zte /   zb**2
c
c  Impurity species (use only impurity species 1 for now)
c  assume T_Z = T_H throughout the plasma here
c
        ztz    = zti
        znz    = densimp(jz)
        zmass  = amassimp(jz)
        zimpz  = avezimp(jz)
        zimpz  = max ( zimpz, cthery(120) )
c
        zfnzne = znz / zne
        zmzmh  = zmass / amasshyd(jz)
c
c  superthermal ions
c  zfnsne = ratio of superthermal ions to electrons
c  zchrgns = charge of fast ions (assumed = 1.0 here)
c
        zfnsne = max ( zfnsnea(jz), 0.0 )
        zchrgns = 1.0
c
        zsdasw(1) = cthery(87)
c
        if ( lthery(13) .eq. 4) then
c
          call sda01dif ( isdasw, zsdasw, iswitch, idim
     &   , iprint, nprint
     &   , zgne, zgnh, zgnz, zgte, zgth, zgtz, zthte, ztzte
     &   , zfnzne, zimpz, zmzmh, zfnsne, zchrgns
     &   , zbetae, znuhat, zq, zshat, zelong
     &   , zfldath, zfldanh, zfldate, zfldanz, zfldatz
     &   , zdfdath, zdfdanh, zdfdate, zdfdanz, zdfdatz
     &   , zdfthi, zvlthi
     &   , inerr )
c
        else
c
          call sda04dif ( isdasw, zsdasw, iswitch, idim
     &   , iprint, nprint
     &   , zgne, zgnh, zgnz, zgte, zgth, zgtz, zthte, ztzte
     &   , zfnzne, zimpz, zmzmh, zfnsne, zchrgns
     &   , zbetae, znuhat, zq, zshat, zelong
     &   , zfldath, zfldanh, zfldate, zfldanz, zfldatz
     &   , zdfdath, zdfdanh, zdfdate, zdfdanz, zdfdatz
     &   , zdfthi, zvlthi
     &   , inerr )
c
        endif
c
c..Set total effective diffusivities
c
        znormd    = zsound * zrhos**2 / zrmaj
        znormv    = zsound * zrhos    / zrmaj
c
        zdrb(jz)  = frb(1) * zdfdanh * znormd * zne / zni

        thrbe(jz) = frb(2) * zdfdate * znormd
        thrbi(jz) = frb(3) * zdfdath * znormd
     &    * zne * zte / ( zni * zti )
c
        thrbgb(jz) = thrbe(jz)
c
        if ( zdrb(jz)  .lt. 0.0 ) zdrb(jz)  = 0.0
        if ( thrbe(jz) .lt. 0.0 ) thrbe(jz) = 0.0
        if ( thrbi(jz) .lt. 0.0 ) thrbi(jz) = 0.0
c
c..diagnostic printout
c
      if ( lprint .gt. 0 .or. nstep .eq. lthery(26)
     &  .or. ( zlastime .lt. cthery(88) .and. cthery(88) .le. time ) )
     &  then
c
      if ( jz .eq. jzmin ) then
c
        write (nprint,180) time, nstep, znormd, znormv
 180    format (/' Diagnostic output from sbrtn theory '
     &    ,' for the drift Alfven wave after sda01dif'
     &    ,/' time   =',1pe13.5,/' nstep  =',i5
     &    ,/' znormd =',1pe13.5,/' znormv =',1pe13.5)
c
        write (nprint,181) ( isdasw(jc),jc=1,iswitch )
 181    format (/' isdasw(jc) =',/(5i5))
c
        write (nprint,182) ( zsdasw(jc),jc=1,iswitch )
 182    format (/' zsdasw(jc) =',/(1p5e13.5))
c
        write (nprint,183)
 183    format (
     &    /t4,'radius',t17,'zgne',t30,'zgnh',t43,'zgnz'
     &    ,t56,'zgte',t69,'zgth',t82,'zthte',t95,'zfnzne'
     &    ,t108,'zimpz',t125,'#da1')
c
        write (nprint,184)
 184    format (
     &    /t4,'radius',t17,'zfnsne',t30,'zchrgns',t43,'zbetae'
     &    ,t56,'znuhat',t69,'zq',t82,'zshat',t95,'zelong'
     &    ,t108,' ',t125,'#da2')
c
        write (nprint,185)
 185    format (
     &    /t4,'radius',t17,'chi_i',t30,'d_h',t43,'chi_e'
     &    ,t56,'zdfdath',t69,'zdfdanh',t82,'zdfdate',t95,'zdfdanz'
     &    ,t108,'zdfdatz',t125,'#da3')
c
        write (nprint,186)
 186    format (
     &    /t4,'radius',t17,'zfldath',t30,'zfldanh',t43,'zfldate'
     &    ,t56,'zfldanz',t69,'zfldatz',t82,'normalized fluxes'
     &    ,t125,'#da4')
c
      endif
c
        write (nprint,187) zrmin, zgne, zgnh, zgnz, zgte, zgth
     &    , zthte, zfnzne, zimpz
 187    format (1p9e13.5,t125,'#da1')
c
        write (nprint,188) zrmin, zfnsne, zchrgns
     &    , zbetae, znuhat, zq, zshat, zelong
 188    format (1p8e13.5,t125,'#da2')
c
        write (nprint,189) zrmin
     &    , thrbi(jz), zdrb(jz), thrbe(jz)
     &    , zdfdath, zdfdanh, zdfdate, zdfdanz, zdfdatz
 189    format (1p9e13.5,4x,'#da3')
c
        write (nprint,190) zrmin
     &    , zfldath, zfldanh, zfldate, zfldanz, zfldatz
 190    format (1p6e13.5,4x,'#da4')
c
      endif
c
      endif
!| %**********************************************************************c
!| 
!| \subsection{Neoclassical MHD Model}
!| 
!| The effective diffusivity driven by neoclassical MHD consists of an
!| $E \times B$ part, taken from page 300
!| of Kwon, Diamond and Biglari\cite{Kwon}
!| $$ D_p =  \frac{\eta}{2 \mu_0} \frac{q \beta R}{r}
!|           \frac{L_s}{L_p} \delta_e \Lambda_N^2  \eqno{\tt zexbnm} $$
!| and an effective electron diffusivity due to stochastic magnetic fields
!| as given by Eq. (32) of Kwon, Diamond and Biglari\cite{Kwon}
!| with corrections by Callen\cite{Callen}
!| $$
!|  \chi_{e0}=.046 (4 \pi)^{2/3} \frac{v_{e} L_s}{(n S)^{2/3}}
!|  \left( \frac{q \beta R}{L_{p}} \right) ^{4/3}
!|  \delta_{e}^{5/3}
!|  \Lambda_{N}^{7/3} f_{\Lambda} f_{\gamma}  \eqno{\tt zxnm}
!| $$
!| where
!| $$
!|  \delta_{e}^{-1}=1+\frac{\alpha_{e}(1+1.07
!|  \nu_{*e}^{1/2}+1.02\nu_{*e})
!|  (1+1.07\epsilon^{3/2}\nu_{*e})}{2.31\epsilon^{1/2}}  \eqno{\tt zdelm1}
!| $$
!| $$ \delta_e = 1. / \delta_e^{-1}   \eqno{\tt zdele} $$
!| $$
!|  \alpha_{e}=(1+1.198Z_{eff}+0.222Z_{eff}^{2})/
!|  (1+2.966Z_{eff}+0.753Z_{eff}^{2})   \eqno{\tt zalphe}
!| $$
!| $$
!|  \Lambda_{N} = \sqrt{3 \delta_{e}^{-1} - 1
!|  + 2 \sqrt{\delta_e^{-1} (2\delta_{e}^{-1}-1)}}. \eqno{\tt zlambn}
!| $$
!| Note, $\delta_e$ is always $ \leq 1.0 $
!| and $ \Lambda_{N} $ is always $ \geq 2.0 $.
!| 
!| In the original presentation of the theory\cite{Kwon},
!| which is accessed by setting ${\tt lthery(15)} = 1$,
!| $$ f_{\Lambda} = 1  \eqno{\tt zflamb} $$
!| $$ f_{\gamma}  = 1. \eqno{\tt zfgam}  $$
!| In more recent presentations\cite{Callen,IAEA1986},
!| accessed by setting ${\tt lthery(15)} \geq 2$,
!| $$
!|  f_{\Lambda}=(1-\Lambda_{N}^{-1})/
!|  \sqrt{1-\sqrt{2}/(\Lambda_{N}+\Lambda_{N}^{3})}   \eqno{\tt zflamb}
!| $$
!| and
!| $$
!|  f_{\gamma}=\left( \frac{\mu_{i}}{\mu_{i}+\gamma_0}
!|  + (1+2q^2) \frac{\epsilon^{2}}{q^{2}}\right) ^{1/2}   \eqno{\tt zfgam}
!| $$
!| where
!| $$
!|  \mu_{i}=0.66\frac{\epsilon^{1/2}\nu_{i}}
!|  {(1+1.03\nu_{*i}^{1/2}+0.31\nu_{*i})
!|  (1+0.66\nu_{*i}\epsilon^{3/2})}   \eqno{\tt zcmi}
!| $$
!| $$
!|  \nu_{i}=(n_{i}/n_{e}) \sqrt{A_{i}/2} [1+\sqrt{2}(Z_{eff}-1)]\nu_{ii}.
!|    \eqno{\tt znui}
!| $$
!| Here, $\nu_{ii}$ is the ion-ion collision frequency among only the hydrogenic
!| species,  $\nu_i$ is the ion-ion collision frequency including impurities,
!| and $ \nu_{*i} = \nu_i R q / ( \epsilon^{3/2} v_{Ti} ) $ is the ion-ion
!| collision frequency divided by the ion bounce frequency.
!| 
!| The growth rate of the mode is given by
!| $$
!|  \gamma_0 = c_{70}\left( \frac{\delta_{e}}{4S}\right) ^{1/3}
!|  \left( \frac{n q \beta R}{L_{p}} \right) ^{2/3}
!|  \frac{v_{A}}{R}   \eqno{\tt zgammh}
!| $$
!| 
!| Each contribution is multiplied by a correction due to diamagnetic effects
!| derived by Diamond et al \cite{diam85a}
!| $$  f_{dia} = ( 1 + c_{75} \omega_*^2/\gamma^2 )^{-c_{76}}  $$
!| where
!| $$  \omega_* = - n q \rho_s c_s / ( r L_{n_e} )  \eqno{\tt zwstrp} $$
!| and
!| $$ \gamma ( \gamma^2 + \omega_*^2 ) = \gamma_0^3  $$
!| for $ T_e = T_i $.
!| Here, an approximate form for the diamagnetic stabilization is used:
!| $$ f_{dia} = ( 1 + c_{75} \omega_*^6 / \gamma_0^6 )^{-c_{76}}
!|               \eqno{\tt zfdia3} $$
!| which matches $f_{dia}$ for $\omega_* \gg \gamma_0 $
!| and reduces to $f_{dia} \simeq 1$ for $ \omega_* \ll \gamma_0$.
!| 
!| Note, in all of the above, the average toroidal mode number is taken to be
!| $$ n = max[1,{\tt cthery(77)}]  \eqno{\tt zntor} $$,
!| where $ n = 1 $ gives the largest thermal diffusivity and the smallest
!| diamagnetic stabilization.
!| 
!| Each contribution is multiplied by an enhancement for elongated plasmas
!| $$  {\tt zelonf}^{\tt cthery(71)}  \eqno{\tt zelfnm}.  $$
!| Finally, {\tt zrbfac} is the correction to the finite difference
!| expressions which is defined at the beginning of the resistive
!| ballooning section.
!| 
!| The coding is:
c ...........................
c  Neoclassical mhd theory  .
c............................
c
      if ( lthery(15) .eq. 1 ) then
       zntor  = max( 1.0, cthery(77) )
       zalphe = ( 1.0 + 1.198*zeff + 0.222*zeff**2 )
     &        / ( 1.0 + 2.966*zeff + 0.753*zeff**2 )
       zdelm1 = 1.0 + zalphe *
     &  ( 1.0 + 1.07*sqrt(abs(thnust(jz))) + 1.02*thnust(jz) )
     &  / ( 2.31*sqrt(abs(zep)) )
       zdele  = 1. / zdelm1
       zlambn = sqrt( abs( 3.0*zdelm1 - 1.0
     &  + 2.0*sqrt(abs( zdelm1 * (2.*zdelm1 - 1.) ) ) ) )
       zflamb = ( 1.0 - 1.0/zlambn )
     &  / sqrt(abs(( 1.0 - sqrt(2.0)/( zlambn * ( 1.0 + zlambn**2 )))))
       znui = ( zni/zne ) * sqrt(zai/2.0)
     &  * ( 1.0 + sqrt(2.0) * (zeff-1.) ) * znuii
       zcmi = 0.66 * sqrt(abs(zep)) * znui
     &  / ( (1.0 + 1.03 * sqrt(abs(znusti)) + 0.31 * znusti)
     &    * (1.0 + 0.66 * znusti * abs(zep)**(1.5)) )
       zgammh = cthery(70)
     &  *( abs(zdele/(4.0*zsrhp))
     &    * (zntor*zq*zbeta*zrmaj/zlpr)**2)**(1./3.)
     &  * zvalfv / zrmaj
       zfgam = sqrt(abs( zcmi/(zcmi+zgammh) + (zep/zq)**2 ))
       zxnm  = 0.2486 * zvthe * abs(zlsh)
     &  * abs( zq * zbeta * zrmaj / zlpr )**(4./3.)
     &  * abs(zdele)**(5./3.) * abs(zlambn)**(7./3.)
     &  / ( abs( zntor * zsrhp )**(2./3.) )
c
       zexbnm = 0.5 * zresis * zq * zrmaj * zbeta * abs(zlsh)
     &    * zdele* zlambn**2 / abs( zcmu0 * zrmin * zlpr )
c
      elseif ( lthery(15) .gt. 1 ) then
       zntor  = max( 1.0, cthery(77) )
       zalphe = ( 1.0 + 1.198*zeff + 0.222*zeff**2 )
     &        / ( 1.0 + 2.966*zeff + 0.753*zeff**2 )
       zdelm1 = 1.0 + zalphe *
     &  ( 1.0 + 1.07*sqrt(abs(thnust(jz))) + 1.02*thnust(jz) )
     &  * ( 1.0 + 1.07*abs(zep)**(1.5)*thnust(jz) )
     &  / ( 2.31 * sqrt(abs(zep)) )
       zdele  = 1. / zdelm1
       zlambn = sqrt( abs( 3.0*zdelm1 - 1.0
     &  + 2.0*sqrt(abs( zdelm1 * (2.*zdelm1 - 1.) ) ) ) )
       zflamb = ( 1.0 - 1.0/zlambn )
     &  / sqrt(abs(( 1.0 - sqrt(2.0)/( zlambn * ( 1.0 + zlambn**2 )))))
       znui = ( zni/zne ) * sqrt(zai/2.0)
     &  * ( 1.0 + sqrt(2.0) * (zeff-1.) ) * znuii
       zcmi = 0.66 * sqrt(abs(zep)) * znui
     &  / ( (1.0 + 1.03 * sqrt(abs(znusti)) + 0.31 * znusti)
     &    * (1.0 + 0.66 * znusti * abs(zep)**(1.5)) )
       zgammh = cthery(70)
     &  *( abs(zdele/(4.0*zsrhp))
     &    * (zntor*zq*zbeta*zrmaj/zlpr)**2)**(1./3.)
     &  * zvalfv / zrmaj
       zfgam = sqrt(abs( zcmi/(zcmi+zgammh)
     &  + (1.0 + 2.0 * zq**2 ) * (zep/zq)**2 ))
       zxnm  = 0.2486 * zvthe * abs(zlsh)
     &  * abs( zq * zbeta * zrmaj / zlpr )**(4./3.)
     &  * abs(zdele)**(5./3.) * abs(zlambn)**(7./3.)
     &  * zflamb * zfgam / ( abs( zntor * zsrhp )**(2./3.) )
c
       zexbnm = 0.5 * zresis * zq * zrmaj * zbeta * abs(zlsh)
     &    * zdele* zlambn**2 / abs( zcmu0 * zrmin * zlpr )
      endif
c
      if ( lthery(15) .gt. 0 ) then
c
       zelfnm = zelonf**cthery(71)
c
       zwstrp = - zntor * zq * zrhos * zsound / ( zrmin * abs(zlne) )
       zfdia3 = 1.0
       if ( min( cthery(75), cthery(76), zgammh ) .gt. zepslon )
     &   zfdia3 = ( 1. + cthery(75)*(zwstrp/zgammh)**6 )**(-cthery(76))
c
       zalphz(jz) = zalphe
       zdelez(jz) = zdele
       zlambz(jz) = zlambn
c
       zflamz(jz) = zflamb
       znuiz(jz)  = znui
       zcmiz(jz)  = zcmi
       zgammz(jz) = zgammh
       zfgamz(jz) = zfgam
       zxnmz(jz)  = zxnm
       zexbnz(jz) = zexbnm
       zfdiaz(jz) = zfdia3
       zwstrnm(jz) = zwstrp
c
       zdnm(jz)  = ( fmh(1) * zexbnm + cthery(72) * zxnm )
     &             * zelfnm * zfdia3 * zrbfac
       thnme(jz) = ( fmh(2) * zxnm + cthery(73) * zexbnm )
     &             * zelfnm * zfdia3 * zrbfac
       thnmi(jz) = ( fmh(3) * zexbnm + cthery(74) * zxnm )
     &             * zelfnm * zfdia3 * zrbfac
      endif
c
!| 
!| %**********************************************************************c
!| 
!| \subsection{Cirulating Electron and High-$m$ Tearing Modes}
!| 
!| Fluxes due to circulating electrons
!| and/or the high-$m$ tearing mode can sensibly
!| be added to those defined above.  To do this, let
!| $$
!|  \Gamma_{a}^{CE}=F^{CE}_{a}D^{CE}\kappa^{c_{83}}
!|  \frac{\partial n_{a}}{\partial r}
!| \eqno{\tt zxce} $$
!| $$
!|  Q_{e}^{CE}=F^{CE}_{e}D^{CE}\kappa^{c_{83}}
!|  n_{e}\frac{\partial T_{e}}{\partial r}
!| \eqno{\tt thcee} $$
!| $$
!|  Q_{i}^{CE}=F^{CE}_{i}D^{CE}\kappa^{c_{83}}
!|  n_{i}\frac{\partial T_{i}}{\partial r}
!| \eqno{\tt thcei} $$
!| \begin{equation}
!|  D^{CE}=(\nu_{ei}\omega_{e}^{*}/\omega_{te}^{2})
!|  (1+a_{19}f_{ith}\eta_{e}\epsilon_{n})Df_{\tau}
!| \end{equation}
!| where $\omega_{te}={\hat s}v_{e}/(qR)$.
!| For electron energy
!| fluxes due to high-$m$ tearing modes, let
!| $$
!|  Q_{e}^{HM}=c_{82}(\nu_{ei}\omega_{e}^{*}/\omega_{te}^{2})
!|  \eta_{e}^{2}Df_{\tau}
!|  \kappa^{c_{83}}\frac{\partial n_{a}}{\partial r}
!| \eqno{\tt thhme} $$
!| 
!| The coding is:
!| 
c ...................................................
c . the circulating electron & high-m tearing model .
c ...................................................
c
      if ( lthery(16) .eq. 1 ) then
       zepn=zlne/zrmaj
       zfte=(zshat*zvthe)/(zq*zrmaj)
       zdperp=zdiafr/zwn**2
       zdfte=znuei*zdiafr/zfte**2
       zcest=zfith*zetae*zepn
       zhmst=(zetae**2)*zdperp*zdtite
       zelfce=zelonf**cthery(81)
       zxce=zdfte*(1.+cthery(80)*zcest)*zdperp*zdtite
       zdce      = fec(1) * zxce * zelfce
       thcee(jz) = fec(2) * zxce * zelfce
       thcei(jz) = fec(3) * zxce * zelfce
       thhme(jz) = cthery(82)*zdfte*zhmst*zelonf**cthery(83)
      endif
c
!| 
!| %**********************************************************************c
!| 
!| \subsection{Kinetic Ballooning}
!| 
!| For transport due to the kinetic ballooning mode, we compute $D^{KB}$ and
!| the thermal diffusivities.  The ideal and
!| second stability thresholds are given, respectively, as
!| $$  \beta_{c1}' = c_{78} \hat{s}/(1.7 q^{2}R_{o}) \eqno{\tt zbc1} $$ \\[-5mm]
!| $$  \beta_{c2}' = c_{79} 4 \hat{s}/(q^{2}R_{o}) \eqno{\tt zbc2} $$ \\[-2mm]
!| Here, $cthery(78,79)=1$ by default, but are included for flexibility.
!| For the original Singer-Tang-Rewoldt~\cite{Comments,Tang86,RewTang}
!| kinetic ballooning mode model, chosen by setting lthery(17) = 0, we have
!| $$  f_{\beta th} = \left[ 1 +
!|   \exp \left[ -\frac{L_{p}}{c_{8}\rho_{\theta i}}(\beta ' -
!|   \beta_{c1}') \right] \right]^{-1} \eqno{\tt zfbth} $$
!| and
!| $$  D^{KB} = \omega_{e}^{*}\rho_{i}^{2}f_{\beta th}
!|   \left(1 + \frac{\beta '}{\beta_{c1}'}\right)
!|   \left[1 - \frac{\beta '}{\beta_{c2}'} , 0\right]_{\max} \eqno{\tt zdk} $$ \\
!| The diffusivities are then given as:
!| $$ D_{a}^{KB}=D^{KB}F^{KB}_{a} F_{\kappa} \eqno{\tt zdkb(jz)} $$
!| $$ Q_{e}^{KB}\frac{L_{Te}}{n_{e}T_{e}}=2.5D^{KB}F^{KB}_{e} F_{\kappa} \eqno{\tt thkbe} $$
!| $$ Q_{i}^{KB}\frac{L_{Ti}}{n_{i}T_{i}}=2.5D^{KB}F^{KB}_{i} F_{\kappa} \eqno{\tt thkbi} $$\\
!| 
!| \noindent
!| For the 1995 revised version~\cite{gbcomm} (lthery(17) = 1),
!| $$  f_{\beta th} = \exp \left[c_{8}\left( \frac{\beta '}{\beta_{c1}'} -1 \right) \right]
!| \eqno{\tt zfbth2} $$
!| along with
!| $$  D^{KB} = \frac{c_s \rho_s^2}{L_p} f_{\beta th} \eqno{\tt zdk} $$\\
!| The diffusivities are then given as:
!| $$ D_{a}^{KB}=D^{KB}F^{KB}_{a} F_{\kappa} \eqno{\tt zdkb(jz)} $$
!| $$ Q_{e}^{KB}\frac{L_{Te}}{n_{e}T_{e}}=D^{KB}F^{KB}_{e} F_{\kappa} \eqno{\tt thkbe} $$
!| $$ Q_{i}^{KB}\frac{L_{Ti}}{n_{i}T_{i}}=D^{KB}F^{KB}_{i} F_{\kappa} \eqno{\tt thkbi} $$
!| Note that the new version does not include the (5/2) factor in the thermal
!| diffusivities.
!| 
!| \noindent
!| The relevant coding is:
!| 
c ..................................
c .  the kinetic ballooning model  .
c ..................................
c
c       zbprim, zbc1, and zbpbc1 computed above under drift model
c
      if ( lthery(17) .gt. -1  .and.  abs(cthery(8)) .gt. zepslon
     &   .and.  zlpr .gt. 0.0  ) then
c
      zbprim = abs(zbeta/zlpr)
      zbcoef1 = 1.0
      zbcoef2 = 1.0
      if ( abs(cthery(78)) .gt. zepslon ) zbcoef1 = cthery(78)
      if ( abs(cthery(79)) .gt. zepslon ) zbcoef2 = cthery(79)
      zbc1   = zbcoef1 * abs(zshat)/(1.7*zq**2*zrmaj)
      zbpbc1 = zbprim/zbc1
      zbc2   = zbcoef2 * 4.* abs(zshat)/(zq**2*zrmaj)
      zelfkb = zelonf**cthery(15)
c
      if ( lthery(17) .eq. 1) then
        zfbthn = exp( min(abs(zlgeps),
     &     max(-abs(zlgeps),cthery(8)*(zbprim/zbc1 - 1.))) )
c
        zdk = abs( zsound * zrhos**2 * zfbthn / zlpr )
        zdkb(jz)  = zdk*fkb(1)*zelfkb
        thkbe(jz) = zdk*fkb(2)*zelfkb
        thkbi(jz) = zdk*fkb(3)*zelfkb
      else
        zexkb  = - zlpr*(zbprim-zbc1)/(cthery(8)*zlarpo)
        zovfkb = max(zexkb,-abs(zlgeps))
        zovfkb = min(zovfkb,abs(zlgeps))
        zfbth  = 1.0/(1.0+exp(zovfkb))
        zdk1   = max(1.-zbprim/zbc2,0.0)*(1.+zbpbc1)
        zdk = abs(zdk1*zdiafr*zlari**2.*zfbth)
        zdkb(jz)  = zdk*fkb(1)*zelfkb
        thkbe(jz) = 2.5*zdk*fkb(2)*zelfkb
        thkbi(jz) = 2.5*zdk*fkb(3)*zelfkb
      endif
c
c..arrays for diagnostic printout
c
        zbprima(jz) = zbprim
        zbc1a(jz)   = zbc1
        thbpbc(jz)  = zbpbc1
        zbc2a(jz)   = zbc2
        zdka(jz)    = zdk
c
      endif
c
!| 
!| %**********************************************************************c
!| 
!| \subsection{$\eta_{e}$ Mode}
!| 
!| For the $\eta_{e}$ mode, we compute
!| $$ f_{eth}=\{ 1+\exp [-c_{9}(\eta_{e}-1)]\} ^{-1} \eqno{\tt zfeth} $$
!| $$ \chi_{e,Md}=0.1\left( \frac{c}{\omega_{pe}}\right) ^{2}
!|  \frac{v_{e}}{qR_{0}}(1+\eta_{e})\eta_{e}{\hat s} \eqno{\tt zxemd} $$
!| with the modified limit \cite{Guzdar}
!| $$ f_{lim}=\eta_{e}(1+\eta_{e})/[1+.015(T_{e}/T_{i})\eta_{e}(1+\eta_{e})]
!|  \eqno{\tt zflim} $$
!| $$ \chi^{HF}=f_{lim}f_{eth}\frac{1}{1+\nu_{eff}/\omega_{e}^{*}}\chi_{e,Md}
!|  \eqno{\tt zxhf} $$
!| As above, we give the user the option of adding similar
!| scalings for particle and ion energy diffusion coefficients
!| in the form
!| $$ D_{a}^{HF}=\chi^{HF}F^{HF}_{a} \eqno{\tt zdhf(jz)} $$
!| in addition to (C27) (with the new symbol $F^{HF}_{e}$ equivalent
!| to $F^{HF}$ in the Comments paper),
!| $$ Q^{HF}_{e}L_{Te}/(n_{e}T_{e})=\chi^{HF}F^{HF}_{e} \eqno{\tt thhfe} $$
!| As above, we also allow an ion energy tranport option of the form
!| $$ Q^{HF}_{i}L_{Ti}/(n_{i}T_{i})=\chi^{HF}F^{HF}_{i} \eqno{\tt thhfi} $$
!| The relevant coding is:
!| 
c ..........................
c .  the eta-e mode model  .
c ..........................
c
      if ( lthery(20) .lt. 0 ) then
        zdhf(jz)  = 0.0
        thhfe(jz) = 0.0
        thhfi(jz) = 0.0
      else
        zexhf   = -cthery(9)*(zetae-1.0)
         zovfhf = max(zexhf,zlgeps)
        zovfhf  = min(zovfhf,-zlgeps)
        zfeth   = 1./(1.+exp( min(15.0, max(-15.0, -6.*(zetae-1.))) ))
        z1      = zetae*(1.+abs(zetae))
        zxemd   = 0.1*(zcc/zfpe)**2*(zvthe/(zq*zrmaj))*z1*zshat
        zflim   = z1/(1.+0.015*(zte/zti)*z1)
        zxhf    = zflim*zfeth*zxemd/(1.+abs(znueff/zdiafr))
          zelfhf= zelonf**cthery(16)
        zdhf(jz)  = zxhf*fhf(1)*zelfhf
        thhfe(jz) = zxhf*fhf(2)*zelfhf
        thhfi(jz) = zxhf*fhf(3)*zelfhf
      endif
!| 
!| %**********************************************************************c
!| 
!| \subsection{Rebut-Lallia-Watkins Model}
!| 
!| The Rebut-Lallia-Watkins transport model\cite{RLW88a,rebu91a}
!| is turned on with the default coefficients by setting
!| ${\tt lthery(25)} = 1$ together with
!| ${\tt cthery(24)} = 1.0$ for particle diffusivity,
!| ${\tt cthery(25)} = 1.0$ for electron thermal diffusivity, and
!| ${\tt cthery(26)} = 1.0$ for ion thermal diffusivity.
!| Note that convective transport should also be turned on when using this
!| model by setting ${\tt cthery(68)} = 1.5$ and ${\tt cthery(69)} = 1.5$.
!| 
!| For
!| \[ |\nabla T_{ec}| / |\nabla T_e| < 1.0 \;\;
!|    {\rm and} \;\; \nabla q > 0.0 \]
!| the expressions for the thermal and particle diffusivities are:
!| $$ \chi_e^{RLW} = C_{25} \chi_e^{an} ( 1.-\nabla T_{ec} / \nabla T_e )
!|     \eqno{\tt thrlwe(jz)} $$
!| $$ \chi_i^{RLW} = C_{26} \chi_i^{an} ( 1.-\nabla T_{ec} / \nabla T_e )
!|     \eqno{\tt thrlwi(jz)} $$
!| and
!| $$ D^{RLW} = C_{24} 0.7 \chi_i^{RLW}. \eqno{\tt zdrlw} $$
!| The anomalous electron thermal diffusivity is given by
!| $$ \begin{array}{rcl}
!|   \chi_e^{an} &  = &  0.5 c^2 \sqrt{\mu_0 m_i}
!|   \left| \frac{\nabla T_e}{T_e} + \frac{2\nabla n_e}{n_e} \right|
!|   \left( \frac{T_e}{T_i} \right)^{1/2}
!|   \left( \frac{q^2}{\nabla q B \sqrt{R}} \right) \\
!|   ( 1 - \sqrt{r/R} ) \sqrt{ 1 + Z_{eff} }
!|                & = & 0.5
!|   \left[ \frac{1}{L_{T_e}} + \frac{2}{L_{n_e}} \right]
!|   \left( \frac{T_e}{T_i} \right)^{1/2}
!|   \frac{q}{\hat{s}} \frac{c^2}{v_A} \frac{r}{\sqrt{Rn_e}}
!|   ( 1 - \sqrt{r/R} ) \sqrt{ 1 + Z_{eff} }.
!|   \end{array} \eqno{\tt zchian} $$
!| The critical electron temperature gradient is given by
!| $$ \begin{array}{rcl}  \frac{\nabla T_{ec}}{\nabla T_e} & = &
!|   \frac{0.06}{q \nabla T_e}
!|   \left[ \frac{\eta J B^3 e^2}{n T_e^{1/2} \mu_o m_e^{1/2}}
!|      \right]^{1/2} \\
!|   & = & \frac{0.12 L_{T_e}}{q \rho_e}
!|   \left[ \sqrt{2} \frac{\eta J}{B v_e}
!|     \frac{1+\frac{n_i T_i}{n_e T_e}}{\beta}
!|   \right]^{1/2}
!|   \end{array} \eqno{\tt ztcrit} $$
!| where
!| $$ \rho_e = v_e / \omega_{ce} \eqno{\tt zrhoe} $$
!| Then the anomalous ion thermal diffusivity is given by
!| $$ \chi_i^{an} =  \chi_e^{an} (T_e / T_i )^{1/2}
!|   2.0 Z_i / \sqrt{1 + Z_{eff}} $$
!| Each contribution is multiplied by an enhancement for elongated plasmas
!| $$  {\tt zelonf}^{\tt cthery(27)}  \eqno{\tt zelrlw}  $$
!| The relevant coding is:
!| 
c
      thrlwe(jz) = 0.0
      thrlwi(jz) = 0.0
      zdrlw      = 0.0
c
      if ( lthery(25) .eq. 1 ) then
       zrhoe  = zvthe * zcme / ( zce * zb )
c rgb 15-apr-95 define zefld from zvloop rather than ajzs(1,jz)
cbate       zefld  = zresis * ajzs(1,jz)*usij
       zefld = 0.0
       if ( zvloop .gt. zepslon) zefld  = zvloop / ( 2. * zpi * zrmaj)
       ztcrit(jz) = ( 0.12 * zlte / ( zrhoe * zq ) )
     &  * sqrt( sqrt(2.0) * zefld
     &   * ( 1.0 + ( zni * zti ) / ( zne * zte ) )
     &    / ( zb * zvthe * zbeta ) )
c
       if ( abs( ztcrit(jz) ) .lt. 1.0
     &     .and. q(jz+1) .gt. q(jz-1) ) then
         zchian = 0.5 * ( abs(1.0/zlte) + abs(2.0/zlne) )
     &    * sqrt( zte / ( zti * zrmaj * zne ) )
     &    * zq * zcc**2 / abs( zshat * zvalfv )
     &    * ( 1.0 - sqrt(abs(zrmin/zrmaj)) ) * sqrt( 1.0 + zeff )
         zelrlw = zelonf**cthery(27)
         thrlwe(jz) = cthery(25) * zchian * (1.0 - ztcrit(jz)) * zelrlw
         thrlwi(jz) = cthery(26) * zchian * sqrt( zte / zti )
     &    * ( 1.0 - ztcrit(jz) ) * zelrlw * 2.0 / sqrt( 1.0 + zeff )
         zdrlw = cthery(24) * 0.7 * zchian * sqrt( zte / zti )
     &    * ( 1.0 - ztcrit(jz) ) * zelrlw * 2.0 / sqrt( 1.0 + zeff )
       endif
      endif
c
!| 
!| %**********************************************************************c
!| 
!| \subsection{Sawteeth}
!| 
!| As there is no immediately forseeable need for the
!| post-sawtooth transport enhancement from the Comments paper,
!| writing coding for evaluation of these fluxes
!| has been deferred until such time as they are required.
!| When this is included, it will be necessary to
!| have the time $t_{saw}$ of the last sawtooth crash.
!| It may be possible to compute this from the sawtooth-controlling
!| parameters already in {\tt common} and the present values of time and
!| timestep (and $q$ profile, to make sure a sawtooth crash actually
!| occured when allowed by the input data).  Alternatively,
!| it may be necessary to alter BALDUR elsewhere
!| and transfer $t_{saw}$ by {\tt common} or subroutine argument.
!| Then compute
!| (C32), (C31), and $Q_{e}^{RR}L_{Te}/(n_{e}T_{e})$.
!| 
!| %**********************************************************************c
!| 
!| \subsection{Neoclassical Fluxes}
!| 
!| Implementation of the simplified
!| neoclassical fluxes in the Comments paper
!| will also be deferred until after preliminary applications of
!| the anomalous flux formulas and evidence surfaces of a need
!| for the simplified neoclassical formulas.
!| To give some idea of how much additional coding these would require,
!| however, the needed formulas are outlined here.
!| For the neoclassical fluxes, an appropriate order of computation
!| would be something like the following. (The sign conventions here
!| should be rechecked, and the formulas should be rechecked
!| against the original references.  Here,
!| we follow the
!| convention used elsewhere
!| in BALDUR of defining the particle
!| fluxes as ``pinches''.  This should be reconsidered before
!| final implementation.)  Compute $v_{a}^{W}=-\Gamma_{a}^{W}$ from
!| (C1), $v_{I}^{P}=\Gamma_{I}^{P}/n_{I}$ from (C3),
!| $\sum_{a}v_{a}^{W}n_{a}L_{Te}/n_{e}$, and
!| $\sum_{I}^{P}(1-Z_{I})L_{Ti}n_{I}/n_{i}$ [{\it cf.} (C4)].
!| The following quantities in (C41) and the definitions immediately
!| thereafter would be needed: $\alpha_{nc}$, $\mu_{i}$, $\nu_{I}^{*}$,
!| $K_{2ps}$, $K_{2nc}$. Also, $K_{2}$, $\chi_{nc}$,
!| and $\chi_{nc-new}$ are needed, their interpretation for more
!| than one impurity needs to be clarified. It should also be checked whether
!| $K_{2}$ and $\chi_{nc}$ are properly listed.  For self-consistency,
!| ion heating due to damping of poloidal rotation should also be
!| included in a complete neoclassical treatment ({\it cf.} the
!| Hirshman-Sigmar Nuclear Fusion review \cite{Hirshman} and/or the
!| Hirshman-Jardin J. Comp. Physics \cite{JCP} paper for details).
!| 
!| %**********************************************************************c
!| 
!| \subsection{Totals}
!| 
!| The quantities computed above which have units
!| of diffusivity are combined in the sums
!| $$ D_{a}=D_{a}^{TEM}+D_{a}^{ITG}+D_{a}^{RM}+D_{a}^{RB}+D_{a}^{KB}+
!|  D_{a}^{NMHD}+D_{a}^{CE}+D_{a}^{HF}
!|  \eqno{\tt dhtot} $$
!| $$ \chi_{e}
!|  =(Q_{e}^{TEM} + Q_e^{ITG} + Q_e^{RM}
!|  +Q_{e}^{RB}+Q_{e}^{KB}+Q_{e}^{NMHD}+Q_{e}^{CE}+Q_{e}^{HF})
!|  \frac{L_{Te}}{n_{e}T_{e}} \eqno{\tt xetot} $$
!| $$ \chi_{i}
!|  =(Q_{i}^{TEM} + Q_i^{ITG} + Q_i^{RM}
!|  +Q_{i}^{RB}+Q_{i}^{KB}+Q_{i}^{NMHD}+Q_{i}^{CE}+Q_{i}^{HF})
!|  \frac{L_{Ti}}{n_{i}T_{i}} \eqno{\tt xitot} $$
!| and  the thermal diffusivities are
!| corrected for inclusion of convective energy transport using
!| $$  \chi_{e}=Q_{e}\frac{L_{T_{e}}}{n_{e}T_{e}}
!|                - c_{17} C_{pv}^{e}D_{a}/\eta_{e} \eqno{\tt xetot} $$
!| $$  \chi_{i}=Q_{i}\frac{L_{T_{i}}}{n_{i}T_{i}}
!|                - c_{17} C_{pv}^{i}D_{a}/\eta_{i} \eqno{\tt xitot} $$
!| 
!| and then returned to BALDUR subroutine {\tt trcoef} as is
!| presently done from {\tt empirc}. Those thermal diffusivities and the
!| electron-
!| ion energy interchange are printed out when {\tt theory} is called from
!| subroutine {\tt mprint}. The relevant coding is:
!| 
c   combined totals
c
        zdsum = zdti(jz) + zdrm(jz) + zdrb(jz) + zdkb(jz)
     &          + zdnm(jz) + zdhf(jz)
        dhtot(jz)=zdsum
        dztot(jz)=zdsum
c
       xetot(jz) =   thrme(jz) + thrbe(jz) + thkbe(jz)
     &  + thnme(jz) + thhfe(jz)
     &  + thtie(jz) + thrlwe(jz) - cthery(17)*cthery(68)*zdsum/zetae
       xitot(jz) =   thrmi(jz) + thrbi(jz) + thkbi(jz)
     &  + thnmi(jz) + thhfi(jz)
     &  + thtii(jz) + thrlwi(jz) - cthery(17)*cthery(69)*zdsum/zetai
c
c
c ..............................
c  arrays for diagnostic output
c ..............................
c
        threti(jz) = zetai
        thdinu(jz) = zdiafr / znueff
        thfith(jz) = zfith
        thdte(jz)  = zdte
        thdi(jz)   = zdi
        thbpbc(jz) = zbpbc1
        thlni(jz)  = zln
        thlti(jz)  = zlti
        thdia(jz)  = zdiafr / zwn**2
c
        thlsh(jz)  = zlsh
        thlpr(jz)  = zlpr
        thlarp(jz) = zlarpo
        thrhos(jz) = zrhos
c
        thvthe(jz) = zvthe
        thvthi(jz) = zvthi
        thsoun(jz) = zsound
        thalfv(jz) = zvalfv
c
        thbeta(jz) = zbeta
        thetth(jz) = zetith
        thsrhp(jz) = zsrhp
        thdias(jz) = zfdias
        thtau(jz) = zti / zte
c
        zrsist(jz) = zresis
        zdshat(jz) = zshat
        zdnuhat(jz) = znuhat
        zdbetae(jz) = zbetae
        zdbetah(jz) = zbetah
        zdbetaz(jz) = zbetaz
        zkpar(jz) = zkparl
c
c..gradient scale lengths
c  print smoothed values if lthery(33) .gt. 0
c
      if ( lthery(33) .gt. 0 ) then
        zslne(jz) = zlne
        zslni(jz) = zlni
        zslnh(jz) = zlnh
        zslnz(jz) = zlnz
        zslte(jz) = zlte
        zslti(jz) = zlti
        zslpr(jz) = zlpr
      endif
c
 300  continue
c
        zlastime = time
c
c   end of the main do-loop over the radial index, "jz"----------
c
!| 
!| In order to limit the time rate of change of the theory-based
!| diffusivities, the old values are kept in local arrays.
!| The difference between the old and the new values is computed
!| \[ \Delta \chi_j = \chi^{N}_j - \chi^{N-1}_j \]
!| and stored in local arrays.
!| This difference is then spatially averaged
!| \[  \bar{ \Delta \chi_j }
!|     = ( \Delta \chi_{j-1} + 2 \Delta \chi_j +  \Delta \chi_{j+1} ) / 4 \]
!| Finally, the adjusted diffusivity is computed
!| \[ \chi^N_j = \chi^{N-1}_j
!|  + \Delta \chi_j /
!|  ( 1. + c_{60} |  \Delta \chi_j - \bar{ \Delta \chi_j} | ). \]
!| Here $ c_{60} = {\tt cthery(60)} $ with default value 0.0.
!| A recommended value is $ {\tt cthery(60)} = 10.0 $
!| if the diffusivities show the pattern of a numerical instability.
!| This adjustment suppresses large local changes in the diffusivities.
!| Here, this algorithm is applied only to the ITG ($\eta_i$) mode.
!| 
      if ( cthery(60) .gt. zepslon ) then
c
        if ( nstep .lt. 1 ) then
          do jz=1,medge
            zoetai(jz) = thigi(jz)
            zoetae(jz) = thige(jz)
            zoetad(jz) = zddig(jz)
            zoetaz(jz) = zdzig(jz)
          enddo
        endif
c
        do jz=1,medge
          zdleti(jz) = thigi(jz) - zoetai(jz)
          zdlete(jz) = thige(jz) - zoetae(jz)
          zdletd(jz) = zddig(jz) - zoetad(jz)
          zdletz(jz) = zdzig(jz) - zoetaz(jz)
        enddo
c
        do jz=maxis+1,medge-1
          ztemp1(jz)=0.25*(zdleti(jz-1)+2.0*zdleti(jz)+zdleti(jz+1))
          ztemp2(jz)=0.25*(zdlete(jz-1)+2.0*zdlete(jz)+zdlete(jz+1))
          ztemp3(jz)=0.25*(zdletd(jz-1)+2.0*zdletd(jz)+zdletd(jz+1))
          ztemp4(jz)=0.25*(zdletz(jz-1)+2.0*zdletz(jz)+zdletz(jz+1))
        enddo
c
        do jz=maxis+1,medge-1
          thigi(jz) = zoetai(jz) + zdleti(jz)
     &     / ( 1. + cthery(60) * abs ( zdleti(jz) - ztemp1(jz) ) )
          thige(jz) = zoetae(jz) + zdlete(jz)
     &     / ( 1. + cthery(60) * abs ( zdlete(jz) - ztemp2(jz) ) )
          zddig(jz) = zoetad(jz) + zdletd(jz)
     &     / ( 1. + cthery(60) * abs ( zdletd(jz) - ztemp3(jz) ) )
          zdzig(jz) = zoetaz(jz) + zdletz(jz)
     &     / ( 1. + cthery(60) * abs ( zdletz(jz) - ztemp4(jz) ) )
        enddo
c
        if (  nstep .gt. istep ) then
          istep = nstep
          do jz=1,medge
            zoetai(jz) = thigi(jz)
            zoetae(jz) = thige(jz)
            zoetad(jz) = zddig(jz)
            zoetaz(jz) = zdzig(jz)
          enddo
        endif
c
      endif
!| 
!| If {\tt cthery(61)} > 0.0, the same algorithm is applied to the
!| trapped electron modes.
!| 
c
      if ( cthery(61) .gt. zepslon ) then
c
        if ( nstep .lt. 1 ) then
          do jz=1,medge
            zotmai(jz) = thdri(jz)
            zotmae(jz) = thdre(jz)
            zotmad(jz) = zddtem(jz)
            zotmaz(jz) = zdztem(jz)
          enddo
        endif
c
        do jz=1,medge
          zdltmi(jz) = thdri(jz) - zotmai(jz)
          zdltme(jz) = thdre(jz) - zotmae(jz)
          zdltmd(jz) = zddtem(jz) - zotmad(jz)
          zdltmz(jz) = zdztem(jz) - zotmaz(jz)
        enddo
c
        do jz=maxis+1,medge-1
          ztemp1(jz)=0.25*(zdltmi(jz-1)+2.0*zdltmi(jz)+zdltmi(jz+1))
          ztemp2(jz)=0.25*(zdltme(jz-1)+2.0*zdltme(jz)+zdltme(jz+1))
          ztemp3(jz)=0.25*(zdltmd(jz-1)+2.0*zdltmd(jz)+zdltmd(jz+1))
          ztemp4(jz)=0.25*(zdltmz(jz-1)+2.0*zdltmz(jz)+zdltmz(jz+1))
        enddo
c
        do jz=maxis+1,medge-1
          thdri(jz) = zotmai(jz) + zdltmi(jz)
     &     / ( 1. + cthery(61) * abs ( zdltmi(jz) - ztemp1(jz) ) )
          thdre(jz) = zotmae(jz) + zdltme(jz)
     &     / ( 1. + cthery(61) * abs ( zdltme(jz) - ztemp2(jz) ) )
          zddtem(jz) = zotmad(jz) + zdltmd(jz)
     &     / ( 1. + cthery(61) * abs ( zdltmd(jz) - ztemp3(jz) ) )
          zdztem(jz) = zotmaz(jz) + zdltmz(jz)
     &     / ( 1. + cthery(61) * abs ( zdltmz(jz) - ztemp4(jz) ) )
        enddo
c
        if (  nstep .gt. istep ) then
          istep = nstep
          do jz=1,medge
            zotmai(jz) = thdri(jz)
            zotmae(jz) = thdre(jz)
            zotmad(jz) = zddtem(jz)
            zotmaz(jz) = zdztem(jz)
          enddo
        endif
c
      endif
c
c..finally, add ITG mode and TEM transport
c  to the total effective thermal diffusivities
c
c  Skip this if lthery(7) > 20  .and. lthery(8) < 21
c    (Full matrix difthi used instead)
c
      if ( lthery(7) .lt. 20 .or. lthery(8) .gt. 20 ) then
c
        do 280 jz=maxis+1,medge
          xitot(jz) = xitot(jz) + thdri(jz) + thigi(jz)
          xetot(jz) = xetot(jz) + thdre(jz) + thige(jz)
c
c..hydrogenic diffusivity
c
            dhtot(jz) = dhtot(jz) + zddtem(jz) + zddig(jz)
c
c..impurity diffusivity
c
            dztot(jz) = dztot(jz) + zddtem(jz) + zdzig(jz)
 280    continue
c
      endif
c
c..smoothing applied to effective diffusivities and matrix
c
      if ( lthery(28) .gt. 0 ) then
c
        ismooth = lthery(28)
        zsmooth = cthery(127)
        ilower  = maxis + 1
        iupper  = medge
c
        call smooth2 ( xetot, 1, ztemp1, ztemp2, 1
     &    , ilower, iupper, ismooth, zsmooth )
        call smooth2 ( xitot, 1, ztemp1, ztemp2, 1
     &    , ilower, iupper, ismooth, zsmooth )
c
        call smooth2 ( dhtot, 1, ztemp1, ztemp2, 1
     &    , ilower, iupper, ismooth, zsmooth )
        call smooth2 ( vhtot, 1, ztemp1, ztemp2, 1
     &    , ilower, iupper, ismooth, zsmooth )
c
        call smooth2 ( dztot, 1, ztemp1, ztemp2, 1
     &    , ilower, iupper, ismooth, zsmooth )
        call smooth2 ( vztot, 1, ztemp1, ztemp2, 1
     &    , ilower, iupper, ismooth, zsmooth )
c
        if ( lthery(7) .gt. 20 ) then
c
          idim = matdim
          idim2 = idim**2
c
          do j1=1,idim2
            call smooth2 ( difthi, idim2, ztemp1, ztemp2, j1
     &        , ilower, iupper, ismooth, zsmooth )
          enddo
c
          do j1=1,idim
            call smooth2 ( velthi, idim, ztemp1, ztemp2, j1
     &        , ilower, iupper, ismooth, zsmooth )
          enddo
c
        endif
c
      endif
c
!| 
!| Boundary conditions at the magnetic axis and at the plasma edge:
!| 
c
c..values at "r=0"
c
        dhtot(maxis) = dhtot(jzmin)
        dztot(maxis) = dztot(jzmin)
c
        vhtot(maxis) = 0.0
        vztot(maxis) = 0.0
c
        xetot(maxis) = xetot(jzmin)
        xitot(maxis) = xitot(jzmin)
c
c..extrapolate density * diffusivity from penultimate to edge grid point
c
      if ( lthery(2) .eq. 1 ) then
c
        dhtot(medge) = dhtot(medge-1) *
     &      densi(medge-1) / densi(medge)
        vhtot(medge) = vhtot(medge-1) *
     &      densi(medge-1) / densi(medge)
c
        dztot(medge) = dztot(medge-1) *
     &      densi(medge-1) / densi(medge)
        vztot(medge) = vztot(medge-1) *
     &      densi(medge-1) / densi(medge)
c
        xetot(medge) = xetot(medge-1) *
     &      dense(medge-1) / dense(medge)
        xitot(medge) = xitot(medge-1) *
     &      densi(medge-1) / densi(medge)
c
      endif
c
c..set up total diffusivities for printout
c
      do jz=maxis,medge
        zchie(jz) = xetot(jz)
        zchii(jz) = xitot(jz)
        zdifh(jz) = dhtot(jz)
        zdifz(jz) = dztot(jz)
      enddo
c
      if ( lthery(7) .ge. 20 .and. lthery(8) .lt. 21 ) then
        do jz=maxis,medge
          zchie(jz) = zchie(jz) + thdre(jz) + thige(jz)
          zchii(jz) = zchii(jz) + thdri(jz) + thigi(jz)
          zdifh(jz) = zdifh(jz) + zddtem(jz) + zddig(jz)
          zdifz(jz) = zdifz(jz) + zddtem(jz) + zdzig(jz)
        enddo
      endif
c
!| 
!| %**********************************************************************c
!| 
!| \subsection{Printout}
!| 
c
c  print theory's output
c
      if ( lprint .lt. 1 ) return
c
cbate      entry prtheory
c
 900  continue
c
c..Profiles as a function of major radius
c
      icntr = maxis
      iedge = medge + 1
c
c..total theory-based diffusivities
c
       write(nprint,10007) nstep, time
       write(nprint,10009)
       write(nprint,10008)
c
c  weithe(jz) used to be eithes(jz)/(useh*uesp)
c
      do jz=jzmin,medge
        write(nprint,101) jz, rminor(jz), xetot(jz)
     &     , xitot(jz), weithe(jz), zdifh(jz), zdifz(jz)
      enddo
c
c..electron thermal diffusivities
c
      write(nprint,104)  nstep, time
      write(nprint,105)
c
      do 920 jz=jzmin,medge
        write(nprint,106) jz, rminor(jz), thdre(jz), thige(jz)
     &  , thrbb(jz), thrbgb(jz), thkbe(jz), thnme(jz)
     &  , zchie(jz)
 920  continue
c
      write(nprint,117)
c
      do 925 jz=jzmin,medge
        write(nprint,118) jz, rminor(jz), thtie(jz)
     &  , thhfe(jz), thcee(jz), thhme(jz), zchie(jz)
 925  continue
c
c..ion thermal diffusivities
c
      write(nprint,107)  nstep, time
      write(nprint,108)
c
      do 930 jz=jzmin,medge
      write(nprint,106) jz, rminor(jz), thdri(jz), thigi(jz)
     &  , thtii(jz), thrbi(jz), thkbi(jz) ,thnmi(jz)
     &  , zchii(jz)
 930  continue
c
      write(nprint,119)
c
      do 935 jz=jzmin,medge
        write(nprint,120) jz, rminor(jz)
     &      , thrmi(jz), thhfi(jz), thcei(jz), zchii(jz)
 935  continue
c
c..hydrogen particle diffusivity
c
      write (nprint,103)  nstep, time
      write (nprint,109)
c
      do jz=jzmin,medge
        write(nprint,106)jz,rminor(jz),zddtem(jz),zddig(jz)
     &    ,zdti(jz),zdrm(jz),zdrb(jz),zdkb(jz)
     &    ,zdnm(jz),zdhf(jz),zdifh(jz)
      enddo
c
c..frequencies and 1/k_perp^2
c
      write (nprint,103)  nstep, time
      write (nprint,170)
c
      do jz=jzmin,medge
        write(nprint,171) rminor(jz), zgmitg(jz), zomitg(jz)
     &      , zgm2nd(jz), zom2nd(jz), zgmtem(jz), zomtem(jz)
     &      , zomegde(jz), zomegse(jz), zkinvsq(jz), wexbs(jz)
      enddo
c
c..Print out diffusivity matrix
c
      if ( lthery(7) .ge. 21  .and.  lthery(7) .le. 23 ) then
c
        write(nprint,161)  nstep, time
c
        write(nprint,135)
c
        do jz=jzmin,medge
          write(nprint,106) jz, rminor(jz), thigi(jz)
     &      , velthi(1,jz), (difthi(1,j2,jz),j2=1,4), zprfmx(jz)
        enddo
c
        write(nprint,162)  nstep, time
c
        write(nprint,135)
c
        do jz=jzmin,medge
          write(nprint,106) jz, rminor(jz), zddig(jz)
     &      , velthi(2,jz), (difthi(2,j2,jz),j2=1,4)
        enddo
c
        write(nprint,163)  nstep, time
c
        write(nprint,135)
c
        do jz=jzmin,medge
          write(nprint,106) jz, rminor(jz), thige(jz)
     &      , velthi(3,jz), (difthi(3,j2,jz),j2=1,4)
        enddo
c
        write(nprint,164)  nstep, time
c
        write(nprint,135)
c
        do jz=jzmin,medge
          write(nprint,106) jz, rminor(jz), zdzig(jz)
     &      , velthi(4,jz), (difthi(4,j2,jz),j2=1,4)
        enddo
c
      endif
c
c..diagnostic arrays
c
      if ( lthery(29) .gt. 2 ) then
c
        write(nprint,110)  nstep, time
        write(nprint,111)
c
        do jz=jzmin,medge
          write(nprint,106)jz,rminor(jz),threti(jz),thetth(jz)
     &      ,thfith(jz),thbpbc(jz),thnust(jz),thsrhp(jz),thdias(jz)
     &      ,zdifh(jz),zdifz(jz)
        enddo
c
      endif
c
      write(nprint,110)  nstep, time
      write(nprint,113)
c
      do jz=jzmin,medge
        write(nprint,106)jz,rminor(jz)
     &        ,zslne(jz),zslnh(jz),zslnz(jz),zslte(jz),zslti(jz)
     &        ,thlpr(jz),thlsh(jz),thrhos(jz)
      enddo
c
      if ( lthery(29) .gt. 2 ) then
c
        write(nprint,110)  nstep, time
        write(nprint,114)
c
        do jz=jzmin,medge
          write(nprint,106)jz,rminor(jz),thvthe(jz),thvthi(jz)
     &        ,thalfv(jz),thsoun(jz)/(rmajor(jz))
     &        ,zgmitg(jz),zgmtem(jz),zrsist(jz)
        enddo
c
c..dimensionless variables
c
        write(nprint,110)  nstep, time
        write(nprint,140)
c
        do jz=jzmin,medge
          write(nprint,126)jz,rminor(jz),thnust(jz)
     &      ,thrstr(jz),q(jz),zdshat(jz), thbeta(jz),thtau(jz)
        enddo
      endif
c
c..diagnostic output for the Hahm-Tang TEM when lthery(5) = 1
c
      if ( lthery(5) .eq. 1 .and. lthery(29) .ge. 5 ) then
c
        write(nprint,115)  nstep, time
        write(nprint,116)
c
      do jz=jzmin,medge
        write(nprint,106) jz, rminor(jz), zddtem(jz)
     &    , zhctem(jz), zhdtem(jz), zd1tem(jz)
     &    , zh1tem(jz), zk1tem(jz), weithe(jz)
      enddo
c
      endif
c
c..diagnostic output for Nordman-Weiland ITG model when lthery(7)=21-30
c
      if ( lthery(7) .gt. 21 .and. lthery(29) .gt. 2 ) then
c
        write(nprint,158) ieq, nstep, time
        write(nprint,159)
c
        do jz=jzmin,medge
          write(nprint,160) jz,rminor(jz),q(jz),zdshat(jz)
     &      ,zdnuhat(jz),zdbetae(jz),zdbetah(jz)
     &      ,zdbetaz(jz),zkpar(jz)
        enddo
c
      endif
c
c..diagnostic printout for the kinetic ballooning mode
c
      if ( lthery(17) .gt. -1 .and. lthery(29) .ge. 5 ) then
c
        write(nprint,110)  nstep, time
        write(nprint,112)
c
      do jz=jzmin,medge

        write(nprint,106) jz, rminor(jz)
     &    , zbprima(jz), zbc1a(jz), thbpbc(jz), zbc2a(jz)
     &    , thlpr(jz), thlarp(jz), zdka(jz)
      enddo
c
      endif
c
c..diagnostic output for the Carreras-Diamond RB model
c
      if ( lthery(15) .le. 2 .and. lthery(29) .ge. 5 ) then
c
        write(nprint,110)  nstep, time
        write(nprint,121)
c
      do jz=jzmin,medge
c
        write(nprint,124) jz, rminor(jz)
     &    , thlamb(jz), zfstarrb(jz), zfdiarb(jz)
c
      enddo
c
      endif
c
c..diagnostic output for the Guzdar-Drake RB model
c
      if ( lthery(13) .gt. 0  .and.  lthery(29) .ge. 5 ) then
c
        write(nprint,110)  nstep, time
        write(nprint,122)
c
      do jz=jzmin,medge
c
        write(nprint,125) jz, rminor(jz)
     &    , zwstrnm(jz), znuiz(jz), zcmiz(jz), zalphz(jz)
c
      enddo
c
      endif
c
c..diagnostic output for the neoclassical MHD model
c
      if ( lthery(15) .eq. 2  .and.  lthery(29) .ge. 5 ) then
c
        write(nprint,110)  nstep, time
        write(nprint,123)
c
      do jz=jzmin,medge
c
        write(nprint,106) jz, rminor(jz)
     &    , zxnmz(jz), zexbnz(jz),zdelez(jz),zlambz(jz)
     &    , zgammz(jz),zflamz(jz),zfgamz(jz),zfdiaz(jz)
c
      enddo
c
      endif
c
c**********************************************************************c
c Format statements
c
10007 format(/,10x,'transport coefficients from theory'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/)
10008 format(4x,'zone',6x,'radius',9x,'chi-elc',8x,'chi-ion',
     #       8x,'intrchg',10x,'zdifh',10x,'zdifz')
10009 format(16x,'m',13x,'m*m/s',10x,'m*m/s',12x,'w',
     #       12x,'m*m/s')
c
 101  format(5x,i2,6x,0pf6.3,8x,5(1pe11.4,4x))
 103  format(/,10x,'hydrogenic ion diffusion coefficients'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/,
     &       10x,37('-'))
 104  format(/,10x,'electron theoretical diffusion coefficients'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/,
     &       10x,43('-'))
 105  format(12x,'m',9x,'m2/s',6(8x,'m2/s'),/
     & 5x,'jz',3x,'radius',6x,'xedr',8x,'xeig',7x
     &         ,'xerb-B',6x,'xerbgB',7x,'xekb',8x,'xenm'
     &         ,8x,'xethe',7x,' ',6x,' ')
 106  format(5x,i2,3x,0pf6.3,4x,9(1pe10.3,2x))
 107  format(/,10x,'ion theoretical diffusion coefficients'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/,
     &       10x,37('-'))
 108  format(12x,'m',9x,'m2/s',6(8x,'m2/s'),/
     &  5x,'jz',3x,'radius',6x,'xidr',8x,'xiig',8x,'xiti',8x
     &         ,'xirb',8x,'xikb',8x,'xinm'
     &         ,8x,'xithe',7x,' ',6x,' ')
 109  format(12x,'m',9x,'m2/s',7(8x,'m2/s'),/
     &  5x,'jz',3x,'radius',6x,'dhdr',8x,'dhig',8x,'dhti',8x
     &         ,'dhrm',8x,'dhrb',8x,'dhkb',8x,'dhnm'
     &         ,8x,'dhhf',8x,'dhthe')
 110  format(/,10x,'diagnostic arrays from sbrtn THEORY'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/)
 111  format(5x,'jz',3x,'radius',7x,'eta_i ',4x,'eta_i^th'
     #       ,5x,'f_ith',5x,'beta_ratio',5x,'nu_e^*',5x,'Reynolds'
     #       ,5x,'zfdias',6x,'difhyd',6x,'difimp'/)
 112  format(5x,'jz',3x,'radius'
     #       ,7x,'zbprim',6x,'zbc1',8x,'bp/zbc1',5x,'zbc2',8x,'L_p '
     #       ,8x,'zlarpo',6x,'zdk',9x,' ')
 113  format(5x,'jz',3x,'radius'
     #       ,7x,'L_ne',8x,'L_nH',8x,'L_nZ',8x,'L_Te',8x,'L_Ti'
     #       ,8x,'L_p',9x,'L_S',9x,'rho_S')
 114  format(5x,'jz',3x,'radius'
     &       ,8x,'v_the',7x,'v_thi',9x,'v_A',5x,'c_s / R'
     &       ,2x,'gamma_etai',3x,'gamma_tem',2x,'resistivity')
c
 115  format (
     & /,10x,'special diagnostic output for the Hahm-Tang TEM'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec'
     & /,10x,'-----------------------------------------------')
 116  format (5x,'jz',3x,'radius',7x,'zddtem',7x,'zhctem',7x,'zhdtem'
     &   ,7x,'zd1tem',7x,'zh1tem',7x,'zk1tem',7x,'weithe',/)
 117  format(/,12x,'m',9x,'m2/s',4(8x,'m2/s'),/
     & ,5x,'jz',3x,'radius',6x,'xeti',8x,'xehf',8x,'xece',8x
     &   ,'xehm',8x,'xethe')
 118  format(5x,i2,3x,0pf6.3,4x,5(1pe10.3,2x))
 119  format(/,12x,'m',9x,'m2/s',3(8x,'m2/s'),/
     & ,5x,'jz',3x,'radius',6x,'xirm',8x,'xihf',8x,'xice',8x,'xithe')
 120  format(5x,i2,3x,0pf6.3,4x,4(1pe10.3,2x))
 121  format(5x,'jz',3x,'radius'
     &       ,6x,'thlamb',6x,'zfstar',6x,'zfdias')
 122  format(/,5x,'jz',3x,'radius'
     &       ,6x,'zwstrp',6x,'znui',9x,'zcmi',6x,'zalphe')
 123  format(/,5x,'jz',3x,'radius'
     &       ,6x,'zxnmz ',6x,'zexbnz',6x,'zdelez',6x,'zlambn'
     &       ,6x,'zgammh',6x,'zflamb',6x,'zfgamh',6x,'zfdiaz')
 124  format(5x,i2,3x,0pf6.3,4x,4(1pe10.3,2x))
 125  format(5x,i2,3x,0pf6.3,4x,5(1pe10.3,2x))
 126  format(5x,i2,3x,0pf6.3,1x,9(1pe10.3,1x))

c
 130  format (
     & /,10x,'Profiles as a function of major radius'
     & /,t4,'rmajor(m)',t17,'ne(m^-3)',t30,'Te(keV)',t43,'Ti(keV)'
     &  ,t56,'Zeff')
 132  format (5(2x,1pe11.4))
c
 135  format (5x,'jz',3x,'radius',2x,'diffusivity',4x,'velthi(*)'
     &  ,'  difthi(*,1) difthi(*,2) difthi(*,3) difthi(*,4)'
     &  ,t95,'perform')
c
 140  format (5x,'jz',3x,'radius',4x,'nustar',4x,'rhostar'
     &  ,6x,'q',9x,'shear',6x,'beta',6x,'Ti/Te')
c
 158  format (
     &  /,10x,'diagnostic output for Weiland ITG model'
     &  ,' with ',i2,' equations'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec'
     &  /,10x,'---------------------------------------')
c
 159  format (/,5x,'jz',3x,'radius',5x,'zq',7x,'zshat',6x
     &  ,'znuhat',5x,'zbetae',5x,'zbetah',5x,'zbetaz',5x
     &  ,'zkparl')
 160  format(5x,i2,3x,0pf6.3,1x,9(1pe10.3,1x))
 161  format(/,10x,'Ion thermal channel of diffusivity matrix'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/)
c
 162  format(/,10x,'Hydrogen particle channel of diffusivity matrix'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/)
c
 163  format(/,10x,'Electron thermal channel of diffusivity matrix'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/)
c
 164  format(/,10x,'Impurity particle channel of diffusivity matrix'
     &  ,' at step ',i5,'  at time ',0pf13.6,' sec',/)
c
 170  format(/,3x,'radius',3x,'gammaitg',3x,'omegaitg'
     & ,3x,'gamma2nd',3x,'omega2nd',3x,'gammatem',3x,'omegatem'
     & ,3x,'omega_De',3x,'omega_*e',3x,'1./k_r^2',3x,'wexb')
 171  format(3x,0pf6.3,1x,11(1pe10.3,1x))
c
 990  return
      end
!| 
!| %**********************************************************************c
!| 
!| \section{Recommended Input Values}
!| 
!| After benchmarking the Weiland ITG model with parallel ion motion and
!| finite beta effects and the Guzdar-Drake resistive ballooning model with Ohmic,
!| L-mode, and H-mode shots at Lehigh University, the following values are recommended
!| for the best fit to experimental data:
!| 
!|
!| ! Multi Mode Model in sbrtn THEORY as of Mar 1996
!| !
!| lthery(3)  = 4  ! use hydrogen and impurity density scale length in etaw14
!| lthery(4)  = 1  ! use neoclassical resistivity in sbrtn THEORY
!| lthery(5)  = 2  ! skip dissipative trapped electron mode (DTEM)
!| lthery(6)  = 1  ! min[1.0,0.1/\nu_e^*] transition to collisionless TEM
!| lthery(7)  = 27 ! Weiland ITG model with 10 equations
!| lthery(8)  = 21 ! Use effective diffusivities
!| lthery(9)  = 2  ! linear ramp form for f_ith
!| lthery(13) = 3  ! Guzdar-Drake resistive ballooning mode (1994)
!| lthery(14) = 1  ! Single iteration for lambda in RB mode
!| lthery(15) = 0  ! Neoclassical MHD model w/ Callen corrections (no longer used)
!| lthery(16) = 0  ! Circulating Electron model
!| lthery(17) = 1, ! 1995 kinetic ballooning model
!| lthery(25) = 0  ! Rebut-Lallia-Watkins model
!| lthery(26) = 100, ! time-step for diagnostic output
!| lthery(27) = 1, ! replace negative diffusivity with convective velocity
!| lthery(29) = 5, ! more printout
!| lthery(30) = 1, ! retain sign of gradient scale lengths
!| lthery(31) = 1, ! Monotonic gradient scale lengths at axis
!| lthery(32) = -2, ! smooth inverse gradient scale lengths over -2 pts
!| !
!| !  misc. parameters for sub. theory
!| !
!| cthery(1)  = 0.0      ! Divertor shear off
!| cthery(3)  0.5        ! minimum shear
!| cthery(7)  = 1.0      ! Width of linear ramp in ITG mode
!| cthery(8)  = 3.5      ! for fbeta-th in kinetic ballooning
!| cthery(12) =-4.0      ! Elongation exponent for TEM,ITG modes
!| cthery(14) =-4.0      ! Elongation exponent for RB mode
!| cthery(15) =-4.0      ! Elongation exponent for KB mode
!| cthery(17) = 0.0      ! turn off convective correction in sbrtn THEORY
!| cthery(20) = 1.0      ! min[c20,c21*0.1/\nu_e^*] in Dominguez-Waltz DTEM
!| cthery(21) = 1.0      ! min[c21,c21*0.1/\nu_e^*] in Dominguez-Waltz DTEM
!| cthery(22) = 0.25     ! exp[-c34(Ti/Te-1)**2] multiplying TEM mode
!| cthery(23) = 0.95     ! Numerical correction in D^{DR} of original TEM model
!| cthery(29) = 0.0,     ! No critical gradient in OHE eta_i mode
!| cthery(30) = 1.0      ! eta-ith = max[c30, c31*L_n/R]
!| cthery(31) = 5.5      ! eta-ith = max[c31, c31*L_n/R]
!| cthery(34) = 0.0      ! exp[-c_{34} (Ti/Te-1.)**2] multiplying ITG mode
!| cthery(35) = 5.0      ! exp[-c35*L_n, c36*L_Ti] multiplying ITG mode
!| cthery(36) = 4.0      ! exp[-c36*L_n, c36*L_Ti] multiplying ITG mode
!| cthery(41) = 2.0      ! Toroidal mode # suggested by Carreras in CD RB model
!| cthery(42) = 1.00     ! diamagnetic stabilization of Carreras-Diamond (CD) RB mode
!| cthery(43) = 0.16667  ! ( 1 + f_\star )**(-cthery(43)) in CD model
!| cthery(44) = 4.0      ! E x B multiplier in RB mode in CD model
!| cthery(45) = 1.0      ! Numerical correction in RB mode in CD model
!| cthery(47) = 8.0      ! q-exponent for Lambda in RB mode in CD model
!| cthery(48) = 0.0      ! ln(256/Lambda^3) used in single iteration of Lambda in CD model
!| cthery(49) = 1.0      ! q-exponent for D^{RB} in RB mode in CD model
!| cthery(50) = 5*100.0, ! limit L_n to c_50 times major radius
!| ! cthery(60) = 5.0    ! Limit local change in diffusivity to 20%
!|                         ! (not used with Weiland)
!| cthery(70) = 1.0      ! Growth rate multiplier in NMHD mode
!| cthery(71) =-4.0      ! Elongation exponent in NMHD mode
!| cthery(72) = 0.0      ! Coeff of chi_e0^{NM} added to D^{NM} in NMHD mode
!| cthery(73) = 1.0      ! Coeff of D_p^{NM} added to chi_e^{NM} in NMHD mode
!| cthery(74) = 0.0      ! Coeff of chi_e0^{NM} added to chi_i^{NM} in NMHD mode
!| cthery(75) = 1.0      ! (c75*omega_*/gamma)^6 in dia stabil of NMHD mode
!| cthery(76) = 0.16667  ! Exponential in dia stabil of NMHD mode
!| cthery(77) = 10.0     ! Average toroidal mode number in NMHD mode
!| cthery(78) 1.0        ! coeff of beta_prime_1 in kinetic ballooning mode
!| cthery(79) 1.0        ! coeff of beta_prime_2 in kinetic ballooning mode
!| cthery(80) = 1.0      ! Multiplier in diffusivity for CE mode
!| cthery(81) =-4.0      ! Elongation exponent for CE mode
!| cthery(82) = 1.0      ! Multiplier in diffusivity for High-m Tearing mode
!| cthery(83) =-4.0      ! Elongation exponent for High-m Tearing mode
!| cthery(85) = 2.0,     ! Specify diamagnetic stabilization in 
!|                       !   Guzdar-Drake RB model
!| cthery(86) = 0.15     ! Dia stabilization in Guzdar-Drake RB model
!| cthery(111) = 0.0,    ! difthi -> velthi for chi_i
!| cthery(112) = 0.0,    ! difthi -> velthi for hydrogen
!| cthery(113) = 0.0,    ! difthi -> velthi for chi_e
!| cthery(114) = 0.0,    ! difthi -> velthi for impurity
!| cthery(119) = 1.0,    ! coeff of finite beta in etaw14
!| cthery(121) = 1.0,    ! set fast particle fraction for use in etaw14
!| cthery(123) = 1.0,    ! coeff of k_ii in etaw14
!| cthery(124) = 0.0,    ! coeff of nuhat in etaw14
!| !
!| ! contributions to fluxes and interchange(for sub. theory)
!| !
!| !particles elec-energy ion-energy
!| fdr=0.00 0.00 0.00
!| fig=0.80 0.80 0.80
!| frm=0.00 0.00 0.00
!| fkb=1.00 0.65 0.65
!| frb=1.00 1.00 1.00
!| fhf=0.00 0.00 0.00
!| fmh=0.00 0.00 0.00
!| fec=0.00 0.00 0.00
!|
!| 
!| %**********************************************************************c
!| 
!| \section{Changes to the Default Model}
!| The default model used in subroutine {\tt theory} was developed by
!| C.~E. Singer as documented
!| in ``Theoretical Particle and Energy Flux Formulas for Tokamaks,''
!| Comments on Plasma Physics and Controlled Fusion, {\bf 11}, 165 (1988)
!| (\cite{Comments}, hereafter referred to as the
!| Comments paper).  The flux formulas are identical to
!| those in the comments paper, with three exceptions.  First, a
!| correction due to Romanelli to the $\eta_{i}$-mode threshold
!| is included \cite{Romanelli}.
!| Second, a minor change in the high-collisionally
!| cut-off on the $\eta_{e}$ mode is included.  Third,
!| an option is included for specifying a harmonic divergence
!| in the shear used in the formulas.This option is included in case the user
!| does not
!| want to include enough moments in the equilibrium solver to
!| get an adequate description of the shear near the separatrix in
!| H-mode plasmas.
!| Additional coding which allows a stand-alone calculation of the transport
!| fluxes is also outlined.
!| 
!| %**********************************************************************c
!| 
!| \section{Numerical Methods}
!| 
!| For simplicity in constructing the coding, we first compute
!| all of the anomalous transport fluxes (given in Sections 1.2-1.7 of
!| the Comments paper~\cite{Comments})
!| from diffusivities of
!| the form $\Gamma_{a}/(n_{a}/L_{ni})$ and $Q_{j}/(n_{j}T_{j}/L_{Tj})$,
!| where $\Gamma_{a}$ and $Q_{j}$ are the particle and energy fluxes.
!| Effective diffusivities associated with ``convective''
!| fluxes normally controlled by the input variables {\tt cthery(68)} and
!| {\tt cthery(69)} are then subtracted to get thermal diffusivities.
!| A related problem is that the ion energy fluxes associated with
!| the Ware pinch effect appear not to have been coded into BALDUR
!| \cite{BALDUR}.  Rather than trying to sort out these complications,
!| one might eventually want to include in subroutine {\tt theory}
!| coding for the complete simplified
!| neoclassical energy fluxes defined in the Comments paper.
!| Input switches could then be defined so that the user who wants to
!| substitute the more complicated pieces of these neoclassical
!| energy fluxes with expressions already available in BALDUR
!| can turn off the parts in subroutine {\tt theory} which
!| would give duplication.
!| Care would have to be taken that calling subroutine {\tt theory}
!| with default input values for parameters which previously
!| controlled neoclassical energy fluxes will result
!| in a self-consistent formulation.  In other words, calling
!| subroutine {\tt theory}
!| with all default input parameters should produce no additional
!| particle or energy fluxes.  At present, however,
!| we retain the existing neoclassical fluxes and add only
!| a new set of options for anomalous fluxes.
!| 
!| As far as finite differencing goes, we calculate
!| parameters which include scale heights in a manner analogous to
!| that used in subroutine {\tt empirc}.  This means that a call to subroutine
!| {\tt xscale} preceeds the call to  subroutine {\tt theory},
!| just as for {\tt empirc}.  The more stringent singularity-prevention
!| limitations described in Section 1.8 of the Comments paper are applied
!| to the scale heights in subroutine {\tt theory}.
!| 
!| %**********************************************************************c
!| 
!| \section{Calculation Order}
!| 
!| Here we describe, in narrative and coded form,
!| the subroutine structure and the calculations required
!| in the order in which they occur in the new subroutine.
!| For the present, we include only anomalous fluxes due to microinstabilities.
!| After we have some practice using the new subroutine,
!| we will decide about coding the
!| post-sawtooth transport enhancement and neoclassical formulas.
!| In a Table 1, we list the coding
!| and algebraic symbols for some preexisting BALDUR
!| {\tt common} variables which are needed in the new subroutine.
!| 
!| Some notes about interaction with BALDUR and its coding
!| conventions are in order here.
!| The array index set equal to {\tt 1} indicates
!| that parameters defined at both zone centers and zone boundaries
!| are being used at zone centers.  The index {\tt jz}
!| indicates a dummy index for the zones.  Care is taken
!| with the innermost dummy zone associated with
!| BALDUR's boundary conditions.  Note that the order of these
!| indices are interchanged in the arrays {\tt rmajor(jz)} and
!| {\tt rmajor(jz)} compared to other such variables.
!| This was evidently done deliberately when Glenn Bateman
!| added these to the older
!| BALDUR variables.
!| We have assumed that {\tt rminor(jz)} is
!| the midplane halfwidth required for computing the inverse
!| aspect ratio in the Comments paper formulas.
!| The real variables local to {\tt theory}
!| (beginning with {\tt z} by OLYMPUS convention)
!| are all in standard units except tempretures which are
!| in keV, so the
!| convention of indicating units with
!| the last coding letter for these variables is {\it not}
!| followed.  For parallism  with the
!| coding for {\tt empirc}, we do
!| maintain this units convention in the new
!| {\tt common} variables added, however.
!| Coding conventions local to subroutine {\tt theory}
!| are (a) variables beginning with {\tt zc}
!| depend only on physical constants, (b) variables whose values are
!| modified later in the subroutine are indented an extra space,
!| and (c) coding statements giving the final definition
!| of each variable in the subroutine (as originally written)
!| are given a statement label which is identical to
!| the corresponding equation number in the original
!| version of this documentation document.
!| 
!| %**********************************************************************c
!| 
!| \subsection{Code Verification}
!| 
!| To aid in performing checks the coding, Table~2
!| is provided here to give a convenient set of numerical results
!| \cite{Comments}.
!| Also shown in Table~2 are some other quantities useful
!| for estimating transport fluxes.  (In constructing this table, we have
!| assumed $n_{i}\approx n_{e}$, so the more exact expressions given in the
!| text above
!| should be used for consistency in detailed multispecies transport code work.)
!| As one check on the coding, by setting the variables in Table~2 to
!| unity using the stand-alone driver routine and verifying that the coding
!| described above reproduces the hand-calculated numerical coefficients
!| shown in Table~2.
!| 
!| \section{Nmemonics}
!| 
!| The mode abbreviations used here are
!| \begin{center}
!| \begin{tabular}{llll}
!|     &             &                                         &        \\
!|     & {\tt dr}    & drift (other than $\eta_{i}$-mode)      &        \\
!|     & {\tt ig}    & $\eta_i$-mode                           &        \\
!|     & {\tt rm}    & rippling mode                           &        \\
!|     & {\tt rb}    & resistive ballooning                    &        \\
!|     & {\tt kb}    & kinetic ballooning                      &        \\
!|     & {\tt hf}    & high frequency ($\eta_{e}$)             &        \\
!|     & {\tt mh}    & neoclassical MHD                        &        \\
!|     & {\tt ec}    & circulating electron                    &        \\
!|     & {\tt hm}    & high-m tearing                          &        \\
!|     & {\tt rlw}   & Rebut-Lallia-Watkins                    &        \\
!|     &             &                                         &
!| \end{tabular}
!| \end{center}
!| 
!| Table 3 lists coding symbols for
!| variables local to subroutine {\tt theory}, statement labels for variables
!| defined in labelled statements (which correspond to
!| equation numbers in the present document), the
!| corresponding algebraic symbol, and the nmemonic
!| used to generate the coding symbol.
!| 
!| %**********************************************************************c
!| 
!| \begin{thebibliography}{99}
!| 
!| \bibitem{BALDUR} C. E. Singer, D. E. Post, D. R. Mikkelsen,
!| M. H. Redi, A. McKenney, et al., ``BALDUR: A One-dimensional
!| Plasma Transport Code,'' Comp. Phys. Communications {\bf 48}
!| (1988, in press).
!| 
!| \bibitem{Bateman} G. Bateman, ``Multi-Mode Simulations of Transport
!| in TFTR,'' IAEA Technical Committee Meeting on Tokamak Transport,''
!| (8-10 October, 1990).
!| 
!| \bibitem{Callen} J. Callen, University
!| of Wisconsin personal communication (dated 4/6/91).
!| 
!| \bibitem{hortoncomm}
!| M.~Ottoviani, W.~Horton, M.~Erba
!| ``Thermal Transport from a Phenomonological Description of ITG-Driven
!| Turbulence'', private communication from W.~Horton, March 1996
!| 
!| \bibitem{carr89a}
!| B.~A. Carreras and P.~H. Diamond,
!| ``Thermal diffusivity induced by resistive pressure-gradient-driven
!| turbulence,'' Physics of Fluids B {\bf 1} (1989) 1011.
!| 
!| \bibitem{Carreras} B. Carreras, Oak Ridge National Laboratory personal
!| communication (27 Nov., 1989).
!| 
!| \bibitem{drake93}
!| P.~N. Guzdar, J.~F. Drake, D. McCarthy, A.~B. Hassam, and C.~S. Liu,
!| ``Three-dimensional Fluid Simulations of the Nonlinear Drift-resistive
!| Ballooning Modes in Tokamak Edge Plasmas,'' Physics of Fluids B {\bf 5}
!| (1993) 3712.
!| 
!| \bibitem{guzcomm} P.N. Guzdar, University of Maryland, personal communication
!|  (11/94).
!| 
!| \bibitem{drakecom} J.F. Drake, University of Maryland, personal
!| communication (6/94).
!| 
!| \bibitem{drakecom2} J.F. Drake, University of Maryland, personal
!| communication (3/95).
!| 
!| \bibitem{Comments} C. E. Singer, ``Theoretical Particle and Energy
!| Flux Formulas for Tokamaks,'' Comments on Plasma Physics and Controlled
!| Fusion {\bf 11} (1988) 165.
!| 
!| \bibitem{gbcomm} G. Bateman, Princeton Plasma Physics Laboratory,
!| personal communication (9/95).
!| 
!| \bibitem{diam85a} P.~H. Diamond, P.~L. Similon, T.~C. Hender, and
!| B.~A. Carreras, ``Kinetic theory of resistive ballooning modes,''
!| Phys. Fluids {\bf 28} (1985) 1116--1125.
!| 
!| \bibitem{domn87} R. R. Dominguez and R. E. Waltz,
!| Nucl. Fusion {\bf 27} (1987) 65.
!| 
!| \bibitem{domn89a} R. R. Dominguez and M. N. Rosenbluth,
!| Nuclear Fusion {\bf 29} (1989) 844.
!| 
!| \bibitem{Dominguez} R. Dominguez, ``DIII-D Hot Ion Plasma
!| Simulations,'' preliminary draft of General
!| Atomics Report GA-A20382 (11 Feb., 1991).
!| 
!| \bibitem{DW} R. R. Dominguez and R. E. Waltz, ``Ion Temperature
!| Gradient Mode and H-mode Conefinement,'' Nuclear Fusion
!| {\bf 29} (1989) 885.
!| 
!| \bibitem{nord90a} H. Nordman, J. Weiland, and A. Jarmen,
!| ``Simulation of toroidal drift mode turbulence driven by
!| temperature gradients and electron trapping,''
!| Nucl. Fusion {\bf 30} (1990) 983--996.
!| 
!| \bibitem{Ghanem} E-S. Ghanem, C. E. Singer, G. Bateman, and D.
!| P. Stotler, ``Multiple Mode Model of Tokamak Transport,''
!| Nuclear Fusion {\bf 30} (1990) 1595.
!| 
!| \bibitem{Ghanphd} E-S. Ghanem, University of Illinois at
!| Urbana-Champaign Department of Nuclear Engineering
!| PhD Thesis (Jan, 1991).
!| 
!| \bibitem{Guzdar} P. Guzdar, private communication (18 April, 1988).
!| 
!| \bibitem{hahm87a} T.~S. Hahm, P.~H. Diamond, P.~W. Terry, L. Garcia,
!| and B.~A. Carreras, Physics of Fluids {\bf 30} (1987) 1452.
!| 
!| \bibitem{hama89a} S. Hamaguchi and W. Horton,
!| ``Fluctuation Spectrum and Transport from Ion Temperature Gradient Driven
!| Modes in Sheared Magnetic Fields,''
!| University of Texas, Institute for Fusion Studies report
!| IFSR \# 383 (August 1989).
!| 
!| \bibitem{hahm89a} T.~S. Hahm and W.~M. Tang,
!| Physics of Fluids {\bf 1} B (1989) 1185.
!| 
!| \bibitem{hahm90a}
!| T.~S. Hahm and W.~M. Tang,
!| ``Weak Turbulence Theory of Collisionless Trapped Electron Driven
!| Drift Instability in Tokamaks,''
!| Princeton Plasma Physics report PPPL-2721 (Sept, 1990).
!| 
!| \bibitem{hahm90b}
!| T.~S. Hahm and W.~M. Tang, private communication.
!| 
!| \bibitem{Hamaguchi} S. Hamaguchi aand W. Horton, ``Fluctuation
!| Spectrum and Transport from Ion Temperature Gradient
!| Driven Modes in Sheared Magnetic Fields,'' University of Texas
!| Institute for Fusion Studies Rep. IFSR \#383 (August, 1989).
!| 
!| \bibitem{HD} T. S. Hahm and P. H. Diamond, Phys. Fluids {\bf 30} (1987) 133.
!| 
!| \bibitem{Hirshman} S. P. Hirshman and D. Sigmar, Nucl. Fusion {\bf 21}
!| (1981) 1079.
!| 
!| \bibitem{IAEA1986} J. D. Callen, W. X. Qu, K. D. Siebert,
!| B. A. Carreras, K. C. Shaing, and I. A. Spong,
!| in {\it Plasma Physics and Controlled Nuclear Fusion Research}
!| (IAEA, Vienna, 1987) Vol II (1986) p. 157.
!| 
!| \bibitem{IAEA} C. E. Singer, W. Choe, D. Cox, T. Djemil,
!| E. Ghanem, J, Kinsey, G. Miley, J. Park, D. Ruzic,
!| S. Hu, N. Tiouririne-Ougouag, V. Varadarajan,
!| R. R. Dominguez, R. E. Waltz, and G. Bateman,
!| ``Predictive Modelling of Tokamak Plasmas,''
!| Thirteenth Conf. on Plasma Physics and Controlled Fusion
!| Research (Washington, October, 1991), paper IAEA-CN-53/D-1-1.
!| 
!| \bibitem{JCP} S. P. Hirshman and S. Jardin, Phys. Fluids {\bf 22} (1978) 731.
!| 
!| \bibitem{Kinsey} J. Kinsey, University of Illinois at
!| Urbana-Champaign Department of Nuclear Engineering
!| Masters Thesis (May, 1991).
!| 
!| \bibitem{Kwon} O. J. Kwon, P. H. Diamond, and H. Biglari,
!| Phys. Fluids {\bf B2} (1990) 291.
!| 
!| \bibitem{lee86a} G. S. Lee and P. H. Diamond,
!| ``Theory of ion-temperature-gradient-driven turbulence in tokamaks,''
!| Physics of Fluids {\bf 29} (1986) 3291.
!| 
!| \bibitem{matt89a} N. Mattor and P.~H. Diamond,
!| Physics of Fluids {\bf 1} B (1989) 1980.
!| 
!| \bibitem{Redi} M. Redi and G. Bateman, ``Transport
!| Simulations of TFTR Experiments to Test Theoretical
!| Models for $\chi_{e}$ and $\chi_{i}$, Princeton
!| Plasma Physics Laboratory Rep. PPPL-2694 (August, 1990).
!| 
!| \bibitem{RLW88a}
!| P.~H. Rebut, P.~P. Lallia, and M.~L. Watkins,
!| ``The Critical Temperature Gradient Model of Plasma Transport:
!| Applications to JET and Future Tokamaks,''
!| IAEA Nice Meeting, Vol. II, 191 (1988).
!| 
!| \bibitem{rebu91a}
!| P.~H. Rebut, M.~L. Watkins, D.~J. Gambier, and D. Boucher,
!| ``A Program toward a fusion reactor,''
!| Phys. Fluids B {\bf 3} (1991) 2209--2219.
!| 
!| \bibitem{Romanelli} F. Romanelli, Joint European Undertaking
!| Report JET-IR-16 (1987).
!| 
!| \bibitem{Rosenbluth} R. R. Dominguez and M. N. Rosenbluth,
!| Nucl. Fusion {\bf 29} (1989) 844.
!| 
!| \bibitem{Ross} D. Ross, P. H. Diamond, J. F. Drake,
!| F. L. Hinton, F. W. Perkins, W. M. Tang, R. E. Waltz,
!| and S. J. Zweben, ``Thermal and Particle Transport
!| for Ignition Studies,'' DOE/ET-53193-7 and
!| University of Texas Fusion Research Center Report
!| FRCR \#295 (1987).
!| 
!| \bibitem{Sherwood} R. Dominguez and
!| R. E. Waltz, Sherwood Theory Meeting Abstracts (1988).
!| 
!| \bibitem{Singer} C.E.Singer, G.Bateman, and D.D.Stotler,
!| ``Boundary Conditions for OH, L, and H-mode Simulations,''
!| Princeton University Plasma Physics Report PPPL-2527 (1988).
!| 
!| \bibitem{Waltz} R. E. Waltz and R. R. Dominguez, Phys. Fluids
!| {\bf B1} (1989) 1935.
!| 
!| \end{thebibliography}
!| 
!| %**********************************************************************c
!| 
!| \begin{table}
!| \begin{center}
!| \underline{Table 1.  Variables already in {\tt common}}
!| \end{center}
!| \begin{tabular}{lll}
!|                    &                      &           \\
!| \underline{Symbol} & \underline{Coding}   & Units     \\
!|                    &                      &           \\
!| $A_{i}$            & {\tt aimass(jz)}     &           \\
!| $R$                & {\tt rmajor(jz)}     & cm         \\
!| $r$                & {\tt rminor(jz)}     & cm         \\
!| $B_{o}$            & {\tt btor(jz)}       & T         \\
!| $q$                & {\tt q(jz)}          &           \\
!| $n_{e}$            & {\tt dense(jz)}      & m$^{-3}$  \\
!| $L_{ne}$           & {\tt slnes(jz)}      & cm         \\
!| $L_{ni}$           & {\tt slnis(jz)}      & cm         \\
!| $L_{p}$            & {\tt slprs(jz)}      & cm         \\
!| $L_{T_{e}}$        & {\tt sltes(jz)}      & cm         \\
!| $L_{T_{i}}$        & {\tt sltis(jz)}      & cm         \\
!| $T_{e}$            & {\tt tekev(jz)}      & keV        \\
!| $T_{i}$            & {\tt tikev(jz)}      & keV       \\
!| $Z_{eff}$          & {\tt xzeff(jz)}      &           \\
!| $\theta_{shear}$   & {\tt slbps(jz)}      &           \\
!| $C_{vp}^{e}$       & {\tt cthery(68)}     &           \\
!| $C_{vp}^{i}$       & {\tt cthery(69)}     &           \\
!| Center zone index        & {\tt maxis}    &       \\
!| First real zone index    & {\tt jzmin}    &       \\
!| Number of zones computed & {\tt medge}    &
!| \end{tabular}
!| \end{table}
!| 
!| 
!| \begin{table}
!| \begin{center}
!| \underline{Table 2.  Nominal Diffusivities}
!| 
!| \begin{tabular}{ll} &                                                       \\
!| $D_{eff}^{W}$       & $\equiv -\Gamma_{a}^{W}/(\partial n_{a}/\partial r)$  \\
!|                     & $=2E_{o}B_{o}^{-1}L_{ni}\epsilon^{3/2}q^{-1}
!|                        [1+(\nu_{e}^{*})^{1/2}+\nu_{e}^{*}]^{-1}$            \\
!|                     & \\
!| $D_{eff}^{P}$       & $\equiv -\Gamma_{I}^{P}/(\partial n_{I}/\partial r)$  \\
!|                     & $=4.02T_{i}^{3/2}B_{o}^{-2}R_{o}^{-1}qA_{i}^{1/2}
!|                        A_{I}^{1/2}Z_{I}^{-1}(1+1.5\eta_{i})\eta_{I}^{-1}$   \\
!|                     & \\
!| ${\hat D}$          & $\equiv \epsilon ^{1/2}\omega_{e}^{*}/k_{\perp}^{2}$  \\
!|          & $=10.8T_{e}^{3/2}B_{o}^{-2}L_{ni}^{-1}\epsilon^{1/2}A_{i}^{1/2}$ \\
!|       & $\omega_{e}^{*}/\nu_{eff}=10.1(\ln \lambda )^{-1}n_{20}^{-1}T_{e}^{2}
!|          L_{ni}^{-1}\epsilon A_{i}^{-1/2}Z_{eff}^{-1}$                       \\
!|                     & \\
!| ${\hat D}_{i}$      & $=15.2T_{e}T_{i}^{1/2}B_{o}^{-2}
!|                          R_{o}^{-1/2}L_{ni} ^{-1/2}
!|                          A_{i}^{1/2}\eta_{i}^{1/2}$                         \\
!|                     & \\
!| $D_{\nabla \eta}$   & $=3.16\times 10^{-4}(\ln \lambda )^{1/3}
!|                E_{o}^{4/3}n_{20}^{1/3}T_{i}^{-5/6}B_{o}^{-4/3}R_{o}^{2}r^{2/3}
!|                 L_{\sigma}^{-4/3}q^{2}A_{i}^{1/6}Z_{I}^{2/3}{\hat s}^{-2}$  \\
!|                     & \\
!| $\chi_{e}^{RB}$     & $\equiv -Q_{e}^{RB}/(n_{e}\partial T_{e}/\partial r)
!|                        =2.29\times 10^{-7}(\ln \lambda )^{3/2}\Lambda_{S}^{2}
!|                        (f_{*}^{-1}+1)^{-1/4}$                              \\
!|   & $\ \ \  n_{20}^{5/2}T_{e}^{-7/4}T_{i}^{-3/4}
!|    (T_{e}+T_{i})^{2}B_{o}^{-4}R_{o}^{3/2}
!|    L_{ni}^{1/2}L_{p}^{-3/2}q^{5}A_{i}^{1/4}Z_{eff}^{3/2}{\hat s}^{-3/2}$  \\
!|  & $\Lambda_{S} \ =9.70+0.98\log _{10}[(\ln \lambda )^{-1}
!|   n_{20}^{-1}T_{e}^{3/2}(T_{e}+T_{i})^{-1/2}
!|   B_{o}^{2}R_{o}A_{i}^{-1/2}Z_{eff}^{-1}]$                                 \\
!|  & $f_{*}^{-1}=3.27\times 10^{-11}(\ln \lambda )^{2}n_{20}^{2}T_{e}^{-3}
!|     T_{i}^{-3}(T_{e}+T_{i})^{2}L_{ni}^{2}q^{4}A_{i}^{-1}Z_{eff}^{2}$         \\
!|                     & \\
!| $D^{KB}$ & $=1.94T_{e}^{1/2}T_{i}B_{o}^{-2}L_{ni}^{-1}A_{i}^{1/2}f_{\beta th}
!|             (1+\beta '/\beta_{c1}')[1-\beta '/\beta_{c2}',0]_{max}$        \\
!|                     & \\
!| $\chi_{e,Md}$ & $=0.530n_{20}^{-1}T_{e}^{1/2}R_{o}^{-1}q^{-1}(1+\eta_{e})
!|                  \eta_{e}{\hat s}$                                         \\
!|                     & \\
!| $\chi_{RR}$ & $=5.97\times 10^{6}a^{2}T_{e}^{1/2}R_{o}^{-1}q^{-2}$        \\
!|   & $t_{rec}(U_{R}=.5)=1.88\times 10^{-2}(\ln \lambda )^{-1/2}n_{20}^{1/4}
!|      T_{e}^{3/4}B_{o}^{-1/2}R_{o}^{1/2}aA_{i}^{1/4}Z_{eff}^{-1/2}$
!| \end{tabular}
!| \end{center}
!| \end{table}
!| 
!| 
!| 
!| \begin{table}
!| \begin{center}
!| \underline{Table 3a-d.  Symbols for Variables Local to {\tt theory}}
!| 
!| \begin{tabular}{lllp{3.in}}
!|  & & & \\
!| \underline{Symbol} & \underline{Eq.} &    & \underline{Meaning} \\
!|  & & & \\
!| {\tt zai   } &    & $A_{i}$
!|                     & Average {\tt a}tomic mass of {\tt i}ons    \\
!| {\tt zb    } &    & $B_{0}$
!|                     & Toroidal {\tt B}-field                     \\
!| {\tt zbc1  } & 40 & $\beta_{c1}'$
!|                     & {\tt b}eta {\tt c}ritical gradient-{\tt 1} \\
!| {\tt zbc2  } & 58 & $\beta_{c2}'$
!|                     & {\tt b}eta {\tt c}ritical gradient-{\tt 2} \\
!| {\tt zbeta } &  3 & $\beta$
!|                     & {\tt beta}                                 \\
!| {\tt zbetap} &  9 & $\beta_{p}$
!|                     & {\tt beta} {\tt p}oloidal                  \\
!| {\tt zbpbc1} & 41 & $\beta '/\beta_{c1}'$
!|                     & {\tt b}eta {\tt p}rime/{\tt b}eta-{\tt c}rit-1' \\
!| {\tt zbprim} & 39 & $\beta '$
!|                     & {\tt b}eta {\tt prim}e                      \\
!| {\tt zcc   } &    & $c$
!|                     & speed of light {\tt c}onstant, {\tt c}      \\
!| {\tt zceps0 } &    & $\epsilon_{0}$
!|                     & {\tt c}onstant {\tt eps}ilon-{\tt 0}        \\
!| {\tt zcf   } &    &
!|                     & {\tt c}onstant for collision {\tt f}requencies \\
!| {\tt zckb  } &    & $k_{b}$
!|                     & {\tt c}onstant {\tt k}, {\tt B}oltzmann     \\
!| {\tt zcme  } &    & $m_{e}$
!|                     & {\tt c}onstant {\tt m}ass of {\tt e}lectron \\
!| {\tt zcmp  } &    & $m_{p}$
!|                     & {\tt c}onstant {\tt m}ass of {\tt p}roton   \\
!| {\tt zcmu0 } &    & $\mu_{0}$
!|                     & {\tt c}onstant {\tt mu}-{\tt 0}             \\
!| {\tt zdd   } & 42 & $D^{DR}$
!|                     & nominal {\tt d}iffusivity for {\tt d}rift modes \\
!| {\tt zddtem(jz)} & 43 & $D_{a}^{DR}$
!|                     & {\tt d}iffusivity for {\tt dr}ift modes     \\
!| {\tt zdi   } & 37 & ${\hat D}_{i}$
!|                     & {\tt d}iffusivity for eta-{\tt i} mode      \\
!| {\tt zdiafr} & 34 & $\omega_{e}^{*}$
!|                     & {\tt dia}magnetic drift {\tt f}requency    \\
!| {\tt zdgret} & 47 & $D_{\nabla \eta}$
!|                     & {\tt d}iffusivity due to {\tt g}radient of {\tt et}a \\
!| {\tt zdhf  } & 68 & $D_{a}^{HF}$
!|                     & {\tt d}iffusivity, {\tt h}igh {\tt f}requency mode \\
!| {\tt zdk   } & 60 & $D^{KB}$
!|                 & nominal {\tt d}iffusivity, {\tt k}inetic {\tt b}allooning \\
!| {\tt zdkb  } & 61 & $D^{KB}_{a}$
!|                     & {\tt d}iffusivity, {\tt k}inetic {\tt b}allooning \\
!| {\tt zdrm  } & 48 & $D^{RM}_{a}$
!|                     & {\tt d}iffusivity, {\tt r}ippling {\tt m}ode \\
!| {\tt zdrb  } & 55 & $D^{RB}_{a}$
!|                     & {\tt d}iffusivity, {\tt r}esitive {\tt b}allooning \\
!| {\tt zdsum } & 71 & $D_{a}$
!|                     & {\tt d}iffusivity {\tt s}um                \\
!| {\tt zdte  } & 38 & ${\hat D}_{te}$
!|                     & {\tt d}iffusivity, {\tt t}rapped {\tt e}lectron mode
!| \end{tabular}
!| \end{center}
!| \end{table}
!| 
!| \end{document}
!| 
!| \begin{table}
!| \begin{center}
!| \underline{Table 4. Control Parameters in {\tt Theory}}
!| 
!| \begin{tabular}{llcp{3.0in}}
!| & & & \\
!| \underline{Parameter}&\underline{Coding}&\underline{Default}
!| &\underline{Meaning}\\
!| & & & \\
!| 
!| $F_{a}^{DR}$&${\tt fdr(1)}$ & 0.0 & particle contribution to drift wave mode\\
!| $F_{e}^{DR}$&${\tt fdr(2)}$ & 0.0 & electron contribution to drift wave mode
!| \\
!| $F_{i}^{DR}$&${\tt fdr(3)}$ & 0.0 & ion contribution to drift wave mode \\
!| $F_{\Delta}^{DR}$&${\tt fdrint}  $ & 0.0 & electron-ion energy interchange
!| coeff. \\
!| $F_{a}^{RM}$&${\tt frm(1)}  $ & 0.0 & particle contribution to rippling mode\\
!| $F_{e}^{RM}$&${\tt frm(2)}  $ & 0.0 & electron contribution to rippling mode\\
!| $F_{i}^{RM}$&${\tt frm(3)}  $ & 0.0 & ion contribution to rippling mode\\
!| $F_{a}^{RB}$&${\tt frb(1)}  $ & 0.0 & particle contribution to res. ball.
!| mode\\
!| $F_{e}^{RB}$&${\tt frb(2)}  $ & 0.0 & electron contribution to res. ball.
!| mode\\
!| $F_{i}^{RB}$&${\tt frb(3)}  $ & 0.0 & ion contribution to res. ball. mode\\
!| $F_{a}^{KB}$&${\tt fkb(1)}  $ & 0.0 & particle contribution to kin. ball.
!| mode\\
!| $F_{e}^{KB}$&${\tt fkb(2)}  $ & 0.0 & electron contribution to kin. ball.
!| mode\\
!| $F_{i}^{KB}$&${\tt fkb(3)}  $ & 0.0 & ion contribution to kin. ball. mode\\
!| $F_{a}^{HF}$&${\tt fhf(1)}  $ & 0.0 & particle contribution to $\eta_{e}$
!| mode\\
!| $F_{e}^{HF}$&${\tt fhf(2)}  $ & 0.0 & electron contribution to $\eta_{e}$
!| mode\\
!| $F_{i}^{HF}$&${\tt fhf(3)}  $ & 0.0 & ion contribution to $\eta_{e}$ mode\\
!| $c_{1}$&${\tt cthery(1)}$ & 0.0 & shear switch\\
!| $c_{2}$&${\tt cthery(2)}$ & 1.0 & shear parameter\\
!| $c_{3}$&${\tt cthery(3)}$ & 0.5 & minimum shear \\
!| $c_{4}$&${\tt cthery(4)}$ & 0.0 & gradient of Z-effective\\
!| $c_{5}$&${\tt cthery(5)}$ & 6.0 & impurity charge\\
!| $c_{6}$&${\tt cthery(6)}$ & 1.0 & switch to turn on or off $f_{ith}$\\
!| $c_{7}$&${\tt cthery(7)}$ & 6.0 & controls the smoothing of $f_{ith}$ \\
!| $c_{8}$&${\tt cthery(8)}$ & 6.0 & controls the smoothing of $f_{bth}$ \\
!| $c_{9}$&${\tt cthery(9)}$ & 6.0 & controls the smoothing of $f_{eth}$ \\
!| $c_{10}$&${\tt cthery(10)}$& 0.0 & switch for $f_{*}$ in res. ball. model\\
!| $c_{11}$&${\tt cthery(11)}$& 1.0 & sets the value of $\eta_{i}^{th}$\\
!| $c_{12-15}$&${\tt cthery(12-15)}$&0's & elongation parameters\\
!|  & & &
!| \end{tabular}
!| \end{center}
!| \end{table}
!| 
!| %**********************************************************************c
!| 
!| The following abreviations are used in the chronology of changes below:
!| \begin{center}
!| \begin{tabular}{lll}
!|     &               &             \\
!| \underline{Abbreviation} & \underline{Name} & \underline{Affiliation}\\
!| rgb & Glenn Bateman & PPPL \\
!| pis & P{\"a}r Strand & Chalmers \\
!| jcc & J.~C. Cummings & PPPL \\
!| emg & E.~S. Ghanem  & U. Illinois \\
!| jek & Jon Kinsey    & Lehigh Univ. \\
!| ajr & Aaron J.~Redd & Lehigh Univ. \\
!| mhr & Martha Redi   & PPPL \\
!| ces & C.~E. Singer  & U. Illinois \\
!| dps & D.~P. Stotler & PPPL \\
!| \end{tabular}
!| \end{center}
!| 
c--------1---------2---------3---------4---------5---------6---------7-c
c@theory   .../baldur/code/bald/theory.tex
c  pis 16-jul-98 added cthery(129) as multiplier to wexbs
c  pis 16-jul-98 added cthery(130) as multiplier to impurity heat flux
c  pis 07-jul-98 added diagnostics for wexb
c  pis 07-jul-98 corrected def of omegde(jz) and moved it to before etaw17
c  pis 15-may-98 added ExB shearing rate (wexbs) to argument list
c  pis 15-may-98 replaced etaw17 with etaw17diff, order of diagnostic
c    output have been changed
c  pis 15-may-98 switches pertaining to choice of eigensolvers obsolete
c    with introduction of etaw17 i.e. iletai(6) and iletai(10)
c  pis 14-may-98 etaw16 replaced by etaw17 using non-proprietary solvers
c    for generalized eigenvalue equation, allowing for ExB shearing rate
c    reduction of growthrates
c  rgb 30-mar-98 diagnostic output added for drift Alfven mode
c    controlled by cthery(88)
c  rgb 02-mar-98 call sda01dif for Bruce Scott's Drift Alfven model
c    added zelong to diagnostic output
c  rgb 24-feb-98 etaw14 --> etaw16, cetain(25) = cthery(122),
c    zelong added to argumentl list of etaw16
c  rgb 25-feb-97 print zgmitg, zomitg, zgm2nd, zom2nd, zgmtem, zomtem
c    zomegde, zomegse, zkinvsq
c  rgb 21-nov-96 lprint .gt. 0 turns on diagnostic printout from etaw..
c  rgb 06-nov-96 cthery(126) > zepslon controls zftrap for etaw14
c    cthery(126) < zepslon multiplies zftrap * abs(cthery(126))
c  ajr 01-oct-96 added Ottoviani-Horton-Erba eta_i model
c  rgb 13-sep-96 cthery(85) --> nint(cther(85)
c  rgb 01-jul-96 force zero gradients to round up
c  rgb 21-feb-96 revised printout for kinetic ballooning mode
c  rgb 14-feb-96 smooth the relative superthermal ion density
c    if lthery(19) > 0
c  rgb 13-feb-96 etaw12 --> etaw14  and changed order of arguments
c    zgnh, zgnz, zgns --> zgne, zgnh, zgnz
c  rgb 12-feb-96 zgrdns = ....  / max ( zfnsne, 1.e-6 )
c    zgrdns may be 0.0 and remove zepsns
c  rgb 05-feb-96 lthery(26) timestep for diagnostic printout for etaw*
c     remove use of cthery(125) for this purpose
c  rgb 21-jan-96 corrected zovfkb = max(zexkb,-abs(zlgeps)) ...
c    fixed zdk = abs( zsound * zrhos**2 * zfbthn / zlpr )
c  jek 18-jan-96 added new kinetic ballooning mode model
c  jek 08-dec-95 use etaw12.f for Weiland ITG/TEM model
c  jek 02-dec-95 added Guzdar-Drake resistive ballooning model
c                and added diagnostic printout
c  rgb 07-may-95 change zlmin from 1.e-6 to 1.e-4 because units for
c    minor radius were changed from cm to m
c  rgb 06-may-95 skip directly to printout if lprint < 0
c  rgb 15-apr-95 replace cpvelc -> cthery(68), cpvion -> cthery(69)
c    diagnostic ouput controlled by lprint
c  rgb 11-apr-95 common blocks -> argument list
c  rgb 07-jan-95 Inserted elongation factor into Weiland and Horton etai
c  rgb 19-oct-94 Smooth reciprocals of gradient scale lengths when
c    lthery(32) < 0 and gradient scale lengths when lthery(32) > 0
c    added Z_eff to profiles as a function of major radius
c  rgb 07-oct-94 No kinetic ballooning mode it zlpr < 0.0
c  rgb 15-jul-94 revised computation of zepsns
c  rgb 14-jul-94 compute zfnsne directly from fast particle densities
c    had to include 'cd3he.m' for rh1fst and rh2fst
c  rgb 29-jun-94 replace negative diffusivities with convective
c    velocity when lthery(27) > 0
c  rgb 25-jun-94 temporary diagnostic output
c  rgb 20-jun-94 include maxis + 1 in printout of profiles as a
c    function of major radius
c  rgb 04-jun-94 implement cthery(111) to cthery(114) to transfer from
c    diffusivity matrix to convective velocity
c  rgb 25-may-94 implemented sbrtn etawn8 with superthermal ions
c    correctly set zlnz from zslnz
c  rgb 09-may-94 entry prtheory added
c  rgb 25-apr-94 compute zlnz directly and limit zlnh and zlnz
c  rgb 02-apr-94 print out fluxes and sources as well as vftot
c  rgb 25-mar-94 compute effective convective velocities and print out
c  rgb 20-mar-94 print neoclassical and empirical diffusivity columns
c  rgb 06-mar-94 compute zslnh(jz) = n_H / ( d n_H / dr )
c  rgb 25-feb-94 smooth diffusivities if lthery(28) > 0
c    fixed smoothing when cthery(60) or cthery(61) > 0.0
c  rgb 22-feb-94 diagnostic printout if iprint > 0
c  rgb 02-feb-94 when lthery(8) > 20, use effective diffusivities
c    and set the diffusivity matrix to zero
c  rgb 29-jan-94 compute difthi and velthi from sbrtn etawn7
c  rgb 11-jan-94 always print out gradient scale lengths
c  rgb 06-jan-94 Use IMSL rather than NAG14 routine in sbrtn etawn6
c  rgb 02-jan-94 set zimpz = max ( zimpz, cthery(120) )
c    set iprint = lthery(29) - 10 before calling etawn6
c  rgb 29-nov-93 Use lthery(29) to limit diagnostic printout
c    print out hydrogen particle diffusivities
c    print out effective eta_i mode diffusivities next to matrix
c    set zcetai(32) = cthery(128)
c  rgb 23-nov-93 Print out diffusivity matrix from Weiland model
c    set zcetai(32) = cthery(39)  or = 1.e-6 if cthery(39) < zepslon
c  rgb 22-nov-93 protected etae mode from overflow
c    control etae mode using lthery(20)
c  rgb 21-nov-93 changed zcetai(32) from sqrt(zepslon) to 1.e-6
c    fixed computation of difthi, zgmitg, and zgmtem
c    skip trapped electron mode models if lthery(6) < 0
c  rgb 07-nov-93 set zcetai(32) = sqrt ( zepslon )
c  jek 25-jun-92 added circ-electron and high-m tearing models
c  rgb 04-sep-93 implement sbrtn etawn6 to compute Weiland model
c    with the effect of impurities, trapped electrons and FLR effects
c  jek 04-sep-93 corrections to the Carreras-Diamond resistive
c    ballooning mode based on comments by Dave Ross
c  rgb 20-feb-93 replaced zlne with zln for Nordman-Weiland model
c  rgb 20-feb-93 print out profiles as a function of major radius
c  rgb 18-feb-93 print out effective particle diffisivities
c  rgb 10-feb-93 implemented matrix form of Nordman-Weiland Model
c  rgb 11-nov-92 corrected switch between thdre and thdri since 20-sep-92
c  rgb 06-nov-92 implement control by cthery(38) and cthery(39)
c     for the Kim-Horton eta_i mode model
c  rgb 02-nov-92 compute diffusivity from Kim-Horton eta_i mode model
c  rgb 28-oct-92 Revised Nordman-Weiland model by combining eta_i and
c     TEM modes and normalizing frequencies by omega_{De}
c  rgb 22-sep-92 inserted abs(...) to deal with negative zl** values
c  rgb 21-sep-92 retain sign of gradient scale lengths when lthery(30)=1
c  rgb 20-sep-92 limit local change in TEM modes when cthery(61) .gt. 0.
c    Remove old use of cthery(61) and cthery(62)
c  rgb 17-sep-92 k_y \rho_s = cthery(38) or 0.316
c  rgb 14-sep-92 Weiland-Nordman NF 30 (1990) 983 \eta_i mode model
c  rgb 01-apr-92 neoclassical MHD toroidal mode number  cthery(77)
c  rgb 30-mar-92 use \nu_{ii} rather than \nu_{ei} in \nu_{*i}
c    There have been many revisions to the neoclassical MHD model
c  rgb 26-mar-92 neoclassical MHD proper conversion to MKS units
c  rgb 25-mar-92 print out zalphz(jz),...,zfdiaz(jz)
c  rgb 24-mar-92 lthery(15)=1 for original neoclassical MHD, =2 revised
c  rgb 20-mar-92 corrections to neoclassical MHD
c  rgb 19-mar-92 temporary arrays to debug neoclassical MHD
c  rgb 17-mar-92 revised Rebut-Lallia-Watkins model PF B 3 (1991) 2209
c  rgb 16-mar-92 implemented ExB part of neoclassical MHD for particle
c    and ion thermal diffusivity controlled by fmh(1) and fmh(3)
c  Note:  fmh(j) is used for the coefficients of neoclassical MHD
c    because fnm(j) is already used in common block adsdat in file comadp.m
c  rgb 16-feb-92 replace nusti(jz) (from Kinsey) by znusti (scalar)
c  rgb 14-feb-92 eta_i mode times q(jz)**cthery(37)
c    cthery(45)=1.0 to correct resistive ballooning mode diffusivity to
c      more closely match the analytic solution
c  rgb 13-feb-92 changed lthery(33) to lthery(15) for neoclassical MHD mode
c  jek 16-nov-91 20.05  added neoclassical MHD mode
c  rgb 17-oct-91 20.17  multiply trapped electron mode contributions
c      by exp[-cthery(22)*(Ti/Te-1)**2]
c  rgb 18-jul-91 20.02  let zetai=zlnj/zlti and use zlnj in etai-mode forms
c      where zlnj=zlne if lthery(3).lt.1, else zlnj=zlni
c      and   zln =zlne if lthery(3).lt.2, else zln =zlni
c      Also, changes made to weithe(jz)
c  rgb 10-jun-91 19.09  implemented changes from Martha Redi and J. Cummings
c      but decided to keep zetai=zln/zlti with zln determined by lthery(3)
c      that is, zln=zlne if lthery(3).eq.0 and zln=zlni if lthery(3).ne.0
c  jcc 01-mar-91 19.08  replace term removed in version 19.07 and add two
c                       new trapped electron mode theory options.  if
c                       lthery(6)=7, use Hahm-Tang CTEM with Rewoldt
c                       transition to dissipative regime.  if lthery(6)=8,
c                       use Hahm-Tang CTEM and Kadomtsev-Pogutse DTEM.
c  jcc 26-feb-91 19.07  remove {sqrt[zrmaj/zln]-log[sqrt(zrmaj/zln)]-1}
c                       from Hahm-Tang formula for zdte to see if it is the
c                       cause of crashes with high q, low beam power cases.
c  jcc 18-feb-91 19.06  made zetai equal zlni/zlti instead of zln/zlti,
c                       and used zlne explicitly in definitions of
c                       zetae and zdiafr.
c  jcc 04-feb-91 19.05  add separate printout of Bohm and gyro-Bohm
c                       contributions to electron thermal diffusivity
c                       compile all routines with cft77.
c  jcc 04-feb-91 separate gyro-Bohm and Bohm contributions to thrbe
c                they are labeled thrbgb and thrbb, respectively.
c  jcc 28-jan-91 19.04  change dbeams to give proper balanced injection.
c  jcc 19-sep-90 19.03  made lthery(6)=4 a Hahm-Tang CTEM only option
c  jcc 17-sep-90 19.02  added complementary Hahm-Tang DTEM model
c                       for nu-star > 0.1
c  jcc 05-aug-90 19.01  fixed errors in separation of particle and heat
c                       fluxes due to trapped electron modes from those
c                       due to eta-i modes, eliminated possible double-
c                       counting of contributions.
c  jcc 04-aug-90 19.00  consolidated MMM, Rewoldt transition, Hahm-Tang
c                       CTEM model and Kadomtsev-Pogutse DTEM model.
c                       Also adding diagnostic for validity of Hahm-Tang.
c  jcc 20-jul-90 18.4601  added Hahm, Tang CTEM model (IAEA 1990).
c  rgb 05-may-91 18.88  add Rebut-Lallia-Watkins model after $\eta_e$ mode
c  rgb 26-dec-90 18.81  go back to cft77 compiler
c  rgb 12-oct-90 18.72  limit \chi^{ITG} with 2nd and 4th differences
c  rgb 05-oct-90 18.71  limit local rate of change only for eta_i mode
c  rgb 05-oct-90 18.70  skip straight to printout when knthe = 3
c  rgb 04-oct-90 18.69  when cthery(60) .gt. zepslon, limit the rate of
c      change of diffusivities relative to their average rate of change
c  rgb 02-oct-90 18.68  lthery(31)=1  r * (gradient scale lengths)
c      monotonic near the magnetic axis by changing value at jz=maxis+1
c  rgb 20-sep-90 18.66  exp[-min(5 L_n, 4 L_T) / L_s] in Hamaguchi-Horton
c  rgb 14-sep-90 18.64  Revised Hahm-Tang TEM model and
c      always compute zdiafr using the electron density zlne
c  rgb 12-sep-90 18.63  Revised precond and smoothing grad scale lengths
c  rgb 10-sep-90 18.62  Diagnostic output for the Hahm-Tang when lthery(5)=1
c  rgb 05-sep-90 18.61  Hahm-Tang trapped electron mode when lthery(5)=1
c  rgb 03-sep-90 18.60  use (1+\kappa^2)/2 instead of \kappa if lthery(12)=1
c  rgb 20-aug-90 18.54  minor changes to output
c  rgb 30-jul-90 18.51  precondition gradient scale lengts before smoothing
c  rgb 19-jul-90 18.49  Allow smoothing directly on gradient scale lengths
c    changes to argument list in calls to sbrtn smooth
c  rgb 15-jul-90 18.48  Hamaguchi-Horton eta_i mode, first attempt
c  rgb 12-jul-90 18.47  Dominguez-Rosenbluth \eta_i^{th}
c  rgb 05-may-90 18.32  exp[-cthery(34)*(Ti/Te-1)**2] factor
c      multiplying the eta_i mode (IG) in all models
c        Place upper bound on scale lengths relative to major radius
c      controlled by cthery(50...) when these coefficients are positive
c  rgb 16-apr-90 replaced zspres with zresis throughout
c      lthery(4) controls type of resistivity used throughout
c      store zresis in array zrsist(jz) and print out
c  rgb 10-apr-90 removed eta_i contribution from drift wave particle diff
c  rgb 09-apr-90 thrbe(jz)=...+cthery(44)*zxrb*zfdias
c  rgb 20-mar-90 compute and use ion density scale length slnis(jz)
c      if lthery(3)=0 zln = zlne, else zln = zlni
c      zlne replaced by zln almost everywhere
c      collect formatted output from file DIO all together
c  rgb 16-mar-90 Lee-Diamond eta_i mode theory when lthery(7)=1
c  rgb 09-mar-90 input fig(j) for eta_i and fti(j) for trapped ion
c      separate sections and columns of output for eta_i and trapped ion
c  rgb 17-feb-90 linear ramp form for f_ith when lthery(9=2
c  rgb 16-feb-90 add cthery(44)*D^{RB} to \chi_e^{RB}
c  rgb 15-feb-90 implemented diamagnetic stabilization of new resistive
c      ballooning mode using cthery(42) and cthery(43)
c    extrapolate diffusivities to edge grid point when lthery(2)=1
c  rgb 08-feb-90 implemented variables in common /comth3/
c      added new page and rearranged printout
c  rgb 03-feb-90 Mattor-Diamond, Hahm-Tang \eta_i^{th} when lthery(8)=1
c      Hahm-Diamond... estimate for \chi_e^{RM} when lthery(11)=1
c  rgb 01-feb-90 revised form for f_{ith} when lthery(9)=1
c  rgb 30-jan-90 Rewoldt's transition controlled by lthery(6)=1
c  rgb 29-jan-90 Implemented Greg Rewoldt's suggestion for transition from
c      dissipative to collisionless trapped electron mode in \hat{D}_{te}
c  rgb 28-jan-90 Carreras-Diamond resistive ballooning mode
c      PF B1 (1989) 1011-1017
c  rgb 15-jan-90 zlpr corrected and shear(jz) used to compute shear
c      These changes restore the code to what it was the last half of 1989
c  rgb 12-jan-90 zs1,...,zs20 replaced by zs(js), js=1,128
c      zs(js)=ctheory(js)
c  rgb 28-nov-89 moved dimension zx... to common /comth2/ th...
c  rgb 27-oct-89 cthery(19) coefficient of f_ith added to 5/2 in
c      drift wave electron thermal diffusivity (default = -1.5)
c  emg 04-oct-89 fix a bug in the expression of zetith,eq. 34. switch
c                the 1. into zs11
c  emg 29-sep-89 convert zetith,zfith,zdi,zdte into arrays and
c                add printout commands to printthem in BALDUR's
c                long output.
c  rgb 09-oct-89 cthery(17) controls subtraction of convective flux
c     to correct thermal flux (CPP Eq. 73 and 74)
c   cthery(20) (default=1.0) controls transition in CPP Eq. 37
c  rgb 03-oct-89 add diagnostic output of threti(j),thdinu(j),...
c     new page of printout
c    Moved computation of values at r=0 after 300 continue
c  ces 25-jul-89 add numerical overflow protection to zlpr
c  ces 25-jul-89 add variable eta-i-crit
c  rgb 13-jun-89 removed zt and zdt from argument list
c     and defined zt znd zdt just before do 400
c  rgb 09-jun-89 use civic with lang=cft rather than cft77 compiler
c  emg 20-apr-89 change the energy interchange name from 'eithes' to
c               'weithe' to be compatable with other sources names
c                and add the new name into the same common block
c  emg 09-mar-89 add cthery to 'fstar' in the resistive
c                ballooning model with default 0.0
c  emg 03-mar-89 add the print commands for the detailed diffusion
c                coefficients.
c  emg 26-feb-89 correct the expression for the pressure scale
c                length, zlpr.
c  emg 16-feb-89 correct the expression for the shear in
c                equation (23)
c  emg 19-dec-88 15.06 add the overflow protection for
c                the exponential terms
c  emg 07-dec-88 15.06 change the constants in exponents
c                into cthery's
c  dps 20-oct-88 15.06 added to BALDPN S, V.15.06.
c  ces 17-oct-88 correct parentheses in statement 25, zsdiv=...
c  emg 11-oct-88 finish first standard version for shipping to PPPL
c  emg 23-jun-88 subroutine set up
c
c***********************************************************************
!| 
!| \end{document}              0.000000E+00nd of document.
