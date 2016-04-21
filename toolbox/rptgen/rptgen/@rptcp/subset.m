function rez=subset(p,idx)
%SUBSET takes a subset of a pointer list
%   S=SUBSET(P,[1 3 5])
%   This function exists to replace P{[1 3 5]} because 
%   subsref with curly brackets now assumes a comma-
%   separated list in the output.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:03 $

if strcmp(idx,'end')
    rez=rptcp(p.h(end));
else
    rez=rptcp(p.h(idx));
end
