function [results] = cftoolgetresults(cftoolFit, newName)
%CFTOOLGETRESULTS Records new fit name and returns results.

%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:40:12 $
%   Copyright 2004 The MathWorks, Inc.

cftoolFit=handle(cftoolFit);
cftoolFit.name=newName;
results = cftoolFit.results;

