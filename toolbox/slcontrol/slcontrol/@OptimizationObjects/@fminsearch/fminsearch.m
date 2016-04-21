function this = fminsearch(opcond,options)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:36:52 $

%% Construct the object
this = OptimizationObjects.fminsearch;
this.linoptions = options;
initialize(this,opcond);