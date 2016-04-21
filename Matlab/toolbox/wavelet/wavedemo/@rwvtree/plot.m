function varargout = plot(t,varargin);
%PLOT Plot RWVTREE object.
%   PLOT(T) plots the RWVTREE object T.
%   FIG = PLOT(T) returns the handle of the figure, which
%   contains the tree T.
%   PLOT(T,FIG) plots the tree T in the figure FIG, which
%   already contains a tree.
%
%   PLOT is a graphical tree-management utility. The figure
%   that contains the tree is a GUI tool. It lets you change
%   the Node Label to Depth_Position or Index, and Node Action
%   to Split-Merge or Visualize.
%   The default values are Depth_Position and Visualize.
%
%   You can click the nodes to execute the current Node Action.
%
%   After some split or merge actions you can get the new tree
%   using the handle of the figure, which contains it.
%   You must use the following special syntax:
%       NEWT = PLOT(T,'read',FIG).
%   In fact, the first argument is dummy. Then the most general
%   syntax for this purpose is:
%       NEWT = PLOT(DUMMY,'READ',FIG);
%   where DUMMY is any object parented by an NTREE object.
%
%   DUMMY can be any object constructor name, which returns
%   an object parented by an NTREE object. For example:
%      NEWT = PLOT(ntree,'read',FIG);
%      NEWT = PLOT(dtree,'read',FIG);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:36:07 $ 

nbin = length(varargin);
fig_tree = NaN;
switch nbin
  case 0    , option = 'create';
  otherwise
    option = varargin{1};
    if isnumeric(option)
        fig_tree = option;
        option = 'create';
    end
end

switch option
  case {'create'}
  case {'length','type'} , fig_tree = varargin{2};  % Added Node Labels
end

switch option
  case 'create'
	order = treeord(t);
	fig_tree = plot(getwtbo(t,'wtree'),fig_tree);
    if nargout>0 , varargout{1} = fig_tree; end
    set(fig_tree,'NumberTitle','Off','Name',...
        ['Fig ' int2str(fig_tree) ...		
         ' - Right Wavelet Tree Object of Order ' int2str(order)]);

    % Store the RWVTREE.
    %-------------------
    plot(dtree,'write',fig_tree,t);

    % Add Node Label menus.
    %----------------------
    plot(ntree,'addNodeLabel',fig_tree,'length');
    plot(ntree,'addNodeLabel',fig_tree,'type');

    % Set default Node Label to 'Index'.
    %-----------------------------------
    plot(ntree,'setNodeLabel',fig_tree,'Index');

  case {'length','type'}
    t = plot(ntree,'read',fig_tree);
    if nbin<3 , nodes = allnodes(t); else , nodes = varargin{3}; end
    n = length(nodes);
    switch option
      case 'length' , labtype = 's';
      case 'type'   , labtype = 't';
    end
    labels = tlabels(t,labtype,nodes);
    err    = ~isequal(n,size(labels,1));
    varargout = {labels,err};

  otherwise
    try
      nbout = nargout;
      varargout{1:nbout} = plot(dtree,varargin{:});       
    end
    
end

%-------------------------------------------------------------------------%
% Internal Functions                                                      %
%-------------------------------------------------------------------------%
function labels = tlabels(t,varargin)

labtype = varargin{1};
if length(varargin)<2
    nodes = allnodes(t);
else
    nodes = varargin{2};
end
nbnodes	= length(nodes);
labels  = [];
order = treeord(t);

switch labtype
   case 's'
     sizes = read(t,'sizes',nodes);
     switch order
       case 2         
         for k=1:nbnodes
           labels = strvcat(labels,sprintf('%0.f',max(sizes(k,:))));
         end

       case 4
         for k=1:nbnodes
           labels = strvcat(labels,sprintf('(%0.f,%0.f)',sizes(k,:)));
         end
     end

   case 't'
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
     labels(1:end,:) = labels([2:end,1],:);
end
%-------------------------------------------------------------------------%
function m = repLine(c,n)
%REPLINE Replicate Lines.

m = c(ones(n,1),:);
%-------------------------------------------------------------------------%
