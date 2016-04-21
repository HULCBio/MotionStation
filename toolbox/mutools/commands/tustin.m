%function dsys = tustin(csys,T,prewarpf);
%
%   Perform a continuous (CSYS) to discrete (DSYS) conversion
%   by the prewarped Tustin method.  T is the sample time
%   (in seconds) and PREWARP is the prewarp frequency in
%   rad/sec. If no prewarp frequency is specified, a standard
%   bilinear transformation is performed.
%
%   See also: DTRSP and SAMHLD.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function dsys = tustin(csys,T,prewarpf);
if nargin ~= 3 & nargin ~= 2,
    disp('usage: dsys = tustin(csys,T,prewarpf)')
    return
    end

%       the bilinear case is obtained in the limit as the prewarp
%       frequency goes to zero.  For this case substitute the
%       scaling alpha rather than have matlab crash on a 0/0
%       calculation.
%
if nargin == 3,
    if prewarpf < -eps,
        error(' negative prewarp frequency')
        return
    elseif prewarpf < eps,
        alpha = 2/T;
    else
        alpha = prewarpf/tan(T*prewarpf/2);
        end
else
    alpha = 2/T;
    end

[type,ny,nu,nx] = minfo(csys);
if type == 'cons'
  dsys = csys;
elseif type == 'syst'

  [a,b,c,d] = unpck(csys);

  invterm = inv(eye(nx) - (1/alpha)*a);

  dsys = zeros(nx+ny+1,nx+nu+1);
  dsys(1:nx,1:nx) = (eye(nx) + (1/alpha)*a)*invterm;
  dsys(1:nx,nx+1:nx+nu) = invterm*b*sqrt(2/alpha);
  dsys(nx+1:nx+ny,1:nx) = sqrt(2/alpha)*c*invterm;
  dsys(nx+1:nx+ny,nx+1:nx+nu) = c*invterm*b*(1/alpha) + d;

  dsys(nx+ny+1,nx+nu+1) = -inf;
  dsys(1,nx+nu+1) = nx;
else
    error('Not a SYSTEM matrix')
    return
    end
%
%