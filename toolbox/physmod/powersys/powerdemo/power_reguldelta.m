function [gf,Pmf]=power_reguldelta(deltadeg)

% Computing the final (steady) states of the generator
%
% Parameters of the generator and network, and coefficients of the 
% model; at the end delta and omega in steady state.
% Parameters of the generator and network: from parms7i2.m (Francis);
% coefficients of the model from paper: Conf. IEEE CANADA, May 1996.

%   rev: 24-09-1999
%   Copyright 1997-2002 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

global DELTA_FINAL

Wr=2*pi*60;
Rs=3.0e-3;
Ll=1.9837e-1;
Lmd=9.1763e-1;
Lmq=2.1763e-1;

Rfd=6.3581e-4;
Llfd=1.6537e-1;

Rkd=4.6454e-3;
Llkd=3.9203e-2;

Rkq=6.8430e-3;
Llkq=1.4544e-2;

H=3.195;
F=0;

% parametres du reseau:

% inductance , capacite et resistance de base:
	
Lfd=Llfd+Lmd;
Ld=Ll+Lmd;
Lq=Ll+Lmq;

% inductance et resistance de ligne (p.u):
Re=Rs*20;
Le=Ld/4.25;

% tension du bus infini(p.u):
Vinf=1;
K=Vinf;
a=pi/2;


% Coefficients of the model
aa =  Lmd^2 - Lfd*(Ld + Le); % it is a from the paper
b = Lq + Le;

% Other parameters needed which are in ms72.m, turbine
gmin = 0.01;
gmax = 0.9752;
At = 1/(gmax - gmin);

A11 = (Rs + Re)*Lfd*Wr/aa;
A12 = Lmd*Rfd*Wr/aa;
A13 = -Lfd*(Lq + Le)*Wr/aa;
A14 = Lfd*Vinf*Wr/aa;

A21 = -(Ld + Le)*Wr/b;
A22 = Lmd*Wr/b;
A23 = -(Rs + Re)*Wr/b;
A24 = -Vinf*Wr/b;

A31 = (Rs + Re)*Lmd*Wr/aa;
A32 = Rfd*(Ld + Le)*Wr/aa;
A33 = -Lmd*(Lq + Le)*Wr/aa;
A34 = Lmd*Vinf*Wr/aa;

A51 = -(Lq - Ld)/(2*H);
A52 = -Lmd/(2*H);
A53 = -F/(2*H);
A54 = 1/(2*H);

g11 = - Lmd*Wr/aa;
g31 = - (Ld + Le)*Wr/aa;

% desired delta and omega in steady (final) state.
wf = 1;
DELTA_FINAL = deltadeg*pi/180;

vFf = fzero('power_regulzero',0.01,optimset('Display','off'));

% Computing the steady states of the generator, having a "f" at the end
% from "final".
% Data: the same from equilgen.m, plus vFf computed at equilgen.m
% Output: the sready states.
% Method: from the first three equations, knowing vFf one finds the
% currents (in steady state), from eq. 5 Gf, from eq. 7 qf, from eq. 6 gf 
% and ugf; Pmf follows.

Ai = [A11, A12, A13;
      A21, A22, A23;
      A31, A32, A33];
Bi = inv(Ai);

Idf = -Bi(1,1)*(A14*cos(DELTA_FINAL - a) + g11*vFf) -Bi(1,2)*(A24*sin(a...
      - DELTA_FINAL))-Bi(1,3)*(A34*cos(DELTA_FINAL - a) + g31*vFf);
IFf = -Bi(2,1)*(A14*cos(DELTA_FINAL - a) + g11*vFf) -Bi(2,2)*(A24*sin(a...
      - DELTA_FINAL))-Bi(2,3)*(A34*cos(DELTA_FINAL - a) + g31*vFf);
Iqf = -Bi(3,1)*(A14*cos(DELTA_FINAL - a) + g11*vFf) -Bi(3,2)*(A24*sin(a...
      - DELTA_FINAL))-Bi(3,3)*(A34*cos(DELTA_FINAL - a) + g31*vFf);

Gf  = -(A51*Iqf*Idf + A52*Iqf*IFf + A53*wf)/A54;
gf  = Gf/At;
ugf = gf;
qf  = Gf;
Pmf = Gf;
