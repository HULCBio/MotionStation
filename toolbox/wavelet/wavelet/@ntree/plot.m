function varargout = plot(treeobj,varargin);
%PLOT Plot NTREE object.
%   PLOT(T) plots the NTREE object T.
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
%   where DUMMY is any NTREE object.
%   DUMMY can be the NTREE object constructor name:
%      NEWT = PLOT(ntree,'read',FIG);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/03/15 22:38:32 $

% Miscelleanous Values.
%----------------------
line_color = [1 1 1];
actColor   = 'y';
inactColor = 'r';

% MemBloc of stored values.
%--------------------------
n_stored_val = 'NTREE_Plot';
ind_tree     = 1;
ind_Class    = 2;
ind_hdls_txt = 3;
ind_hdls_lin = 4;
ind_menu_NodeLab =  5;
ind_type_NodeLab =  6;
ind_menu_NodeAct =  7;
ind_type_NodeAct =  8;
ind_menu_TreeAct =  9;
ind_type_TreeAct = 10;
nb1_stored = 10;

%----------------------------
% User oriented Memory Block.
% For overloading methods.
%----------------------------
n_toolMemB = 'OverLoad_MB';

% Initialization.
%----------------
objClass = 'ntree';
fig_tree = NaN;
nbin = length(varargin);
switch nbin
  case 0 , option = 'create';
  case 1 ,
    option = varargin{1};
    if isnumeric(option)
       child = allchild(0);
       if ismember(option,child)
           dummy = wmemtool('rmb',option,n_stored_val,ind_type_NodeLab);
           if ~isempty(dummy) , fig_tree = option; end
           option = 'create';
       end
    else
       objClass = option;
       option = 'create';
    end
  otherwise , option = varargin{1}; fig_tree = varargin{2};
end

switch option
  case 'create'
  case {'setNodeLabel','addNodeLabel', ...
        'setNodeAction','addNodeAction','exeNodeAction', ...
        'setTreeAction','addTreeAction', ...
        'Split-Merge', ...
        'getNode','read','write','close',...
        'storeValue','getValue'}
     fig_tree = varargin{2};
  otherwise
    if ischar(option)
      objClass = option;
    else
      option = 'create';
    end
    option = 'create';
end

switch option
  case 'create'
    order = treeord(treeobj);
    depth = treedpth(treeobj);
    allN  = allnodes(treeobj);
    NBnod = nbmaxn(order,depth);
    table_node = -ones(1,NBnod);
    table_node(allN+1) = allN;
    [xnpos,ynpos] = xynodpos(table_node,order,depth);

    if isnan(fig_tree)
        menu_bar = get(0,'DefaultFigureMenuBar');
        fig_tree = colordef('new','black');
        set(fig_tree, ...
            'menubar',menu_bar,   ...
            'Units','normalized', ...
            'HandleVisibility','Callback',...
            'Interruptible','on'  ...
            );
        str_numf = sprintf('%20.15f',fig_tree);
        m_lab = uimenu(fig_tree,'Label','Node Label  ');
        m(1)  = uimenu(m_lab,'Label','Depth_Position','Checked','On');
        m(2)  = uimenu(m_lab,'Label','Index');
        cb_beg = ['plot(ntree,''setNodeLabel'','];
        cb_m1  = [cb_beg , str_numf ',''Depth_Position'');'];
        cb_m2  = [cb_beg , str_numf ',''Index'');'];
        set(m(1),'Callback',cb_m1);
        set(m(2),'Callback',cb_m2);
        wmemtool('ini',fig_tree,n_stored_val,nb1_stored);
        type_NodeLab = 'Depth_Position';
        type_NodeAct = 'Split-Merge';
    else
        str_numf = sprintf('%20.15f',fig_tree);
        delete(findobj(fig_tree,'type','axes'));
        [m_lab,type_NodeLab,type_NodeAct] = ...
            wmemtool('rmb',fig_tree,n_stored_val,...
                           ind_menu_NodeLab,ind_type_NodeLab,ind_type_NodeAct);
    end

    if (nbin<1) | isequal(objClass,'ntree')
        pos_axe_tree = [0.05 0.08 0.90 0.84];
    else
        pos_axe_tree = [0.05 0.08 0.40 0.84];
    end
    axe_tree_lin = axes(...
                    'Parent',fig_tree,               ...
                    'Visible','on',                  ...
                    'XLim',[-0.5,0.5],               ...
                    'YDir','reverse',                ...
                    'YLim',[0 1],                    ...
                    'Units','normalized',            ...
                    'Position',pos_axe_tree,         ...
                    'XTicklabelMode','manual',       ...
                    'YTicklabelMode','manual',       ...
                    'XTickLabel',[],'YTickLabel',[], ...
                    'XTick',[],'YTick',[],           ...
                    'Box','On'                       ...
                    );
	wtitle('Tree Decomposition','Parent',axe_tree_lin);
    hdls_lin = zeros(1,NBnod);
    hdls_txt = zeros(1,NBnod);
    i_fath  = 1;
    i_child = i_fath+[1:order];
    for d=1:depth
        ynT = ynpos(d,:);
        ynL = ynT+[0.01 -0.01];
        for p=0:order^(d-1)-1
            if table_node(i_child(1)) ~= -1
                for k=1:order
                    ic = i_child(k);
                    hdls_lin(ic) = line(...
                        'Parent',axe_tree_lin, ...
                        'XData',[xnpos(i_fath) xnpos(ic)],...
                        'YData',ynL,...
                        'Color',line_color);
                end
            end
            i_child = i_child+order;
            i_fath  = i_fath+1;
        end
    end

    labels = tlabels(treeobj,'dp');
    textProp = {...
        'Parent',axe_tree_lin,          ...
        'FontWeight','bold',            ...
        'Color',actColor,               ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle',   ...
        'Clipping','on'                 ...
        };    
    
    i_node = 1;   
    hdls_txt(i_node) = ...
        text(textProp{:},...
             'String', labels(i_node,:),   ...
             'Position',[0 0.1 0],         ...
             'UserData',table_node(i_node) ...
             );
    i_node = i_node+1;
    
    i_fath  = 1;
    i_child = i_fath+[1:order];
    for d=1:depth
        for p=0:order:order^d-1
            if table_node(i_child(1)) ~= -1
                p_child = p+[0:order-1];
                for k=1:order
                    ic = i_child(k);
                    hdls_txt(ic) = text(...
                                      textProp{:},...
                                      'String',labels(i_node,:), ...
                                      'Position',[xnpos(ic) ynpos(d,2) 0],...
                                      'Userdata',table_node(ic)...
                                      );
                    i_node = i_node+1;
                end
            end
            i_child = i_child+order;
        end
    end

    btndown_fcn = ['plot(ntree,''Split-Merge'',' str_numf ');'];
    set(hdls_txt(find(hdls_txt)),'ButtonDownFcn',btndown_fcn);
    
    wmemtool('wmb',fig_tree,n_stored_val, ...
                   ind_tree,treeobj,      ...
                   ind_hdls_txt,hdls_txt, ...
                   ind_hdls_lin,hdls_lin, ...
                   ind_menu_NodeLab,m_lab, ...
                   ind_type_NodeLab,'Depth_Position', ...
                   ind_type_NodeAct,'Split-Merge' ...
                   );

    [nul,notAct] = findactn(treeobj,allN,'na');
    set(hdls_txt(notAct+1),'Color',inactColor);

    switch type_NodeLab
      case 'Depth_Position'
      case 'Index' , plot(treeobj,'setNodeLabel',fig_tree,type_NodeLab);
      otherwise
        plot(treeobj,'setNodeLabel',fig_tree,'Depth_Position');
    end

    switch type_NodeAct
      case 'Split-Merge'
      otherwise
        plot(treeobj,'setNodeAction',fig_tree,'Split-Merge');
    end

    set(fig_tree,'Visible','on')
    if nargout>0 , varargout{1} = fig_tree; end

  case 'setNodeLabel'
    NodeLabType = varargin{3};
    m_lab = wmemtool('rmb',fig_tree,n_stored_val,ind_menu_NodeLab);
    if ~isempty(m_lab)
          m = findobj(m_lab,'type','uimenu');
          lstItems = get(m,'label');
          idx_menu = strmatch(NodeLabType,lstItems);
          if isempty(idx_menu) , return; end
          type_lab = wmemtool('rmb',fig_tree,n_stored_val,ind_type_NodeLab);
          if isequal(type_lab,NodeLabType), return; end
          set(m,'Checked','off');
          set(m(idx_menu),'Checked','on');
    end
    wmemtool('wmb',fig_tree,n_stored_val,ind_type_NodeLab,NodeLabType);
    t = wmemtool('rmb',fig_tree,n_stored_val,ind_tree);
    switch NodeLabType
      case {'Depth_Position','Index'} , 
        if isequal(NodeLabType,'Depth_Position')
            labtype = 'dp';
        else
            labtype = 'i';
        end
        labels = tlabels(t,labtype);

      otherwise
        [labels,err] = plot(t,NodeLabType,fig_tree);
        if err , return; end
    end
    hdls_txt = wmemtool('rmb',fig_tree,n_stored_val,ind_hdls_txt);
    hdls_txt = hdls_txt(hdls_txt~=0);
    for k=1:length(hdls_txt), set(hdls_txt(k),'String',labels(k,:)); end

  case 'addNodeLabel'
    NodeLabType = varargin{3};
    m_lab = wmemtool('rmb',fig_tree,n_stored_val,ind_menu_NodeLab);
    m = findobj(m_lab,'type','uimenu');
    lstItems = get(m,'label');
    idx_menu = strmatch(NodeLabType,lstItems);
    if ~isempty(idx_menu) , varargout{1} = m(idx_menu);return; end
    m_add  = uimenu(m_lab,'Label',NodeLabType);
    cb_add = ['plot(ntree,''setNodeLabel'',' , num2str(fig_tree) , ...
              ',''' NodeLabType ''');'];
    set(m_add,'Callback',cb_add);
    varargout{1} = m_add;

  case 'setNodeAction'
    NodeActType = varargin{3};
    m_act = wmemtool('rmb',fig_tree,n_stored_val,ind_menu_NodeAct);
    if ~isempty(m_act)
        m = findobj(m_act,'type','uimenu');
        lstItems = get(m,'label');
        idx_menu = strmatch(NodeActType,lstItems);
        type_act = wmemtool('rmb',fig_tree,n_stored_val,ind_type_NodeAct);
        if isequal(type_act,NodeActType), return; end
        set(m,'Checked','off');
        set(m(idx_menu),'Checked','on');
    end
    str_numf = sprintf('%20.15f',fig_tree);
    wmemtool('wmb',fig_tree,n_stored_val,ind_type_NodeAct,NodeActType);
    switch NodeActType
      case 'Split-Merge'       
        nodeAction = ['plot(ntree,''Split-Merge'',' str_numf ');'];

      otherwise
        nodeAction = ['plot(ntree,''exeNodeAction'',' str_numf ...
                      ',''' NodeActType ''');'];
    end
    hdls_txt = wmemtool('rmb',fig_tree,n_stored_val,ind_hdls_txt);
    hdls_txt = hdls_txt(hdls_txt~=0);
    set(hdls_txt(ishandle(hdls_txt)),'ButtonDownFcn',nodeAction);

  case 'addNodeAction'
    NodeActType = varargin{3};
    m_act = wmemtool('rmb',fig_tree,n_stored_val,ind_menu_NodeAct);
    if isempty(m_act)
        m_act = uimenu(fig_tree,'Label','Node Action  ');
        wmemtool('wmb',fig_tree,n_stored_val,ind_menu_NodeAct,m_act);
    else
        m = findobj(m_act,'type','uimenu');
        lstItems = get(m,'label');
        idx_menu = strmatch(NodeActType,lstItems);
        if ~isempty(idx_menu)
            varargout{1} = m(idx_menu);
            return;
        end
    end
    m_add  = uimenu(m_act,'Label',NodeActType);
    cb_add = ['plot(ntree ,''setNodeAction'',' , num2str(fig_tree) , ...
              ',''' NodeActType ''');'];
    set(m_add,'Callback',cb_add);
    varargout{1} = m_add;

  case 'exeNodeAction'
    NodeActType = varargin{3};
    t = wmemtool('rmb',fig_tree,n_stored_val,ind_tree);
    plot(t,NodeActType,fig_tree);

  case 'setTreeAction'
    TreeActType = varargin{3};
    m_tree = wmemtool('rmb',fig_tree,n_stored_val,ind_menu_TreeAct);
    m = findobj(m_tree,'type','uimenu');
    lstItems = get(m,'label');
    idx_menu = strmatch(TreeActType,lstItems);
    if isempty(idx_menu) , return; end
    % type_act = wmemtool('rmb',fig_tree,n_stored_val,ind_type_TreeAct);
    % if isequal(type_act,TreeActType), return; end
    wmemtool('wmb',fig_tree,n_stored_val,ind_type_TreeAct,TreeActType);
    set(m,'Checked','off');
    set(m(idx_menu),'Checked','on');
    t = wmemtool('rmb',fig_tree,n_stored_val,ind_tree);
    plot(t,TreeActType,fig_tree);

  case 'addTreeAction'
    TreeActType = varargin{3};
    m_tree = wmemtool('rmb',fig_tree,n_stored_val,ind_menu_TreeAct);
    if isempty(m_tree)
        m_tree = uimenu(fig_tree,'Label','Tree Action  ');
        wmemtool('wmb',fig_tree,n_stored_val,ind_menu_TreeAct,m_tree);
    else
        m = findobj(m_tree,'type','uimenu');
        lstItems = get(m,'label');
        idx_menu = strmatch(TreeActType,lstItems);
        if ~isempty(idx_menu)
            varargout{1} = m(idx_menu);
            return;
        end
    end
    m_add  = uimenu(m_tree,'Label',TreeActType);
    cb_add = ['plot(ntree ,''setTreeAction'',' , num2str(fig_tree) , ...
              ',''' TreeActType ''');'];
    set(m_add,'Callback',cb_add);
    varargout{1} = m_add;

  case 'Split-Merge'
    node = plot(ntree,'getNode',fig_tree);
    if isempty(node) , return; end

    % Get stored values.
    %-------------------
    [treeobj,hdls_txt,hdls_lin,type_lab]  = ...
        wmemtool('rmb',fig_tree,n_stored_val, ...
                       ind_tree,     ...
                       ind_hdls_txt, ...
                       ind_hdls_lin, ...
                       ind_type_NodeLab  ...
                       );

    % Decomposition/recomposition.
    %-----------------------------
    [n_rank,node] = findactn(treeobj,node,'a');
    if isempty(n_rank), return; end
    order = treeord(treeobj);
    if order==0 , return; end
    mousefrm(fig_tree,'watch')
    if n_rank==0
        treeobj = nodejoin(treeobj,node);
    else
        treeobj = nodesplt(treeobj,node);
    end
    wmemtool('wmb',fig_tree,n_stored_val,ind_tree,treeobj);
    depth = treedpth(treeobj);
    allN  = allnodes(treeobj);
    NBnod = nbmaxn(order,depth);
    table_node = -ones(1,NBnod);
    table_node(allN+1) = allN;
    [xnpos,ynpos] = xynodpos(table_node,order,depth);

    % Drawing New Tree.
    %------------------
    axe_tree_lin = get(hdls_txt(1),'Parent');
    axes(axe_tree_lin);
    btndown_fcn = get(hdls_txt(1),'ButtonDownFcn');
 
    % Create the new tree.
    %---------------------
    node  = depo2ind(order,node);
    [d,b] = ind2depo(order,node);

    % Suppress the descendants of the node.
    %--------------------------------------
    if n_rank==0
        if NBnod < size(hdls_txt,2)
            to_del = find(hdls_txt(NBnod+1:size(hdls_txt,2)))+NBnod;
            delete([hdls_txt(to_del) hdls_lin(to_del)]);
            hdls_txt = hdls_txt(1:NBnod);
            hdls_lin = hdls_lin(1:NBnod);
        end
        K = find((table_node==-1) & (hdls_txt ~= 0));
        K = K(K>1);
        delete([hdls_txt(K) hdls_lin(K)]);
        hdls_txt(K) = 0;
        hdls_lin(K) = 0;
 
    % Create the descendants of the node.
    %------------------------------------
    else
        Tree_Colors = wtbxappdata('get',fig_tree,'Tree_Colors');
        if ~isempty(Tree_Colors)
            line_color = Tree_Colors.line_color;
            actColor   = Tree_Colors.actColor;
            inactColor = Tree_Colors.inactColor;
        end

        i_fath  = node+1;
        child   = node*order+[1:order]';
        i_child = child+1;

        if NBnod > size(hdls_lin,2)
            hdls_txt = [hdls_txt zeros(1,NBnod-size(hdls_txt,2))];
            hdls_lin = [hdls_lin zeros(1,NBnod-size(hdls_lin,2))];
        end
        for k=1:order
            ic = i_child(k);
            ynT = ynpos(d+1,:);
            ynL = ynT+[0.01 -0.01];
            hdls_lin(ic) = ...
                    line(...
                         'XData',[xnpos(i_fath) xnpos(ic)],...
                         'YData',ynL, ...
                         'Color',line_color,     ...
                         'Userdata',[i_fath ic]  ...
                         );
        end        
        switch type_lab
          case 'Depth_Position' , labels = tlabels(treeobj,'dp',child);
          case 'Index'          , labels = tlabels(treeobj,'i',child);
          otherwise
            [labels,err] = plot(treeobj,type_lab,fig_tree,child);
            if err , return; end
        end

        for k=1:order
            ic = i_child(k);
            hdls_txt(ic) = text(...
                    'Clipping','on',                       ...
                    'String',labels(k,:),                  ...
                    'Position',[xnpos(ic) ynpos(d+1,2) 0], ...
                    'HorizontalAlignment','center',        ...
                    'VerticalAlignment','middle',          ...
                    'Color',actColor,                      ...
                    'FontWeight','bold',                   ...
                    'Userdata',table_node(ic),             ...
                    'ButtonDownFcn',btndown_fcn            ...
                    );
        end
        [nul,notAct] = findactn(treeobj,child,'na');
        set(hdls_txt(notAct+1),'Color',inactColor);
    end

    % Plot the new tree.
    %-------------------
    i_fath = 1;
    i_child = i_fath+[1:order];
    for d=1:depth
        ynT = ynpos(d,:);
        ynL = ynT+[0.01 -0.01];
        for p=0:order^(d-1)-1
            if table_node(i_child(1)) ~= -1
                for k=1:order
                    ic = i_child(k);
                    set(hdls_txt(ic),'Position',[xnpos(ic) ynT(2) 0]);
                    set(hdls_lin(ic),...
                    'XData',[xnpos(i_fath) xnpos(ic)], ...
                    'YData',ynL);
                end
            end
            i_child = i_child+order;
            i_fath  = i_fath+1;
        end
    end
    wmemtool('wmb',fig_tree,n_stored_val, ...
                   ind_hdls_txt,hdls_txt, ...
                   ind_hdls_lin,hdls_lin  ...
                   );
    mousefrm(fig_tree,'arrow')

  case 'getNode'
    varargout{1} = [];
    obj = get(fig_tree,'CurrentObject');
    if ~isempty(obj)
        hdls_txt = wmemtool('rmb',fig_tree,n_stored_val,ind_hdls_txt);
        axe_tree_lin = get(hdls_txt(1),'Parent');
        if isequal(get(obj,'Parent'),axe_tree_lin)
           varargout{1} = get(obj,'UserData');
        end
    end

  case 'read'
    varargout{1} = wmemtool('rmb',fig_tree,n_stored_val,ind_tree);

  case 'write'
    varargout{1} = wmemtool('wmb',fig_tree,n_stored_val,...
                      ind_tree,varargin{3},ind_Class,class(varargin{3}));

  case 'storeValue'
    % varargin{3} = name
    % varargin{4} = value
    %--------------------                       
    memB = wmemtool('rmb',fig_tree,n_toolMemB,1);
    memB.(varargin{3}) = varargin{4};
    wmemtool('wmb',fig_tree,n_toolMemB,1,memB);
    if nargout>0 , varargout = {memB}; end

  case 'getValue'
    % varargin{3} = name
    %--------------------
    memB = wmemtool('rmb',fig_tree,n_toolMemB,1);
    try   , varargout{1} = memB.(varargin{3});
    catch , varargout{1} = [];
    end

  case 'close'
    close(fig_tree)
end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function nb = nbmaxn(order,depth);
switch order
  case 1    , nb = depth+1;
  otherwise , nb = (order^(depth+1)-1)/(order-1);
end
%-----------------------------------------------------------------------------%
%=============================================================================%