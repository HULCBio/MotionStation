function report_condition_setup(varargin)
% CONDITION_SETUP - Generate a global data structure 
% to support reporting for condition coverage.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:41 $

    global gcondition;
    
    gcondition = varargin{1}.metrics.condition;
    
    for i=2:length(varargin)
        gcondition = [gcondition varargin{i}.metrics.condition];
    end
    
    
    
