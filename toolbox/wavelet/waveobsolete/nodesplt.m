function Ts = nodesplt(Ts,node)
%NODESPLT Split (decompose) node.
%   T = NODESPLT(T,N) returns the modified tree
%   structure T corresponding to the decomposition
%   of the node N.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   See also MAKETREE, NODEJOIN, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[2],nargout,[0 1]), error('*'); end

node_rank = wtreemgr('istnode',Ts,node);
if node_rank==0
    errargt(mfilename,'invalid node value','msg');
    return
end

order   = wtreemgr('order',Ts);
depth   = wtreemgr('depth',Ts);
node    = depo2ind(order,node);
indord  = node*order;
nbinfo  = size(Ts,1)-1;
ins_val = [indord+1:indord+order;zeros(nbinfo,order)];
Ts      = wtreemgr('replace',Ts,ins_val,node_rank,node_rank);
