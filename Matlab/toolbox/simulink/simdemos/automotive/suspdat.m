%SUSPDAT Load suspension demo data
%   SUSPDAT  when typed at the command line, places suspension model parameters 
%   in the MATLAB workspace (also called as preload function of suspn.mdl)
%
%   See also SUSPGRPH

%   Author(s): D. Maclay, S. Quinn, 12/1/97 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

Lf = 0.9;	% front hub displacement from body CG
Lr = 1.2;       % rear hub displacement from body CG
Mb = 1200;      % body mass in kg
Iyy = 2100;	% body moment of inertia about y-axis in kgm^2
kf = 28000;     % front suspension stiffness in N/m
kr = 21000;	% rear suspension stiffness in N/m
cf = 2500;	% front suspension damping in N/(m/s)
cr = 2000; 	% rear suspension damping in N/(m/s)
