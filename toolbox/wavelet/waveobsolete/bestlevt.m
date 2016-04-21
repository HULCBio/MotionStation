function [Ts,Ds,ento,n2m] = bestlevt(Ts,Ds)
%BESTLEVT Best level tree (wavelet packet).
%   BESTLEVT computes the optimal complete sub-tree of an
%   initial tree with respect to an entropy type criterion.
%   The resulting complete tree may be of smaller depth
%   than the initial one.
%
%   [T,D] = BESTLEVT(T,D) computes the modified tree
%   structure T and data structure D, corresponding to
%   the best level tree decomposition.
%
%   [T,D,E] = BESTLEVT(T,D) returns best tree T,
%   data structure D and in addition, the best entropy value E.
%
%   See also BESTTREE, MAKETREE, WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 05-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.13 $ $Date: 2002/04/14 19:27:06 $

% Check arguments.
if errargn(mfilename,nargin,[2],nargout,[2:4]), error('*'); end

order     = wtreemgr('order',Ts);
an        = wtreemgr('allnodes',Ts);
tn        = wtreemgr('tnodes',Ts);

[dtn,ptn] = ind2depo(order,tn);
[dan,pan] = ind2depo(order,an);
dmin      = min(dtn);
K         = find(dan==dmin);
an_min    = depo2ind(order,[dan(K) pan(K)]);
ind_an    = wcommon(an_min,tn);
n2m       = [an_min(find(1-ind_an))];

od        = order^dmin;
nodes     = depo2ind(order,[dmin*ones(od,1) [0:od-1]']);
ento      = sum(wdatamgr('read_ent',Ds,nodes));
dini      = dmin;
for d=dini-1:-1:0
    od    = order^d;
    nodes = depo2ind(order,[d*ones(od,1) [0:od-1]']);
    ent   = sum(wdatamgr('read_ent',Ds,nodes));
    if ent<=ento
        dmin = d;
        ento = ent;
        n2m  = nodes;
    end;
end

for n = n2m(:)'
    [Ts,Ds] = wpjoin(Ts,Ds,n);
end
ent = wdatamgr('read_ent',Ds);
Ds  = wdatamgr('write_ento',Ds,ent);
