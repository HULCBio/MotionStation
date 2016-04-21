function op = linevent(model,snapshottimes,varargin);
%SIMLINCOND Returns an object to set up a simulation time based
%linearization or operating condition snapshot
%

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2003/12/04 02:37:05 $

%% Create the constraint object
op = LinearizationObjects.TimeEvent;

%% Set the model property
op.Model = model;

%% Set the linearization times
op.Times = snapshottimes;

%% Handle additional parameters
if (nargin == 3)
    this.simopts = varargin{2};
elseif (nargin == 4)
    this.simopts = varargin{2};
    this.ut = varargin{3};
end