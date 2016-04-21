function mpc_chkts(Ts)

%MPC_CHKTS Check correctness of sampling time

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:12 $   

if ndims(Ts)>2 | ~isreal(Ts) | ~isfinite(Ts) | length(Ts)~=1,
   error('mpc:mpc_chkts:scalar','Sampling time must be a real positive number or empty.')
elseif Ts<=0,
   error('mpc:mpc_chkts:zero','Sampling time cannot be less than or equal to 0');
end

