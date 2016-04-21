%OPTIMGET  Return structure of optimization options.
% 
%   OPT_SETTINGS=OPTIMGET(PROJ) returns the current optimization settings
%   object, OPT_SETTINGS, for the project PROJ. Use OPTIMSET to modify the
%   optimization options.
%
%   For a list of all possible settings and the values they can take, see
%   the documentation for the MATLAB function OPTIMSET.
%
%   Example:
%     proj = newsro('srotut1','Kint');
%     opt_settings = optimget(proj)
%   
%   See also RESPONSEOPTIMIZER/OPTIMSET, RESPONSEOPTIMIZER/SIMGET,
%   RESPONSEOPTIMIZER/SIMSET.

%  Author(s): Pascal Gahinet
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/04/19 01:33:39 $