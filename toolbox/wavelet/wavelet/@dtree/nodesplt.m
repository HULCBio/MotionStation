function [t,child,tndata] = nodesplt(t,node)
%NODESPLT Split (decompose) node.
%   T = NODESPLT(T,N) returns the modified tree T
%   corresponding to the decomposition of the node N.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   This method overloads the NTREE method and 
%   calls the right overloaded method SPLIT.
%
%   See also SPLIT, NODEJOIN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:37:33 $

[n_rank,node] = findactn(t,node,'a_tn');
if isempty(n_rank)
    child  = [];
    tndata = [];
    return
end
order  = treeord(t);
t_tree = get(t,'ntree');
node   = depo2ind(order,node);
x      = read(t,'data',node);
t_tree = nodesplt(t_tree,node);
t      = set(t,'ntree',t_tree);
child  = node*order+[1:order]';
tndata = split(t,node,x);
sizes  = zeros(order,2);
data   = [];
for k =1:order
    tmp = tndata{k};
    sizes(k,:) = size(tmp);
    data = [data tmp(:)'];
end
t     = fmdtree('tn_write',t,n_rank,sizes,data);
aninf = defaninf(t,child,tndata);
t     = fmdtree('an_write',t,[child sizes aninf],'add');
