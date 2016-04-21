% This M-file generates the initial geometric and dynamic information for
% the Stewart platform in controls case study.  The Stewart platform
% consists of a top plate, a bottom plate, and six legs connecting the top
% plate to the bottom plate.  The overall system has six independent
% degrees of freedom.  Each disconnected leg has six degrees of freedom and
% is composed of two bodies, two universal joints, and one cylindrical
% joint.
% 
%                     Copyright 2002-2003 The MathWorks, Inc.

% Angular conversion and CS axes
deg2rad = pi/180;
x_axis = [1 0 0];
y_axis = [0 1 0];
z_axis = [0 0 1];

% Connection points on base and top plate w.r.t. World CS at the center
% of the base plate
pos_base = [];
pos_top = [];
alpha_b = 2.5*deg2rad; % +- offset angle from 120 degree spacing on base
alpha_t = 10*deg2rad;  % +- offset angle from 120 degree spacing on top
height = 2.0;   % two meter height in initial configuration
radius_b = 3.0; % base radius in meters
radius_t = 1.0; % top radius in meters

for i = 1:3,
  % Base points
  angle_m_b = (2*pi/3)* (i-1) - alpha_b;
  angle_p_b = (2*pi/3)* (i-1) + alpha_b;
  pos_base(2*i-1,:) = radius_b* [cos(angle_m_b), sin(angle_m_b), 0.0];
  pos_base(2*i,:) = radius_b* [cos(angle_p_b), sin(angle_p_b), 0.0];

  % Top points
  % Top points are 60 degrees offset
  angle_m_t = (2*pi/3)* (i-1) - alpha_t + 2*pi/6; 
  angle_p_t = (2*pi/3)* (i-1) + alpha_t + 2*pi/6;
  pos_top(2*i-1,:) = radius_t* [cos(angle_m_t), sin(angle_m_t), height];
  pos_top(2*i,:) = radius_t* [cos(angle_p_t), sin(angle_p_t), height];
end
% Permute pos_top points so that legs are end points of base and top points
% 6th point on top connects to 1st on bottom
pos_top = [pos_top(6,:); pos_top(1:5,:)];

% Compute points w.r.t. to the body frame in a 3x6 matrix
body_pts = pos_top' - height*[zeros(2,6);ones(1,6)];

% Leg vectors
legs = pos_top - pos_base;
leg_length = [ ];
leg_vectors = [ ];
for i = 1:6,
  leg_length(i) = norm(legs(i,:));
  leg_vectors(i,:) = legs(i,:) / leg_length(i);
end

% Calculate revolute and cylindrical axes
for i = 1:6,
  rev1(i,:) = cross(leg_vectors(i,:), z_axis);
  rev1(i,:) = rev1(i,:) / norm(rev1(i,:));
  rev2(i,:) = - cross(rev1(i,:), leg_vectors(i,:));
  rev2(i,:) = rev2(i,:) / norm(rev2(i,:));
  cyl1(i,:) = leg_vectors(i,:);
  rev3(i,:) = rev1(i,:);
  rev4(i,:) = rev2(i,:);
end

% Coordinate systems
lower_leg = struct('origin', [0 0 0], 'rotation', eye(3), 'end_point', [0 0 0]);
upper_leg = struct('origin', [0 0 0], 'rotation', eye(3), 'end_point', [0 0 0]);

for i = 1:6,
  lower_leg(i).origin = pos_base(i,:) + (3/8)*legs(i,:);  
  lower_leg(i).end_point = pos_base(i,:) +  (3/4)*legs(i,:);  
  lower_leg(i).rotation = [rev1(i,:)', rev2(i,:)', cyl1(i,:)'];
  upper_leg(i).origin = pos_base(i,:) + (1-3/8)*legs(i,:);
  upper_leg(i).end_point = pos_base(i,:) +  (1/4)*legs(i,:);  
  upper_leg(i).rotation = [rev1(i,:)', rev2(i,:)', cyl1(i,:)'];
end

% Inertias and masses
top_thickness = 0.05;
base_thickness = 0.05;
inner_radius = 0.03;
outer_radius = 0.05;
density = 76e3/9.81; % steel density in kg/m^3

% Leg inertia and mass
[lower_leg_mass, lower_leg_inertia] = inertiaCylinder(density, ... 
              0.75*leg_length(1),outer_radius, inner_radius);
[upper_leg_mass, upper_leg_inertia] = inertiaCylinder(density, ... 
              0.75*leg_length(1),inner_radius, 0);

% Top and base plate mass and inertia
[top_mass, top_inertia] = inertiaCylinder(density, ... 
              top_thickness, radius_t, 0);
[base_mass, base_inertia] = inertiaCylinder(density, ... 
              base_thickness,radius_b, 0);
          
% Reference motion and control constants
freq = 3.0;
transfer_num = [5*freq 0];
transfer_denom = [1 5*freq];

Ki = 1e6;
Kp = 4e6;
Kd = 1e4;