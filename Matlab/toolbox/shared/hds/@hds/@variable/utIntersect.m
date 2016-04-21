function [ia,ib] = utIntersect(Vars1,Vars2)
% Optimized intersect for variable handles

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:43 $
nv = length(Vars1);
[c,ndx] = sort([Vars1;Vars2]);
d = find(c(1:end-1)==c(2:end));
ndx = ndx([d;d+1]);
b = ndx > nv;
ia = ndx(~b);
ib = ndx(b)-nv;
