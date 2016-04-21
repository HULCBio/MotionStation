function report_sigrange_setup(varargin)
% SIGRANGE_SETUP - Generate a global data structure 
% to support reporting for condition coverage.

% Copyright 2003 The MathWorks, Inc.

    global gsigrange;
    
    gsigrange = varargin{1}.metrics.sigrange;
    
    for i=2:length(varargin)
        gsigrange = [gsigrange varargin{i}.metrics.sigrange];
    end
    
