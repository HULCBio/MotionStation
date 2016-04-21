function [name, dL, dH, dLLE, dHLE, rL, rH, rLLE, rHLE, ds] = cftoolgetcopyexcludeinfo(outlier)
%CFTOOLGETOPENEDITORINFO Get information needed to copy a cftool exclusion rule 

%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:40:10 $
%   Copyright 2004 The MathWorks, Inc.

outlier = handle(outlier);

name = outlier.name;

dL = outlier.domainLow;
dH = outlier.domainHigh;
dLLE = outlier.domainLowLessEqual;
dHLE = outlier.domainHighLessEqual;

rL = outlier.rangeLow;
rH = outlier.rangeHigh;
rLLE = outlier.rangeLowLessEqual;
rHLE = outlier.rangeHighLessEqual;

ds = outlier.dataset;

    


