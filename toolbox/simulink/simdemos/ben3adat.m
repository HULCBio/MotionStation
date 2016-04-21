 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.17 $

T1 = 1/50;
T2 = 1/200;

offT1  = 0.0;
offT2 = 0.00499999;
offZOH = 1.0e-8;

%***continuous transfers
gn1 = -15*[1,1.5];
gd1 = [1,6,13];

gn2 = [-0.1,9];
gd2 = [1,6,13];

%***SIMO Transfer function for numerator
gn1_gn2 = [gn1; gn2];

%***sampled data transfers
gn3 = .2625*[1,-0.9048];
gd3 = [1,-1];

gn4 = 1.7*[1,-0.9608];
gd4 = [1,-0.6667];

gn5 = 1.035*[1,-0.9324];
gd5 = [1,-1];

gn6 = 0.1564*[1,1];
gd6 = [1,-0.6873];

gn7 = 0.0362*[1,1];
gd7 = [1,-0.9277];

