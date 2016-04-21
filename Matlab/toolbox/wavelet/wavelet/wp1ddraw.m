function out1 = wp1ddraw(option,win_wptool,in3)
%WP1DDRAW Wavelet packets 1-D drawing manager. 
%   OUT1 = WP1DDRAW(OPTION,WIN_WPTOOL,IN3)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 08-Jun-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.15 $

% Memory Blocks of stored values.
%================================
% MB2 (main window).
%-------------------
n_wp_utils = 'WP_Utils';
ind_tree_lin  = 1;
ind_tree_txt  = 2;
ind_type_txt  = 3;
ind_sel_nodes = 4;
ind_gra_area  = 5;
ind_nb_colors = 6;
nb2_stored    = 6;

% MB3 (main window).
%-------------------
n_structures = 'Structures';
ind_tree_st  = 1;
ind_data_st  = 2;
nb3_stored   = 2;

% Tag property of objects.
%-------------------------
tag_pop_colm  = 'Txt_PopM';
tag_curtree   = 'Pop_CurTree';
tag_nodact    = 'Pop_NodAct';

tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_sig   = 'Axe_Sig';
tag_lin_sig   = 'Lin_sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_axe_col   = 'Axe_Col';
tag_sli_size  = 'Sli_Size';
tag_sli_pos   = 'Sli_Pos';

% Miscellaneous values.
%----------------------
Col_SigIni  = 'r';
children    = get(win_wptool,'Children');
axe_handles = findobj(children,'flat','type','axes');
uic_handles = findobj(children,'flat','type','uicontrol');
WP_Axe_Tree = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
WP_Axe_Sig  = findobj(axe_handles,'flat','Tag',tag_axe_sig);
WP_Axe_Pack = findobj(axe_handles,'flat','Tag',tag_axe_pack);
WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
WP_Axe_Col  = findobj(axe_handles,'flat','Tag',tag_axe_col);
WP_Sli_Size = findobj(uic_handles,'Tag',tag_sli_size);
WP_Sli_Pos  = findobj(uic_handles,'Tag',tag_sli_pos);

switch option
    case 'sig'
        % Signal_Anal = in3;
        %------------------
        set([ WP_Axe_Tree,WP_Axe_Cfs,WP_Axe_Sig,WP_Axe_Pack, ...
              WP_Axe_Col,WP_Sli_Size,WP_Sli_Pos],'Visible','on');
        xmin = 1;         xmax = length(in3);
        ymin = min(in3);  ymax = max(in3);
        if ymin==ymax , dy = 0.01; else , dy = (ymax-ymin)/25; end
        ymin = ymin-dy;   ymax = ymax+dy;
        plot(in3,'Color',Col_SigIni,'tag',tag_lin_sig,'Parent',WP_Axe_Sig);
        set(WP_Axe_Sig,'Xlim',[xmin xmax],'Ylim',[ymin ymax],'Tag',tag_axe_sig);
        wtitle(sprintf('Analyzed Signal : length = %.0f',xmax),...
                'Parent',WP_Axe_Sig);
        wtitle('Decomposition Tree','Parent',WP_Axe_Tree);
        wtitle('Node Action Result','Parent',WP_Axe_Pack);
        set(WP_Axe_Cfs,'Xlim',[xmin xmax]);
        wtitle('Colored Coefficients for Terminal Nodes','Parent',WP_Axe_Cfs);
        pop_colm = findobj(win_wptool,'style','popupmenu',...
                                        'tag',tag_pop_colm);
        col_mode = get(pop_colm,'Value');
        if find(col_mode==[1 2 3 4])
            strlab = ['frequency ordered coefficients'];
        else
            strlab = ['(down -> up) for Cfs <==> (left -> right) in Tree'];
        end
        wsetxlab(WP_Axe_Cfs,strlab);
        NB_ColorsInPal  = wmemtool('rmb',win_wptool,    ...
                                        n_wp_utils,ind_nb_colors);
        image([0 1],[0 1],[1:NB_ColorsInPal],'Parent',WP_Axe_Col);
        set(WP_Axe_Col,...
                'XTickLabel',[],'YTickLabel',[],...
                'XTick',[],'YTick',[],'Tag',tag_axe_col);
        wsetxlab(WP_Axe_Col,'Scale of Colors from Min to Max');

    case 'anal'
        pop_handles = findobj(uic_handles,'style','popupmenu');
        pop_curtree = findobj(pop_handles,'Tag',tag_curtree);
        pop_nodact  = findobj(pop_handles,'Tag',tag_nodact);

        % Reading structures.
        %--------------------
        [tree_struct,data_struct] = wmemtool('rmb',win_wptool,n_structures,...
                                                   ind_tree_st,ind_data_st);
        if isa(tree_struct,'wptree')
            wptreeop('input_tree',win_wptool,tree_struct);
        else
            wptreeop('input_tree',win_wptool,tree_struct,data_struct);
        end
        depth = treedpth(tree_struct);
        str_depth = int2str([0:depth]');
        set(pop_curtree,'String',str_depth,'Value',depth+1);
        wtitle('Node Action Result','Parent',WP_Axe_Pack);

        % Setting Dynamic Visualization tool.
        %------------------------------------
        dynvtool('init',win_wptool,...
                        [WP_Axe_Pack],[WP_Axe_Sig,WP_Axe_Cfs],[],[1 0],'','',...
                                                        'wp1dcoor',WP_Axe_Cfs);
        wptreeop('nodact',win_wptool,pop_nodact);

    case 'r_orig'
        out1 = findobj(WP_Axe_Sig,'type','line','tag',tag_lin_sig);

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
