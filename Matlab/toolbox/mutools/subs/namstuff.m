% function [numsys,names,namelen,maxlen] = namstuff(systemnames);

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [numsys,names,namelen,maxlen] = namstuff(systemnames);
  maxlen = 0;
  names = [];
  tmpln = length(systemnames);
  iloc = find(systemnames ~= ']' & systemnames ~= '[');
  tmp = [' ' systemnames(iloc) ' '];
  blks = find(tmp == ' ');
  blksd = diff(blks);
  imp = find(blksd>1);
  numsys = length(imp);
  namelen = zeros(numsys,1);
  for i=1:numsys
     nn = tmp(blks(imp(i))+1:blks(imp(i)+1)-1);
     if length(nn) > maxlen
       maxlen = length(nn);
     end
     namelen(i) = length(nn);
     names = [names ; [nn mtblanks(tmpln-length(nn))]];
  end
  names = names(:,1:maxlen);