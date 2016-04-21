% himat_dk
%
%  This script file contains the USER DEFINED VARIABLES for the
%	mutools DKIT script file. The user MUST define the 5 variables
%	below.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%----------------------------------------------%
% 	REQUIRED USER DEFINED VARIABLES        %
%----------------------------------------------%
% Nominal plant interconnection structure
NOMINAL_DK = himat_ic;

% Number of measurements
NMEAS_DK = 2;

% Number of control inputs
NCONT_DK = 2;

% Block structure for mu calculation
BLK_DK = [2 2;4 2];

% Frequency response range
OMEGA_DK = logspace(-3,3,60);


%-------------------- end of himat_dk --------------------------------%