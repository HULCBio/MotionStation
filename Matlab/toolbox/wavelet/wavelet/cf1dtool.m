function varargout = cf1dtool(option,varargin)
%CF1DTOOL Wavelet Coefficients Selection 1-D tool.
%   VARARGOUT = CF1DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 28-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/06/17 12:19:28 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 9;

% Stem parameters.
%-----------------
absMode = 0;
appView = 1;

% Memory Blocs of stored values.
%===============================
% MB0.
%-----
n_membloc0 = 'MB0';
ind_sig    = 1;
ind_coefs  = 2;
ind_longs  = 3;
ind_first  = 4;
ind_last   = 5;
ind_sort   = 6;
ind_By_Lev = 7;
ind_sizes  = 8;  % Dummy
nb0_stored = 8;

% MB1.
%-----
n_param_anal = 'MB1';
ind_sig_name =  1;
ind_sig_size =  2;
ind_wav_name =  3;
ind_lev_anal =  4;
nb1_stored   =  4;

% MB2.
%-----
n_InfoInit   = 'MB2';
ind_filename =  1;
ind_pathname =  2;
nb2_stored   =  2;

% MB3.
%-----
n_synt_sig = 'MB3';
ind_ssig   =  1;
nb3_stored =  1;

% MB4.
%-----
n_miscella     = 'MB4';
ind_graph_area =  1;
ind_axe_hdl    =  2;
ind_lin_hdl    =  3;
nb4_stored     =  3;

if ~isequal(option,'create') , win_tool = varargin{1}; end
switch option
  case {'create','close'} ,
  otherwise
    toolATTR = wfigmngr('getValue',win_tool,'ToolATTR');
    hdl_UIC  = toolATTR.hdl_UIC;
    hdl_MEN  = toolATTR.hdl_MEN;
    pus_ana  = hdl_UIC.pus_ana;
    chk_sho  = hdl_UIC.chk_sho;
end
switch option
  case 'create'
    % Get Globals.
    %--------------
    [Def_Btn_Height,Def_Btn_Width,Pop_Min_Width,  ...
     Def_Txt_Height,X_Spacing,Y_Spacing,Def_FraBkColor ] = ...
        mextglob('get',...
            'Def_Btn_Height','Def_Btn_Width','Pop_Min_Width',  ...
            'Def_Txt_Height','X_Spacing','Y_Spacing','Def_FraBkColor' ...
            );

    % Window initialization.
    %----------------------
    win_title = 'Wavelet Coefficients Selection 1-D';
    [win_tool,pos_win,win_units,str_numwin,...
        frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
           wfigmngr('create',win_title,winAttrb,'ExtFig_Tool_3',mfilename,1,1,0);
    if nargout> 0 , varargout{1} = win_tool; end
	
	% Add Help for Tool.
	%------------------
	wfighelp('addHelpTool',win_tool,'One-Dimensional &Selection','CF1D_GUI');
	
    % Menu construction.
    %-------------------
    m_files = wfigmngr('getmenus',win_tool,'file');	
    m_load = uimenu(m_files,...
                    'Label','&Load Signal', ...
                    'Position',1,           ...
                    'Callback',             ...
                    [mfilename '(''load'',' str_numwin ');'] ...
                    );		
    m_save = uimenu(m_files,...
                    'Label','&Save Synthesized Signal', ...
                    'Position',2,     ...
                    'Enable','Off',   ...
                    'Callback',       ...
                    [mfilename '(''save'',' str_numwin ');'] ...
                    );
    m_demo = uimenu(m_files,...
                    'Label','&Example Analysis ','Position',3);
    m_demo_1 = uimenu(m_demo,'Label','Basic Signals');
    m_demo_2 = uimenu(m_demo,'Label','Noisy Signals');
    m_demo_3 = uimenu(m_demo,'Label','Noisy Signals - Movie');
	
    % Submenu of test signals.
    %-------------------------
    names(1,:)  = 'Sum of sines               ';
    names(2,:)  = 'Frequency breakdown        ';
    names(3,:)  = 'Uniform white noise        ';
    names(4,:)  = 'AR(3) noise                ';
    names(5,:)  = 'Noisy polynomial           ';
    names(6,:)  = 'Noisy polynomial           ';
    names(7,:)  = 'Step signal                ';
    names(8,:)  = 'Two nearby discontinuities ';
    names(9,:)  = 'Two nearby discontinuities ';
    names(10,:) = 'Second derivative breakdown';
    names(11,:) = 'Second derivative breakdown';
    names(12,:) = 'Ramp + white noise         ';
    names(13,:) = 'Ramp + colored noise       ';
    names(14,:) = 'Sine + white noise         ';
    names(15,:) = 'Triangle + sine            ';
    names(16,:) = 'Triangle + sine + noise    ';
    names(17,:) = 'Electrical consumption     ';
    names(18,:) = 'Cantor curve               ';
    names(19,:) = 'Koch curve                 ';

    files = [ 'sumsin  ' ; 'freqbrk ' ; 'whitnois' ; 'warma   ' ; ...
              'noispol ' ; 'noispol ' ; 'wstep   ' ; 'nearbrk ' ; ...
              'nearbrk ' ; 'scddvbrk' ; 'scddvbrk' ; 'wnoislop' ; ...
              'cnoislop' ; 'noissin ' ; 'trsin   ' ; 'wntrsin ' ; ...
              'leleccum' ; 'wcantor ' ; 'vonkoch '                    ];

    waves = ['db3' ; 'db5' ; 'db3' ; 'db3' ; 'db2' ; 'db3' ; 'db2' ; ...
             'db2' ; 'db7' ; 'db1' ; 'db4' ; 'db3' ; 'db3' ; 'db5' ; ...
             'db5' ; 'db5' ; 'db3' ; 'db1' ; 'db1'                      ];

    levels = ['5';'5';'5';'5';'4';'4';'5';'5';'5';'2';'2';'6';'6';'5';...
                    '6';'7';'5';'5';'5'];

    beg_call_str = [mfilename '(''demo'',' str_numwin ','''];
    for i=1:size(files,1)
            libel = ['with ' waves(i,:) ' at level ' levels(i,:) ...
                            '  --->  ' names(i,:)];
            action = [beg_call_str files(i,:) ''',''' ...
                            waves(i,:) ''',' levels(i,:) ');'];
            uimenu(m_demo_1,'Label',libel,'Callback',action);
    end

    names = strvcat(...
              'Noisy blocks','Noisy bumps','Noisy heavysin',     ...
              'Noisy Doppler','Noisy quadchirp','Noisy mishmash' ...
              );
    files      = [ 'noisbloc' ; 'noisbump' ; 'heavysin' ; ...
                   'noisdopp' ; 'noischir' ; 'noismima'      ];
    waves  = ['sym8';'sym4';'sym8';'sym4';'db1 ';'db3 '];
    levels = ['5';'5';'5';'5';'5';'5'];
    beg_call_str = [mfilename '(''demo'',' str_numwin ','''];
    for i=1:size(files,1)
        libel = ['with ' waves(i,:) ' at level ' levels(i,:) ...
                        '  --->  ' names(i,:)];
        action = [beg_call_str files(i,:) ''',''' ...
                        waves(i,:) ''',' levels(i,:) ');'];
        uimenu(m_demo_2,'Label',libel,'Callback',action);
    end

    for i=1:size(files,1)
        libel = ['with ' waves(i,:) ' at level ' levels(i,:) ...
                        '  --->  ' names(i,:)];
        action = [beg_call_str files(i,:) ''',''' ...
                               waves(i,:) ''',' levels(i,:) ',' ...
                               '{''Stepwise''}' ');'];
        uimenu(m_demo_3,'Label',libel,'Callback',action);
    end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,'Wait ... initialization');

    % General parameters initialization.
    %-----------------------------------
    dx = X_Spacing;   dx2 = 2*dx;
    dy = Y_Spacing;   dy2 = 2*dy;
    d_txt = (Def_Btn_Height-Def_Txt_Height);
 
    % Command part of the window.
    %============================
    % Data, Wavelet and Level parameters.
    %------------------------------------
    xlocINI = pos_frame0([1 3]);
    ytopINI = pos_win(4)-dy;
    toolPos = utanapar('create',win_tool, ...
                  'xloc',xlocINI,'top',ytopINI,...
                  'enable','off', ...
                  'wtype','dwt'   ...
                  );
 
    w_uic   = 1.5*Def_Btn_Width;
    h_uic   = 1.5*Def_Btn_Height;
    bdx     = (pos_frame0(3)-w_uic)/2;
    x_left  = pos_frame0(1)+bdx;
    y_low   = toolPos(2)-1.5*Def_Btn_Height-2*dy;
    pos_ana = [x_left, y_low, w_uic, h_uic];

    commonProp = {...
        'Parent',win_tool, ...
        'Unit',win_units,  ...
        'Enable','off'     ...
        };

    str_ana = xlate('Analyze');
    cba_ana = [mfilename '(''anal'',' str_numwin ');'];
    pus_ana = uicontrol(commonProp{:},...
                         'Style','Pushbutton', ...
                         'Position',pos_ana,   ...
                         'String',str_ana,     ...
                         'Callback',cba_ana,   ...
                         'Interruptible','On'  ...
                         );

    % Create coefficients tool.
    %--------------------------
    ytopCFS = pos_ana(2)-4*dy;
    toolPos = utnbcfs('create',win_tool,...
                      'toolOPT','cf1d',  ...
                      'xloc',xlocINI,'top',ytopCFS);

    % Create show checkbox.
    %----------------------
    w_uic = (3*pos_frame0(3))/4;
    x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
    h_uic = Def_Btn_Height;
    y_uic = toolPos(2)-Def_Btn_Height/2-h_uic;
    pos_chk_sho = [x_uic, y_uic, w_uic, h_uic];
    str_chk_sho = 'Show Original Signal';
    chk_sho = uicontrol(commonProp{:},...
                        'Style','checkbox',     ...
                        'Visible','on',         ...
                        'Position',pos_chk_sho, ...
                        'String',str_chk_sho    ...
                        );

    %  Normalisation.
    %----------------
    Pos_Graphic_Area = wfigmngr('normalize',win_tool,Pos_Graphic_Area);
 
    % Axes contruction.
    %------------------
    ax     = zeros(4,1);
    pos_ax = zeros(4,4);
    bdx = 0.05;
     ecy_top = 0.04;
    ecy_bot = 0.04;
    ecy_mid = 0.06;
    w_ax = (Pos_Graphic_Area(3)-3*bdx)/2;
    h_ax = (Pos_Graphic_Area(4)-ecy_top-ecy_mid-ecy_bot)/3;
    x_ax = bdx;
    y_ax = Pos_Graphic_Area(2)+Pos_Graphic_Area(4)-ecy_top-h_ax;
    pos_ax(1,:) = [x_ax y_ax w_ax h_ax];
    x_ax = x_ax+w_ax+bdx;
    pos_ax(4,:) = [x_ax y_ax w_ax h_ax];
    x_ax = bdx;
    y_ax = Pos_Graphic_Area(2)+ecy_bot;
    pos_ax(2,:) = [x_ax y_ax w_ax 2*h_ax];
    x_ax = x_ax+w_ax+bdx;
    pos_ax(3,:) = [x_ax y_ax w_ax 2*h_ax];
    for k = 1:4
        ax(k) = axes(...
                     'Parent',win_tool,      ...
                     'Unit','normalized',    ...
                     'Position',pos_ax(k,:), ...
                     'Xtick',[],'Ytick',[],  ...
                     'Box','on',             ...
                     'Visible','off'         ...
                     );
    end

    % Callbacks update.
    %------------------
    hdl_den = utnbcfs('handles',win_tool);
    utanapar('set_cba_num',win_tool,[m_files;hdl_den(:)]);
    pop_lev = utanapar('handles',win_tool,'lev');
    tmp     = num2mstr([pop_lev chk_sho]);
    end_cba = [str_numwin ',' tmp ');'];
    cba_pop_lev = [mfilename '(''update_level'',' end_cba];
    cba_chk_sho = [mfilename '(''show_ori_sig'',' str_numwin ');'];
    set(pop_lev,'Callback',cba_pop_lev);
    set(chk_sho,'Callback',cba_chk_sho);

    % Memory for stored values.
    %--------------------------
    hdl_UIC  = struct('pus_ana',pus_ana,'chk_sho',chk_sho);
    hdl_MEN  = struct('m_load',m_load,'m_save',m_save,'m_demo',m_demo);
    toolATTR = struct('hdl_UIC',hdl_UIC,'hdl_MEN',hdl_MEN);
    wfigmngr('storeValue',win_tool,'ToolATTR',toolATTR);
    hdl_STEM = struct(...
                      'Hstems_O',[], ...
                      'H_vert_O',[], ...
                      'H_stem_O',[], ...
                      'H_vert_O_Copy',[], ...
                      'H_stem_O_Copy',[], ...
                      'Hstems_M',[], ...
                      'H_vert_M',[], ...
                      'H_stem_M',[], ...
                      'H_vert_M_Copy',[], ...
                      'H_stem_M_Copy',[]  ...
                      );
    wfigmngr('storeValue',win_tool,'Stems_struct',hdl_STEM);
    wmemtool('ini',win_tool,n_InfoInit,nb0_stored);
    wmemtool('ini',win_tool,n_param_anal,nb1_stored);
    wmemtool('ini',win_tool,n_membloc0,nb2_stored);
    wmemtool('ini',win_tool,n_synt_sig,nb3_stored);
    wmemtool('ini',win_tool,n_miscella,nb4_stored);
    wmemtool('wmb',win_tool,n_miscella,...
                   ind_graph_area,Pos_Graphic_Area,ind_axe_hdl,ax);

    % End waiting.
    %---------------
    wwaiting('off',win_tool);

  case 'load'
    % Loading file.
    %-------------
    if length(varargin)<2
       [sigInfos,sig_Anal,ok] = ...
            utguidiv('load_sig',win_tool,'Signal_Mask','Load Signal');
        demoFlag = 0;
    else
        sig_Name = deblank(varargin{2});
        wav_Name = deblank(varargin{3});
        lev_Anal = varargin{4};
        filename = [sig_Name '.mat'];
        pathname = utguidiv('WTB_DemoPath',filename);
        [sigInfos,sig_Anal,ok] = ...
            utguidiv('load_dem1D',win_tool,pathname,filename);
        demoFlag = 1;
    end
    if ~ok, return; end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,'Wait ... loading');

    % Get Values.
    %------------
    axe_hdl = wmemtool('rmb',win_tool,n_miscella,ind_axe_hdl);

    % Cleaning.
    %----------
    dynvtool('stop',win_tool);
    utnbcfs('clean',win_tool)
    set(hdl_MEN.m_save,'Enable','Off');
    set(axe_hdl(2:end),'Visible','Off');
    children = allchild(axe_hdl);
    delete(children{:});
    set(axe_hdl,'Xtick',[],'Ytick',[],'Box','on');

    % Setting GUI values.
    %--------------------
    sig_Name = sigInfos.name;
    sig_Size = sigInfos.size;
    sig_Size = max(sig_Size);
    levm     = wmaxlev(sig_Size,'haar');
    levmax   = min(levm,max_lev_anal);
    lev      = min(levmax,5);
    str_lev_data = int2str([1:levmax]');
    if ~demoFlag
        cbanapar('set',win_tool, ...
                 'n_s',{sig_Name,sig_Size}, ...
                 'lev',{'String',str_lev_data,'Value',lev});
    else
        cbanapar('set',win_tool, ...
                 'n_s',{sig_Name,sig_Size}, ...
                 'wav',wav_Name, ...
                 'lev',{'String',str_lev_data,'Value',lev_Anal});
        lev = lev_Anal;
    end
    set(chk_sho,'Value',0)
    cf1dtool('position',win_tool,lev,chk_sho);

    % Drawing.
    %---------
    axeAct = axe_hdl(1);
    lsig   = length(sig_Anal);
    wtitle('Original Signal','Parent',axeAct);
    col_s = wtbutils('colors','sig');
    lin_hdl(1) = line(...
      'Parent',axeAct,  ...
      'Xdata',[1:lsig], ...
      'Ydata',sig_Anal, ...
      'Color',col_s,'Visible','on'...
      );
    ymin = min(sig_Anal);
    ymax = max(sig_Anal);
    dy   = (ymax-ymin)/20;
    set(axeAct,...
        'Xlim',[1 lsig],'Ylim',[ymin-dy ymax+dy], ...
        'XtickMode','auto','YtickMode','auto','Visible','on' ...
        );
    axeAct = axe_hdl(4);
    wtitle('Synthesized Signal','Parent',axeAct);
    lin_hdl(2) = line(...
      'Parent',axeAct,  ...
      'Xdata',[1:lsig], ...
      'Ydata',sig_Anal, ...
      'Color',col_s,'Visible','off'...
      );
    col_ss = wtbutils('colors','ssig');
    lin_hdl(3) = line(...
      'Parent',axeAct,  ...
      'Xdata',[1:lsig], ...
      'Ydata',sig_Anal, ...
      'Color',col_ss,'Visible','off'...
      );
    set(axeAct,...
        'Xlim',[1 lsig],'Ylim',[ymin-dy ymax+dy], ...
        'XtickMode','auto','YtickMode','auto'     ...
        );

    % Setting Analysis parameters.
    %-----------------------------
    wmemtool('wmb',win_tool,n_membloc0,ind_sig,sig_Anal);
    wmemtool('wmb',win_tool,n_param_anal, ...
                   ind_sig_name,sigInfos.name,...
                   ind_sig_size,sigInfos.size ...
                   );
    wmemtool('wmb',win_tool,n_InfoInit, ...
                   ind_filename,sigInfos.filename, ...
                   ind_pathname,sigInfos.pathname  ...
                   );

    % Store Values.
    %--------------
    wmemtool('wmb',win_tool,n_miscella,ind_lin_hdl,lin_hdl);

    % Setting enabled values.
    %------------------------
    utnbcfs('set',win_tool,'handleORI',lin_hdl(1),'handleTHR',lin_hdl(3))
    cbanapar('enable',win_tool,'on');
    set(pus_ana,'Enable','On' );
 
    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'demo'
    cf1dtool('load',varargin{:})
    if length(varargin)>4 
        parDEMO = varargin{5};
    else
        parDEMO = {'Global'};
    end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,'Wait ... computing');

    % Computing.
    %-----------
    cf1dtool('anal',win_tool);
    pause(1)
    utnbcfs('demo',win_tool,parDEMO);

    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'save'
    % Testing file.
    %--------------
    [filename,pathname,ok] = utguidiv('test_save',win_tool, ...
                                 '*.mat','Save Synthesized Signal');
    if ~ok, return; end

    % Begin waiting.
    %--------------
    wwaiting('msg',win_tool,'Wait ... saving');

    % Getting Synthesized Signal.
    %---------------------------
    wname   = wmemtool('rmb',win_tool,n_param_anal,ind_wav_name);
    lin_hdl = wmemtool('rmb',win_tool,n_miscella,ind_lin_hdl);
    lin_hdl = lin_hdl(3);
    sig     = get(lin_hdl,'Ydata');

    % Saving file.
    %--------------
    [name,ext] = strtok(filename,'.');
    if isempty(ext) | isequal(ext,'.')
        ext = '.mat'; filename = [name ext];
    end
    eval([name ' = sig ;']);
    saveStr = {name,'wname'};
    wwaiting('off',win_tool);
    try
      save([pathname filename],saveStr{:});
    catch
      errargt(mfilename,'Save FAILED !','msg');
    end

  case 'anal'
    % Waiting message.
    %-----------------
    wwaiting('msg',win_tool,'Wait ... computing');
 
    % Reading Analysis Parameters.
    %-----------------------------
    sig_Anal = wmemtool('rmb',win_tool,n_membloc0,ind_sig);
    [wav_Name,lev_Anal] = cbanapar('get',win_tool,'wav','lev');

    % Setting Analysis parameters
    %-----------------------------
    wmemtool('wmb',win_tool,n_param_anal, ...
                   ind_wav_name,wav_Name, ...
                   ind_lev_anal,lev_Anal ...
                   );
    % Get Values.
    %------------
    [axe_hdl,lin_hdl] = wmemtool('rmb',win_tool,n_miscella,...
                                  ind_axe_hdl,ind_lin_hdl);

    % Analyzing.
    %-----------
    [coefs,longs] = wavedec(sig_Anal,lev_Anal,wav_Name);
    [tmp,idxsort] = sort(abs(coefs));
    last  = cumsum(longs(1:end-1));
    first = ones(size(last));
    first(2:end) = last(1:end-1)+1;
    len = length(last);
    idxByLev = cell(1,len);
    for k=1:len
        idxByLev{k} = find((first(k)<=idxsort) & (idxsort<=last(k)));
    end

    % Writing coefficients.
    %----------------------
    wmemtool('wmb',win_tool,n_membloc0,...
             ind_coefs,coefs,ind_longs,longs, ...
             ind_first,first,ind_last,last, ...
             ind_sort,idxsort,ind_By_Lev,idxByLev,...
             ind_sizes,[]);
 
    % Clean axes and reset dynvtool.
    %-------------------------------
    hdls_all = get(axe_hdl(2:3),'Children');
    delete(hdls_all{:});
    set(axe_hdl(2:3),'YTickLabel',[],'YTick',[]);
    dynvtool('ini_his',win_tool,'reset')

    % Plot original decomposition.
    %-----------------------------
    xlim = [1,length(sig_Anal)];
    set(axe_hdl(1:4),'Xlim',xlim);
    ax_prop = {'Xlim',xlim,'box','on','XtickMode','auto','Visible','On'};
    axeAct = axe_hdl(2);
    axes(axeAct);
    Hstems_O = dw1dstem(axeAct,coefs,longs,absMode,appView,'WTBX');
    set(axeAct,ax_prop{:});
    wtitle('Original Coefficients','Parent',axeAct);

    % Plot modified decomposition.
    %-----------------------------
    axeAct = axe_hdl(3);
    axes(axeAct);
    Hstems_M = dw1dstem(axeAct,coefs,longs,absMode,appView,'WTBX');
    set(axeAct,ax_prop{:});
    wtitle('Selected Coefficients','Parent',axeAct);

    % Plot signal and synthezised signal.
    %------------------------------------
    axeAct = axe_hdl(4);
    set(axeAct,'Visible','on');
    set(lin_hdl(3),'Ydata',sig_Anal,'Visible','on');

    % Reset tool coefficients.
    %-------------------------
    utnbcfs('update_NbCfs',win_tool,'anal');
    utnbcfs('update_methode',win_tool,'anal');
    utnbcfs('enable',win_tool,'anal');
    set(hdl_MEN.m_save,'Enable','On');

    % Construction of the invisible Stems.
    %-------------------------------------
    cf1dtool('set_Stems_HDL',win_tool,'anal',Hstems_O,Hstems_M);

    % Connect dynvtool.
    %------------------
    params = [axe_hdl(2:3)' , -lev_Anal];
    dynvtool('init',win_tool,[],axe_hdl,[],[1 0], ...
            '','','cf1dcoor',params,'cf1dselc',params);

    % End waiting.
    %-------------
    wwaiting('off',win_tool);
        
  case 'apply'
    % Waiting message.
    %-----------------
    wwaiting('msg',win_tool,'Wait ... computing');
 
    % Analysis Parameters.
    %--------------------
    [first,idxsort,idxByLev] = ...
        wmemtool('rmb',win_tool,n_membloc0,ind_first,ind_sort,ind_By_Lev);
    [nameMeth,nbkept] = utnbcfs('get',win_tool,'nameMeth','nbkept');
    len = length(idxByLev);

    switch nameMeth
      case {'Global','ByLevel'}
        ind = [];
        for k=1:len
            ind = [ind , idxByLev{k}(end-nbkept(k)+1:end)];
        end
        idx_Cfs = idxsort(ind);

        % Computing & Drawing.
        %---------------------
        Hstems_M = cf1dtool('plot_NewDec',win_tool,idx_Cfs,nameMeth);

        % Construction of the invisible Stems.
        %-------------------------------------
        cf1dtool('set_Stems_HDL',win_tool,'apply',Hstems_M);

      case {'Manual'}
        [H_stem_O,H_stem_O_Copy] = ...
            cf1dtool('get_Stems_HDL',win_tool,'Manual');
        ind = [];
        for k=1:len
            y = len+1-k;
            x_stem = get(H_stem_O(y),'Xdata');
            x_stem_Copy = get(H_stem_O_Copy(y),'Xdata');
            Idx = find(ismember(x_stem,x_stem_Copy));
            ind = [ind , Idx+first(k)-1];
        end
        idx_Cfs = ind;

        % Computing & Drawing.
        %---------------------
        cf1dtool('plot_NewDec',win_tool,idx_Cfs,nameMeth);
    end 

    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'Apply_Movie'
    movieSET = varargin{2};
    if isempty(movieSET)
        Hstems_M = cf1dtool('plot_NewDec',win_tool,[],'Stepwise');
        return
    end
    nbInSet = length(movieSET);  
    appFlag = varargin{3};
    popStop = varargin{4};

    % Waiting message.
    %-----------------
    if nbInSet>1
        txt_msg = wwaiting('msg',win_tool,'Wait ... computing');
    end

    % Get Analysis Parameters.
    %-------------------------
    [first,last,idxsort,idxByLev] = ...
        wmemtool('rmb',win_tool,n_membloc0, ...
                       ind_first,ind_last,ind_sort,ind_By_Lev);

    % Computing.
    %-----------
    len = length(last);
    nbKept = zeros(1,len+1);
    switch appFlag
      case 1
        idx_App = idxsort(idxByLev{1});
        App_Len = length(idx_App);
        idxsort(idxByLev{1}) = [];

      case 2
        idx_App = [];
        App_Len = 0;
       
      case 3
        idx_App = [];
        App_Len = 0;       
        idxsort(idxByLev{1}) = [];
    end
    for jj = 1:nbInSet
        nbcfs = movieSET(jj);
        nbcfs  = nbcfs-App_Len;
        idx_Cfs = [idx_App , idxsort(end-nbcfs+1:end)];
        if nbInSet>1 , 
            for k=1:len
              dummy  = find((first(k)<=idx_Cfs) & (idx_Cfs<=last(k)));
              nbKept(k) = length(dummy);
            end
            nbKept(end) = sum(nbKept(1:end-1));
            msg2 = [int2str(nbKept(end)) '  = [' int2str(nbKept(1:end-1)) ']'];
            msg  = strvcat(' ', sprintf('Number of kept coefficients:  %s', msg2)); 
            set(txt_msg,'String',msg);
        end

        % Computing & Drawing.
        %---------------------
        Hstems_M = cf1dtool('plot_NewDec',win_tool,idx_Cfs,'Stepwise');

        if nbInSet>1 , 
            % Test for stopping.
            %-------------------
            user = get(popStop,'Userdata');
            if isequal(user,1)
               set(popStop,'Userdata',[]);
               break
            end
            pause(0.1);
        end
    end

    % Construction of the invisible Stems.
    %-------------------------------------
    cf1dtool('set_Stems_HDL',win_tool,'apply',Hstems_M);

    % End waiting.
    %-------------
    if nbInSet>1 , wwaiting('off',win_tool); end

  case {'select','unselect'}
     OK_Select = isequal(option,'select');

     % Find Select Box.
     %-----------------
     [X,Y] = mngmbtn('getbox',win_tool);
     xmin = ceil(min(X));
     xmax = floor(max(X));
     ymin = min(Y);
     ymax = max(Y);

     % Get stored Stems.
     %------------------
     [H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy,...
      H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy] = ...
          cf1dtool('get_Stems_HDL',win_tool,'allComponents');
     nb_Stems = length(H_stem_O);

     % Find points.
     %-------------         
     nbKept = utnbcfs('get',win_tool,'nbKept');
     ylow = max(1,floor(ymin));
     ytop = min(ceil(ymax),nb_Stems);
     for y = ylow:ytop
        xy_stem      = get(H_stem_O(y),{'Xdata','Ydata'});
        xy_stem_Copy = get(H_stem_O_Copy(y),{'Xdata','Ydata'});
        Idx = find(xmin<=xy_stem{1} & xy_stem{1}<=xmax & ...
                   ymin<=xy_stem{2} & xy_stem{2}<=ymax);
        if OK_Select
            Idx = Idx(~ismember(xy_stem{1}(Idx),xy_stem_Copy{1}));
        else
            Idx = find(ismember(xy_stem_Copy{1},xy_stem{1}(Idx)));
        end
        if ~isempty(Idx)
            xy_vert_Copy = get(H_vert_O_Copy(y),{'Xdata','Ydata'});
            if OK_Select
                xy_stem_Copy{1} = [xy_stem_Copy{1} , xy_stem{1}(Idx)];
                xy_stem_Copy{2} = [xy_stem_Copy{2} , xy_stem{2}(Idx)];
                tmp = [xy_stem{1}(Idx); xy_stem{1}(Idx) ; xy_stem{1}(Idx)];
                xy_vert_Copy{1} = [xy_vert_Copy{1} , tmp(:)'];
                nbIdx = length(Idx);
                tmp = [y*ones(1,nbIdx); xy_stem{2}(Idx) ; NaN*ones(1,nbIdx)];
                xy_vert_Copy{2} = [xy_vert_Copy{2} , tmp(:)'];
            else
                xy_stem_Copy{1}(Idx) = [];
                xy_stem_Copy{2}(Idx) = [];
                Idx = 3*Idx-4;
                Idx = [Idx,Idx+1,Idx+2];
                xy_vert_Copy{1}(Idx) = [];
                xy_vert_Copy{2}(Idx) = [];
            end
            set([H_stem_O_Copy(y),H_stem_M_Copy(y)],...
                'Xdata',xy_stem_Copy{1},...
                'Ydata',xy_stem_Copy{2} ...
                );
            set([H_vert_O_Copy(y),H_vert_M_Copy(y)],...
                'Xdata',xy_vert_Copy{1},...
                'Ydata',xy_vert_Copy{2} ...
                );        
            nbInd = length(xy_stem_Copy{1})-1;
            nbKept(nb_Stems+1-y) = nbInd;
        end               
     end
     nbKept(end) = sum(nbKept(1:end-1));
     utnbcfs('set',win_tool,'nbKept',nbKept);

  case 'plot_NewDec'
    % Indices of preserved coefficients & Methode.
    %---------------------------------------------
    idx_Cfs  = varargin{2};
    nameMeth = varargin{3};
    
    % Get Handles.
    %-------------
    [axe_hdl,lin_hdl] = wmemtool('rmb',win_tool,n_miscella,...
                                  ind_axe_hdl,ind_lin_hdl);

    % Get Analysis Parameters.
    %-------------------------
    wav_Name = wmemtool('rmb',win_tool,n_param_anal,ind_wav_name);
    [coefs,longs] = wmemtool('rmb',win_tool,n_membloc0,ind_coefs,ind_longs);

    % Compute synthezized signal.
    %---------------------------
    Cnew = zeros(size(coefs));
    Cnew(idx_Cfs) = coefs(idx_Cfs);
    SS  = waverec(Cnew,longs,wav_Name);
    thr = min(abs(Cnew));

    % Plot modified decomposition.
    %-----------------------------
    xlim    = get(axe_hdl(1),'Xlim');
    ax_prop = {'Xlim',xlim,'box','on'};
    axeAct = axe_hdl(3);
    if ~isequal(nameMeth,'Manual')
        axes(axeAct);
        varargout{1} = dw1dstem(axeAct,Cnew,longs,absMode,appView,'WTBX');
        set(axeAct,ax_prop{:});
    else
        varargout{1} = [];
    end

    % Plot synthezised signal.
    %-------------------------
    axeAct = axe_hdl(4);
    axes(axeAct);
    set(lin_hdl(3),'Ydata',SS);
    ymin = min(SS);
    ymax = max(SS);
    dy   = (ymax-ymin)/20;
    cf1dtool('show_ori_sig',win_tool)
    % wtitle('Synthesized Signal','Parent',axeAct);
    set(axeAct,...
        'Xlim',xlim,  ...
        'XtickMode','auto','YtickMode','auto', ...
        'Box','on'  ...
        );
    set(hdl_MEN.m_save,'Enable','On');   

  case 'get_Stems_HDL'
    % Output parameter.
    %------------------
    mode = varargin{2};

    % Get stored Stems.
    %------------------
    hdl_STEM  = wfigmngr('getValue',win_tool,'Stems_struct');
    varargout = struct2cell(hdl_STEM);
    if isequal(mode,'All') , return; end
    
    [...
     Hstems_O,H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy, ...
     Hstems_M,H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy  ...
     ] = deal(varargout{:});
     switch mode
       case 'allComponents'
         varargout = {... 
           H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy, ...
           H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy};

       case 'Manual'
         varargout = {H_stem_O,H_stem_O_Copy};
     end

  case 'set_Stems_HDL'
    mode = varargin{2};
    axe_hdl  = wmemtool('rmb',win_tool,n_miscella,ind_axe_hdl);
    lev_Anal = wmemtool('rmb',win_tool,n_param_anal,ind_lev_anal);
    nb_STEMS = lev_Anal+1;
    hdl_STEM = wfigmngr('getValue',win_tool,'Stems_struct'); 
    switch mode
      case 'anal'
        Hstems_O = varargin{3};
        Hstems_M = varargin{4};

        % Construction of the invisible duplicated coefficients axes.
        %------------------------------------------------------------
        [H_vert_O,H_stem_O,Hstems_O] = extractSTEMS(Hstems_O);
        [H_vert_M,H_stem_M,Hstems_M] = extractSTEMS(Hstems_M);

        % Store values.
        %--------------
        hdl_STEM.Hstems_O = Hstems_O;
        hdl_STEM.H_vert_O = H_vert_O;
        hdl_STEM.H_stem_O = H_stem_O;
        hdl_STEM.Hstems_M = Hstems_M;
        hdl_STEM.H_vert_M = H_vert_M;
        hdl_STEM.H_stem_M = H_stem_M;

      case 'apply'
        Hstems_M = varargin{3};

        % Modification of Stems.
        %-----------------------
        [H_vert_M,H_stem_M,Hstems_M] = extractSTEMS(Hstems_M);
        hdl_STEM.Hstems_M = Hstems_M;
        hdl_STEM.H_vert_M = H_vert_M;
        hdl_STEM.H_stem_M = H_stem_M;

      case 'reset'
        nameMeth = varargin{3};
        hdl_DEL = [hdl_STEM.H_vert_O_Copy,hdl_STEM.H_stem_O_Copy,...
                   hdl_STEM.H_vert_M_Copy,hdl_STEM.H_stem_M_Copy];

        hdl_DEL = hdl_DEL(ishandle(hdl_DEL));
        delete(hdl_DEL)
        if ~isempty(hdl_STEM.Hstems_M)
            HDL_VIS = hdl_STEM.Hstems_M(:,[2:4]);
            HDL_VIS = HDL_VIS(ishandle(HDL_VIS(:)));
        else
            HDL_VIS = [];
        end
        switch nameMeth
          case {'Global','ByLevel','Stepwise'}
            H_vert_O_Copy = [];  H_stem_O_Copy = [];
            H_vert_M_Copy = [];  H_stem_M_Copy = [];
            if ~isequal(nameMeth,'Stepwise')
                vis_VIS = 'On';
            else
                vis_VIS = 'Off';
            end

          case {'Manual'}
            [H_vert_O_Copy,H_stem_O_Copy] = initSTEMS(axe_hdl(2),nb_STEMS);
            [H_vert_M_Copy,H_stem_M_Copy] = initSTEMS(axe_hdl(3),nb_STEMS);
            HDL_Copy = [H_vert_O_Copy(:);H_stem_O_Copy(:);...
                        H_vert_M_Copy(:);H_stem_M_Copy(:)];
            vis_VIS = 'Off';
            set(HDL_Copy,'Visible','On');
        end
        set(HDL_VIS,'Visible',vis_VIS);
        hdl_STEM.H_vert_O_Copy = H_vert_O_Copy;
        hdl_STEM.H_stem_O_Copy = H_stem_O_Copy;
        hdl_STEM.H_vert_M_Copy = H_vert_M_Copy;
        hdl_STEM.H_stem_M_Copy = H_stem_M_Copy;
    end
    wfigmngr('storeValue',win_tool,'Stems_struct',hdl_STEM);

  case 'show_ori_sig'
    lin_hdl = wmemtool('rmb',win_tool,n_miscella,ind_lin_hdl);
    vis = getonoff(get(chk_sho,'Value'));
    set(lin_hdl(2),'Visible',vis);
    strTitle = 'Synthezised Signal';
    if isequal(vis(1:2),'on')
        strTitle = [strTitle ' and Original Signal'];
    end
    wtitle(strTitle,'Parent',get(lin_hdl(2),'Parent'))

  case 'position'
    lev_view = varargin{2};
    chk_sho  = varargin{3};
    set(chk_sho,'Visible','off');
    pos_old  = utnbcfs('get',win_tool,'position');
    utnbcfs('set',win_tool,'position',{1,lev_view})
    pos_new  = utnbcfs('get',win_tool,'position');
    ytrans   = pos_new(2)-pos_old(2);
    pos_chk  = get(chk_sho,'Position');
    pos_chk(2) = pos_chk(2)+ytrans;
    set(chk_sho,'Position',pos_chk,'Visible','on');

  case 'update_level'
    pop_lev = varargin{2}(1);
    chk_sho = varargin{2}(2);
    levmax  = get(pop_lev,'value');

    % Get Values.
    %------------
    [axe_hdl,lin_hdl] = wmemtool('rmb',win_tool,n_miscella,...
                                  ind_axe_hdl,ind_lin_hdl);
    % Clean axes.
    %------------
    hdls_all = get([axe_hdl(2:3)],'Children');
    delete(hdls_all{:});
    set(axe_hdl(2:3),'Visible','Off','YTickLabel',[],'YTick',[]);

    % Hide synthezised signal.
    %-------------------------
    set(chk_sho,'Value',0);
    set(wfindobj(axe_hdl(4)),'Visible','Off');
    set(hdl_MEN.m_save,'Enable','Off');

    % Reset coefficients tool and dynvtool.
    %--------------------------------------
    utnbcfs('clean',win_tool)
    cf1dtool('position',win_tool,levmax,chk_sho);
    dynvtool('ini_his',win_tool,'reset')

  case 'handles'

  case 'close'
 
  otherwise
    errargt(mfilename,'Unknown Option','msg');
    error('*');
end


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function varargout = copyManyObj(axe,varargin)

nbin = length(varargin);
varargout = cell(1,nbin);
for k = 1:nbin , varargout{k} = copyobj(varargin{k},axe); end
%-----------------------------------------------------------------------------%
function varargout = extractSTEMS(HDL_Stems)

nbrow = 4;
nbcol = length(HDL_Stems)/nbrow;
HDL_Stems = reshape(HDL_Stems(:),nbrow,nbcol)';
H_vert = HDL_Stems(:,2);
H_stem = HDL_Stems(:,3);
varargout = {H_vert,H_stem,HDL_Stems};
%-----------------------------------------------------------------------------%
function varargout = initSTEMS(axe,nbSTEMS)

stemColor = 'y';
stemColor = wtbutils('colors','stem');
linProp   = {...
             'Visible','Off',             ...
             'Xdata',NaN,'Ydata',NaN,     ...
             'MarkerEdgeColor',stemColor, ...
             'MarkerFaceColor',stemColor  ...
             };
linPropVert = {linProp{:},'linestyle','-','Color',stemColor};
linPropStem = {linProp{:},'linestyle','none','Marker','o','MarkerSize',3};

linTmpVert = line(linPropVert{:},'Parent',axe);
linTmpStem = line(linPropStem{:},'Parent',axe);
dupli      = ones(nbSTEMS,1);
HDL_vert = copyobj(linTmpVert,axe(dupli));
HDL_stem = copyobj(linTmpStem,axe(dupli));
delete([linTmpVert,linTmpStem]);
varargout = {HDL_vert,HDL_stem};
%-----------------------------------------------------------------------------%
%=============================================================================%
