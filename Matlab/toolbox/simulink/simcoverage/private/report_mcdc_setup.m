function report_mcdc_setup(varargin)
% MCDC_SETUP - Generate a global data structure 
% to support reporting for mcdc coverage.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:51 $

    global gmcdc;
    
    gmcdc = varargin{1}.metrics.mcdc;
    
    for i=2:length(varargin)
        appendMetric = varargin{i}.metrics.mcdc;
        if isempty(appendMetric)
            appendMetric = zeros(length(gmcdc), 1);
        end; %if
        gmcdc = [gmcdc appendMetric];
    end
    


