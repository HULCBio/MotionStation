%% Copyright (C) 2004-2012  Carlo de Falco
%%
%% This file is part of 
%% SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
%%
%% SECS1D is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% SECS1D is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with SECS1D; If not, see <http://www.gnu.org/licenses/>.

%% material properties for silicon and silicon dioxide
%%
%% esir       = relative electric permittivity of silicon
%% esio2r     = relative electric permittivity of silicon dioxide
%% esi 	      = electric permittivity of silicon
%% esio2      = electric permittivity of silicon dioxide
%% mn         = effective mass of electrons in silicon
%% mh         = effective mass of holes in silicon
%% 
%% u0n        = low field electron mobility
%% u0p        = low field hole mobility
%% uminn      = parameter for doping-dependent electron mobility
%% betan      = idem
%% Nrefn      = idem
%% uminp      = parameter for doping-dependent hole mobility
%% betap      = idem
%% Nrefp      = idem
%% vsatn      = electron saturation velocity
%% vsatp      = hole saturation velocity
%% tp         = electron lifetime
%% tn         = hole lifetime
%% Cn         = electron Auger coefficient
%% Cp         = hole Auger coefficient
%% an         = impact ionization rate for electrons
%% ap         = impact ionization rate for holes
%% Ecritn     = critical field for impact ionization of electrons
%% Ecritp     = critical field for impact ionization of holes 
%% Nc         = effective density of states in the conduction band
%% Nv         = effective density of states in the valence band
%% Egap       = bandgap in silicon
%% EgapSio2   = bandgap in silicon dioxide
%% 
%% ni         = intrinsic carrier density
%% Phims      = metal to semiconductor potential barrier

esir 	       = 11.7;
esio2r 	     = 3.9;
esi 	       = e0 * esir;
esio2 	     = e0 * esio2r;
mn           = 0.26*mn0;
mh           = 0.18*mn0;

qsue         = q / esi;

u0n          = 1417e-4;
u0p          = 480e-4;
uminn        = u0n;            % ref. value: 65e-4;
uminp        = u0p;            % ref. value: 47.7e-4;
betan        = 0.72;
betap        = 0.76;
Nrefn        = 8.5e22;
Nrefp        = 6.3e22;
vsatn        = inf;            % ref. value: 1.1e5;
vsatp        = inf;            % ref. value: 9.5e4;

tp           = inf;            % ref. value: 1e-6;
tn           = inf;            % ref. value: 1e-6;

Cn           = 0;              % ref. value: 2.8e-31*1e-12; 
Cp           = 0;              % ref. value: 9.9e-32*1e-12;   
an           = 0;              % ref. value: 7.03e7;
ap           = 0;              % ref. value: 6.71e7;
Ecritn       = 1.231e8; 
Ecritp       = 1.693e8;

mnl          = 0.98*mn0;
mnt          = 0.19*mn0;
mndos        = (mnl*mnt*mnt)^(1/3); 

mhh         = 0.49*mn0;
mlh         = 0.16*mn0;
mhdos       = (mhh^(3/2)+mlh^(3/2))^(2/3);

Nc          = (6/4)*(2*mndos*Kb*T0/(hbar^2*pi))^(3/2);   
Nv          = (1/4)*(2*mhdos*Kb*T0/(hbar^2*pi))^(3/2);
Eg0         = 1.16964*q;
alfaEg      = 4.73e-4*q;
betaEg      = 6.36e2;
Egap        = Eg0-alfaEg*((T0^2)/(T0+betaEg));
Ei          = Egap/2+Kb*T0/2*log(Nv/Nc);
EgapSio2    = 9*q;
deltaEcSio2 = 3.1*q;
deltaEvSio2 = EgapSio2-Egap-deltaEcSio2;

ni          = sqrt(Nc*Nv)*exp(-Egap/(2*(Kb * T0)));
Phims       = - Egap /(2*q);
