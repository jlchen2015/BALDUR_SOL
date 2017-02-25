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
!| \normalsize  {\tt sda04flx.tex} \\
!| \vspace{1pc}
!| Bruce Scott \\
!| Max Planck Institut f\"{u}r Plasmaphysik \\
!| Euratom Association \\
!| D-85748 Garching, Germany \\
!| \vspace{1pc}
!| Glenn Bateman \\
!| Lehigh University, Physics Department \\
!| 16 Memorial Drive East, Bethlehem, PA 18015 \\
!| \vspace{1pc}
!| \today
!| \end{center}
!| 
!| This subroutine computes the transport fluxes driven by
!| drift Alfv\'{e}n turbulence using a model based on
!| simulations by Bruce Scott.
!| 
!| The following expressions are based on data sent on 13 Feb 98
!| and 24 September 1998:
!| 
!| The transport fluxes ($ Q_i^{DA} = $ ion thermal flux,
!| $ Q_i^{DA} = $ electron thermal flux, and
!| $ \Gamma_i^{DA} = $ ion particle flux)
!| computed by these turbulence
!| simulations are fitted by the following functions:
!| \begin{eqnarray*}
!| Q_i^{DA}
!|  & = & - 5.65 \times 10^{-3} n_e T_e c_s ( \rho_s / R )^2 g_p^2
!|       ( T_i / T_e )^{2.233} \\
!|  & & \times [ 0.12 g_{ph}^2 + 1.64 g_{ph} g_{nh} + 0.24 g_{nh}^2 ] \\
!|  & & \times
!| [ ( 0.29 + 0.18 \nu ) + ( 196. - 20. \nu ) \beta_e ] \\
!|  & & \times \exp [ -3.1236 ( \kappa - 1 ) ]
!|    \; q^2 / ( 7.72 - 0.38 \hat{s}^2 + 0.105 \hat{s}^4 )
!| \end{eqnarray*}
!| \begin{eqnarray*}
!| Q_e^{DA}
!|  & = & - 1.65 \times 10^{-3} n_e T_e c_s ( \rho_s / R )^2  g_p^2
!|       \exp [ 1.1224 ( T_i / T_e  - 1 ) ]
!|   \\
!|  & &  \times [ 0.3 g_{pe}^2 + 0.8 g_{pe} g_{ne} + 1.2 g_{ne}^2 ] \\
!|  & & \times
!| [ ( .32 + 0.61 \nu ) + ( 173. - 94. \nu ) \beta_e ] \\
!|  & & \times \exp [ -3.1236 ( \kappa - 1 ) ]
!|  \; q^2  / ( 2.45 + 1.16 \hat{s}^2 )
!| \end{eqnarray*}
!| \begin{eqnarray*}
!| \Gamma_i^{DA}
!|  & = & - 6.8 \times 10^{-4} n_e c_s ( \rho_s / R )^2  g_p^2
!|       \exp [ 1.0015 ( T_i / T_e  - 1 ) ] \\
!|  & &  \times [ 0.032 g_{ph}^2 - 0.13 g_{ph} g_{nh} + 4.13 g_{nh}^2 ] \\
!|  & & \times
!|   [ ( 0.11 + 0.3 \nu ) + ( 246. - 44. \nu ) \beta_e ] \\
!|  & & \times \exp [ -3.1236 ( \kappa - 1 ) ]
!|  \; q^2 / ( 6.34 + 0.21 \hat{s}^2 + 0.057 \hat{s}^4 )
!| \end{eqnarray*}
!| where $ c_s = \sqrt{T_e/M_i} $, $ \rho_s = \sqrt{T_e M_i} / ( e B )$,
!| $ R = $ major radius,
!| $ g_p = - R ( d p / d r ) / p $, $ p = n_e T_e + n_i T_i $,
!| (correspondingly $ p_H = n_H T_H $ is the hydrogenic thermal pressure with
!| hydrogenic density $ n_H $ and temperature $ T_H $ with normalized gradient
!| $ g_{ph} = - R ( d p_H / d r ) / p_H $,
!| and $ p_e = n_e T_e $ is the electron pressure),
!| $ \nu = $ collisionality,
!| $ \beta_e \equiv n_e T_e 2 \mu_0 / B^2 $,
!| $ \kappa = $ local elongation,
!| $ q = $ safety factor, and
!| $ \hat{s} \approx r ( d q / d r ) / q $ is the magnetic shear.
!| The strong scaling with elongation is shown in Fig. 1.
!| The strong scaling
!| of this mode with pressure gradient to the fourth power
!| and magnetic $ q^2 $ results in
!| more transport near the plasma edge than in the core.
!| This model has gyro-Bohm scaling.
!| 
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
c@sda04flx
c rgb 10-oct-98 revised with model based on 24-sep-98 data
c rgb 26-feb-98 first draft
c---:----1----:----2----:----3----:----4----:----5----:----6----:----7-c
c
      subroutine sda04flx (lswitch, cswitch, lprint, nout
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
c  fluxth   = - flux of hydrogenic heat / ( n_e T_e c_s (\rho_s/R)^2 )
c  fluxnh   = - flux of hydrogenic ions / ( n_e c_s (\rho_s/R)^2 )
c  fluxte   = - flux of electron heat / ( n_e T_e c_s (\rho_s/R)^2 )
c  fluxnz   = - flux of impurity ions / ( n_e c_s (\rho_s/R)^2 )
c  fluxtz   = - flux of impurity heat / ( n_e T_e c_s (\rho_s/R)^2 )
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
      real zfracnh, zgp, zgph, zgpe
     &  , zfactor
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
c  compute zfracnh from charge neutrality
c
      zfracnh = zone - chargenz * fracnz - chargens * fracns
c
      if ( zfracnh .lt. zero ) then
        zfracnh = zero
        nerr = 2
      endif
c
      zgp =  ( gne + gte
     &  + zfracnh * th7te * ( gnh + gth )
     &  + fracnz  * tz7te * ( gnz + gtz ) )
     &  / ( zone + zfracnh * th7te + fracnz * tz7te )
c
      zgph =  ( gnh + gth )
      zgpe =  ( gne + gte )
c
c..compute fluxes
c
c  Note that the factor 0.51 = ( L_p / Lpp )**2
c  from Bruce Scott's e-mail on 8 October 1998
c
      zfactor = 0.51 * q**2
     &  * exp( - 3.1236 * ( kappa - zone ) ) * zgp**2
c
      fluxth = 5.65e-3 * zfactor * th7te**(2.233)
     &  * ( 0.29 + 0.18 * vef
     &      + ( 196. - 20. * vef ) * betae )
     &  * ( 0.12 * zgph**2 + 1.64 * zgph * gnh + 0.24 * gnh**2 )
     &  / ( 7.72 - 0.38 * shear**2 + 0.105 * shear**4 )
c
      fluxte = 1.65e-3 * zfactor * exp( 1.1224 * ( th7te - zone ) )
     &  * ( 0.32 + 0.61 * vef
     &      + ( 173.0 - 94.0 * vef ) * betae )
     &  * ( 0.3 * zgpe**2 + 0.8 * zgpe * gne + 4.13 * gne**2 )
     &  / ( 2.45 + 1.16 * shear**2 )
c
      fluxnh = 6.8e-4 * zfactor * exp( 1.0015 * ( th7te - zone ) )
     &  * ( 0.11 + 0.3 * vef
     &      + ( 246.0 - 44.0 * vef ) * betae )
     &  * ( 0.033 * zgph**2 - 0.13 * zgph * gnh + 4.13 * gnh**2 )
     &  / ( 6.34 + 0.21 * shear**2 + 0.057 * shear**4 )
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
