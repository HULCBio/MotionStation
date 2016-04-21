% function out = varyrand(rdim,cdim,nindv,ivflg)
%
%  Create a random VARYING matrix, with a specified number of
%  rows RDIM, columns CDIM, and independent variable values NINDV.
%  The default value for IVFLG is 0 which sorts the positive,
%  random independent variables to be monotonically increasing.
%  If IVFLG is set to a nonzero value, then the independent variable's
%  values are 1:NINDV.
%
%   See also: CRAND, RAND, SYSRAND, and RANDEL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function out = varyrand(rdim,cdim,nindv,ivflg)
 if nargin < 3
   disp(['usage: out = varyrand(rdim,cdim,nindv)']);
 else
   if nargin == 3
     ivflg = 0;
   end
   if min([rdim cdim nindv]) <= 0
     error('dimensions should be positive')
     return
   elseif ceil([rdim cdim nindv]) == floor([rdim cdim nindv])
     out = zeros(rdim*nindv+1,cdim+1);
     out(rdim*nindv+1,cdim+1) = inf;
     out(rdim*nindv+1,cdim) = nindv;
     if ivflg == 0
       out(1:nindv,cdim+1) = sort(exp(rand(nindv,1)));
     else
       out(1:nindv,cdim+1) = (1:nindv)';
     end
     out(1:nindv*rdim,1:cdim) = rand(nindv*rdim,cdim);
   else
     error('dimensions should be integers')
     return
   end
 end

%
%