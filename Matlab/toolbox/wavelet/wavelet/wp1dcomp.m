function varargout = wp1dcomp(option,varargin)
%WP1DCOMP Wavelet packets 1-D compression.
%   VARARGOUT = WP1DCOMP(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $

% Memory Blocks of stored values.
%================================
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

% MB3.
%-----
n_structures = 'Structures';
ind_tree_st  = 1;
ind_data_st  = 2;
nb3_stored   = 2;

% MB1 (local).
%-------------
n_misc_loc = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
ind_cfsMode    = 6;
nbLOC_1_stored = 6;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

% Tag property (Main Window).
%----------------------------
tag_pop_colm = 'Txt_PopM';
tag_axe_cfs  = 'Axe_Cfs';

% Tag property.
%--------------
tag_axetxt_perf = 'Txt_Perf';

if ~isequal(option,'create') , win_compress = varargin{1}; end
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
        pop = wfindobj(win_caller,'style','popupmenu','tag',tag_pop_colm);
        cfsMode = get(pop,'Value');

        % Window initialization.
        %----------------------
        win_name = 'Wavelet Packet 1-D  --  Compression';
        [win_compress,pos_win,win_units,str_win_compress,...
                frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
                    wfigmngr('create',win_name,'','ExtFig_CompDeno', ...
                        strvcat(mfilename,'cond'),1,1,0);
        set(win_compress,'userdata',win_caller);
        if nargout>0 , varargout{1} = win_compress; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_compress,'Signal Compression','WP1D_COMP_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_compress,'Compression Procedure','COMP_PROCEDURE');
		wfighelp('addHelpItem',win_compress,'Available Methods','COMP_DENO_METHODS');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_compress,'save');
        sav_menus(1) = uimenu(m_save,...
                              'Label','Compressed &Signal ',...
                              'Position',1,                   ...
                              'Enable','Off',                 ...
                              'Callback',                     ...
                              [mfilename '(''save_synt'','    ...
                                      str_win_compress ');']  ...
                              );
        sav_menus(2) = uimenu(m_save,...
                              'Label','&Decomposition ', ...
                              'Position',2,                  ...
                              'Enable','Off',                ...
                              'Callback',                    ...
                              [mfilename '(''save_dec'','    ...
                                      str_win_compress ');'] ...
                              );

        % Begin waiting.
        %---------------
        wwaiting('msg',win_compress,'Wait ... initialization');

        % Getting variables from wp1dtool figure memory block.
        %-----------------------------------------------------
        [WP_Tree,WP_Data] = wmemtool('rmb',win_caller,n_structures,...
                                           ind_tree_st,ind_data_st);
        depth = treedpth(WP_Tree);
        [Sig_Name,Sig_Size,Wav_Name,Ent_Nam,Ent_Par] = ...
                wmemtool('rmb',win_caller,n_param_anal, ...
                               ind_sig_name,ind_sig_size,...
                               ind_wav_name,ind_ent_anal,ind_ent_par);
        Wav_Fam = wavemngr('fam_num',Wav_Name);
        isBior  = wavemngr('isbior',Wav_Fam);        

        % General graphical parameters initialization.
        %---------------------------------------------
        dy = Y_Spacing;

        % Command part of the window.
        %============================
        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create_copy',win_compress, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',depth}...
                    );
 
        % Entropy parameters.
        %--------------------
        ytopENT = toolPos(2)-dy;
        toolPos = utentpar('create_copy',win_compress, ...
                    {'xloc',xlocINI,'top',ytopENT,...
                     'ent',{Ent_Nam,Ent_Par}} ...
                    );

        % Global Compression tool.
        %-------------------------
        ytopTHR = toolPos(2)-4*dy;
        utthrgbl('create',win_compress,'toolOPT','wp1dcomp', ...
                 'xloc',xlocINI,'top',ytopTHR, ...
                 'isbior',isBior,   ...
                 'caller',mfilename ...
                 );

        % Adding colormap GUI.
        %---------------------
        pop_pal_caller = cbcolmap('get',win_caller,'pop_pal');
        prop_pal = get(pop_pal_caller,{'String','Value','Userdata'});
        utcolmap('create',win_compress, ...
                 'xloc',xlocINI, ...
                 'bkcolor',Def_FraBkColor, ...
                 'enable','on',...
                 'briFlag',0);
        pop_pal_loc = cbcolmap('get',win_compress,'pop_pal');
        set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                        'Userdata',prop_pal{3});
        set(win_compress,'Colormap',get(win_caller,'Colormap'));        

        % General graphical parameters initialization.
        %--------------------------------------------
        bdx     = 0.08*pos_win(3);
        bdy     = 0.06*pos_win(4);
        ecy     = 0.03*pos_win(4);
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph;
        w_graph = pos_frame0(1);

        % Axes construction parameters.
        %------------------------------
        w_left     = (w_graph-3*bdx)/2;
        x_left     = bdx;
        w_right    = w_left;
        x_right    = x_left+w_left+5*bdx/4;
        n_axeright = 3;
        ind_right  = n_axeright;

        % Vertical separation.
        %---------------------
        w_fra   = 0.01*pos_win(3);
        x_fra   = (w_graph-w_fra)/2;
        uicontrol('Parent',win_compress,...
                  'Style','frame',...
                  'Unit',win_units,...
                  'Position',[x_fra,y_graph,w_fra,h_graph],...
                  'Backgroundcolor',Def_FraBkColor...
                  );

        % Building axes on the right part.
        %---------------------------------
        ecy_right = 2*ecy;
        h_right   =(h_graph-2*bdy-(n_axeright-1)*ecy_right)/n_axeright;
        y_right   = y_graph+2*bdy/3;
        axe_datas = zeros(1,n_axeright);
        pos_right = [x_right y_right w_right h_right];
        for k = 1:n_axeright
            axe_datas(k) = axes('Parent',win_compress,...
                                'Units',win_units,...
                                'Position',pos_right,...
                                'Drawmode','fast',...
                                'Box','On'...
                                );
            pos_right(2) = pos_right(2)+pos_right(4)+ecy_right;
        end
        set(axe_datas(1),'visible','off');

        % Computing and drawing original signal.
        %---------------------------------------
        Signal_Anal = get(wp1ddraw('r_orig',win_caller),'Ydata');
        axeAct = axe_datas(3);
        curr_color   = wtbutils('colors','sig');
        hdl_datas    = [NaN ; NaN];
        hdl_datas(1) = line(...
                         1:length(Signal_Anal),Signal_Anal,...
                         'erasemode','none',...
                         'Color',curr_color,...
                         'Parent',axeAct);
        wtitle('Original signal','Parent',axeAct);
        xmin = 1;                       
        xmax = length(Signal_Anal);
        ylim = [min(Signal_Anal) max(Signal_Anal)];
        ymin = min(Signal_Anal);
        ymax = max(Signal_Anal);
        if abs(ylim(1)-ylim(2))<eps , ylim = ylim+0.01*[-1 1]; end
        set(axeAct,'Xlim',[xmin xmax],'Ylim',ylim);

        % Displaying original details coefficients.
        %------------------------------------------
        axe_handles = findobj(get(win_caller,'Children'),'flat','type','axes');
        WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
        xylim   = get(WP_Axe_Cfs,{'Xlim','Ylim'});
        ylim   = get(WP_Axe_Cfs,'Ylim');
        axeAct = axe_datas(2);
        commonProp = {...
            'Xlim',xylim{1},           ...
            'Ylim',xylim{2},           ...
            'YTicklabelMode','manual', ...
            'YTicklabel',[],           ...
            'YTick',[],                ...
            'Box','On'                 ...
            };
        set(axeAct,commonProp{:});
        if isa(WP_Tree,'wptree')
            wpplotcf(WP_Tree,cfsMode,axeAct);
        else
            wpplotcf(WP_Tree,WP_Data,cfsMode,axeAct);
        end
        wtitle('Original coefficients','Parent',axeAct);
        set(axe_datas(1),commonProp{:});

        % Initializing global threshold.
        %-------------------------------
        [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
            wp1dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('set',win_compress,'thrBOUNDS',[0,valTHR,maxTHR]);

        % Displaying perfos & legend.
        %----------------------------
        y_axe   = y_graph+2*bdy/3+h_right+ecy_right;
        h_axe   = 2*h_right+ecy_right;
        pos_axe_perfo = [x_left y_axe w_left h_axe];
        y_axe   = y_graph+h_right/2;
        h_axe   = h_right/2;
        pos_axe_legend = [x_left y_axe w_left h_axe];
        utthrgbl('displayPerf',win_compress, ...
                  pos_axe_perfo,pos_axe_legend,thresVALUES,n0SCR,rl2SCR,valTHR);
        [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
        utthrgbl('set',win_compress,'perfo',[perfl2,perf0]);
        drawnow

        % Memory blocks update.
        %----------------------
        utthrgbl('set',win_compress,'handleORI',hdl_datas(1));
        wmemtool('ini',win_compress,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_compress,n_misc_loc,  ...
                       ind_sav_menus,sav_menus,  ...
                       ind_status,0,             ...
                       ind_win_caller,win_caller,...
                       ind_cfsMode,cfsMode,      ...
                       ind_axe_datas,axe_datas,  ...
                       ind_hdl_datas,hdl_datas   ...
                       );
        wmemtool('ini',win_compress,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = axe_datas(3);
        axe_act = axe_datas(1:2);
        dynvtool('init',win_compress,[],axe_cmd,axe_act,[1 0]);

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_compress);

        % End waiting.
        %-------------
        wwaiting('off',win_compress);

       %%% PROVISOIRE BUG %%%%
       % refresh(win_compress)
       %%%%%%%%%%%%%%%%%%%%%%%

    case 'compress'

        % Waiting message.
        %-----------------
        wwaiting('msg',win_compress,'Wait ... computing');

        % Handles.
        %---------
        wp1dcomp('clear_GRAPHICS',win_compress);
        [axe_datas,hdl_datas] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);

        % Getting memory blocks.
        %-----------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        [WP_Tree,WP_Data] = wmemtool('rmb',win_caller,n_structures,...
                                           ind_tree_st,ind_data_st);
        depth    = treedpth(WP_Tree);
        Wav_Name = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name);
        isBior   = wavemngr('isbior',Wav_Name);

        % Compression.
        %-------------
        valTHR = utthrgbl('get',win_compress,'valthr');
        thrParams = {'h','nobest',valTHR,1};
        if isBior
            if isa(WP_Tree,'wptree')
                [C_Sig,C_Tree,perf0] = wpdencmp(WP_Tree,thrParams{:});
                C_Data = [];
            else
                [C_Sig,C_Tree,C_Data,perf0] = ...
                       wpdencmp(WP_Tree,WP_Data,thrParams{:});
            end
            lin_sig  = hdl_datas(1);
            Sig_Anal = get(lin_sig,'Ydata');
            perfl2   = 100*(norm(C_Sig)/norm(Sig_Anal))^2;
            topTitle = 'Energy ratio ';

        else
            if isa(WP_Tree,'wptree')
                [C_Sig,C_Tree] = wpdencmp(WP_Tree,thrParams{:});
                C_Data = [];
            else
                [C_Sig,C_Tree,C_Data] = wpdencmp(WP_Tree,WP_Data,thrParams{:});
            end
            [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
            topTitle = 'Retained energy ';
        end

        % Displaying compressed signal.
        %------------------------------
        axes(axe_datas(3));
        hdl_comp = hdl_datas(2);
        if ishandle(hdl_comp)
            set(hdl_comp,'Ydata',C_Sig,'Visible','on');
        else
            curr_color = wtbutils('colors','ssig');
            hdl_comp = line('Xdata',1:length(C_Sig),...
                            'Ydata',C_Sig,...
                            'color',curr_color,...
                            'Parent',axe_datas(3));
            hdl_datas(2) = hdl_comp;
            utthrgbl('set',win_compress,'handleTHR',hdl_comp);
            wmemtool('wmb',win_compress,n_misc_loc,...
                           ind_hdl_datas,hdl_datas);
        end     

        % Set a text as a super title.
        %-----------------------------
        wtitle('Original and compressed signals','Parent',axe_datas(3));
        strPerfo = [topTitle num2str(perfl2,'%5.2f') ...
                    ' % -- Zeros ' num2str(perf0,'%5.2f') ' %'];
        wtxttitl(axe_datas(3),strPerfo,tag_axetxt_perf);

        % Displaying thresholded details coefficients.
        %---------------------------------------------
        cfsMode = wmemtool('rmb',win_compress,n_misc_loc,ind_cfsMode);
        delete(findobj(axe_datas(1),'type','image'));
        if isa(C_Tree,'wptree')
            wpplotcf(C_Tree,cfsMode,axe_datas(1));
        else
            wpplotcf(C_Tree,C_Data,cfsMode,axe_datas(1));
        end
        xylim = get(axe_datas(2),{'Xlim','Ylim'});
        set(axe_datas(1),'Xlim',xylim{1},'Ylim',xylim{2});
        wtitle('Thresholded coefficients','Parent',axe_datas(1));
        set(findobj(axe_datas(1)),'Visible','on');       

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',win_compress,n_thrDATA, ...
                       ind_value,{C_Sig,C_Tree,C_Data,valTHR});
        wp1dcomp('enable_menus',win_compress,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_compress);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        [numMeth,meth,sliVal] = utthrgbl('get_GBL_par',win_compress);
        [WP_Tree,WP_Data] = wmemtool('rmb',win_caller,n_structures,...
                                           ind_tree_st,ind_data_st);
        thrFLAGS = 'wp1dcompGBL';
        switch numMeth
          case 1
            [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                wthrmngr(thrFLAGS,meth,WP_Tree,WP_Data);
            if nargout==1 , varargout = {valTHR};
            else          , varargout = {valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR};
            end

          case 2
            sig    = get(wp1ddraw('r_orig',win_caller),'Ydata');
            valTHR = wthrmngr(thrFLAGS,meth,sig);
            if isa(WP_Tree,'wptree')
                cfs = read(WP_Tree,'allcfs');
            else
                cfs = wdatamgr('rallcfs',WP_Data);
            end
            maxTHR = max(abs(cfs));
            valTHR = min(valTHR,maxTHR);
            varargout = {valTHR};
        end

    case 'update_GBL_meth'
        wp1dcomp('clear_GRAPHICS',win_compress);
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = wp1dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('update_GBL_meth',win_compress,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_compress,n_misc_loc,ind_status);
        if status==0 , return; end

        % Diseable save Menus.
        %--------------------
        wp1dcomp('enable_menus',win_compress,'off');

        % Get Handles.
        %-------------
        [axe_datas,hdl_datas] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);

        % Setting the compressed coefs axes invisible.
        %---------------------------------------------
        hdl_comp = hdl_datas(2);
        if  ishandle(hdl_comp)
            vis = get(hdl_comp,'Visible');
            if vis(1:2)=='on'
               txt_perf = findobj(axe_datas(3),'Tag',tag_axetxt_perf);
               set([findobj(axe_datas(1));hdl_comp;txt_perf],'Visible','off');
               wtitle('Original signal','Parent',axe_datas(3));
            end
        end
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_compress,n_misc_loc,ind_sav_menus);
        set(sav_menus,'Enable',enaVal);
        utthrgbl('enable_tog_res',win_compress,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else , status = 0; end
        wmemtool('wmb',win_compress,n_misc_loc,ind_status,status);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                                     '*.mat','Save Compressed Signal');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name);
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        xc = thrDATA{1};
        valTHR = thrDATA{4};

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = name;
        eval([saveStr '= xc ;']);
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr,'valTHR','wname');
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                                   '*.wp1','Save Wavelet Packet Analysis (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,'Wait ... saving decomposition');

        % Getting Analysis parameters.
        %-----------------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        data_name = wmemtool('rmb',win_caller,n_param_anal,ind_sig_name);

        % Getting Analysis values.
        %-------------------------
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        tree_struct = thrDATA{2};
        data_struct = thrDATA{3};
        valTHR = thrDATA{4};

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.wp1'; filename = [name ext];
        end
        if isa(tree_struct,'wptree')
            saveStr = {'tree_struct','data_name','valTHR'};
        else
            saveStr = {'tree_struct','data_struct','data_name','valTHR'};
        end
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'close'
        [status,win_caller] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans(win_compress,...
                              'Update the synthesized signal ?',2,'cancel');
        end
        switch status
            case 1
              wwaiting('msg',win_compress,'Wait ... computing');
              thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
              valTHR  = thrDATA{4};
              wmemtool('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
              hdl_datas = wmemtool('rmb',win_compress,n_misc_loc,ind_hdl_datas);
              hdl_comp  = hdl_datas(2);
              wp1dmngr('return_comp',win_caller,status,hdl_comp);
              wwaiting('off',win_compress);

            case 0 , wp1dmngr('return_comp',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
