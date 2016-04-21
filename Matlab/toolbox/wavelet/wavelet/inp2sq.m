function Y = inp2sq(xDEC,level)
%INP2SQ In Place to "square" storage of coefficients.
%   Y = INP2SQ(xDEC,LEVEL) returns the "Square" storage
%   for a 2-D wavelet decomposition obtained by Lifting.
%
%   Example:
%      load woman; L = 3
%      XinP = lwt2(X,'db2,L);
%      Xsq  = inp2sq(XinP,L);
%
%   See also ILWT2, LWT2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-May-2001.
%   Last Revision: 26-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:44 $

wname = 'dummy';
Y = lwtcoef2('ca',xDEC,wname,level,level);
for k = level:-1:1
    H = lwtcoef2('ch',xDEC,wname,level,k);
    V = lwtcoef2('cv',xDEC,wname,level,k);
    D = lwtcoef2('cd',xDEC,wname,level,k);
    Y = [Y , H ; V , D];
end
