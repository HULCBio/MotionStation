function [E,V] = dpssload(N,NW)
%DPSSLOAD  Load discrete prolate spheroidal sequences from database.
%   [E,V] = DPSSLOAD(N,NW) are the  DPSSs E and their concentrations V, with 
%   length N and time-halfbandwidth product NW, as stored in the DPSS MAT-file 
%   database, 'dpss.mat'.  
%
%   See also DPSS, DPSSSAVE, DPSSDIR, DPSSCLEAR.

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.6 $

index = dpssdir(N,NW);
if isempty(index)
    error('DPSSs of given length N and parameter NW are not in database.')
else
    key = index.wlist.key;
    str = sprintf('load dpss E%g V%g', key, key);
    eval(str)
    str = sprintf('E = E%g; V =  V%g;', key, key);
    eval(str)
end

