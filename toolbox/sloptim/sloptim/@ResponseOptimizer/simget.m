%SIMGET  Retrieve current simulation settings for response optimization
%project.
% 
%   SIMOPTIONS=SIMGET('PROJ') returns a object containing the current
%   simulation options, SIMOPTIONS, used by the response optimization
%   project, PROJ. To modify the project’s simulation settings, use the
%   function SIMSET.
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
%
%   See also RESPONSEOPTIMIZER/OPTIMGET, RESPONSEOPTIMIZER/OPTIMSET,
%   RESPONSEOPTIMIZER/SIMSET.

%  Author(s): Pascal Gahinet
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/04/19 01:33:43 $