%
% Define default parameters for 
%  Fixed Point State Space Demo
%

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.8 $  
% $Date: 2002/04/10 19:02:34 $

%
% assume control system toolbox is available and try
% to build models from scratch
%
try
    %
    % Define default Storage-Data-Types
    %
    ntemp = 6;
    ShortType    = sfix(1*ntemp);
    BaseType     = sfix(2*ntemp);
    LongType     = sfix(4*ntemp);
    %ExtendedType = sfix(8*ntemp);
    
    %
    % Define default Sample Time
    %
    SampleTime = 0.01;   % sec
    
    %
    % Define default specs for the state space model in the S-Plane
    %
    
    % natural freq and damping ratio
    wn = 20;
    zeta = 0.2;
    
    % tf numerator and denominator S-domain
    num_s = 4 * wn^2;
    den_s =     [1 2*zeta*wn wn^2];
    den_s = conv( den_s, [ 1/wn 1 ] );
    
    plant_dc_gain = polyval(num_s,0)/polyval(den_s,0);
    
    % convert to discrete time
    sys_s = tf( num_s, den_s );
    sys_z = c2d( sys_s, SampleTime, 'tustin');
    
    % convert to canonical state space form
    [Ac_s, Bc_s, Cc_s, Dc_s ] = ssdata(sys_s);
    [Ac_z, Bc_z, Cc_z, Dc_z ] = ssdata(sys_z);
    
    % convert to a balanced realization
    sysb_z = balreal(sys_z);
    
    [Ab_z, Bb_z, Cb_z, Db_z ] = ssdata(sysb_z);
    
    % specify initial input
    u0 = 0;
    
    % derive inital conditions for balanced realization
    xb0_z  = inv( eye(length(Ab_z)) - Ab_z ) * Bb_z * u0;
    
    % derive inital conditions for balanced canonical realization
    xc0_z  = inv( eye(length(Ac_z)) - Ac_z ) * Bc_z * u0;
    xc0_s  = inv( -Ac_s ) * Bc_s * u0;
%
% if models could not be built for scratch (probably because
% control toolbox not available), then load variables from
% MAT file
%
catch
    %disp('Unable to calculate models for fxpdemo_state_space, so using MAT file.')
    load preload_state_space
end
