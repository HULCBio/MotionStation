function model=addmd(pmod,dmod)

% ADDMD	Add a measured disturbance model to a plant model.
%       model=addmd(pmod,dmod)
% ADDMD creates a composite model in which the outputs
% are the sum of the outputs of pmod and dmod.  The inputs
% of the composite model are the manipulated variables from
% pmod, followed by the inputs to dmod (which are all classified
% as measured disturbances in the composite model), followed by
% the unmeasured disturbances from pmod (if any).
%
% Inputs:
%  pmod  is the plant model in the MPC mod format.
%  dmod  is the disturbance model in the MPC mod format.
%
% Outputs:
%  model is the composite model in the MPC mod format.
%
% See also  ADDMOD, ADDUMD, APPMOD, PARAMOD, SERMOD.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin ~= 2
   disp('USAGE:  model=addmd(pmod,dmod)')
   return
end
[a,b,c,d,minfo]=mod2ss(pmod);
[ad,bd,cd,dd,minfod]=mod2ss(dmod);

T1=minfo(1);     T2=minfod(1);
n1=minfo(2);     n2=minfod(2);
nu1=minfo(3);    nu2=minfod(3);
nd1=minfo(4);    nd2=minfod(4);
nw1=minfo(5);    nw2=minfod(5);
nym1=minfo(6);   nym2=minfod(6);
nyu1=minfo(7);   nyu2=minfod(7);

if minfo(1)~=minfod(1)
   error('PMOD and DMOD have different sampling periods.')
elseif any([nym1 nyu1] ~= [nym2 nyu2]);
   error('PMOD and DMOD have different number of measured/unmeasured outputs')
elseif  nd1 ~= 0
   error('PMOD already contains measured disturbances.')
elseif  nd2 ~= 0 | nw2 ~= 0
   error('All inputs to DMOD must be classified as manipulated variables.')
end

% Put the two models in parallel.

[a,b,c,d]=mpcparal(a,b,c,d,ad,bd,cd,dd);

% If pmod had an unmeasured disturbance, move those elements of b and d into
% the proper position.

if nw1 ~= 0
   map=[1:nu1, nu1+nw1+1:nu1+nw1+nu2, nu1+1:nu1+nw1];
   if ~ isempty(b)
      b=b(:,map);
   end
   d=d(:,map);
end
minfom=[T1 n1+n2 nu1 nu2 nw1 nym1 nyu1];
model=ss2mod(a,b,c,d,minfom);

%%% end of function addmd.m %%%