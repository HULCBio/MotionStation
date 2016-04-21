% dk_defin
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




%---------------------------------------------------------------------%
%        USER DEFINED VARIABLES TO BE CLEARED FROM THE WORKSPACE      %
%                     AFTER EACH D-K ITERATION	                  	   	%
%---------------------------------------------------------------------%

CLEAR_DK_DATA = 'NOMINAL_DK NMEAS_DK NCONT_DK BLK_DK GMIN_DK EPR_DK';
CLEAR_DK_DATA = [CLEAR_DK_DATA, ' GMAX_DK GTOL_DK GTOLS_DK RICMTHD_DK '];
CLEAR_DK_DATA = [CLEAR_DK_DATA, ' EPP_DK MUDIM_DK '];
CLEAR_DK_DATA = [CLEAR_DK_DATA, ' NAME_DK GMAX_DK_PLAN'];

%--------------------------------------------------------------------%
%           DK_ITER VARIABLES TO BE SAVED IN THE WORKSPACE           %
%                     AFTER EACH D-K ITERATION			                    %
%--------------------------------------------------------------------%
%
%  nom_dk_g     - frequency response of NOMINAL_DK using OMEGA_DK
%  gf_dk(i)     - H-infinity norm of i'th iteration
%  k_dk(i)      - i'th iteration controller
%  Dscale_dk(i) - D-scaling data from the  i'th iteration
%  sens_dk(i)   - sebsitivity data from the  i'th iteration
%  bnds_dk(i)   - mu across frequency for the i'th iteration
%  dl_dk(i)     - left state-space D scale associated with i'th iteration
%  dr_dk(i)     - right state-space D scale associated with i'th iteration

CLEAR_DK_IT_DATA = 'g_dk g_dk_g g_dk_gs gf_dk k_dk_g k_dk IC_DK ';
CLEAR_DK_IT_DATA = [CLEAR_DK_IT_DATA 'Dscale_dk dl_dk dr_dk sens_dk bnds_dk'];