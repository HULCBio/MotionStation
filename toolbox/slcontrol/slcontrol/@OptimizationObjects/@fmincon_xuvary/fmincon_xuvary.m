function this = fmincon_xuvary(opcond,options)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:35:06 $

%% Construct the object
this = OptimizationObjects.fmincon_xuvary;
this.linoptions = options;
initialize(this,opcond);