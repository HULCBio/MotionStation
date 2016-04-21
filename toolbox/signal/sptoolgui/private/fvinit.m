function varargout = fvinit(varargin)
%FVINIT Initialize filter viewer.

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $  $Date: 2004/04/13 00:32:57 $ 
 

    save_shh = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on')

    figname = prepender('Filter Viewer');

    toolnum = 1;  % which instance of the filter viewer

    visFrame = 'off';   % set frame around single popups invisible 
    if strcmp(visFrame,'off')
       indentPop = 15; 
    else
       indentPop = 0;
    end
    
    % ====================================================================
    % set defaults and initialize userdata structure
    filtview1Prefs = sptool('getprefs','filtview1');
    filtview2Prefs = sptool('getprefs','filtview2');
    rulerPrefs = sptool('getprefs','ruler');
    colorPrefs = sptool('getprefs','color');

    ud.prefs.tool.zoompersist = filtview1Prefs.zoomFlag;

    ud.prefs.colororder = colorPrefs.colorOrder;
    ud.prefs.linestyleorder = colorPrefs.linestyleOrder;

    % Ruler preferences
    ud.prefs.tool.ruler = filtview1Prefs.rulerEnable;    % rulersenabled 
    
    markerStr = { '+' 'o' '*' '.' 'x' ...
         'square' 'diamond' 'v' '^' '>' '<' 'pentagram' 'hexagram' }';
    typeStr = {'vertical' 'horizontal' 'track' 'slope'}';

    ud.prefs.ruler.color = rulerPrefs.rulerColor;
    ud.prefs.ruler.marker = markerStr{rulerPrefs.rulerMarker};
    ud.prefs.ruler.markersize = rulerPrefs.markerSize;
    ud.prefs.ruler.type = typeStr{rulerPrefs.initialType};
    
    ud.linecache.h = [];  % no line objects defined yet

    ud.lines = [];
    ud.SPToolIndices = [];
    ud.focusline = [];
    ud.focusIndex = 1;
    ud.colorCount = 0;  % number of colors allocated thus far
    ud.colororder = num2cell(evalin('base',ud.prefs.colororder),2);
    ud.linestyleorder = num2cell(evalin('base',ud.prefs.linestyleorder),2);

    for i = 1:6  % number of subplots
      ud.limits(i).xlim = [0 1];
      ud.limits(i).ylim = [0 1];
    end

    ud.prefs.nfft = evalin('base',filtview1Prefs.nfft);
    ud.prefs.nimp = evalin('base',filtview1Prefs.nimp);
            % Length of impulse / step response ([] ==> auto)
                                    
    ud.prefs.magmode = {'linear' 'log' 'decibels'};
    ud.prefs.magmode = ud.prefs.magmode{filtview1Prefs.magscale};
    ud.prefs.phasemode = {'degrees' 'radians'};
    ud.prefs.phasemode = ud.prefs.phasemode{filtview1Prefs.phaseunits};
    ud.prefs.freqscale = {'linear' 'log'};
    ud.prefs.freqscale = ud.prefs.freqscale{filtview1Prefs.freqscale};
    ud.prefs.freqrange = filtview1Prefs.freqrange;
            % 1==[0 Fs/2], 2==[0 Fs], 3==[-Fs/2 Fs/2]
                        
    if filtview2Prefs.mode1
        ud.prefs.tilemode = [2 3];
    elseif filtview2Prefs.mode2
        ud.prefs.tilemode = [3 2];
    elseif filtview2Prefs.mode3
        ud.prefs.tilemode = [6 1];
    elseif filtview2Prefs.mode4
        ud.prefs.tilemode = [1 6];
    end
            
    ud.prefs.plots = [1 1 0 0 0 0]';  
    realFilterFlag = 1; 
    ud.prefs.plottitles = filtview('plotTitles',realFilterFlag);
    ud.prefs.plotspacing = [40 35 10 20]; 
        % spacing in pixels from [left bottom right top] 
        % lots of room: [40 40 20 25]
    scalefactor = (get(0,'screenpixelsperinch')/72)^.5;
    ud.prefs.plotspacing = ud.prefs.plotspacing*scalefactor;
    
    co = get(0,'defaultaxescolororder');
    ud.prefs.linecolor = co(1,:);

    ud.sz = sptsizes;
    ud.sz.bw = ud.sz.bw+10;
    
    ud.justzoom = [ -1 -1 ] ;  % used for mode switching (between zoom and pan)
             % justzoom is set to the current point after a zoom, and is reset
             % by a call to justzoom.m to [0 0]
             % Set to [-1 -1] now since currentpoint is [0 0] for an invisible
             % figure
    filtDefined = 0; 
    
    %
    % Initialize ud.filt 
    %
    switch nargin
    case 0
        makeParams = {1 1 1};
    case 1
        for i = 1:length(varargin{1})  % Loop through all selected filters
            if isstruct(varargin{1}(i))
                [valid,ud.filt(i)] = importfilt('valid',varargin{1}(i));
                if ~valid
                    error('Input is not a valid Filter structure.')
                end
                filtDefined = 1;
            else
                makeParams = {varargin{1} 1 1};
            end
        end
    case 2
            makeParams = {varargin{1:2} 1};
    case 3
            makeParams = varargin;
    end
    if ~filtDefined
        [err,errstr,ud.filt] = importfilt('make',{1 makeParams{:}});
        if err
            error(errstr)
        end
    end
    
    ud.prefs.Fs = sprintf('%.9g',max([ud.filt.Fs]));

    ud.prefs.rulerPrefsPanelName = 'filtview1'; %ruler needs to know this so
       % it can update the SPTOOL preferences when it is turned on/off

    ud.tilefig = [];  % handle to tile dialog box figure
    ud.loadfig = [];  % handle to Load dialog box figure
    ud.tabfig = [];  % settings figure handle
    ud.toolnum = toolnum;
    
    ud.pointer = 0;  % pointer mode ...  == -1 watch, 0 arrow/drag indicators, 
                     %     1 zoom, 2 help
    sz = ud.sz;

    screensize = get(0,'screensize');
    
    % minimum width, height of figure window;
    ud.resize.minsize = [3*sz.bw+9*sz.fus+ud.sz.rw+60 ...
                         sz.ih+16*sz.fus+11*sz.uh+4*sz.lh];   
       % actual values on PCWIN [595  419];
       % Fontsize (therefore label height, sz.lh) on UNIX is smaller 
       % therefore actual values on UNIX [595  403]
       
    ud.resize.leftwidth = sz.bw+6*sz.fus;
    ud.left_width = ud.resize.leftwidth;  % used by ruler.m for positioning
    ud.resize.topheight = 0; %sz.ih;
    
    fp = get(0,'defaultfigureposition');
    
    % Give UNIX figures a little more height so that the ruler panel fits
    % By default figures on UNIX platforms are smaller
    if ~strcmp(computer,'PCWIN') & ~strcmp(computer,'MAC2')
        fp = fp + [0 -20 0 20];    % Arbitrarily add (enough) 20 to the height
    end
    
    w = max(ud.resize.minsize(1),fp(3))+ud.sz.rw;
    h = max(ud.resize.minsize(2),fp(4));
    fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper-left corner stationary
    
    % ====================================================================
    % Save figure position for use in resizefcn:   
    ud.resize.figpos = fp;
    
    % CREATE FIGURE
    fig = figure('createfcn','',...
            'closerequestfcn','filtview(''SPTclose'')',...
            'tag','filtview',...
            'numbertitle','off',...
            'dockcontrols','off',...
            'integerhandle','off',...
            'userdata',ud,...
            'units','pixels',...
            'position',fp,...
            'menubar','none',...
            'inverthardcopy','off',...
            'paperpositionmode','auto',...
            'visible','off',...
            'name',figname,...
            'resizefcn','sbswitch(''resizedispatch'')%');


    uibgcolor = get(0,'defaultuicontrolbackgroundcolor');
    uifgcolor = get(0,'defaultuicontrolforegroundcolor');

    % ====================================================================
    % MENUs
    %  create cell array with {menu label, callback, tag}

 %  MENU LABEL                     CALLBACK                      TAG
mc={ 
 'File'                              ' '                        'filemenu'
 '>Pa&ge Setup...'                   'printcomp(''pgepos'')'    'pagepos'
 '>Print Pre&view...'                'printcomp(''prev'')'      'printprev'
 '>&Print...'                        'printcomp(''prnt'')'      'prnt'
 '>---'                              ' '                        ' '
 '>&Close^w'                         'close'                    'closemenu'
 '&Window'                           winmenu('callback')        'winmenu'    };
 
% 'Options'                           ' '                        'optionsmenu'
% '>&Tile Axes...'                    'sbswitch(''fvtile'')'     'tilemenu'

    % Build the cell array string for the Help menu.
    mh = filtview_helpmenu;
	mc = [mc;mh];
    mc = ruler('makemenu',mc);  % add Marker menu

    menu_handles = makemenu(fig, char(mc(:,1)), ...
                            char(mc(:,2)), char(mc(:,3)));
    winmenu(fig)
    
 %   set(menu_handles,'hiddenhandle','on')
 %   ud.ht.reloadmenu = menu_handles(3);
 %   set(menu_handles(3),'enable','off')
    
    % ====================================================================
    % Frames

    f1 = [1 0 sz.bw+6*sz.ffs-1 fp(4)-sz.ih];
    ud.ht.frame1 = uicontrol('units','pixels',...
              'style','frame','position',f1,'tag','mainframe');

    f2 = [1 fp(4)-sz.ih-1 sz.bw+6*sz.ffs-1 sz.ih+1];
    ud.ht.frame2 = uicontrol('units','pixels',...
              'style','frame','position',f2,'tag','filtlabelframe');

    pf_height = 8*sz.fus+8.5*sz.uh;
    pf =  [  f1(1)+sz.fus      f1(2)+f1(4)-(sz.lh/2+sz.fus+pf_height) ...
             f1(3)-2*sz.fus    pf_height  ];
    ud.ht.plotsframe = uicontrol('units','pixels',...
              'style','frame','position',pf,'tag','plotframe');
    freqframeHt = 4*sz.fus+2*sz.uh+2.5*sz.lh;
    ff = [sz.fus pf(2)-freqframeHt-sz.fus-sz.lh/2 4*sz.fus+sz.bw freqframeHt];
    ud.ht.freqframe = uicontrol('units','pixels',...
              'style','frame','tag','freqframe',...
              'position',ff);

    mf = [pf(1)+sz.fus pf(2)+pf(4)-(sz.lh/2+sz.fus+2*sz.uh+sz.fus)+4 ...
             pf(3)-2*sz.fus  sz.fus+1.5*sz.uh];
    ud.ht.magframe = uicontrol('units','pixels','visible',visFrame,...
              'style','frame','position',mf,'tag','magframe');
    phf = [pf(1)+sz.fus pf(2)+pf(4)-(sz.lh/2+2*sz.fus+4*sz.uh+2*sz.fus)+5 ...
             pf(3)-2*sz.fus  sz.fus+1.5*sz.uh];
    ud.ht.phaseframe = uicontrol('units','pixels','visible',visFrame,...
              'style','frame','position',phf,'tag','phaseframe');

    fsf = [ff(1)+sz.fus ff(2)+ff(4)-(sz.fus+sz.uh+1.5*sz.lh) ...
           ff(3)-2*sz.fus sz.fus+sz.uh+.5*sz.lh];
    ud.ht.fscaleframe = uicontrol('units','pixels','visible',visFrame,...
              'style','frame','tag','freqsframe',...
              'position',fsf);

    frf = [ff(1)+sz.fus ff(2)+1.5*sz.fus ...
           ff(3)-2*sz.fus sz.fus+sz.uh+.5*sz.lh];
    ud.ht.frangeframe = uicontrol('units','pixels','visible',visFrame,...
              'style','frame','tag','freqrframe',...
              'position',frf);

   % ud.ht.Fsframe = uicontrol('units','pixels',...
   %           'style','frame','tag','fsframe','position',...
   %             [sz.fus sz.fus ...
   %              4*sz.fus+sz.bw sz.fus+sz.uh+.5*sz.lh]);

    % ====================================================================
    % Labels

    ud.ht.plotslabel = framelab(ud.ht.plotsframe,'Plots',sz.lfs,sz.lh,'tag','plottext');
    ud.ht.freqlabel = framelab(ud.ht.freqframe,'Frequency Axis',sz.lfs,sz.lh,'tag','freqtext');
    ud.ht.fscalelabel = framelab(ud.ht.fscaleframe,'Scale',sz.lfs,sz.lh,'tag','freqstext');
    ud.ht.frangelabel = framelab(ud.ht.frangeframe,'Range',sz.lfs,sz.lh,'tag','freqrtext');
    
    ud.ht.filterLabel = uicontrol('style','text',...
                'horizontalalignment','left',...
                'tag','filterLabel',...
                'position',[sz.fus fp(4)-2-19 sz.bw 19]);
    ud.ht.Fsedit = uicontrol('style','text',...
                'horizontalalignment','left',...
                'tag','fsbox',...
                'position',[sz.fus fp(4)-4-2*19 sz.bw 19]);

    [FsStr filtLabelStr] = filtview('filtFsLabelStrs', ...
        ud.prefs,ud.ht,ud.filt);
    set(ud.ht.filterLabel, 'string',filtLabelStr)
    set( ud.ht.Fsedit,'string',FsStr)
    
    % framelab(ud.ht.Fsframe,'Sampling Freq.',sz.lfs,sz.lh,'tag','fstext');

    % ====================================================================
    % Checkboxes
    cb_props = {'units','pixels',...
              'style','checkbox','horizontalalignment','left'};
 
    checkbox_width = 15; % The checkbox part of the uicontrol

    cb1_pos = [mf(1)+sz.fus mf(2)+sz.uh+sz.fus sz.bw sz.uh];
    ud.ht.cb(1) = uicontrol(cb_props{:},...
        'string','Magnitude',...
        'tag','magcheck',...
        'value',ud.prefs.plots(1),...
        'callback','filtview(''cb'',1)',...
	'position',cb1_pos);
    if ~isunix
       label_ext = get(ud.ht.cb(1),'extent');
       cb1_pos(3) = label_ext(3)+checkbox_width;
       set(ud.ht.cb(1),'position', cb1_pos);
    end
    
    cb2_pos = [phf(1)+sz.fus phf(2)+sz.uh+sz.fus sz.bw sz.uh];
    ud.ht.cb(2) = uicontrol(cb_props{:},...
        'string','Phase',...
        'tag','phasecheck',...
        'value',ud.prefs.plots(2),...
	'callback','filtview(''cb'',2)',...
	'position',cb2_pos);
    if ~isunix
       label_ext = get(ud.ht.cb(2),'extent');
       cb2_pos(3) = label_ext(3)+checkbox_width;
       set(ud.ht.cb(2),'position', cb2_pos);
    end    

    ud.ht.cb(3) = uicontrol(cb_props{:},...
       'string','Group Delay',...
       'tag','groupdelay',...
       'value',ud.prefs.plots(3),...
       'callback','filtview(''cb'',3)',...
       'position',[pf(1)+2*sz.fus pf(2)+4*sz.fus+3*sz.uh sz.bw sz.uh]);
    ud.ht.cb(4) = uicontrol(cb_props{:},...
       'string','Zeros and Poles',...
       'tag','polezero',...
       'value',ud.prefs.plots(4),...
       'callback','filtview(''cb'',4)',...
       'position',[pf(1)+2*sz.fus pf(2)+3*sz.fus+2*sz.uh sz.bw sz.uh]);
    ud.ht.cb(5) = uicontrol(cb_props{:},...
       'string','Impulse Response',...
       'tag','impresp',...
       'value',ud.prefs.plots(5),...
       'callback','filtview(''cb'',5)',...
       'position',[pf(1)+2*sz.fus pf(2)+2*sz.fus+sz.uh sz.bw sz.uh]);
    ud.ht.cb(6) = uicontrol(cb_props{:},...
       'string','Step Response',...
       'tag','stepresp',...
       'value',ud.prefs.plots(6),...
       'callback','filtview(''cb'',6)',...
       'position',[pf(1)+2*sz.fus pf(2)+sz.fus sz.bw sz.uh]);

    % ====================================================================
    % Popups
    pop_props = {'units','pixels','BackgroundColor','white',...
              'style','popup','horizontalalignment','left'};

    % Tweak position & size of popups: [horz_pos ver_pos width height]
    switch computer
    case 'MAC2'
       popTweak = [0 -2 0 0];
    case 'PCWIN'
       popTweak = [0  0 0 0];
    otherwise  % UNIX
       popTweak = [0 -2 0 0];
    end
  
    switch ud.prefs.magmode
    case 'linear'
       magpopvalue = 1;
    case 'log'
       magpopvalue = 2;
    case 'decibels'
       magpopvalue = 3;
    end
    
    ud.ht.magpop = uicontrol(pop_props{:},...
       'string',{'linear'; 'log'; 'decibels'},...
       'tag','maglist',...
       'callback','filtview(''magpop'')',...
       'value',magpopvalue,...
       'position',[mf(1:2)+sz.fus+[indentPop 0] sz.bw-indentPop sz.uh]+popTweak);

    switch ud.prefs.phasemode
    case 'degrees'
       phasepopvalue = 1;
    case 'radians'
       phasepopvalue = 2;
    end

    ud.ht.phasepop = uicontrol(pop_props{:},...
       'string',{'degrees'; 'radians'},...
       'tag','phaselist',...
       'callback','filtview(''phasepop'')',...
       'value',phasepopvalue,...
       'position',[phf(1:2)+sz.fus+[indentPop 0] sz.bw-indentPop sz.uh]+popTweak);
 
    switch ud.prefs.freqscale
    case 'linear'
        fscalevalue = 1;
    case 'log'
        fscalevalue = 2;
    end
    ud.ht.fscalepop = uicontrol(pop_props{:},...
       'string',{'linear'; 'log'},...
       'tag','freqscale',...
       'callback','filtview(''fscalepop'')',...
       'value',fscalevalue,...
       'position',[fsf(1:2)+sz.fus+[indentPop 0] sz.bw-indentPop sz.uh]+popTweak);

    ud.ht.frangepop = uicontrol(pop_props{:},...
       'string',{'[0,Fs/2]'; '[0,Fs]'; '[-Fs/2,Fs/2]'},...
       'tag','freqrange',...
       'callback','filtview(''frangepop'')',...
       'value',ud.prefs.freqrange,...
       'position',[frf(1:2)+sz.fus+[indentPop 0] sz.bw-indentPop sz.uh]+popTweak);

    % ====================================================================
    % Create axes:

    ax_props = {
         'units','pixels',...
         'box','on',...
         'parent',fig};

    ud.ht.highlightAxes = axes(ax_props{:},'xtick',[],'ytick',[],'visible','off');
    % create axes:
    for i=1:6
        ud.ht.a(i) = axes(ax_props{:});
        set(ud.ht.a(i),'buttondownfcn',['filtview(''mainaxes_down'',' num2str(i) ')']);
        if i == 4   % Zero-Pole plot
            w = linspace(0,2*pi,201);
            zgrid = line(cos(w),sin(w), ...
                 'color',get(ud.ht.a(4),'xcolor'),...
                'linestyle',':',...
                'tag','unitcircle',...
                'parent',ud.ht.a(4));
        end
    end

    ud.titles = {   'Magnitude' 
                    { 'Phase (degrees)' 'Phase (radians)' } 
                    'Group Delay' 
                    'Zeros & Poles' 
                    'Impulse Response'
                    'Step Response'};

    ud.tags =    { 'magaxes'
                   'phaseaxes'
                   'delayaxes'
                   'pzaxes'
                   'impaxes'
                   'stepaxes' };

    ud.xlabels = {  'Frequency'
                    'Frequency'
                    'Frequency'
                    'Real'
                    'Time'
                    'Time' };
  
    ud.ylabels = {  ''
                    ''
                    ''
                    'Imaginary'
                    ''
                    ''};

    th = get(ud.ht.a,'title');
    set([th{[1 3:6]}],{'string'},ud.titles([1 3:6]))
    switch ud.prefs.phasemode
    case 'degrees'
        set(th{2},'string',ud.titles{2}(1))
    case 'radians'
        set(th{2},'string',ud.titles{2}(2))
    end
    if fscalevalue == 2
        set(ud.ht.a([1 2 3]),'xscale','log')
    end
    if magpopvalue == 2
        set(ud.ht.a(1),'yscale','log')
    end

    set([th{:}],{'tag'},ud.tags)
    set(ud.ht.a,{'tag'},ud.tags)
    xh = get(ud.ht.a,'xlabel');
    set([xh{:}],{'string'},ud.xlabels,{'tag'},ud.tags)
    yh = get(ud.ht.a,'ylabel');
    set([yh{:}],{'string'},ud.ylabels,{'tag'},ud.tags)

    % ==================================================================
    % Identify Main axes - axes where rulers are focused

    % Let Magnitude plot be the default mainaxes
    mainaxes = ud.ht.a(1);
    set(mainaxes,'handlevisibility','callback');
    ud.mainaxes = mainaxes;

    % ====================================================================
    % initialize lines to []
    for i = 1:length(ud.filt)
        if ~isstruct(ud.lines)
            ud.lines = filtview('emptyLinesStruct');
        else
            ud.lines(i) = filtview('emptyLinesStruct');
        end
    end

    % ====================================================================
    % Create context menu for lines in plot axes:  TPK 6/5/99
    ud.contextMenu.u = uicontextmenu('parent',fig);
    ud.contextMenu.pickMenu = uimenu(ud.contextMenu.u);  
    ud.contextMenu.changeName = uimenu(ud.contextMenu.pickMenu);
    ud.contextMenu.Fs = uimenu(ud.contextMenu.pickMenu);
    ud.contextMenu.lineprop = uimenu(ud.contextMenu.pickMenu);

    set(ud.ht.a,'uicontextmenu',ud.contextMenu.u)
    
    % ====================================================================
    % Save userdata structure
    set(fig,'userdata',ud)
    
    % ====================================================================
    % now add toolbar for filter viewer
    % NEW toolbar, using uitoolbar functionality, available as of 5.3:
    ud = create_toolbar(fig);
    set(fig,'userdata',ud)

    set(fig,'resizefcn',...
            appstr(get(fig,'resizefcn'),'sbswitch(''fvresize'')'))
    set(fig,'windowbuttonmotionfcn',...
          ['sbswitch(''fvmotion'',' num2str(ud.toolnum) ')'])
    set(fig,'HandleVisibility','callback')

    % ====================================================================
    % create legend - changes userdata
    sptlegend(fig,'filtview(''changefocus'')','filtview',1)
    ud = get(fig,'userdata');
    
    % ====================================================================    
    % Do the plots - changes userdata
    filtview('plots',ud.prefs.plots)
    ud = get(fig,'userdata');
  
    % ====================================================================
    % display the rulers on the default plot (magnitude);
    if 1   % ud.prefs.tool.ruler    ALWAYS initialize rulers, turn off after
                                   % if not enabled
        saveRulerFlag = ud.prefs.tool.ruler;
        plotPopVal = 1;       % mag plot is default
        realFilterFlag = (isreal(ud.filt(ud.focusIndex).tf.num) &...
            isreal(ud.filt(ud.focusIndex).tf.den));
        ud.prefs.plottitles = filtview('plotTitles',realFilterFlag);
        set(fig,'userdata',ud)

        popupCallback = 'filtview(''rulerpopup'')';	
        ruler('init',fig,ud.prefs.plottitles,plotPopVal,popupCallback,...
            ud.ht.a,[1 2 3 5 6]);
        ud = get(fig,'userdata');    
    else
        %set([ud.toolbar.zoominx ud.toolbar.zoominy ...
        %     ud.toolbar.zoomoutx ud.toolbar.zoomouty],'enable','off')
    end
    
    ud.focusline = ud.lines(ud.focusIndex).mag; % mag plot is default 
    set(fig,'userdata',ud)

    % ====================================================================
    % Initialize legend; set color and line style of all filters
    ud = get(fig,'userdata');

    for i = 1:length(ud.filt)
        if isempty(ud.filt(i).lineinfo)
            % assign line color and style to each filter
            [ud.filt(i).lineinfo,ud.colorCount] = ...
                nextcolor(ud.colororder,ud.linestyleorder,ud.colorCount);
            % poke back into SPTool
            sptool('import',ud.filt(i))            
        end

        % Set line color & style for the rest of the lines for each filter
        handleCell = struct2cell(ud.lines(i));
        h = [handleCell{:}];
        set(h,'color',ud.filt(i).lineinfo.color, ...
            'linestyle',ud.filt(i).lineinfo.linestyle)
    end
    set(fig,'userdata',ud)
    
    sptlegend('setstring',{ud.filt.label},{},fig,0)
    sptlegend('setvalue',ud.focusline,ud.focusIndex,1,fig)
    %set(ud.legend.legendline,'linestyle', ...
    %    ud.filt(ud.focusIndex).lineinfo.linestyle)

    % ====================================================================
    % position axes:
    fvresize(1,fig)
    ruler('resize',1,fig)

    ut = get(ud.toolbar.whatsthis,'parent');
    tbfillblanks(ut,ud.toolbar.lineprop,ud.toolbar)

    % set ud.limits of 2 visible plots (the default plots, phase and mag)
    ud = get(fig,'userdata');
    ud = filtview('setudlimits',ud,ud.ht.a,[1 2]); 
    set(fig,'userdata',ud)

    % Now highlight the main axes:
    moveRulerFlag = 0;

    filtview('mainaxes_down',1,moveRulerFlag)

    if saveRulerFlag
        ruler('newlimits',fig)
        ruler('newsig',fig)
        ruler('showlines',fig)
    else
        ud=get(fig,'userdata');
        ud.prefs.tool.ruler = 0;
        set(fig,'userdata',ud)
        ruler('close',fig)
    end

    set(fig,'visible','on')
    set(0,'showhiddenhandles',save_shh)

%-------------------------------------------------------------------------------
function ud = create_toolbar(fig)
% CREATE_TOOLBAR Creates the toolbar for the Filter Viewer.
%
ud = get(fig,'userdata');
load siggui_icons
ut=uitoolbar(fig);
ud.toolbar.print = ...
    uipushtool('cdata',bmp.print,...
                 'parent',ut,...
                 'clickedcallback','printcomp(''prnt'')' ,...
                 'tooltipstring',xlate('Print...'));
ud.toolbar.printpreview = ...
    uipushtool('cdata',bmp.printpreview,...
                 'parent',ut,...
                 'clickedcallback','printcomp(''prev'')' ,...
                 'tooltipstring',xlate('Print Preview...'));
ud.toolbar.mousezoom = ...
    uitoggletool('cdata',bmp.mousezoom,...
                 'separator','on',...
                 'parent',ut,...
                 'clickedcallback','sbswitch(''fvzoom'',''mousezoom'')',...
                 'tooltipstring',xlate('Mouse Zoom'));
ud.toolbar.fullviewall = ...
    uipushtool('cdata',bmp.fullviewall,...
                 'parent',ut,...
                 'clickedcallback','sbswitch(''fvzoom'',''zoomout'',''all'')',...
                 'tooltipstring',xlate('Full View All (zooms out both axes, all plots)')); 
ud.toolbar.fullview = ...
    uipushtool('cdata',bmp.fullview,...
                 'parent',ut,...
                 'clickedcallback','sbswitch(''fvzoom'',''zoomout'')',...
                 'tooltipstring',xlate('Full View (zooms out both axes, selected plot)')); 
ud.toolbar.zoominy = ...
    uipushtool('cdata',bmp.zoominy,...
                 'parent',ut,...
                 'clickedcallback','sbswitch(''fvzoom'',''zoominy'')',...
                 'tooltipstring',xlate('Zoom In - Y (vertical axis)'));
ud.toolbar.zoomouty = ...
    uipushtool('cdata',bmp.zoomouty,...
                 'parent',ut,...
                 'clickedcallback','sbswitch(''fvzoom'',''zoomouty'')',...
                 'tooltipstring',xlate('Zoom Out - Y (vertical axis)'));
ud.toolbar.zoominx = ...
    uipushtool('cdata',bmp.zoominx,...
                 'parent',ut,...
                 'clickedcallback','sbswitch(''fvzoom'',''zoominx'')',...
                 'tooltipstring',xlate('Zoom In - X (horizontal axis)'));
ud.toolbar.zoomoutx = ...
    uipushtool('cdata',bmp.zoomoutx,...
                 'parent',ut,...
                 'clickedcallback','sbswitch(''fvzoom'',''zoomoutx'')',...
                 'tooltipstring',xlate('Zoom Out - X (horizontal axis)'));
ud.toolbar.select = ...
    uipushtool('cdata',bmp.select,...
                 'parent',ut,...
                 'separator','on',...
                 'clickedcallback','sbswitch(''sptlegend'',''popup'')' ,...
                 'tooltipstring',xlate('Select signal...'));
ud.toolbar.lineprop = ...
    uipushtool('cdata',bmp.lineprop,...
                 'parent',ut,...
                 'clickedcallback','sbswitch(''sptlegend'',''button'')' ,...
                 'tooltipstring',xlate('Line Properties...'));
ud.toolbar = ruler('toolbarbuttons',ud.toolbar,ut,bmp);

ud.toolbar.whatsthis = ...
    uitoggletool('cdata',bmp.whatsthis,...
                 'parent',ut,...
                 'separator','on',...
                 'clickedcallback','sbswitch(''filtview'',''help'')' ,...
                 'tooltipstring',xlate('"What''s This?" Help'));

%------------------------------------------------------------------------------
function mh = filtview_helpmenu
% Set up a string cell array that can be passed to makemenu to create the Help
% menu for the Filter Viewer.
  
% Define specifics for the Help menu in Filter Viewer.
toolname      = 'Filter Viewer';
toolhelp_cb   = 'filtview(''help'',''topics'')';
toolhelp_tag  = 'helptopicsmenu';
whatsthis_cb  = 'filtview(''help'',''whatsthis'')';
whatsthis_tag = 'whatsthismenu';

% Add other Help menu choices that are common to all SPTool clients.
mh=sptool_helpmenu(toolname,toolhelp_cb,toolhelp_tag,whatsthis_cb,whatsthis_tag);

% [EOF] fvinit.m
