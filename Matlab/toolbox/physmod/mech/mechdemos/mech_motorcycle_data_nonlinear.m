% Motorcycle model definition file.
% Author(s): G.D Wood
% Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/06/27 18:42:51 $
% $Revision: 1.0

% Inertia parameters.
Mff_str = 13.1;  % kg.
Mff_sus = 17.5;  % kg.
Mmain  = 209.6;  % kg.
Mfw = 25.6;      % kg.
Mrw = 25.6;      % kg.
Mubr = 44.5;     % kg.
Mswg_arm = 0;    % kg.
Iff_strx = 0.8;  % kg*m^2.
Iff_stry = 1.2;  % kg*m^2.
Iff_strz = 0.5;  % kg*m^2.
Iff_strxz = 0;   % kg*m^2.
Imnx = 6.9;      % kg*m^2.
Imny = 34.1;     % kg*m^2.
Imnz = 21.1;     % kg*m^2.
Imnxz  = 1.7;    % kg*m^2.
Iubrx = 1.3;     % kg*m^2.
Iubry = 2.1;     % kg*m^2.
Iubrz = 1.4;     % kg*m^2.
Iubrxz = 0.3;    % kg*m^2.
Ifwy  = 0.58;    % kg*m^2.
Irwy = 0.74;     % kg*m^2.

% Geometric parameters.
x1  =  0.770;   % m
z1  = -0.582;   % m
x2  =  1.168;   % m
z2  = -0.834;   % m
x3  =  1.165;   % m
z3  = -0.869;   % m
x4  =  1.225;   % m
z4  = -0.867;   % m
x5  =  1.539;   % m
z5  = -0.318;   % m
x6  =  1.539;   % m
z6  = -0.318;   % m
x7  =  0.000;   % m
z7  = -0.321;   % m
x8  =  0.680;   % m
z8  = -0.532;   % m
x9  =  0.600;   % m
z9  = -1.000;   % m
x10 =  0.600;   % m
z10 = -1.190;   % m
x11 =  0.400;   % m
z11 = -0.321;   % m
x12 =  0.000;   % m
z12 = -0.330;   % m
x13 =  0.000;   % m
z13 = -0.700;   % m
x14 =  0.100;   % m
z14 = -0.330;   % m
r_tcf = 0.049;  % m
r_tcr = 0.07;   % m
fwrad = 0.319;  % m
rwrad = 0.321;  % m 
epsilon = 0.52; %rad

% Suspension parameters.
r_sprld0 = 1540.0;  
f_sprld0 = 940.0;  
Ksf = 9000.0;  
Csf = 550.0;  
Ksr = 25700.0;
Csr = 1100.0; 
Ktf = 115000.0;  
Ktr = 170000.0;  
fw_ld0 = 1250.0;  
rw_ld0 = 1792.0;

% Stiffness and damping parameters.
Kp_ubr = 10000.0;
Cp_ubr = 85.2;  
Kp_twst = 34100.0;  
Cp_twst = 99.7;  
Kp_str = 0.0;
Kp_sts = 1000000.0;  
Cp_str = 7.4;  
CDA = 0.312;  
CLA = 0.114;

% Tyre parameters.
C_Mgf = 4.8;
C_Mgr = 7.9;
C_Faf = 1.85e4;
C_Far = 2.58e4;
C_Fgf = 1.71e3;
C_Fgr = 2.80e3;
p_agf = 0.46;  
p_agr = 0.4;
p_ggf = 0.36;  
p_ggr = 0.5;  
q_aaf = 10.1;  
q_aar = 10.1; 
q_ggf = 5.1;  
q_ggr = 5.1;
t_pf = 0.03; 
t_pr = 0.03;  
n_af = 14;  
n_ar = 1.9;  
n_gf = 1.3; 
n_gr = 1.69;
sigma_fyr = 0.25;  
sigma_fyf = 0.25;  
r_sl_stf = 20000;  
f_sl_stf = 15000;

% Set-defaults
theta = 0.0; 
brake = 0.0; 
satf = 4800;
v_ini = 30.0;


% Suspension pickup points.
Pickup.p1.name  = 'Aerodynamics centre of pressure';
Pickup.p1.coordinates = eval(['[x1 0 z1]']);
Pickup.p2.name = 'Twist axis joint with rear frame';
Pickup.p2.coordinates = eval(['[x2 0 z2]']);
Pickup.p3.name = 'Centre of mass of front frame steer body'; 
Pickup.p3.coordinates = eval(['[x3 0 z3]']);
Pickup.p4.name = 'Joint co-ordinate for front frame suspension and steer bodies'; 
Pickup.p4.coordinates = eval(['[x4 0 z4]']);
Pickup.p5.name = 'Centre of mass of front suspension body';
Pickup.p5.coordinates = eval(['[x5 0 z5]']);
Pickup.p6.name = 'Front wheel attachment point'; 
Pickup.p6.coordinates = eval(['[x6 0 z6]']);
Pickup.p7.name = 'Rear wheel centre point'; 
Pickup.p7.coordinates = eval(['[x7 0 z7]']);
Pickup.p8.name = 'Centre of mass of the main frame'; 
Pickup.p8.coordinates = eval(['[x8 0 z8]']);
Pickup.p9.name =  'Attachment point for rider on rear frame'; 
Pickup.p9.coordinates = eval(['[x9 0 z9]']);
Pickup.p10.name = 'Rider centre of mass'; 
Pickup.p10.coordinates = eval(['[x10 0 z10]']);
Pickup.p11.name = 'Swinging arm joint point to main frame'; 
Pickup.p11.coordinates = eval(['[x11 0 z11]']);
Pickup.p12.name = 'Attachment point for the rear spring onto bottom link'; 
Pickup.p12.coordinates = eval(['[x12 0 z12]']);
Pickup.p13.name = 'Attachment point for the rear spring onto main frame'; 
Pickup.p13.coordinates = eval(['[x13 0 z13]']);
Pickup.p14.name = 'Centre of mass of swing arm'; 
Pickup.p14.coordinates = eval(['[x14 0 z14]']);

