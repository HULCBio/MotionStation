function [E,V] = dpssclear(N,NW)
%DPSSCLEAR  Remove discrete prolate spheroidal sequences from database.
%   DPSSCLEAR(N,NW) removes the DPSSs with length N and time-halfbandwidth 
%   product NW, from the DPSS MAT-file database, 'dpss.mat'.  
%
%   See also DPSS, DPSSSAVE, DPSSLOAD, DPSSDIR.

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $

error(nargchk(2,2,nargin))
index = dpssdir;

if ~isempty(index)
    w = which('dpss.mat');

    i = find([index.N] == N);
    if isempty(i)
        error('No DPSSs in the database of given length.')
    end
    j = find([index(i).wlist.NW] == NW);
    if isempty(j)
        error(...
          sprintf('No DPSSs in the database of given length with NW = %g.',NW))
    end

    key = index(i).wlist(j).key;
    index(i).wlist(j) = [];
    if length(index(i).wlist) == 0
       index(i) = [];
    end

    str = sprintf('E%g = []; V%g = [];',key,key);
    eval(str)
    str = sprintf('save(''%s'',''E%g'',''V%g'',''index'',''-append'')',w,key,key);
    eval(str)
end
