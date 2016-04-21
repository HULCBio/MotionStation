function funcout = aero_extkalman(pinput)
%AERO_EXTKALMAN Radar Data Processing Tracker Using an Extended Kalman Filter
%
%  This program is executed as a MATLAB function block in the 
%  aero_radmod Simulink model.  There is a file called "aero_raddat.m" that 
%  contains the data needed to run the aero_radmod model.  The estimated 
%  and actual positions are saved to the workspace and are plotted at
%  the end of the simulation by the program aero_radplot (called from the 
%  simulation automatically).
%
%  See the description in the "Extended Kalman Filter" Brochure for 
%  the equations.

%  This program was developed by Dr. Richard Gran, September 1, 1996, 
%  and modified by Paul Barnard, June 1997.
%  Copyright 1990-2002 The MathWorks, Inc.
%  $Revision: 1.9 $  $Date: 2002/04/10 18:40:25 $

% Initialization
meas = pinput(1:2);
xhatPrev = pinput(3:6);
PPrev = pinput(7:22);       %  Covariance matrix (zeros assumes perfect estimate)
deltat = pinput(23);

xhat = xhatPrev(:);         %  Estimate
P    = reshape(PPrev,4,4);  

%  Radar update time deltat is inherited from workspace where it was defined by raddat.

% 1. Compute Phi, Q, and R 
Phi = [1 deltat 0 0; 0 1 0 0 ; 0 0 1 deltat; 0 0 0 1];
Q =  diag([0 .005 0 .005]);
R =  diag([300^2 0.001^2]);

% 2. Propagate the covariance matrix:
P = Phi*P*Phi' + Q;

% 3. Propagate the track estimate::
xhat = Phi*xhat;

% 4 a). Compute observation estimates:
Rangehat = sqrt(xhat(1)^2+xhat(3)^2);
Bearinghat = atan2(xhat(3),xhat(1));

% 4 b). Compute observation vector y and linearized measurement matrix M 
yhat = 	[Rangehat
          Bearinghat];
M = [ cos(Bearinghat)          0 sin(Bearinghat)          0
   -sin(Bearinghat)/Rangehat 0 cos(Bearinghat)/Rangehat 0 ];

% 4 c).  Compute residual (Estimation Error)
residual = meas - yhat;

% 5. Compute Kalman Gain:
W = P*M'/(M*P*M'+ R);

% 6. Update estimate
xhat = xhat + W*residual;

% 7. Update Covariance Matrix
P = (eye(4)-W*M)*P*(eye(4)-W*M)' + W*R*W';

% Output columwise for Simulink.
funcout = [residual;xhat;P(:);deltat];





