function [Ts,Ds,n2m] = wp2wtree(Ts,Ds)
%WP2WTREE Extract wavelet tree from wavelet packet tree.
%   [T,D] = WP2WTREE(T,D) computes the modified tree
%   structure T and data structure D (see MAKETREE),
%   corresponding to the wavelet decomposition tree.
%
%   See also MAKETREE, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.13 $

% Check arguments.
if errargn(mfilename,nargin,[2],nargout,[2:3]), error('*'); end

depth = wtreemgr('depth',Ts);
if depth==0
    n2m = [];
    return
end

order  = wtreemgr('order',Ts);
an     = wtreemgr('allnodes',Ts);
tn     = wtreemgr('tnodes',Ts);
ind_an = wcommon(an,tn);
an     = an(ind_an==0);
[d,p]  = ind2depo(order,an);
n2m    = [];
for k=1:order-1
    n2m = [n2m ; an(p==k)];
end
for n = n2m(:)'
    [Ts,Ds] = wpjoin(Ts,Ds,n);
end
