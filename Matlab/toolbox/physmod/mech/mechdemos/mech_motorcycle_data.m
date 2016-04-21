%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
%                       The Sharp 1994 bike model                       %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/06/27 18:42:48 $

% Set up preliminaries:
G = 9.81;

% Motorcycle's nominal state is stationary in static equilibrium with no
% lean angle.  n0 is at ground level, directly beneath the rear frame mass
% centre. The vector [nx] is forwards, [ny] to the right side and [nz]
% downwards (SAE standard).

linear = 1;
hands_on = 1;

% Introduce all the bike parameters:

% Default values for masses:
Mf.name = 'Mass of Front Frame';
Mr.name = 'Mass of Rear Frame';
Mb.name = 'Mass of Rear Wheel Assembly';
Mp.name = 'Mass of Upper Body of Rider';

Mf.value = 40.59;
Mr.value = 170.3;
Mb.value = 25.0;
Mp.value = 50.0;

Mfw = 26.5;
Mrw = 26.5;

% Default values for moments of inertia:
Ifx.name  = 'Front frame assembly inertia about x-axis';
Ifz.name  = 'Front frame assembly inertia about z-axis';
Ifxz.name = 'Front frame assembly inertia product';
Ipx.name  = 'Rear frame inertia about x-axis';
Ipz.name  = 'Rear frame inertia about z-axis';
Ipxz.name = 'Rear frame inertia product';
Irx.name  = 'Rider upper body inertia about x-axis';
Irz.name  = 'Rider upper body inertia about z-axis';
Irxz.name = 'Rider upper body inertia product';
irwx.name = 'Rear wheel inertia about x-axis';
irwy.name = 'Rear wheel spin inertia';
ifwy.name = 'Front wheel spin inertia';
iry.name  = 'Effective engine flywheel inertia';

Ifx.value   = 3.97;
Ifxz.value  = 0; 
Ipx.value   = 1.96; 
Ipz.value   = 0.55; 
Ipxz.value  = 0.26; 
Irx.value   = 7.43;
Irz.value   = 11.63; 
Irxz.value  = 7.4;
irwx.value  = 0.4; 
irwy.value  = 0.65; 
ifwy.value  = 0.58;
iry.value   = 0.41;

% Geometric parameters:
aa = 0.527;
bb = 0.628;
bb_b = 0.62;
bb_p = 0.28;
ee = 0.049;
hh = 0.438;
hh_b =  0.33;
hh_p = 0.4;
hh_s = 0.8;
jj = 0.527;
ll = 0.807;
Rf = 0.336;
Rr = 0.321;
ss = 0.77;
trail = 0.094;
epsilon = 0.47;
epsilon1 = 1.435;
hh_cp = 0.33;

% Frame flexibility and rider parameters:
k_v.name = 'steering head lateral stifness coefficient';
D_v.name = 'steering head lateral damping coefficient';
k_lamda.name = 'rear wheel assembly twist stiffness coefficient';
D_lamda.name = 'rear wheel assembly twist damping coefficient';
k_gamma.name = 'steering head torsional stiffness coefficient';
D_gamma.name = 'steering head torsional damping coefficient';
k_zita.name = 'rider upper body restraint stiffness coefficient';
D_zita.name = 'rider upper body restraint damping coefficient';
k_steer.name = 'steer stiffness coefficient';
D_steer.name = 'steer damping coefficient';

k_v.value = 1.04e6;
D_v.value = 456;
k_lamda.value = 46000;
D_lamda.value = 17.7;
k_gamma.value = 61200;
D_gamma.value = 44.1;
k_zita.value = 10000;
D_zita.value = 156;

if (hands_on),
    Ifz.value =  0.91;
    k_steer.value = 50.0;
    D_steer.value = 6.0;
else
    Ifz.value = 0.71;
    k_steer.value = 0.0;
    D_steer.value =  1.0;
end;


% Tyre parameters:
Cfvf.name = 'Front Tyre Cornering Stiffness';
Cfvr.name = 'Rear Tyre Cornering Stiffness';
Cmvf.name = 'Front Tyre Aligning Moment Stiffness';
Cmvr.name = 'Rear Tyre Aligning Moment Stiffness';
Cf1.name = 'Front Tyre Camber Stiffness';
Cr1.name = 'Rear Tyre Camber Stiffness';
Cf2.name = 'Front Tyre Aligning Moment Camber Coefficient';
Cr2.name = 'Rear Tyre Aligning Moment Camber Coefficient';
Cf3.name = 'Front Tyre Overturning Moment Coefficient';
Cr3.name = 'Rear Tyre Overturning Moment Coefficient';
Crr1.name = 'Tyre rolling resistance coefficient 1';
Crr2.name = 'Tyre rolling resistance coefficient 2';

Crr1.value =  0.018;
Crr2.value = 6.8e-6;

% Other parameters:
Dc.name = 'Aerodynamic Drag Coefficient';
Lc.name = 'Aerodynamic Lift Coefficient';

Dc.value =  0.377;
Lc.value =  0.05;

kk = ll+(ee+trail-jj*sin(epsilon))/cos(epsilon);
whl_bs  = bb+ll;


% Define various points in the nominal configuration within the coordinate 
% system of body n:

p1.name = 'Rear Frame centre of mass';
p1.coordinates = [0 0 -hh];

p2.name = 'Rear Wheel Assembly centre of mass';
p2.coordinates = [-bb_b 0 -hh_b];

p3.name = 'Front Frame centre of mass';
p3.coordinates = [kk 0 -jj];

p4.name = 'Rider centre of mass';
p4.coordinates = [-bb_p 0 -hh_s-hh_p];

p5.name = 'Rear Wheel centre point';
p5.coordinates = [-bb 0 -Rr];

p6.name = 'Front Wheel centre point';
p6.coordinates = [ll 0 -Rf];

p7.name = 'Rear Wheel Assembly joint with Rear Frame';
p7.coordinates = [-bb+aa*cos(epsilon1) 0 -aa*sin(epsilon1)];

p8.name = 'Front Twist Frame joint with Rear Frame';
p8.coordinates = [ll+trail/cos(epsilon)-ss*tan(epsilon) 0 -ss];

p9.name = 'Rider joint with Rear Frame';
p9.coordinates = [-bb_p 0 -hh_s];

p10.name = 'Rear Wheel ground contact point in n';
p10.coordinates =  [-bb 0 0];

p11.name = 'Front Wheel ground contact point in n';
p11.coordinates = [ll 0 0];

p12.name = 'Centre of pressure';
p12.coordinates = [whl_bs/2-bb 0 -hh_cp];

%Initial conditions.

if (~linear)
    vu =  53.5; 
    rid_tq  = 0; 
    ki = 300;
    kp = 300;
end;
    
% "tu(yaw_fr,1)" vu "rq(rf)" 0.005))


% Compute normal tyre loads.
Zf = ((Mf.value*(bb+kk)+Mr.value*bb+Mb.value*(bb-bb_b)+Mp.value*(bb-bb_p))*G-(vu^2)*(Dc.value*hh_cp+Lc.value*whl_bs/2))/whl_bs;
Zr = (Mf.value+Mr.value+Mp.value+Mb.value)*G-Lc.value*vu^2-Zf;

% Calculate tyre parameters:

Cfvr = -92.9+23.129*Zr-(4.663/1000)*Zr^2-(6.457e-7)*Zr^3+(1.887e-10)*Zr^4;
Cfvf = -300+28.577*Zf-0.0143*Zf^2+(1.431e-6)*Zf^3+(3.347e-10)*Zf^4;
Cmvr = 9+0.3573*Zr + (3.378e-5)*Zr^2;
Cmvf = -0.281+0.2442*Zf+(8.575e-5)*Zf^2;
Cr1 = 27.38+0.9727*Zr-(4e-6)*Zr^2;
Cf1 = -13.25+1.302*Zf-(1.39e-4)*Zf^2;
Cr2 = 2.056+0.01282*Zr+(4.928e-6)*Zr^2;
Cf2 = 2.788+0.0165*Zf+(3.9e-6)*Zf^2;
Cr3 = -0.07*Zr;
Cf3 = -0.06*Zf;
sigmar = 0.03594+(1.941e-4)*Zr-(5.667e-8)*Zr^2+(5.728e-12)*Zr^3;
sigmaf = 0.1012+(1.297e-4)*Zf-(3.267e-8)*Zf^2;



