function varargout = dw1ddeno(option,varargin)
%DW1DDENO Wavelet 1-D de-noising.
%   VARARGOUT = DW1DDENO(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $

% Default Value(s).
%------------------
def_nbCodeOfColors = 128;

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;
ind_thr_val    = 8;
nb1_stored     = 8;

% MB2.
%-----
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;
nb2_stored    = 2;

% MB1 (local).
%-------------
n_misc_loc = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
ind_cfsMode    = 6;
ind_lin_cfs    = 7;
nbLOC_1_stored = 7;

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
        win_caller     = varargin{1};
        str_win_caller = sprintf('%.0f',win_caller);

        % Window initialization.
        %----------------------
        win_name = 'Wavelet 1-D  --  De-noising';
        [win_denoise,pos_win,win_units,str_win_denoise,...
                frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
                    wfigmngr('create',win_name,'','ExtFig_CompDeno', ...
                        strvcat(mfilename,'cond'),1,1,0);
        set(win_denoise,'userdata',win_caller);
        varargout{1} = win_denoise;
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_denoise,'Signal De-noising','DW1D_DENO_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_denoise,'De-noising Procedure','DENO_PROCEDURE');
		wfighelp('addHelpItem',win_denoise,'Available Methods','COMP_DENO_METHODS');
		wfighelp('addHelpItem',win_denoise,'Variance Adaptive Thresholding','VARTHR');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_denoise,'save');
        sav_menus(1) = uimenu(m_save,...
                                'Label','De-noised &Signal ',...
                                'Position',1,                    ...
                                'Enable','Off',                  ...
                                'Callback',                      ...
                                [mfilename '(''save_synt'','     ...
                                        str_win_denoise ');']    ...
                                );
        sav_menus(2) = uimenu(m_save,...
                               'Label','&Coefficients ',  ...
                               'Position',2,                  ...
                               'Enable','Off',                ...
                               'Callback',                    ...
                               [mfilename '(''save_cfs'','    ...
                                       str_win_denoise ');']  ...
                               );
        sav_menus(3) = uimenu(m_save,...
                                'Label','&Decomposition ', ...
                                'Position',3,                  ...
                                'Enable','Off',                ...
                                'Callback',                    ...
                                [mfilename '(''save_dec'','    ...
                                        str_win_denoise ');']  ...
                                );

        % Begin waiting.
        %---------------
        wwaiting('msg',win_denoise,'Wait ... initialization');

        % Getting variables from dw1dtool figure memory block.
        %-----------------------------------------------------
        [Sig_Name,Wav_Name,Lev_Anal,Sig_Size] = ...
                        wmemtool('rmb',win_caller,n_param_anal, ...
                                ind_sig_name,ind_wav_name,      ...
                                ind_lev_anal,ind_sig_size);
        Wav_Fam = wavemngr('fam_num',Wav_Name);
        [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs, ...
                                       ind_coefs,ind_longs);

        % Parameters initialization.
        %---------------------------
        dy = Y_Spacing;

        % Command part of the window.
        %============================
        
        % Position property of objects.
        %------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;

        % Data, Wavelet and Level parameters.
        %------------------------------------
        toolPos = utanapar('create_copy',win_denoise, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                    );

        % Threshold tool.
        %----------------
        ytopTHR = toolPos(2)-4*dy;
        utthrw1d('create',win_denoise, ...
                 'xloc',xlocINI,'top',ytopTHR,...
                 'ydir',-1, ...
                 'levmax',Lev_Anal, ...
                 'levmaxMAX',Lev_Anal, ...
                 'caller',mfilename, ...
                 'toolOPT','deno' ...
                 );

        % Adding colormap GUI.
        %---------------------
        [viewType,hdl_cfs] = dw1dvdrv('get_imgcfs',win_caller);
        if isequal(viewType,'image') & (Lev_Anal<8)
            [pop_pal_caller,mapName,nbColors] = ...
                cbcolmap('get',win_caller,'pop_pal','mapName','nbColors');
            utcolmap('create',win_denoise, ...
                     'xloc',xlocINI, ...
                     'bkcolor',Def_FraBkColor, ...
                     'briflag',0, ...
                     'enable','on');
            pop_pal_loc = cbcolmap('get',win_denoise,'pop_pal');
            set(pop_pal_loc,'Userdata',get(pop_pal_caller,'Userdata'));
            cbcolmap('set',win_denoise,'pal',{mapName,nbColors});
        end

        % General graphical parameters initialization.
        %--------------------------------------------
        bdx      = 0.08*pos_win(3);
        bdy      = 0.06*pos_win(4);
        ecy      = 0.03*pos_win(4);
        y_graph  = 2*Def_Btn_Height+dy;
        h_graph  = pos_frame0(4)-y_graph;
        w_graph  = pos_frame0(1);
        fontsize = wmachdep('fontsize','normal',9,Lev_Anal);

        % Axes construction parameters.
        %------------------------------
        w_left     = (w_graph-3*bdx)/2;
        x_left     = bdx;
        w_right    = w_left;
        x_right    = x_left+w_left+5*bdx/4;
        n_axeleft  = Lev_Anal;
        n_axeright = 3;
        ind_left   = n_axeleft;
        ind_right  = n_axeright;

        % Vertical separation.
        %---------------------
        w_fra = 0.01*pos_win(3);
        x_fra = (w_graph-w_fra)/2;
        uicontrol('Parent',win_denoise,...
                  'Style','frame',...
                  'Unit',win_units,...
                  'Position',[x_fra,y_graph,w_fra,h_graph],...
                  'Backgroundcolor',Def_FraBkColor ...
                  );

        % Building axes on the right part.
        %---------------------------------
        ecy_right = 2*ecy;
        h_right =(h_graph-2*bdy-(n_axeright-1)*ecy_right)/n_axeright;
        y_right = y_graph+bdy;
        axe_datas = zeros(1,n_axeright);
        pos_right = [x_right y_right w_right h_right];
        for k = 1:n_axeright
            axe_datas(k) = axes(...
                                'Parent',win_denoise, ...
                                'Units',win_units,     ...
                                'Position',pos_right,  ...
                                'Drawmode','fast',     ...
                                'Box','On'             ...
                                );
            pos_right(2) = pos_right(2)+pos_right(4)+ecy_right;
        end
        set(axe_datas(1),'visible','off');

        % Displaying the signal.
        %-----------------------
        sig = dw1dfile('sig',win_caller,1);
        axeAct = axe_datas(3);
        axes(axeAct)
        curr_color = wtbutils('colors','sig');
        lin_sig = line(...
                       'Xdata',1:length(sig),...
                       'Ydata',sig,...
                       'erasemode','none',...
                       'Color',curr_color,...
                       'Parent',axeAct);
        wtitle('Original signal','Parent',axeAct);
        xlim = [1         Sig_Size];
        ylim = [min(sig)  max(sig)];
        if xlim(1)==xlim(2) , xlim = xlim+0.01*[-1 1]; end
        if ylim(1)==ylim(2) , ylim = ylim+0.01*[-1 1]; end
        set(axeAct,'Xlim',xlim,'Ylim',ylim);
        utthrw1d('set',win_denoise,'handleORI',lin_sig);

        % Displaying original details coefficients.
        %------------------------------------------
        axeAct = axe_datas(2);
        [viewType,hdl_cfs] = dw1dvdrv('get_imgcfs',win_caller);
        [details,set_ylim,ymin,ymax] = dw1dfile('cfs_beg',win_caller,...
                            [1:Lev_Anal],1);
        
        if isequal(viewType,'image')
            flagType = 1;
            cfsMode  = [];
            set(win_denoise,'Colormap',get(win_caller,'Colormap'));
            [nul,i_min] = min(abs(details(:)));
            if ~isempty(hdl_cfs)
                col_cfs = flipud(get(hdl_cfs,'Cdata'));
            else
                col_cfs = wcodemat(details,def_nbCodeOfColors,'row',1);
            end
            col_min = col_cfs(i_min);
            col_cfs = flipud(col_cfs);
            axes(axeAct);
            cfs_ori = image(col_cfs,'Parent',axeAct,'Userdata',col_min);
            clear col_cfs
            levlab = int2str([Lev_Anal:-1:1]');
        else
            flagType = -1;
            axes(axeAct);
            hdl_stem = copyobj(hdl_cfs,axeAct);
            set(hdl_stem,'Visible','on');
            cfsMode = get(hdl_stem(1),'Userdata');
            levlab  = int2str([1:Lev_Anal]');
            cfs_ori = '';
        end
        set(axeAct,...
              'Userdata',cfs_ori,       ...
              'Xlim',[1 Sig_Size],      ...
              'YTicklabelMode','manual',...
              'YTick',[1:Lev_Anal],     ...
              'YTickLabel',levlab,      ...
              'Ylim',[0.5 Lev_Anal+0.5] ...
              );

        wtitle('Original coefficients','Parent',axeAct);
        wylabel('Level number','Parent',axeAct);

        xylim = get(axeAct,{'Xlim','Ylim'});        
        set(axe_datas(1),'Xlim',xylim{1},'Ylim',xylim{2});

        % Building axes on the left part.
        %--------------------------------
        ecy_left = ecy/2;
        h_left   = (h_graph-2*bdy-(n_axeleft-1)*ecy_left)/n_axeleft;
        y_left   = y_graph+0.75*bdy;

        axe_left = zeros(1,n_axeleft);
        txt_left = zeros(1,n_axeleft);
        pos_left = [x_left y_left w_left h_left];
        commonProp = {...
           'Parent',win_denoise,...
           'Units',win_units,...
           'Drawmode','fast',...
           'Box','On'...
           };
        for k = 1:n_axeleft
            if k~=1
                axe_left(k) = axes(commonProp{:}, ...
                                  'Position',pos_left,...
                                  'XTicklabelMode','manual','XTickLabel',[]);
            else
                axe_left(k) = axes(commonProp{:},'Position',pos_left);
            end
            pos_left(2) = pos_left(2)+pos_left(4)+ecy_left;

            txt_left(k) = txtinaxe('create',['d' wnsubstr(k)],...
                                    axe_left(k),'left',...
                                    'on','bold',fontsize);
        end
        utthrw1d('set',win_denoise,'axes',axe_left);

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(1,Lev_Anal);
        for k = 1:Lev_Anal , maxTHR(k) = max(abs(details(k,:))); end
        valTHR = dw1ddeno('compute_LVL_THR',win_denoise,win_caller);
        valTHR = min(valTHR,maxTHR);

        % Displaying details.
        %-------------------
        col_det = wtbutils('colors','det',Lev_Anal);
        for k = Lev_Anal:-1:1
            axeAct  = axe_left(ind_left);
            axes(axeAct);
            lin_cfs(k) = line(...
                             'Parent',axeAct,...
                             'Xdata',1:Sig_Size,...
                             'Ydata',details(k,:),...
                             'Color',col_det(k,:));
            utthrw1d('plot_dec',win_denoise,k, ...
                     {maxTHR(k),valTHR(k),1,Sig_Size,k})
            maxi = max([abs(ymax(k)),abs(ymin(k))]);
            if abs(maxi)<eps , maxi = maxi+0.01; end;
            ylim = 1.1*[-maxi maxi];
            set(axe_left(ind_left),'Xlim',xlim,'Ylim',ylim);
            ind_left = ind_left-1;
        end
        axeAct = axe_left(Lev_Anal);
        wtitle('Original details coefficients','Parent',axeAct);

        % Axes attachment.
        %-----------------
        if flagType~=-1
            axe_cmd = [axe_datas(1:3) axe_left(1:n_axeleft)];
            axe_act = [];
            axe_cfs = [axe_datas(1:2)];
        else
            axe_cmd = [axe_datas(1:3) axe_left(1:n_axeleft)];
            axe_act = [];
            axe_cfs = [axe_datas(1:2)];
        end
        dynvtool('init',win_denoise,[],axe_cmd,axe_act,[1 0], ...
                        '','','dw1dcoor',[win_caller,axe_cfs,flagType*Lev_Anal]);

%        dynvtool('init',win_denoise,[],axe_cmd,axe_act,[1 0], ...
%                        '','','dw1dcoor',[axe_cfs flagType*Lev_Anal],...
%                        'cbthrw1d',[axe_left(1:n_axeleft)]);

        % Initialization of  Denoising structure.
        %----------------------------------------
        xmin = 1; xmax = Sig_Size;
        utthrw1d('set',win_denoise,...
                       'thrstruct',{xmin,xmax,valTHR,lin_cfs},...
                       'intdepthr',[]);


        % Memory blocks update.
        %----------------------
        wmemtool('ini',win_denoise,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_denoise,n_misc_loc,    ...
                       ind_sav_menus,sav_menus,   ...
                       ind_status,0,              ...
                       ind_win_caller,win_caller, ...
                       ind_axe_datas,axe_datas,   ...
                       ind_cfsMode,cfsMode,       ...
                       ind_lin_cfs,lin_cfs        ...
                       );
        wmemtool('ini',win_denoise,n_thrDATA,nbLOC_2_stored);

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_denoise);

        % End waiting.
        %-------------
        utthrw1d('enable',win_denoise,'on',[1:Lev_Anal]);
        wwaiting('off',win_denoise);

    case 'denoise'

        % Waiting message.
        %-----------------
        wwaiting('msg',win_denoise,'Wait ... computing');

        % Clear & Get Handles.
        %----------------------
        dw1ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        axe_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_axe_datas);

        % Getting memory blocks.
        %-----------------------
        [Wav_Name,Lev_Anal,Sig_Size] = ...
                        wmemtool('rmb',win_caller,n_param_anal, ...
                                       ind_wav_name,ind_lev_anal,ind_sig_size);
        [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs, ...
                                       ind_coefs,ind_longs);


        % De-noising depending on the selected thresholding mode.
        %--------------------------------------------------------
        cxc = utthrw1d('den_M2',win_denoise,coefs,longs);
        lxc = longs;
        xc  = waverec(cxc,longs,Wav_Name);

        % Displaying denoised signal.
        %----------------------------
        lin_den = utthrw1d('get',win_denoise,'handleTHR');
        if ishandle(lin_den)
            set(lin_den,'Ydata',xc,'Visible','on');
        else
            curr_color = wtbutils('colors','ssig');
            lin_den = line(...
                           'Parent',axe_datas(3), ...
                           'Xdata',1:length(xc),  ...
                           'Ydata',xc,            ...
                           'color',curr_color     ...
                           );
            utthrw1d('set',win_denoise,'handleTHR',lin_den);
        end     
        wtitle('Original and de-noised signals','Parent',axe_datas(3));

        % Displaying thresholded details coefficients.
        %---------------------------------------------
        cfsMode = wmemtool('rmb',win_denoise,n_misc_loc,ind_cfsMode);
        if isempty(cfsMode)
            col_cfs   = wrepcoef(cxc,lxc);
            nz_cfs    = find(col_cfs~=0);
            [nbr,nbc] = size(col_cfs);
            img_cfs   = get(axe_datas(2),'Userdata');
            col_min   = get(img_cfs,'Userdata');
            cfs_ori   = flipud(get(img_cfs,'Cdata'));
            col_cfs   = col_min*ones(nbr,nbc);
            col_cfs(nz_cfs) = cfs_ori(nz_cfs);
            image(flipud(col_cfs),'Parent',axe_datas(1));
            levlab = int2str([Lev_Anal:-1:1]');
        else
            dw1dstem(axe_datas(1),cxc,lxc,'mode',cfsMode,'colors','WTBX');
            levlab = int2str([1:Lev_Anal]');
        end
        set(axe_datas(1),...
                'clipping','on',            ...
                'Xlim',get(axe_datas(2),'Xlim'),...                    
                'YTicklabelMode','manual',  ...
                'YTick',[1:Lev_Anal],       ...
                'YTickLabel',levlab,        ...
                'Ylim',[0.5 Lev_Anal+0.5]   ...
                );
        wtitle('Thresholded coefficients','Parent',axe_datas(1));
        wylabel('Level number','Parent',axe_datas(1));
        set(findobj(axe_datas(1)),'Visible','on');

        % Memory blocks update.
        %----------------------
        thrStruct = utthrw1d('get',win_denoise,'thrstruct');
        thrParams = {thrStruct(1:Lev_Anal).thrParams};
        wmemtool('wmb',win_denoise,n_thrDATA,ind_value,{xc,cxc,lxc,thrParams});
        dw1ddeno('enable_menus',win_denoise,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'compute_LVL_THR'
        win_caller = varargin{2};
        [numMeth,meth,alfa,sorh] = utthrw1d('get_LVL_par',win_denoise);
        [coefs,longs] = wmemtool('rmb',win_caller,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        varargout{1} = wthrmngr('dw1ddenoLVL',meth,coefs,longs,alfa);

    case 'update_LVL_meth'
        dw1ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        valTHR = dw1ddeno('compute_LVL_THR',win_denoise,win_caller);
        utthrw1d('update_LVL_meth',win_denoise,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_denoise,n_misc_loc,ind_status);
        if status == 0 , return; end

        % Diseable Toggle and Menus.
        %---------------------------
        dw1ddeno('enable_menus',win_denoise,'off');

        % Get Handles.
        %-------------
        axe_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_axe_datas);

        % Setting the de-noised coefs axes invisible.
        %--------------------------------------------
        lin_den = utthrw1d('get',win_denoise,'handleTHR');
        if ~isempty(lin_den)
           vis = get(lin_den,'Visible');
           if vis(1:2)=='on'
               set(findobj(axe_datas(1)),'Visible','off');
               axes(axe_datas(3));
               wtitle('Original signal','Parent',axe_datas(3));
               set(lin_den,'Visible','off');
           end
        end

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_denoise,n_misc_loc,ind_sav_menus);
        set(sav_menus,'Enable',enaVal);
        utthrw1d('enable_tog_res',win_denoise,enaVal);     
        if strncmpi(enaVal,'on',2) , status = 1; else , status = 0; end
        wmemtool('wmb',win_denoise,n_misc_loc,ind_status,status);

    case 'save_synt'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                                     '*.mat','Save De-noised Signal');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name);
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        xc = thrDATA{1};
        thrParams = thrDATA{4};

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = name;
        eval([saveStr '= xc ;']);
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr,'thrParams','wname');
        catch          
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_cfs'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                                     '*.mat','Save Coefficients (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,'Wait ... saving coefficients');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name);
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        coefs = thrDATA{2};
        longs = thrDATA{3};
        thrParams = thrDATA{4};

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','longs','thrParams','wname'};
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
                                     '*.wa1','Save Wavelet Analysis (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,'Wait ... saving decomposition');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        [wave_name,data_name] = wmemtool('rmb',win_caller,n_param_anal, ...
                                          ind_wav_name,ind_sig_name);
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        coefs = thrDATA{2};
        longs = thrDATA{3};
        thrParams = thrDATA{4};

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.wa1'; filename = [name ext];
        end
        saveStr = {'coefs','longs','thrParams','wave_name','data_name'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch          
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'close'
        [status,win_caller] = wmemtool('rmb',win_denoise,n_misc_loc, ...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans(win_denoise,...
                              'Update the synthesized signal ?',2,'cond');
        end
        switch status
          case 1
            wwaiting('msg',win_denoise,'Wait ... computing');
            thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
            valTHR  = thrDATA{4};
            lin_den = utthrw1d('get',win_denoise,'handleTHR');
            wmemtool('wmb',win_caller,n_param_anal,...
                     ind_ssig_type,'ds',ind_thr_val,valTHR);
            dw1dmngr('return_deno',win_caller,status,lin_den);
            wwaiting('off',win_denoise);

          case 0 , dw1dmngr('return_deno',win_caller,status);
        end
        varargout{1} = status;

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end


%-------------------------------------------------
function varargout = depOfMachine(varargin)

btn_height = varargin{1};
scrSize = get(0,'ScreenSize');
if scrSize(4)<600
    hvisu = btn_height;
elseif scrSize(4)<700
    hvisu = 3*btn_height/2;
else
    hvisu = 2*btn_height;
end
varargout{1} = hvisu;
%-------------------------------------------------
