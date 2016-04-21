function [Ts,Ds,ento,n2m] = besttree(Ts,Ds)
%BESTTREE Best tree (wavelet packet).
%   BESTTREE computes the optimal sub-tree of an initial tree
%   with respect to an entropy type criterion.
%   The resulting tree may be much smaller than the initial one.
%
%   [T,D] = BESTTREE(T,D) computes the modified tree
%   structure T and data structure D, corresponding to
%   the best entropy value.
%
%   [T,D,E] = BESTTREE(T,D) returns the best tree T,
%   data structure D and in addition, the best entropy value E.
%
%   [T,D,E,N] = BESTTREE(T,D) returns the best tree T,
%   data structure D, entropy value E and in addition,
%   the vector N containing the indices of the merged nodes.
% 
%   See also BESTLEVT, MAKETREE, WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 05-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[2],nargout,[2:4]), error('*'); end

ent  = wdatamgr('read_ent',Ds);
ento = NaN;
ento = ento(ones(size(ent)));
rec  = ento;

an_ind = wtreemgr('allnodes',Ts)+1;
tn_ind = wtreemgr('tnodes',Ts)+1;
rec(an_ind) = 2;
rec(tn_ind) = 1;

ento(tn_ind) = ent(tn_ind);
order = wtreemgr('order',Ts);

J = wrev(find(rec==2));
for ind_n = J
    ind_child = [1:order]+(ind_n-1)*order+1;
    echild = sum(ento(ind_child));
    if echild < ent(ind_n)
        ento(ind_n) = echild;
        rec(ind_n) = 2;
    else
        ento(ind_n) = ent(ind_n);
        rec(ind_n) = rec(ind_child(1))+2;
        rec(ind_child) = -rec(ind_child);
    end
end
n2m = wrev(find(rec>2))-1;

for n = n2m
    [Ts,Ds] = wpjoin(Ts,Ds,n);
end
depth = wtreemgr('depth',Ts);
nbn   = (order^(depth+1)-1)/(order-1);       
ento  = ento(1:nbn);
Ds    = wdatamgr('write_ento',Ds,ento);
