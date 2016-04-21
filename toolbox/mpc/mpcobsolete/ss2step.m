function [plant] = ss2step(phi, gam, c, d, tfinal, delt1, delt2, nout)

%SS2STEP Calculate step response model from a continuous or discrete SS model.
%  	plant = ss2step(phi, gam, c, d, tfinal)
%   	plant = ss2step(phi, gam, c, d, tfinal, delt1, delt2, nout)
%
% Inputs:
%   phi,gam,c,d:   appropriate state-space realization of system.
%   tfinal:        truncation time for step response model.
%   delt1:         sampling interval of realization. For continuous systems
%                  this argument is set to zero.
%                  Optional: default value is delt1=0.
%   delt2:         desired sampling interval for step response model.
%                  Optional: default value is delt2=delt1 if delt1 is
%                  specified. Otherwise, default value is delt2=1.
%   nout:          output stability indicator. For stable systems, this
%                  argument is set equal to number of outputs, ny. For
%                  systems with one or more integrating outputs, this
%                  argument is a column vector of length ny with nout(i)=0
%                  indicating an integrating output and nout(i)=1
%                  indicating a stable output. Optional: default value is
%                  nout=ny. (only stable outputs).
% Output:
%   plant:         step response coefficient matrix in MPC step format.
%
% See also PLOTSTEP, MOD2STEP, TFD2STEP.

%  Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $


if nargin == 0
   disp('usage: plant = ss2step(phi, gam, c, d, tfinal, delt1, delt2, nout)');
   return;
end;

% check incoming data
if nargin < 5 | nargin > 8
    error(' Incorrect number of input arguments.')
end

[ny,na] = size(c);
[ord,nu]  = size(gam);

if (nargin == 5)
    delt2 = 1;
    delt1 = 0;
 end;
if (nargin == 6)
    delt2=delt1;
end;

if (isempty(delt2) & isempty(delt1))
    delt1=0;
    delt2=1;
else
    if isempty(delt2) & delt1 ~= 0,
       delt2=delt1;
    elseif isempty(delt2) & delt1 == 0,
       delt2=1;
    end
    if isempty(delt1)
       delt1=0;
    end
end

if (nargin == 8)
    if isempty(nout)
       nout=ones(ny,1);
    end
    if length(nout)==1
       if nout==0
          if ny~=1
             error('nout is not consistent with realization')
          end;
       else
          if nout~=ny
             error('nout is not consistent with realization')
          end;
       end;
    else
          if length(nout)~=ny
             error('nout is not consistent with realization')
          end;
    end;
else
     nout=ones(ny,1);
end;

if (d==0)
    d=zeros(ny,nu);
end
error(abcdchkm(phi,gam,c,d));
if delt1==0,
    [phi,gam]=c2dmp(phi,gam,delt2);
end;
if delt1~=delt2 & delt1~=0,
    [phi,gam]=d2cmp(phi,gam,delt1);
    [phi,gam]=c2dmp(phi,gam,delt2);
end;
n = max(round(tfinal/delt2)+1,2);
nny=n*ny;
step=ones(n,1);
for iu = 1:nu
    y = dlsimm(phi,gam(:,iu),c,d(:,iu),step);
    y=y';
    plant(:,iu) = y(:);
end;
 plant=plant(ny+1:nny,:);
 nny=nny-ny;

if length(nout)==1 & nout~=0
        nout=ones(ny,1);
end;

plant(nny+1:nny+ny+2,1)=[nout;ny;delt2];

%end;
% end of function SS2STEP.M