function OUT = lwtcoef2(type,xDEC,LS,level,levEXT)
%LWTCOEF2 Extract or reconstruct 2-D LWT wavelet coefficients.
%   Y = LWTCOEF2(TYPE,XDEC,LS,LEVEL,LEVEXT) returns the coefficients
%   or the reconstructed coefficients of level LEVEXT, extracted from
%   XDEC, the LWT decomposition at level LEVEL obtained with the 
%   lifting scheme LS.
%   The valid values for TYPE are:
%      - 'a' for approximations
%      - 'h', 'v', 'd'  for horizontal, vertical and diagonal details
%         respectively.
%      - 'ca' for  coefficients of approximations
%      - 'ch', 'cv', 'cd'  for  coefficients of horizontal, vertical
%        and diagonal details respectively.
%
%   Y = LWTCOEF2(TYPE,XDEC,W,LEVEL,LEVEXT) returns the same output 
%   using W which is the name of a "lifted wavelet".
%
%   See also ILWT2, LWT2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Feb-2000.
%   Last Revision: 10-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:40:00 $

firstIdxAPP = 1;
firstIdxDET = 1+mod(firstIdxAPP,2);
DELTA = firstIdxAPP-1;

[R,C]  = size(xDEC);
indCFS_ROW = [1:R];
indCFS_COL = [1:C];
indROW = (1-DELTA)*ones(1,levEXT);
indCOL = (1-DELTA)*ones(1,levEXT);
switch type
  case {'a','ca'}
  case {'h','ch'} , indROW(levEXT) = DELTA;
  case {'v','cv'} , indCOL(levEXT) = DELTA;
  case {'d','cd'} , indCOL(levEXT) = DELTA; indROW(levEXT) = DELTA;
end

% Extract coefficients.
for k=1:levEXT
    firstROW = 2-indROW(k);
    firstCOL = 2-indCOL(k);
    indCFS_ROW = indCFS_ROW(firstROW:2:end);
    indCFS_COL = indCFS_COL(firstCOL:2:end);
end
OUT = xDEC(indCFS_ROW,indCFS_COL);
if isequal(type,'ca') & (level>levEXT)
    OUT = ilwt2(OUT,LS,level-levEXT);
end

switch type
  case {'a','h','v','d'}
    xTMP = zeros(R,C);
    xTMP(indCFS_ROW,indCFS_COL) = OUT;
    OUT = ilwt2(xTMP,LS,level);
end
