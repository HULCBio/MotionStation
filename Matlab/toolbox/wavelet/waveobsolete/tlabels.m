function labels = tlabels(t,data,varargin)
%TLABELS Labels for the nodes of a wavelet packet tree.
%   LABELS = TLABELS(T,D,TYPE,N) returns the labels for
%   the nodes N of the tree T.
%   D is the data structure associated with T.
%   The valid values for TYPE are:
%       'i'  --> indices.
%       'p'  --> depth-position.
%       'e'  --> entropy.
%       'eo' --> optimal entropy.
%       's'  --> size.
%       'n'  --> none.
%       't'  --> type.
%   
%   LABELS = TLABELS(T,D,TYPE) returns the labels
%   for all nodes of T.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 17-Jul-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 19:27:42 $

labtype = varargin{1};
if length(varargin)<2
    nodes = allnodes(t);
else
    nodes = varargin{2};
end
nbnodes	= length(nodes);
labels  = [];

switch labtype
   case 'p'
     order = treeord(t);
     [d,p] = ind2depo(order,nodes);
     for k=1:nbnodes
         labels = strvcat(labels,sprintf('(%0.f,%0.f)',d(k),p(k)));
     end

   case 'i'
     for k=1:nbnodes
         labels = strvcat(labels,sprintf('(%0.f)',nodes(k)));
     end

   case 'e'
     entropies = wdatamgr('read_ent',data,nodes);
     labels = num2str(entropies(:),5);

   case 'eo'
     ent_opt = wdatamgr('read_ento',data,nodes);
     labels  = num2str(ent_opt(:),5);

   case 's'
     order = treeord(t);
     labels = SizesLab(data,order,nodes,nbnodes);

   case 'n'

   case 't'
     order = treeord(t);
     [d,p] = ind2depo(order,nodes);
     p = rem(p,order);
     pstr = repLine('a',nbnodes);
     if order==2
         I = find(p==1); pd = repLine('d',length(I)); pstr(I,:) = pd;
     else
         I = find(p==1); pd = repLine('h',length(I)); pstr(I,:) = pd;
         I = find(p==2); pd = repLine('v',length(I)); pstr(I,:) = pd;
         I = find(p==3); pd = repLine('d',length(I)); pstr(I,:) = pd;
     end
     lp = repLine('(',nbnodes);
     rp = repLine(')',nbnodes);
     labels = [lp pstr rp];
end



%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function m = repLine(c,n)
%REPLINE Replicate Lines.

m = c(ones(n,1),:);
%-----------------------------------------------------------------------------%
function labels = SizesLab(data,order,nodes,nbnodes)
%SIZESLAB Built Length or SizesLabels.
%
labels  = [];
sizes   = wdatamgr('rsizes',data);
[d,p]   = ind2depo(order,nodes);
d   = d+1;
switch order
    case 2
        for k=1:nbnodes
            labels = strvcat(labels,sprintf('%0.f',sizes(d(k))));
        end

    case 4
        for k=1:nbnodes
            labels = strvcat(labels, sprintf('(%0.f,%0.f)',sizes(:,d(k))));
        end
end
%-----------------------------------------------------------------------------%
%=============================================================================%
