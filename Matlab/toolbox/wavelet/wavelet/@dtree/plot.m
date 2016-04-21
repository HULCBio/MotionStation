function varargout = plot(t,varargin);
%PLOT Plot DTREE object.
%   PLOT(T) plots the DTREE object T.
%   FIG = PLOT(T) returns the handle of the figure which,
%   contains the tree T.
%   PLOT(T,FIG) plots the tree T in the figure FIG which,
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
%   using the handle of the figure, which contains this one.
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

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 13-Feb-2002.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 19:35:05 $

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
  case 'Visualize' , fig_tree = varargin{2};
end

switch option
  case 'create'
    fig_tree = plot(t.ntree,class(t),fig_tree);
    if nargout>0 , varargout{1} = fig_tree; end

    % Store the DTREE.
    %-----------------
    plot(ntree,'write',fig_tree,t);

    % Add menus for node actions.
    %----------------------------
    plot(t,'addNodeAction',fig_tree,'Split-Merge');
    plot(t,'addNodeAction',fig_tree,'Visualize');
    plot(t,'setNodeAction',fig_tree,'Visualize');

    % Add one axes.
    %--------------
    pos_axe_visu = [0.55 0.08 0.40 0.84];
    axe_vis = axes(...
                   'Parent',fig_tree,       ...
                   'Visible','on',          ...
                   'Units','normalized',    ...
                   'Position',pos_axe_visu, ...
                   'Box','On'               ...
                   );
	wtitle('Node Action Result','Parent',axe_vis);

    % Store the handle of new axes.
    %------------------------------
    plot(ntree,'storeValue',fig_tree,'axe_vis',axe_vis);

  case 'Visualize'
    node = plot(ntree,'getNode',fig_tree);
    if isempty(node) , return; end
    t = plot(ntree,'read',fig_tree);
    axe_vis = plot(ntree,'getValue',fig_tree,'axe_vis');

    %============================================================%
    mousefrm(fig_tree,'watch')
    [t,x] = nodejoin(t,node);
    if ~isempty(x)
        if min(size(x))<2
            plot(x,'Color','r','parent',axe_vis);
            lx = length(x);
            if lx> 1 , set(axe_vis,'Xlim',[1,lx]); end
        else
           NBC = 128;
           colormap(pink(NBC))
           image(wcodemat(x,NBC,'mat',1),'parent',axe_vis);
        end
        endTitle = '.';
    else
        delete(get(axe_vis,'Children'))
        endTitle = ' ==> NONE.';
    end
    lind = tlabels(t,'i',node);
    ldep = tlabels(t,'p',node);
    axeTitle = ['data for node: ' lind ' or ' ldep endTitle];
    wtitle(axeTitle,'parent',axe_vis);
    mousefrm(fig_tree,'arrow')
    %============================================================%

  otherwise
    try
      nbout = nargout;
      varargout{1:nbout} = plot(ntree,varargin{:});
    end
    
end
