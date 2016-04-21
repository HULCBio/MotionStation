% CALLED by LMIEDIT to parse blocks

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [token,tmap,blck,map]=parslblk(blck,map,seps)

% seps=string of delimiters

lb=length(blck);
if lb<2, token=blck; tmap=map; map=[]; blck=[]; return, end
i=2;

while(~any(blck(i)==seps) | map(i)~=0),
  i=i+1;
  if (i > lb), token=blck; tmap=map; map=[]; blck=[]; return, end
end

token=blck(1:i-1);
tmap=map(1:i-1);

if blck(i)=='-',
  blck=blck(i:lb);
  map=map(i:lb);
else
  blck=blck(i+1:lb);
  map=map(i+1:lb);
end
