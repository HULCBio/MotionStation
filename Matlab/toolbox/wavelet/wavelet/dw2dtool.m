function varargout = dw2dtool(option,varargin)
%DW2DTOOL Discrete wavelet 2-D tool.
%   VARARGOUT = DW2DTOOL(OPTION,VARARGIN)
%
%   OPTION = 'create' , 'close'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 15-Jan-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.20 $ $Date: 2002/06/17 12:19:05 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 5;
default_nbcolors = 128;

% Tag property of objects.
%-------------------------
tag_m_savesyn = 'Save_Syn';
tag_m_savecfs = 'Save_Cfs';
tag_m_savedec = 'Save_Dec';
tag_pus_anal  = 'Pus_Anal';
tag_pus_deno  = 'Pus_Deno';
tag_pus_comp  = 'Pus_Comp';
tag_pus_hist  = 'Pus_Hist';
tag_pus_stat  = 'Pus_Stat';
tag_pop_declev= 'Pop_DecLev';
tag_pus_vis   = 'Pus_Visu';
tag_pus_big   = 'Pus_Big';
tag_pus_rec   = 'Pus_Rec';
tag_pop_viewm = 'Pop_ViewM';
tag_txt_full  = 'Txt_Full';
tag_pus_full  = ['Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'];

tag_axefigutil = 'Axe_FigUtil';
tag_linetree   = 'Tree_lines';
tag_txttree    = 'Tree_txt';
tag_axeimgbig  = 'Axe_ImgBig';
tag_axeimgini  = 'Axe_ImgIni';
tag_axeimgvis  = 'Axe_ImgVis';
tag_axeimgsel  = 'Axe_ImgSel';
tag_axeimgdec  = 'Axe_ImgDec';
tag_axeimgsyn  = 'Axe_ImgSyn';
tag_axeimghdls = 'Img_Handles';

% MemBloc0 of stored values.
%---------------------------
n_InfoInit   = 'DW2D_InfoInit';
ind_filename = 1;
ind_pathname = 2;
nb0_stored   = 2;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn2d_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_img_t_name = 4;
ind_img_size   = 5;
ind_nbcolors   = 6;
ind_act_option = 7;
ind_simg_type  = 8;
ind_thr_val    = 9;
nb1_stored     = 9;

% MemBloc2.1 and 2.2 of stored values.
%------------------------------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MemBloc3 of stored values.
%---------------------------
n_miscella      = 'DWAn2d_Miscella';
ind_graph_area  =  1;
ind_pos_axebig  =  2;
ind_pos_axeini  =  3;
ind_pos_axevis  =  4;
ind_pos_axedec  =  5;
ind_pos_axesyn  =  6;
ind_pos_axesel  =  7;
ind_view_status =  8;
ind_save_status =  9;
ind_sel_funct   = 10;
nb3_stored      = 10;

% Miscellaneous values.
%----------------------
% square_viewm  = 1;
% tree_viewm    = 2;
% BoxTitleSel_Col = 'g';

switch option
    case 'create'

        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width,  ...
         X_Spacing,Y_Spacing,Def_FraBkColor] = ...
            mextglob('get',...
              'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width','Pop_Min_Width',  ...
              'X_Spacing','Y_Spacing','Def_FraBkColor' ...
              );

        % Variables initialization.
        %--------------------------
        BoxTitleSel_Col = 'g';
        Width_LineSel   = 3;
        select_funct    = 'dw2dimgs(''get_img'');';

        % Wavelet 2-D window initialization.
        %-----------------------------------
        win_title = 'Wavelet 2-D';
        [win_dw2dtool,pos_win,win_units,str_numwin,...
             frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
                wfigmngr('create',win_title,winAttrb,'ExtFig_Tool',mfilename,1,1,0);
        if nargout>0 , varargout{1} = win_dw2dtool; end
		
		% Add Coloration Mode Submenu.
		%-----------------------------
		wfigmngr('add_CCM_Menu',win_dw2dtool);

		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_dw2dtool,'T&wo-Dimensional Analysis','DW2D_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_dw2dtool,'Working with Images','DW2D_WORKING');
		wfighelp('addHelpItem',win_dw2dtool,'Loading and Saving','DW2D_LOADSAVE');

        % Menu construction for current figure.
        %--------------------------------------
		[m_files,m_load,m_save] = ...
			wfigmngr('getmenus',win_dw2dtool,'file','load','save');
				
        m_loadimg = uimenu(m_load,...
                                'Label','&Image ',    ...
                                'Position',1,             ...
                                'Callback',               ...
                                ['dw2dmngr(''load_img'',' ...
                                        str_numwin ');']  ...
                                );

        m_loadcfs = uimenu(m_load,...
                                'Label','&Coefficients ', ...
                                'Position',2,             ...
                                'Callback',               ...
                                ['dw2dmngr(''load_cfs'',' ...
                                        str_numwin ');']  ...
                                );
        m_loaddec = uimenu(m_load,...
                                'Label','&Decomposition ', ...
                                'Position',3,              ...
                                'Callback',                ...
                                ['dw2dmngr(''load_dec'','  ...
                                        str_numwin ');']   ...
                                );

		m_savesyn = uimenu(m_save,...
                                'Label','&Synthesized Image ',...
                                'Position',1,                 ...
                                'Enable','Off',               ...
                                'Tag',tag_m_savesyn,          ...
                                'Callback',                   ...
                                ['dw2dmngr(''save_synt'','    ...
                                        str_numwin ');']      ...
                                );
        m_savecfs = uimenu(m_save,...
                                'Label','&Coefficients ', ...
                                'Position',2,             ...
                                'Enable','Off',           ...
                                'Tag',tag_m_savecfs,      ...
                                'Callback',               ...
                                ['dw2dmngr(''save_cfs'',' ...
                                        str_numwin ');']  ...
                                );
        m_savedec = uimenu(m_save,...
                                'Label','&Decomposition ', ...
                                'Position',3,              ...
                                'Enable','Off',            ...
                                'Tag',tag_m_savedec,       ...
                                'Callback',                ...
                                ['dw2dmngr(''save_dec'','  ...
                                        str_numwin ');']   ...
                                );
        m_loadtst = uimenu(m_files,...
                                'Label','&Example Analysis ', ...
                                'Position',3,             ...
                                'Separator','Off'         ...
                                );

        % Submenu of test signals.
        %-------------------------
        beg_call_str = ['dw2dmngr(''demo'',' str_numwin];
        tab  = setstr(9);
        sep1 = ['At level '];
        sep2 = [' , with '];
        sep3 = ['    ' tab ' ---> '];

        lab_str = [sep1 '3' sep2 'sym4' sep3 'Detail Durer '];
        cba     = [beg_call_str ',''detail'',''sym4'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '2' sep2 'haar' sep3 'Woman '];
        cba     = [beg_call_str ',''woman'',''haar'',2);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'haar' sep3 'Finger '];
        cba     = [beg_call_str ',''detfingr'',''haar'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'haar' sep3 'Tire '];
        cba     = [beg_call_str ',''tire'',''haar'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'sym3' sep3 'Chess '];
        cba     = [beg_call_str ',''chess'',''sym3'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '2' sep2 'bior3.7' sep3 'Barb '];
        cba     = [beg_call_str ',''wbarb'',''bior3.7'',2);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'bior5.5' sep3 'Facets '];
        cba     = [beg_call_str ',''facets'',''bior5.5'',3);'];
        uimenu(m_loadtst,'Separator','on','Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'bior4.4' sep3 'Geometry '];
        cba     = [beg_call_str ',''geometry'',''bior4.4'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '4' sep2 'db3' sep3 'Sinsin '];
        cba     = [beg_call_str ',''sinsin'',''db3'',4);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'coif2' sep3 'Tartan '];
        cba     = [beg_call_str ',''tartan'',''coif2'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'db1' sep3 'Mandel set '];
        cba     = [beg_call_str ',''mandel'',''db1'',3);'];
        uimenu(m_loadtst,'Separator','on','Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'db1' sep3 'Julia set '];
        cba     = [beg_call_str ',''julia'',''db1'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '5' sep2 'coif1' sep3 'Ifs '];
        cba     = [beg_call_str ',''wifs'',''coif1'',5);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'db2' sep3 'Noisy Woman '];
        cba     = [beg_call_str ',''noiswom'',''db2'',3);'];
        uimenu(m_loadtst,'Separator','on','Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'bior6.8' sep3 'Noisy SinSin '];
        cba     = [beg_call_str ',''noissi2d'',''bior6.8'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '2' sep2 'haar' sep3 'Mandrill '];
        cba     = [beg_call_str ',''wmandril'',''haar'',2);'];
        uimenu(m_loadtst,'Separator','on','Label',lab_str,'Callback',cba);

        lab_str = [sep1 '2' sep2 'sym5' sep3 'Gatlin '];
        cba     = [beg_call_str ',''wgatlin'',''sym5'',2);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        lab_str = [sep1 '3' sep2 'bior1.5' sep3 'Belmont 1'];
        cba     = [beg_call_str ',''belmont1'',''bior1.5'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);
  
        lab_str = [sep1 '3' sep2 'coif1' sep3 'Belmont 2'];
        cba     = [beg_call_str ',''belmont2'',''coif1'',3);'];
        uimenu(m_loadtst,'Label',lab_str,'Callback',cba);

        % Begin waiting.
        %---------------
        wwaiting('msg',win_dw2dtool,'Wait ... initialization');

        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing; dx2 = 2*dx;
        dy = Y_Spacing; dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);
        x_frame0   = pos_frame0(1);
        btn_width  = Def_Btn_Width;
        w_subframe = pos_frame0(3)-4*dx;
        w_util     = (pos_frame0(3)-9*dx)/3;
        push_width = (pos_frame0(3)-8*dx)/2;
        pop_width  = Pop_Min_Width;

        % Position property of objects.
        %------------------------------
        xlocINI    = pos_frame0([1 3]);
        ybottomINI = pos_win(4)-3.5*Def_Btn_Height-dy2;
        y_low      = ybottomINI;

        bdx        = (pos_frame0(3)-1.5*btn_width)/2;
        x_left     = x_frame0+bdx;
        y_low      = y_low-Def_Btn_Height-3*dy2;
        h_btn      = 1.5*Def_Btn_Height;
        pos_anal   = [x_left, y_low, 1.5*btn_width, h_btn];

        x_left     = x_frame0+dx2;
        y_low      = pos_anal(2)-1.5*Def_Btn_Height-2*dy2;
        push_width = (pos_frame0(3)-3*dx2)/2;
        pos_stat   = [x_left, y_low, push_width, h_btn];

        pos_comp    = pos_stat;
        pos_comp(1) = pos_stat(1)+pos_stat(3)+dx2;

        y_low       = y_low-1.5*Def_Btn_Height-dy;
        pos_hist    = [x_left, y_low, push_width, h_btn];
        pos_deno    = pos_hist;
        pos_deno(1) = pos_hist(1)+pos_hist(3)+dx2;

        y_low          = y_low-Def_Btn_Height-2*dy2;
        w_txt          = 2*push_width+dx2-pop_width;
        pos_txt_declev = [x_left, y_low+d_txt/2, w_txt, Def_Txt_Height];

        pos_declev     = [x_left+4*dx2, y_low, pop_width, Def_Btn_Height];
        pos_declev(1)  = pos_txt_declev(1)+pos_txt_declev(3);

        y_low          = y_low-Def_Btn_Height-2*dy2;
        pos_pop_viewm  = [x_left, y_low, 2*push_width+dx2, Def_Btn_Height];

        y_low          = y_low-Def_Btn_Height-dy2;
        w_txt          = dx2+w_util;
        xl             = x_left+dx;
        yl             = y_low-Def_Txt_Height/2;
        pos_txt_full   = [xl, yl, w_txt, Def_Txt_Height];

        pos_pus_full      = zeros(4,4);
        xl                = pos_txt_full(1)+pos_txt_full(3)+dx;
        pos_pus_full(1,:) = [xl, y_low, w_util, Def_Btn_Height];

        pos_pus_full(2,:) = pos_pus_full(1,:);
        pos_pus_full(2,2) = pos_pus_full(2,2)-Def_Btn_Height;

        pos_pus_full(3,:) = pos_pus_full(1,:);
        pos_pus_full(3,1) = pos_pus_full(3,1)+pos_pus_full(3,3);

        pos_pus_full(4,:) = pos_pus_full(3,:);
        pos_pus_full(4,2) = pos_pus_full(4,2)-pos_pus_full(4,4);

        y_low       = y_low-2*Def_Btn_Height-3*dy2;
        pos_tdrag   = [x_left, y_low, w_subframe, Def_Btn_Height];

        h_btn       = 1.25*Def_Btn_Height;
        w_btn       = 1.25*push_width;
        x_btn       = x_frame0+(pos_frame0(3)-w_btn)/2;
        y_low       = y_low-h_btn;
        pos_pus_vis = [x_btn , y_low , w_btn ,h_btn];
        y_low       = y_low-h_btn;
        pos_pus_big = [x_btn , y_low , w_btn ,h_btn];
        y_low       = y_low-h_btn;
        pos_pus_rec = [x_btn , y_low , w_btn ,h_btn];

        % String property of objects.
        %----------------------------
        str_anal       = 'Analyze';
        str_synt       = 'Synthesize';
        str_stat       = 'Statistics';
        str_comp       = 'Compress';
        str_hist       = 'Histograms';
        str_deno       = 'De-noise';
        str_txtlev_dec = 'Decomposition at level : ';
        str_vallev_dec = int2str([1:max_lev_anal]');
        str_txt_drag   = 'Operations on selected image : ';
        str_rec        = 'Reconstruct';
        str_vis       = 'Visualize';
        str_big        = 'Full Size';
        str_pop_viewm  = 'View mode : Square|View mode : Tree';
        str_txt_full   = 'Full Size';

        % Callback property of objects.
        %------------------------------
        cba_pus_anal   = ['dw2dmngr(''analyze'',' str_numwin ');'];
        cba_stat       = ['dw2dmngr(''stat'',' str_numwin ');'];
        cba_comp       = ['dw2dmngr(''comp'',' str_numwin ');'];
        cba_hist       = ['dw2dmngr(''hist'',' str_numwin ');'];
        cba_deno       = ['dw2dmngr(''deno'',' str_numwin ');'];
        cba_pop_declev = ['dw2dmngr(''view_dec'',' str_numwin ');'];
        cba_pop_viewm  = ['dw2dmngr(''view_mode'',' str_numwin ');'];

        % Command part of the window.
        %============================
        % Data, Wavelet and Level parameters.
        %------------------------------------
        utanapar('create',win_dw2dtool, ...
                 'xloc',xlocINI,'bottom',ybottomINI,...
                 'enable','off',        ...
                 'wtype','dwt',         ...
                 'maxlev',max_lev_anal  ...
                 );
        comFigProp = {'Parent',win_dw2dtool,'Unit',win_units};
        comPusProp = {comFigProp{:},'Style','Pushbutton','Enable','off'};
        comPopProp = {comFigProp{:},'Style','Popupmenu','Enable','off'};
        comTxtProp = {comFigProp{:},'Style','Text', ...
                      'Backgroundcolor',Def_FraBkColor};
        pus_anal = uicontrol(comPusProp{:},...
                             'Position',pos_anal,...
                             'String',xlate(str_anal),...
                             'Tag',tag_pus_anal,...
                             'Interruptible','On',...
                             'Callback',cba_pus_anal...
                             );

        pus_stat = uicontrol(comPusProp{:},...
                             'Position',pos_stat,...
                             'String',xlate(str_stat),...
                             'Tag',tag_pus_stat,...
                             'Callback',cba_stat...
                             );

        pus_comp = uicontrol(comPusProp{:},...
                             'Position',pos_comp,...
                             'String',xlate(str_comp),...
                             'Tag',tag_pus_comp,...
                             'Callback',cba_comp...
                             );

        pus_hist = uicontrol(comPusProp{:},...
                             'Position',pos_hist,...
                             'String',xlate(str_hist),...
                             'Tag',tag_pus_hist,...
                             'Callback',cba_hist...
                             );

        pus_deno = uicontrol(comPusProp{:},...
                             'Position',pos_deno,...
                             'String',xlate(str_deno),...
                             'Tag',tag_pus_deno,...
                             'Callback',cba_deno...
                             );

        txt_declev = uicontrol(comTxtProp{:},...
                               'Position',pos_txt_declev,...
                               'HorizontalAlignment','left',...
                               'String',str_txtlev_dec...
                               );

        pop_declev = uicontrol(comPopProp{:},...
                               'Position',pos_declev,...
                               'String',str_vallev_dec,...
                               'Tag',tag_pop_declev,...
                               'Callback',cba_pop_declev...
                               );

        pop_view_mode = uicontrol(comPopProp{:},...
                                  'Position',pos_pop_viewm,...
                                  'String',str_pop_viewm,...
                                  'Callback',cba_pop_viewm,...
                                  'Tag',tag_pop_viewm...
                                  );

        txt_full = uicontrol(comTxtProp{:},...
                             'HorizontalAlignment','Center',...
                             'Position',pos_txt_full,...
                             'String',str_txt_full,...
                             'Tag',tag_txt_full...
                             );

        tooltip = strvcat(...
            'View original image',    ...
            'View synthesized image', ...
            'View selected image',...
            'View wavelet decomposition' ...
            );
        for k=1:4
            pus_full(k) = uicontrol(comPusProp{:},...
                                    'Position',pos_pus_full(k,:),...
                                    'String',sprintf('%.0f',k),...
                                    'Userdata',0,...
                                    'ToolTip',deblank(tooltip(k,:)), ...
                                    'Tag',tag_pus_full(k,:)...
                                    );
        end


        txt_drag = uicontrol(comTxtProp{:},...
                             'Position',pos_tdrag,...
                             'HorizontalAlignment','left',...
                             'String',str_txt_drag...
                             );

        pus_vis = uicontrol(comPusProp{:},...
                             'Position',pos_pus_vis,...
                             'String',xlate(str_vis),...
                             'Tag',tag_pus_vis...
                             );

        pus_big  = uicontrol(comPusProp{:},...
                             'Position',pos_pus_big,...
                             'String',xlate(str_big),...
                             'Tag',tag_pus_big...
                             );

        pus_rec  = uicontrol(comPusProp{:},...
                             'Position',pos_pus_rec,...
                             'String',xlate(str_rec),...
                             'Tag',tag_pus_rec...
                             );


        % Adding colormap GUI.
        %---------------------
        utcolmap('create',win_dw2dtool, ...
                 'xloc',xlocINI,'bkcolor',Def_FraBkColor);

        %  Normalisation.
        %----------------
        Pos_Graphic_Area = wfigmngr('normalize',win_dw2dtool,Pos_Graphic_Area);

        % Callbacks update.
        %------------------
        utanapar('set_cba_num',win_dw2dtool,[m_files;pus_anal]);
        beg_cba     = ['dw2dmngr(''select'','  str_numwin ','];
        cba_pus_vis = [beg_cba , num2mstr(pus_vis) ');'];
        cba_pus_big = [beg_cba , num2mstr(pus_big) ');'];
        cba_pus_rec = [beg_cba , num2mstr(pus_rec) ');'];
        set(pus_vis,'Callback',cba_pus_vis);
        set(pus_big,'Callback',cba_pus_big);
        set(pus_rec,'Callback',cba_pus_rec);
        beg_cba = ['dw2dmngr(''fullsize'',' str_numwin ','];
        for k=1:4
            pus = pus_full(k);
            cba_pus_full = [beg_cba sprintf('%.0f',k) ');'];
            set(pus,'Callback',cba_pus_full);
        end

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_DW2D_FULLSIZE = [txt_full,pus_full(:)'];
		hdl_DW2D_SELECT = [txt_drag,pus_vis,pus_big,pus_rec];
		wfighelp('add_ContextMenu',win_dw2dtool,hdl_DW2D_FULLSIZE,'DW2D_FULLSIZE');		
		wfighelp('add_ContextMenu',win_dw2dtool,hdl_DW2D_SELECT,'DW2D_SELECT');
		%-------------------------------------

        % Memory for stored values.
        %--------------------------
        wmemtool('ini',win_dw2dtool,n_InfoInit,nb0_stored);
        wmemtool('ini',win_dw2dtool,n_param_anal,nb1_stored);
        wmemtool('ini',win_dw2dtool,n_miscella,nb3_stored);
        wmemtool('wmb',win_dw2dtool,n_param_anal,ind_act_option,option);
        wmemtool('wmb',win_dw2dtool,n_miscella,                 ...
                 ind_graph_area,Pos_Graphic_Area,ind_view_status,'none', ...
                 ind_save_status,'none',ind_sel_funct,select_funct       ...
                 );

        % Setting Colormap.
        %------------------
        cbcolmap('set',win_dw2dtool,'pal',{'pink',default_nbcolors});

        % Creating Axes: ImgIni, ImgBig, ImgVis, ImgSyn & ImgSel.
        %--------------------------------------------------------
        commonProp = {...
                      'Parent',win_dw2dtool,     ...
                      'Position',[0 0 1 1],      ...
                      'Visible','off',           ...
                      'DrawMode','Fast',         ...
                      'XTicklabelMode','manual', ...
                      'YTicklabelMode','manual', ...
                      'XTicklabel',[],           ...
                      'YTicklabel',[],           ...
                      'Box','On',                ...
                      'XGrid','off',             ...
                      'YGrid','off'              ...
                      };
        Axe_ImgIni = axes(commonProp{:},'Tag',tag_axeimgini);
        Axe_ImgVis = axes(commonProp{:},'Tag',tag_axeimgvis);
        Axe_ImgBig = axes(commonProp{:},'Tag',tag_axeimgbig);
        Axe_ImgSyn = axes(commonProp{:},'Tag',tag_axeimgsyn);
        Axe_ImgSel = axes(commonProp{:},'Tag',tag_axeimgsel);

        % Creating AxeImgDec.
        %--------------------
        locProp = {commonProp{:},'XTick',[],'YTick',[],'Tag',tag_axeimgdec}; 
        Axe_ImgDec = zeros(1,4*max_lev_anal);
        for ind=1:4*max_lev_anal
            Axe_ImgDec(ind) = axes(locProp{:});
        end
        wmemtool('wmb',win_dw2dtool,tag_axeimgdec,1,Axe_ImgDec);

        % Creating Tree axes.
        %-------------------
        axe_figutil = axes(...
                           'Parent',win_dw2dtool,    ...
                           'Position',[0 0 1 1],     ...
                           'Xlim',[0 1],'Ylim',[0 1],...
                           'DrawMode','Normal',      ...
                           'Visible','off',          ...
                           'Tag',tag_axefigutil      ...
                           );

        for k = 1:max_lev_anal+1
            line(...
                 'Parent',axe_figutil,       ...
                 'Xdata',[0 0],'Ydata',[0 0],...
                 'LineWidth',2,'Color',wtbutils('colors','linDW2D'), ...
                 'Visible','off',   ...
                 'Userdata',k,      ...
                 'Tag',tag_linetree ...
                 );
        end
        fontsize = wmachdep('fontsize','normal');
        axeXColor = get(win_dw2dtool,'DefaultAxesXColor');
        for k = 1:max_lev_anal
            text(...
                 'Parent',axe_figutil,           ...
                 'String',['L_' sprintf('%.0f',k)],...
                 'FontSize',fontsize,            ...
                 'FontWeight','bold',            ...
                 'HorizontalAlignment','left',   ...
                 'Visible','off',                ...
                 'Userdata',k,                   ...
                 'Color',axeXColor,              ...
                 'Tag',tag_txttree               ...
                 );
        end
        dw2darro('ini_arrow',win_dw2dtool);
        wboxtitl('create',axe_figutil,Axe_ImgSel,BoxTitleSel_Col,...
                          'Image Selection','off');

        % End waiting.
        %---------------
        wwaiting('off',win_dw2dtool);
		
    case 'close'
        called_win = wfindobj('figure','Userdata',varargin{1});
        delete(called_win);

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
