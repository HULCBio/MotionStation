function dVt = power_regulzero(vFf,Ai,Bi,Idf,IFf,Iqf); % dVt = 1-Vt
% Prerequisite for computing the steady states of the generator.
%
% Data: the coefficients of the plant A, c, a, g11,g31, and wf = 1
% (speed in st. st.) and df = given (delta in st. st.), all in datagen.m.
%
% Output: the permanent excitation voltage vFf (vfd in steady
% state, having an "f" at the end from "final"), essential for 
% computing the other steady states, in stestagen.m.
%
% Method: from the first 3 eqs one find the currents as a function
% of vFf; using also the eq of vt one finds vFf by the MATLAB
% function: fzero('equilgen', 0.01).

%   Copyright 1997-2002 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

global DELTA_FINAL

A14=-6.271928634180870e+02;
A24=-5.555520989357817e+02;
A34=-5.314228875884941e+02;

Bi=[	2.53723982128792  -0.00130017546014  -2.99461277536793
	3.82832791844038   0.00000000000000  -4.51824715372311
	0.24094571509805  -0.00012070803726  -0.28160625852757 ];

c11=0.56313701001881;
c12=0.03247763163119;
c13=-2.353486735406178e-04;
c14=0.03386185014253;
c15=0.37015566527833;
c21=0.61303744798890;
c22=0.03562135922330;
c23=-0.27087378640777;
c24=0.35508844660194;

g11=5.314228875884941e+02;
g31=7.983755334890164e+02;

df=DELTA_FINAL;
a=1.57079632679490;

Idf = -Bi(1,1)*(A14*cos(df - a) + g11*vFf) -Bi(1,2)*(A24*sin(a - df))....
      -Bi(1,3)*(A34*cos(df - a) + g31*vFf);
IFf = -Bi(2,1)*(A14*cos(df - a) + g11*vFf) -Bi(2,2)*(A24*sin(a - df))....
      -Bi(2,3)*(A34*cos(df - a) + g31*vFf);
Iqf = -Bi(3,1)*(A14*cos(df - a) + g11*vFf) -Bi(3,2)*(A24*sin(a - df))....
      -Bi(3,3)*(A34*cos(df - a) + g31*vFf);

wf=1;

dVt = 1 - ((c11*cos(df - a) + c12*Idf + c13*IFf + c14*wf*Iqf....
     + c15*vFf)^2....
     + (c21*sin(-df + a) + c22*Iqf + c23*wf*Idf....
     + c24*wf*IFf)^2)^(1/2);
