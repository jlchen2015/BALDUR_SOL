!| %---:----1----:----2----:----3----:----4----:----5----:----6----:----7-c
!| 
!| \documentstyle[12pt]{article}
!| \headheight 0pt \headsep 0pt
!| \topmargin 0pt  \textheight 9.0 in
!| \oddsidemargin 0pt \textwidth 6.5 in
!| 
!| \newcommand{\Partial}[2]{\frac{\partial #1}{\partial #2}}
!| \newcommand{\jacobian}{{\cal J}}
!| 
!| \begin{document}
!| 
!| \begin{center}
!| \large {\bf Drift Alfv\'{e}n Transport Model} \\
!| \normalsize  {\tt sda02flx.tex} \\
!| \vspace{1pc}
!| Bruce Scott \\
!| Max Plansk stitut f\"{u}r Plasmaphysik \\
!| Euratom Association \\
!| D-85748 Garchg, Germany \\
!| \vspace{1pc}
!| Glenn Bateman \\
!| Lehigh University, Physics Department \\
!| 16 Memorial Drive East, Bethlehem, PA 18015 \\
!| \vspace{1pc}
!| \today
!| \end{center}
!| 
!| This subroute computes the transport fluxes driven by
!| drift Alfv\'{e}n turbulence usg a model based on
!| simulations by Bruce Scott.
!| 
!| The following expressions are based on data sent on 13 Feb 98:
!| 
!| \begin{eqnarray*}
!| Q_i
!|  & = & 26.0 n_e T_e c_s ( \rho_s / R )^2 ( 200 / 3 )^2
!|       ( 4000 \beta_e ) \left( \frac{ q R }{ 200 L_{p} } \right)^2
!|       \left| \frac{ 3 R }{ 200 L_p } \right|^{\rm cswitch(1)}  \\
!|  & & \times \left[ 0.12
!|  + 0.82 \left( \frac{ 2 T_h d ( n_h ) }{ d ( n_h T_h ) } \right)
!|  + 0.06 \left( \frac{ 2 T_h d ( n_h ) }{ d ( n_h T_h ) } \right)^2
!|       \right] \\
!|  & & \times \exp [ -3.1236 ( \kappa - 1 ) ]
!| \end{eqnarray*}
!| 
!| \begin{eqnarray*}
!| Q_e
!|  & = & 22.8 n_e T_e c_s ( \rho_s / R )^2 ( 200 / 3 )^2
!|       ( 4000 \beta_e ) \left( \frac{ q R }{ 200 L_{p} } \right)^2
!|       \left| \frac{ 3 R }{ 200 L_p } \right|^{\rm cswitch(1)}  \\
!|  & &  \times \left[ 0.3
!|  + 0.4 \left( \frac{ 2 T_e d ( n_e ) }{ d ( n_e T_e ) } \right)
!|  + 0.3 \left( \frac{ 2 T_e d ( n_e ) }{ d ( n_e T_e ) } \right)^2
!|       \right] \\
!|  & & \times \exp [ -3.1236 ( \kappa - 1 ) ]
!| \end{eqnarray*}
!| 
!| \begin{eqnarray*}
!| \Gamma_n
!|  & = & 8.71 n_e c_s ( \rho_s / R )^2 ( 200 / 3 )^2
!|       ( 4000 \beta_e ) \left( \frac{ q R }{ 200 L_{p} } \right)^2
!|       \left| \frac{ 3 R }{ 200 L_p } \right|^{\rm cswitch(1)}  \\
!|  & &  \times \left[ 0.032
!|  - 0.065 \left( \frac{ 2 T_h d ( n_h ) }{ d ( n_h T_h ) } \right)
!|  + 1.033 \left( \frac{ 2 T_h d ( n_h ) }{ d ( n_h T_h ) } \right)^2
!|       \right] \\
!|  & & \times \exp [ -3.1236 ( \kappa - 1 ) ]
!| \end{eqnarray*}
!| 
!| 	The heat fluxes computed in this subroutine are normalized by
!| $ n_e T_e c_s ( \rho_s / R )^2 $ and the particle fluxes are
!| normalized by $ n_e c_s ( \rho_s / R )^2 $.
!| 
!| 	It is assumed that these fluxes are
!| proportional to the pressure
!| gradient squared, for constant $ T_e d ( n_e ) / d ( n_e T_e ) $
!| and that the presure gradient driving this mode includes
!| both electrons and thermal ions:
!| \[ \frac{ R }{ L_p } = \frac{ R }{ n_e T_e + n_i T_i }
!|   \frac{ d ( n_e T_e + n_i T_i ) }{ d r } \]
!| 
!| 	Also, It is assumed that the data sent on 13 Feb 98 was
!| for a baseline case of a plasma with circular cross section
!| (ie, $ \kappa = 1 $).
!| 
!| 	The other baseline parameters are:  $ q = 3.0 $,
!| $ q R / L_{pe} = 200.0 $, $ 2 T_e d ( n_e ) / d ( n_e T_e ) = 1.0 $,
!| and $ 4000 \beta_e = 1.0 $, where $ M_i / m_e = 4000 $,
!| and $ \hat{\nu} = 0.3 $.
!| For these baseline values, the fluxes are:
!| $ Q_i / ( n_e T_e c_s ) = 26 $,
!| $ Q_e / ( n_e T_e c_s ) = 22.8 $, and
!| $ \Gamma_n / ( n_e c_s ) = 8.71$.
!| 
!| 	The data for as a function of ratios of gradients
!| ($ 2 T_e d ( n_e ) / d ( n_e T_e ) $) was fit to a quadratic
!| polynomial using three data points and then rounding off the
!| coefficients.
!| 
!| 	For the $ \beta_e $ dependence, it was found that the ratio
!| of polynomials with the form
!| $ ( 1 + a_1 \beta_e^4 ) / ( 1 + a_2 \beta_e^4 ) $
!| reproduces the S-curve of the data reasonably well.
!| 
!| 	The linear dependence in the collisionality $ \hat{ \nu } $
!| is a crude approximation to the scatter of that data.
!| 
!| 	It was found that $ \exp [ -3.1236 ( \kappa - 1 ) ] $
!| fit the data better than a power scaling for elongation $ \kappa $.
!| 
c@sda02flx
c rgb 26-feb-98 first draft
c---:----1----:----2----:----3----:----4----:----5----:----6----:----7-c
c
      subroutine sda02flx (lswitch, cswitch, lprint, nout
     & , gne, gnh, gnz
     & , gte, gth, gtz, th7te, tz7te
     & , fracnz, chargenz, amassz, fracns, chargens
     & , betae, vef, q, shear, kappa
     & , fluxth, fluxnh, fluxte, fluxnz, fluxtz
     & , nerr )
c
c    input:
c
c  lswitch(j), j=1,32  integer switches
c  cswitch(j), j=1,32  real-valued switches
c  lprint    controls amount of printout
c  nout      output unit
c
c  gne      = - R ( d n_e / d r ) / n_e  electron density gradient
c  gnh      = - R ( d n_H / d r ) / n_H  hydrogen density gradient
c  gnz      = - R ( d n_Z / d r ) / n_Z  impurity density gradient
c  gte      = - R ( d T_e / d r ) / T_e  electron temperature gradient
c  gth      = - R ( d T_H / d r ) / T_H  hydrogen temperature gradient
c  gtz      = - R ( d T_Z / d r ) / T_Z  impurity temperature gradient
c  th7te    = T_H / T_e  ratio of hydrogen to electron temperature
c  tz7te    = T_Z / T_e  ratio of impurity to electron temperature
c  fracnz   = n_Z / n_e  ratio of impurity to electron density
c  chargenz = average charge of impurity ions
c  amassh   = average mass of hydrogen ions (in AMU)
c  amassz   = average mass of impurity (in AMU)
c  fracns   = n_s / n_e  ratio of fast ion to electron density
c  chargens = average charge of fast ions
c  betae    = n_e T_e / ( B^2 / 2 mu_o )
c  vef      = collisionality
c  q        = magnetic q value
c  shear    = r ( d q / d r ) / q
c  kappa    = elongation
c
c    output:
c
c  fluxth   = radial velocity of hydrogenic heat / ( n_e T_e c_s )
c  fluxnh   = radial velocity of hydrogenic ions / ( n_e c_s )
c  fluxte   = radial velocity of electron heat / ( n_e T_e c_s )
c  fluxnz   = radial velocity of impurity ions / ( n_e c_s )
c  fluxtz   = radial velocity of impurity heat / ( n_e T_e c_s )
c  nerr     = output error condition
c
      implicit none
c
      integer lswitch(*), lprint, nout, nerr
c
      real cswitch(*)
     & , gne, gnh, gnz
     & , gte, gth, gtz, th7te, tz7te
     & , fracnz, chargenz, amassz, fracns, chargens
     & , betae, vef, q, shear, kappa
     & , fluxth, fluxnh, fluxte, fluxnz, fluxtz
c
      real zero, zone, zhalf
c
c  zone  = 1.0
c  zhalf = 1.0 / 2
c
      real zcoefth, zcoefnh, zcoefte, zcoefnz, zcoeftz, zscale
c
      real zp1, zb1, zb2, znu1, znu2, zkappa1
     &  , zwth1, zwth2, zwth3
     &  , zwnh1, zwnh2, zwnh3
     &  , zwte1, zwte2, zwte3
     &  , zwnz1, zwnz2, zwnz3
     &  , zwtz1, zwtz2, zwtz3
c
c  coefficients used in computing fluxes
c
c  zp1   = 200
c  zb1   = 137.3
c  zb2   = 9.1
c  znu1  = 1.099
c  znu2  = 0.33
c
      real zfracnh, zgp, zgph, zgpe, zbmh7me
     &  , zfactor, zfactorh, zfactore
c
c  zfracnh = n_H / n_e
c  zgp   = - R ( d pth / d r ) / pth
c    where pth = n_e T_e + n_H T_H + n_Z T_Z
c  zgph  = - R [ d ( n_h T_h ) / d r ] / ( n_h T_h )
c  zgpe  = - R [ d ( n_e T_e ) / d r ] / ( n_e T_e )
c  zbmh7me = 4000 * betae
c    where 4000 was used for M_H / m_e in Scott's simulations
c  zfactor = common factor used in all the fluxes
c
      zero  = 0
      zone  = 1
      zhalf = zone / 2
c
c  coefficients used in computing fluxes
c
      zcoefth = 26.0
      zcoefnh = 8.71
      zcoefte = 22.8
      zcoefnz = zero
      zcoeftz = zero
c
c  zscale is ( R / L_p )**2 at the reference point (200./3.)**3
c
      zscale  = ( 200.0 / 3.0 )**2
c
      zp1   = 200
c
      zwth1 = 0.12
      zwth2 = 0.82
      zwth3 = zone - zwth1 - zwth2
c
      zwnh1 = 0.032
      zwnh2 = - 0.065
      zwnh3 = zone - zwnh1 - zwnh2
c
      zwte1 = 0.3
      zwte2 = 0.4
      zwte3 = zone - zwte1 - zwte2
c
      zwnz1 = zone
      zwnz2 = zero
      zwnz3 = zone - zwnz1 - zwnz2
c
      zwtz1 = zone
      zwtz2 = zero
      zwtz3 = zone - zwtz1 - zwtz2
c
      zb1   = 137.3
      zb2   = 9.1
c
      znu1  = 1.099
      znu2  = 0.33
c
      zkappa1 = 3.1236
c
c  compute zfracnh from charge neutrality
c
      zfracnh = zone - chargenz * fracnz - chargens * fracns
c
      if ( zfracnh .lt. zero ) then
        zfracnh = zero
        nerr = 2
      endif
c
      zgp = zhalf * ( gne + gte
     &  + zfracnh * th7te * ( gnh + gth )
     &  + fracnz  * tz7te * ( gnz + gtz ) )
     &  / ( zone + zfracnh * th7te + fracnz * tz7te )
c
      zgph = zhalf * ( gnh + gth )
      zgpe = zhalf * ( gne + gte )
c
      zbmh7me = 4000 * betae
c
c..compute fluxes
c
      zfactor = zscale * ( q / zp1 )**2
     &  * exp( - zkappa1 * ( kappa - zone ) )
c
      if ( cswitch(1) .gt. zero ) then
        zfactorh = zfactor * ( abs ( 3.0 * zgph / 200. ) )**cswitch(1)
        zfactore = zfactor * ( abs ( 3.0 * zgpe / 200. ) )**cswitch(1)
      else
        zfactorh = zfactor
        zfactore = zfactor
      endif
c
      fluxth = zcoefth * zfactorh
     &  * ( zwth1 * zgph**2 + zwth2 * zgph * gnh + zwth3 * gnh**2 )
c
      fluxnh = zcoefnh * zfactorh
     &  * ( zwnh1 * zgph**2 + zwnh2 * zgph * gnh + zwnh3 * gnh**2 )
c
      fluxte = zcoefte * zfactore
     &  * ( zwte1 * zgpe**2 + zwte2 * zgpe * gne + zwte3 * gne**2 )
c
      fluxnz = zero
c
      fluxtz = zero
c
c---:----1----:----2----:----3----:----4----:----5----:----6----:----7-c
c
      return
      end
!| \end{document}
