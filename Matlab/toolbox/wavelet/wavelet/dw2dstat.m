function out1 = dw2dstat(option,in2,in3,in4,in5,in6)
%DW2DSTAT Discrete wavelet 2-D statistics.
%   OUT1 = DW2DSTAT(OPTION,IN2,IN3,IN4,IN5,IN6)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 18-Dec-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.21 $

% Memory Blocks of stored values.
%================================
% MB1.
%-----
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

% MB2.1 & MB2.2
%--------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MB3.
%-----
n_miscella     = 'DWStat2D_Misc';
ind_curr_img   = 1;
ind_curr_color = 2;
nb3_stored     = 2;

% Tag property of objects.
%-------------------------
tag_txt_ad   = 'Appdet_Txt';
tag_pop_ad   = 'Appdet_Val';
tag_pop_dir  = 'Detdir_Val';
tag_sel_cfs  = 'Sel_Cfs';
tag_sel_rec  = 'Sel_Rec';
tag_ori_img  = 'Orig_img';
tag_syn_img  = 'Synt_img';
tag_app_img  = 'App_img';
tag_det_img  = 'Det_img';
tag_txt_bin  = 'Bins_Txt';
tag_edi_bin  = 'Bins_Data';
tag_levels   = 'Levels';
tag_ax_image = 'Ax_Image';
tag_ax_hist  = 'Ax_Hist';
tag_ax_cumhist = 'Ax_Cumhist';
tag_pus_sta  = 'Show_Stat';

if ~isequal(option,'create') , win_stats = in2; end
switch option
    case 'create'
        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,Def_EdiBkColor,Def_FraBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
                'Pop_Min_Width','X_Spacing','Y_Spacing', ...
                'Def_EdiBkColor','Def_FraBkColor' ...
                );

        % Calling figure.
        %----------------
        win_dw2dtool = in2;
        str_win_dw2dtool = sprintf('%.0f',win_dw2dtool);

        % Window initialization.
        %----------------------
        win_name = 'Wavelet 2-D  --  Statistics';
        [win_stats,pos_win,win_units,str_numwin,...
                frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
                    wfigmngr('create',win_name,'','ExtFig_HistStat',mfilename,0);
        out1 = win_stats;

        % Begin waiting.
        %---------------
        set(wfindobj('figure'),'Pointer','watch');

        % Getting variables from dw2dtool figure memory block.
        %-----------------------------------------------------
        [Img_Name,Img_Size,NB_ColorsInPal,Wav_Name,Lev_Anal] = ...
        wmemtool('rmb',win_dw2dtool,n_param_anal,...
                       ind_img_name, ...
                       ind_img_size, ...
                       ind_nbcolors, ...
                       ind_wav_name, ...
                       ind_lev_anal  ...
                       );
        [Wav_Fam,Wav_Num] = wavemngr('fam_num',Wav_Name);

        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing;  dx2 = 2*dx;
        dy = Y_Spacing;  dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);
        gra_width  = Pos_Graphic_Area(3);
        x_frame0   = pos_frame0(1);
        cmd_width  = pos_frame0(3);
        push_width = (cmd_width-4*dx)/2;
        txt_width  = Def_Btn_Width;
        pop_width  = Pop_Min_Width;
        default_bins = 50;

        % Position property of objects.
        %------------------------------
        [chk_heigth,dy_chk] = depOfMachine(Def_Btn_Height);
        xlocINI      = [x_frame0 cmd_width];
        ybottomINI   = pos_win(4)-3.5*Def_Btn_Height-dy2;

        y_low        = ybottomINI-Def_Btn_Height-10*dy;
        wx           = 7*push_width/4;
        px           = x_frame0+(cmd_width-wx)/2;
        pos_ori_img  = [px, y_low, wx, chk_heigth];
        y_low        = pos_ori_img(2)-chk_heigth-dy_chk;
        pos_syn_img = [px, y_low, wx, chk_heigth];
        y_low        = pos_syn_img(2)-chk_heigth-dy_chk;
        pos_app_img  = [px, y_low, wx, chk_heigth];
        y_low        = pos_app_img(2)-chk_heigth-dy_chk;
        pos_det_img  = [px, y_low, wx, chk_heigth];


        wx             = 3*push_width/2;
        px             = x_frame0+(cmd_width-wx)/2;
        y_low          = pos_det_img(2)-3*Def_Btn_Height/2;
        pos_txt_ad = [px, y_low+d_txt/2, wx, Def_Txt_Height];
        y_low          = y_low-Def_Btn_Height;
        pos_pop_ad = [px, y_low, wx, Def_Btn_Height];
        y_low          = y_low-3*Def_Btn_Height/2;
        pos_pop_dir = [px, y_low, wx, Def_Btn_Height];

        wx            = 5*push_width/4;
        px            = x_frame0+(cmd_width-wx)/2;
        y_low         = pos_pop_dir(2)-2*Def_Btn_Height;
        pos_sel_cfs   = [px, y_low, wx, Def_Btn_Height];
        y_low         = pos_sel_cfs(2)-3*Def_Btn_Height/2;
        pos_sel_rec   = [px, y_low, wx, Def_Btn_Height];

        px            = x_frame0+(cmd_width-3*pop_width)/2;
        y_low         = pos_sel_rec(2)-2*Def_Btn_Height;
        pos_txt_bin  = [px, y_low+d_txt/2, 2*pop_width, Def_Txt_Height];
        px            = pos_txt_bin(1)+pos_txt_bin(3)+dx;
        pos_edi_bin = [px, y_low, pop_width, Def_Btn_Height];

        px            = x_frame0+(cmd_width-3*push_width/2)/2;
        y_low         = pos_edi_bin(2)-3*Def_Btn_Height;
        pos_pus_sta = [px, y_low, 3*push_width/2, 2*Def_Btn_Height];

        % String property of objects.
        %----------------------------
        s_i = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_simg_type);
        if      s_i=='ss', str_ss = 'Synthesized image';
        elseif  s_i=='ds', str_ss = 'De_noised image';
        elseif  s_i=='cs', str_ss = 'Compressed image';
        end
        str_syn_img     = str_ss;
        str_ori_img     = 'Original image';
        str_app_img     = 'Approximation';
        str_det_img     = 'Detail';
        str_app_txt     = 'Approximation at';
        str_det_txt     = 'Detail at';
        str_pop_dir  = [ 'Horizontal' ; 'Vertical  ' ; 'Diagonal  '];
        str_sel_cfs     = 'Coefficients';
        str_sel_rec     = 'Reconstructed';
        str_txt_bin    = 'Number of bins';
        str_edi_bin   = sprintf('%.0f',default_bins);
        str_pus_sta   = 'Show statistics';
        str_pop_ad  = [];
        for i = 1:Lev_Anal
            str_pop_ad  = [str_pop_ad ; sprintf('Level %2.0f', i)];
        end

        % Command part construction of the window.
        %-----------------------------------------
        utanapar('create_copy',win_stats, ...
                 {'xloc',xlocINI,'bottom',ybottomINI},...
                 {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                 );

        commonProp = {'Parent',win_stats,'Unit',win_units};
        comRadProp = {commonProp{:},'Style','Radiobutton','Enable','off'};

        rad_ori_img = uicontrol(comRadProp{:}, ...
                         'Position',pos_ori_img,...
                         'String',str_ori_img,...
                         'Value',1,...
                         'Userdata',1,...
                         'Tag',tag_ori_img...
                         );

        rad_syn_img = uicontrol(comRadProp{:}, ...
                         'Position',pos_syn_img,...
                         'String',str_syn_img,...
                         'Tag',tag_syn_img...
                         );

        rad_app_img = uicontrol(comRadProp{:}, ...
                        'Position',pos_app_img,...
                        'String',str_app_img,...
                        'Tag',tag_app_img...
                        );

       rad_det_img = uicontrol(comRadProp{:}, ...
                        'Position',pos_det_img,...
                        'String',str_det_img,...
                        'Tag',tag_det_img...
                        );

        txt_txt_ad  = uicontrol(commonProp{:},...
                                    'Style','Text',...
                                    'Position',pos_txt_ad,...
                                    'String',str_app_txt,...
                                    'Visible','off',...
                                    'Tag',tag_txt_ad,...
                                    'Backgroundcolor',Def_FraBkColor...
                                    );
        pop_ad      = uicontrol(commonProp{:},...
                                    'Style','Popup',...
                                    'Position',pos_pop_ad,...
                                    'String',str_pop_ad,...
                                    'Visible','off',...
                                    'Userdata',1,...
                                    'Tag',tag_pop_ad...
                                    );
        pop_dir     = uicontrol(commonProp{:},...
                                    'Style','Popup',...
                                    'Position',pos_pop_dir,...
                                    'String',str_pop_dir,...
                                    'Visible','off',...
                                    'Userdata',1,...
                                    'Tag',tag_pop_dir...
                                    );
        rad_sel_cfs = uicontrol(commonProp{:},...
                                'Style','Radiobutton',...
                                'Position',pos_sel_cfs,...
                                'String',str_sel_cfs,...
                                'Visible','off',...
                                'Tag',tag_sel_cfs,...
                                'Userdata',0,...
                                'Value',0);
        rad_sel_rec = uicontrol(commonProp{:},...
                                'Style','Radiobutton',...
                                'Position',pos_sel_rec,...
                                'String',str_sel_rec,...
                                'Visible','off',...
                                'Tag',tag_sel_rec,...
                                'Userdata',1,...
                                'Value',1);
        txt_bin     = uicontrol(commonProp{:},...
                                'Style','text',...
                                'Position',pos_txt_bin,...
                                'String',str_txt_bin,...
                                'Backgroundcolor',Def_FraBkColor,...
                                'Visible','off',...
                                'Tag',tag_txt_bin...
                                );
        edi_bin   = uicontrol(commonProp{:},...
                                    'Style','Edit',...
                                    'Position',pos_edi_bin,...
                                    'String',str_edi_bin,...
                                    'Backgroundcolor',Def_EdiBkColor,...
                                    'Visible','off',...
                                    'Tag',tag_edi_bin...
                                    );
        pus_sta   = uicontrol(commonProp{:},...
                                    'Style','Pushbutton',...
                                    'Position',pos_pus_sta,...
                                    'String',xlate(str_pus_sta),...
                                    'Visible','off',...
                                    'Tag',tag_pus_sta...
                                    );

        coeff_vari_pos = 2;
        pos_txt_bin(2) = pos_det_img(2)-coeff_vari_pos*Def_Btn_Height;
        pos_edi_bin(2)= pos_txt_bin(2);
        pos_pus_sta(2)= pos_edi_bin(2)-3*Def_Btn_Height;
        set(txt_bin,'Position',pos_txt_bin,'Visible','on');
        set(edi_bin,'Position',pos_edi_bin,'Visible','on');
        set(pus_sta,'Position',pos_pus_sta,'Visible','on');

        % Frame Stats. construction.
        %---------------------------
        [infos_hdls,h_frame1] = utstats('create',win_stats,...
                                        'xloc',Pos_Graphic_Area([1,3]), ...
                                        'bottom',dy2);

        % Group handles.
        %---------------
        set1_hdls = [txt_txt_ad;pop_ad;pop_dir;rad_sel_cfs;rad_sel_rec];
        set2_hdls = [txt_bin;edi_bin;pus_sta];

        % Selected box limits.
        %---------------------
        Axe_Ref = findobj(get(win_dw2dtool,'Children'),'flat','Type','axes');
        Axe_Ref = findobj(Axe_Ref,'Tag','Axe_ImgIni');
        [xlim_selbox ylim_selbox]= mngmbtn('getbox',win_dw2dtool); 
        if ~isempty(xlim_selbox)
            xlim_selbox = [min(xlim_selbox) max(xlim_selbox)];
        else
            xlim_selbox = get(Axe_Ref,'XLim');
        end
        if ~isempty(ylim_selbox)
            ylim_selbox = [min(ylim_selbox) max(ylim_selbox)];
        else
            ylim_selbox = get(Axe_Ref,'YLim');
        end
        xlim_selbox = round(xlim_selbox);
        ylim_selbox = round(ylim_selbox);
        xlim1       = xlim_selbox(1);
        xlim2       = xlim_selbox(2);
        ylim1       = ylim_selbox(1);
        ylim2       = ylim_selbox(2);
        if xlim1<1,                xlim1 = 1;           end
        if xlim2>Img_Size(1),      xlim2 = Img_Size(1); end
        if (xlim2<1) | (xlim1>Img_Size(1)), return,     end
        if ylim1<1,                ylim1 = 1;           end
        if ylim2>Img_Size(2),      ylim2 = Img_Size(2); end
        if (ylim2<1) | (ylim1>Img_Size(2)), return,     end
        selbox = [xlim1 xlim2 ylim1 ylim2];

        % Callbacks update.
        %------------------
        str_infos_hdls  = num2mstr(infos_hdls);
        str_group_hdls  = num2mstr([set2_hdls;set1_hdls]);
        str_set2_hdls   = num2mstr(set2_hdls);
        str_rad_ori_img = num2mstr(rad_ori_img);
        str_rad_syn_img = num2mstr(rad_syn_img);
        str_rad_app_img = num2mstr(rad_app_img);
        str_rad_det_img = num2mstr(rad_det_img);
        str_pop_ad      = num2mstr(pop_ad);
        str_pop_dir     = num2mstr(pop_dir);
        str_rad_sel_rec = num2mstr(rad_sel_rec);
        str_rad_sel_cfs = num2mstr(rad_sel_cfs);
        str_edi_bin = num2mstr(edi_bin);
        str_selbox  = num2mstr(selbox);

        cba_ori_img = [mfilename '(''select'',' ...
                            str_numwin ','      ...
                            str_rad_ori_img ',' ...
                            str_infos_hdls ','  ...
                            str_group_hdls ','  ...
                            str_set2_hdls       ...
                            ');'];
        cba_syn_img = [mfilename '(''select'',' ...
                            str_numwin ','      ...
                            str_rad_syn_img ',' ...
                            str_infos_hdls ','  ...
                            str_group_hdls ','  ...
                            str_set2_hdls       ...
                            ');'];
        cba_app_img = [mfilename '(''select'',' ...
                            str_numwin ','      ...
                            str_rad_app_img ',' ...
                            str_infos_hdls ','  ...
                            str_group_hdls ','  ...
                            str_group_hdls      ...
                            ');'];
        cba_det_img = [mfilename '(''select'',' ...
                            str_numwin ','      ...
                            str_rad_det_img ',' ...
                            str_infos_hdls ','  ...
                            str_group_hdls ','  ...
                            str_group_hdls      ...
                            ');'];
        cba_pop_ad = [mfilename '(''upd'','    ...
                            str_numwin ',''lvl'',' ...
                            str_infos_hdls ',' ...
                            str_pop_ad         ...
                            ');'];
        cba_pop_dir = [mfilename '(''upd'','   ...
                            str_numwin ',''lvl'',' ...
                            str_infos_hdls ',' ...
                            str_pop_dir        ...
                            ');'];
        cba_sel_rec = [mfilename '(''upd'','   ...
                            str_numwin ',''cfs'',' ...
                            str_infos_hdls ',' ...
                            str_rad_sel_rec    ...
                            ');'];
        cba_sel_cfs = [mfilename '(''upd'','   ...
                            str_numwin ',''cfs'',' ...
                            str_infos_hdls ',' ...
                            str_rad_sel_cfs    ...
                            ');'];
        cba_edi_bin = [mfilename '(''update_bins'',' ...
                            str_numwin ','  ...
                            str_edi_bin ',' ...
                            str_infos_hdls  ...
                            ');'];
        cba_pus_sta = [mfilename '(''draw'',' ...
                            str_numwin ','    ...
                            str_win_dw2dtool ',' ...
                            str_infos_hdls ',' ...
                            str_selbox ...
                            ');'];

        set(rad_ori_img,'Callback',cba_ori_img);
        set(rad_syn_img,'Callback',cba_syn_img);
        set(rad_app_img,'Callback',cba_app_img);
        set(rad_det_img,'Callback',cba_det_img);
        set(pop_ad,'Callback',cba_pop_ad);
        set(pop_dir,'Callback',cba_pop_dir);
        set(rad_sel_rec,'Callback',cba_sel_rec);
        set(rad_sel_cfs,'Callback',cba_sel_cfs);
        set(edi_bin,'Callback',cba_edi_bin);
        set(pus_sta,'Callback',cba_pus_sta);

        % Axes construction.
        %-------------------
        xspace          = gra_width/10;
        yspace          = pos_frame0(4)/10;
        axe_height      = (pos_frame0(4)-Def_Btn_Height-h_frame1-4*dy)/2-yspace;
        axe_width       = gra_width-2*xspace;
        half_width      = axe_width/2-xspace/2;
        cx              = xspace+axe_width/2;
        cy              = h_frame1+2*dy2+axe_height+4*yspace/3+axe_height/2;
        [w_used,h_used] = wpropimg(Img_Size,axe_width,axe_height,'pixels');
        pos_ax_image    = [cx-w_used/2,cy-h_used/2,w_used,h_used];
        pos_ax_hist     = [xspace h_frame1+2*dy2+yspace/3 ...
                                 half_width axe_height];
        pos_ax_cumhist  = [2*xspace+half_width h_frame1+2*dy2+yspace/3 ...
                                 half_width axe_height];
        commonProp = {...
             'Parent',win_stats,...
             'Unit',win_units,...
             'Visible','Off',...
             'box','on',...
             'NextPlot','Replace',...
             'Drawmode','fast' ...
             };

        locProp = {commonProp{:}, ...
                     'Position',pos_ax_image,'Tag',tag_ax_image};
        axe_image = axes(locProp{:});
        locProp = {commonProp{:}, ...
                     'Position',pos_ax_hist,'Tag',tag_ax_hist};
        axe_hist  = axes(locProp{:});
        locProp = {commonProp{:}, ...
                     'Position',pos_ax_cumhist,'Tag',tag_ax_cumhist};
        axe_cumhist  = axes(locProp{:});
        drawnow

        % Displaying the window title.
        %-----------------------------
        str_nb_val   = [' (' sprintf('%.0f',Img_Size(1)) ' x ' sprintf('%.0f',Img_Size(2)) ')'];
        str_wintitle = [Img_Name,str_nb_val,' analyzed at level ',...
                        sprintf('%.0f',Lev_Anal),' with ',Wav_Name];
        str_wintitle = [str_wintitle '  --->  X = ' ,...
                        sprintf('%.0f',selbox(1)) ' : ' ...
                        sprintf('%.0f',selbox(2)) '    Y = ' ...
                        sprintf('%.0f',selbox(3)) ' : ' ...
                        sprintf('%.0f',selbox(4))];
        wfigtitl('string',win_stats,str_wintitle,'off');

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_stats);

		% Initialization with signal statistics (31/08/2000).
		%----------------------------------------------------
        dw2dstat('draw',win_stats,win_dw2dtool,infos_hdls,selbox);

		% End waiting.
        %-------------
        set(wfindobj('figure'),'Pointer','arrow');
        set([rad_ori_img rad_syn_img rad_app_img rad_det_img],'Enable','on');

    case 'select'
        %***********************************************%
        %** OPTION = 'select' - SIGNAL TYPE SELECTION **%
        %***********************************************%
        sel_rad_btn = in3;
        infos_hdls  = in4;
        group_hdls  = in5;
        curr_hdls   = in6;

        % Get Globals.
        %--------------
        Def_Btn_Height = mextglob('get','Def_Btn_Height');

        % Set to the current selection.
        %------------------------------
        rad_handles = findobj(win_stats,'Style','radiobutton');
        rad_ori_img = findobj(rad_handles,'Tag',tag_ori_img);
        rad_syn_img = findobj(rad_handles,'Tag',tag_syn_img);
        rad_app_img = findobj(rad_handles,'Tag',tag_app_img);
        rad_det_img = findobj(rad_handles,'Tag',tag_det_img);
        rad_opt     = [rad_ori_img rad_syn_img rad_app_img rad_det_img];

        old_rad = findobj(rad_opt,'Userdata',1);
        set(rad_opt,'Value',0,'Userdata',[]);
        set(sel_rad_btn,'Value',1,'Userdata',1)
        if old_rad==sel_rad_btn , return; end

        % Reset all.
        %-----------
        set(infos_hdls,'Visible','off');
        set(group_hdls,'Visible','off');
        axe_handles = findobj(get(win_stats,'Children'),'flat','Type','axes');
        axe_image   = findobj(axe_handles,'flat','Tag',tag_ax_image);
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        set(findobj([axe_image axe_hist axe_cumhist]),'visible','off');
        drawnow

        % Redraw the command part depending on the current selection.
        %------------------------------------------------------------
        pos_det_img = get(rad_det_img,'Position');
        pos_txt_bin = get(curr_hdls(1),'Position');
        pos_edi_bin = get(curr_hdls(2),'Position');
        pos_pus_sta = get(curr_hdls(3),'Position');
        coeff_vari_pos = 10;

        [nul,ypixl] = wfigutil('prop_size',win_stats,0,1);
        deltay      = Def_Btn_Height*ypixl;
        if sel_rad_btn==rad_ori_img | sel_rad_btn==rad_syn_img
            coeff_vari_pos = 2;
        end
        pos_txt_bin(2) = pos_det_img(2)-coeff_vari_pos*deltay;
        pos_edi_bin(2)= pos_txt_bin(2);
        pos_pus_sta(2)= pos_edi_bin(2)-3*deltay;
        set(curr_hdls(1),'Position',pos_txt_bin);
        set(curr_hdls(2),'Position',pos_edi_bin);
        set(curr_hdls(3),'Position',pos_pus_sta);
        set(curr_hdls,'Visible','On');
        if sel_rad_btn==rad_app_img
              set(curr_hdls(4),'String',xlate('Approximation at'))
              set(curr_hdls(6),'Visible','off')
        elseif sel_rad_btn==rad_det_img
              set(curr_hdls(4),'String',xlate('Detail at'))
              set(curr_hdls(6),'Visible','on')
        end

    case 'upd'
        %***************************************%
        %** OPTION = 'upd' - UPDATE :         **%
        %**     COEFFICIENTS TYPE SELECTION   **%
        %**     LEVEL NUMBER SELECTION        **%
        %**     LEVEL DIRECTION SELECTION     **%
        %***************************************%
        opt        = in3;
        infos_hdls = in4;

        % Set to the current selection.
        %------------------------------
        switch opt
            case 'cfs'
                sel_rad_btn = in5;
                rad_handles = findobj(win_stats,'Style','radiobutton');
                rad_sel_rec = findobj(rad_handles,'Tag',tag_sel_rec);
                rad_sel_cfs = findobj(rad_handles,'Tag',tag_sel_cfs);
                rad_opt     = [rad_sel_rec rad_sel_cfs];
                old_rad     = findobj(rad_opt,'Userdata',1);
                set(rad_opt,'Value',0,'Userdata',0);
                set(sel_rad_btn,'Value',1,'Userdata',1)
                if old_rad==sel_rad_btn , return; end

            case 'lvl'
                pop_level = in5;
                val_pop = get(pop_level,'value');
                usr_pop = get(pop_level,'userdata');
                if usr_pop==val_pop , return; end
                set(pop_level,'userdata',val_pop);

            case 'dir'
                pop_dir = in5;
                val_pop = get(pop_dir,'value');
                usr_pop = get(pop_dir,'userdata');
                if usr_pop==val_pop , return; end
                set(pop_dir,'userdata',val_pop);
        end

        % Reset all.
        %-----------
        set(infos_hdls,'Visible','off');
        axe_handles = findobj(get(win_stats,'Children'),'flat','Type','axes');
        axe_image   = findobj(axe_handles,'flat','Tag',tag_ax_image);
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        set(findobj([axe_image axe_hist axe_cumhist]),'visible','off');
        drawnow

    case 'lvl'
        %*********************************************%
        %** OPTION = 'lvl' - LEVEL NUMBER SELECTION **%
        %*********************************************%
        pop_level  = in3;
        infos_hdls = in4;

        % Set to the current selection.
        %------------------------------
        val_pop = get(pop_level,'value');
        usr_pop = get(pop_level,'userdata');
        if usr_pop==val_pop , return; end
        set(pop_level,'userdata',val_pop);

        % Reset all.
        %-----------
        set(infos_hdls,'Visible','off');
        axe_handles = findobj(get(win_stats,'Children'),'flat','Type','axes');
        axe_image   = findobj(axe_handles,'flat','Tag',tag_ax_image);
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        set(findobj([axe_image axe_hist axe_cumhist]),'visible','off');
        drawnow

    case 'draw'
        %**********************************************%
        %** OPTION = 'draw' - DRAW AXES              **%
        %**********************************************%
        win_dw2dtool = in3;
        infos_hdls   = in4;
        selbox       = in5;
	
        % Handles of tagged objects.
        %---------------------------
        children    = get(win_stats,'Children');
        uic_handles = findobj(children,'flat','type','uicontrol');
        axe_handles = findobj(children,'flat','type','axes');
        rad_handles = findobj(uic_handles,'Style','radiobutton');
        edi_handles = findobj(uic_handles,'Style','edit');
        txt_handles = findobj(uic_handles,'Style','text');
        pop_handles = findobj(uic_handles,'Style','popupmenu');
        pus_sta = findobj(uic_handles,'Style','pushbutton','Tag',tag_pus_sta);
        rad_sel_cfs = findobj(rad_handles,'Tag',tag_sel_cfs);
        rad_ori_img = findobj(rad_handles,'Tag',tag_ori_img);
        rad_syn_img = findobj(rad_handles,'Tag',tag_syn_img);
        rad_app_img = findobj(rad_handles,'Tag',tag_app_img);
        rad_det_img = findobj(rad_handles,'Tag',tag_det_img);
        edi_bin = findobj(edi_handles,'Tag',tag_edi_bin);
        pop_ad  = findobj(pop_handles,'Tag',tag_pop_ad);
        pop_dir = findobj(pop_handles,'Tag',tag_pop_dir);

        % Handles of tagged objects continuing.
        %-------------------------------------
        axe_image   = findobj(axe_handles,'flat','Tag',tag_ax_image);
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);

        % Main parameters selection before drawing.
        %------------------------------------------
        sel_cfs  = (get(rad_sel_cfs,'Value')~=0);
        orig_img = (get(rad_ori_img,'Value')~=0);
        synt_img = (get(rad_syn_img,'Value')~=0);
        app_img  = (get(rad_app_img,'Value')~=0);
        det_img  = (get(rad_det_img,'Value')~=0);

        % Check the bins number.
        %-----------------------
        default_bins = 50;
        old_params   = get(pus_sta,'Userdata');
        if ~isempty(old_params)
            default_bins = old_params(1);
        end
        nb_bins = wstr2num(get(edi_bin,'String'));
        if isempty(nb_bins) | (nb_bins<2)
            nb_bins = default_bins;   
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end
        level     = get(pop_ad,'value');
        direction = get(pop_dir,'value');

        new_params = [nb_bins sel_cfs orig_img synt_img ...
                      app_img det_img level direction   ...
                      ];

        if ~isempty(old_params) & (new_params==old_params)
            vis = get(axe_hist,'Visible');
            if vis(1:2)=='on', return, end
        end

        % Updating parameters.
        %--------------------- 
        set(pus_sta,'Userdata',new_params);

        % Show the status line.
        %----------------------
        wfigtitl('vis',win_stats,'on');

        % Cleaning the graphical part.
        %-----------------------------
        set(infos_hdls,'Visible','off');

        % Waiting message.
        %-----------------
        wwaiting('msg',win_stats,'Wait ... computing');

        % Cleaning the graphical part continuing.
        %----------------------------------------
        set(findobj([axe_image axe_hist axe_cumhist]),'visible','off');
        drawnow

        % Deseable new selection.
        %-------------------------
        pop_handles = cbanapar('no_pop',win_stats,pop_handles);
        set([rad_handles;edi_bin],'Enable','off');

        % Getting memory blocks.
        %-----------------------
        [Img_Name,NB_ColorsInPal,Wav_Name,Lev_Anal] = ...
                 wmemtool('rmb',win_dw2dtool,n_param_anal,...
                                ind_img_name, ...
                                ind_nbcolors, ...
                                ind_wav_name, ...
                                ind_lev_anal  ...
                                );

        coefs = wmemtool('rmb',win_dw2dtool,n_coefs,1);
        sizes = wmemtool('rmb',win_dw2dtool,n_sizes,1);

		% Image Coding Value.
		%-------------------
		codemat_v = wimgcode('get',win_dw2dtool);
		
        % Current image construction.
        %----------------------------
        if orig_img
            curr_img   = get(dw2drwcd('r_orig',win_dw2dtool),'Cdata');
            flg_code   = 0;
            curr_color = wtbutils('colors','sig');
            str_title  = 'Original image';

        elseif synt_img
            curr_img   = get(dw2drwcd('r_synt',win_dw2dtool),'Cdata');
            flg_code   = 0;
            curr_color = wtbutils('colors','ssig');
            s_i = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_simg_type);
            if     s_i=='ss', str_ss = 'Synthesized image';
            elseif s_i=='ds', str_ss = 'De_noised image';
            elseif s_i=='cs', str_ss = 'Compressed image';
            end
            str_title = str_ss;

        elseif app_img
            if sel_cfs
                curr_img = appcoef2(coefs,sizes,Wav_Name,level);
                flg_code = 1;
                str_title= sprintf('Coefficients of approximation at level ');
            else
                curr_img = wrcoef2('a',coefs,sizes,Wav_Name,level);
                flg_code = 0;
                str_title= sprintf('Reconstructed approximation at level ');
            end
            col_app    = wtbutils('colors','app',Lev_Anal);
            curr_color = col_app(level,:);
            str_title  = [str_title, sprintf('%.0f',level)];
        elseif det_img
            switch direction
              case 1 , dir = 'horizontal ';
              case 2 , dir = 'vertical ';
              case 3 , dir = 'diagonal ';
            end
            if sel_cfs
                curr_img = detcoef2(dir(1),coefs,sizes,level);
                flg_code = 1;
                str_title= sprintf('Coefficients of detail at level ');
            else
                curr_img = wrcoef2(dir(1),coefs,sizes,Wav_Name,level);
                flg_code = 1;
                str_title= sprintf('Reconstructed detail at level ');
            end
            col_det    = wtbutils('colors','det',Lev_Anal);
            curr_color = col_det(level,:);
            str_title  = [str_title dir,sprintf('%.0f',level)];
        end
        if sel_cfs & ~orig_img & ~synt_img
            selbox  = ceil(selbox./2^level);
        end
        if selbox(2)-selbox(1)<2 | selbox(4)-selbox(3)<2
            wwarndlg([' Not enough coefficients ' ...
                    'remaining at level ' ...
                    sprintf('%.0f',level)],...
                    'Wavelet 2-D -- Statistics','block');
            set([pop_handles;rad_handles;edi_bin],'Enable','on');
            wwaiting('off',win_stats);
            return;
        end

        % Displaying the image.
        %-----------------------
        set(win_stats,'Colormap',get(win_dw2dtool,'Colormap'));
        curr_img = curr_img(selbox(3):selbox(4),selbox(1):selbox(2));
        axes(axe_image);
        pos_ax_image    = get(axe_image,'Position');
        pos3            = pos_ax_image(3);
        pos_ax_image(3) = min((pos_ax_image(4)/(selbox(4)-selbox(3)+1))...
                        *(selbox(2)-selbox(1)+1),pos3);
        pos_ax_image(1) = pos_ax_image(1)+(pos3-pos_ax_image(3))/2;      
        set(axe_image,'Position',pos_ax_image);
        tag = get(axe_image,'Tag');
        image([selbox(1) selbox(2)],[selbox(3) selbox(4)],...
                wimgcode('cod',flg_code,curr_img,NB_ColorsInPal,codemat_v),...
                'Parent',axe_image);
        wtitle(str_title,'Parent',axe_image);

        %%% BUG enable %%%
        pause(0.1);

        set(axe_image,'Visible','on','Tag',tag);
        drawnow;

        % Check the bins number.
        %-----------------------
        nb_bins = wstr2num(get(edi_bin,'String'));
        if isempty(nb_bins) 
            nb_bins = default_bins;   
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        elseif nb_bins<2
            nb_bins = default_bins;
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end

        % Displaying histogram.
        %----------------------
        his       = wgethist(curr_img(:),nb_bins);
        [xx,imod] = max(his(2,:));
        mode_val  = (his(1,imod)+his(1,imod+1))/2;
        his(2,:)  = his(2,:)/length(curr_img(:));
        axes(axe_hist);
        wplothis(axe_hist,his,curr_color);
        wtitle('Histogram','Parent',axe_hist);

        % Displaying cumulated histogram.
        %--------------------------------
        for i=6:4:length(his(2,:));
            his(2,i)   = his(2,i)+his(2,i-4);
            his(2,i+1) = his(2,i);
        end
        axes(axe_cumhist);
        wplothis(axe_cumhist,[his(1,:);his(2,:)],curr_color);
        wtitle('Cumulative histogram','Parent',axe_cumhist);
        drawnow;

        % Displaying statistics.
        %-----------------------
        errtol    = 1.0E-12;
        mean_val  = mean(mean(curr_img));
        if abs(mean_val)<errtol , mean_val = 0; end
        max_val   = max(max(curr_img));
        if abs(max_val)<errtol , max_val = 0; end
        min_val   = min(min(curr_img));
        if abs(min_val)<errtol , min_val = 0; end
        range_val = max_val-min_val;
        if abs(range_val)<errtol , range_val = 0; end
        std_val   = std(curr_img(:));
        if abs(std_val)<errtol , std_val = 0; end
        med_val   = median(curr_img(:));
        if abs(med_val)<errtol , med_val = 0; end
        utstats('display',win_stats, ...
            [mean_val; med_val ; mode_val;  ...
             max_val ; min_val ; range_val; ...
             std_val ; median(abs(curr_img(:)-med_val)); ...
             mean(abs(curr_img(:)-mean_val))]);

        % Memory blocks update.
        %----------------------
        wmemtool('ini',win_stats,n_miscella,nb3_stored);
        wmemtool('wmb',win_stats,n_miscella,  ...
                       ind_curr_img,curr_img(:), ...
                       ind_curr_color,curr_color ...
                       );

        % End waiting.
        %-------------
        wwaiting('off',win_stats);

        % Setting infos visible.
        %-----------------------
        set(infos_hdls,'Visible','on');

        % Enable new selection.
        %----------------------
        set([pop_handles;rad_handles;edi_bin],'Enable','on');

    case 'update_bins'
        %**************************************************************%
        %** OPTION = 'update_bins' - UPDATE HISTOGRAMS WITH NEW BINS **%
        %**************************************************************%
        edi_bin    = in3;
        infos_hdls = in4;

        % Handles of tagged objects.
        %---------------------------
        children = get(win_stats,'Children');
        pus_sta  = findobj(children,'Style','pushbutton','Tag',tag_pus_sta);
        axe_handles = findobj(children,'flat','Type','axes');
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);

        % Return if no current display.
        %------------------------------
        vis = get(axe_hist,'Visible');
        if vis(1:2)=='of', return, end

        % Check the bins number.
        %-----------------------
        default_bins = 50;
        old_params   = get(pus_sta,'Userdata');
        if ~isempty(old_params)
            default_bins = old_params(1);
        end
        nb_bins = wstr2num(get(edi_bin,'String'));
        if isempty(nb_bins) | (nb_bins<2)
            nb_bins = default_bins;   
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end
        if default_bins==nb_bins , return; end

        % Waiting message.
        %-----------------
        set(infos_hdls,'Visible','off');
        wwaiting('msg',win_stats,'Wait ... computing');

        % Getting memory blocks.
        %-----------------------
        [curr_img,curr_color] = wmemtool('rmb',win_stats,n_miscella,...
                                               ind_curr_img,...
                                               ind_curr_color);
        % Updating histograms.
        %---------------------
        if ~isempty(curr_img)
            old_params(1) = nb_bins;
            set(pus_sta,'Userdata',old_params);
            his      = wgethist(curr_img,nb_bins);
            his(2,:) = his(2,:)/length(curr_img);
            axes(axe_hist);
            wplothis(axe_hist,his,curr_color);
            wtitle('Histogram','Parent',axe_hist);
            for i=6:4:length(his(2,:));
                his(2,i)   = his(2,i)+his(2,i-4);
                his(2,i+1) = his(2,i);
            end
            axes(axe_cumhist);
            wplothis(axe_cumhist,[his(1,:);his(2,:)],curr_color);
            wtitle('Cumulative histogram','Parent',axe_cumhist);
        end

        % End waiting.
        %-------------
        wwaiting('off',win_stats);
        set(infos_hdls,'Visible','on');

    case 'demo'
        %****************************************%
        %** OPTION = 'demo' -  DEMOS or TESTS  **%
        %****************************************%
        pus_sta = findobj(win_stats,'Style','pushbutton','Tag',tag_pus_sta);
        eval(get(pus_sta,'Callback'));

    case 'close'

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end

%-------------------------------------------------
function varargout = depOfMachine(varargin)

Def_Btn_Height = varargin{1};
scrSize = get(0,'ScreenSize');
if scrSize(4)<700
    chk_heigth = Def_Btn_Height;
    dy_chk     = Def_Btn_Height/2;
else
    chk_heigth = 3*Def_Btn_Height/2;
    dy_chk     = Def_Btn_Height/2;
end
varargout = {chk_heigth,dy_chk};
%-------------------------------------------------
