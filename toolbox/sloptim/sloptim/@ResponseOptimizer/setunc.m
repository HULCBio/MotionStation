%SETUNC  Specify parameter uncertainty in response optimization project.
%
%   SETUNC(PROJ,UNC_SETTINGS) sets the parameter uncertainty specifications
%   for the response optimization project, PROJ. Use the functions GRIDUNC
%   or RANDUNC to specify the uncertainty settings, UNC_SETTINGS.
%
%   Example:
%      proj = newsro('srotut1','Kint');
%      uset = gridunc('zeta',[0.9,1,1.1],'w0',[0.95,1,1.05])
%      % Include responses for all uncertain values in optimization
%      uset.Optimized = true 
%      % Add uncertainty to project
%      setunc(proj,uset)
%
%   See also GRIDUNC, RANDUNC

%  Author(s): Pascal Gahinet
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/04/19 01:33:42 $

