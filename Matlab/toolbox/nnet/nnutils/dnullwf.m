function d=dnullwf(code,w,p,z)
%DNULLWF Null weight derivative function.
%
%  Syntax
%  
%    dZ_dP = dnullwf('p',W,P,Z)
%    dZ_dW = dnullwf('w',W,P,Z)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

switch code
  case 'p', d = zeros(size(w));
  case 'w', d = zeros(size(p));
  otherwise, error(['Unrecognized code.'])
end
