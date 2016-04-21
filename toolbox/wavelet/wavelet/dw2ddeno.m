function varargout = dw2ddeno(option,varargin)
%DW2DDENO Discrete wavelet 2-D de-noising.
%   VARARGOUT = DW2DDENO(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 12-Mar-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $ $Date: 2004/03/15 22:40:19 $

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

% MB2.1 and MB2.2.
%-----------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MB1 (local).
%-------------
n_misc_loc = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
nbLOC_1_stored = 5;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

if ~isequal(option,'create') , win_denoise = varargin{1}; end                                
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Btn_Height,Y_Spacing,Def_FraBkColor] = ...
            mextglob('get','Def_Btn_Height','Y_Spacing','Def_FraBkColor');

        % Calling figure.
        %----------------
        win_caller = varargin{1};
        str_win_caller = sprintf('%.0f',win_caller);

        % Window initialization.
        %----------------------
        win_name = 'Wavelet 2-D  --  De-noising';
        [win_denoise,pos_win,win_units,str_win_denoise,...
             frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
                 wfigmngr('create',win_name,'',...
                     'ExtFig_CompDeno',strvcat(mfilename,'cond'));
        set(win_denoise,'userdata',win_caller);
        varargout{1} = win_denoise;

		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_denoise,'Image De-noising','DW2D_DENO_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_denoise,'De-noising Procedure','DENO_PROCEDURE');
		wfighelp('addHelpItem',win_denoise,'Available Methods','COMP_DENO_METHODS');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_denoise,'save');
        sav_menus(1) = uimenu(m_save,...
                                'Label','De-noised &Image ',...
                                'Position',1,                   ...
                                'Enable','Off',                 ...
                                'Callback',                     ...
                                [mfilename '(''save_synt'','    ...
                                        str_win_denoise ');']   ...
                                );
        sav_menus(2) = uimenu(m_save,...
                                'Label','&Coefficients ',   ...
                                'Position',2,                   ...
                                'Enable','Off',                 ...
                                'Callback',                     ...
                                [mfilename '(''save_cfs'','     ...
                                         str_win_denoise ');']  ...
                                );
        sav_menus(3) = uimenu(m_save,...
                                'Label','&Decomposition ',  ...
                                'Position',3,                   ...
                                'Enable','Off',                 ...
                                'Callback',                     ...
                                [mfilename '(''save_dec'','     ...
                                         str_win_denoise ');']  ...
                                );

        % Begin waiting.
        %---------------
        wwaiting('msg',win_denoise,'Wait ... initialization');

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Name,Img_Size,Wav_Name,Lev_Anal] = ...
        wmemtool('rmb',win_caller,n_param_anal, ...
                       ind_img_name, ...
                       ind_img_size, ...
                       ind_wav_name, ...
                       ind_lev_anal  ...
                       );
        [Wav_Fam,Wav_Num] = wavemngr('fam_num',Wav_Name);

        % General parameters initialization.
        %-----------------------------------
        dy = Y_Spacing;
        str_dir_det = strvcat('Horizontal','Diagonal','Vertical');

        % Command part of the window.
        %============================
        comFigProp = {'Parent',win_denoise,'Unit',win_units};

        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create_copy',win_denoise, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                    );

        % denoising tools.
        %-----------------
        ytopTHR = toolPos(2)-4*dy;
        utthrw2d('create',win_denoise, ...
                 'xloc',xlocINI,'top',ytopTHR,...
                 'ydir',-1, ...
                 'visible','on', ...
                 'enable','on', ...
                 'levmax',Lev_Anal, ...
                 'levmaxMAX',Lev_Anal, ...
                 'toolOPT','deno' ...
                 );

        % Adding colormap GUI.
        %---------------------
        briflag = (Lev_Anal<6); 
        if Lev_Anal<6
            pop_pal_caller = cbcolmap('get',win_caller,'pop_pal');
            prop_pal = get(pop_pal_caller,{'String','Value','Userdata'});
            utcolmap('create',win_denoise, ...
                     'xloc',xlocINI, ...
                     'bkcolor',Def_FraBkColor, ...
                     'briflag',briflag, ...
                     'enable','on');
            pop_pal_loc = cbcolmap('get',win_denoise,'pop_pal');
            set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                            'Userdata',prop_pal{3});
            set(win_denoise,'Colormap',get(win_caller,'Colormap'));
        end

        % Graphic part of the window.
        %============================
        % Displaying the window title.
        %-----------------------------
        strX = sprintf('%.0f',Img_Size(2));
        strY = sprintf('%.0f',Img_Size(1));
        str_nb_val   = [' (' strX ' x ' strY ')'];
        str_wintitle = [Img_Name,str_nb_val,' analyzed at level ',...
                        sprintf('%.0f',Lev_Anal),' with ',Wav_Name];
        wfigtitl('string',win_denoise,str_wintitle,'on');
        drawnow

        % Common axes properties.
        %------------------------
        comAxeProp = {...
          comFigProp{:},    ...
          'Units',win_units,...
          'Drawmode','fast',...
          'Box','On',       ...
          'Visible','on'    ...
          };

        % General graphical parameters initialization.
        %--------------------------------------------
        bdx_l   = 0.10*pos_win(3);
        bdx_r   = 0.06*pos_win(3);
        bdx     = 0.08*pos_win(3);
        ecx     = 0.04*pos_win(3);
        bdy     = 0.07*pos_win(4);
        ecy     = 0.03*pos_win(4);
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph-Def_Btn_Height;
        w_graph = pos_frame0(1);

        % Building axes for original image.
        %----------------------------------
        x_axe           = bdx;
        w_axe           = (w_graph-ecx-3*bdx/2)/2;
        h_axe           = 0.95*w_axe;
        y_axe           = y_graph+h_graph-w_axe-bdy;
        cx_ori          = x_axe+w_axe/2;
        cy_ori          = y_axe+h_axe/2;
        cx_den          = cx_ori+w_axe+ecx;
        cy_den          = cy_ori;
        [w_used,h_used] = wpropimg(Img_Size,w_axe,h_axe,'pixels');
        pos_axe         = [cx_ori-w_used/2 cy_ori-h_used/2 w_used h_used];
        axe_datas(1)    = axes(comAxeProp{:},'Position',pos_axe);
        axe_orig        = axe_datas(1);

        % Displaying original image.
        %---------------------------
        Img_Anal  = get(dw2drwcd('r_orig',win_caller),'Cdata');
        hdl_datas = [NaN;NaN];
        set(win_denoise,'Colormap',get(win_caller,'Colormap'));
        hdl_datas(1) = image([1 Img_Size(1)],[1,Img_Size(2)],Img_Anal, ...
                              'Parent',axe_orig);
        wtitle('Original image','Parent',axe_orig);

        % Building axes for denoised image.
        %----------------------------------
        pos_axe = [cx_den-w_used/2 cy_den-h_used/2 w_used h_used];
        xylim   = get(axe_orig,{'Xlim','Ylim'});
        axe_datas(2) = axes(comAxeProp{:},...
                            'Visible','off', ...
                            'Position',pos_axe,'Xlim',xylim{1},'Ylim',xylim{2});
        axe_deno = axe_datas(2);

        % Building axes for histograms.
        %------------------------------
        x_axe    = bdx;
        y_axe    = y_graph+bdy;
        h_axe    = (h_graph-w_axe-3*bdy-(Lev_Anal-1)*ecy)/Lev_Anal;
        w_axe    = (w_graph-2*ecx-3*bdx/2)/3;
        pos_axe  = [x_axe y_axe w_axe h_axe];
        axe_hist = zeros(3,Lev_Anal);
        for k = 1:Lev_Anal
            pos_axe(1) = bdx_l;
            pos_axe(2) = y_graph+bdy+(k-1)*(h_axe+ecy);
            for direct=1:3
                axe_hist(direct,k) = axes(comAxeProp{:},'Position',pos_axe);
                pos_axe(1) = pos_axe(1)+pos_axe(3)+ecx;
            end
        end
        utthrw2d('set',win_denoise,'axes',axe_hist);

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(3,Lev_Anal);
        valTHR = dw2ddeno('compute_LVL_THR',win_denoise,win_caller);
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);
        for d=1:3
            for i=Lev_Anal:-1:1
                dir = lower(str_dir_det(d,1));
                c   = detcoef2(dir,coefs,sizes,i);
                tmp = max(abs(c(:)));
                if tmp<eps , maxTHR(d,i) = 1;else , maxTHR(d,i) = 1.1*tmp; end
            end
        end
        valTHR = min(maxTHR,valTHR);

        % Displaying details coefficients histograms.
        %--------------------------------------------
        dirDef   = 1;
        fontsize = wmachdep('fontsize','normal');
        col_det  = wtbutils('colors','det',Lev_Anal);
        nb_bins  = 50;
        axeXColor = get(win_denoise,'DefaultAxesXColor');        
        for level = 1:Lev_Anal
            for direct=1:3
                axeAct  = axe_hist(direct,level);
                axes(axeAct);
                dir        = lower(str_dir_det(direct,1));
                curr_img   = detcoef2(dir,coefs,sizes,level);
                curr_color = col_det(level,:);
                his        = wgethist(curr_img(:),nb_bins);
                his(2,:)   = his(2,:)/length(curr_img(:));
                hdl_hist   = wplothis(axeAct,his,curr_color);
                if direct==dirDef
                    txt_hist(direct) = ...
                    txtinaxe('create',['L_' sprintf('%.0f',level)],...
                             axeAct,'left','on',...
                             'bold',fontsize);
                    set(txt_hist(direct),'color',axeXColor);
                end
                if level==1
                    wxlabel([deblank(str_dir_det(direct,:)) ' Details'],...
                            'color',axeXColor,...
                            'Parent',axeAct);
                end
                thr_val = valTHR(direct,level);
                thr_max = maxTHR(direct,level);
                ylim    = get(axeAct,'Ylim');
                utthrw2d('plot_dec',win_denoise,dirDef, ...
                          {thr_max,thr_val,ylim,direct,level,axeAct})
                xmax = 1.1*max([thr_max, max(abs(his(1,:)))]);
                set(axeAct,'Xlim',[-xmax xmax]);
                set(findall(axeAct),'Visible','on');
            end
        end
        drawnow

        % Initialization of denoising structure.
        %----------------------------------------
        utthrw2d('set',win_denoise,'valthr',valTHR,'maxthr',maxTHR);

        % Memory blocks update.
        %----------------------
        utthrw2d('set',win_denoise,'handleORI',hdl_datas(1));
        wmemtool('ini',win_denoise,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_denoise,n_misc_loc,   ...
                       ind_sav_menus,sav_menus,  ...
                       ind_status,0,             ...
                       ind_win_caller,win_caller,...
                       ind_axe_datas,axe_datas,  ...
                       ind_hdl_datas,hdl_datas   ...
                       );
        wmemtool('ini',win_denoise,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = [axe_orig axe_deno];
        axe_act = [];
        dynvtool('init',win_denoise,[],axe_cmd,axe_act,[1 1],'','','','int');

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_denoise);

        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'denoise'

        % Waiting message.
        %-----------------
        wwaiting('msg',win_denoise,'Wait ... computing');

        % Clear & Get Handles.
        %----------------------
        dw2ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        [axe_datas,hdl_datas] = wmemtool('rmb',win_denoise,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        axe_orig = axe_datas(1);
        axe_deno = axe_datas(2);

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Size,Wav_Name,Lev_Anal] = ...
                wmemtool('rmb',win_caller,n_param_anal,...
                               ind_img_size, ...
                               ind_wav_name, ...
                               ind_lev_anal  ...
                               );

        % Getting Analysis values.
        %-------------------------
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);

        % De-noising.
        %------------
        valTHR = utthrw2d('get',win_denoise,'valthr');
        [numMeth,meth,scal,sorh] = utthrw2d('get_LVL_par',win_denoise);
        [xc,cxc,lxc,perf0] = wdencmp('lvd',coefs,sizes,...
                                      Wav_Name,Lev_Anal,valTHR,sorh);

        % Displaying compressed image.
        %------------------------------
        hdl_deno = hdl_datas(2);
        if ishandle(hdl_deno)
            set(hdl_deno,'Cdata',xc,'Visible','on');
        else
            hdl_deno = image([1 Img_Size(1)],[1,Img_Size(2)],xc,...
                              'Parent',axe_deno);
            hdl_datas(2) = hdl_deno;
            utthrw2d('set',win_denoise,'handleTHR',hdl_deno);
            wmemtool('wmb',win_denoise,n_misc_loc,ind_hdl_datas,hdl_datas);
        end
        xylim =  get(axe_orig,{'Xlim','Ylim'});
        set(axe_deno,'Xlim',xylim{1},'Ylim',xylim{2},'Visible','on');
        wtitle('De-noised image','Parent',axe_deno);

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',win_denoise,n_thrDATA,ind_value,{xc,cxc,lxc,valTHR});
        dw2ddeno('enable_menus',win_denoise,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'compute_LVL_THR'
        win_caller = varargin{2};
        [numMeth,meth,alfa,sorh] = utthrw2d('get_LVL_par',win_denoise);
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);
        varargout{1} = wthrmngr('dw2ddenoLVL',meth,coefs,sizes,alfa);
 
    case 'update_LVL_meth'
        dw2ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        valTHR = dw2ddeno('compute_LVL_THR',win_denoise,win_caller);
        utthrw2d('update_LVL_meth',win_denoise,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_denoise,n_misc_loc,ind_status);
        if isempty(status) | isequal(status,0), return; end;
 
        % Disable Toggles and Menus.
        %----------------------------
        dw2ddeno('enable_menus',win_denoise,'off');

        % Get Handles.
        %-------------
        axe_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_axe_datas);
        axe_deno = axe_datas(2);

        % Setting compressed axes invisible.
        %-----------------------------------
        set(findobj(axe_deno),'visible','off');
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_denoise,n_misc_loc,ind_sav_menus);
        set(sav_menus,'Enable',enaVal);
        utthrw2d('enable_tog_res',win_denoise,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else , status = 0; end
        wmemtool('wmb',win_denoise,n_misc_loc,ind_status,status);

    case 'save_synt'
 
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                                     '*.mat','Save De-noised Image');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name);
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_caller,n_param_anal,ind_nbcolors);
            map = pink(nb_colors);
        end
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        X = round(thrDATA{1});
        valTHR = thrDATA{4};

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'X','map','valTHR','wname'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_cfs'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                                     '*.mat','Save Coefficients (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,'Wait ... saving coefficients');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name);
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_caller,n_param_anal,ind_nbcolors);
            map = pink(nb_colors);
        end
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        coefs  = thrDATA{2};
        sizes  = thrDATA{3};
        valTHR = thrDATA{4};

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','map','valTHR','wname'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                                     '*.wa2','Save Wavelet Analysis (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,'Wait ... saving decomposition');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        [wave_name,data_name,nb_colors] =    ...
                wmemtool('rmb',win_caller,n_param_anal, ...
                               ind_wav_name, ...
                               ind_img_name, ...
                               ind_nbcolors  ...
                               );
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map) , map = pink(nb_colors); end
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        coefs  = thrDATA{2};
        sizes  = thrDATA{3};
        valTHR = thrDATA{4};

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.wa2'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','wave_name','map','valTHR','data_name'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'close'

        % Returning or not the denoised image in the 2D current analysis.
        %----------------------------------------------------------------
        [status,win_caller] = wmemtool('rmb',win_denoise,n_misc_loc,...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans(win_denoise,...
                              'Update the synthesized image ?',2,'cancel');
        end
        switch status
            case 1
                wwaiting('msg',win_denoise,'Wait ... computing');
                thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
                valTHR  = thrDATA{4};
                wmemtool('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
                hdl_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_hdl_datas);
                img = hdl_datas(2);
                dw2dmngr('return_deno',win_caller,status,img);
                wwaiting('off',win_denoise);

            case 0
                dw2dmngr('return_deno',win_caller,status);
        end
        varargout{1} = status;

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
