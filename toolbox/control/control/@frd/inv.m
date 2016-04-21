function sysinv = inv(sys,method)
%INV  LTI model inverse.
%
%   ISYS = INV(SYS) computes the inverse model ISYS such that
%
%       y = SYS * u   <---->   u = ISYS * y 
%
%   The LTI model SYS must have the same number of inputs and
%   outputs. For arrays of LTI models, INV is performed on each 
%   individual model.
%   
%   See also MLDIVIDE, MRDIVIDE, LTIMODELS.

%     Users can supply their own inversion method with the
%     syntax  INV(SYS,METHOD).  For instance, 
%        isys = inv(sys,'myway')
%     executes
%        isys.ResponseData = myway(sys.ResponseData)
%     to perform the inversion.

%       Author(s): S. Almy
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.7.4.1 $  $Date: 2004/04/16 22:01:36 $

% Effect on other properties: exchange Input/Output Names, rest deleted.

sizes = size(sys.ResponseData);

% Error checking and quick exits
if any(sizes==0),
   sysinv = sys.';  
   return
elseif sizes(1)~=sizes(2),
   error('Cannot invert non-square system.');
elseif nargin>1,
   % User-supplied method
   sysinv = sys;
   sysinv.ResponseData = feval(method,sys.ResponseData);
   sysinv.lti = inv(sys.lti);
   return
elseif hasdelay(sys)
   error('Inverse of delay system is non causal.');
end


% Compute inverse
sysinv = sys;
for k = 1:prod(sizes(3:end))
   [L,U,P] = lu(sys.ResponseData(:,:,k));
   if rcond(U) < 10*eps
      error('Cannot invert FRD model with singular frequency response.');
   else
      sysinv.ResponseData(:,:,k) = U\(L\P);
   end
end

% Update LTI properties
sysinv.lti = inv(sys.lti);
