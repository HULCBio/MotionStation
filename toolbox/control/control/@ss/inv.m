function sysinv = inv(sys)
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

%       Author(s): A. Potvin, 3-1-94, P. Gahinet, 4-1-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.19.4.1 $

% Effect on other properties: exchange Input/Output Names
% Everything else is blown away

sizes = size(sys.d);
if any(sizes==0),
   sysinv = sys.';  return
elseif sizes(1)~=sizes(2),
   error('Non-square models cannot be inverted.');
elseif hasdelay(sys),
   error('Inverse of delay system is non causal.')
end

sysinv = sys;
for k=1:prod(sizes(3:end))
   % Extract data for k-th model
   % RE: use SSDATA to eliminate E matrix
   [a,b,c,d] = ssdata(subsref(sys,substruct('()',{':' ':' k})));
   nx = size(a,1);
   
   % LU decomposition of D
   [l,u,p] = lu(d);
   if rcond(u)<10*eps,
      error('Cannot invert system with singular D matrix.');
   end
   
   % Compute matrices of inverse model
   bdinv = (((b/u)/l)*p);
   sysinv.a{k} = a - bdinv * c;
   sysinv.b{k} = bdinv;
   sysinv.c{k} = -u\(l\(p*c));
   sysinv.d(:,:,k) = u\(l\p);
   % Stripping E matrix to match ssdata usage
   sysinv.e{k} = [];
end
sysinv.lti = inv(sys.lti);

