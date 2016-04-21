function [Ts,Ds,n2m] = wpcutree(Ts,Ds,level)
%WPCUTREE Cut wavelet packet tree.
%   [T,D] = WPCUTREE(T,D,L) cuts the tree T at level L
%   and computes the corresponding data structure D
%   (see MAKETREE).
%
%   [T,D,RN] = WPCUTREE(T,D,L) returns the same arguments
%   as above and in addition, the vector RN contains
%   the indices of the reconstructed nodes.
%
%   See also MAKETREE, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.13 $

% Check arguments.
if errargn(mfilename,nargin,[2 3],nargout,[2 3]), error('*'); end
if nargin==2 , level = 0; end

depth = wtreemgr('depth',Ts);
if level<0
    errargt(mfilename,'invalid level value','msg'); error('*');
    return;
elseif (level>depth) | (depth==0)
    n2m = [];
    return;
end
order = wtreemgr('order',Ts);
dp    = wtreemgr('allnodes',Ts,1);
p_an  = dp(dp(:,1)==level,2);
dp    = wtreemgr('tnodes',Ts,1);
p_tn  = dp(dp(:,1)==level,2);
ind   = wcommon(p_an,p_tn);
p_an  = p_an(ind==0);
d_an  = level*ones(size(p_an));
n2m   = depo2ind(order,[d_an p_an]);
for n = n2m(:)'
    [Ts,Ds] = wpjoin(Ts,Ds,n);
end

