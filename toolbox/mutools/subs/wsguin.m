%   function wsguin(toolhan,message,in1,in2,in3,in4)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.15.4.3 $

function wsguin(toolhan,message,in1,in2,in3,in4)

mlvers = version;
if str2double(mlvers(1)) < 4
    error('Need Matlab Version 4 or better to run wsgui.');
    return
end

if nargin == 0
   toolhan = 0; % dummy, not used
   message = 'create';
elseif isempty(toolhan)
        if ~isempty(get(0,'children'))
                toolhan = gcf;
        end
end

if ~strcmp(message,'create') & ~strcmp(message,'hide')
    addrunf(toolhan,get(0,'chi'));
end

if strcmp(message,'create')
    TOOLTYPE = 'wksp';
        
%   Declare all GUI variables
    mudeclar;   % initialize
    mudeclar('ALLNAMES','ALLNAMESLEN','ALLINFO','SELITEMS','AXESHAN','BINLOC','SELECT_PO');
    mudeclar('MESSAGE','SR_BUT','REFMESS','TOOLTYPE','PSHAN','CUSTOM','SELTOR','SELSTAT');
    mudeclar('RIGHTHAND','LEFTHAND','APPLYSTAT','EXPMESS','CUSITEMS','WIN','FIXC','FONT');
    mudeclar('NUMLINES','DRAGAX','FONTHANS','LINEHANS','TMP','CWIN','SWIN','SFILE','RUNNING')
    [VN,PIM] = mudeclar('mkvar');

%   Create Main Window    
    ss = get(0,'screensize');
    winpos = [ss(3)/2-300 ss(4)/2-220 500 310];
    litgray = [192 192 192]/255;
    medgray = [128 128 128]/255;
    wincol = litgray;
    WIN = figure('color',wincol,...
        'menubar','none',...
        'Numbertitle','off',...
        'visible','off',...
        'pointer','watch',...
        'position',winpos,...
        'BusyAction','queue',...
        'Interruptible','off',...
        'DoubleBuffer','on',...
        'resize','off', ...
        'DockControls', 'off');
    WINDOWPRE = ['muTools(' int2str(WIN) '): '];
    set(WIN,'Name',[WINDOWPRE 'Workspace Manager']);

    [a1,a2,a3,a4] = findmuw(get(0,'chi'));
    if ~isempty(a1)
        runkeeper = min(a1);
        if WIN<runkeeper
            RUNNING = gguivar('RUNNING',runkeeper);
        else
            RUNNING = [];
        end
    else
        RUNNING = [];
    end
    
%   Create CLEAR window 
    bw = 90; bh = 30; xbo = 15; ybo = 15; ymbo = 10; xmbo = 12; th = 20;
    cwinw = xbo + bw + xmbo + bw + xbo;
    cwinh = ybo + bh + ymbo + th + ybo;
    cwinpos = [winpos(1)+120 winpos(2)+winpos(4)-cwinh-30 cwinw cwinh];
    cwincol = litgray;
%	'nextplot','new',...   GJW 09/10/96
    CWIN = figure('color',cwincol,...
        'menubar','none',...
        'Numbertitle','off',...
        'visible','off',...
        'pointer','watch',...
        'position',cwinpos, ...
        'DockControls', 'off');
    uicontrol('style','pushbutton','string','Clear',...
        'position',[xbo ybo bw bh],...
        'callback',...
        'wsguin([],''clear'');eval(gguivar(''TMP''));wsguin([],''resetsel'');wsguin([],''refill'');');
    uicontrol('style','pushbutton','string','Cancel',...
        'callback','set(gcf,''visible'',''off'')',...
        'position',[xbo+bw+xmbo ybo bw bh]);
    uicontrol('style','text','string','Clear all selected matrices',...
        'horizontalalignment','left',...
        'backgroundcolor',cwincol,...
        'position',[xbo ybo+bh+ymbo bw+xmbo+bw th]);
%   Create SAVE window 
    bw = 90; bh = 30; xbo = 15; ybo = 15; ytbo = 5; ymbo = 10; xmbo = 12; th = 20;
    swinw = xbo + bw + xmbo + bw + xbo;
    swinh = ybo + bh + ymbo + th + ytbo + th + ybo;
    swinpos = [winpos(1)+120 winpos(2)+winpos(4)-swinh-30 swinw swinh];
    swincol = litgray;
%	'nextplot','new',...   GJW 09/10/96
    SWIN = figure('color',swincol,...
        'menubar','none',...
        'Numbertitle','off',...
        'visible','off',...
        'pointer','watch',...
        'position',swinpos, ...
        'DockControls', 'off');
    uicontrol('style','pushbutton','string','Save',...
        'position',[xbo ybo bw bh],...
        'enable','on',...
        'callback','wsguin([],''save'');eval(gguivar(''TMP''));');
    uicontrol('style','pushbutton','string','Cancel',...
        'callback','set(gcf,''visible'',''off'')',...
        'position',[xbo+bw+xmbo ybo bw bh]);
    SFILE = uicontrol('style','edit','horizontalalignment','left',...
        'string','savefile',...
        'backgroundcolor',[1 1 1],...
        'position',[xbo ybo+bh+ymbo bw+xmbo+bw th]);
    uicontrol('style','text','string','Save selected matrices as...',...
        'horizontalalignment','left',...
        'backgroundcolor',swincol,...
        'position',[xbo ybo+bh+ymbo+th+ytbo bw+xmbo+bw th]);

    puter = computer;    
%   Menus
    fs = [7;8;9;10;11;12];
    nl = [8;12;20;28;36];    
    uselines = 1;
    if strcmp('PCWIN',puter)
        fs = [7;8;9;10;11;12];
        usefont = 2;
        tmp = uimenu(WIN,'Label','&File');
        ttmp = uimenu(tmp,'label','&Clear Selected Matrices',...
            'callback','wsguin([],''mkclear'')');
        ttmp = uimenu(tmp,'label','&Save Selected Matrices','callback','wsguin([],''mksave'');');
        ttmp = uimenu(tmp,'label','&Quit','callback','wsguin([],''quit'');');
        tmp = uimenu(WIN,'Label','&Options');
        ttmp = uimenu(tmp,'label','&CleanUp','callback','wsguin([],''cleanup'');');
        tttmp = uimenu(tmp,'label','Fo&nt','separator','on');
    elseif strcmp('MAC2',puter)
        fs = [8;9;10;11;12;14];
        usefont = 3;
        tmp = uimenu(WIN,'Label','File');
        ttmp = uimenu(tmp,'label','Clear Selected Matrices',...
            'callback','wsguin([],''mkclear'')');
        ttmp = uimenu(tmp,'label','Save Selected Matrices','callback','wsguin([],''mksave'');');
        ttmp = uimenu(tmp,'label','Quit','callback','wsguin([],''quit'');');
        tmp = uimenu(WIN,'Label','Options');
        ttmp = uimenu(tmp,'label','CleanUp','callback','wsguin([],''cleanup'');');
        tttmp = uimenu(tmp,'label','Font','separator','on');
    else
        fs = [8;9;10;11;12;14];
        usefont = 3;
        tmp = uimenu(WIN,'Label','File');
        ttmp = uimenu(tmp,'label','Clear Selected Matrices',...
            'callback','wsguin([],''mkclear'')');
        ttmp = uimenu(tmp,'label','Save Selected Matrices','callback','wsguin([],''mksave'');');
        ttmp = uimenu(tmp,'label','Quit','callback','wsguin([],''quit'');');
        tmp = uimenu(WIN,'Label','Options');
        ttmp = uimenu(tmp,'label','CleanUp','callback','wsguin([],''cleanup'');');
        tttmp = uimenu(tmp,'label','Font','separator','on');
    end
    FONT = fs(usefont);
    NUMLINES = nl(uselines);
    FONTHANS = zeros(length(fs),1);
    for i=1:length(fs)
        FONTHANS(i) = uimenu(tttmp,'label',int2str(fs(i)),'callback',...
            ['wsguin([],''font'',' int2str(fs(i)) ',' int2str(i) ');']);
    end
    ttttmp = uimenu(tmp,'label','# of Lines','separator','on');
    LINEHANS = zeros(length(nl),1);
    for i=1:length(nl)
        LINEHANS(i) = uimenu(ttttmp,'label',int2str(nl(i)),'callback',...
            ['wsguin([],''lines'',' int2str(nl(i)) ',' int2str(i) ');']);
    end
    set(LINEHANS(uselines),'checked','on');
    set(FONTHANS(usefont),'checked','on');

%   create axes & dummy icon for dragable text and dropboxes
    DRAGAX = mkdragtx('create',WIN);
    set(DRAGAX,'xlim',[0 1],'ylim',[0 1]);

    FIXC = zeros(10,1);
    topborder = 21;     % see axespos (about line 465)
    boty = 1;
    leftx = 0;
    messoffset = 3;
    rightx = winpos(3)-leftx;
    vgap = 4;
    hgap = 6;
    % these are relevant when considering font/resolution
    messh = 20;
    buth = 21;
    butw = 52;
    EXPMESS = uicontrol('style','text',...
            'backgroundcolor',wincol,...
            'horizontalalignment','left',...
            'position',[leftx+messoffset boty rightx-leftx-messoffset messh],...
            'string',' ');
    butbot = boty+messh+vgap;
    EXPBUT = uicontrol('style','pushbutton',...
            'backgroundcolor',wincol,...
            'horizontalalignment','left',...
            'position',[leftx butbot butw buth],...
            'string','Export',...
            'callback','wsguicb',...
            'enable','on');
    binw = 40;
    binh = 22;
    binxl = leftx+butw+hgap;
    binx = [binxl;binxl;binxl+binw;binxl+binw];
    binyb = butbot+(buth-binh)/2;
    biny = [binyb+binh;binyb;binyb;binyb+binh];
    FIXC(5:8) = [binxl;binyb;binw;binh];
    nbinx = binx/winpos(3);
    nbiny = biny/winpos(4);
    axes(DRAGAX);
    binline = line(nbinx,nbiny,'color',[0 0 0]);
    FIXC(9) = binline;
    fxl = binxl+binw+hgap;
    fw = 180;
    fh = 24;
    fb = 2;
    fyb = butbot - (fh-buth)/2;
    fh1 = uicontrol('style','frame','position',[fxl fyb fw fh],...
        'backgroundcolor',medgray);
    exl = fxl+fb;
    eyb = fyb+fb;
    RIGHTHAND = uicontrol('style','edit','position',[exl eyb fw-2*fb fh-2*fb],...
        'backgroundcolor',[1 1 1],'horizontalalignment','left');
    tox = fxl + fw + hgap;
    tow = 22;
    tmp = uicontrol('style','text',...
            'backgroundcolor',wincol,...
            'horizontalalignment','center',...
            'position',[tox butbot 25 tow],...
            'string','As');
    f2x = tox+tow+hgap;
    f2y = fyb;
    f2w = rightx-(f2x);
    f2h = fh;
    fh2 = uicontrol('style','frame',...
        'position',[f2x f2y f2w f2h],...
        'backgroundcolor',medgray);
    exl = f2x + fb;
    eyb = f2y + fb;
    LEFTHAND = uicontrol('style','edit',...
        'position',[exl eyb f2w-2*fb f2h-2*fb],...
        'backgroundcolor',[1 1 1]);
    binloc = [WIN nbinx(1) nbiny(2) nbinx(3)-nbinx(1) nbiny(1)-nbiny(2) RIGHTHAND];
    
    bvgap = 5;
    botlevel = butbot + buth + bvgap;
    FL = uicontrol('style','frame','position',[0 botlevel winpos(3) 2]);

    prey = botlevel + bvgap;
    
    messw = 180;
    messh = 20;    
    REFMESS = uicontrol('style','text',...
            'backgroundcolor',wincol,...
            'horizontalalignment','left',...
            'position',[leftx+messoffset prey messw messh],...
            'string',' ');
    messw = 190;
    MESSAGE = uicontrol('style','text',...
            'backgroundcolor',wincol,...
            'horizontalalignment','right',...
            'position',[rightx-messw-messoffset prey messw messh],...
            'string',' ');
    buty = prey + messh + vgap;
    butw = 140;
    buth = 30;
    REFRESH_BUT = uicontrol('style','pushbutton',...
            'position',[leftx buty butw buth],...
            'callback',...
            ['MUWHOVAR=who;wsguin([],''who'',MUWHOVAR);clear MUWHOVAR;' ...
             'wsminfo;wsguin([],''applysr'');wsguic;' ...
             'wsguin([],''refill'');wsguin([],''reclock'');'],...
            'string','Refresh Variables');
    popupw = 190;
    SR_BUT = uicontrol('style','pushbutton',...
            'visible','on',...
            'enable','off',...
            'position',[rightx-popupw buty popupw buth],...
            'callback',...
            ['if gguivar(''SELSTAT'')==1;wsguin([],''applysr'');else;' ...
            'wsguic;end;wsguin([],''refill'');'],...
            'string','Apply Selection');
            
    prey = buty + buth + vgap;
    
    selectheight = 24;    
    psdv = [0;0;2;2;4;4;1;45;75;3;3];
    cusdv = [0;0;3;3;4;4;20;45;75;3;3];
    xywh = parmwin('dimquery','nwet',psdv,'Prefix',[],WIN,'date',[1 1 1]);
    psdv(1:4) = [leftx;prey;2;2];
    psdv(7) = psdv(7) - (xywh(4)-selectheight);
    xywh = parmwin('dimquery','nwet',psdv,'Prefix',[],WIN,'date',[1 1 1]);
    cusdv([1 2 4 8 9]) = [leftx;prey;4;65;55+rightx-xywh(3)-leftx-20];
    [prehan,ptxt] = parmwin('create','nwet',psdv,'Prefix',[],WIN,...        
        'wsguin([],''asvis'',1)',[1 1 1],'callbackscript');
        prepointers = [prehan;get(prehan,'userdata');ptxt];
    psdv(1) = [leftx+xywh(3)-1];    
    [sufhan,stxt] = parmwin('create','nwet',psdv,'Suffix',[],WIN,...    
        'wsguin([],''asvis'',1)',[1 1 1],'callbackscript');
        sufpointers = [sufhan;get(sufhan,'userdata');stxt];
    [xywhc] = parmwin('dimquery','nwet',cusdv,'Custom',[],WIN,...    
        'wsguin([],''asvis'',2)',[1 1 1],'callbackscript');
    cusdv(7) = cusdv(7) - (xywhc(4)-selectheight) + 2;
    [CUSTOM,ctxt] = parmwin('create','nwet',cusdv,'Custom',[],WIN,...    
        'wsguin([],''asvis'',2)',[1 1 1],'callbackscript');
        cuspointers = [CUSTOM;get(CUSTOM,'userdata');ctxt];
    set(cuspointers,'visible','off');
    SELECT_PO = uicontrol('style','popup',...
        'String',...
        'All|Constant|Varying|System|Varying/Constant|System/Constant|System/Varying|Packed',...
        'position',[leftx+2*xywh(3)-2 prey rightx-leftx-2*xywh(3)+2-20 xywh(4)],...
        'callback','wsguin([],''asvis'',1)');
    SELTOR = [];
    SELTOR = ipii(SELTOR,[sufpointers;prepointers;SELECT_PO],1);
    SELTOR = ipii(SELTOR,cuspointers,2);
    CUSTOMBUT = uicontrol('style','pushbutton','position',[rightx-20 prey 20 xywh(4)+1],...
        'string','*','callback','wsguin([],''switchsel'')'); 
    
    
    PSHAN = [prehan;sufhan];
        
    ybota = prey + xywh(4);
    axepos = [leftx/winpos(3) ybota/winpos(4) ...
        (rightx-20-leftx)/winpos(3) (winpos(4)-topborder-ybota)/winpos(4)];
    FIXC(1:4) = [leftx;ybota;rightx-20;winpos(3)];

    exhan = [];
    coltypemask = ['dssss';'spiii'];    %dragable/static(d/s), string/integer(p/s/i) 
    colpt = [6 1 2 3 4;25 1 2 3 4];
    colpos = [.01 .5 .75 .87 .99];
    colstrings =...
       str2mat('Constant','Empty','System','Varying','Packed','Unknown');
    colalign = 'llrrr';
    coltitles = str2mat('Variable Name','Type','Rows','Cols','Num');
    [AXESHAN] = scrtxtn('create',WIN,axepos,[0 1],[0.01 NUMLINES],...
        coltypemask,colpos,colalign,colpt,colstrings,coltitles,FONT);
    exhan = [REFRESH_BUT;SR_BUT;SELECT_PO;MESSAGE;FL;fh1;fh2];    
    mudeclar('done',exhan,WIN,VN,PIM,CWIN,SWIN);
    
    sguivar('AXESHAN',AXESHAN,'BINLOC',[],'SELECT_PO',SELECT_PO,'SR_BUT',SR_BUT);
    sguivar('MESSAGE',MESSAGE,'REFMESS',REFMESS,'TOOLTYPE',TOOLTYPE,'RUNNING',RUNNING)
    sguivar('PSHAN',PSHAN,'SELTOR',SELTOR,'SELSTAT',1,'CUSTOM',CUSTOM,'NUMLINES',NUMLINES)
    sguivar('BINLOC',binloc,'RIGHTHAND',RIGHTHAND','LEFTHAND',LEFTHAND,'APPLYSTAT',[0;0]);
    sguivar('EXPMESS',EXPMESS,'WIN',WIN,'FIXC',FIXC,'FONT',FONT,'DRAGAX',DRAGAX);
    sguivar('FONTHANS',FONTHANS,'LINEHANS',LINEHANS,'CWIN',CWIN,'SWIN',SWIN,'SFILE',SFILE);

% I cannot hide WIN just yet..
    set(WIN,'visible','on','pointer','arrow');
    set(CWIN,'visible','off','pointer','arrow','handlevis','call');
    set(SWIN,'visible','off','pointer','arrow','handlevis','call');

% Clean up in case some one snuffs us out.  Maybe we should
% prompt "Are you sure?" instead..??   GJW
    set(WIN,'DeleteFcn',...
           ['disp(''Cleaning up in WSGUI..'');wsguin([],''quit'');']); 

elseif strcmp(message,'hide')

% Make like Bert Campbell
    WIN = gcf;
    set(WIN,'handlevis','call');

elseif strcmp(message,'who')
    names = char(in1);
    nl    = [];
    if ~isempty(names)
        nl = sum(abs(names) ~= 32, 2);
        an = abs(names);
        for i=1:size(an,2)
            [dum,ind] = sort(an(:,size(an,2)-i+1));
            an = an(ind,:);
            nl = nl(ind);
        end
        names = setstr(an);
   end
   sguivar('ALLNAMES',names,'ALLNAMESLEN',nl);

elseif strcmp(message,'reclock')
    set(gguivar('REFMESS'),'string',nicetod);
elseif strcmp(message,'refill')
    listofnames = str2mat('Constant','Empty','System','Varying');
    [CUSITEMS,SELITEMS,AXESHAN,MESSAGE,ALLINFO,SELSTAT] = ...
        gguivar('CUSITEMS','SELITEMS','AXESHAN','MESSAGE','ALLINFO','SELSTAT');
    if SELSTAT == 1
        scrtxtn('changedata',AXESHAN,SELITEMS,zeros(size(SELITEMS,1),1));
        numsel = int2str(size(SELITEMS,1));
    elseif SELSTAT == 2
        scrtxtn('changedata',AXESHAN,CUSITEMS,zeros(size(CUSITEMS,1),1));
        numsel = int2str(size(CUSITEMS,1));
    end
    scrtxtn('draw',AXESHAN);
    numtot = int2str(size(ALLINFO,1));
    set(MESSAGE,'string',[numsel ' (of ' numtot ') Items Selected']);
elseif strcmp(message,'applysr')
    [ALLINFO,SELECT_PO,SR_BUT,PSHAN,APPLYSTAT] = ...
        gguivar('ALLINFO','SELECT_PO','SR_BUT','PSHAN','APPLYSTAT');
    if ~isempty(ALLINFO)
        srval = get(SELECT_PO,'value');
        if srval == 1
            loc = 1:size(ALLINFO,1);
        elseif srval == 2
            loc = find(ALLINFO(:,1)==1);
        elseif srval == 3
            loc = find(ALLINFO(:,1)==4);
        elseif srval == 4
            loc = find(ALLINFO(:,1)==3);
        elseif srval == 5
            loc = find(ALLINFO(:,1)==4 | ALLINFO(:,1)==1);
        elseif srval == 6
            loc = find(ALLINFO(:,1)==3 | ALLINFO(:,1)==1);
        elseif srval == 7
            loc = find(ALLINFO(:,1)==3 | ALLINFO(:,1)==4);
        elseif srval == 8
            loc = find(ALLINFO(:,1)==5);
        end
        SELITEMS = ALLINFO(loc,:);
    else
        SELITEMS = [];
    end
    if ~isempty(SELITEMS)
    prefix = deblank(parmwin('getstring','nwet',PSHAN(1),1));
    prefix = fliplr(deblank(fliplr(prefix)));
    apre = abs(prefix);
    numitems = size(SELITEMS,1);
    if ~isempty(prefix)
        tmp = (SELITEMS(:,6:(5+size(apre,2)))==ones(numitems,1)*apre)';
        tmp = [tmp;ones(1,size(tmp,2))];
        loc = find(all(tmp));
        SELITEMS = SELITEMS(loc,:);
    end
    end
    if ~isempty(SELITEMS)
    suffix = deblank(parmwin('getstring','nwet',PSHAN(2),1));
    suffix = fliplr(deblank(fliplr(suffix)));
    asuf = abs(suffix);
    numitems = size(SELITEMS,1);
    if ~isempty(suffix)
        loc = [];
        lsuf = length(suffix);
        for i=1:numitems
            lvarn = SELITEMS(i,5);
            if all(SELITEMS(i,6+lvarn-lsuf:6+lvarn-1)==asuf)
                loc = [loc;i];
            end
        end
        SELITEMS = SELITEMS(loc,:);
    end
    end
    sguivar('SELITEMS',SELITEMS,'APPLYSTAT',[0;APPLYSTAT(2)]);
    set(SR_BUT,'enable','off');
elseif strcmp(message,'asvis')    
    [SR_BUT,APPLYSTAT] = gguivar('SR_BUT','APPLYSTAT');
    set(SR_BUT,'visible','on')
    set(SR_BUT,'enable','on')
    if in1==1
        sguivar('APPLYSTAT',[1;APPLYSTAT(2)]);
    elseif in1==2
        sguivar('APPLYSTAT',[APPLYSTAT(1);1]);
    end
elseif strcmp(message,'switchsel')
    [SELSTAT,SELTOR,SR_BUT,APPLYSTAT] = ...
        gguivar('SELSTAT','SELTOR','SR_BUT','APPLYSTAT');
    if SELSTAT == 1
        set(xpii(SELTOR,1),'visible','off');
        set(xpii(SELTOR,2),'visible','on');
        sguivar('SELSTAT',2);
        if APPLYSTAT(2)==1
            set(SR_BUT,'enable','on')
        else
            set(SR_BUT,'enable','off');
        end
        wsguin([],'refill');
    else
        set(xpii(SELTOR,2),'visible','off');
        set(xpii(SELTOR,1),'visible','on');
        sguivar('SELSTAT',1);
        if APPLYSTAT(1)==1
            set(SR_BUT,'enable','on')
        else
            set(SR_BUT,'enable','off');
        end
        wsguin([],'refill');
    end
elseif strcmp(message,'quit')
    WIN = gcf;
    [mains,othw] = findmuw(get(0,'chi'));
    mkdragtx('destroy',WIN)
    hanid = xpii(othw,WIN);
    if ~isempty(hanid)
        delete(hanid(:,1))
    end
    delete(WIN);
elseif strcmp(message,'lines')
    [AXESHAN,WIN,FIXC,FONT,BINLOC,DRAGAX] = ...
        gguivar('AXESHAN','WIN','FIXC','FONT','BINLOC','DRAGAX');
    [LINEHANS] = gguivar('LINEHANS');
    scrtxtn('delete',AXESHAN);
    winpos = get(WIN,'position');
    winpos(3) = FIXC(4);
    set(WIN,'position',winpos);
    binxl=FIXC(5);binyb=FIXC(6);binw=FIXC(7);binh=FIXC(8);binline=FIXC(9);
    delete(binline);
    binx = [binxl;binxl;binxl+binw;binxl+binw];
    biny = [binyb+binh;binyb;binyb;binyb+binh];
    nbinx = binx/winpos(3);
    nbiny = biny/winpos(4);
    axes(DRAGAX);
    binline = line(nbinx,nbiny,'color',[0 0 0]);
    FIXC(9) = binline;
    BINLOC(2:5) = [nbinx(1) nbiny(2) nbinx(3)-nbinx(1) nbiny(1)-nbiny(2)];
    set(DRAGAX,'xlim',[0 1],'ylim',[0 1]);
    axepos = [FIXC(1)/winpos(3) FIXC(2)/winpos(4) ...
            (FIXC(3)-FIXC(1))/winpos(3) (winpos(4)-21-FIXC(2))/winpos(4)];
    coltypemask = ['dssss';'spiii'];    %dragable/static(d/s), string/integer(p/s/i) 
    colpt = [6 1 2 3 4;25 1 2 3 4];
    colpos = [.01 .5 .75 .87 .99];
    colstrings = str2mat('Constant','Empty','System','Varying');
    colalign = 'llrrr';
    coltitles = str2mat('Variable Name','Type','Rows','Cols','Num');
    [AXESHAN] = scrtxtn('create',WIN,axepos,[0 1],[0.01 in1],...
        coltypemask,colpos,colalign,colpt,colstrings,coltitles,FONT);
    sguivar('AXESHAN',AXESHAN,'NUMLINES',in1,'BINLOC',BINLOC,'FIXC',FIXC);
    set(LINEHANS,'checked','off')
    set(LINEHANS(in2),'checked','on')
    wsguin([],'refill');
elseif strcmp(message,'cleanup')
    [AXESHAN,WIN,FIXC,FONT,NUMLINES,BINLOC] = ...
        gguivar('AXESHAN','WIN','FIXC','FONT','NUMLINES','BINLOC');
    dims = xpii(get(AXESHAN,'userdata'),1);
    slidhan = dims(1);
    slidpos = get(slidhan,'position');
    [DRAGAX] = gguivar('DRAGAX');
    winpos = get(WIN,'position');
    winpos(3) = FIXC(4);
    set(WIN,'position',winpos);
    binxl=FIXC(5);binyb=FIXC(6);binw=FIXC(7);binh=FIXC(8);binline=FIXC(9);
    delete(binline);
    binx = [binxl;binxl;binxl+binw;binxl+binw];
    biny = [binyb+binh;binyb;binyb;binyb+binh];
    nbinx = binx/winpos(3);
    nbiny = biny/winpos(4);
    axes(DRAGAX);
    binline = line(nbinx,nbiny,'color',[0 0 0]);
    FIXC(9) = binline;
    BINLOC(2:5) = [nbinx(1) nbiny(2) nbinx(3)-nbinx(1) nbiny(1)-nbiny(2)];
    set(DRAGAX,'xlim',[0 1],'ylim',[0 1]);
    axepos = [];
    axepos = [FIXC(1)/winpos(3) FIXC(2)/winpos(4) ...
            (FIXC(3)-FIXC(1))/winpos(3) (winpos(4)-30-FIXC(2))/winpos(4)];
    set(slidhan,'position',[FIXC(3) FIXC(2) 20 winpos(4)-30-FIXC(2)]);
    set(AXESHAN,'position',axepos);
    sguivar('FIXC',FIXC,'BINLOC',BINLOC);
elseif strcmp(message,'font')
    [AXESHAN,FONTHANS] = gguivar('AXESHAN','FONTHANS');
    scrtxtn('changefont',AXESHAN,in1);
    set(FONTHANS,'checked','off')
    set(FONTHANS(in2),'checked','on')
    sguivar('FONT',in1);
elseif strcmp(message,'resetsel')
    [PSHAN,SELECT_PO,SELSTAT,CUSTOM] = ...
        gguivar('PSHAN','SELECT_PO','SELSTAT','CUSTOM');
    if SELSTAT == 1
        set(SELECT_PO,'value',1);
        parmwin('setstring','nwet',PSHAN(1),1,'');
        parmwin('setstring','nwet',PSHAN(2),1,'');
    else
        parmwin('setstring','nwet',CUSTOM,1,'');
    end
elseif strcmp(message,'mkclear')
    WIN = gcf;
    winpos = get(WIN,'position');
    [mains,othw] = findmuw(get(0,'chi'));
    hanid = xpii(othw,WIN);
    cloc = find(hanid(:,2)==1);
    if ~isempty(cloc)
        CWIN = hanid(cloc,1);
        cpos = get(CWIN,'position');
        x = winpos(1)+120; y=winpos(2)+winpos(4)-cpos(4)-30;
        set(CWIN,'visible','on','position',[x y cpos(3) cpos(4)])
        figure(CWIN);
    else
%       Re-Create CLEAR window 
        bw = 90;bh = 30;xbo = 15;ybo = 15;ymbo = 10;xmbo = 12;th = 20;
        cwinw = xbo + bw + xmbo + bw + xbo;
        cwinh = ybo + bh + ymbo + th + ybo;
        x = winpos(1)+120; y=winpos(2)+winpos(4)-cwinh-30;
        cwinpos = [x y cwinw cwinh];
        cwincol = get(WIN,'color');
%	    'nextplot','new',...  GJW 09/10/96
        CWIN = figure('color',cwincol,...
            'menubar','none',...
            'Numbertitle','off',...
            'visible','on',...
            'pointer','watch',...
            'position',cwinpos, ...
            'DockControls', 'off');
        uicontrol('style','pushbutton','string','Clear',...
            'position',[xbo ybo bw bh],...
            'callback',...
            'wsguin([],''clear'');eval(gguivar(''TMP''));wsguin([],''resetsel'');wsguin([],''refill'');');
        uicontrol('style','pushbutton','string','Cancel',...
            'callback','set(gcf,''visible'',''off'')',...
            'position',[xbo+bw+xmbo ybo bw bh]);
        uicontrol('style','text','string','Clear all selected matrices',...
            'horizontalalignment','left',...
            'backgroundcolor',cwincol,...
            'position',[xbo ybo+bh+ymbo bw+xmbo+bw th]);
        winud = get(WIN,'userdata');
        set(CWIN,'Userdata',[winud(1:length(winud)-4);abs('SUB')';WIN+.01]);
    end
elseif strcmp(message,'mksave')
    WIN = gcf;
    winpos = get(WIN,'position');
    [mains,othw] = findmuw(get(0,'chi'));
    hanid = xpii(othw,WIN);
    sloc = find(hanid(:,2)==2);
    if ~isempty(sloc)
        SWIN = hanid(sloc,1);
        spos = get(SWIN,'position');
        x = winpos(1)+120; y=winpos(2)+winpos(4)-spos(4)-30;
        set(SWIN,'visible','on','position',[x y spos(3) spos(4)])
        figure(SWIN);
    else
%       Re-Create SAVE window 
        bw = 90;bh = 30;xbo = 15;ybo = 15;ytbo = 5;ymbo = 10;xmbo = 12;th = 20;
        swinw = xbo + bw + xmbo + bw + xbo;
        swinh = ybo + bh + ymbo + th + ytbo + th + ybo;
        swinpos = [winpos(1)+120 winpos(2)+winpos(4)-swinh-30 swinw swinh];
        swincol = get(WIN,'color');
%	    'nextplot','new',...  GJW 09/10/96
        SWIN = figure('color',swincol,...
            'menubar','none',...
            'Numbertitle','off',...
            'visible','on',...
            'pointer','watch',...
            'position',swinpos, ...
            'DockControls', 'off');
        uicontrol('style','pushbutton','string','Save',...
            'position',[xbo ybo bw bh],...
            'enable','on',...
            'callback','wsguin([],''save'');eval(gguivar(''TMP''));');
        uicontrol('style','pushbutton','string','Cancel',...
            'callback','set(gcf,''visible'',''off'')',...
            'position',[xbo+bw+xmbo ybo bw bh]);
        SFILE = uicontrol('style','edit','horizontalalignment','left',...
            'backgroundcolor',[1 1 1],...
            'string','savefile',...
            'position',[xbo ybo+bh+ymbo bw+xmbo+bw th]);
        uicontrol('style','text','string','Save selected matrices as...',...
            'horizontalalignment','left',...
            'backgroundcolor',swincol,...
            'position',[xbo ybo+bh+ymbo+th+ytbo bw+xmbo+bw th]);
        winud = get(WIN,'userdata');
        set(SWIN,'Userdata',[winud(1:length(winud)-4);abs('SUB')';WIN+.02]);
        sguivar('SFILE',SFILE);
    end
elseif strcmp(message,'clear')
% Need big fixes
    [SELITEMS,CUSITEMS,SELSTAT,ALLINFO,CWIN,ALLNAMES] = ...
        gguivar('SELITEMS','CUSITEMS','SELSTAT','ALLINFO','CWIN','ALLNAMES');
    [ALLNAMESLEN] = gguivar('ALLNAMESLEN');
    if SELSTAT==1
        items = SELITEMS;
        itname = 'SELITEMS';
        others = CUSITEMS;
        otname = 'CUSITEMS';
    else
        items = CUSITEMS;
        itname = 'CUSITEMS';
        others = SELITEMS;
        otname = 'SELITEMS';
    end
        nvar = size(ALLINFO,1);
        otnvar = size(others,1);
        all_away = [];
        ot_away = [];
        str = 'clear ';
        if size(items,1)>0
            for i=1:size(items,1)
                namelen = items(i,5);
                all_delit = find(all( (ALLINFO==ones(nvar,1)*items(i,:))' ));
                all_away = [all_away;all_delit];
                str = [str setstr(items(i,6:6+namelen-1)) ' '];
                ot_delit = find(all( (others==ones(otnvar,1)*items(i,:))' ));
                ot_away = [ot_away;ot_delit];
            end
            allkeep = comple(all_away,nvar);
            otkeep = comple(ot_away,otnvar);
            sguivar(itname,ALLINFO(allkeep,:),otname,others(otkeep,:),...
                'ALLNAMES',ALLNAMES(allkeep,:),'ALLNAMESLEN',ALLNAMESLEN(allkeep,:),...
                'ALLINFO',ALLINFO(allkeep,:),'TMP',str);
        else
            sguivar('TMP',[' ']);
        end
    set(CWIN,'visible','off')
elseif strcmp(message,'save')
    [SELITEMS,CUSITEMS,SELSTAT,ALLINFO,SWIN,SFILE] = ...
        gguivar('SELITEMS','CUSITEMS','SELSTAT','ALLINFO','SWIN','SFILE');
    if SELSTAT==1
        items = SELITEMS;
    else
        items = CUSITEMS;
    end
    sname = get(SFILE,'string');
    allow = find(sname~=' ');
    sname = sname(allow);
    if size(items,1)>0
            str = ['save ' sname ' '];
            for i=1:size(items,1)
                namelen = items(i,5);
                str = [str setstr(items(i,6:6+namelen-1)) ' '];
            end
            sguivar('TMP',str);
    else
            sguivar('TMP',[' ']);
    end
    set(SWIN,'visible','off')
else
    disp('Warning in WSGUIN: Unknown message');
end

if ~strcmp(message,'create')& ~strcmp(message,'quit')& ~strcmp(message,'hide')
    delrunf(get(0,'chi'));
end

%   LOADing a .mat file is most easily done from the command line
%   in MATLAB, since there is only 1 file.  This is in contrast to
%   SAVEing to a .mat file, where you must list the matrices which
%   are to be SAVEd.  In other words, to SAVE all system matrices
%   to a file called allsys.mat would require quite a bit of working through
%   the workspace variables to see which are SYSTEMS and which are not, and
%   then typing a long command for the SAVE.  This is now easily accomplished
%   with the muTools workspace tool.  On the other hand, loading this .mat
%   file is easily accomplished simply by typing
%
%       >> load allsys
%
%   at the command line.  Hence, a "Load .mat-file" operation has been excluded
%   from the workspace tool.   
