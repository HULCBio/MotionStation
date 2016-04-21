function runreport(rptname)
%RUNREPORT  Run the specified report
%   This file functions as an error-catching wrapper for the directory
%   reports in the current directory browser.

% Copyright 1984-2004 The MathWorks, Inc.

try
    
    feval(rptname);
    
catch
    
    errMsg = sprintf('<html><body><span style="color:#F00">Error generating report.<p/>%s\n</span></body></html>', ...
        lasterr)

    web(['text://' errMsg],'-noaddressbox');

end
