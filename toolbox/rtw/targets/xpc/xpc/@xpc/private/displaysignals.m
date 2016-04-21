function displaySignals(xpcObj)
%DISPLAYSIGNALS Displays signals for a target model (Private).

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $Date: 2004/04/08 21:03:38 $

modelname = get(xpcObj, 'Application');

signames = xpcgate('getbio', modelname);
npar     = length(signames);
index    = 0;

for i = 1 : npar
   sig    = signames{i};
%   sindex = find(sig == '/');
%   sig    = sig(sindex(1)+1:end);
   fprintf(2, '   %-23s%-8s%-18f%-10s\n',' ',['S',num2str(i-1)],xpcgate('getmonsignals',i-1),sig);   
end
fprintf(2, '\n');

%% EOF displaySignals.m