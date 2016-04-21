function x = mpc_chkstate(state,type,n,off);

%MPC_CHKSTATE Check extended state vector, and possibly remove offsets
%
% state: extended state vector (MPCSTATE object)
% type:  either 'Plant' or 'Dist' or 'Noise' or 'LastMove'
% n:     number of components

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/10 23:35:20 $   

x = get(state,type);
if isempty(x),
    x = zeros(n,1); % Default: Nominal.X(type) or Nominal.U(mvindex)
else
    if ~isa(x,'double'),
        error('mpc:mpc_chkstate:real','State components must be real valued.')
    elseif ~all(isfinite(x)), %some x(i) are Inf
        error('mpc:mpc_chkstate:inf','Infinite state components are not allowed.')
    else
        [nx,mx] = size(x);
        if nx*mx~=n, 
            if strcmp(type,'LastMove'),
                error('mpc:mpc_chkstate:udim',sprintf('The vector of previous inputs should have dimension %d.',n));
            else
                error('mpc:mpc_chkstate:xdim',sprintf('State.%s should be a vector of dimension %d.',type,n));
            end
        end
        x = x(:)-off;
    end
end
