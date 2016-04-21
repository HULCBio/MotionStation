% function simgui(toolhan,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,...
%                 in11,in12,in13,in14,in15)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.15.2.3 $

function simgui(toolhan,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,...
                in11,in12,in13,in14,in15)

 mlvers = version;
 if str2double(mlvers(1)) < 4
    error('Need Matlab Version 4 or better to run this - See manual and use dkit.m');
    return
 end


 %  h2v pointers
    gonumcol = 4;
    numlinks = 3;


 if nargin == 0
   toolhan = 0; % dummy, not used
   in1 = 'create';
   in2 = '';
   thstr = [];
 elseif isempty(toolhan)
    if ~isempty(get(0,'children'))
            toolhan = gcf;
    end
 %   nin = nargin;
    thstr = int2str(toolhan);
 else
 %   nin = nargin;
    thstr = int2str(toolhan);
 end

 if strcmp(in1,'create')
    if nargin == 1
        in2 = '';
    end
    wsuff = in2;
    TOOLTYPE = 'linsim';
    UDNAME = wsuff;
    if ~isempty(wsuff)
        wsuff = [' - ' wsuff];
    end

    FIGMAX = 6;
    DF_FONT = [10 10 10 10];
    PLTMENU = zeros(FIGMAX+2,1);

    mudeclar;
    mudeclar('YOLN');
    mudeclar('YOLP');
    mudeclar('YCLN');
    mudeclar('YCLP');
    mudeclar('SOLIC');
    mudeclar('PERTURBATION');
    mudeclar('INPUTSIG');
    mudeclar('CONTROLLER');
    mudeclar('TFIN', 'INTSS', 'SAMPT', 'XINITP', 'XINITK', 'XINITD', 'TRSP_IDHANS', ...
        'TOOLTYPE', 'MAINWINDOW', 'MFILENAME', 'UDNAME', 'STOPFLAG');
    mudeclar('EDITHANDLES', 'EDITRESULTS', 'RESTOOLHAN', 'ERRORCB', 'SUCCESSCB', 'MINFOTAB');
    mudeclar('SUFFIXNAME', 'EXPHAN', 'EXPORTVAR', 'TLINKNAMES', 'ULINKNAMES', 'BINLOC');
    mudeclar('LOADSTAT', 'COMPUTEHAN', 'REFRESHHAN', 'DONEEDITHAN', 'EDITING',...
         'DIMREADY', 'GGWIN', 'SIMTYPE', 'STOPHAN');
    mudeclar('SOL_K_PER_IN', 'TEMP', ...
            'DATAHANDLES', 'DATACB');
    mudeclar('SIMWIN', 'PARMWIN', 'PRINTWIN', 'MESSAGE', 'COLORMENU', 'PRINTNFIG',...
            'TABLELOC', 'APPLYBUT','PLTMENU');
    mudeclar('NAMESCOMP', 'NAMESNOTCOMP', 'WHICHDATA', 'TYPEDATA', 'SELECTHAN', 'ALLTABHAN');
    mudeclar('FRESH','PRCHAN', 'DIMKNOWN', 'LASTCOORD', 'CURCOORD', 'ALLFIGS', 'ORIGWINPOS');
    mudeclar('OLN', 'CLN', 'OLP', 'CLP', 'YHANOLN', 'YHANOLP', 'YHANCLN', 'YHANCLP');
%
    mudeclar('SAVESET','MESS_PARM');
    mudeclar('MASKPIM');
    mudeclar('MATDATAPIM');
    mudeclar('MATRVPIM');
    mudeclar('VISROWPIM');
    mudeclar('TITLEPIM', 'XLPIM', 'YLPIM', 'AXESPIM', 'GRIDPIM');
    mudeclar('GROUPFFPIM', 'CNTPIM', 'TFONTPIM', 'XFONTPIM', 'YFONTPIM', 'DF_FONT', 'AFONTPIM');
    mudeclar('PLOTHANDLES', 'PLOTFIGHAND',  'COMPSTAT', ...
            'PLTAXES', 'PLTWIN', 'VISIBLE_MAT', 'FIGMAT', 'OLDFIGMAT' , 'FIGMAX');
    mudeclar('DF_GROUPFF', 'DF_CNT', 'DF_MASK', 'DF_MATDATA', 'DF_MATRV', 'DF_VISROW', 'DF_GRID');

%   VISIBLE_MAT is ONLY used to turn off the Plot Axes when no plots are showing, purely cosmentc

    [VN,PIM] = mudeclar('mkvar');

    ss = get(0,'Screensize');

    vechandles = zeros(100,1);
    handlecnt = 1;

    hardware = computer;
    if strcmp(hardware,'PCWIN')
        ET_BGC = [1 1 1];
        lvfs = 8;
		link_font = 8;
    elseif strcmp(hardware,'MAC2')
        ET_BGC = [1 1 1];
        lvfs = 10;
		link_font = 10;
    else
        ET_BGC = [1 1 1];
        lvfs = 9;
		link_font = 10;
    end

%   DIMENSIONS
    SIMWIN = 1; % DUMMY figure
    ybotbo = 3;
    ytopbo = 6;
    xlbo = 3;
    xrbo = 3;
    llx = 0;
    lly = 0;

%   COMPUTE/REFRESH BUTTONS
    comp_bw = xlbo + 100 + xrbo;
    comp_bh = 40;
    bbgap = 3;
    comp_xywh = [llx lly comp_bw comp_bh];

%   PLOTTING SELECTION SIZES
    bw = 60; th = 20; bth = -14; tth = 20; nw = 200; bbw = 30;
    xbo = 4; numcols = 4; sgap = 3; tgap = 3; bgap = 3;
    dgap = 3; hgap = 3; ytopbo = 5; ybotbo = 5; scroll_lim = 1;
    dimvec_plt = [bw;th;bth;tth;nw;bbw;xbo;numcols;...
        sgap;tgap;bgap;dgap;hgap;ytopbo;ybotbo;scroll_lim];

    NAMESCOMP = str2mat('Output Channels','Open-Loop Nominal',...
        'Open-Loop Perturbed','Closed-Loop Nominal','Closed-Loop Perturbed  ');
    NAMESNOTCOMP = str2mat('Output Channels','(Open-Loop Nominal)',...
    '(Open-Loop Perturbed)','(Closed-Loop Nominal)','(Closed-Loop Perturbed)');
    cb1 = ['simgui(' thstr ',''pb'','];
    cb2 = ['simgui(' thstr ',''rvname'','];
    pos_plt = scrolltb('dimquery','Plots and LineTypes',NAMESNOTCOMP,...
        str2mat('text','text','text','text','text'),...
        str2mat('rand(',cb1,cb1,cb1,cb1),...
        str2mat('rand(',cb1,cb1,cb1,cb1),...
        str2mat('text','text','text','text','text'),...
        str2mat('rand(',cb2,cb2,cb2,cb2),...
        0,0,SIMWIN,dimvec_plt);
    YHBGAP = pos_plt(4) - 2*comp_bh - bbgap;

    XLBO = 6;
    XRBO = 6;
    XMIDBO = 15;
    YBOTBO = 2;
    YTOPBO = 4;
    VGAP = 4;
    vtab_gap = 2;

    mainwin_w = XLBO + comp_xywh(3) + XMIDBO + pos_plt(3) + XRBO;

%  Drop boxes and name data
    lx = 0;
    ly = 0;
    ytopbo = 2;
    ybotbo = 2;
    binlbo = 0;
    binrbo = 8;
    binw   = 40;
    xrbo   = 2;
    xlbo   = 2;
    nw = 110;
    dw = 0;
    mw = 130;
    th = 20; % entry 7
    vgap = 3;
    hgap = 5;

    systemdv = [lx;ly;ytopbo;ybotbo;binlbo;binrbo;binw;xlbo;xrbo; ...
                 nw;dw;mw;th;vgap;hgap];
    cboxnames = str2mat('Plant','Controller','Perturbation','Input Signal');
    varnames_box = str2mat('SOLIC','CONTROLLER','PERTURBATION','INPUTSIG');
    mdef = [];
    systemwh = dataent('dimquery',systemdv,cboxnames,varnames_box,mdef,[],[],[],1,1);
    systemdv(11) = mainwin_w - XLBO - XRBO - systemwh(3);

    mess_h = 20;
    messx = XLBO;
    messy = YBOTBO;

%%---------------- Begin Plotting Table Controls Setup dimquery ------------------------------%%
    DUMMYWIN = 0;
    ifgap1_1 = 4;
    ifgap2 = 9;
    xbo2 = 6;
    ybotbo1 = 8;
    ybotbo2 = 2;
    ytopbo1 = 8;
    ytopbo2 = 8;
    titleheight = 20;
    swgap = 1;  % always 1, remember..
%
% frame around the Plotting figure buttons
    pltbuttitle = 'Current Plotting Figure Information';
    pltbutw = 2*xbo2;
    pltbutybotbo = ybotbo2;
    pltbutfx = messx;
    pltbutfy = messy + mess_h + ifgap1_1;
    pltbutf_dv = [pltbutfx;pltbutfy;pltbutybotbo;swgap;titleheight;pltbutw];

% title/xlabel/ylabel names with editable text
    txy_fx = pltbutfx + xbo2;
    txy_fy = pltbutfy + ybotbo2;
    dim_vec_txy  = [txy_fx;txy_fy;3;3;5;5;20;50;0;3;2];
    varnames_txy = str2mat('Title','Xlabel','Ylabel');
    callback_txy = [];
    txy_xywh = parmwin('dimquery','nwet',dim_vec_txy,...
            varnames_txy,[],DUMMYWIN,callback_txy,ET_BGC);

% title, xlabel, ylabel font names with editable text
    font_gap = 2;
    font_fx = txy_fx + txy_xywh(3) + font_gap;
    font_fy = txy_fy;
    dim_vec_font  = [font_fx;font_fy;3;3;5;5;20;28;26;3;2];
    varnames_font = str2mat('font','font','font');
    vardefaults_font = str2mat('10','10','10');
    callback_font = [];
    font_xywh = parmwin('dimquery','nwet',dim_vec_font,...
            varnames_font,vardefaults_font,DUMMYWIN,callback_font,ET_BGC);

    big_but_gap = 0;
    but_gap = 12;
    Nytopbo = 2;

    dim_vec_fig = [0;0;2;4;3;5;10;5;24;60;30;20;6];
    dim_vec_fig(1) = txy_fx;
    dim_vec_fig(2) = txy_fy + txy_xywh(4) + Nytopbo;
    butfig_xywh = updownb('dimquery',0,dim_vec_fig);

% Col#
    dim_vec_col = [0;0;3;4;3;5;10;5;22;46;30;24;6;16;30];
    dim_vec_col(1) = dim_vec_fig(1) + butfig_xywh(3) + but_gap;
    dim_vec_col(2) = dim_vec_fig(2);
    butcol_xywh = updownb2('dimquery',0,dim_vec_col);

% Row#
    dim_vec_row = [0;0;3;3;3;5;10;5;22;46;30;24;6;16;30];
    dim_vec_row(1) = dim_vec_fig(1) + butfig_xywh(3) + but_gap;
    dim_vec_row(2) = dim_vec_fig(2) + butcol_xywh(4) + 2;
    butrow_xywh = updownb2('dimquery',0,dim_vec_row);

% plot axes tick mark font,  names with editable text
    patfont_gap = 2;
    patfont_fx = butcol_xywh(1) + butcol_xywh(3) + big_but_gap;
    patfont_fy = butcol_xywh(2);
    dim_vec_patfont  = [patfont_fx;patfont_fy;3;3;5;5;butcol_xywh(4)-4;90;26;3;5];
    varnames_patfont = 'axes font';
    vardefaults_patfont = '10';
    callback_patfont = [];
    patfont_xywh = parmwin('dimquery','nwet',dim_vec_patfont,...
            varnames_patfont,vardefaults_patfont,0,...
            callback_patfont,ET_BGC);

%%------ End Plotting windows controls Setup dimquery --------------------%%

% Update based on WINDOW width/height

    big_but_gap = mainwin_w ...
                - (patfont_xywh(1) + patfont_xywh(3) + 2*xbo2);
       dim_vec_txy(9)  = mainwin_w ...
		- XLBO - XRBO - txy_xywh(3) - font_gap - font_xywh(3) - 2*xbo2;
       txy_xywh(3)     = txy_xywh(3) + dim_vec_txy(9);
       dim_vec_font(1) = txy_fx + txy_xywh(3) + font_gap;
       dim_vec_patfont(1) = butcol_xywh(1) + butcol_xywh(3) + big_but_gap;

% frame around the Plotting figure buttons
    pltbuttitle = 'Current Plotting Figure Information';
    pltbutw = xbo2 + txy_xywh(3) + font_gap + font_xywh(3) + xbo2;
    pltbutybotbo = ybotbo2 + txy_xywh(4) + Nytopbo + butfig_xywh(4) + ybotbo2;
    pltbutfx = messx;
    pltbutfy = messy + mess_h + ifgap1_1;
    pltbutf_dv = [pltbutfx;pltbutfy;pltbutybotbo;swgap;titleheight;pltbutw];
    pltbutfwh = parmwin('dimquery','frwtit',pltbutf_dv,DUMMYWIN,pltbuttitle);

% correct the height of the Main window
    mainwin_h = YBOTBO + mess_h + ifgap1_1 + pltbutfwh(4) + vtab_gap + ...
        pos_plt(4) + vtab_gap + systemwh(4) + YTOPBO;

% start setting up the window
    win_xy = [20 ss(4)-520];             % Window XY Corner
    win_c = [192 192 192]/255; % Window Color
    ORIGWINPOS = [win_xy mainwin_w mainwin_h];
    SIMWIN = figure('visible','off', 'DockControls', 'off');
    thstr = int2str(SIMWIN);
    set(SIMWIN,'menubar','none',...
        'NumberTitle','off',...
        'Color',win_c,...
        'visible','on',...
        'Position',ORIGWINPOS,...
        'DoubleBuffer','on');
    set(SIMWIN,'Name',['muTools(',int2str(SIMWIN),'): Simulation Tool' wsuff]);
    out = SIMWIN;

    NORMAX = mkdragtx('create',SIMWIN);
    set(NORMAX,'xlim',[0 1],'ylim',[0 1]);

    tmp = uimenu(SIMWIN,'Label','File');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    lscb1 = ['simgui(' thstr ',''ls_setup'',''load'');'];
    ttmp = uimenu(tmp,'Label','Load Setup',...
            'callback',lscb1);
    tttmp = uimenu(tmp,'Label','Save Setup','callback',...
            ['simgui(' thstr ',''save_setup'');']);
    ttttmp = uimenu(tmp,'Label','Quit','callback',['simgui(' thstr ',''quit'');']);
    vechandles(handlecnt:handlecnt+2) = [ttmp; tttmp; ttttmp];
    handlecnt = handlecnt + 3;
    tmp = uimenu(SIMWIN,'Label','LineStyle');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    ttmp = uimenu(tmp,'Label','Edit','callback',['simgui(' thstr ',''edittable'');']);
    tttmp = uimenu(tmp,'Label','Default');
    vechandles(handlecnt:handlecnt+1) = [ttmp;tttmp];
    handlecnt = handlecnt + 2;

    tmp = uimenu(tttmp,'Label','Color','callback',['simgui(' thstr ',''defaultcolor'');']);
    btmp = uimenu(tttmp,'Label','B/W','callback',['simgui(' thstr ',''defaultbw'');']);
    ctmp = uimenu(tttmp,'Label','Color Symbols',...
		'callback',['simgui(' thstr ',''defaultclrsym'');']);
    dtmp = uimenu(tttmp,'Label','B/W Symbols',...
		'callback',['simgui(' thstr ',''defaultbwsym'');']);
    COLORMENU = [tmp;btmp;ctmp;dtmp];
    set(COLORMENU,'enable','off');
    vechandles(handlecnt:handlecnt+3) = [tmp;btmp;ctmp;dtmp];
    handlecnt = handlecnt + 4;

    tmp = uimenu(SIMWIN,'Label','Options');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    ttmp = uimenu(tmp,'Label','Continuous',...
		'callback',['simgui(' thstr ',''typemenu'',1);'], 'checked','on');
    tttmp = uimenu(tmp,'Label','Discrete',...
		'callback',['simgui(' thstr ',''typemenu'',2);'],'checked','off');
    ttttmp = uimenu(tmp,'Label','Sampled-Data',...
		'callback',['simgui(' thstr ',''typemenu'',3);'],'checked','off');
    SIMTYPE = [1;ttmp;tttmp;ttttmp];
    vechandles(handlecnt:handlecnt+2) = [ttmp;tttmp;ttttmp];
    handlecnt = handlecnt + 3;

    tmp = uimenu(SIMWIN,'Label','Window');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    ttmp = uimenu(tmp,'Label','Hide Main','callback',['simgui(' thstr ',''hidemain'');']);
    tttmp = uimenu(tmp,'Label','Parameters','callback',...
		['simgui(' thstr ',''showparmwin'');']);
    PLTMENU(1) = uimenu(tmp,'Label','Plots');
      tmp1 = uimenu(PLTMENU(1),'Label',int2str(1),...
        'callback',['simgui(' thstr ',''showplotwin'',1);']);
    vechandles(handlecnt:handlecnt+2) = [ttmp;tttmp;PLTMENU(1)];
    handlecnt = handlecnt + 3;
    drawnow
    set(SIMWIN,'visible','on');

% create the message window
    MESSAGE = uicontrol(SIMWIN,'style','text',...
        'Position',[XLBO YBOTBO mainwin_w-XLBO-XRBO mess_h],...
        'visible','on','horizontalalignment','left',...
        'backgroundcolor',win_c);
    vechandles(handlecnt) = MESSAGE;
    handlecnt = handlecnt + 1;
    set(MESSAGE,'string','Setting up Simulation GUI......');
    drawnow

    llx = XLBO;
    lly = YBOTBO + mess_h + ifgap1_1 + pltbutfwh(4) + vtab_gap;
	TABLELOC = [XLBO+comp_xywh(3)+XMIDBO lly+pos_plt(4)+vtab_gap];
    ref_y = lly + YHBGAP;

%-----------------------------------------------------------------------------------%
%  Create Plotting Window Controls
%-----------------------------------------------------------------------------------%
    PRCHAN = zeros(19,1);
    pltbutfwh = parmwin('create','frwtit',pltbutf_dv,SIMWIN,pltbuttitle);

% Title, xlabel, ylabel
    callback_txy = ['simgui(' thstr ',''txy_names'','];
    txy_han = parmwin('create','nwet',dim_vec_txy,...
        varnames_txy,[],SIMWIN,callback_txy,ET_BGC,[]);

    PRCHAN(5) = txy_han;
% Title, Xlabel, Ylabel Fonts
    callback_font = ['simgui(' thstr ',''txy_font'','];
    txyfont_han = parmwin('create','nwet',dim_vec_font,...
            varnames_font,vardefaults_font,SIMWIN,callback_font,...
            ET_BGC,[]);
    PRCHAN(6) = txyfont_han;

    name = 'Plot Fig#';
    callbackfig = str2mat(['simgui(' thstr ',''changepagenum'')'],...
            ['simgui(' thstr ',''changepagenum'')'],...
            ['simgui(' thstr ',''changepagenum'')']);
    minmax_vals = [1 FIGMAX];

% Fig#
    fig_default = 1;
    fig_han = updownb('create',SIMWIN,dim_vec_fig,name,...
         ET_BGC,callbackfig,fig_default,minmax_vals);

% Row #
    minmax_vals = [1 1];
    name1 = 'Row #';
    name2 = 'of';
    row_default = [1 1];
    callbackrow = str2mat(['simgui(' thstr ',''changerownum'')'],...
            ['simgui(' thstr ',''changerownum'')'],...
            ['simgui(' thstr ',''changerownum'')'],...
            ['simgui(' thstr ',''rowcol_nwet'',1)']);
    row_han = updownb2('create',SIMWIN,dim_vec_row,name1,...
                 ET_BGC,callbackrow,row_default,name2,minmax_vals);

% Col #
    minmax_vals = [1 1];
    name1 = 'Col #';
    name2 = 'of';
    col_default = [1 1];
    callbackcol = str2mat(['simgui(' thstr ',''changecolnum'')'],...
            ['simgui(' thstr ',''changecolnum'')'],...
            ['simgui(' thstr ',''changecolnum'')'],...
            ['simgui(' thstr ',''rowcol_nwet'',2)']);
    col_han = updownb2('create',SIMWIN,dim_vec_col,name1,...
                 ET_BGC,callbackcol,col_default,name2,minmax_vals);

    PRCHAN(1:4) = [fig_han;0;row_han;col_han];

% total # of rows and cols
    butcol_xywh = updownb2('dimquery',0,dim_vec_col);
    APPLYBUT = uicontrol('style','pushbutton',...
        'position',...
          [dim_vec_col(1)+butcol_xywh(3)+10 dim_vec_col(2) 100 30],...
        'callback',['simgui(' thstr ',''applyrc'')'],...
        'visible','off',...
        'string','Apply');
    vechandles(handlecnt) = APPLYBUT;
    handlecnt = handlecnt + 1;

% plot axes tick mark font,  names with editable text
    callback_patfont = ['simgui(' thstr ',''axes_font'','];
    patfont_han = parmwin('create','nwet',dim_vec_patfont,...
            varnames_patfont,vardefaults_patfont,SIMWIN,...
            callback_patfont,ET_BGC,[]);
    PRCHAN(7) = patfont_han;

% Grid on/off popup menu
    grid_bw = patfont_xywh(3);
    grid_bh = butfig_xywh(4) - patfont_xywh(4) - 1;
    grid_x  = dim_vec_patfont(1);
    grid_y  = dim_vec_patfont(2) + patfont_xywh(4) + 1;
    grid_han = uicontrol('style','popup','String','Grid Off|Grid On',...
            'position',[grid_x grid_y grid_bw grid_bh],...
            'callback',['simgui(' thstr ',''grid'')']);
    PRCHAN(8) = grid_han;
    vechandles(handlecnt) = grid_han;
    handlecnt = handlecnt + 1;

    lly = ref_y - YHBGAP + comp_bh + bbgap;

    STOPHAN = uicontrol(SIMWIN,'style','pushbutton',...
    'visible','off',...
    'position',[messx lly comp_bw 1.5*comp_bh],...
        'enable','on','callback',['sguivar(''STOPFLAG'',1,' thstr ');'],...
        'String','Stop',...
    'interruptible','on');
    vechandles(handlecnt) = STOPHAN;
    handlecnt = handlecnt + 1;

    COMPUTEHAN = uicontrol(SIMWIN,'style',...
        'pushbutton','position',[messx lly comp_bw 1.5*comp_bh],...
    'visible','on',...
        'enable','off','callback',['simgui(' thstr ',''compute'');muexport;'],...
        'String','Compute',...
    'interruptible','on');
    vechandles(handlecnt) = COMPUTEHAN;
    handlecnt = handlecnt + 1;

%    lly = ref_y + 2*comp_bh + VGAP + VGAP; % updated location
    lly = TABLELOC(2)+vtab_gap;
% create drop boxes for IC, K, Delta amd input
    [o1,o2,o3,o4] = ...
        h2v(VN,PIM,'SOLIC','CONTROLLER','PERTURBATION','INPUTSIG');
    %LINKABLEEDIT = [zeros(4,2)];
    systemdv(1) = llx;
    systemdv(2) = lly;
    solicscb = ['set(gguivar(''MESSAGE'',' thstr '),''string'',''Refreshing Plant...'');'...
        'drawnow;simgui(' thstr ',''genendata'',1);'...
        'drawnow;simgui(' thstr ',''genench2'',1);'...
        'drawnow;simgui(' thstr ',''rtc'');'];
    solicecb = ['sguivar(''SOLIC'',[],' thstr ');disp(''error in SOLIC'');'];
    contscb  = ['set(gguivar(''MESSAGE'',' thstr '),''string'',''Refreshing Controller...'');'...
        'drawnow;simgui(' thstr ',''genendata'',2);'...
        'drawnow;simgui(' thstr ',''genench2'',2);'...
        'drawnow;simgui(' thstr ',''rtc'');'];
    contecb  = ['sguivar(''CONTROLLER'',[],' thstr ');disp(''error in CONT'');'];
    pertscb  = ['set(gguivar(''MESSAGE'',' thstr '),''string'',''Refreshing Perturbation...'');'...
        'drawnow;simgui(' thstr ',''genendata'',3);'...
        'drawnow;simgui(' thstr ',''genench2'',3);'...
        'drawnow;simgui(' thstr ',''rtc'');'];
    pertecb  = ['sguivar(''PERTURBATION'',[],' thstr ');disp(''error in PERT'');'];
    inptscb  = ['set(gguivar(''MESSAGE'',' thstr '),''string'',''Refreshing Input Signal...'');'...
        'drawnow;simgui(' thstr ',''genendata'',4);'...
        'drawnow;simgui(' thstr ',''genench2'',4);'...
        'drawnow;simgui(' thstr ',''rtc'');'];
    inptecb  = ['sguivar(''INPUTSIG'',[],' thstr ');disp(''error in INPUTSIG'');'];
    scb = str2mat(solicscb,contscb,pertscb,inptscb);
    ecb = str2mat(solicecb,contecb,pertecb,inptecb);
    [SOL_K_PER_IN,BINLOC] = ...
        dataent('create',systemdv,cboxnames,varnames_box,mdef,NORMAX,...
          scb,ecb,SIMWIN,'SOL_K_PER_IN');

% ----------------------------------------------------------------------------------
%  PARAMETER WINDOW
% ----------------------------------------------------------------------------------

    XLBO = 2;
    XRBO = 2;
    YTOPBO = 4;

    XMIDBO = 15;
    YBOTBO = 2;
    ybotbo2 = 6;
    ifgapx1 = 5;
    xbo1 = 2;


%   NAME STUFF
    nametitle = 'Identifiers';

    wnamedv = [0 0 4 4 4 4 20 150 3];
    wnamehead = '<Simulation Name>';
    wnamestring = '';
    wnamecb = ['simgui(' thstr ',''namecb'')'];

    sufdv = [0 0 4 4 4 4 20 150 3];
    sufhead = '<Export Suffix>';
    sufstring = '';
    sufcb = ['simgui(' thstr ',''sufcb'')'];

    messh = 20;
    messx = XLBO + 4;
    messy = YBOTBO;

% Export to Workspace
    savenames = str2mat('Open-Loop Nominal',...
        'Open-Loop Perturbed','Closed-Loop Nominal','Closed-Loop Perturbed',...
        'Plant','Controller','Perturbation','Input Signal');
    savedefaults = [1;1;1;1;0;0;0;0];
    savetitle = 'Export to Workspace';
    savecallback = 'rand(';
    tdv = [0;0;5;5;5;5;20;130;50;4;4];
    allrbdv = [0;0;5;5;5;5;22;sum(tdv([8 9 10]));4];

    %savefx = iternamefx + ifgapx1 + inf_wh(3);
    savefx = messx;
    savefy = messy + messh + ifgap1_1;
        savbutwh = parmwin('dimquery','locb',allrbdv,savenames,...
            savedefaults,DUMMYWIN,savecallback);

    savefw = xbo2 + savbutwh(3) + xbo2;
    savefybotbo = ybotbo2 + savbutwh(4) + ybotbo2;
    savef_dv = [savefx;savefy;savefybotbo;5;20;savefw];
    % this is just to get the height of this frame
    savefwh = parmwin('dimquery','frwtit',savef_dv,DUMMYWIN,savetitle);
        savbut_dv = allrbdv;
        savbut_dv(1) = savefx + xbo2;

% TRSP parameter frame
    tnames = str2mat('Final Time','Integration Step Size','Sample Time');
    tdefaults = [];
    ttitle = 'Response Parameters';
    tcallback = ['simgui(' thstr ',''ft_intss'',[]);gdataevl;simgui(' thstr ',''ft_intss'', '];

    xopdv = [0 0 4 4 4 4 20 201 3];
    xokdv = [0 0 4 4 4 4 20 201 3];
    xoddv = [0 0 4 4 4 4 20 201 3];
    xophead = 'Initial Condition (Plant)';
    xokhead = 'Initial Condition (Controller)';
    xodhead = 'Initial Condition (Perturbation)';
    xostring = '';
    xopcb = ['simgui(' thstr ',''IC_PKD'',1,''Plant'');'];
    xopcb = [xopcb 'gdataevl;simgui(' thstr ',''IC_PKD'',2,''Plant'');'];
    xokcb = ['simgui(' thstr ',''IC_PKD'',1,''Controller'');'];
    xokcb = [xokcb 'gdataevl;simgui(' thstr ',''IC_PKD'',2,''Controller'');'];
    xodcb = ['simgui(' thstr ',''IC_PKD'',1,''Perturbation'');'];
    xodcb = [xodcb 'gdataevl;simgui(' thstr ',''IC_PKD'',2,''Perturbation'');'];

    % numfx = txy_fx;
    numfx = XLBO;
    numfy = 0;
        xodwh = parmwin('dimquery','longed',xoddv,xodhead,xostring,...
            DUMMYWIN,xodcb,ET_BGC);
        xokwh = parmwin('dimquery','longed',xokdv,xokhead,xostring,...
            DUMMYWIN,xokcb,ET_BGC);
        xopwh = parmwin('dimquery','longed',xopdv,xophead,xostring,...
            DUMMYWIN,xopcb,ET_BGC);
    tdv(8) = 145;
        twh = parmwin('dimquery','nwd',tdv,tnames,tdefaults,...
            DUMMYWIN,tcallback,ET_BGC);
    numfw = xbo2 + twh(3) + xbo2;
    numfybotbo = ybotbo2 + xodwh(4) + ifgap2 + xokwh(4) + ifgap2 + ...
                  xopwh(4) + ifgap2 + twh(4) + ybotbo2;
    numf_dv = [numfx;numfy;numfybotbo;5;20;numfw];
    numfwh = parmwin('dimquery','frwtit',numf_dv,DUMMYWIN,ttitle);

    topofframe = YBOTBO + messh + ifgap1_1 + numfwh(4) + YTOPBO;
    	savef_dv(2) = topofframe - savefwh(4);
        	savbut_dv(2) = savef_dv(2) + ybotbo2;
    numfy = topofframe - numfwh(4);
    numf_dv(2) = numfy;
        xod_dv = xoddv;
        xod_dv(1) = numfx + xbo2;
        xod_dv(2) = numfy + ybotbo2;
        xok_dv = xokdv;
        xok_dv(1) = numfx + xbo2;
        xok_dv(2) = xod_dv(2) + xodwh(4) + ybotbo2;
        xop_dv = xopdv;
        xop_dv(1) = numfx + xbo2;
        xop_dv(2) = xok_dv(2) + xokwh(4) + ybotbo2;
        tdv(1) = numfx + xbo2;
        tdv(2) = xop_dv(2) + xopwh(4) + ifgap2;

% Identifiers
    iternamefx = numfx + numfwh(3) + ifgapx1;
    iternamefy = 0;
        wnamewh = parmwin('dimquery','longed',wnamedv,wnamehead,wnamestring,...
            DUMMYWIN,wnamecb,ET_BGC);
        sufwh = parmwin('dimquery','longed',sufdv,sufhead,sufstring,...
            DUMMYWIN,sufcb,ET_BGC);
    infw = xbo2 + wnamewh(3) + xbo2;
    inybotbo = ybotbo2 + wnamewh(4) + ifgap2 + sufwh(4) + ytopbo2;
    inf_dv = [iternamefx;iternamefy;inybotbo;5;20;infw];
    inf_wh = parmwin('dimquery','frwtit',inf_dv,DUMMYWIN,nametitle);
    iternamefy = topofframe - inf_wh(4);
        inf_dv(2)  = iternamefy;
    inf_wh(2)  = iternamefy;
        wnamedv(1) = iternamefx + xbo2;
        wnamedv(2) = iternamefy + ybotbo2;
        sufdv(1) = wnamedv(1);
        sufdv(2) = wnamedv(2) + ifgap2 + wnamewh(4);

    savefx = iternamefx + ifgapx1 + inf_wh(3);
    savefy = savef_dv(2);
        savbutwh = parmwin('dimquery','locb',allrbdv,savenames,...
            savedefaults,DUMMYWIN,savecallback);

    savefw = xbo2 + savbutwh(3) + xbo2;
    savefybotbo = ybotbo2 + savbutwh(4) + ybotbo2;
    savef_dv = [savefx;savefy;savefybotbo;5;20;savefw];
    savefwh = parmwin('dimquery','frwtit',savef_dv,DUMMYWIN,savetitle);
        savbut_dv = allrbdv;
        savbut_dv(1) = savefx + xbo2;
    savef_dv(2) = topofframe - savefwh(4);
        savbut_dv(2) = savef_dv(2) + ybotbo2;

    parmwin_w = savefx+savefwh(3)+xbo1;

    parmwin_h = savefy+savefwh(4)+ytopbo1;

%----------------------------------------------------%
%  Create the Parameter Window
%----------------------------------------------------%

    wsuff = [];
    winpos  = [ss(3)-630 50 parmwin_w parmwin_h];
    PARMWIN = figure('visible','off',...
	'menubar','none',...
        'NumberTitle','off',...
        'color',win_c,...
        'Position',winpos,...
        'DoubleBuffer','on', ...
        'DockControls', 'off');
    set(PARMWIN,'Name',['muTools(',int2str(PARMWIN),'): Simulation Parameters' wsuff]);
    tmp = uimenu(PARMWIN,'Label','Window');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    ttmp = uimenu(tmp,'Label','Hide Parameter','callback',...
		['simgui(' thstr ',''hideparmwin'');']);
    tttmp = uimenu(tmp,'Label','Main','callback',...
		['simgui(' thstr ',''showmain'');']);
    PLTMENU(2) = uimenu(tmp,'Label','Plots');
      tmp1 = uimenu(PLTMENU(2),'Label',int2str(1),...
        'callback',['simgui(' thstr ',''showplotwin'',1);']);
    vechandles(handlecnt:handlecnt+2) = [ttmp;tttmp;PLTMENU(2)];
    handlecnt = handlecnt + 3;
    drawnow

    MESS_PARM = uicontrol('style','text',...
              'position',[messx messy parmwin_w-2*xbo1 messh],...
               'visible','on','horizontalalignment','left',...
                  'backgroundcolor',win_c);
%%%%%%%%%%%%----------------- New Linkable Table -------------------%%%%%%%%%%%%%%

    PNORMAX = mkdragtx('create',PARMWIN);
    set(PNORMAX,'xlim',[0 1],'ylim',[0 1]);

    Lx = iternamefx;
    Ly = numfy;
    Lw = inf_wh(3)-20; % 70 for 2nd col
    Lh = iternamefy - 30 - Ly;
    sliderw = 20;
    linktabpos = [Lx/winpos(3) Ly/winpos(4) Lw/winpos(3) Lh/winpos(4)];
    ULN = str2mat('Plant','K','Pert','Input','YOLN','YOLP','YCLN','YCLP');
    TLN = str2mat('SOLIC','CONTROLLER','PERTURBATION','INPUTSIG','YOLN','YOLP',...
        'YCLN','YCLP');
    dl = str2mat('Plant ','K','Pert','Input','YOLN','YOLP','YCLN','YCLP');
    dr = str2mat('Open-loop IC','Controller','Perturbation',...
            'Input Signal','OL Nominal','OL Perturbed',...
            'CL Nominal','CL Perturbed');
    axes(PNORMAX)
    coltypemask = ['ds';'ss'];    %dragable/static(d/s), string/integer(p/s/i)
    colpt = [1 6;5 18];
    colpos = [.017 (Lw-100)/Lw];
    colstrings = str2mat('Constant','Empty','System','Varying');
    colalign = 'll';
    coltitles = str2mat('Name','Meaning');
    [AXESHAN,exhan] = scrtxtn('create',PARMWIN,linktabpos,[0 1],[0.005 6],...
        coltypemask,colpos,colalign,colpt,colstrings,coltitles,link_font);
    ndata = abs([dl dr]);
    scrtxtn('changedata',AXESHAN,ndata,(1:7)');
    scrtxtn('draw',AXESHAN);
    set(PARMWIN,'visible','off');
    %% vechandles(handlecnt:handlecnt+length(exhan)-1) = exhan;
    %% handlecnt = handlecnt + length(exhan);

    %% COORDS = [Lx+Lw+sliderw Ly rightx];

    trspof = parmwin('create','frwtit',savef_dv,PARMWIN,savetitle);

    EXPHAN = parmwin('create','locb',savbut_dv,savenames,savedefaults,PARMWIN,savecallback);

    name_tit = parmwin('create','frwtit',inf_dv,PARMWIN,nametitle);
    xx = parmwin('create','longed',wnamedv,wnamehead,wnamestring,...
        PARMWIN,wnamecb,ET_BGC);
    yy = parmwin('create','longed',sufdv,sufhead,sufstring,...
        PARMWIN,sufcb,ET_BGC);
    set(name_tit,'userdata',[yy xx]);
    sufhans = get(yy,'userdata');
    exphans = get(xx,'userdata');
    TRSP_IDHANS(7:8) = [sufhans(2);exphans(2)];

    num_tit = parmwin('create','frwtit',numf_dv,PARMWIN,ttitle);
        xodhan = parmwin('create','longed',xod_dv,xodhead,xostring,PARMWIN,xodcb,ET_BGC);
        xokhan = parmwin('create','longed',xok_dv,xokhead,xostring,PARMWIN,xokcb,ET_BGC);
        xophan = parmwin('create','longed',xop_dv,xophead,xostring,PARMWIN,xopcb,ET_BGC);
        hand = get(xodhan,'userdata');
        hank = get(xokhan,'userdata');
        hanp = get(xophan,'userdata');
        thandle = parmwin('create','nwd',tdv,tnames,tdefaults,...
            PARMWIN,tcallback,ET_BGC,[]);

        thans = get(thandle,'userdata');
    thans_edit = thans(1:3,1);
    thans_text = thans(1:3,2);
    hanp_edit  = hanp(2);
    hank_edit  = hank(2);
    hand_edit  = hand(2);
    TRSP_IDHANS(1:6) = [thans_edit;hanp_edit;hank_edit;hand_edit];
    TRSP_IDHANS(9:11) = thans_text;
% continuous time enabled, discrete disabled
    set(TRSP_IDHANS(3),'string',int2str(1),'enable','off');
    set(TRSP_IDHANS(11),'enable','off');

%    [o5,o6,o7,o8,o9] = h2v(VN,PIM,'TFIN','INTSS','XINITP','XINITK','XINITD');
%    LINKABLEEDIT = [LINKABLEEDIT; ...
%        [ [thans; hanp(2);hank(2);hand(2)] ...
%            [o5(gonumcol);o6(gonumcol);o7(gonumcol);o8(gonumcol);o9(gonumcol)] ]];
%
%---------------------- end of Parameter Window creation ----------------------------------%

%   this is what we're doing
%    TLN = str2mat('SOLIC','CONTROLLER','PERTURBATION','INPUTSIG','YOLN','YOLP',...
%        'YCLN','YCLP');
%    ULN = str2mat('Sim_OLIC','K','Delta','u','YOLN','YOLP',...
%        'YCLN','YCLP');

%---------- create the 1st plotting window --------------%
     ALLFIGS(1) = figure('visible','off',...
            'Numbertitle','off',...
            'menubar','none', ...
            'DockControls', 'off');
    set(ALLFIGS(1),'Name',...
      ['muTools(',int2str(ALLFIGS(1)),'): Simulation Plot Page #' int2str(1)  wsuff]);

% Set default colors and stuff now .. GJW 09/10/96
%   colordef(ALLFIGS(1),'black');	% colordef is really broken
    pltcols(ALLFIGS(1));
    ah = subplot(1,1,1);
    set(ah,'nextplot','add','Fontsize',DF_FONT(4));
    AXESPIM = mdipii([],ah,1,1,1);

    PLTWIN = ALLFIGS(1);
    tmp = uimenu(PLTWIN,'Label','Window');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    atmp = uimenu(tmp,'Label',['Hide Plot #' int2str(1)],...
        'callback',['simgui(' thstr ',''hideplotwin'',1);']);
    btmp = uimenu(tmp,'Label','Main','callback',['simgui(' thstr ',''showmain'');']);
    ctmp = uimenu(tmp,'Label','Parameters','callback',...
		['simgui(' thstr ',''showparmwin'');']);
    PLTMENU(3) = uimenu(tmp,'Label','Plots');
      ttmp = uimenu(PLTMENU(3),'Label',int2str(1),...
            'callback',['simgui(' thstr ',''showplotwin'',1);']);
    vechandles(handlecnt:handlecnt+3) = [atmp;btmp;ctmp;PLTMENU(3)];
    handlecnt = handlecnt + 4;

    tmp = uimenu(PLTWIN,'Label','Printing');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    atmp = uimenu(tmp,'Label','Print','callback',...
        ['simgui(' thstr ',''lets_print'',' int2str(1) ');']);
    vechandles(handlecnt) = [atmp];
    handlecnt = handlecnt + 1;
    drawnow
    set(ALLFIGS(1),'visible','on');

%---------------- end 1st plot window setup --------------%

%---------------------------------------------------------%
%  Create the Print Dialog Box and Load/Save Dialog Box
%---------------------------------------------------------%

    printb_fx = XLBO;
    printb_fy = YBOTBO;
    printb_bw = 180;
    printb_bh = 30;
    vpgap = 5;
    hpgap = 15;

% Print device/options/filename names with editable text
    dof_fx = printb_fx;
    dof_fy = printb_fy + printb_bh + vpgap;
    dim_vec_dof  = [dof_fx;dof_fy;3;3;5;5;20;80;190;3;5];
    varnames_dof = str2mat('Device','Options','Filename');
    callback_dof = 'rand(';
    dof_xywh = parmwin('dimquery','nwet',dim_vec_dof,...
            varnames_dof,[],DUMMYWIN,callback_dof,ET_BGC);

    quit_bw = dof_xywh(3) - printb_bw - hpgap;
    quit_bh = printb_bh;
    quit_fx = printb_fx + printb_bw + hpgap;
    quit_fy = printb_fy;

    printwin_w = XLBO + dof_xywh(3) + XRBO;
    printwin_h = YBOTBO + printb_bh + vpgap + dof_xywh(4) + YTOPBO;

    PRINTWIN = figure('menubar','none',...
        'NumberTitle','off',...
        'color',[0.6 0.6 0.6],...
        'visible','off',...
        'position',[ss(3)/2-150 ss(4)/2-50 printwin_w printwin_h],...
        'DoubleBuffer','on', ...
        'DockControls', 'off');
    set(PRINTWIN,'Name',['muTools(',int2str(PRINTWIN),'): Print Dialog Box' wsuff]);

% print button
    PRINTBHAN  = uicontrol(PRINTWIN,'style','pushbutton',...
    'position',[printb_fx printb_fy printb_bw printb_bh],'visible','on',...
        'enable','on',...
        'callback',['simgui(' thstr ',''print_dof'');'],...
        'String','Print');
    %vechandles(handlecnt) = PRINTBHAN;
    %handlecnt = handlecnt + 1;
    PRCHAN(13) = PRINTBHAN;

% quit print dialog box button
    QUITBHAN  = uicontrol(PRINTWIN,'style',...
        'pushbutton','position',[quit_fx quit_fy quit_bw quit_bh],'visible','on',...
        'enable','on',...
        'callback',['simgui(' thstr ',''quit_dof'');'],...
        'String','Cancel');
    PRCHAN(14) = QUITBHAN;

% Print device, options, and filname
    [dof_han,dof_than] = parmwin('create','nwet',dim_vec_dof,...
        varnames_dof,[],PRINTWIN,callback_dof,ET_BGC,[]);

    PRCHAN(9) = dof_han;
    PRCHAN(10:12) = dof_than;

% load/save button
    lscb = ['simgui(' thstr ',''load_save'');eval(gguivar(''SUCCESSCB'',' thstr '),'];
    lscb = [lscb ['gguivar(''ERRORCB'',' thstr '));']];
    LSBHAN  = uicontrol(PRINTWIN,'style','pushbutton',...
    'position',[printb_fx printb_fy printb_bw printb_bh],'visible','off',...
        'enable','on',...
        'callback',lscb,...
        'String','Load/Save');
    PRCHAN(15) = LSBHAN;

% quit load/save dialog box button
    QUITLSBHAN  = uicontrol(PRINTWIN,'style',...
        'pushbutton','position',[quit_fx quit_fy quit_bw quit_bh],'visible','off',...
        'enable','on',...
        'callback',['simgui(' thstr ',''quit_ls'');'],...
        'String','Cancel');
    PRCHAN(16) = QUITLSBHAN;

% Load/Save variable and filname
    dof_fx = printb_fx;
    dof_fy = printb_fy + printb_bh + vpgap;
    dim_vec_ls  = [dof_fx;dof_fy;3;3;5;5;20;80;190;3;5];
    varnames_ls = str2mat('Variable','Filename');
    varnames_def = str2mat('SAVESET','SAVESET.mat');
    callback_ls = 'rand(';
    [ls_han,ls_than] = parmwin('create','nwet',dim_vec_ls,...
        varnames_ls,varnames_def,PRINTWIN,callback_ls,ET_BGC,[]);
    ud = get(ls_han,'userdata');
    set(ud,'visible','off');
    set(ls_han,'visible','off');
    set(ls_than,'visible','off');

    PRCHAN(17) = ls_han;
    PRCHAN(18:19) = ls_than;

%---------------- end print dialog box setup --------------%

% setup USERDATA
    exhan = vechandles(1:handlecnt-1);
%   set(SIMWIN,'Userdata',[exhan;abs('MAIN')']);
%   set(PLTWIN,'Userdata',[exhan;abs('SPLT')']);
%   set(PARMWIN,'Userdata',[exhan;abs('WIND')']);
%   set(PRINTWIN,'Userdata',[exhan;abs('WIND')']);
    mkours(exhan,SIMWIN,PARMWIN,PRINTWIN,PLTWIN);
    set(PLTWIN,'Userdata',[get(PLTWIN,'Userdata');abs('SPLT')']);
    set(exhan(1),'userdata',VN); set(exhan(2),'userdata',PIM);

    sguivar('PLTWIN',PLTWIN,'PLTAXES',[],'COMPUTEHAN',COMPUTEHAN,...
		'PLTMENU',PLTMENU,SIMWIN);
    sguivar('PRCHAN',PRCHAN,'FIGMAX',FIGMAX,'APPLYBUT',APPLYBUT,SIMWIN);
    sguivar('CURCOORD',[1 1 1],'LASTCOORD',[1 1 1],SIMWIN);
    sguivar('EXPORTVAR',[],'EXPHAN',EXPHAN,SIMWIN);
    sguivar('FRESH',0,'COMPSTAT',zeros(4,2),'GGWIN',[],'STOPHAN',STOPHAN,SIMWIN);
    sguivar('LOADSTAT',...
     [0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 0;2 0 0 0;2 0 0 0;2 0 0 0;2 0 0 0;2 0 0 0],SIMWIN);
    sguivar('DIMREADY',0,'EDITING',0,'STOPFLAG',0,SIMWIN);
    sguivar('NAMESCOMP',NAMESCOMP,'NAMESNOTCOMP',NAMESNOTCOMP,SIMWIN);
    sguivar('MESSAGE',MESSAGE,'MESS_PARM',MESS_PARM,SIMWIN);
    sguivar('MFILENAME','simgui','TOOLTYPE','SIM','TABLELOC',TABLELOC,SIMWIN);
    sguivar('SIMWIN',SIMWIN,'TYPEDATA',zeros(9,1),SIMWIN);
    sguivar('COLORMENU',COLORMENU,'UDNAME',UDNAME,SIMWIN);
    sguivar('XINITP',[],'XINITK',[],'XINITD',[],'TFIN',[],...
		'INTSS',[],'TRSP_IDHANS',TRSP_IDHANS,SIMWIN);
    sguivar('ULINKNAMES',ULN,'TLINKNAMES',TLN,'SAMPT',1,SIMWIN);
    sguivar('SOL_K_PER_IN',SOL_K_PER_IN,'ORIGWINPOS',ORIGWINPOS,SIMWIN);
    sguivar('TITLEPIM',[],'XLPIM',[],'YLPIM',[],'DF_GRID',1,SIMWIN);
    sguivar('TFONTPIM',[],'XFONTPIM',[],'YFONTPIM',[],...
		'AFONTHAN',[],'DF_FONT',DF_FONT,SIMWIN);
    sguivar('MASKPIM',[],'MATDATAPIM',[],'MATRVPIM',[],...
		'CNTPIM',[],'VISROWPIM',[],'GROUPFFPIM',[],SIMWIN);
    sguivar('OLN',[],'CLN',[],'OLP',[],'CLP',[],'OLDFIGMAT',[],SIMWIN);
    sguivar('YHANOLN',[],'YHANCLN',[],'YHANOLP',[],'YHANCLP',[],'SIMTYPE',SIMTYPE,SIMWIN);
    sguivar('PARMWIN',PARMWIN,...
		'ALLFIGS',[ALLFIGS(1); nan*ones(FIGMAX-1,1)],'AXESPIM',AXESPIM,SIMWIN);
    sguivar('FIGMAT',[ones(FIGMAX,4) [1; nan*ones(FIGMAX-1,1)]],...
		'PRINTWIN',PRINTWIN,'PRINTNFIG',[],SIMWIN);

    mknorm(SIMWIN);
    mknorm(PARMWIN);

    if ss(4)<600
        set(SIMWIN,'position',[ORIGWINPOS(1:2) 1*ORIGWINPOS(3:4)]);
    end

    figure(SIMWIN);
    axhans = axes('position',[0 0 1 1],...
                        'visible','off');   % create invisible, full, normalized AXES
    %BINLOC = [BINLOC LINKABLEEDIT(1:4,1)];
    sguivar('BINLOC',BINLOC,SIMWIN);
    set(SIMWIN,'DeleteFcn',['disp(''Cleaning up in SIMGUI..'');simgui([],''quit'')']);

    set(SIMWIN,'handlevis','call');
    set(PARMWIN,'handlevis','call');
    set(PRINTWIN,'handlevis','call');
    set(ALLFIGS(1),'handlevis','call');

    set(MESSAGE,'string','Done with Setup.  See the manual, pages 6-41 to 6-67 for more info.');
elseif strcmp(in1,'edittable')
    [SELECTHAN,DONEEDITHAN] = gguivar('SELECTHAN','DONEEDITHAN',toolhan);
    scrolltb('switchrowstyle',SELECTHAN,[2 3 4 5],['edit';'edit';'edit';'edit']);
    set(DONEEDITHAN,'visible','on');
    sguivar('EDITING',1,toolhan);
elseif strcmp(in1,'doneedit')
    tmpstyle = 'checkbox';
    [SELECTHAN,DONEEDITHAN] = gguivar('SELECTHAN','DONEEDITHAN',toolhan);
    scrolltb('switchrowstyle',SELECTHAN,[2 3 4 5],...
        [tmpstyle;tmpstyle;tmpstyle;tmpstyle]);
    set(DONEEDITHAN,'visible','off');
    sguivar('EDITING',0,toolhan);
elseif strcmp(in1,'computeenable')
    [DIMREADY] = gguivar('DIMREADY',toolhan);
    % Quick fix to remove a warning.. GJW 09/11/96
    if isempty(DIMREADY)
        DIMREADY = 0;
    end;
    if DIMREADY == 1
        simgui(toolhan,'rtc');
    end
elseif strcmp(in1,'compute')
    [SOLIC,CONTROLLER,PERTURBATION,INPUTSIG,LOADSTAT,COMPSTAT] = ...
        gguivar('SOLIC','CONTROLLER','PERTURBATION',...
		'INPUTSIG','LOADSTAT','COMPSTAT',toolhan);
    [FRESH,PLTAXES,VISIBLE_MAT,SELECTHAN,SIMWIN] = ...
        gguivar('FRESH','PLTAXES','VISIBLE_MAT','SELECTHAN','SIMWIN',toolhan);
    [OLDFIGMAT,FIGMAT,ALLFIGS,SIMTYPE,STOPHAN,COMPUTEHAN] = ...
     gguivar('OLDFIGMAT','FIGMAT','ALLFIGS','SIMTYPE','STOPHAN','COMPUTEHAN',toolhan);

    set(STOPHAN,'visible','on');
    set(COMPUTEHAN,'visible','off');
    simgui(SIMWIN,'ct2pim'); % copy the current table state into the PIMS
    [AXESPIM] = gguivar('AXESPIM',toolhan);
    zero_pert = zeros(LOADSTAT(3,2),LOADSTAT(3,3));
    zero_cont = zeros(LOADSTAT(2,2),LOADSTAT(2,3));
    tmp = [(COMPSTAT(:,1)==0 & COMPSTAT(:,2) == 1) ; ones(4,1)];
    [SUFFIXNAME,EXPHAN,MESSAGE] = gguivar('SUFFIXNAME','EXPHAN','MESSAGE',toolhan);
    savestat = find(tmp & parmwin('getvalues','locb',EXPHAN));
    EXPORTVAR = [];
    EXPORTVAR = ipii(EXPORTVAR,length(savestat),1);
    iexpcnt = 1;
    [TFIN,INTSS,SAMPT] = gguivar('TFIN','INTSS','SAMPT',toolhan);
    if ~isempty(TFIN)
        tfinal = TFIN;
    else
        [mattype,rowd,cold,num] = minfo(INPUTSIG);
    if strcmp(mattype,'cons');
        tfinal = 1;
    else
            tfinal = max(getiv(INPUTSIG));
    end
    end
    if ~isempty(INTSS)
        intss = INTSS;
    else
        intss = 0;
    end
    if ~isempty(SAMPT)
        sampt = SAMPT;
    else
        sampt = 1;
    end
    flag = zeros(1,4);
    %% [mainw,othw,spltw] = findmuw;
      [mainw,othw,notours,spltw] = findmuw;
      spltw = xpii(spltw,gguivar('SIMWIN',toolhan));
      spltw = spltw(:,1);
    if COMPSTAT(1,1) == 0 & COMPSTAT(1,2) == 1
        set(gguivar('MESSAGE',toolhan),'string','Computing ...');
        drawnow
        [XINITP] = gguivar('XINITP',toolhan);
        if isempty(XINITP)
            xo = [zeros(xnum(SOLIC),1)];
        else
            xo = [XINITP];
        end
    if SIMTYPE(1) == 1 | SIMTYPE(1) == 3    % continuous time or sampled-data
            y = trsp(starp(zero_pert,starp(SOLIC,zero_cont)),INPUTSIG,...
                tfinal,intss,xo,MESSAGE);
    elseif SIMTYPE(1) == 2          % discrete time
            y = dtrsp(starp(zero_pert,starp(SOLIC,zero_cont)),INPUTSIG,...
                sampt,tfinal,xo,MESSAGE);
    end
    YHANOLN = [];
    if ~isempty(y)
        for i=1:length(find(~isnan(FIGMAT(:,5))))
            set(gguivar('MESSAGE',toolhan),'string',...
                ['Drawing Plot #' int2str(i)]);
            if any(ALLFIGS(i) == spltw)
            drawnow
            for j=1:FIGMAT(i,1)
                for k=1:FIGMAT(i,2)
                    axes(mdxpii(AXESPIM,i,j,k));
                        smhand = vplot(y,'gui');
                    set(smhand,'visible','off');
                    YHANOLN = mdipii(YHANOLN,smhand,i,j,k);
                end
            end
            end
        end
        set(gguivar('MESSAGE',toolhan),'string',...
            'Finished Plotting Nominal Open-loop Response');
        drawnow
        sguivar('YHANOLN',YHANOLN,'YOLN',y,toolhan);
            if any(savestat == 1)
                EXPORTVAR = ipii(EXPORTVAR,['YOLN' SUFFIXNAME],2*iexpcnt+1);
                EXPORTVAR = ipii(EXPORTVAR,['YOLN'],2*iexpcnt);
                iexpcnt = iexpcnt + 1;
            end
            COMPSTAT(1,1) = 1;
        flag(1) = 1;
    else
         set(gguivar('MESSAGE',toolhan),'string',...
                        'Nominal Open-loop Response Stopped');
    end
    end
    if COMPSTAT(2,1) == 0 & COMPSTAT(2,2) == 1
        set(gguivar('MESSAGE',toolhan),'string','Computing ...');
        drawnow
        [XINITP,XINITD] = gguivar('XINITP','XINITD',toolhan);
        if isempty(XINITD)
            xo = zeros(xnum(PERTURBATION),1);
        else
            xo = XINITD;
        end
        if isempty(XINITP)
            xo = [xo;zeros(xnum(SOLIC),1)];
        else
            xo = [xo;XINITP];
        end
    if SIMTYPE(1) == 1 | SIMTYPE(1) == 3    % continuous time or sampled-data
            y = trsp(starp(PERTURBATION,starp(SOLIC,zero_cont)),INPUTSIG,...
                tfinal,intss,xo,MESSAGE);
    elseif SIMTYPE(1) == 2          % discrete time
            y = dtrsp(starp(PERTURBATION,starp(SOLIC,zero_cont)),INPUTSIG,...
                sampt,tfinal,xo,MESSAGE);
    end
    YHANOLP = [];
    if ~isempty(y)
        for i=1:length(find(~isnan(FIGMAT(:,5))))
            set(gguivar('MESSAGE',toolhan),'string',...
                ['Drawing Plot #' int2str(i)]);
            drawnow
            if any(ALLFIGS(i) == spltw)
            for j=1:FIGMAT(i,1)
                for k=1:FIGMAT(i,2)
                    axes(mdxpii(AXESPIM,i,j,k));
                        smhand = vplot(y,'gui');
                    set(smhand,'visible','off');
                    YHANOLP = mdipii(YHANOLP,smhand,i,j,k);
                end
            end
            end
        end
        set(gguivar('MESSAGE',toolhan),'string',...
            'Finished Plotting Perturbed Open-loop Response');
        drawnow
        sguivar('YHANOLP',YHANOLP,'YOLP',y,toolhan);
            if any(savestat == 2)
                    EXPORTVAR = ipii(EXPORTVAR,['YOLP' SUFFIXNAME],...
                        2*iexpcnt+1);
                    EXPORTVAR = ipii(EXPORTVAR,['YOLP'],2*iexpcnt);
                iexpcnt = iexpcnt + 1;
            end
            COMPSTAT(2,1) = 1;
        flag(2) = 1;
    else
         set(gguivar('MESSAGE',toolhan),'string',...
                        'Perturbed Open-loop Response Stopped');
    end
    end
    if COMPSTAT(3,1) == 0 & COMPSTAT(3,2) == 1
        set(gguivar('MESSAGE',toolhan),'string','Computing ...');
        drawnow
        [XINITP,XINITK] = gguivar('XINITP','XINITK',toolhan);
        if isempty(XINITP)
            xo = zeros(xnum(SOLIC),1);
        XINITP = zeros(xnum(SOLIC),1);
        else
            xo = XINITP;
        end
        if isempty(XINITK)
            xo = [xo;zeros(xnum(CONTROLLER),1)];
        XINITK = zeros(xnum(CONTROLLER),1);
        else
            xo = [xo;XINITK];
        end
    if SIMTYPE(1) == 1              % continuous time
            y = trsp(starp(zero_pert,starp(SOLIC,CONTROLLER)),...
                INPUTSIG,tfinal,intss,xo,MESSAGE);
    elseif SIMTYPE(1) == 2              % discrete time
            y = dtrsp(starp(zero_pert,starp(SOLIC,CONTROLLER)),...
                INPUTSIG,sampt,tfinal,xo,MESSAGE);
    elseif SIMTYPE(1) == 3              % sample-data
            y = sdtrsp(starp(zero_pert,SOLIC),CONTROLLER,INPUTSIG,...
                sampt,tfinal,intss,XINITP,XINITK,MESSAGE);
    end
    YHANCLN = [];
    if ~isempty(y)
        for i=1:length(find(~isnan(FIGMAT(:,5))))
            set(gguivar('MESSAGE',toolhan),'string',...
                ['Drawing Plot #' int2str(i)]);
            drawnow
            if any(ALLFIGS(i) == spltw)
            for j=1:FIGMAT(i,1)
                for k=1:FIGMAT(i,2)
                    axes(mdxpii(AXESPIM,i,j,k));
                        smhand = vplot(y,'gui');
                    set(smhand,'visible','off');
                    YHANCLN = mdipii(YHANCLN,smhand,i,j,k);
                end
            end
            end
        end
        set(gguivar('MESSAGE',toolhan),'string',...
            'Finished Plotting Nominal Closed-loop Response');
        drawnow
        sguivar('YHANCLN',YHANCLN,'YCLN',y,toolhan);
            if any(savestat == 3)
                    EXPORTVAR = ipii(EXPORTVAR,['YCLN' SUFFIXNAME],...
                        2*iexpcnt+1);
                    EXPORTVAR = ipii(EXPORTVAR,['YCLN'],2*iexpcnt);
                    iexpcnt = iexpcnt + 1;
            end
            COMPSTAT(3,1) = 1;
        flag(3) = 1;
    else
         set(gguivar('MESSAGE',toolhan),'string',...
                        'Nominal Closed-loop Response Stopped');
    end
    end
    if COMPSTAT(4,1) == 0 & COMPSTAT(4,2) == 1
        set(gguivar('MESSAGE',toolhan),'string','Computing ...');
        drawnow
        [XINITP,XINITK,XINITD] = gguivar('XINITP','XINITK','XINITD',toolhan);
        if isempty(XINITD)
            xo = zeros(xnum(PERTURBATION),1);
        XINITDP = zeros(xnum(PERTURBATION),1);
        else
            xo = XINITD;
        end
        if isempty(XINITP)
            xo = [xo;zeros(xnum(SOLIC),1)];
        XINITDP = [XINITDP;zeros(xnum(SOLIC),1)];
        else
            xo = [xo;XINITP];
        XINITDP = [XINITDP;XINITP];
        end
        if isempty(XINITK)
            xo = [xo;zeros(xnum(CONTROLLER),1)];
        XINITK = zeros(xnum(CONTROLLER),1);
        else
            xo = [xo;XINITK];
        end
    if SIMTYPE(1) == 1              % continuous time
            y = trsp(starp(PERTURBATION,starp(SOLIC,CONTROLLER)),...
                INPUTSIG,tfinal,intss,xo,MESSAGE);
    elseif SIMTYPE(1) == 2              % discrete time
            y = dtrsp(starp(PERTURBATION,starp(SOLIC,CONTROLLER)),...
                INPUTSIG,sampt,tfinal,xo,MESSAGE);
    elseif SIMTYPE(1) == 3              % sample-data
            y = sdtrsp(starp(PERTURBATION,SOLIC),CONTROLLER,INPUTSIG,...
                sampt,tfinal,intss,XINITDP,XINITK,MESSAGE);
    end
    YHANCLP = [];
        set(STOPHAN,'visible','off');
        set(COMPUTEHAN,'visible','on','enable','off');
    if ~isempty(y)
        for i=1:length(find(~isnan(FIGMAT(:,5))))
            set(gguivar('MESSAGE',toolhan),'string',...
                ['Drawing Plot #' int2str(i)]);
            drawnow
            if any(ALLFIGS(i) == spltw)
            for j=1:FIGMAT(i,1)
                for k=1:FIGMAT(i,2)
                    axes(mdxpii(AXESPIM,i,j,k));
                        smhand = vplot(y,'gui');
                    set(smhand,'visible','off');
                    YHANCLP = mdipii(YHANCLP,smhand,i,j,k);
                end
            end
            end
        end
        set(gguivar('MESSAGE',toolhan),'string',...
            'Finished Plotting Perturbed Closed-loop Response');
        drawnow
        sguivar('YHANCLP',YHANCLP,'YCLP',y,toolhan);
            if any(savestat == 4)
                    EXPORTVAR = ipii(EXPORTVAR,...
                ['YCLP' SUFFIXNAME],2*iexpcnt+1);
                    EXPORTVAR = ipii(EXPORTVAR,['YCLP'],2*iexpcnt);
                    iexpcnt = iexpcnt + 1;
            end
            COMPSTAT(4,1) = 1;
        flag(4) = 1;
    else
         set(gguivar('MESSAGE',toolhan),'string',...
                        'Perturbed Closed-loop Response Stopped');
    end
    end

    if any(savestat == 5)
        EXPORTVAR = ipii(EXPORTVAR,['SOLIC' SUFFIXNAME],2*iexpcnt+1);
        EXPORTVAR = ipii(EXPORTVAR,['SOLIC'],2*iexpcnt);
        iexpcnt = iexpcnt + 1;
    end
    if any(savestat == 6)
        EXPORTVAR = ipii(EXPORTVAR,['K' SUFFIXNAME],2*iexpcnt+1);
        EXPORTVAR = ipii(EXPORTVAR,['CONTROLLER'],2*iexpcnt);
        iexpcnt = iexpcnt + 1;
    end
    if any(savestat == 7)
        EXPORTVAR = ipii(EXPORTVAR,['DELTA' SUFFIXNAME],2*iexpcnt+1);
        EXPORTVAR = ipii(EXPORTVAR,['PERTURBATION'],2*iexpcnt);
        iexpcnt = iexpcnt + 1;
    end
    if any(savestat == 8)
        EXPORTVAR = ipii(EXPORTVAR,['U' SUFFIXNAME],2*iexpcnt+1);
        EXPORTVAR = ipii(EXPORTVAR,['INPUTSIG'],2*iexpcnt);
        iexpcnt = iexpcnt + 1;
    end

    [PLTWIN,COMPUTEHAN,NAMESCOMP,NAMESNOTCOMP] = ...
        gguivar('PLTWIN','COMPUTEHAN','NAMESCOMP','NAMESNOTCOMP',toolhan);
    cc = find(COMPSTAT(:,1)==1);
    names = [NAMESCOMP(cc+1,:)];
    scrolltb('namechange',SELECTHAN,names,[cc+1]);
    if ~any(any(VISIBLE_MAT))
        set(PLTAXES,'visible','off');
    end
    sguivar('FRESH',1,'COMPSTAT',COMPSTAT,'EXPORTVAR',EXPORTVAR,toolhan);
    [MATDATAPIM,MATRVPIM,MASKPIM,VISROWPIM] = ...
        gguivar('MATDATAPIM','MATRVPIM','MASKPIM','VISROWPIM',toolhan);
    [AXESPIM] = gguivar('AXESPIM',toolhan);
    if any(flag==1)
        set(gguivar('MESSAGE',toolhan),'string',...
            'Start Displaying Plotted Responses');
        drawnow
        % need to do something here is the PAGE Figure doesn't exist
              [mainw,othw,notours,spltw] = findmuw;
              spltw = xpii(spltw,gguivar('SIMWIN',toolhan));
                  spltw = spltw(:,1);
        for i=1:length(find(~isnan(FIGMAT(:,5))))
            if any(ALLFIGS(i)==spltw)
            for j=1:FIGMAT(i,1)
                for k=1:FIGMAT(i,2)
                    matdata = mdxpii(MATDATAPIM,i,j,k);
                    matrv = mdxpii(MATRVPIM,i,j,k);
                    mask = mdxpii(MASKPIM,i,j,k);
                    visrow = mdxpii(VISROWPIM,i,j,k);
                    if flag(1)
                        oln = mdxpii(YHANOLN,i,j,k);
                    else
                        oln = [];
                    end
                    if flag(2)
                        olp = mdxpii(YHANOLP,i,j,k);
                    else
                        olp = [];
                    end
                    if flag(3)
                        cln = mdxpii(YHANCLN,i,j,k);
                    else
                        cln = [];
                    end
                    if flag(4)
                        clp = mdxpii(YHANCLP,i,j,k);
                    else
                        clp = [];
                    end
                    axhan = mdxpii(AXESPIM,i,j,k);
                    simgui(SIMWIN,'ssredraw',matdata,matrv,mask,visrow,...
                        oln,olp,cln,clp,axhan,[i j k]);
                end
            end
            end
        end
        set(gguivar('MESSAGE',toolhan),'string',...
            'Finished Displaying Plotted Responses');
        drawnow
    end
        set(gguivar('STOPHAN',toolhan),'visible','off');
        set(gguivar('COMPUTEHAN',toolhan),'enable','off','visible','on');
    sguivar('OLDFIGMAT',FIGMAT,toolhan);
elseif strcmp(in1,'rvname') % in2 contains which row was pushed
    [YHANOLN,YHANOLP,YHANCLN,YHANCLP] = ...
            gguivar('YHANOLN','YHANOLP','YHANCLN','YHANCLP',toolhan);
        [COMPSTAT,SELECTHAN,FIGMAT,SIMWIN] = ...
        	gguivar('COMPSTAT','SELECTHAN','FIGMAT','SIMWIN',toolhan);
        namerv = scrolltb('getrvname',SELECTHAN);
        if namerv(in2) == 0 %XXXX wasnt selected but should be now
            COMPSTAT(in2-1,2) = 1;
            sguivar('COMPSTAT',COMPSTAT,toolhan);
            scrolltb('enablerow',SELECTHAN,in2); % visrows
            scrolltb('rvname2',SELECTHAN,in2,1);   % video of names
            simgui(SIMWIN,'computeenable');     % enable COMPUTE button if something is turn ON
            simgui(SIMWIN,'locredraw');
        else                    % was selected, unselect
            scrolltb('disablerow',SELECTHAN,in2);
        [CURCOORD,OLN,OLP,CLN,CLP] = gguivar('CURCOORD','OLN','OLP','CLN','CLP',toolhan);
            COMPSTAT(in2-1,2) = 0;
        if in2==2
            hand = mdxpii(YHANOLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
            if ~isempty(deladdc(OLN,CURCOORD,0))
                    COMPSTAT(in2-1,2) = 1;
            end
        elseif in2==3
            hand = mdxpii(YHANOLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
            if ~isempty(deladdc(OLP,CURCOORD,0))
                    COMPSTAT(in2-1,2) = 1;
            end
        elseif in2==4
            hand = mdxpii(YHANCLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
            if ~isempty(deladdc(CLN,CURCOORD,0))
                    COMPSTAT(in2-1,2) = 1;
            end
        elseif in2==5
            hand = mdxpii(YHANCLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
            if ~isempty(deladdc(CLP,CURCOORD,0))
                    COMPSTAT(in2-1,2) = 1;
            end
        end
            sguivar('COMPSTAT',COMPSTAT,toolhan);
            scrolltb('rvname2',SELECTHAN,in2,0);
            set(hand,'visible','off');  % need to hide all the plots
            [VISIBLE_MAT,PLTAXES] = gguivar('VISIBLE_MAT','PLTAXES',toolhan);
            VISIBLE_MAT(in2,:) = 0*VISIBLE_MAT(in2,:);
            if ~any(any(VISIBLE_MAT))
                    set(PLTAXES,'visible','off');
            end
            sguivar('VISIBLE_MAT',VISIBLE_MAT,toolhan);
        end
elseif strcmp(in1,'locredraw')
    [VISIBLE_MAT,SELECTHAN,PLTAXES,COMPSTAT] = ...
        gguivar('VISIBLE_MAT','SELECTHAN','PLTAXES','COMPSTAT',toolhan);
    [YHANOLN,YHANOLP,YHANCLN,YHANCLP,CURCOORD] = ...
        gguivar('YHANOLN','YHANOLP','YHANCLN','YHANCLP','CURCOORD',toolhan);
    [matdata,matrv,cnt,mask,visrow] = scrolltb('getstuff',SELECTHAN);

    index = find(COMPSTAT(:,1)+visrow(2:5)==2); % data available and enabled
    [rowind,colind] = find(matrv(index+1,:)==1);

    for k = 1:length(rowind)
    if index(rowind(k))==1
        hand = mdxpii(YHANOLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));
    elseif index(rowind(k))==2
        hand = mdxpii(YHANOLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));
    elseif index(rowind(k))==3
        hand = mdxpii(YHANCLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));
    elseif index(rowind(k))==4
        hand = mdxpii(YHANCLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));
    end
        [svalue,color,linestyle] = ...
            gjb2(matdata(index(rowind(k))+1,colind(k)),mask(index(rowind(k))+1,colind(k)));
        set(PLTAXES,'visible','on')
        % Suppress an HG warning about Marker and Linestyle properties
        warn_state = warning;
        warning('off');
        set(hand(colind(k)),'visible','on','color',color,'linestyle',linestyle);
        warning(warn_state);
        VISIBLE_MAT(index(rowind(k))+1,colind(k)) = 1;
    end
    sguivar('VISIBLE_MAT',VISIBLE_MAT,toolhan);

elseif strcmp(in1,'redraw')
    [VISIBLE_MAT,SELECTHAN,PLTAXES,COMPSTAT,CURCOORD] = ...
        gguivar('VISIBLE_MAT','SELECTHAN','PLTAXES','COMPSTAT','CURCOORD',toolhan);
    [YHANOLN,YHANOLP,YHANCLN,YHANCLP,CURCOORD] = ...
        gguivar('YHANOLN','YHANOLP','YHANCLN','YHANCLP','CURCOORD',toolhan);
    [matdata,matrv,cnt,mask,visrow] = scrolltb('getstuff',SELECTHAN);

    index = find(COMPSTAT(:,1)+visrow(2:5)==2); % data available and enabled
    [rowind,colind] = find(matrv(index+1,:)==1);

    for k = 1:length(rowind)
    if index(rowind(k))==1
        hand = mdxpii(YHANOLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));
    elseif index(rowind(k))==2
        hand = mdxpii(YHANOLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));
    elseif index(rowind(k))==3
        hand = mdxpii(YHANCLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));
    elseif index(rowind(k))==4
        hand = mdxpii(YHANCLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));
    end
        [svalue,color,linestyle] = ...
            gjb2(matdata(index(rowind(k))+1,colind(k)),mask(index(rowind(k))+1,colind(k)));
        set(PLTAXES,'visible','on')
        % Suppress an HG warning about Marker and Linestyle properties
        warn_state = warning;
        warning('off');
        set(hand(colind(k)),'visible','on','color',color,'linestyle',linestyle);
        warning(warn_state);
        VISIBLE_MAT(index(rowind(k))+1,colind(k)) = 1;
    end
    sguivar('VISIBLE_MAT',VISIBLE_MAT,toolhan);
elseif strcmp(in1,'ssredraw')
    [VISIBLE_MAT,SELECTHAN,COMPSTAT,DF_FONT] = ...
        gguivar('VISIBLE_MAT','SELECTHAN','COMPSTAT','DF_FONT',toolhan);
    [TITLEPIM,XLPIM,YLPIM,TFONTPIM,XFONTPIM,YFONTPIM] = ...
    gguivar('TITLEPIM','XLPIM','YLPIM','TFONTPIM','XFONTPIM','YFONTPIM',toolhan);
    [AFONTPIM,ALLFIGS] = gguivar('AFONTPIM','ALLFIGS',toolhan);

    matdata = in2;
    matrv = in3;
    mask = in4;
    visrow = in5;
    oln = in6;
    olp = in7;
    cln = in8;
    clp = in9;
    axeshan = in10;
    ijk = in11;
    tstr = mdxpii(TITLEPIM,ijk(1),ijk(2),ijk(3));
    if isempty(tstr)
        tstr = '';
    end
    xstr = mdxpii(XLPIM,ijk(1),ijk(2),ijk(3));
    if isempty(xstr)
        xstr = '';
    end
    ystr = mdxpii(YLPIM,ijk(1),ijk(2),ijk(3));
    if isempty(ystr)
        ystr = '';
    end
    tfnt = mdxpii(TFONTPIM,ijk(1),ijk(2),ijk(3));
    if isempty(tfnt)
        tfnt = DF_FONT(1);
    end
    xfnt = mdxpii(XFONTPIM,ijk(1),ijk(2),ijk(3));
    if isempty(xfnt)
        xfnt = DF_FONT(2);
    end
    yfnt = mdxpii(YFONTPIM,ijk(1),ijk(2),ijk(3));
    if isempty(yfnt)
        yfnt = DF_FONT(3);
    end
    afnt = mdxpii(AFONTPIM,ijk(1),ijk(2),ijk(3));
    if isempty(afnt)
        afnt = DF_FONT(4);
    end
    th = get(axeshan,'title');
    xh = get(axeshan,'xlabel');
    yh = get(axeshan,'ylabel');
    set(th,'string',tstr,'fontsize',tfnt);
    set(xh,'string',xstr,'fontsize',xfnt);
    set(yh,'string',ystr,'fontsize',yfnt);
    set(axeshan,'Fontsize',afnt);
    if ~isempty(visrow)
        index = find(COMPSTAT(:,1)+visrow(2:5)==2); % data available and enabled
        [rowind,colind] = find(matrv(index+1,:)==1);
    set(ALLFIGS(ijk(1)),'visible','on');

        for k = 1:length(rowind)
        if index(rowind(k)) == 1
            hand = oln;
        elseif index(rowind(k)) == 2
            hand = olp;
        elseif index(rowind(k)) == 3
            hand = cln;
        elseif index(rowind(k)) == 4
            hand = clp;
        end
        if ~isempty(hand)
                [svalue,color,linestyle] = ...
                    gjb2(matdata(index(rowind(k))+1,colind(k)),mask(index(rowind(k))+1,colind(k)));
                set(axeshan,'visible','on')
                % Suppress an HG warning about Marker and Linestyle properties
                warn_state = warning;
                warning('off');
                set(hand(colind(k)),'visible','on','color',color,'linestyle',linestyle);
                warning(warn_state);
            %   VISIBLE_MAT(index(rowind(k))+1,colind(k)) = 1;
        end
        end
    end
    %   sguivar('VISIBLE_MAT',VISIBLE_MAT);
elseif strcmp(in1,'ganged')
    [VISIBLE_MAT,PLTAXES,GGWIN] = gguivar('VISIBLE_MAT','PLTAXES','GGWIN',toolhan);
    [SELECTHAN,COMPSTAT,CURCOORD] = ...
    gguivar('SELECTHAN','COMPSTAT','CURCOORD',toolhan);
    [YHANOLN,YHANOLP,YHANCLN,YHANCLP] = ...
        gguivar('YHANOLN','YHANOLP','YHANCLN','YHANCLP',toolhan);
    [matdata,matrv,cnt,mask,visrow,GANGED] = scrolltb('getstuff',SELECTHAN);
    in2 = get(GGWIN,'value');
%if matrv(in2,in3+cnt-1)==0 % not yet highlighted, so turn on

    if in2 ~= 1 & GANGED == 1   % was GANGED, now FREE FORM (leave everything higlighted that was)
        GANGED = 0;
    elseif in2 == 1 & GANGED == 0   % was FREE FORM, now GANGED
        GANGED = 1;
        [rowhl,colhl] = find(matrv(2:5,2:size(matrv,2)) == 1);
        scrolltb('rv2',SELECTHAN,[rowhl+1 colhl+1],zeros(size(rowhl))); % unhighlight col 2-N cells
        rowhl1 = find(matrv(2:5,1) == 0);
        scrolltb('rv2',SELECTHAN,[rowhl1+1 ones(size(rowhl1))],...
              ones(size(rowhl1))); % highlight col 1 cells
        for i = 1:length(rowhl)
            if VISIBLE_MAT(rowhl(i)+1,colhl(i)+1) == 1
                VISIBLE_MAT(rowhl(i)+1,colhl(i)+1) = 0;
            end
        end
        for i = 1:4
        if i==1
        hand = mdxpii(YHANOLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
        set(hand,'visible','off')
        elseif i==2
        hand = mdxpii(YHANOLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
        set(hand,'visible','off')
        elseif i==3
        hand = mdxpii(YHANCLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
        set(hand,'visible','off')
        elseif i==4
        hand = mdxpii(YHANCLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
        set(hand,'visible','off')
        end
            if COMPSTAT(i,1) == 1 & visrow(i+1) == 1
                [svalue,color,linestyle] = gjb2(matdata(i+1,1),mask(i+1,1));
                % Suppress an HG warning about Marker and Linestyle properties
                warn_state = warning;
                warning('off');
                set(hand(1),'visible','on','color',color,'linestyle',linestyle);
                warning(warn_state);
                set(PLTAXES,'visible','on');
                VISIBLE_MAT(i+1,1) = 1;
            end
        end
    end
    scrolltb('setgff',SELECTHAN,GANGED);
    sguivar('VISIBLE_MAT',VISIBLE_MAT,toolhan);
elseif strcmp(in1,'genendata') % call back from the 1 of 4 main data_evals (P,K,D,U)
    [YHANOLN,YHANOLP,YHANCLN,YHANCLP,FIGMAT] = ...
        gguivar('YHANOLN','YHANOLP','YHANCLN','YHANCLP','FIGMAT',toolhan);
    [PLTAXES,NAMESNOTCOMP,ALLFIGS] = gguivar('PLTAXES','NAMESNOTCOMP','ALLFIGS',toolhan);
    [SELECTHAN,VISIBLE_MAT,COMPSTAT] = ...
            gguivar('SELECTHAN','VISIBLE_MAT','COMPSTAT',toolhan);
    % BTSTAT = gdataent('getbstat',gguivar('SOL_K_PER_IN'),'all');
    BTSTAT = zeros(4,1);
    BTSTAT(in2) = 1;
    if ~isempty(SELECTHAN)
    depthvec = 1:length(find(~isnan(FIGMAT(:,5))));
    % need to see if the figure exists and is a mutools SPLT window
    %% [mainw,othw,spltw] = findmuw;
      [mainw,othw,notours,spltw] = findmuw;
      spltw = xpii(spltw,gguivar('SIMWIN',toolhan));
          spltw = spltw(:,1);
    dd = [];
    for i = 1:length(depthvec)
        if any(ALLFIGS(i)==spltw)
            dd = [i; dd];
        end
    end
    depthvec = dd;
    rows = FIGMAT(depthvec,1);
    cols = FIGMAT(depthvec,2);
        if BTSTAT(1) == 1 | BTSTAT(4) == 1
        mdpimdel(YHANOLN,depthvec,rows,cols);
        mdpimdel(YHANOLP,depthvec,rows,cols);
        mdpimdel(YHANCLN,depthvec,rows,cols);
        mdpimdel(YHANCLP,depthvec,rows,cols);
        sguivar('YHANOLN',[],'YHANOLP',[],'YHANCLN',[],'YHANCLP',[],toolhan);
        sguivar('YOLN',[],'YOLP',[],'YCLN',[],'YCLP',[],toolhan);
            VISIBLE_MAT = 0*VISIBLE_MAT;
            scrolltb('namechange',SELECTHAN,NAMESNOTCOMP(2:5,:),[2:5]);
            COMPSTAT(:,1) = zeros(4,1);  %XXXX everything is out of date
        elseif BTSTAT(2) == 1
        mdpimdel(YHANCLN,depthvec,rows,cols);
        mdpimdel(YHANCLP,depthvec,rows,cols);
        sguivar('YHANCLN',[],'YHANCLP',[],toolhan);
        sguivar('YCLN',[],'YCLP',[],toolhan);
            scrolltb('namechange',SELECTHAN,NAMESNOTCOMP(4:5,:),[4:5]);
            VISIBLE_MAT(4:5,:) = 0*VISIBLE_MAT(4:5,:);
            COMPSTAT([3 4],1) = [0;0];  %XXXX closed-loop is out of date
        elseif BTSTAT(3) == 1
        mdpimdel(YHANOLP,depthvec,rows,cols);
        mdpimdel(YHANCLP,depthvec,rows,cols);
        sguivar('YHANOLP',[],'YHANCLP',[],toolhan);
        sguivar('YOLP',[],'YCLP',[],toolhan);
            scrolltb('namechange',SELECTHAN,NAMESNOTCOMP([3 5],:),[3 5]);
            VISIBLE_MAT([3 5],:) = 0*VISIBLE_MAT([3 5],:);
            COMPSTAT([2 4],1) = [0;0];  %XXXX pert is out of date
        end
        sguivar('VISIBLE_MAT',VISIBLE_MAT,toolhan);
        if ~any(any(VISIBLE_MAT))
            set(PLTAXES,'visible','off')
        end
    end
    sguivar('COMPSTAT',COMPSTAT,toolhan);
elseif strcmp(in1,'genench2')
    SIMWIN = gguivar('SIMWIN',toolhan);
    varnames = str2mat('SOLIC','CONTROLLER','PERTURBATION','INPUTSIG');
    sguivar('WHICHDATA',in2,toolhan);
    simgui(SIMWIN,'newdata',deblank(varnames(in2,:)),...
		gguivar( deblank( varnames(in2,:) ),toolhan));
    simgui(SIMWIN,'dimcheck')
    simgui(SIMWIN,'computeenable');
elseif strcmp(in1,'genench')
    SIMWIN = gguivar('SIMWIN',toolhan);
    varnames = str2mat('SOLIC','CONTROLLER','PERTURBATION','INPUTSIG');
    BTSTAT = gdataent('getbstat',gguivar('SOL_K_PER_IN',toolhan),'all');
    index = find(BTSTAT == 1);
    for i=1:length(index)
      sguivar('WHICHDATA',index(i),toolhan);
      simgui(SIMWIN,'newdata',deblank(varnames(index(i),:)),...
        	gguivar(deblank(varnames(index(i),:)),toolhan));
      simgui(SIMWIN,'dimcheck')
      simgui(SIMWIN,'computeenable');
    end
elseif strcmp(in1,'typeddata')
    [TYPEDATA,TEMP,PLTAXES,NAMESNOTCOMP,FIGMAT,SIMWIN] = ...
        gguivar('TYPEDATA','TEMP','PLTAXES','NAMESNOTCOMP','FIGMAT','SIMWIN',toolhan);
    [SELECTHAN,WHICHDATA,VISIBLE_MAT,COMPSTAT,AXESPIM] = ...
            gguivar('SELECTHAN','WHICHDATA','VISIBLE_MAT','COMPSTAT','AXESPIM',toolhan);
    if ~isempty(SELECTHAN)
        if WHICHDATA == 1 | WHICHDATA == 4 | WHICHDATA >= 5 %  XXXX, other parameters
        rowind = find(~isnan(FIGMAT(:,5)));
        for i=1:length(rowind)
            pagenum = i;
            rows    = FIGMAT(i,1);
            cols    = FIGMAT(i,2);
            for j=1:rows
                for k=1:cols
                    ah = mdxpii(AXESPIM,i,j,k);
                    delete(get(ah,'children'));
                end
            end
        end
            sguivar('YHANOLN',[],toolhan);
            sguivar('YHANOLP',[],toolhan);
            sguivar('YHANCLN',[],toolhan);
            sguivar('YHANCLP',[],toolhan);
                VISIBLE_MAT = 0*VISIBLE_MAT;
                scrolltb('namechange',SELECTHAN,NAMESNOTCOMP(2:5,:),[2:5]);
                COMPSTAT(:,1) = zeros(4,1);  %XXXX everything is out of date
        elseif WHICHDATA == 2
            delete(xpii(YHAN,3));
            delete(xpii(YHAN,4));
            YHAN =  ipii(YHAN,[],3);
            YHAN =  ipii(YHAN,[],4);
            scrolltb('namechange',SELECTHAN,NAMESNOTCOMP(4:5,:),[4:5]);
            VISIBLE_MAT(4:5,:) = 0*VISIBLE_MAT(4:5,:);
            COMPSTAT([3 4],1) = [0;0];  %XXXX closed-loop is out of date
        elseif WHICHDATA == 3
            delete(xpii(YHAN,2));
            delete(xpii(YHAN,4));
            YHAN =  ipii(YHAN,[],2);
            YHAN =  ipii(YHAN,[],4);
            scrolltb('namechange',SELECTHAN,NAMESNOTCOMP([3 5],:),[3 5]);
            VISIBLE_MAT([3 5],:) = 0*VISIBLE_MAT([3 5],:);
            COMPSTAT([2 4],1) = [0;0];  %XXXX pert is out of date
        end
    % XXXXX changed from before
        % sguivar('VISIBLE_MAT',VISIBLE_MAT);
        % if ~any(any(VISIBLE_MAT))
        %     set(PLTAXES,'visible','off')
        % end
    end
    TYPEDATA(WHICHDATA) = 1;
    sguivar('TYPEDATA',TYPEDATA,'COMPSTAT',COMPSTAT,toolhan);
    varnames = str2mat('SOLIC','CONTROLLER',...
        'PERTURBATION','INPUTSIG','TFIN','INTSS','XINITP','XINITK','XINITD','SAMPT');
    if isnan(TEMP) % callback failed
        simgui(SIMWIN,'newdata',deblank(varnames(WHICHDATA,:)),TEMP);
    elseif isinf(TEMP) & TEMP>0 % link: found
        disp('FINISHINGCALLBACK IN LINK')
    elseif isinf(TEMP) & TEMP<0 % link: not found
        disp('LINK not found')
    else
        simgui(SIMWIN,'newdata',deblank(varnames(WHICHDATA,:)),TEMP);
        simgui(SIMWIN,'dimcheck')
        simgui(SIMWIN,'computeenable');
    end
elseif strcmp(in1,'acceptlinkdata') % toolhan=handle_of_sim, in2=PIM_g in3=dr
            % can be deleted, but should be saved somewhere for future reference
    allhandles = get(toolhan,'userdata');
    VARNAMES = get(allhandles(1),'userdata');
    varname = deblank(setstr(VARNAMES(:,in2)'))
    whichdata = find(abs(varname(1))==abs(['SCPI']))
    sguivar('WHICHDATA',whichdata,toolhan);
    simgui(toolhan,'newdata',varname,in3);
    simgui(toolhan,'dimcheck')
    simgui(toolhan,'computeenable');
    % MORE USER CODE goes here in acceptlinkdata
elseif strcmp(in1,'pb')
    [VISIBLE_MAT,PLTAXES] = gguivar('VISIBLE_MAT','PLTAXES',toolhan);
    [SELECTHAN,COMPSTAT,EDITING,CURCOORD] = ...
    gguivar('SELECTHAN','COMPSTAT','EDITING','CURCOORD',toolhan);
    [YHANOLN,YHANOLP,YHANCLN,YHANCLP] = ...
        gguivar('YHANOLN','YHANOLP','YHANCLN','YHANCLP',toolhan);

    [data,matrv,cnt,mask,visrow,GANGED] = scrolltb('getstuff',SELECTHAN);

    if EDITING == 0     % in pushbutton mode
        if GANGED == 0  % unganged, no loop
        if in2==2
        hand = mdxpii(YHANOLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
        elseif in2==3
        hand = mdxpii(YHANOLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
        elseif in2==4
        hand = mdxpii(YHANCLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
        elseif in2==5
        hand = mdxpii(YHANCLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
        end
            if matrv(in2,in3+cnt-1)==0 % not yet highlighted, so turn on
                if COMPSTAT(in2-1,1) == 1 & visrow(in2) == 1 % HAVE & WANT
                    [svalue,color,linestyle] = gjb2(data(in2,in3+cnt-1),mask(in2,in3+cnt-1));
                    set(PLTAXES,'visible','on')
                    % Suppress an HG warning about Marker and Linestyle properties
                    warn_state = warning;
                    warning('off');
                    set(hand(in3+cnt-1),'visible','on','color',color,'linestyle',linestyle);
                    warning(warn_state);
                    VISIBLE_MAT(in2,in3+cnt-1) = 1;
                end
                scrolltb('rv2',SELECTHAN,[in2 in3+cnt-1],1); % update table (local..)
            else % was highlighted, now turn off
                if COMPSTAT(in2-1,1) == 1
                    set(hand(in3+cnt-1),'visible','off')
                    VISIBLE_MAT(in2,in3+cnt-1) = 0;
                    if ~any(any(VISIBLE_MAT))
                        set(PLTAXES,'visible','off')
                    end
                end
                scrolltb('rv2',SELECTHAN,[in2 in3+cnt-1],0); % update table (local..)
            end
        else     % if GANGED == 1, talking about a whole column (in3)
            if matrv(in2,in3+cnt-1)==0 % this column wasn't yet highlighted, continue
                hc = find(sum(matrv(2:5,:))>0); % columns that are highlighted (ganged mode)
                for i=1:4
                if i==1
            hand = mdxpii(YHANOLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));
                elseif i==2
            hand = mdxpii(YHANOLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));
                elseif i==3
            hand = mdxpii(YHANCLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));
                elseif i==4
            hand = mdxpii(YHANCLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));
                end
                    if COMPSTAT(i,1) == 1 & visrow(i+1) == 1
                        [svalue,color,linestyle] = gjb2(data(i+1,in3+cnt-1),...
                            mask(i+1,in3+cnt-1));
                        set(PLTAXES,'visible','on')
                        % Suppress an HG warning about Marker and Linestyle properties
                        warn_state = warning;
                        warning('off');
                        set(hand(in3+cnt-1),'visible','on',...
                'color',color,'linestyle',linestyle);
                        warning(warn_state);
                        VISIBLE_MAT(i+1,in3+cnt-1) = 1;
                        set(hand(hc),'visible','off');
                        VISIBLE_MAT(i+1,hc) = 0;
                    end
                    scrolltb('rv2',SELECTHAN,...
            [i+1 in3+cnt-1;i+1 hc],[1;0]);   % update table/MATRV
                end
            else
                set(get(gcf,'currentobject'),'value',1); % change for checkbox
            end
        end
        sguivar('VISIBLE_MAT',VISIBLE_MAT,toolhan);
    elseif EDITING == 1         % edit mode
    if in2==2
        hand = mdxpii(YHANOLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
    elseif in2==3
        hand = mdxpii(YHANOLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
    elseif in2==4
        hand = mdxpii(YHANCLN,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
    elseif in2==5
        hand = mdxpii(YHANCLP,CURCOORD(1),CURCOORD(2),CURCOORD(3));;
    end
        co = get(gcf,'currentobject');
        se = get(co,'string');
        [svalue,color,linestyle] = gjb2(se,2);
        if ~isempty(svalue)
            data(in2,cnt+in3-1) = svalue;
            scrolltb('newdata',SELECTHAN,data,mask);
            set(co,'string',deblank(se));
            if COMPSTAT(in2-1,1) == 1
                % Suppress an HG warning about Marker and Linestyle properties
                warn_state = warning;
                warning('off');
                set(hand(in3+cnt-1),'color',color,'linestyle',linestyle);
                warning(warn_state);
            end
        else
            set(co,'string',gjb2(data(in2,cnt+in3-1),2));
        end
    end
elseif strcmp(in1,'newdata')
    sguivar('FRESH',0,toolhan);
    sguivar(in2,in3,toolhan);
    [LOADSTAT,SOLIC,CONTROLLER,PERTURBATION,INPUTSIG,WHICHDATA] =...
        gguivar('LOADSTAT','SOLIC','CONTROLLER',...
        'PERTURBATION','INPUTSIG','WHICHDATA',toolhan);
    [TFIN,INTSS,SAMPT,XINITP,XINITK,XINITD] = ...
         gguivar('TFIN','INTSS','SAMPT','XINITP','XINITK','XINITD',toolhan);
    if WHICHDATA==1
        [mtype,mrows,mcols,mnum] = minfo(SOLIC);
        if (strcmp(mtype,'syst') | strcmp(mtype,'cons')) & ~isnan(SOLIC)
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,1) = 0;
            set(gguivar('MESSAGE',toolhan),'string','Plant Variable: Incorrect Type');
        end
    elseif WHICHDATA==2
        [mtype,mrows,mcols,mnum] = minfo(CONTROLLER);
        if (strcmp(mtype,'syst') | strcmp(mtype,'cons')) & ~isnan(CONTROLLER)
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        elseif strcmp(mtype,'empt')
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','CONTROLLER Variable: Incorrect Type');
        end
    elseif WHICHDATA==3
        [mtype,mrows,mcols,mnum] = minfo(PERTURBATION);
        if (strcmp(mtype,'syst') | strcmp(mtype,'cons')) & ~isnan(PERTURBATION)
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        elseif strcmp(mtype,'empt')
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','Perturbation Variable: Incorrect Type');
        end
    elseif WHICHDATA==4
        [mtype,mrows,mcols,mnum] = minfo(INPUTSIG);
        if (strcmp(mtype,'vary') | strcmp(mtype,'cons')) & ~isnan(INPUTSIG)
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','Input Signal Variable: Incorrect Type');
        end
    elseif WHICHDATA==5
        [mtype,mrows,mcols,mnum] = minfo(TFIN);
        if strcmp(mtype,'cons') & mrows==1 & mcols == 1
            if TFIN(1,1)>0
                LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
                set(gguivar('MESSAGE',toolhan),'string',' ');
                set(gguivar('MESS_PARM',toolhan),'string',' ');
            else
                LOADSTAT(WHICHDATA,:) = zeros(1,4);
                set(gguivar('MESSAGE',toolhan),'string','Final Time Should be Positive');
                set(gguivar('MESS_PARM',toolhan),'string','Final Time Should be Positive');
            end
        elseif strcmp(mtype,'empt')
            LOADSTAT(WHICHDATA,:) = [2 0 0 0];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','Final Time: Incorrect Type');
            set(gguivar('MESS_PARM',toolhan),'string','Final Time: Incorrect Type');
        end
    elseif WHICHDATA==6
        [mtype,mrows,mcols,mnum] = minfo(INTSS);
        if strcmp(mtype,'cons') & mrows==1 & mcols == 1
            if INTSS(1,1)>0
                LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
                set(gguivar('MESSAGE',toolhan),'string',' ');
                set(gguivar('MESS_PARM',toolhan),'string',' ');
            else
                LOADSTAT(WHICHDATA,:) = zeros(1,4);
                set(gguivar('MESSAGE',toolhan),'string','Step Size Should be Positive');
                set(gguivar('MESS_PARM',toolhan),'string','Step Size Should be Positive');
            end
        elseif strcmp(mtype,'empt')
            LOADSTAT(WHICHDATA,:) = [2 0 0 0];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','Integration Step: Incorrect Type');
            set(gguivar('MESS_PARM',toolhan),'string','Integration Step: Incorrect Type');
        end
    elseif WHICHDATA==7
        [mtype,mrows,mcols,mnum] = minfo(XINITP);
        if strcmp(mtype,'cons') & mcols == 1
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        elseif strcmp(mtype,'empt')
            LOADSTAT(WHICHDATA,:) = [2 0 0 0];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','Plant Initial Condition: Incorrect Type');
            set(gguivar('MESS_PARM',toolhan),'string','Plant Initial Condition: Incorrect Type');
        end
    elseif WHICHDATA==8
        [mtype,mrows,mcols,mnum] = minfo(XINITK);
        if strcmp(mtype,'cons') & mcols == 1
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        elseif strcmp(mtype,'empt')
            LOADSTAT(WHICHDATA,:) = [2 0 0 0];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','Controller Initial Condition: Incorrect Type');
            set(gguivar('MESS_PARM',toolhan),'string','Controller Initial Condition: Incorrect Type');
        end
    elseif WHICHDATA==9
        [mtype,mrows,mcols,mnum] = minfo(XINITD);
        if strcmp(mtype,'cons') & mcols == 1
            LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        elseif strcmp(mtype,'empt')
            LOADSTAT(WHICHDATA,:) = [2 0 0 0];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','Perturbation Initial Condition: Incorrect Type');
            set(gguivar('MESS_PARM',toolhan),'string','Perturbation Initial Condition: Incorrect Type');
        end
    elseif WHICHDATA==10
        [mtype,mrows,mcols,mnum] = minfo(SAMPT);
        if strcmp(mtype,'cons') & mrows==1 & mcols == 1
            if SAMPT>0
                LOADSTAT(WHICHDATA,:) = [2 mrows mcols mnum];
                set(gguivar('MESSAGE',toolhan),'string',' ');
                set(gguivar('MESS_PARM',toolhan),'string',' ');
            else
                LOADSTAT(WHICHDATA,:) = zeros(1,4);
                set(gguivar('MESSAGE',toolhan),'string','Sample Time Should be Positive');
                set(gguivar('MESS_PARM',toolhan),'string','Sample Time Should be Positive');
            end
        elseif strcmp(mtype,'empt')
            LOADSTAT(WHICHDATA,:) = [2 0 0 0];
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
        else
            LOADSTAT(WHICHDATA,:) = zeros(1,4);
            set(gguivar('MESSAGE',toolhan),'string','Sample Time: Incorrect Type');
            set(gguivar('MESS_PARM',toolhan),'string','Sample Time: Incorrect Type');
        end
    end
    drawnow;
    sguivar('LOADSTAT',LOADSTAT,toolhan);
elseif strcmp(in1,'dimcheck')
    [SIMWIN,LOADSTAT] = gguivar('SIMWIN','LOADSTAT',toolhan);
    % Moved these up one level to remove warnings at line 2059  GJW 09/11/96
    failstring = '';
    failflg = 0;
    if all(LOADSTAT(:,1)==2)
        if LOADSTAT(1,4)~=LOADSTAT(7,2) & LOADSTAT(7,2)>0
            failstring = [failstring 'Error: Incorrect Plant Initial Condition'];
            failflg = 1;
        end
        if LOADSTAT(2,4)~=LOADSTAT(8,2) & LOADSTAT(8,2)>0
            failstring = [failstring 'Error: Incorrect Controller Initial Condition'];
            failflg = 1;
        end
        if LOADSTAT(3,4)~=LOADSTAT(9,2) & LOADSTAT(9,2)>0
            failstring = [failstring 'Error: Incorrect Perturbation Initial Condition'];
            failflg = 1;
        end
        if sum(LOADSTAT([2:4],2))~=LOADSTAT(1,3)
            failstring = [failstring 'Error: Plant Inputs  '];
            failflg = 2;
        end
        if LOADSTAT(4,3)~=1
            failstring = [failstring 'Error: INPUT_SIG needs 1 Column  '];
            failflg = 2;
        end
        if LOADSTAT(1,2)<=sum(LOADSTAT([2 3],3))
            failstring = [failstring 'Error: No OUTPUTS  '];
            failflg = 2;
        end
        if failflg == 0
            [ALLTABHAN,DONEEDITHAN] = gguivar('ALLTABHAN','DONEEDITHAN',toolhan);
            dd = [];
            numout = LOADSTAT(1,2)-sum(LOADSTAT([2 3],3));
            if ~isempty(ALLTABHAN)
                SELECTHAN = gguivar('SELECTHAN',toolhan);
                [data,matrv,cnt,mask] = scrolltb('getstuff',SELECTHAN);
                oldoutdim = size(data,2);
                if numout ~= oldoutdim
                    simgui(SIMWIN,'deletetable');
                    dd = 'c';
                end
            else
                dd = 'c';
            end
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
            drawnow;
            sguivar('DIMREADY',1,toolhan);
            if strcmp(dd,'c')
                simgui(SIMWIN,'createtable');
            end
        elseif failflg == 1
            sguivar('DIMREADY',0,toolhan);
            set(gguivar('MESSAGE',toolhan),'string',failstring);
            set(gguivar('MESS_PARM',toolhan),'string',failstring);
            drawnow;
        elseif failflg == 2
            sguivar('DIMREADY',0,toolhan);
            set(gguivar('MESSAGE',toolhan),'string',failstring);
            set(gguivar('MESS_PARM',toolhan),'string',failstring);
            drawnow;
            simgui(SIMWIN,'deletetable');
        end
    else
        if LOADSTAT(1,4)~=LOADSTAT(7,2) & LOADSTAT(7,2)>0 & LOADSTAT(1,1) == 2
            failstring = [failstring 'Error: Incorrect Plant Initial Condition'];
            failflg = 1;
        end
        if LOADSTAT(2,4)~=LOADSTAT(8,2) & LOADSTAT(8,2)>0 & LOADSTAT(2,1) == 2
            failstring = [failstring 'Error: Incorrect Controller Initial Condition'];
            failflg = 1;
        end
        if LOADSTAT(3,4)~=LOADSTAT(9,2) & LOADSTAT(9,2)>0 & LOADSTAT(3,1) == 2
            failstring = [failstring 'Error: Incorrect Perturbation Initial Condition'];
            failflg = 1;
        end
        if failflg == 1
            sguivar('DIMREADY',0,toolhan);
            set(gguivar('MESSAGE',toolhan),'string',failstring);
            set(gguivar('MESS_PARM',toolhan),'string',failstring);
            drawnow;
        elseif failflg == 0
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
            drawnow;
        end
    end
    TYPEDATA = gguivar('TYPEDATA',toolhan);
%    if all(TYPEDATA(1:4))
%        set(gguivar('REFRESHHAN',toolhan),'enable','on')
%    end
elseif strcmp(in1,'createtable')
    set(gguivar('MESSAGE',toolhan),'string','Setting up Plots and Line Type Table ');
    drawnow
    [SIMWIN,LOADSTAT] = gguivar('SIMWIN','LOADSTAT',toolhan);
    bw = 60; th = 20; bth = -14; tth = 20; nw = 200; bbw = 30;
    xbo = 4; sgap = 3; tgap = 3; bgap = 3;
    dgap = 3; hgap = 3; ytopbo = 5; ybotbo = 5; scroll_lim = 1;

    numout = LOADSTAT(1,2)-sum(LOADSTAT([2 3],3));
    numcols = min([4 numout]);
    if numout <= 4
        bth = 0;
    end
    [SIMWIN,TABLELOC,NAMESCOMP,NAMESNOTCOMP,ORIGWINPOS] = ...
        gguivar('SIMWIN','TABLELOC','NAMESCOMP','NAMESNOTCOMP','ORIGWINPOS',toolhan);
    winunits = get(SIMWIN,'units');
    if ~strcmp('pixels',winunits)
        set(SIMWIN,'units','pixels')
    end
    winpos = get(SIMWIN,'position');
    wf = winpos(3)/ORIGWINPOS(3);
    hf = winpos(4)/ORIGWINPOS(4);
    dimvec_plt = [bw*wf;th*hf;bth*hf;tth*hf;nw*wf;bbw*wf;xbo*wf;numcols;...
        sgap*hf;tgap*hf;bgap*hf;dgap*wf;hgap*hf;ytopbo*hf;ybotbo*hf;scroll_lim];

    cb1 = ['simgui(' thstr ',''pb'','];
    cb2 = ['simgui(' thstr ',''rvname'','];
    type1 = 'checkbox';
    [pos_plt] = ...
        scrolltb('dimquery','Plots and LineTypes',...
        NAMESNOTCOMP,...
        str2mat('text',type1,type1,type1,type1),...
        str2mat('rand(',cb1,cb1,cb1,cb1),...
        str2mat('rand(',cb1,cb1,cb1,cb1),...
        str2mat('text',type1,type1,type1,type1),...
        str2mat('rand(',cb2,cb2,cb2,cb2),...
                0,0,SIMWIN,dimvec_plt);
    llx = wf*TABLELOC(1);
    lly = hf*TABLELOC(2) - pos_plt(4);
    dbw = wf*80;
    dbh = hf*18;
    dbx = llx + pos_plt(3) - dbw - wf*6;
    dby = lly + pos_plt(4) - dbh - hf*6;
    [SELECTHAN,exhan,ALLTABHAN,table_han] = ...
        scrolltb('create','Plots and LineTypes',NAMESNOTCOMP,...
        str2mat('text',type1,type1,type1,type1),...
        str2mat('rand(',cb1,cb1,cb1,cb1),...
        str2mat('rand(',cb1,cb1,cb1,cb1),...
        str2mat('text',type1,type1,type1,type1),...
        str2mat('rand(',cb2,cb2,cb2,cb2),...
        llx,lly,SIMWIN,dimvec_plt);
    scrolltb('normalized',SELECTHAN);
    set(exhan(6),'style','text');   % change top_row OUTPUT CHANNELS to static text
%   set up the MASK matrix and the color/line type matrices to be put in the
%   color/line type table
    sguivar('VISIBLE_MAT',zeros(5,numout),'DIMKNOWN',1,toolhan);
    MASK = [zeros(1,numout); 2*ones(4,numout)];
    MATDATA = [1:numout;...            % row numbers
        121045000*ones(1,numout); ...  % yellow, solid
        114045045*ones(1,numout); ...  % red, dashed
        109058000*ones(1,numout); ...  % magenta, dotted
        119045046*ones(1,numout)];     % white, dashed-dotted
    scrolltb('firstdata',SELECTHAN,MATDATA,MASK);
%   highlights the 1st column, corresponding to GANGED = 1
    scrolltb('rv2',SELECTHAN,[2 1;3 1;4 1;5 1],ones(4,1));
    scrolltb('refill2',SELECTHAN);
    scrolltb('disablerow',SELECTHAN,2:5);
    [DF_MATDATA,DF_MATRV,DF_CNT,DF_MASK,DF_VISROW,DF_GROUPFF] = scrolltb('getstuff',SELECTHAN);
    sguivar('DF_MATDATA',DF_MATDATA,'DF_MATRV',DF_MATRV,'DF_CNT',DF_CNT,...
    'DF_MASK',DF_MASK,'DF_VISROW',DF_VISROW,'DF_GROUPFF',DF_GROUPFF,toolhan);
%   check to see if the scroll table was setup before
    [CURCOORD] = gguivar('CURCOORD',toolhan);
    [MASKPIM,MATDATAPIM,MATRVPIM,CNTPIM,VISROWPIM,GROUPFFPIM] = ...
        gguivar('MASKPIM','MATDATAPIM','MATRVPIM','CNTPIM','VISROWPIM','GROUPFFPIM',toolhan);
    pagenum = CURCOORD(1);
    rownum  = CURCOORD(2);
    colnum  = CURCOORD(3);
    mask    = mdxpii(MASKPIM,pagenum,rownum,colnum);
    if ~isempty(mask)
        matdata = mdxpii(MATDATAPIM,pagenum,rownum,colnum);
        matrv   = mdxpii(MATRVPIM,pagenum,rownum,colnum);
        cnt     = mdxpii(CNTPIM,pagenum,rownum,colnum);
        visrow  = mdxpii(VISROWPIM,pagenum,rownum,colnum);
        gff     = mdxpii(GROUPFFPIM,pagenum,rownum,colnum);
                lnoutputs = size(matdata,2);
                if numout<lnoutputs
                    mask    = mask(:,1:numout);
                    matdata = matdata(:,1:numout);
            matrv   = matrv(:,1:numout);
            if cnt>numout
                cnt = 1;
            end
        elseif numout>lnoutputs
            mask    = [mask DF_MASK(:,lnoutputs+1:numout)];
            matdata = [matdata DF_MATDATA(:,lnoutputs+1:numout)];
            matrv   = [matrv DF_MATRV(:,lnoutputs+1:numout)];
                end
        scrolltb('setstuff',SELECTHAN,matdata,matrv,cnt,mask,visrow,gff);
        scrolltb('refill2',SELECTHAN);
        scrolltb('enablerow',SELECTHAN,find(visrow==1));
        scrolltb('setrvname2',SELECTHAN,[0;visrow(2:5)]);
        scrolltb('updateslid',SELECTHAN);
        if gff == 0 % freeform
            set(GGWIN,'value',2);
        else
            set(GGWIN,'value',1);
        end
    end
%       create the done edit button
    DONEEDITHAN = uicontrol(SIMWIN,'style',...
        'pushbutton','position',[dbx dby dbw dbh],...
        'visible','off',...
        'callback',['simgui(' thstr ',''doneedit'');'],...
        'String','Done Edit');
    sguivar('DONEEDITHAN',DONEEDITHAN,...
        'SELECTHAN',SELECTHAN,'ALLTABHAN',ALLTABHAN,toolhan);
    sguivar('FRESH',0,toolhan);                 % XXX new way
    %sguivar('FRESH',0,'COMPSTAT',zeros(4,2));      % XXX old way
    set(gguivar('COLORMENU',toolhan),'enable','on');
    set(gguivar('MESSAGE',toolhan),'string',' ');
    set(gguivar('MESS_PARM',toolhan),'string',' ');
%% Put a popup Ganged/Free-form buttons on the scroll table
    gff_bw = 100;
    gff_bh = 20;
    GGWIN = uicontrol('style','popup',...
        'String','Grouped|Free Form',...
            'position',[llx+pos_plt(1)+5 lly+pos_plt(2)+pos_plt(4)-26 gff_bw gff_bh],...
             'callback',['simgui(' thstr ',''ganged'')']);
    set(DONEEDITHAN,'units','normalized');
    set(GGWIN,'units','normalized');
    sguivar('GGWIN',GGWIN,toolhan);
elseif strcmp(in1,'deletetable')
    [ALLTABHAN,DONEEDITHAN,GGWIN] = gguivar('ALLTABHAN','DONEEDITHAN','GGWIN',toolhan);
    if ~isempty(ALLTABHAN)
        delete(ALLTABHAN);
        delete(DONEEDITHAN);
        delete(GGWIN);
        sguivar('SELECTHAN',[],'GGWIN',[],'ALLTABHAN',[],'DONEEDITHAN',[],toolhan);
        set(gguivar('COLORMENU',toolhan),'enable','off');
    end
elseif strcmp(in1,'defaultcolor')
    [SIMWIN,VISIBLE_MAT,SELECTHAN] = gguivar('SIMWIN','VISIBLE_MAT','SELECTHAN',toolhan);
    numout = size(VISIBLE_MAT,2);
    [data,matrv,cnt,mask] = scrolltb('getstuff',SELECTHAN);
    MATDATA = [1:numout;...            % row numbers
        121045000*ones(1,numout); ...  % yellow, solid
        114045045*ones(1,numout); ...  % red, dashed
        109058000*ones(1,numout); ...  % magenta, dotted
        119045046*ones(1,numout)];     % white, dashed-dotted
    scrolltb('newdata',SELECTHAN,MATDATA,mask);
    scrolltb('refill2',SELECTHAN);
    simgui(SIMWIN,'redraw'); % HELP, NEXT 4 PROBABALY ALL SAME FIX
elseif strcmp(in1,'defaultbw')
    [SIMWIN,VISIBLE_MAT,SELECTHAN] = gguivar('SIMWIN','VISIBLE_MAT','SELECTHAN',toolhan);
    numout = size(VISIBLE_MAT,2);
    [data,matrv,cnt,mask] = scrolltb('getstuff',SELECTHAN);
    MATDATA = [1:numout;...            % row numbers
        119045000*ones(1,numout); ...  % white, solid
        119045045*ones(1,numout); ...  % white, dashed
        119058000*ones(1,numout); ...  % white, dotted
        119045046*ones(1,numout)];     % white, dashed-dotted
    scrolltb('newdata',SELECTHAN,MATDATA,mask);
    scrolltb('refill2',SELECTHAN);
    simgui(SIMWIN,'redraw'); % HELP
elseif strcmp(in1,'defaultclrsym')
    [SIMWIN,VISIBLE_MAT,SELECTHAN] = gguivar('SIMWIN','VISIBLE_MAT','SELECTHAN',toolhan);
    numout = size(VISIBLE_MAT,2);
    [data,matrv,cnt,mask] = scrolltb('getstuff',SELECTHAN);
    MATDATA = [1:numout;...            % row numbers
        121120000*ones(1,numout); ...  % yellow, x
        114042000*ones(1,numout); ...  % red,    *
        109043000*ones(1,numout); ...  % magenta, +
        119111000*ones(1,numout)];     % white,   o
    scrolltb('newdata',SELECTHAN,MATDATA,mask);
    scrolltb('refill2',SELECTHAN);
    simgui(SIMWIN,'redraw'); % HELP
elseif strcmp(in1,'defaultbwsym')
    [SIMWIN,VISIBLE_MAT,SELECTHAN] = gguivar('SIMWIN','VISIBLE_MAT','SELECTHAN',toolhan);
    numout = size(VISIBLE_MAT,2);
    [data,matrv,cnt,mask] = scrolltb('getstuff',SELECTHAN);
    MATDATA = [1:numout;...            % row numbers
        119120000*ones(1,numout); ...  % white, x
        119042000*ones(1,numout); ...  % white, *
        119043000*ones(1,numout); ...  % white, +
        119111000*ones(1,numout)];     % white, o
    scrolltb('newdata',SELECTHAN,MATDATA,mask);
    scrolltb('refill2',SELECTHAN);
    simgui(SIMWIN,'redraw'); % HELP
elseif strcmp(in1,'hidemain')
    set(gguivar('SIMWIN',toolhan),'visible','off');
elseif strcmp(in1,'showmain')
    SIMWIN = gguivar('SIMWIN',toolhan);
    figure(SIMWIN);
    set(SIMWIN,'visible','on');
elseif strcmp(in1,'showplotwin');
    ALLFIGS = gguivar('ALLFIGS',toolhan);
    %% [mainw,othw,spltw] = findmuw;
      [mainw,othw,notours,spltw] = findmuw;
      spltw = xpii(spltw,gguivar('SIMWIN',toolhan));
      spltw = spltw(:,1);
    if any(ALLFIGS(in2)==spltw)
        figure(ALLFIGS(in2));
        set(ALLFIGS(in2),'visible','on');
    else
    ALLFIGS(in2) = nan;
    % redo all the plotmenus
    end
elseif strcmp(in1,'hideplotwin');
    ALLFIGS = gguivar('ALLFIGS',toolhan);
    set(ALLFIGS(in2),'visible','off');
elseif strcmp(in1,'showparmwin');
    PARMWIN = gguivar('PARMWIN',toolhan);
    figure(PARMWIN);
    set(PARMWIN,'visible','on');
elseif strcmp(in1,'hideparmwin');
    set(gguivar('PARMWIN',toolhan),'visible','off');
elseif strcmp(in1,'namecb')
    if nargin==2
        co = get(gcf,'currentobject');
        UDNAME = get(co,'string');
        sguivar('UDNAME',UDNAME,toolhan);
    else
    UDNAME = gguivar('UDNAME',toolhan);
    end
    wsuff = UDNAME;
    if ~isempty(UDNAME)
    if ~isempty(deblank(UDNAME))
            wsuff = [' - ' UDNAME];
        end
    end
    [SIMWIN,PARMWIN,ALLFIGS] = gguivar('SIMWIN','PARMWIN','ALLFIGS',toolhan);
    set(SIMWIN,'name',['muTools(',int2str(SIMWIN),'): Simulation Tool' wsuff]);
    set(PARMWIN,'name',['muTools(',int2str(PARMWIN),'): Simulation Parameters' wsuff]);
    npages = find(~isnan(ALLFIGS));
    for i=1:length(npages)
    set(ALLFIGS(i),'name',...
     ['muTools(',int2str(ALLFIGS(i)),'): Simulation Plot Page#' int2str(i) wsuff]);
    end
 elseif strcmp(in1,'sufcb')
    co = get(gcf,'currentobject');
    val = get(co,'string');
    sp = find(val~=' ');
    if length(sp) < length(val)
        val = val(sp);
        set(co,'string',val);
    end
    sguivar('SUFFIXNAME',val,toolhan);
elseif strcmp(in1,'rtc')
    [COMPSTAT,COMPUTEHAN,LOADSTAT] = ...
         gguivar('COMPSTAT','COMPUTEHAN','LOADSTAT',toolhan);
    tmp = find(COMPSTAT(:,1) == 0 & COMPSTAT(:,2) == 1);
    tmp1 = find(LOADSTAT(:,1)==0);
    if ~isempty(tmp) & isempty(tmp1)
        set(gguivar('MESSAGE',toolhan),'string','Ready to Simulate');
        drawnow
        set(gguivar('STOPHAN',toolhan),'visible','off');
        set(gguivar('COMPUTEHAN',toolhan),'enable','on','visible','on');
    end
elseif strcmp(in1,'changepagenum')
    [SIMWIN,PRCHAN,FIGMAT,ALLFIGS,APPLYBUT,SELECTHAN] = ...
        gguivar('SIMWIN','PRCHAN','FIGMAT','ALLFIGS','APPLYBUT','SELECTHAN',toolhan);
    stdata = get(PRCHAN(3),'userdata');
    rehans = stdata(11);
    stdata = get(PRCHAN(4),'userdata');
    cehans = stdata(11);
    pages = updownb('getvals',PRCHAN(1));
    LASTCOORD = [pages(2) FIGMAT(pages(2),3:4)];
    CURCOORD = [pages(1) FIGMAT(pages(1),3:4)];
    if any(LASTCOORD~=CURCOORD)
        % makes 1:pages(1) all "active" figures
        FIGMAT(1:pages(1),5) = ones(pages(1),1);

        updownb2('setval1',PRCHAN(3),FIGMAT(pages(1),3));
        updownb2('setetxt1',PRCHAN(3),int2str(FIGMAT(pages(1),3)));
        updownb2('setmaxval',PRCHAN(3),FIGMAT(pages(1),1));
        updownb2('setval1',PRCHAN(4),FIGMAT(pages(1),4));
        updownb2('setetxt1',PRCHAN(4),int2str(FIGMAT(pages(1),4)));
        updownb2('setmaxval',PRCHAN(4),FIGMAT(pages(1),2));
        set(APPLYBUT,'visible','off');
        set(rehans,'string',int2str(FIGMAT(pages(1),1)));
        set(cehans,'string',int2str(FIGMAT(pages(1),2)));
        sguivar('LASTCOORD',LASTCOORD,'CURCOORD',CURCOORD,...
                'FIGMAT',FIGMAT,toolhan);
        simgui(SIMWIN,'updatelab');
        if isnan(ALLFIGS(pages(1)))
            simgui(SIMWIN,'addpage',pages(1));
            if ~isempty(SELECTHAN)
                simgui(SIMWIN,'refreshpage',pages(1),...
                      FIGMAT(pages(1),3),FIGMAT(pages(1),4))
                scrolltb('updateslid',SELECTHAN);
            end
        else
            % need to put a test to see if the pages(1) window exists
            %  and is a SIMGUI plot window
                %% [mainw,othw,spltw] = findmuw;
                  [mainw,othw,notours,spltw] = findmuw;
                  spltw = xpii(spltw,gguivar('SIMWIN',toolhan));
                  spltw = spltw(:,1);
            if any(ALLFIGS(pages(1))==spltw)
                figure(ALLFIGS(pages(1)));
                if ~isempty(SELECTHAN)
                    scrolltb('updateslid',SELECTHAN);
                end
            else
                PLTMENU = gguivar('PLTMENU',toolhan);
                PLTMENU(pages(1)+2) = -1;
                sguivar('PLTMENU',PLTMENU,toolhan);
                ALLFIGS(pages(1)) = nan;
                simgui(SIMWIN,'addpage',pages(1));
                if ~isempty(SELECTHAN)
                    simgui(SIMWIN,'refreshpage',pages(1),...
                        FIGMAT(pages(1),1),FIGMAT(pages(1),2))
% OLD: cols 3 and 4 correspond to LAST COORDINATE of rows and cols
%                        FIGMAT(pages(1),3),FIGMAT(pages(1),4))
                    scrolltb('updateslid',SELECTHAN);
                end
            end
        end
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
    else
            set(gguivar('MESSAGE',toolhan),...
            'string','Page number remained the same');
    end
elseif strcmp(in1,'rowcol_nwet')            % changed for updownb2
    [PRCHAN,FIGMAT] = gguivar('PRCHAN','FIGMAT',toolhan);
    if in2 == 1         % rows
        stdata = get(PRCHAN(3),'userdata');
    elseif in2 == 2         % cols
        stdata = get(PRCHAN(4),'userdata');
    end
    strhan = stdata(11);
    data = get(strhan,'string');
    number = round(str2double(data));
    set(strhan,'string',int2str(number));
    ok = 1;
    if ok % error checking
        set(gguivar('APPLYBUT',toolhan),'visible','on');
    end
elseif strcmp(in1,'applyrc')
    [SIMWIN,PRCHAN,FIGMAT] = gguivar('SIMWIN','PRCHAN','FIGMAT',toolhan);
    pagenum = updownb('getval',PRCHAN(1));
    rehans2 = get(PRCHAN(3),'userdata');
    strhanrow = rehans2(11);
    cehans2 = get(PRCHAN(4),'userdata');
    strhancol = cehans2(11);
    data1 = get(strhanrow,'string');
    number1 = round(str2double(data1));
    data2 = get(strhancol,'string');
    number2 = round(str2double(data2));
    rcnth = PRCHAN(3);
    ccnth = PRCHAN(4);
    updownb2('setmaxval',rcnth,number1)
    updownb2('setmaxval',ccnth,number2)
    cb = str2mat('changerownum','changecolnum');
    if updownb2('getval1',rcnth) > number1
        updownb2('setval1',rcnth,number1);
        updownb2('setetxt1',rcnth,int2str(number1));
        simgui(SIMWIN,'changerownum');
        FIGMAT(pagenum,3) = number1;
    end
    if updownb2('getval1',ccnth) > number2
        updownb2('setval1',ccnth,number2);
        updownb2('setetxt1',ccnth,int2str(number2));
        simgui(SIMWIN,'changecolnum');
        FIGMAT(pagenum,4) = number2;
    end
    FIGMAT(pagenum,[1 2]) = [number1 number2];
    sguivar('FIGMAT',FIGMAT,toolhan);
    set(gguivar('APPLYBUT',toolhan),'visible','off');
    simgui(SIMWIN,'refreshpage',pagenum,number1,number2)
elseif strcmp(in1,'changerownum')
    [SIMWIN,PRCHAN,FIGMAT] = gguivar('SIMWIN','PRCHAN','FIGMAT',toolhan);
    rows = updownb2('getvals1',PRCHAN(3));
    newrow = rows(1);
    pagenum = updownb('getval',PRCHAN(1));
    LASTCOORD = [pagenum rows(2) FIGMAT(pagenum,4)];
    CURCOORD = [pagenum rows(1) FIGMAT(pagenum,4)];
    if any(LASTCOORD~=CURCOORD)
        FIGMAT(pagenum,3) = newrow;
        sguivar('FIGMAT',FIGMAT,'LASTCOORD',LASTCOORD,...
                'CURCOORD',CURCOORD,toolhan);
        simgui(SIMWIN,'updatelab');
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
    else
            set(gguivar('MESSAGE',toolhan),...
            'string','Row number remained the same');
    end
elseif strcmp(in1,'changecolnum')
    [SIMWIN,PRCHAN,FIGMAT] = gguivar('SIMWIN','PRCHAN','FIGMAT',toolhan);
    cols = updownb2('getvals1',PRCHAN(4));
    newcol = cols(1);
    pagenum = updownb('getval',PRCHAN(1));
    LASTCOORD = [pagenum FIGMAT(pagenum,3) cols(2)];
    CURCOORD = [pagenum FIGMAT(pagenum,3) cols(1)];
    if any(LASTCOORD~=CURCOORD)
        FIGMAT(pagenum,4) = newcol;
        sguivar('FIGMAT',FIGMAT,'LASTCOORD',LASTCOORD,...
                'CURCOORD',CURCOORD,toolhan);
        simgui(SIMWIN,'updatelab');
            set(gguivar('MESSAGE',toolhan),'string',' ');
            set(gguivar('MESS_PARM',toolhan),'string',' ');
    else
            set(gguivar('MESSAGE',toolhan),...
            'string','Column number remained the same');
    end
elseif strcmp(in1,'updatelab')
    [PRCHAN,FIGMAT,LASTCOORD,SELECTHAN,GGWIN] = ...
         gguivar('PRCHAN','FIGMAT','LASTCOORD','SELECTHAN','GGWIN',toolhan);
    pagenum = updownb('getval',PRCHAN(1));
    rownum = FIGMAT(pagenum,3);
    colnum = FIGMAT(pagenum,4);
    DIMKNOWN = gguivar('DIMKNOWN',toolhan);
    if DIMKNOWN
        [matdata,matrv,cnt,mask,visrow,gff] = scrolltb('getstuff',SELECTHAN);
        [MASKPIM,MATDATAPIM,MATRVPIM,CNTPIM,VISROWPIM,GROUPFFPIM] = ...
            gguivar('MASKPIM','MATDATAPIM','MATRVPIM','CNTPIM','VISROWPIM','GROUPFFPIM',toolhan);
        [OLN,CLN,OLP,CLP] = ...
            gguivar('OLN','CLN','OLP','CLP',toolhan);
% this next 14 lines are to make sure the last values are saved
        OLN = deladdc(OLN,LASTCOORD,visrow(2)&any(matrv(2,:)));
        OLP = deladdc(OLP,LASTCOORD,visrow(3)&any(matrv(3,:)));
        CLN = deladdc(CLN,LASTCOORD,visrow(4)&any(matrv(4,:)));
        CLP = deladdc(CLP,LASTCOORD,visrow(5)&any(matrv(5,:)));
        sguivar('OLN',OLN,'CLN',CLN,'OLP',OLP,'CLP',CLP,toolhan);

        MASKPIM = mdipii(MASKPIM,mask,LASTCOORD(1),LASTCOORD(2),LASTCOORD(3));
        MATDATAPIM = mdipii(MATDATAPIM,matdata,LASTCOORD(1),LASTCOORD(2),LASTCOORD(3));
        MATRVPIM = mdipii(MATRVPIM,matrv,LASTCOORD(1),LASTCOORD(2),LASTCOORD(3));
        CNTPIM = mdipii(CNTPIM,cnt,LASTCOORD(1),LASTCOORD(2),LASTCOORD(3));
        VISROWPIM = mdipii(VISROWPIM,visrow,LASTCOORD(1),LASTCOORD(2),LASTCOORD(3));
        GROUPFFPIM = mdipii(GROUPFFPIM,gff,LASTCOORD(1),LASTCOORD(2),LASTCOORD(3));
        sguivar('MASKPIM',MASKPIM,'MATDATAPIM',MATDATAPIM,'CNTPIM',CNTPIM,...
            'MATRVPIM',MATRVPIM,'VISROWPIM',VISROWPIM,'GROUPFFPIM',GROUPFFPIM,toolhan);

        [DF_MASK,DF_MATDATA,DF_MATRV,DF_CNT,DF_VISROW,DF_GROUPFF] = ...
            gguivar('DF_MASK','DF_MATDATA','DF_MATRV','DF_CNT','DF_VISROW','DF_GROUPFF',toolhan);
        mask = mdxpii(MASKPIM,pagenum,rownum,colnum);
        if isempty(mask)
            mask = DF_MASK;
            matdata = DF_MATDATA;
            matrv = DF_MATRV;
            cnt = DF_CNT;
            visrow = DF_VISROW;
            gff = DF_GROUPFF;
        else
            matdata = mdxpii(MATDATAPIM,pagenum,rownum,colnum);
            matrv   = mdxpii(MATRVPIM,pagenum,rownum,colnum);
            cnt     = mdxpii(CNTPIM,pagenum,rownum,colnum);
            visrow  = mdxpii(VISROWPIM,pagenum,rownum,colnum);
            gff     = mdxpii(GROUPFFPIM,pagenum,rownum,colnum);
            noutputs  = size(DF_MATDATA,2);
                        lnoutputs = size(matdata,2);
                        if noutputs<lnoutputs
                                mask    = mask(:,1:noutputs);
                                matdata = matdata(:,1:noutputs);
                matrv   = matrv(:,1:noutputs);
                if cnt>noutputs
                    cnt = 1;
                end
            elseif noutputs>lnoutputs
                mask    = [mask DF_MASK(:,lnoutputs+1:noutputs)];
                matdata = [matdata DF_MATDATA(:,lnoutputs+1:noutputs)];
                matrv   = [matrv DF_MATRV(:,lnoutputs+1:noutputs)];
                        end
        end
        scrolltb('setstuff',SELECTHAN,matdata,matrv,cnt,mask,visrow,gff);
        scrolltb('refill2',SELECTHAN);
        scrolltb('disablerow',SELECTHAN,[2:5]);
        scrolltb('enablerow',SELECTHAN,find(visrow==1));
        scrolltb('setrvname2',SELECTHAN,[0;visrow(2:5)]);
        ggf_butval = get(GGWIN,'value');
        if gff == 0 % freeform
            set(GGWIN,'value',2);
        else
            set(GGWIN,'value',1);
        end
    end
    labhans = get(PRCHAN(5),'userdata');
    fonthans = get(PRCHAN(6),'userdata');
    afonthan = get(PRCHAN(7),'userdata');
    [TITLEPIM,XLPIM,YLPIM,DF_GRID,GRIDPIM] = ...
        gguivar('TITLEPIM','XLPIM','YLPIM','DF_GRID','GRIDPIM',toolhan);
    [TFONTPIM,XFONTPIM,YFONTPIM,AFONTPIM,DF_FONT] = ...
        gguivar('TFONTPIM','XFONTPIM','YFONTPIM','AFONTPIM','DF_FONT',toolhan);
    set(labhans(1),'string',mdxpii(TITLEPIM,pagenum,rownum,colnum));
    set(labhans(2),'string',mdxpii(XLPIM,pagenum,rownum,colnum));
    set(labhans(3),'string',mdxpii(YLPIM,pagenum,rownum,colnum));
    ft = mdxpii(TFONTPIM,pagenum,rownum,colnum);
    fx = mdxpii(XFONTPIM,pagenum,rownum,colnum);
    fy = mdxpii(YFONTPIM,pagenum,rownum,colnum);
    fa = mdxpii(AFONTPIM,pagenum,rownum,colnum);
    % save the last grid value
        grid_han = PRCHAN(8);
        gridval  = get(grid_han,'value');
        GRIDPIM = mdipii(GRIDPIM,gridval,LASTCOORD(1),LASTCOORD(2),LASTCOORD(3));
        sguivar('GRIDPIM',GRIDPIM,toolhan);
    % get the CURCOORD grid value
    gridval = mdxpii(GRIDPIM,pagenum,rownum,colnum);
    if isempty(ft)
        set(fonthans(1),'string',int2str(DF_FONT(1)));
    else
        set(fonthans(1),'string',int2str(ft));
    end
    if isempty(fx)
        set(fonthans(2),'string',int2str(DF_FONT(2)));
    else
        set(fonthans(2),'string',int2str(fx));
    end
    if isempty(fy)
        set(fonthans(3),'string',int2str(DF_FONT(3)));
    else
        set(fonthans(3),'string',int2str(fy));
    end
    if isempty(fa)
        set(afonthan,'string',int2str(DF_FONT(4)));
    else
        set(afonthan,'string',int2str(fa));
    end
    if isempty(gridval)
        set(grid_han,'value',DF_GRID);
    else
        set(grid_han,'value',gridval);
    end
    if ~isempty(SELECTHAN)
    	scrolltb('updateslid',SELECTHAN);
    end
elseif strcmp(in1,'txy_names')
    [PRCHAN,FIGMAT,AXESPIM] = ...
        gguivar('PRCHAN','FIGMAT','AXESPIM',toolhan);
    [TITLEPIM,XLPIM,YLPIM] = ...
        gguivar('TITLEPIM','XLPIM','YLPIM',toolhan);
    [TFONTPIM,XFONTPIM,YFONTPIM,DF_FONT] = ...
        gguivar('TFONTPIM','XFONTPIM','YFONTPIM','DF_FONT',toolhan);
    pagenum = updownb('getval',PRCHAN(1));
    rownum = FIGMAT(pagenum,3);
    colnum = FIGMAT(pagenum,4);
    axhan = mdxpii(AXESPIM,pagenum,rownum,colnum);
    labhans = get(PRCHAN(5),'userdata');
    co = labhans(in2);
    newstr = get(co,'string');
    if in2 == 1
        TITLEPIM = mdipii(TITLEPIM,newstr,pagenum,rownum,colnum);
        sguivar('TITLEPIM',TITLEPIM,toolhan);
        tf = mdxpii(TFONTPIM,pagenum,rownum,colnum);
        if isempty(tf)
            tf = DF_FONT(1);
        end
        if ~isempty(axhan)
            th = get(axhan,'title');
            set(th,'string',newstr,'Fontsize',tf);
        end
    elseif in2 == 2
        XLPIM = mdipii(XLPIM,newstr,pagenum,rownum,colnum);
        sguivar('XLPIM',XLPIM,toolhan);
        xf = mdxpii(XFONTPIM,pagenum,rownum,colnum);
        if isempty(xf)
            xf = DF_FONT(2);
        end
        if ~isempty(axhan)
            xh = get(axhan,'xlabel');
            set(xh,'string',newstr,'Fontsize',xf);
        end
    elseif in2 == 3
        YLPIM = mdipii(YLPIM,newstr,pagenum,rownum,colnum);
        sguivar('YLPIM',YLPIM,toolhan);
        yf = mdxpii(YFONTPIM,pagenum,rownum,colnum);
        if isempty(yf)
            yf = DF_FONT(3);
        end
        if ~isempty(axhan)
            yh = get(axhan,'ylabel');
            set(yh,'string',newstr,'Fontsize',yf);
        end
    end
elseif strcmp(in1,'txy_font')
    [PRCHAN,FIGMAT,AXESPIM] = ...
        gguivar('PRCHAN','FIGMAT','AXESPIM',toolhan);
    [TFONTPIM,XFONTPIM,YFONTPIM,DF_FONT] = ...
        gguivar('TFONTPIM','XFONTPIM','YFONTPIM','DF_FONT',toolhan);
    pagenum = updownb('getval',PRCHAN(1));
    rownum = FIGMAT(pagenum,3);
    colnum = FIGMAT(pagenum,4);
    axhan = mdxpii(AXESPIM,pagenum,rownum,colnum);
    fonthans = get(PRCHAN(6),'userdata');
    co = fonthans(in2);
    newstr = get(co,'string');
    if in2 == 1
        TFONTPIM = mdipii(TFONTPIM,round(str2double(newstr)),pagenum,rownum,colnum);
        sguivar('TFONTPIM',TFONTPIM,toolhan);
        if ~isempty(axhan)
            th = get(axhan,'title');
            set(th,'Fontsize',round(str2double(newstr)));
        end
    elseif in2 == 2
        XFONTPIM = mdipii(XFONTPIM,round(str2double(newstr)),pagenum,rownum,colnum);
        sguivar('XFONTPIM',XFONTPIM,toolhan);
        if ~isempty(axhan)
            xh = get(axhan,'xlabel');
            set(xh,'Fontsize',round(str2double(newstr)));
        end
    elseif in2 == 3
        YFONTPIM = mdipii(YFONTPIM,round(str2double(newstr)),pagenum,rownum,colnum);
        sguivar('YFONTPIM',YFONTPIM,toolhan);
        if ~isempty(axhan)
            yh = get(axhan,'ylabel');
            set(yh,'Fontsize',round(str2double(newstr)));
        end
    end
elseif strcmp(in1,'axes_font')
    [PRCHAN,FIGMAT,AXESPIM] = gguivar('PRCHAN','FIGMAT','AXESPIM',toolhan);
    [AFONTPIM,DF_FONT] = gguivar('AFONTPIM','DF_FONT',toolhan);
    pagenum = updownb('getval',PRCHAN(1));
    rownum = FIGMAT(pagenum,3);
    colnum = FIGMAT(pagenum,4);
    axhan = mdxpii(AXESPIM,pagenum,rownum,colnum);
    afonthan = get(PRCHAN(7),'userdata');
    newstr = get(afonthan,'string');
    AFONTPIM = mdipii(AFONTPIM,round(str2double(newstr)),pagenum,rownum,colnum);
    sguivar('AFONTPIM',AFONTPIM,toolhan);
    if ~isempty(axhan)
        set(axhan,'Fontsize',round(str2double(newstr)));
    end
elseif strcmp(in1,'grid')
    [PRCHAN,FIGMAT,AXESPIM,GRIDPIM] = ...
        gguivar('PRCHAN','FIGMAT','AXESPIM','GRIDPIM',toolhan);
    pagenum = updownb('getval',PRCHAN(1));
    rownum = FIGMAT(pagenum,3);
    colnum = FIGMAT(pagenum,4);
    axhan = mdxpii(AXESPIM,pagenum,rownum,colnum);
    gridval = get(PRCHAN(8),'value');
    GRIDPIM = mdipii(GRIDPIM,gridval,pagenum,rownum,colnum);
    sguivar('GRIDPIM',GRIDPIM,toolhan);
    if gridval == 2
        if ~isempty(axhan)
            set(axhan,'XGrid','On');
            set(axhan,'YGrid','On');
        end
    else
        if ~isempty(axhan)
            set(axhan,'XGrid','Off');
            set(axhan,'YGrid','Off');
        end
    end
elseif strcmp(in1,'createfigs')
    [FIGMAT,PARMWIN] = gguivar('FIGMAT','PARMWIN',toolhan);
    ud = get(PARMWIN,'userdata');
    numfigs = length(find(~isnan(FIGMAT(:,5))));
    ALLFIGS = [];
    AXESPIM = [];

    for i=1:numfigs
        h = figure('Numbertitle','off',...
                'menubar','none',...
                'userdata',ud);

	pltcols(h);

        set(h,'Name',...
         ['muTools(',int2str(h),'): Simulation Plot Page #' int2str(i)  wsuff]);
        for j=1:FIGMAT(i,1)
            for k=1:FIGMAT(i,2)
                ah = subplot(FIGMAT(i,1),FIGMAT(i,2),(j-1)*FIGMAT(i,2)+k);
                set(ah,'nextplot','add');
                AXESPIM = mdipii(AXESPIM,ah,i,j,k);
            end
        end
	set(h,'handlevis','call');
        ALLFIGS = [ALLFIGS;h];
    end
    sguivar('AXESPIM',AXESPIM,'ALLFIGS',ALLFIGS,toolhan);
elseif strcmp(in1,'ct2pim')  % current table data into all of the PIMS
    [CURCOORD,SELECTHAN] = gguivar('CURCOORD','SELECTHAN',toolhan);
    if ~isempty(SELECTHAN)
        [matdata,matrv,cnt,mask,visrow,gff] = scrolltb('getstuff',SELECTHAN);
        [MASKPIM,MATDATAPIM,MATRVPIM,CNTPIM,VISROWPIM,GROUPFFPIM] = ...
            gguivar('MASKPIM','MATDATAPIM','MATRVPIM','CNTPIM','VISROWPIM','GROUPFFPIM',toolhan);
        [OLN,CLN,OLP,CLP] = ...
            gguivar('OLN','CLN','OLP','CLP',toolhan);
        OLN = deladdc(OLN,CURCOORD,visrow(2)&any(matrv(2,:)));
        OLP = deladdc(OLP,CURCOORD,visrow(3)&any(matrv(3,:)));
        CLN = deladdc(CLN,CURCOORD,visrow(4)&any(matrv(4,:)));
        CLP = deladdc(CLP,CURCOORD,visrow(5)&any(matrv(5,:)));
        sguivar('OLN',OLN,'CLN',CLN,'OLP',OLP,'CLP',CLP,toolhan);

        MASKPIM    = mdipii(MASKPIM,mask,CURCOORD(1),CURCOORD(2),CURCOORD(3));
        MATDATAPIM = mdipii(MATDATAPIM,matdata,CURCOORD(1),CURCOORD(2),CURCOORD(3));
        MATRVPIM   = mdipii(MATRVPIM,matrv,CURCOORD(1),CURCOORD(2),CURCOORD(3));
        CNTPIM     = mdipii(CNTPIM,cnt,CURCOORD(1),CURCOORD(2),CURCOORD(3));
        VISROWPIM  = mdipii(VISROWPIM,visrow,CURCOORD(1),CURCOORD(2),CURCOORD(3));
        GROUPFFPIM = mdipii(GROUPFFPIM,gff,CURCOORD(1),CURCOORD(2),CURCOORD(3));

        sguivar('MASKPIM',MASKPIM,'MATDATAPIM',MATDATAPIM,'CNTPIM',CNTPIM,...
            'MATRVPIM',MATRVPIM,'VISROWPIM',VISROWPIM,'GROUPFFPIM',GROUPFFPIM,toolhan);
    end
elseif strcmp(in1,'refreshpage')
    [SIMWIN,CURCOORD,SELECTHAN,GRIDPIM] = ...
		 gguivar('SIMWIN','CURCOORD','SELECTHAN','GRIDPIM',toolhan);
    [PARMWIN,FIGMAT,ALLFIGS,AXESPIM,AFONTPIM,DF_FONT] = ...
        gguivar('PARMWIN','FIGMAT','ALLFIGS','AXESPIM','AFONTPIM','DF_FONT',toolhan);
    [MASKPIM,MATDATAPIM,MATRVPIM,VISROWPIM] = ...
        gguivar('MASKPIM','MATDATAPIM','MATRVPIM','VISROWPIM',toolhan);
    pagenum = in2;
    rows = in3;
    cols = in4;
    kids = get(ALLFIGS(pagenum),'children');
    for j = 1:length(kids)
        str_type = get(kids(j),'type');
        if strcmp(str_type,'axes')
            delete(kids(j))             % delete axes only
        end
    end
    figure(ALLFIGS(pagenum))
    set(ALLFIGS(pagenum),'nextplot','add')
    ahmat = zeros(rows,cols);
    for j=1:rows
        for k=1:cols
            ah = subplot(rows,cols,(j-1)*cols+k);
            afnt = mdxpii(AFONTPIM,pagenum,j,k);
            if isempty(afnt)
                afnt = DF_FONT(4);
            end
            gridval = mdxpii(GRIDPIM,pagenum,j,k);
            if ~isempty(gridval) & gridval == 2
                set(ah,'XGrid','On');
                set(ah,'YGrid','On');
            end
            set(ah,'nextplot','add','Fontsize',afnt);
            AXESPIM = mdipii(AXESPIM,ah,pagenum,j,k);
            ahmat(j,k) = ah;
        end
    end
%   set(ALLFIGS(pagenum),'nextplot','new') % GJW 09/09/96
    sguivar('AXESPIM',AXESPIM,toolhan);
    [YOLN,YOLP,YCLN,YCLP] = gguivar('YOLN','YOLP','YCLN','YCLP',toolhan);
    [YHANOLN,YHANOLP,YHANCLN,YHANCLP] = gguivar('YHANOLN','YHANOLP','YHANCLN','YHANCLP',toolhan);
    [DF_MASK,DF_MATDATA,DF_MATRV,DF_VISROW] = ...
        gguivar('DF_MASK','DF_MATDATA','DF_MATRV','DF_VISROW',toolhan);
    for j=1:rows
        for k=1:cols
            axes(ahmat(j,k));
            if ~isempty(YOLN)
                    oln = vplot(YOLN,'gui');set(oln,'visible','off');
                YHANOLN = mdipii(YHANOLN,oln,pagenum,j,k);
            else
                oln = [];
            end
            if ~isempty(YOLP)
                    olp = vplot(YOLP,'gui');set(olp,'visible','off');
                YHANOLP = mdipii(YHANOLP,olp,pagenum,j,k);
            else
                olp = [];
            end
            if ~isempty(YCLN)
                    cln = vplot(YCLN,'gui');set(cln,'visible','off');
                YHANCLN = mdipii(YHANCLN,cln,pagenum,j,k);
            else
                cln = [];
            end
            if ~isempty(YCLP)
                    clp = vplot(YCLP,'gui');set(clp,'visible','off');
                YHANCLP = mdipii(YHANCLP,clp,pagenum,j,k);
            else
                clp = [];
            end
            if j~=CURCOORD(2) | k~=CURCOORD(3)
                matdata = mdxpii(MATDATAPIM,pagenum,j,k);
                matrv   = mdxpii(MATRVPIM,pagenum,j,k);
                mask    = mdxpii(MASKPIM,pagenum,j,k);
                visrow  = mdxpii(VISROWPIM,pagenum,j,k);
                            noutputs  = size(DF_MATDATA,2);
                            lnoutputs = size(matdata,2);
                            if noutputs<lnoutputs
                                    mask    = mask(:,1:noutputs);
                                    matdata = matdata(:,1:noutputs);
                    matrv   = matrv(:,1:noutputs);
                    if cnt>noutputs
                        cnt = 1;
                    end
                elseif noutputs>lnoutputs
                    mask    = [mask DF_MASK(:,lnoutputs+1:noutputs)];
                    matdata = [matdata DF_MATDATA(:,lnoutputs+1:noutputs)];
                    matrv   = [matrv DF_MATRV(:,lnoutputs+1:noutputs)];
                            end
            else
                if ~isempty(SELECTHAN)
                        [matdata,matrv,cnt,mask,visrow,gff] = ...
                        scrolltb('getstuff',SELECTHAN);
                else
                    mask    = DF_MASK;
                    matdata = DF_MATDATA;
                    matrv   = DF_MATRV;
                    visrow  = DF_VISROW;
                end
            end
            if isempty(mask)
                mask = DF_MASK;
            end
            if isempty(matdata)
                matdata = DF_MATDATA;
            end
            if isempty(matrv)
                matrv = DF_MATRV;
            end
            if isempty(visrow)
                visrow = DF_VISROW;
            end
            simgui(SIMWIN,'ssredraw',matdata,matrv,mask,visrow,...
                    oln,olp,cln,clp,ahmat(j,k),[pagenum j k]);
        end
    end
    sguivar('YHANOLP',YHANOLP,'YHANOLN',YHANOLN,...
		'YHANCLN',YHANCLN,'YHANCLP',YHANCLP,toolhan);
elseif strcmp(in1,'addpage')
    [SIMWIN,FIGMAT,ALLFIGS,AXESPIM,PLTMENU] = ...
        gguivar('SIMWIN','FIGMAT','ALLFIGS','AXESPIM','PLTMENU',toolhan);
    [AFONTPIM,DF_FONT,UDNAME] = gguivar('AFONTPIM','DF_FONT','UDNAME',toolhan);
    pagenum = in2;
    rows = FIGMAT(pagenum,1);
    cols = FIGMAT(pagenum,2);
    % npltmenus = length(PLTMENU);
    npltmenus = sum(PLTMENU~=0);
    wsuff = UDNAME;
    [mainw,othw,notours,splts] = findmuw;
    othw = xpii(othw,SIMWIN);
    subnum = max(othw(:,2));
    ud = get(SIMWIN,'userdata');
    udl = length(ud);
    ud(udl-3:udl-1,1) = abs('SUB')';
    ud(udl) = SIMWIN + (subnum+1)/100;
    if ~isempty(UDNAME)
        if ~isempty(deblank(UDNAME))
                wsuff = [' - ' UDNAME];
        end
    end
    h = figure('Numbertitle','off',...
        'menubar','none',...
        'Userdata',[ud;abs('SPLT')']);

    pltcols(h);

    tit = ['muTools(',int2str(h),'): Simulation Plot Page#'];
    tit = [tit int2str(pagenum)  wsuff];
    set(h,'Name',tit);
    tmp = uimenu(h,'Label','Window');
    atmp = uimenu(tmp,'Label',['Hide Plot #' int2str(pagenum)],'callback',...
        ['simgui(' thstr ',''hideplotwin'',' int2str(pagenum) ');']);
    btmp = uimenu(tmp,'Label','Main','callback',...
        ['simgui(' thstr ',''showmain'');']);
        ctmp = uimenu(tmp,'Label','Parameters','callback',...
		['simgui(' thstr ',''showparmwin'');']);
    if PLTMENU(pagenum+2) ~= 0
            PLTMENU(pagenum+2) = uimenu(tmp,'Label','Plots');
        maxpages = npltmenus;
        del_plt = 1;
    else
            PLTMENU(npltmenus+1) = uimenu(tmp,'Label','Plots');
        maxpages = npltmenus+1;
        del_plt = 0;
    end
    for ii = 1:maxpages     % number of windows with pull down menus
        kids = get(PLTMENU(ii),'children');
        delete(kids)
        for jj = 1:maxpages-2       % number of plot windows
            uimenu(PLTMENU(ii),'Label',int2str(jj),...
                'callback',['simgui(' thstr ',''showplotwin'',' int2str(jj), ');']);
        end
    end
        tmp = uimenu(h,'Label','Printing');
        atmp = uimenu(tmp,'Label','Print',...
        'callback',['simgui(' thstr ',''lets_print'',' int2str(pagenum) ');']);
    for j=1:rows
        for k=1:cols
            ah = subplot(rows,cols,(j-1)*cols+k);
            afnt = mdxpii(AFONTPIM,pagenum,j,k);
            if isempty(afnt)
                afnt = DF_FONT(4);
            end
            set(ah,'nextplot','add','Fontsize',afnt);
            AXESPIM = mdipii(AXESPIM,ah,pagenum,j,k);
        end
    end
    FIGMAT(pagenum,5) = 1;
    ALLFIGS(pagenum) = h;
    sguivar('FIGMAT',FIGMAT,'ALLFIGS',ALLFIGS,toolhan);
    sguivar('AXESPIM',AXESPIM,'PLTMENU',PLTMENU,toolhan);
    if del_plt == 1
        rownum  = FIGMAT(i,1);
        colnum  = FIGMAT(i,2);
        simgui(SIMWIN,'refreshpage',pagenum,rownum,colnum);
    end
    set(h,'handlevis','call');

elseif strcmp(in1,'del_lastpage')       % deletes the last page
    [SIMWIN,FIGMAT,ALLFIGS,PLTMENU] = ...
        gguivar('SIMWIN','FIGMAT','ALLFIGS','PLTMENU',toolhan);
    pagenum = in2;
    npltmenus = length(PLTMENU);
    for ii = 1:npltmenus-1      % decrease the number of plot windows with pull down menus
        kids = get(PLTMENU(ii),'children');
        delete(kids)
        for jj = 1:npltmenus-1-2        % number of plot windows
            uimenu(PLTMENU(ii),'Label',int2str(jj),...
                'callback',['simgui(' thstr ',''showplotwin'',' int2str(jj), ');']);
        end
    end
    delete(ALLFIGS(pagenum))
    ALLFIGS(pagenum) = nan;
    PLTMENU = PLTMENU(1:npltmenus-1);
    FIGMAT(pagenum,5) = nan;
    sguivar('FIGMAT',FIGMAT,'ALLFIGS',ALLFIGS,'PLTMENU',PLTMENU,toolhan);
elseif strcmp(in1,'print_dof')
    [SIMWIN,PRCHAN,PRINTWIN,MESSAGE,PRINTNFIG,ALLFIGS] = ...
        gguivar('SIMWIN','PRCHAN','PRINTWIN','MESSAGE','PRINTNFIG','ALLFIGS',toolhan);
    labhans = get(PRCHAN(9),'userdata');    % handles of device, options, filename
    dev_str = get(labhans(1),'string');
    opt_str = get(labhans(2),'string');
    filen_str = get(labhans(3),'string');
    print_fail = 0;
    foo = ALLFIGS(PRINTNFIG);
    figure(foo);
    set(foo,'handlevis','on');
    eval(['print ' dev_str ' ' opt_str ' ' filen_str ';'],...
        'print_fail=1;');
    set(foo,'handlevis','call');
    if print_fail==1
        set(MESSAGE,'string','Error in executing Print Dialog Box');
    else
        simgui(SIMWIN,'quit_dof');
    end
elseif strcmp(in1,'quit_dof')
    [PRCHAN,PRINTWIN] = gguivar('PRCHAN','PRINTWIN',toolhan);
    set(PRINTWIN,'visible','off');
    labhans = get(PRCHAN(9),'userdata');    % handles of device, options, filename
    set(labhans(3),'string',' ');
    set(gguivar('MESSAGE',toolhan),'string',' ');
    set(gguivar('MESS_PARM',toolhan),'string',' ');
elseif strcmp(in1,'lets_print')
    currfig = gcf;
    ALLFIGS = gguivar('ALLFIGS',toolhan);
    index = find(currfig == ALLFIGS);
    sguivar('PRINTNFIG',in2,toolhan);
    PRINTWIN = gguivar('PRINTWIN',toolhan);
    tit = ['muTools(',int2str(PRINTWIN),'): Print Page '];
    tit = [tit int2str(index) ' Dialog Box'];
    set(PRINTWIN,'visible','on','Name',tit);
    figure(gguivar('PRINTWIN',toolhan))
elseif strcmp(in1,'back2prt')
    [PRINTWIN,PRCHAN] = gguivar('PRINTWIN','PRCHAN',toolhan);
    % 1st visible off load/save info
    ud = get(PRCHAN(17),'userdata');    %editable text handles
    lshans = PRCHAN(15:19);
    set([lshans;ud],'visible','off');
    % 2nd visible on print info
    ud = get(PRCHAN(9),'userdata'); %editable text handles
    printhans = PRCHAN(9:14);
    set([printhans;ud],'visible','on');
    set(PRINTWIN,'visible','off');
elseif strcmp(in1,'load_save')
    [SIMWIN,PRCHAN,PRINTWIN,MESSAGE,PRINTNFIG,ALLFIGS] = ...
        gguivar('SIMWIN','PRCHAN','PRINTWIN','MESSAGE','PRINTNFIG','ALLFIGS',toolhan);
    labhans = get(PRCHAN(17),'userdata');   % handles of device, options, filename
    var_str   = get(labhans(1),'string');
    filen_str = get(labhans(2),'string');
    type = get(PRCHAN(15),'string');
    if strcmp(type,'Save')
        if isempty(deblank(var_str))            % No Variable Name, default to SAVESET
            var_str = 'SAVESET';
        end
            set(gguivar('MESSAGE',toolhan),'string',['Saving Setup data in: ' var_str]);
        drawnow
        if isempty(deblank(filen_str))      % No File Name, default save to workspace
            SUCCESSCB   = [var_str ' = gguivar(''SAVESET'',' thstr ');'];
            SUCCESSCB   = [SUCCESSCB 'set(gguivar(''MESSAGE'',' thstr '),''string'','' '');'];
        else
            SUCCESSCB   = [var_str ' = gguivar(''SAVESET'',' thstr ');save '];
            SUCCESSCB   = [SUCCESSCB filen_str ' ' var_str ';' ];
            SUCCESSCB   = [SUCCESSCB 'set(gguivar(''MESSAGE'',' thstr '),''string'','' '');'];
        end
        ERRORCB     = ['sguivar(''SAVESET'',[],' thstr '); set(gguivar(''MESSAGE'',' thstr ')'];
        ERRORCB     = [ERRORCB ',''string'',''Problem in Saving Setup'');'];
    elseif strcmp(type,'Load')
        if isempty(deblank(var_str))            % No Variable Name, default to SAVESET
            var_str = 'SAVESET';
        end
            set(gguivar('MESSAGE',toolhan),'string',['Loading Setup data from: ' var_str]);
        drawnow
        if isempty(deblank(filen_str))      % No File Name, default save to workspace
            SUCCESSCB   = ['sguivar(''SAVESET'',' var_str ',' thstr ');'];
            SUCCESSCB   = [SUCCESSCB 'simgui(' thstr ',''load_setup'');'];
            SUCCESSCB   = [SUCCESSCB 'set(gguivar(''MESSAGE'',' thstr '),''string'','' '');'];
        else
            SUCCESSCB   = ['load ' filen_str '; sguivar(''SAVESET'',' var_str ',' thstr ');'];
            SUCCESSCB   = [SUCCESSCB 'simgui(' thstr ',''load_setup'');'];
            SUCCESSCB   = [SUCCESSCB 'set(gguivar(''MESSAGE'',' thstr '),''string'','' '');'];
        end
        ERRORCB     = ['sguivar(''SAVESET'',[],' thstr '); set(gguivar(''MESSAGE'',' thstr ')'];
        ERRORCB     = [ERRORCB ',''string'',''Problem in Loading Setup'');drawnow;'];
    end
    sguivar('ERRORCB',ERRORCB,'SUCCESSCB',SUCCESSCB,toolhan);
    simgui(SIMWIN,'back2prt');
elseif strcmp(in1,'quit_ls')
    [SIMWIN,PRCHAN] = gguivar('SIMWIN','PRCHAN',toolhan);
    labhans = get(PRCHAN(9),'userdata');    % handles of device, options, filename
    set(labhans(2),'string',' ');
    set(gguivar('MESSAGE',toolhan),'string',' ');
    simgui(SIMWIN,'back2prt');
elseif strcmp(in1,'ls_setup')
    [PRINTWIN,PRCHAN] = gguivar('PRINTWIN','PRCHAN',toolhan);
    % 1st visible off printing info
    ud = get(PRCHAN(9),'userdata'); %editable text handles
    printhans = PRCHAN(9:14);
    set([printhans;ud],'visible','off');
    % 2nd visible on load/save info
    ud = get(PRCHAN(17),'userdata');    %editable text handles
    lshans = PRCHAN(15:19);
    set([lshans;ud],'visible','on');
    if strcmp(in2,'save')
        tit = ['muTools(',int2str(PRINTWIN),'): Save Dialog Box'];
        set(PRCHAN(15),'string','Save')
    else
        tit = ['muTools(',int2str(PRINTWIN),'): Load Dialog Box'];
        set(PRCHAN(15),'string','Load')
    end
    set(PRINTWIN,'visible','on','Name',tit);
    figure(PRINTWIN)
elseif strcmp(in1,'save_setup')
    [SIMWIN] = gguivar('SIMWIN',toolhan);
    % need to save everything in the current setup, just like changed pagenum
    simgui(SIMWIN,'ct2pim');
    % get all of the important data to be saved, save as 1 MD PIM: SAVESET
    [UDNAME,SUFFIXNAME,LASTCOORD,CURCOORD] = ...
        gguivar('UDNAME','SUFFIXNAME','LASTCOORD','CURCOORD',toolhan);
    SAVESET = ipii(SAVESET,UDNAME,1);
    SAVESET = ipii(SAVESET,SUFFIXNAME,2);
    SAVESET = ipii(SAVESET,LASTCOORD,3);
    SAVESET = ipii(SAVESET,CURCOORD,4);
    [OLN,CLN,OLP,CLP] = ...
        gguivar('OLN','CLN','OLP','CLP',toolhan);
    SAVESET = ipii(SAVESET,OLN,5);
    SAVESET = ipii(SAVESET,OLP,6);
    SAVESET = ipii(SAVESET,CLN,7);
    SAVESET = ipii(SAVESET,CLP,8);
    [MASKPIM,MATDATAPIM,MATRVPIM,CNTPIM,VISROWPIM,GROUPFFPIM] = ...
        gguivar('MASKPIM','MATDATAPIM','MATRVPIM','CNTPIM','VISROWPIM','GROUPFFPIM',toolhan);
    SAVESET = ipii(SAVESET,MASKPIM,9);
    SAVESET = ipii(SAVESET,MATDATAPIM,10);
    SAVESET = ipii(SAVESET,MATRVPIM,11);
    SAVESET = ipii(SAVESET,CNTPIM,12);
    SAVESET = ipii(SAVESET,VISROWPIM,13);
    SAVESET = ipii(SAVESET,GROUPFFPIM,14);
    [TITLEPIM,XLPIM,YLPIM,AXESPIM,GRIDPIM] = ...
        gguivar('TITLEPIM','XLPIM','YLPIM','AXESPIM','GRIDPIM',toolhan);
    SAVESET = ipii(SAVESET,TITLEPIM,15);
    SAVESET = ipii(SAVESET,XLPIM,16);
    SAVESET = ipii(SAVESET,YLPIM,17);
    SAVESET = ipii(SAVESET,AXESPIM,18);
    SAVESET = ipii(SAVESET,GRIDPIM,19);
    [TFONTPIM,XFONTPIM,YFONTPIM,AFONTPIM] = ...
        gguivar('TFONTPIM','XFONTPIM','YFONTPIM','AFONTPIM',toolhan);
    SAVESET = ipii(SAVESET,TFONTPIM,20);
    SAVESET = ipii(SAVESET,XFONTPIM,21);
    SAVESET = ipii(SAVESET,YFONTPIM,22);
    SAVESET = ipii(SAVESET,AFONTPIM,23);
    [FIGMAT,OLDFIGMAT,FIGMAX,COMPSTAT] = ...
        gguivar('FIGMAT','OLDFIGMAT','FIGMAX','COMPSTAT',toolhan);
    SAVESET = ipii(SAVESET,FIGMAT,24);
    SAVESET = ipii(SAVESET,OLDFIGMAT,25);
    SAVESET = ipii(SAVESET,FIGMAX,26);
    SAVESET = ipii(SAVESET,COMPSTAT,27);
    [TFIN,INTSS,XINITP,XINITK,XINITD] = ...
        gguivar('TFIN','INTSS','XINITP','XINITK','XINITD',toolhan);
    SAVESET = ipii(SAVESET,TFIN,28);
    SAVESET = ipii(SAVESET,INTSS,29);
    SAVESET = ipii(SAVESET,XINITP,30);
    SAVESET = ipii(SAVESET,XINITK,31);
    SAVESET = ipii(SAVESET,XINITD,32);
    [SUFFIXNAME,UDNAME,SAMPT,SIMTYPE] = ...
         gguivar('SUFFIXNAME','UDNAME','SAMPT','SIMTYPE',toolhan);
    SAVESET = ipii(SAVESET,SUFFIXNAME,33);
    SAVESET = ipii(SAVESET,UDNAME,34);
    SAVESET = ipii(SAVESET,SAMPT,35);
    SAVESET = ipii(SAVESET,SIMTYPE(1),36);
    sguivar('SAVESET',SAVESET,toolhan);
    simgui(SIMWIN,'ls_setup','save')
elseif strcmp(in1,'load_setup')
    [SAVESET,MESSAGE] = gguivar('SAVESET','MESSAGE',toolhan);
    if isempty(SAVESET)
        set(MESSAGE,'string','Error in Loading Setup Data.....');
        drawnow
    else
        set(MESSAGE,'string','Loading Setup Data.....');
        drawnow
        UDNAME = xpii(SAVESET,1);
        SUFFIXNAME = xpii(SAVESET,2);
        LASTCOORD = xpii(SAVESET,3);
        CURCOORD = xpii(SAVESET,4);
        OLN = xpii(SAVESET,5);
        OLP = xpii(SAVESET,6);
        CLN = xpii(SAVESET,7);
        CLP = xpii(SAVESET,8);
        MASKPIM = xpii(SAVESET,9);
        MATDATAPIM = xpii(SAVESET,10);
        MATRVPIM = xpii(SAVESET,11);
        CNTPIM = xpii(SAVESET,12);
        VISROWPIM = xpii(SAVESET,13);
        GROUPFFPIM = xpii(SAVESET,14);
        TITLEPIM = xpii(SAVESET,15);
        XLPIM = xpii(SAVESET,16);
        YLPIM = xpii(SAVESET,17);
        AXESPIM = xpii(SAVESET,18);
        GRIDPIM = xpii(SAVESET,19);
        TFONTPIM = xpii(SAVESET,20);
        XFONTPIM = xpii(SAVESET,21);
        YFONTPIM = xpii(SAVESET,22);
        AFONTPIM = xpii(SAVESET,23);
        FIGMAT = xpii(SAVESET,24);
        OLDFIGMAT = xpii(SAVESET,25);
        FIGMAX = xpii(SAVESET,26);
        L_COMPSTAT = xpii(SAVESET,27);      % only want the 2nd col of this one
        TFIN       = xpii(SAVESET,28);
        INTSS      = xpii(SAVESET,29);
        XINITP     = xpii(SAVESET,30);
        XINITK     = xpii(SAVESET,31);
        XINITD     = xpii(SAVESET,32);
        SUFFIXNAME = xpii(SAVESET,33);
        UDNAME     = xpii(SAVESET,34);
        SAMPT      = xpii(SAVESET,35);
        SIMTYPE1    = xpii(SAVESET,36);
        COMPSTAT = gguivar('COMPSTAT',toolhan);
        sguivar('COMPSTAT',[COMPSTAT(:,1) L_COMPSTAT(:,2)],toolhan);
        sguivar('UDNAME',UDNAME,'SUFFIXNAME',SUFFIXNAME,'LASTCOORD',LASTCOORD,...
            'CURCOORD',CURCOORD,toolhan);
        sguivar('OLN',OLN,'OLP',OLP,'CLN',CLN,'CLP',CLP,toolhan);
        sguivar('MASKPIM',MASKPIM,'MATDATAPIM',MATDATAPIM,'MATRVPIM',MATRVPIM,...
            'CNTPIM',CNTPIM,'VISROWPIM',VISROWPIM,'GROUPFFPIM',GROUPFFPIM,toolhan);
        sguivar('TITLEPIM',TITLEPIM,'XLPIM',XLPIM,'YLPIM',YLPIM,'GRIDPIM',GRIDPIM,toolhan);
        sguivar('TFONTPIM',TFONTPIM,'XFONTPIM',XFONTPIM,'YFONTPIM',YFONTPIM,...
            'AFONTPIM',AFONTPIM,toolhan);
        sguivar('FIGMAT',FIGMAT,'OLDFIGMAT',OLDFIGMAT,'FIGMAX',FIGMAX,toolhan);
        sguivar('TFIN',TFIN,'INTSS',INTSS,'XINITP',XINITP,...
            'XINITK',XINITK,'XINITK',XINITK,toolhan);
        sguivar('SUFFIXNAME',SUFFIXNAME,'UDNAME',UDNAME,'SAMPT',SAMPT,toolhan)';
%
% All the data is loaded, now let's update all the current info
%
        [PRCHAN,SELECTHAN,GGWIN,DF_GRID,DF_FONT,TRSP_IDHANS] = ...
           gguivar('PRCHAN','SELECTHAN','GGWIN','DF_GRID','DF_FONT','TRSP_IDHANS',toolhan);
	[SIMWIN] = gguivar('SIMWIN',toolhan);
% set final time, int step size, and initial conidtions
        set(TRSP_IDHANS(1),'string',num2str(TFIN));
        set(TRSP_IDHANS(2),'string',num2str(INTSS));
        set(TRSP_IDHANS(3),'string',num2str(SAMPT));
        XINITP = gguivar('XINITP',toolhan);
        if isempty(XINITP)
            set(TRSP_IDHANS(4),'string',' ');
        else
            set(TRSP_IDHANS(4),'string',['gguivar(''XINITP'',' thstr ')']);
        end
        XINITK = gguivar('XINITK',toolhan);
        if isempty(XINITK)
            set(TRSP_IDHANS(5),'string',' ');
        else
            set(TRSP_IDHANS(5),'string',['gguivar(''XINITK'',' thstr ')']);
        end
        XINITD = gguivar('XINITD',toolhan);
        if isempty(XINITD)
            set(TRSP_IDHANS(6),'string',' ');
        else
            set(TRSP_IDHANS(6),'string',['gguivar(''XINITD'',' thstr ')']);
        end
        if isempty(SUFFIXNAME)
            set(TRSP_IDHANS(7),'string',' ');
        else
            set(TRSP_IDHANS(7),'string',SUFFIXNAME);
        end
        if isempty(UDNAME)
            set(TRSP_IDHANS(8),'string',' ');
        else
            set(TRSP_IDHANS(8),'string',UDNAME);
        end
        simgui(SIMWIN,'namecb',1);
        pagenum = CURCOORD(1);
        rownum  = CURCOORD(2);
        colnum  = CURCOORD(3);
        updownb('setval',PRCHAN(1),pagenum);
        updownb('setetxt',PRCHAN(1),int2str(pagenum));
        updownb2('setval1',PRCHAN(3),rownum);
        updownb2('setetxt1',PRCHAN(3),int2str(rownum));
        updownb2('setval2',PRCHAN(3),FIGMAT(pagenum,1));
        updownb2('setetxt2',PRCHAN(3),int2str(FIGMAT(pagenum,1)));
        updownb2('setmaxval',PRCHAN(3),FIGMAT(pagenum,1));
        updownb2('setval1',PRCHAN(4),colnum);
        updownb2('setetxt1',PRCHAN(4),int2str(colnum));
        updownb2('setmaxval',PRCHAN(4),FIGMAT(pagenum,2));
        updownb2('setval2',PRCHAN(4),FIGMAT(pagenum,2));
        updownb2('setetxt2',PRCHAN(4),int2str(FIGMAT(pagenum,2)));
        labhans  = get(PRCHAN(5),'userdata');
        fonthans = get(PRCHAN(6),'userdata');
        afonthan = get(PRCHAN(7),'userdata');
        grid_han = PRCHAN(8);
        tit     = mdxpii(TITLEPIM,pagenum,rownum,colnum);
        xl      = mdxpii(XLPIM,pagenum,rownum,colnum);
        yl      = mdxpii(YLPIM,pagenum,rownum,colnum);
        ft      = mdxpii(TFONTPIM,pagenum,rownum,colnum);
        fx      = mdxpii(XFONTPIM,pagenum,rownum,colnum);
        fy      = mdxpii(YFONTPIM,pagenum,rownum,colnum);
        fa      = mdxpii(AFONTPIM,pagenum,rownum,colnum);
        gridval = mdxpii(GRIDPIM,pagenum,rownum,colnum);

        if isempty(tit)
            set(labhans(1),'string',' ');
        else
            set(labhans(1),'string',tit);
        end
        if isempty(xl)
            set(labhans(2),'string',' ');
        else
            set(labhans(2),'string',xl);
        end
        if isempty(yl)
            set(labhans(3),'string',' ');
        else
            set(labhans(3),'string',yl);
        end
        if isempty(ft)
            set(fonthans(1),'string',int2str(DF_FONT(1)));
        else
            set(fonthans(1),'string',int2str(ft));
        end
        if isempty(fx)
            set(fonthans(2),'string',int2str(DF_FONT(2)));
        else
            set(fonthans(2),'string',int2str(fx));
        end
        if isempty(fy)
            set(fonthans(3),'string',int2str(DF_FONT(3)));
        else
            set(fonthans(3),'string',int2str(fy));
        end
        if isempty(fa)
            set(afonthan,'string',int2str(DF_FONT(4)));
        else
            set(afonthan,'string',int2str(fa));
        end
        if isempty(gridval)
            set(grid_han,'value',DF_GRID);
        else
            set(grid_han,'value',gridval);
        end

% the plot info table is setup correctly now setup the scroll table

        if ~isempty(SELECTHAN)
            [DF_MASK,DF_MATDATA] = gguivar('DF_MASK','DF_MATDATA',toolhan);
            noutputs = size(DF_MATDATA,2);
            mask    = mdxpii(MASKPIM,pagenum,rownum,colnum);
            matdata = mdxpii(MATDATAPIM,pagenum,rownum,colnum);
            matrv   = mdxpii(MATRVPIM,pagenum,rownum,colnum);
            cnt     = mdxpii(CNTPIM,pagenum,rownum,colnum);
            visrow  = mdxpii(VISROWPIM,pagenum,rownum,colnum);
            gff     = mdxpii(GROUPFFPIM,pagenum,rownum,colnum);
            lnoutputs = size(matdata,2);
            if noutputs<lnoutputs
                mask    = mask(:,1:noutputs);
                matdata = matdata(:,1:noutputs);
                matrv   = matrv(:,1:noutputs);
                if cnt>noutputs
                    cnt = 1;
                end
            elseif noutputs>lnoutputs
                mask    = [mask DF_MASK(:,lnoutputs+1:noutputs)];
                matdata = [matdata DF_MATDATA(:,lnoutputs+1:noutputs)];
                matrv   = [matrv DF_MATRV(:,lnoutputs+1:noutputs)];
            end
            scrolltb('setstuff',SELECTHAN,matdata,matrv,cnt,mask,visrow,gff);
            scrolltb('refill2',SELECTHAN);
            scrolltb('disablerow',SELECTHAN,[2:5]);
            scrolltb('enablerow',SELECTHAN,find(visrow==1));
            scrolltb('setrvname2',SELECTHAN,[0;visrow(2:5)]);
            scrolltb('updateslid',SELECTHAN); % new
            if gff == 0 % freeform
                set(GGWIN,'value',2);
            else
                set(GGWIN,'value',1);
            end
        end
        set(MESSAGE,'string','Finished Loading Setup Data, Drawing figures.....');
        drawnow
% ------------- Plot Info Table and Scroll Table should be correct -------------%
        [ALLFIGS] = gguivar('ALLFIGS',toolhan);
        npages = find(~isnan(ALLFIGS));
        load_npages = find(~isnan(FIGMAT(:,5)));

%    since all new variables are loaded, they don't know about the extra figures.
%    therefore we need to delete the extra pages, and update the pull down menus.

        if length(npages) >= length(load_npages)    % extra pages around, delete them
            for i = 1:length(load_npages)
                pagenum = i;
                rownum  = FIGMAT(i,1);
                colnum  = FIGMAT(i,2);
                simgui(SIMWIN,'refreshpage',pagenum,rownum,colnum);
            end
            for i = length(npages):-1:length(load_npages)+1
                pagenum = i;
                simgui(SIMWIN,'del_lastpage',pagenum);
            end
        else                        % new to add new pages
            for i = 1:length(npages)
                pagenum = i;
                rownum  = FIGMAT(i,1);
                colnum  = FIGMAT(i,2);
                simgui(SIMWIN,'refreshpage',pagenum,rownum,colnum);
            end
            for i = length(npages)+1:length(load_npages)
                simgui(SIMWIN,'addpage',i);
                pagenum = i;
                rownum  = FIGMAT(i,1);
                colnum  = FIGMAT(i,2);
                simgui(SIMWIN,'refreshpage',pagenum,rownum,colnum);
            end
        end
%
% set cont, discrete, or sample-data time response
%
            simgui(SIMWIN,'typemenu',SIMTYPE1);
        set(MESSAGE,'string','Finished with Loading Setup Data');
        drawnow
            simgui(toolhan,'dimcheck')
            simgui(toolhan,'computeenable');
        set(MESSAGE,'string',' ');
        drawnow
        figure(gguivar('SIMWIN',toolhan))
    end
elseif strcmp(in1,'ft_intss')
    SIMWIN = gguivar('SIMWIN',toolhan);
    if isempty(in2)
            set(gguivar('MESSAGE',toolhan),'string','Getting Data ...');
            set(gguivar('MESS_PARM',toolhan),'string','Getting Data ...');
    drawnow
    EDITHANDLES = get(gcf,'currentobject');
    EDITRESULTS = 'TEMP';
    RESTOOLHAN  = gcf;
    ERRORCB     = ['sguivar(''TEMP'',[],' thstr ');'];
    SUCCESSCB   = ' ';
    sguivar('EDITHANDLES',EDITHANDLES,'EDITRESULTS',EDITRESULTS,...
        'RESTOOLHAN',RESTOOLHAN,'ERRORCB',ERRORCB,'SUCCESSCB',SUCCESSCB,toolhan);
    else
    temp = gguivar('TEMP',toolhan);
    if in2 == 1
            set(gguivar('MESSAGE',toolhan),'string','Loading Final Time...');
            set(gguivar('MESS_PARM',toolhan),'string','Loading Final Time...');
        drawnow
        sguivar('TFIN',temp,'WHICHDATA',5,toolhan);
    elseif in2 == 2
            set(gguivar('MESSAGE',toolhan),'string','Loading Integration Time...');
            set(gguivar('MESS_PARM',toolhan),'string','Loading Integration Time...');
        drawnow
        sguivar('INTSS',temp,'WHICHDATA',6,toolhan);
    elseif in2 == 3
            set(gguivar('MESSAGE',toolhan),'string','Loading Sample Time...');
            set(gguivar('MESS_PARM',toolhan),'string','Loading Sample Time...');
        drawnow
        sguivar('SAMPT',temp,'WHICHDATA',10,toolhan);
    end
    simgui(SIMWIN,'typeddata');
    end
elseif strcmp(in1,'IC_PKD')
    SIMWIN = gguivar('SIMWIN',toolhan);
    if in2 == 1
        EDITHANDLES = get(gcf,'currentobject');
        EDITRESULTS = 'TEMP';
        RESTOOLHAN  = gcf;
        ERRORCB     = ['sguivar(''TEMP'',[],' thstr ');'];
        SUCCESSCB   = ' ';
        sguivar('EDITHANDLES',EDITHANDLES,'EDITRESULTS',EDITRESULTS,...
            'RESTOOLHAN',RESTOOLHAN,'ERRORCB',ERRORCB,'SUCCESSCB',SUCCESSCB,toolhan);
        if strcmp(in3,'Plant')
            set(gguivar('MESSAGE',toolhan),'string','Getting Plant initial conditions...');
            set(gguivar('MESS_PARM',toolhan),'string','Getting Plant initial conditions...');
            drawnow
        elseif strcmp(in3,'Controller')
            set(gguivar('MESSAGE',toolhan),'string','Getting Controller initial conditions...');
            set(gguivar('MESS_PARM',toolhan),'string','Getting Controller initial conditions...');
            drawnow
        elseif strcmp(in3,'Perturbation')
            set(gguivar('MESSAGE',toolhan),'string','Getting Perturbation initial conditions...');
            set(gguivar('MESS_PARM',toolhan),'string','Getting Perturbation initial conditions...');
            drawnow
        end
    elseif in2 == 2
        temp = gguivar('TEMP',toolhan);
        if strcmp(in3,'Plant')
            set(gguivar('MESSAGE',toolhan),'string','Loading Plant initial conditions...');
            set(gguivar('MESS_PARM',toolhan),'string','Loading Plant initial conditions...');
            drawnow
            sguivar('XINITP',temp,'WHICHDATA',7,toolhan);
        elseif strcmp(in3,'Controller')
            set(gguivar('MESSAGE',toolhan),'string','Loading Controller initial conditions...');
            set(gguivar('MESS_PARM',toolhan),'string','Loading Controller initial conditions...');
            drawnow
            sguivar('XINITK',temp,'WHICHDATA',8,toolhan);
        elseif strcmp(in3,'Perturbation')
            set(gguivar('MESSAGE',toolhan),'string','Loading Perturbation initial conditions...');
            set(gguivar('MESS_PARM',toolhan),'string','Loading Perturbation initial conditions...');
            drawnow
            sguivar('XINITD',temp,'WHICHDATA',9,toolhan);
        end
        simgui(SIMWIN,'typeddata');
    end
elseif strcmp(in1,'cleanupfigs')
    [FIGMAT,AXESPIM,ALLFIGS] = gguivar('FIGMAT','AXESPIM','ALLFIGS',toolhan);
    numfigs = length(find(~isnan(FIGMAT(:,5))));
    for i=1:numfigs
        if in2(i)==1
            delete(get(ALLFIGS(i),'children'))
            for j=1:FIGMAT(i,1)
                for k=1:FIGMAT(i,2)
                    ah = subplot(FIGMAT(i,1),FIGMAT(i,2),(j-1)*FIGMAT(i,2)+k);
                    set(ah,'nextplot','add');
                    AXESPIM = mdipii(AXESPIM,ah,i,j,k);
                end
            end
        end
    end
    sguivar('AXESPIM',AXESPIM,toolhan);
elseif strcmp(in1,'typemenu')
    [SIMWIN,SIMTYPE,TRSP_IDHANS,VISIBLE_MAT] = ...
	 gguivar('SIMWIN','SIMTYPE','TRSP_IDHANS','VISIBLE_MAT',toolhan);
    type = SIMTYPE(1);
    if in2 == 1                     % want continuous
        if type == 2                % was discrete time
            type = 1;
            set(SIMTYPE(2),'checked','on');
            set(SIMTYPE(3),'checked','off');
            set(TRSP_IDHANS(2),'enable','on');
            set(TRSP_IDHANS(10),'enable','on');
            set(TRSP_IDHANS(3),'enable','off');
            set(TRSP_IDHANS(11),'enable','off');
        elseif type == 3            % was sampled-data
            type = 1;
            set(SIMTYPE(2),'checked','on');
            set(SIMTYPE(4),'checked','off');
            set(TRSP_IDHANS(3),'enable','off');
            set(TRSP_IDHANS(11),'enable','off');
        end
    elseif in2 == 2                 % want discrete time
        if type == 1                % was continuous time
            type = 2;
            set(SIMTYPE(3),'checked','on');
            set(SIMTYPE(2),'checked','off');
            set(TRSP_IDHANS(2),'enable','off');
            set(TRSP_IDHANS(10),'enable','off');
            set(TRSP_IDHANS(3),'enable','on');
            set(TRSP_IDHANS(11),'enable','on');
        elseif type == 3            % was sampled-data
            type = 2;
            set(SIMTYPE(3),'checked','on');
            set(SIMTYPE(4),'checked','off');
            set(TRSP_IDHANS(2),'enable','off');
            set(TRSP_IDHANS(10),'enable','off');
        end
    elseif in2 == 3                 % want sampled data
        if type == 1                % was continuous time
            type = 3;
            set(SIMTYPE(4),'checked','on');
            set(SIMTYPE(2),'checked','off');
            set(TRSP_IDHANS(3),'enable','on');
            set(TRSP_IDHANS(11),'enable','on');
        elseif type == 2            % was discrete time
            type = 3;
            set(SIMTYPE(4),'checked','on');
            set(SIMTYPE(3),'checked','off');
            set(TRSP_IDHANS(2),'enable','on');
            set(TRSP_IDHANS(10),'enable','on');
        end
    end
    if type ~= SIMTYPE(1)
        [SELECTHAN,FIGMAT,AXESPIM] = ...
             gguivar('SELECTHAN','FIGMAT','AXESPIM',toolhan);
        [COMPSTAT,NAMESNOTCOMP] = gguivar('COMPSTAT','NAMESNOTCOMP',toolhan);
            if ~isempty(SELECTHAN)
            rowind = find(~isnan(FIGMAT(:,5)));
            for i=1:length(rowind)
                pagenum = i;
                rows    = FIGMAT(i,1);
                cols    = FIGMAT(i,2);
                for j=1:rows
                    for k=1:cols
                        ah = mdxpii(AXESPIM,i,j,k);
                        delete(get(ah,'children'));
                    end
                end
            end
                sguivar('YHANOLN',[],toolhan);
                sguivar('YHANOLP',[],toolhan);
                sguivar('YHANCLN',[],toolhan);
                sguivar('YHANCLP',[],toolhan);
                    VISIBLE_MAT = 0*VISIBLE_MAT;
                    scrolltb('namechange',SELECTHAN,NAMESNOTCOMP(2:5,:),...
                    [2:5]);
                    COMPSTAT(:,1) = zeros(4,1);  % everything out of date
            sguivar('COMPSTAT',COMPSTAT,toolhan);
        end
            simgui(SIMWIN,'dimcheck')
            simgui(SIMWIN,'computeenable');
    end
    sguivar('SIMTYPE',[type;SIMTYPE(2:4)],toolhan);
elseif strcmp(in1,'quit')
    [ALLFIGS,SIMWIN,PARMWIN,PRINTWIN] =...
    gguivar('ALLFIGS','SIMWIN','PARMWIN','PRINTWIN',toolhan);
    rowind = find(~isnan(ALLFIGS));
    allfigs = [ALLFIGS(rowind);SIMWIN;PARMWIN;PRINTWIN];
    mkdragtx('destroy',allfigs)
    [mainw,subw,others,splt] = findmuw;
    simsubs = xpii(subw,SIMWIN);
    if ~isempty(simsubs)
        delete(simsubs(:,1))
    end
    delete(SIMWIN);
end
