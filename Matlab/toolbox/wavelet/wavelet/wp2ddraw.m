function out1 = wp2ddraw(option,win_wptool,in3)
%WP2DDRAW Wavelet packets 2-D drawing manager.
%   OUT1 = WP2DDRAW(OPTION,WIN_WPTOOL,IN3)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 16-Jul-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.15 $

% Image Coding Value.
%-------------------
codemat_v = wimgcode('get');

% Memory Blocks of stored values.
%================================
% MB1 (main window).
%-------------------
n_param_anal   = 'WP2D_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_img_size   = 6;
ind_img_t_name = 7;
ind_act_option = 8;
ind_thr_val    = 9;
nb1_stored     = 9;

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

% Tag properties.
%----------------
tag_curtree   = 'Pop_CurTree';
tag_nodact    = 'Pop_NodAct';

tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_sig   = 'Axe_Sig';
tag_img_sig   = 'Img_sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_axe_col   = 'Axe_Col';
tag_sli_size  = 'Sli_Size';
tag_sli_pos   = 'Sli_Pos';

% Miscellaneous values.
%----------------------
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
        % Img_Anal = in3;
        %----------------
        set([ WP_Axe_Tree,WP_Axe_Cfs,WP_Axe_Sig,WP_Axe_Pack, ...
              WP_Axe_Col,WP_Sli_Size,WP_Sli_Pos],'Visible','on');
        NB_ColorsInPal = wmemtool('rmb',win_wptool, ...
                                        n_wp_utils,ind_nb_colors);
        image(wimgcode('cod',0,in3,NB_ColorsInPal,codemat_v),'tag',tag_img_sig,...
                'Parent',WP_Axe_Sig);
        set(WP_Axe_Sig,'Tag',tag_axe_sig);
        s = size(in3);
        wtitle(sprintf('Analyzed Image : size = (%.0f, %.0f)',s(1),s(2)),...
                'Parent',WP_Axe_Sig);
        wtitle('Decomposition Tree','Parent',WP_Axe_Tree);
        wtitle('Node Action Result','Parent',WP_Axe_Pack);
        wtitle('Colored Coefficients for Terminal Nodes','Parent',WP_Axe_Cfs);
        image([0 1],[0 1],[1:NB_ColorsInPal],'Parent',WP_Axe_Col);
        set(WP_Axe_Col,...
                'XTickLabel',[],'YTickLabel',[],...
                'XTick',[],'YTick',[],...
                'Tag',tag_axe_col);
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
        wtitle('Colored Coefficients for Terminal Nodes',...
                'Parent',WP_Axe_Cfs);

        % Setting Dynamic Visualization tool.
        %------------------------------------
        dynvtool('init',win_wptool,...
                [WP_Axe_Pack],[WP_Axe_Sig],[WP_Axe_Cfs],[0 0],'','',...
                                                        'wp2dcoor',WP_Axe_Cfs);
        wptreeop('nodact',win_wptool,pop_nodact);

    case 'r_orig'
        out1 = findobj(WP_Axe_Sig,'type','image','tag',tag_img_sig);

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
