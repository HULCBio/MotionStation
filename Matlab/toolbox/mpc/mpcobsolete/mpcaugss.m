function [phia,gama,ca,da,na]=mpcaugss(phi,gam,c,d)

%MPCAUGSS Augment a state space model with the output variables.
%        [phia,gama,ca]=mpcaugss(phi,gam,c)
%        [phia,gama,ca,da,na]=mpcaugss(phi,gam,c,d)
% The new states are the differences in the old states
% augmented by the outputs.  The inputs are all differenced.
% The d matrix is optional.  The default is zero.
%
% Inputs:
%  phi  is phi of a plant model in the MPC format.
%  gam  is gam of a plant model in the MPC format.
%  c    is c of a plant model in the MPC format.
%  d    is d of a plant model in the MPC format.
%
% outputs:
%  phia  is phi of a plant model in the MPC format.
%  gama  is gam of a plant model in the MPC format.
%  ca    is c of a plant model in the MPC format.
%  da    is d of a plant model in the MPC format.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $


if nargin == 0
   disp('USAGE:  [phia,gama,ca,da,na]=mpcaugss(phi,gam,c,d)')
   return
elseif nargin < 3 | nargin > 4
   error('Must supply either 3 or 4 input arguments.')
end

[n,nu]=size(gam);
[rowsp,colsp]=size(phi);
[ny,colsc]=size(c);

if nargin == 3
   d=zeros(ny,nu);
elseif isempty(d)
   d=zeros(ny,nu);
end

[rowsd,colsd]=size(d);

if rowsp ~= colsp
   error('PHI matrix must be square')
elseif n ~= rowsp
   error('PHI and GAM must have same number of rows')
elseif n ~= colsc
   error('PHI and C must have same number of columns')
elseif nu ~= colsd
   error('GAM and D must have same number of columns')
elseif ny ~= rowsd
   error('C and D must have same number of rows')
end

phia=[phi, zeros(n,ny);  c*phi, eye(ny)];
gama=[gam; c*gam+d];
ca=[zeros(ny,n), eye(ny)];
da=d;
na=n+ny;