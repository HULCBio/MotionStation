function flyball = mech_flyball_data
%MECH_FLYBALL_DATA - generate data for flyball governor
  
% Copyright 2002 The MathWorks, Inc.
% $Revision: 1.3.4.1 $ $Date: 2004/04/16 22:17:34 $

flyball.brass = 8.0;                  % g/cm^3

%=====================================================================
% ball
%=====================================================================

flyball.ball.radius  = 4.25;          % cm

%=====================================================================
% ball_rod
%=====================================================================

flyball.ball_rod.length     = 19.5;   % cm
flyball.ball_rod.radius     = 0.5;    % cm
flyball.ball_rod.connection = 14.5;   % cm

%=====================================================================
% connecting_rod
%=====================================================================

flyball.connecting_rod.length = 14.5; % cm
flyball.connecting_rod.radius = 0.5;  % cm

%=====================================================================
% cross_member
%=====================================================================

flyball.cross_member.length = 5.5;    % cm
flyball.cross_member.radius = 0.5;    % cm

%=====================================================================
% mast
%=====================================================================

flyball.mast.length         = 29.0;   % cm
flyball.mast.radius         =  3.0;   % cm
flyball.mast.connection     = flyball.ball_rod.connection * sqrt(2);

flyball.mast.rotational_damping = 1;  % N-m-s/rad
flyball.mast.spring             = 10; % N/cm
flyball.mast.damping            = 1;  % N-s/cm

% [EOF] mech_flyball_data.m



