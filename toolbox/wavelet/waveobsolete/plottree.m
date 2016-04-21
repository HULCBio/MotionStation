function out1 = plottree(in1,in2);
%PLOTTREE Plot tree.
%   PLOTTREE(T) plots the tree structure T (see MAKETREE).
%
%   See also MAKETREE, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 02-Aug-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.14 $

% Check arguments.
if errargn(mfilename,nargin,[1:2],nargout,[0 1]), error('*'); end

% Miscelleanous Values.
%----------------------
[line_color,txt_color] = wtbutils('colors','tree');

% Tag property of objects.
%-------------------------
tag_axe_t_lin = 'Axe_TreeLines';

% MemBloc1 of stored values.
%---------------------------
n_stored_val = 'Plottree';
ind_tree     = 1;
ind_hdls_txt = 2;
ind_hdls_lin = 3;
ind_type_txt = 4;
nb1_stored   = 4;

if ~ischar(in1)
    Ts  = in1;
    clear in1
    order = wtreemgr('order',Ts);
    depth = wtreemgr('depth',Ts);
    all   = wtreemgr('allnodes',Ts);
    NB    = (order^(depth+1)-1)/(order-1);
    table_node = -ones(1,NB);
    table_node(all+1) = all;
    [xnpos,ynpos] = xynodpos(table_node,order,depth);
    option = 'create';
else
    option = in1;
end

switch option
    case 'create'
        menu_bar =  get(0,'DefaultFigureMenuBar');
        fig_tree = colordef('new','none');
        set(fig_tree,'visible', 'on',      ...
                     'menubar',menu_bar,   ...
                     'Units','normalized', ...
                     'Interruptible','On'  ...
                     );
        str_numf = int2str(fig_tree);
        m_lab    = uimenu(fig_tree,'Label','Node Label  ');
        uimenu(m_lab,...
                 'Label','Depth_Position  ',                       ...
                 'Callback',[mfilename '(''depo'',' str_numf ');'] ...
                 );
        uimenu(m_lab,...
                 'Label','Index   ',                                 ...
                 'Callback', [mfilename '(''index'',' str_numf ');'] ...
                 );

        pos_axe_tree = [0.05 0.05 0.9 0.9];
        axe_tree_lin = axes(...
                        'Parent',fig_tree,              ...
                        'Visible','off',                ...
                        'XLim',[-0.5,0.5],              ...
                        'YDir','reverse',               ...
                        'YLim',[0 1],                   ...
                        'Units','normalized',           ...
                        'Position',pos_axe_tree,        ...
                        'XTicklabelMode','manual',      ...
                        'YTicklabelMode','manual',      ...
                        'XTicklabel',[],'YTicklabel',[],...
                        'XTick',[],'YTick',[],          ...
                        'Box','On',                     ...
                        'Tag',tag_axe_t_lin             ...
                        );
        wmemtool('ini',fig_tree,n_stored_val,nb1_stored);

        hdls_lin = zeros(1,NB);
        hdls_txt = zeros(1,NB);
        axes(axe_tree_lin)
        i_fath  = 1;
        i_child = i_fath+[1:order];
        for d=1:depth
            for p=0:order^(d-1)-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        hdls_lin(ic) = line(...
                                        'Parent',axe_tree_lin,...
                                        'XData',[xnpos(i_fath) xnpos(ic)],...
                                        'YData',ynpos(d,:),...
                                        'Color',line_color);
                    end
                end
                i_child = i_child+order;
                i_fath  = i_fath+1;
            end
        end

        hdls_txt(1) = text(...
                        'Parent',axe_tree_lin,          ...
                        'String', '(0,0)',              ...
                        'FontWeight','bold',            ...
                        'Position',[0 0.1 0],           ...
                        'Color',txt_color,              ...
                        'HorizontalAlignment','center', ...
                        'VerticalAlignment','middle',   ...
                        'Clipping','on',                ...
                        'UserData',table_node(1)        ...
                        );

        i_fath         = 1;
        i_child = i_fath+[1:order];
        for d=1:depth
            d_str = int2str(d);
            for p=0:order:order^d-1
                if table_node(i_child(1)) ~= -1
                    p_child = p+[0:order-1];
                    for k=1:order
                        ic = i_child(k);
                        p_str = int2str(p_child(k));
                        hdls_txt(ic) = text(...
                                        'Parent',axe_tree_lin,...
                                        'String',['(' d_str ',' p_str ')'],...
                                        'FontWeight','bold',...
                                        'Position',[xnpos(ic) ynpos(d,2) 0],...
                                        'Color',txt_color,...
                                        'HorizontalAlignment','center',...
                                        'VerticalAlignment','middle',...
                                        'Clipping','on',...
                                        'Userdata',table_node(ic)...
                                        );
                    end
                end
                i_child = i_child+order;
            end
        end
        wmemtool('wmb',fig_tree,n_stored_val, ...
                       ind_tree,Ts,         ...
                       ind_hdls_txt,hdls_txt, ...
                       ind_hdls_lin,hdls_lin, ...
                       ind_type_txt,'p'       ...
                       );

    case 'depo'
        fig_tree = in2;
        type_txt = wmemtool('rmb',fig_tree,n_stored_val,ind_type_txt);
        if type_txt=='p', return; end
        [Ts,hdls_txt] = wmemtool('rmb',fig_tree,n_stored_val,...
                                         ind_tree,ind_hdls_txt);
        order = wtreemgr('order',Ts);
        depth = wtreemgr('depth',Ts);
        set(hdls_txt(1),'String','(0,0)')
        n = 2;
        for d=1:depth
            nd_str = int2str(d);
            for b=0:order:order^d-1
                if hdls_txt(n) ~= 0
                    for i=0:order-1
                        set(hdls_txt(n+i),'String',...
                          ['(' nd_str ',' int2str(b+i) ')']);
                    end
                end
                n = n+order;
            end
        end
        wmemtool('wmb',fig_tree,n_stored_val,ind_type_txt,'p');

    case 'index'
        fig_tree = in2;
        type_txt = wmemtool('rmb',fig_tree,n_stored_val,ind_type_txt);
        if type_txt=='i', return; end
        [Ts,hdls_txt] = wmemtool('rmb',fig_tree,n_stored_val,...
                                        ind_tree,ind_hdls_txt);
        order = wtreemgr('order',Ts);
        depth = wtreemgr('depth',Ts);
        set(hdls_txt(1),'String','(0)')
        n = 2;
        for d=1:depth
            nd_str = int2str(d);
            for b=0:order:order^d-1
                if hdls_txt(n) ~= 0
                    for i=0:order-1
                        set(hdls_txt(n+i),'String',...
                          ['(' int2str(depo2ind(order,[d b+i])) ')']);
                    end
                end
                n = n+order;
            end
        end
        wmemtool('wmb',fig_tree,n_stored_val,ind_type_txt,'i');

    case 'read'
        fig_tree = in2;
        out1 = wmemtool('rmb',fig_tree,n_stored_val,ind_tree);
end
