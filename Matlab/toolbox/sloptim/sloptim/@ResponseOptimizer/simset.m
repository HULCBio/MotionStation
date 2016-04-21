%SIMSET  Modify simulation settings for response optimization project.
%
%   SIMSET(PROJ,'SETTING1',VALUE1,'SETTING2',VALUE2,...) modifies the
%   simulation settings within the response optimization project, PROJ. The
%   value of the simulation setting, SETTING1, is set to VALUE1, SETTING2
%   is set to VALUE2, etc.
%
%   For a detailed list of simulation options and the possible values they
%   can take, see the reference page for the Simulink function SIMSET. The
%   default values of the simulation options for the project are the same
%   as those used by the Simulink model the project is associated with.
%   Changes that are made to the project’s simulation settings will only be
%   used during simulations that are run as part of the optimization and
%   will not affect the simulation settings for the model.
%
%   Example:
%      proj = newsro('srotut1','Kint')
%      simget(proj)
%      simset(proj,'Solver','ode23','AbsTol',1e-7)
%
%   See also RESPONSEOPTIMIZER/OPTIMGET, RESPONSEOPTIMIZER/OPTIMSET,
%   RESPONSEOPTIMIZER/SIMGET.

%  Author(s): Pascal Gahinet
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/04/19 01:33:44 $