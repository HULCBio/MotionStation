%------------------------- mk_acnom ------------------------%
% this constructs the aircraft model for the SSLAFCS
% example. the SYSTEM matrix produced has
%
%  ACNOM:  4 states, 7 outputs, 6 inputs
%
%    OUTPUTS:	                      INPUTS:
%	1) pert1o                        1) pert1i
%	2) pert2o                        2) pert2i
%	3) pert3o                      	 3) pert3i
%	4) p (roll rate (rad/s))	 4) theta_el  (elevon angular def (rad))
%	5) r (yaw rate(rad/s))		 5) theta_rud (rudder angular def (rad))
%	6) ny (normal accel (ft/s^2))	 6) gust disturbance (ft/s)
%	7) phi (bank angle (rad))
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

a = [-0.0946   0.141    -0.99   0.0364;
      -3.59   -0.428    0.281     0;
      0.395  -0.0126   -0.0814    0;
       0        1       -0.141    0 ];
%
b = [-0.0124   0.0102   -0.000000109 ;
      6.57     1.26     -0.00000413 ;
      0.378    -0.256    0.000000453;
        0         0          0 ];
%
c = [ 0  1 0 0; 0 0 1 0; -68 -1.74 -4.06 -3.72e-5; 0 0 0 1];
%

bp = [ 0.0128     0       0;
         0     -0.0311   -3.12 ;
         0      -0.19    -0.0644;
         0        0        0];
%
cp = [ 1 0 0 0 ; 0 0 0 0 ; 0 0 0 0];
d12 = [ 0 0 0.00000115 ; 1 0 0 ; 0 1 0];
dp = zeros(3,3);
d21 = [zeros(2,3) ; 11.1 -11.1 -11.1 ; 0 0 0 ];
d22 = [zeros(2,3) ; 26.7 -2.95 -0.0000781; 0 0 0];

acnom = pck(a,[bp b],[cp ; c],[dp d12;d21 d22]);
clear cp d12 d21 d22 bp c b a
%---------------------------------------------------------------%
%
%