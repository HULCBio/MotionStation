function optimSetup(this)
% Performs initialization tasks when optimization starts.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/11 00:46:32 $

% Reset data logs
this.DataLog.X = [];
this.GradLog = [];
   
% Notify dependencies
E = handle.EventData(this,'OptimStart');
this.send('OptimStart',E)
