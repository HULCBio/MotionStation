%   dk_defin
%
%   This script file contains the USER DEFINED VARIABLES for the
%       mutools DKIT script file. The user MUST define all of the
%       variables listed in the REQUIRED section.  Variables listed
%       in the OPTIONAL section may be omitted.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%--------------------------------------------------------%
%          REQUIRED USER-DEFINED VARIABLES               %
%--------------------------------------------------------%

% Nominal Open-Loop Interconnection Structure
NOMINAL_DK = sysrand(11,8,9,1);

% Number of Control Measurements (# of inputs to the controller)
NMEAS_DK = 3;

% Number of Control Actuators (# of outputs of the controller)
NCONT_DK = 3;

% Block Structure for MU Calculation (including, in typical
%   problems, both the uncertainty blocks and the performance
%   block)
BLK_DK = [2 0;1 1;1 1;2 1];

% Frequency Response Range
OMEGA_DK = logspace(-3,3,50);

%--------------------------------------------------------%
%          OPTIONAL USER-DEFINED VARIABLES               %
%--------------------------------------------------------%

% DISCRETE_DK (used for unit disk, rather than imaginary axis)
%   if DISCRETE_DK==1, then all frequency responses and norms
%   are computed over the unit disk, as opposed to the right-half
%   plant.  The Default Value is DISCRETE_DK = 0, which forces
%   imaginary axis interpretation.  The required variable, OMEGA_DK,
%   is interpreted as either imaginary axis values (DISCRETE_DK==0)
%   or angle (in radians) on the unit disc (DISCRETE_DK==1)

DISCRETE_DK = 0;


% AUTOINFO_DK (used for automatic iteration, ie. batch mode)
%   This should be a row vector, 1 x (3+size(BLK_DK,1)).  The
%   interpretations of each term is given below:
%
%   The first entry is the beginning iteration number, usually 1,
%       except when you are resuming, or restarting, an existing
%       iteration.
%   The second entry is the final iteration number.  The automatic
%       iteration will complete this iteration, and then stop.
%   The third entry is a Visual Flag.  If AUTOINFO_DK(3)==1, then
%       the results of the DK-iteration are displayed (both in figures
%       and in the Command Window).    If AUTOINFO_DK(3)==0, then
%       no results are displayed.
%   The remaining entries (there are as many as there are uncertainty
%       blocks in the uncertainty set described by BLK_DK) denote the
%       maximum dynamic order of the rational D-scalings.
%
%   Hence, to
%           Begin at Iteration 3
%           End after Iteration 7
%           Display Results to screen
%           Use 4th order (maximum) systems in entries of scaling matrix
%   define
%           AUTOINFO_DK = [3 7 1 4*ones(1,size(BLK_DK,1))];

AUTOINFO_DK = [1 4 1 6 6 6 3];

% Suffix appended to all variables exported to workspace
NAME_DK = 'suffix';