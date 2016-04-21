function w = FreqVectorCheck(w)
%FREQCHECK  Check frequency input is valid vector or frequency range.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $ $Date: 2002/04/04 15:22:42 $

% Error checking
if iscell(w)
   % W = {WMIN , WMAX}
   if ndims(w)>2 | prod(size(w))~=2,
      error('Frequency range must be specified as a cell array {WMIN,WMAX}.')
   end
   wmin = w{1}(1); 
   wmax = w{2}(1);
   if ~isreal(wmin) | prod(size(wmin))~=1
      error('Lower frequency WMIN must be a real scalar.')
   elseif ~isreal(wmax) | prod(size(wmax))~=1
      error('Upper frequency WMAX must be a real scalar.')
   elseif wmin<=0 | wmax<=wmin,
      error('Frequency range must satisfy 0<WMIN<WMAX.')
   end
elseif ~isreal(w) | ndims(w)>2 | min(size(w))>1 | any(w<0) | any(isnan(w))
   error('Frequency points must be specified as a vector of positive real numbers.')
else
   w = w(:);
end