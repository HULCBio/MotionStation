function report_decision_setup(varargin)
% DECISION_SETUP - Generate a global data structure 
% to support reporting for decision coverage.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:46 $

    global gdecision;
    
    gdecision = varargin{1}.metrics.decision;
    
    for i=2:length(varargin)
        gdecision = [gdecision varargin{i}.metrics.decision];
    end
