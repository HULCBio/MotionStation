function varargout = wp1dtool(option,varargin)
%WP1DTOOL Wavelet packets 1-D tool.
%   VARARGOUT = WP1DTOOL(OPTION,VARARGIN)
%
%   OPTION = 'create' , 'close' , 'read' , 'show'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 27-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.20 $ $Date: 2002/06/17 12:18:51 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 12;
default_nbcolors = 128;

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'WP1D_InfoInit';
ind_filename = 1;
ind_pathname = 2;
nb0_stored   = 2;

% MB1.
%-----
n_param_anal   = 'WP1D_Par_Anal';
ind_sig_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_sig_size   = 6;
ind_act_option = 7;
ind_thr_val    = 8;
nb1_stored     = 8;

% MB2.
%-----
n_wp_utils = 'WP_Utils';
ind_tree_lin  = 1;
ind_tree_txt  = 2;
ind_type_txt  = 3;
ind_sel_nodes = 4;
ind_gra_area  = 5;
ind_nb_colors = 6;
nb2_stored    = 6;

% MB3.
%-----
n_structures = 'Structures';
ind_tree_st  = 1;
ind_data_st  = 2;
nb3_stored   = 2;

% MB4.
%-----
n_sav_struct    = 'Sav_Struct';
ind_sav_tree_st = 1;
ind_sav_data_st = 2;
nb4_stored      = 2;

% Tag property of objects.
%-------------------------
tag_m_savesyn = 'Save_Syn';
tag_m_savedec = 'Save_Dec';
tag_pus_anal  = 'Pus_Anal';
tag_pus_deno  = 'Pus_Deno';
tag_pus_comp  = 'Pus_Comp';
tag_pus_btree = 'Pus_Btree';
tag_pus_blev  = 'Pus_Blev';
tag_inittree  = 'Pus_InitTree';
tag_wavtree   = 'Pus_WavTree';
tag_curtree   = 'Pop_CurTree';
tag_nodlab    = 'Pop_NodLab';
tag_nodact    = 'Pop_NodAct';
tag_nodsel    = 'Pus_NodSel';
tag_txt_full  = 'Txt_Full';
tag_pus_full  = ['Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'];
tag_txt_colm  = 'Txt_ColM';
tag_pop_colm  = 'Txt_PopM';
tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_sig   = 'Axe_Sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_axe_col   = 'Axe_Col';
tag_sli_size  = 'Sli_Size';
tag_sli_pos   = 'Sli_Pos';

switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width, ...
         X_Spacing,Y_Spacing,Def_FraBkColor] = ...
            mextglob('get',...
              'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width',   ...
              'X_Spacing','Y_Spacing','Def_FraBkColor');

        % Wavelet Packets 1-D window initialization.
        %-------------------------------------------
        [win_wptool,pos_win,win_units,str_numwin,...
                frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
                    wfigmngr('create','Wavelet Packets 1-D',...
                                        winAttrb,'ExtFig_Tool',mfilename,1,1,0);
        set(win_wptool,'tag',mfilename);
        if nargout>0 , varargout{1} = win_wptool; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_wptool,'&One-Dimensional Analysis','WP1D_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_wptool,'Wavelet Packets','WP_PACKETS');
		wfighelp('addHelpItem',win_wptool,'Tool Features','WP_TOOLS');
		wfighelp('addHelpItem',win_wptool,'Loading and Saving','WP_LOADSAVE');

        % Menu construction for current figure.
        %--------------------------------------
		[m_files,m_load,m_save] = ...
			wfigmngr('getmenus',win_wptool,'file','load','save');		
        m_loadsig = uimenu(m_load,...
                           'Label','&Signal ', ...
                           'Position',1,           ...
                           'Callback',             ...
                           ['wp1dmngr(''load_sig'',' str_numwin ');'] ...
                           );

        m_loaddec = uimenu(m_load,...
                           'Label','&Decomposition ', ...
                           'Position',2,              ...
                           'Callback',                ...
                           ['wp1dmngr(''load_dec'',' str_numwin ');'] ...
                           );

        m_savesyn = uimenu(m_save,...
                           'Label','&Synthesized Signal ',...
                           'Position',1,        ...
                           'Enable','Off',      ...
                           'Tag',tag_m_savesyn, ...
                           'Callback',          ...
                           ['wp1dmngr(''save_synt'',' str_numwin ');'] ...
                           );

        m_savedec = uimenu(m_save,...
                           'Label','&Decomposition ', ...
                           'Position',2,         ...
                           'Enable','Off',       ...
                           'Tag',tag_m_savedec,  ...
                           'Callback',           ...
                           ['wp1dmngr(''save_dec'',' str_numwin ');'] ...
                           );

        m_loadtst = uimenu(m_files,...
                           'Label','&Example Analysis ', ...
                           'Position',3,             ...
                           'Separator','Off'         ...
                           );

        % Submenu of test signals.
        %-------------------------
        beg_call_str = ['wp1dmngr(''demo'',' str_numwin];

        lab             = ['db1  - depth : 2 - ent : shannon ---> sumsin '];
        end_call_str    = [',''sumsin'',''db1'',2,''shannon'');'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 3 - ent : shannon ---> freqbrk '];
        end_call_str    = [',''freqbrk'',''haar'',3,''shannon'');'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 4 - ent : shannon ---> mfrqbrk '];
        end_call_str    = [',''mfrqbrk'',''haar'',4,''shannon'');'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 3 - ent : threshold (0.2) ---> freqbrk '];
        end_call_str    = [',''freqbrk'',''haar'',3,''threshold'',0.2);'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 3 - ent : shannon ---> vonkoch '];
        end_call_str    = [',''vonkoch'',''haar'',3,''shannon'');'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['db1  - depth : 7 - ent : shannon ---> sinper8 '];
        end_call_str    = [',''sinper8'',''db1'',7,''shannon'');'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['db1  - depth : 3 - ent : shannon ---> qdchirp '];
        end_call_str    = [',''qdchirp'',''db1'',3,''shannon'');'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['db1  - depth : 3 - ent : shannon ---> mishmash '];
        end_call_str    = [',''mishmash'',''db1'',3,''shannon'');'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 3 - ent : threshold (0.2) ---> noisbloc '];
        end_call_str    = [',''noisbloc'',''haar'',3,''threshold'',0.2);'];
        uimenu(m_loadtst,'Separator','on',...
                        'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 2 - ent : threshold (0.2) ---> noisbump '];
        end_call_str    = [',''noisbump'',''haar'',2,''threshold'',0.2);'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 2 - ent : threshold (0.2) ---> heavysin '];
        end_call_str    = [',''heavysin'',''haar'',2,''threshold'',0.2);'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 2 - ent : threshold (0.2) ---> noisdopp '];
        end_call_str    = [',''noisdopp'',''haar'',2,''threshold'',0.2);'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 2 - ent : threshold (0.2) ---> noischir '];
        end_call_str    = [',''noischir'',''haar'',2,''threshold'',0.2);'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['haar - depth : 2 - ent : threshold (0.2) ---> noismima '];
        end_call_str    = [',''noismima'',''haar'',2,''threshold'',0.2);'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['db2  - depth : 4 - ent : threshold (4) ---> linchirp '];
        end_call_str    = [',''linchirp'',''db2'',4,''threshold'',4);'];
        uimenu(m_loadtst,'Separator','on',...
                        'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['db3  - depth : 4 - ent : threshold (4) ---> quachirp '];
        end_call_str    = [',''quachirp'',''db3'',4,''threshold'',4);'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = ['sym3 - depth : 4 - ent : threshold (4) ---> sumlichr '];
        end_call_str    = [',''sumlichr'',''sym3'',4,''threshold'',4);'];
        uimenu(m_loadtst,'Label',lab,'Callback',[beg_call_str end_call_str]);

        % Begin waiting.
        %---------------
        wwaiting('msg',win_wptool,'Wait ... initialization');

        % General graphical parameters initialization.
        %--------------------------------------------
        dx = X_Spacing;  dx2 = 2*dx;
        dy = Y_Spacing;  dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);
        x_frame0   = pos_frame0(1);
        cmd_width  = pos_frame0(3);
        push_width = (cmd_width-3*dx2)/2;

        % Position property of objects.
        %------------------------------
        xlocINI    = [x_frame0 cmd_width];
        ybottomINI = pos_win(4)-3.5*Def_Btn_Height-dy2;
        ybottomENT = ybottomINI-(Def_Btn_Height+dy2)-dy;

        bdx      = (cmd_width-1.5*Def_Btn_Width)/2;
        x_left   = x_frame0+bdx;
        y_low    = ybottomENT-2*(Def_Btn_Height+2*dy2);
        pos_anal = [x_left, y_low, 1.5*Def_Btn_Width, 1.5*Def_Btn_Height];

        x_left   = x_frame0+dx2;
        y_low    = y_low-1.5*Def_Btn_Height-2*dy2;
        pos_comp = [x_left, y_low, push_width , 1.5*Def_Btn_Height];

        pos_deno    = pos_comp;
        pos_deno(1) = pos_deno(1)+pos_deno(3)+dx2;

        y_low        = y_low-Def_Btn_Height-2*dy2;
        pos_inittree = [x_left, y_low, push_width, Def_Btn_Height];
        pos_wavtree    = pos_inittree;
        pos_wavtree(1) = pos_inittree(1)+pos_inittree(3)+dx2;

        y_low       = y_low-Def_Btn_Height-dy;
        pos_btree   = [x_left, y_low, push_width, Def_Btn_Height];
        pos_blev    = pos_btree;
        pos_blev(1) = pos_btree(1)+pos_btree(3)+dx2;

        y_low         = y_low-Def_Btn_Height-dy;
        wx            = cmd_width-2*dx2-dx;
        pos_t_curtree = [x_left, y_low+d_txt/2, (2*wx)/3, Def_Txt_Height];
        x_leftB       = pos_t_curtree(1)+pos_t_curtree(3)+dx;
        pos_curtree   = [x_leftB, y_low, wx/3, Def_Btn_Height];

        y_low         = y_low-Def_Btn_Height-dy2;
        pos_t_nodlab  = [x_left, y_low+d_txt/2, wx/2, Def_Txt_Height];
        x_leftB       = pos_t_nodlab(1)+pos_t_nodlab(3)+dx;
        pos_nodlab    = [x_leftB, y_low, wx/2, Def_Btn_Height];
 
        y_low         = y_low-Def_Btn_Height-dy;
        pos_t_nodact  = [x_left, y_low+d_txt/2, wx/2, Def_Txt_Height];
        x_leftB       = pos_t_nodact(1)+pos_t_nodact(3)+dx;
        pos_nodact    = [x_leftB, y_low, wx/2, Def_Btn_Height];

        y_low         = y_low-Def_Btn_Height-dy;
        pos_t_nodsel  = [x_left, y_low+d_txt/2, wx/2+2*dx, Def_Txt_Height];
        x_leftB       = pos_t_nodsel(1)+pos_t_nodsel(3);
        pos_nodsel    = [x_leftB, y_low, wx/2-dx, Def_Btn_Height];

        pos_t_nodlab(3) = pos_t_nodlab(3)-dx2;
        pos_nodlab(1)   = pos_nodlab(1)-dx2;
        pos_nodlab(3)   = pos_nodlab(3)+dx2;
        pos_t_nodact(3) = pos_t_nodact(3)-dx2;
        pos_nodact(1)   = pos_nodact(1)-dx2;
        pos_nodact(3)   = pos_nodact(3)+dx2;

        y_low           = pos_nodsel(2)-Def_Btn_Height-dy2;
        pos_txt_full    = [x_left, y_low-Def_Btn_Height/2, wx/3, Def_Btn_Height];

        pos_pus_full    = zeros(4,4);
        xl = pos_txt_full(1)+pos_txt_full(3)+dx;
        pos_pus_full(1,:) = [xl, y_low, wx/3, Def_Btn_Height];
        pos_pus_full(2,:) = pos_pus_full(1,:);
        pos_pus_full(2,2) = pos_pus_full(2,2)-Def_Btn_Height;
        pos_pus_full(3,:) = pos_pus_full(1,:);
        pos_pus_full(3,1) = pos_pus_full(3,1)+pos_pus_full(3,3);
        pos_pus_full(4,:) = pos_pus_full(3,:);
        pos_pus_full(4,2) = pos_pus_full(4,2)-pos_pus_full(4,4);

        y_low         = pos_pus_full(4,2)-Def_Btn_Height-dy2;
        wx            = (cmd_width-2*dx2)/24;
        pos_txt_colm  = [x_left, y_low+d_txt/2, 6*wx, Def_Txt_Height];

        xl            = pos_txt_colm(1)+pos_txt_colm(3);
        y_low         = pos_txt_colm(2);
        pos_pop_colm  = [xl, y_low, 18*wx, Def_Btn_Height];

        % String property of objects.
        %----------------------------
        str_anal      = 'Analyze';
        str_btree     = 'Best Tree';
        str_comp      = 'Compress';
        str_blev      = 'Best Level';
        str_deno      = 'De-noise';
        str_inittree  = 'Initial Tree';
        str_wavtree   = 'Wavelet Tree';
        str_t_curtree = 'Cut Tree at Level : ';
        str_curtree   = '0';
        str_t_nodlab  = 'Node Label : ';
        str_nodlab    = 'Depth_Pos|Index|Entropy|Opt. Ent.|Length|None|Type|Energy';
        str_t_nodact  = 'Node Action : ';
        str_nodact    = 'Visualize|Split / Merge|Recons.|Select On';
        str_nodact    = [str_nodact '|Select Off|Statistics|View Col. Cfs'];
        str_t_nodsel  = 'Select Nodes and';
        str_nodsel    = 'Reconstruct';
        str_txt_full  = 'Full Size';
        str_txt_colm  = 'Cfs Col.';
        str_pop_colm  = [ 'FRQ : Global + abs  ' ; 'FRQ : By Level + abs' ; ...
                          'FRQ : Global        ' ; 'FRQ : By Level      ' ; ...
                          'NAT : Global + abs  ' ; 'NAT : By Level + abs' ; ...
                          'NAT : Global        ' ; 'NAT : By Level      '   ...
                        ];

        % Callback property of objects.
        %------------------------------
        cba_WPOpt      = 'wptreeop';
        cba_anal       = ['wp1dmngr(''anal'',' str_numwin ');'];
        cba_comp       = ['wp1dmngr(''comp'',' str_numwin ');'];
        cba_deno       = ['wp1dmngr(''deno'',' str_numwin ');'];
        cba_btree      = [cba_WPOpt '(''best'',' str_numwin ');'];
        cba_blev       = [cba_WPOpt '(''blvl'',' str_numwin ');'];
        cba_inittree   = [cba_WPOpt '(''restore'',' str_numwin ');'];
        cba_wavtree    = [cba_WPOpt '(''wp2wtree'',' str_numwin ');'];
        cba_nodact     = [cba_WPOpt '(''nodact'',' str_numwin ');'];
        cba_nodlab     = [cba_WPOpt '(''nodlab'',' str_numwin ');'];
        cba_pus_nodsel = [cba_WPOpt '(''recons'',' str_numwin ');'];

        % Command part of the window.
        %============================

        % Data, Wavelet and Level parameters.
        %------------------------------------
        utanapar('create',win_wptool, ...
                 'xloc',xlocINI,'bottom',ybottomINI,...
                 'enable','off', ...
                 'wtype','dwt'   ...
                 );

        % Entropy parameters.
        %--------------------
        utentpar('create',win_wptool, ...
                 'xloc',xlocINI,'bottom',ybottomENT,'enable','off' ...
                 );


        comFigProp = {'Parent',win_wptool,'Unit',win_units};
        comPusProp = {comFigProp{:},'Style','Pushbutton','Enable','Off'};
        comPopProp = {comFigProp{:},'Style','Popupmenu','Enable','Off'};
        comTxtProp = {comFigProp{:},'Style','text', ...
           'HorizontalAlignment','left','Backgroundcolor',Def_FraBkColor};
        pus_anal     = uicontrol(...
                                 comPusProp{:},       ...
                                 'Position',pos_anal, ...
                                 'String',xlate(str_anal),   ...
                                 'Tag',tag_pus_anal,  ...
                                 'Callback',cba_anal, ...
                                 'Interruptible','On' ...
                                 );

        pus_comp     = uicontrol(...
                                 comPusProp{:},       ...
                                 'Position',pos_comp, ...
                                 'String',xlate(str_comp),   ...
                                 'Tag',tag_pus_comp,  ...
                                 'Callback',cba_comp  ...
                                 );

        pus_deno     = uicontrol(...
                                 comPusProp{:},       ...
                                 'Position',pos_deno, ...
                                 'String',xlate(str_deno),   ...
                                 'Tag',tag_pus_deno,  ...
                                 'Callback',cba_deno  ...
                                 );

        pus_inittree = uicontrol(...
                                 comPusProp{:},          ...
                                 'Position',pos_inittree,...
                                 'String',xlate(str_inittree),  ...
                                 'Tag',tag_inittree,     ...
                                 'Callback',cba_inittree ...
                                 );

        pus_wavtree  = uicontrol(...
                                 comPusProp{:},          ...
                                 'Position',pos_wavtree, ...
                                 'String',xlate(str_wavtree),   ...
                                 'Tag',tag_wavtree,      ...
                                 'Callback',cba_wavtree  ...
                                 );

        pus_btree    = uicontrol(...
                                 comPusProp{:},        ...
                                 'Position',pos_btree, ...
                                 'String',xlate(str_btree),   ...
                                 'Tag',tag_pus_btree,  ...
                                 'Callback',cba_btree  ...
                                 );

        pus_blev     = uicontrol(...
                                 comPusProp{:},       ...
                                 'Position',pos_blev, ...
                                 'String',xlate(str_blev),   ...
                                 'Tag',tag_pus_blev,  ...
                                 'Callback',cba_blev  ...
                                 );

        pop_curtree  = uicontrol(...
                                 comPopProp{:},          ...
                                 'Position',pos_curtree, ...
                                 'String',str_curtree,   ...
                                 'Tag',tag_curtree       ...
                                 );

        txt_curtree = uicontrol(...
                                comTxtProp{:},            ...
                                'Position',pos_t_curtree, ...
                                'String',str_t_curtree    ...
                                );

        txt_nodlab   = uicontrol(...
                                 comTxtProp{:},           ...
                                 'Position',pos_t_nodlab, ...
                                 'String',str_t_nodlab    ...
                                 );

        pop_nodlab   = uicontrol(...
                                 comPopProp{:},         ...
                                 'Position',pos_nodlab, ...
                                 'String',str_nodlab,   ...
                                 'CallBack',cba_nodlab, ...
                                 'Tag',tag_nodlab       ...
                                 );

        txt_nodact   = uicontrol(...
                                 comTxtProp{:},           ...
                                 'Position',pos_t_nodact, ...
                                 'String',str_t_nodact    ...
                                 );

        pop_nodact   = uicontrol(...
                                 comPopProp{:},         ...
                                 'Position',pos_nodact, ...
                                 'String',str_nodact,   ...
                                 'CallBack',cba_nodact, ...
                                 'Tag',tag_nodact       ...
                                 );

        txt_nodsel   = uicontrol(...
                                 comTxtProp{:},           ...
                                 'Position',pos_t_nodsel, ...
                                 'String',str_t_nodsel    ...
                                 );

        pus_nodsel   = uicontrol(...
                                 comPusProp{:},          ...
                                 'Position',pos_nodsel,  ...
                                 'String',xlate(str_nodsel),    ...
                                 'Tag',tag_nodsel,       ...
                                 'Callback',cba_pus_nodsel...
                                 );

        txt_full     = uicontrol(...
                                 comTxtProp{:},           ...
                                 'Position',pos_txt_full, ...
                                 'String',str_txt_full,   ...
                                 'Tag',tag_txt_full       ...
                                 );
        tooltip = strvcat(...
            'View decomposition tree',  ...
            'View node action result',...
            'View analyzed signal', ...
            'View colored coefficients' ...
            );
        for k=1:4
            pus_full(k) = uicontrol(...
                                    comPusProp{:},        ...
                                    'Position',pos_pus_full(k,:), ...
                                    'String',sprintf('%.0f',k),   ...
                                    'Userdata',0,                 ...
                                    'ToolTip',deblank(tooltip(k,:)), ...
                                    'Tag',tag_pus_full(k,:)       ...
                                    );
        end

        txt_colm = uicontrol(...
                             comTxtProp{:},           ...
                             'Position',pos_txt_colm, ...
                             'String',str_txt_colm,   ...
                             'Tag',tag_txt_colm       ...
                             );

        pop_colm = uicontrol(...
                             comPopProp{:},          ...
                             'Position',pos_pop_colm,...
                             'String',str_pop_colm,  ...
                             'Userdata',1,           ...
                             'Tag',tag_pop_colm      ...
                             );
        drawnow;

        % Adding colormap GUI.
        %---------------------
        utcolmap('create',win_wptool, ...
                 'xloc',xlocINI, ...
                 'briflag',0, ...
                 'bkcolor',Def_FraBkColor);

        %  Normalisation.
        %----------------
        Pos_Graphic_Area = wfigmngr('normalize',win_wptool,Pos_Graphic_Area);
        drawnow

        %  Axes Construction.
        %---------------------
        [pos_axe_pack,   pos_axe_tree,   pos_axe_cfs,    ...
         pos_axe_sig,    pos_sli_size,   pos_sli_pos     ...
         pos_axe_col] =  wpposaxe(win_wptool,1,Pos_Graphic_Area);

        comFigProp = {'Parent',win_wptool,'Units','normalized','Visible','off'};
        WP_Sli_Siz = uicontrol(...
                               comFigProp{:},          ...
                               'Style','slider',       ...
                               'Position',pos_sli_size,...
                               'Min',0.5,              ...
                               'Max',10,               ...
                               'Value',1,              ...
                               'UserData',1,           ...
                               'Tag',tag_sli_size      ...
                               );

        WP_Sli_Pos = uicontrol(...
                               comFigProp{:},          ...
                               'Style','slider',       ...
                               'Position',pos_sli_pos, ...
                               'Min',0,                ...
                               'Max',1,                ...
                               'Value',0,              ...
                               'Tag',tag_sli_pos       ...
                               );
        drawnow;
        commonProp = {...
           comFigProp{:},                  ...
           'XTicklabelMode','manual',      ...
           'YTicklabelMode','manual',      ...
           'XTicklabel',[],'YTicklabel',[],...
           'XTick',[],'YTick',[],          ...
           'Box','On'                      ...
           };

        WP_Axe_Tree = axes(commonProp{:}, ...
                           'XLim',[-0.5,0.5],       ...
                           'YDir','reverse',        ...
                           'YLim',[0 1],            ...
                           'Position',pos_axe_tree, ...
                           'Tag',tag_axe_t_lin      ...
                           );

        WP_Axe_Pack = axes(commonProp{:}, ...
                           'Position',pos_axe_pack,'Tag',tag_axe_pack);

        WP_Axe_Cfs  = axes(commonProp{:}, ...
                           'Position',pos_axe_cfs,'Tag',tag_axe_cfs);

        WP_Axe_Sig  = axes(commonProp{:}, ...
                           'Position',pos_axe_sig,'Tag',tag_axe_sig);

        WP_Axe_Col  = axes(commonProp{:}, ...
                           'Position',pos_axe_col,'Tag',tag_axe_col);

        % Callbacks update.
        %------------------
        utanapar('set_cba_num',win_wptool,[m_files;pus_anal]);
        
        cba_curtree  = [cba_WPOpt '(''cuttree'',' str_numwin ',' ...
                        num2mstr(pop_curtree) ');'];

        cba_colm     = [cba_WPOpt '(''col_mode'',' str_numwin ',' ...
                        num2mstr(pop_colm) ');'];

        cba_sli_siz  = [cba_WPOpt '(''slide_size'',' str_numwin ',' ...
                        num2mstr(WP_Sli_Siz) ','    ...
                        num2mstr(WP_Sli_Pos) ');'];

        cba_sli_pos  = [cba_WPOpt '(''slide_pos'',' str_numwin  ',' ...
                        num2mstr(WP_Sli_Pos) ');'];

        set(pop_curtree,'Callback',cba_curtree);
        set(pop_colm,'Callback',cba_colm);
        set(WP_Sli_Siz,'Callback',cba_sli_siz);
        set(WP_Sli_Pos,'Callback',cba_sli_pos);
        beg_cba = ['wpfullsi(''full'',' str_numwin ','];
        for k=1:4
            cba_pus_full = [beg_cba  sprintf('%.0f',k) ');'];
            set(pus_full(k),'Callback',cba_pus_full);
        end
        drawnow;

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_WP_TOOLS = [...
				txt_nodlab,pop_nodlab, ...
				txt_nodact,pop_nodact, ...
				txt_nodsel,pus_nodsel, ...
				txt_colm,pop_colm      ...
				];
		wfighelp('add_ContextMenu',win_wptool,pus_btree,'WP_BESTTREE');
		wfighelp('add_ContextMenu',win_wptool,hdl_WP_TOOLS,'WP_TOOLS');		
		%-------------------------------------
		
        % Memory for stored values.
        %--------------------------
        wmemtool('ini',win_wptool,n_InfoInit,nb0_stored);
        wmemtool('ini',win_wptool,n_param_anal,nb1_stored);
        wmemtool('ini',win_wptool,n_wp_utils,nb2_stored);
        wmemtool('ini',win_wptool,n_structures,nb3_stored);
        wmemtool('ini',win_wptool,n_sav_struct,nb4_stored);
        wmemtool('wmb',win_wptool,n_wp_utils,ind_gra_area,Pos_Graphic_Area);

        % Setting Initial Colormap.
        %--------------------------
        cbcolmap('set',win_wptool,'pal',{'cool',default_nbcolors});

        % End waiting.
        %---------------
        wwaiting('off',win_wptool);

    case 'close'
        fig = varargin{1};
        called_win = wfindobj('figure','Userdata',fig);
        delete(called_win);
        ssig_file = ['ssig_rec.' sprintf('%.0f',fig)];
        if exist(ssig_file)==2
            try , delete(ssig_file); end
        end

    case 'read'
        %****************************************************%
        %** OPTION = 'read' - read tree (and data struct). **%
        %****************************************************%
        % in2 = hdl fig
        %--------------
        % out1 = tree struct
        % (out2 = data struct - optional)
        %--------------------------------
        fig = varargin{1};
        err = 1-ishandle(fig);
        if err==0
            if ~strcmp(get(fig,'tag'),mfilename) , err = 1; end
        end
        if err
            errargt(mfilename,'Invalid figure !','msg');
            return;
        end
        [varargout{1},varargout{2}] = ...
            wmemtool('rmb',fig,n_structures,ind_tree_st,ind_data_st);

    case 'show'
        %**************************************************%
        %** OPTION = 'show' - show tree and data struct. **%
        %**************************************************%
        % in2 = hdl fig
        % in3 = tree struct
        % (in4 = data struct)
        %---------------------
        fig = varargin{1};      
        err = 1-ishandle(fig);
        if err
            fig = wp1dtool; err = 0;
        elseif ~strcmp(get(fig,'tag'),mfilename)
            err = 1;
        end
        if err
            errargt(mfilename,'Invalid figure !','msg');
            return;
        end
        wp1dmngr('load_dec',varargin{:});

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
