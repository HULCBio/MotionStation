function varargout = plot(t,varargin);
%PLOT Plot EPSDWT object.
%   PLOT(T) plots the EDWTTREE object T.
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
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:36:03 $ 

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
  case 'create'

  % Added Node Labels menus.
  case {'length','type','epsVal'} , fig_tree = varargin{2};  

  % Added Node Action menus.
  case 'Reconstruct'  , fig_tree = varargin{2};

  % Added Tree Action menus.
  case {'Restore Initial Tree','Store Tree',...
        'Restore Last Stored Tree',...
        'De-noise','De-noising Method'}
      fig_tree = varargin{2};
end

switch option
  case 'create'
    fig_tree = plot(getwtbo(t,'dtree'),fig_tree);
    if nargout>0 , varargout{1} = fig_tree; end
    set(fig_tree,'NumberTitle','Off','Name',...
        ['Fig ' int2str(fig_tree) ...
		 ' - EDWT Tree Object - Extension Mode: ',getwtbo(t,'dwtMode'), ...
         '  -  De-noising Method: ','sqtwolog']);

    % Store the EDWTTREE.
    %--------------------
    plot(dtree,'write',fig_tree,t);

    % Add Node Label menus.
    %----------------------
    plot(ntree,'addNodeLabel',fig_tree,'length');
    plot(ntree,'addNodeLabel',fig_tree,'type');
    plot(ntree,'addNodeLabel',fig_tree,'epsVal');

    % Add Node Action menu.
    %----------------------
    plot(t,'addNodeAction',fig_tree,'Reconstruct');

    % Add Tree Action menus.
    %-----------------------
    plot(ntree,'addTreeAction',fig_tree,'Restore Initial Tree');
    plot(ntree,'addTreeAction',fig_tree,'Store Tree');
    plot(ntree,'addTreeAction',fig_tree,'Restore Last Stored Tree');
    m = plot(ntree,'addTreeAction',fig_tree,'De-noising Method');
    set(m,'Separator','on')
    plot(ntree,'addTreeAction',fig_tree,'De-noise');
    plot(ntree,'storeValue',fig_tree,'DenMeth','sqtwolog');

    % Store the TREE.
    %----------------
    plot(ntree,'storeValue',fig_tree,'InitialTREE',t);
    plot(ntree,'storeValue',fig_tree,'LastTREE',t);

    % Set default Node Label to 'Index'.
    %-----------------------------------
    plot(ntree,'setNodeLabel',fig_tree,'Index');

  case {'length','type','epsVal'}
    t = plot(ntree,'read',fig_tree);
    if nbin<3 , nodes = allnodes(t); else , nodes = varargin{3}; end
    n = length(nodes);
    switch option
      case 'length' , labtype = 's';
      case 'type'   , labtype = 't';
      case 'epsVal' , labtype = 'ev';
    end
    labels = tlabels(t,labtype,nodes);
    err    = ~isequal(n,size(labels,1));
    varargout = {labels,err};

  case 'Reconstruct'
    node = plot(ntree,'getNode',fig_tree);
    if isempty(node) , return; end
    t = plot(ntree,'read',fig_tree);
    axe_vis = plot(ntree,'getValue',fig_tree,'axe_vis');

    %============================================================%
    mousefrm(fig_tree,'watch')
    x = rnodcoef(t,node);
    if ~isempty(x)
        if min(size(x))<2
            plot(x,'Color','r','parent',axe_vis);
            lx = length(x);
            if lx> 1 , set(axe_vis,'Xlim',[1,lx]); end
        else
           NBC = 128;
           colormap(pink(NBC))
           image(wcodemat(x,NBC,'mat',0),'parent',axe_vis);
        end
        endTitle = '.';
    else
        delete(get(axe_vis,'Children'))
        endTitle = ' ==> NONE.';
    end
    order = treeord(t);
    [d,p] = ind2depo(order,node);
    ldep = sprintf('(%0.f,%0.f)',d,p);
    lind = sprintf('(%0.f)',node);
    axeTitle = ['data for node: ' lind ' or ' ldep endTitle];
    wtitle(axeTitle,'parent',axe_vis);
    mousefrm(fig_tree,'arrow')
    %============================================================%

  case 'Restore Initial Tree'
    tInit = plot(ntree,'getValue',fig_tree,'InitialTREE');
    tLast = plot(ntree,'getValue',fig_tree,'LastTREE');
    plot(tInit,fig_tree);
    plot(ntree,'storeValue',fig_tree,'LastTREE',tLast);

  case 'Store Tree'
    t = plot(ntree,'read',fig_tree);
    plot(ntree,'storeValue',fig_tree,'LastTREE',t);

  case 'Restore Last Stored Tree'
    tInit = plot(ntree,'getValue',fig_tree,'InitialTREE');
    tLast = plot(ntree,'getValue',fig_tree,'LastTREE');
    tAct  = plot(ntree,'read',fig_tree);
    plot(tLast,fig_tree);
    plot(ntree,'storeValue',fig_tree,'InitialTREE',tInit);

  case 'De-noising Method'
    meth = {'sqtwolog','rigrsure','heursure','minimaxi',...
            'penalhi','penalme','penallo'};
    m = menu('Choose De-noising Method',meth);
    if isempty(m)
        meth = plot(ntree,'getValue',fig_tree,'DenMeth');
    else
        meth = meth{m};
    end
    plot(ntree,'storeValue',fig_tree,'DenMeth',meth);
    t = plot(ntree,'read',fig_tree);
    set(fig_tree,'Name',...
        ['Fig ' int2str(fig_tree) ...
		 ' - EDWT Tree Object - Extension Mode: ',getwtbo(t,'dwtMode'), ...
         '  -  De-noising Method: ',meth]);

  case 'De-noise'
    tInit = plot(ntree,'getValue',fig_tree,'InitialTREE');
    tLast = plot(ntree,'getValue',fig_tree,'LastTREE');
    t = plot(ntree,'read',fig_tree);
    order = treeord(t);
    depth = treedpth(t);
    dpstn = leaves(t,'dps');
    dTN = dpstn(:,1);
    pTN = dpstn(:,2);
    remORD = rem(dpstn(:,2),order);
    appIDX = find(remORD==0 | remORD==3);
    detIDX = find(remORD==1 | remORD==2);
    nbDWT  = length(appIDX);
    tnDWT  = cell(nbDWT,1);

    j = appIDX(end);
    d = dTN(j);
    p = pTN(j);
    tmp = [d,p];
    while d>0
      r = rem(p,order);
      switch r
        case 0 , tmp = [tmp ; [d,p+1]];
        case 3 , tmp = [tmp ; [d,p-1]];
      end
      d = d-1;
      p = fix(p/order);
    end
    tnTMP = depo2ind(order,tmp);
    [CFS,sizes] = read(t,'data',tnTMP,'sizes',tnTMP);
    coefs = cat(2,CFS{:});
    lenSIG = max(read(t,'sizes',0));
    longs = [max(sizes,[],2) ; lenSIG]';

    meth = plot(ntree,'getValue',fig_tree,'DenMeth');
    switch meth
      case {'sqtwolog','rigrsure','heursure','minimaxi'} , param = 'sln';
      case 'penalhi' , param = 5;
      case 'penalme' , param = 2;
      case 'penallo' , param = 1.5;
    end
    thrDWT = wthrmngr('dw1ddenoLVL',meth,coefs,longs,param);

    level = dpstn(detIDX,1);
    idxTN = depo2ind(order,dpstn(detIDX,:));
    CFS = read(t,'data',idxTN);
    for k=1:length(detIDX)
        CFS{k} = wthresh(CFS{k},'h',thrDWT(level(k)));
        t = write(t,'data',idxTN(k),CFS{k});
    end
    plot(t,fig_tree);
    plot(ntree,'storeValue',fig_tree,'InitialTREE',tInit);
    plot(ntree,'storeValue',fig_tree,'LastTREE',tLast);
    plot(ntree,'storeValue',fig_tree,'DenMeth',meth);

    set(fig_tree,'Name',...
        ['Fig ' int2str(fig_tree) ...
		 ' - EDWT Tree Object - Extension Mode: ',getwtbo(t,'dwtMode'), ...
         '  -  De-noising Method: ',meth]);

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
     for k=1:nbnodes
         labels = strvcat(labels,sprintf('%0.f',max(sizes(k,:))));
     end

   case 't'
     [d,p] = ind2depo(order,nodes);
     p = rem(p,order);
     pstr = repLine('a',nbnodes);
     I = find(p==1); pd = repLine('d',length(I)); pstr(I,:) = pd;
     I = find(p==2); pd = repLine('d',length(I)); pstr(I,:) = pd;
     I = find(p==3); pd = repLine('a',length(I)); pstr(I,:) = pd;
     lp = repLine('(',nbnodes);
     rp = repLine(')',nbnodes);
     labels = [lp pstr rp];

   case 'ev'
     [d,p] = ind2depo(order,nodes);
     p = rem(p,order);
     pstr = repLine('0',nbnodes);
     I = find(p==1); pd = repLine('0',length(I)); pstr(I,:) = pd;
     I = find(p==2); pd = repLine('1',length(I)); pstr(I,:) = pd;
     I = find(p==3); pd = repLine('1',length(I)); pstr(I,:) = pd;
     lp = repLine('(',nbnodes);
     rp = repLine(')',nbnodes);
     labels = [lp pstr rp];
end
%-------------------------------------------------------------------------%
function m = repLine(c,n)
%REPLINE Replicate Lines.

m = c(ones(n,1),:);
%-------------------------------------------------------------------------%
