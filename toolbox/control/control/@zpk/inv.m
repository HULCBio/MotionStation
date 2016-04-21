function sys = inv(sys,method)
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
%         isys = inv(sys,'myway')
%     executes
%         [isys.z,isys.p,isys.k] = myway(sys.z,sys.p,sys.k)
%     to perform the inversion.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18.4.1 $

% Effect on other properties: exchange Input/Output Names
% Everything else is blown away

sizes = size(sys.k);
ny = sizes(1);  
nu = sizes(2);

% Error checking and quick exits
if any(sizes==0),
   sys = sys.';  
   return
elseif ny~=nu,
   error('Cannot invert non-square system.');
elseif nargin>1,
   % User-supplied method
   [sys.z,sys.p,sys.k] = feval(method,sys.z,sys.p,sys.k);
   sys.lti = inv(sys.lti);
   return
elseif hasdelay(sys)
   Ts = getst(sys);
   if Ts,
      % Map delay times to poles at z=0 in discrete-time case
      sys = delay2z(sys);
   else
      error('Inverse of delay system is non causal.')
   end   
end


% Compute inverse
if ny==1,
   % SISO system
   [z,p,k] = zpkdata(sys);
   if k==0,
      error('Cannot invert ZPK models with zero gain.')
   end
   
   sys.z = p;
   sys.p = z;
   sys.k = 1/k;
   sys.lti = inv(sys.lti);
elseif ~isproper(sys),
   error('Cannot invert of non proper MIMO models.');
else
   % Convert to state space and then invert
   try 
      sys = zpk(inv(ss(sys)));
   catch
      error('Cannot invert MIMO models with singular feedthrough matrix.')
   end
end

