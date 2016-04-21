function OUT = lwtcoef(type,xDEC,LS,level,levEXT)
%LWTCOEF Extract or reconstruct 1-D LWT wavelet coefficients.
%   Y = LWTCOEF(TYPE,XDEC,LS,LEVEL,LEVEXT) returns the coefficients
%   or the reconstructed coefficients of level LEVEXT, extracted 
%   from XDEC, the LWT decomposition at level LEVEL obtained with 
%   the lifting scheme LS.
%   The valid values for TYPE are:
%      - 'a'  for approximations
%      - 'd'  for details
%      - 'ca' for coefficients of approximations
%      - 'cd' for coefficients of details
%
%   Y = LWTCOEF(TYPE,XDEC,W,LEVEL,LEVEXT) returns the same output
%   using W which is the name of a "lifted wavelet".
%
%   See also ILWT, LWT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Feb-2000.
%   Last Revision: 30-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:59 $

firstIdxAPP = 1;
firstIdxDET = 1+mod(firstIdxAPP,2);
DELTA = firstIdxAPP-1;
indCFS = [1:length(xDEC)];
indEXT = (1-DELTA)*ones(1,levEXT);
switch type
  case {'a','ca'}
  case {'d','cd'} , indEXT(levEXT) = DELTA;
end

% Extract coefficients.
for k=1:levEXT
    first = 2-indEXT(k);
    indCFS = indCFS(first:2:end);
end

switch type
  case {'a','d'}
    OUT = zeros(size(xDEC));
    OUT(indCFS) = xDEC(indCFS);
    OUT = ilwt(OUT,LS,level);

  case {'ca','cd'}
    OUT = xDEC(indCFS);
    if isequal(type,'ca') & (level>levEXT)
        OUT = ilwt(OUT,LS,level-levEXT);
    end
end
