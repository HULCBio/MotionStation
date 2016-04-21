%OPTIMSET  Set optimization options for response optimization project.
% 
%   OPTIMSET(PROJ,'SETTING1',VALUE1,'SETTING2',VALUE2,...) modifies the
%   optimization settings within the response optimization project, PROJ.
%   The value of the optimization setting, SETTING1, is set to VALUE1,
%   SETTING2 is set to VALUE2, etc.
%
%   For a list of all possible settings and the values they can take, see
%   the documentation for the MATLAB function OPTIMSET.
%
%   Example:
%     proj = newsro('srotut1','Kint');
%     opt_settings = optimget(proj)
%     optimset(proj,'MaxIter',150)
%
%   See also RESPONSEOPTIMIZER/OPTIMGET, RESPONSEOPTIMIZER/SIMGET,
%   RESPONSEOPTIMIZER/SIMSET

%  Author(s): Pascal Gahinet
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/04/19 01:33:41 $