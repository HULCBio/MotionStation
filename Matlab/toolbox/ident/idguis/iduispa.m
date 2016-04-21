function iduispa(arg)
%IDUISPA Handles the spectral analysis dialog.

%   L. Ljung 9-27-94,2-22-03
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.3 $  $Date: 2004/04/10 23:19:58 $


Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
XIDplotw = XID.plotw;
XIDlayout = XID.layout;

if strcmp(arg,'open')
    figname=idlaytab('figname',33);
    if ~figflag(figname,0)
        iduistat('Opening the spectral analysis dialog box ...')
        layout
        FigW = iduilay2(3);
        
        f=figure('vis','off',...
            'NumberTitle','off','Name',figname,'HandleVisibility','callback',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),...
            'tag','sitb33');
        set(f,'Menubar','none');
        % LEVEL1
        
        pos = iduilay1(FigW,3);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'Pos',pos(2,:),'style','push',...
            'string','Estimate','callback',...
            'iduipoin(1);iduispa(''estimate'');iduipoin(2);');
        uicontrol(f,'Pos',pos(3,:),'style','push',...
            'callback','set(gcf,''visible'',''off'')','string','Close');
        uicontrol(f,'Pos',pos(4,:),'style','push','string','Help',...
            'callback','iduihelp(''spa.hlp'',''Help: Spectral Analysis'');');
        
        % LEVEL 2e
        lev2 = pos(1,2)+pos(1,4);
        boxno=1;
        pos = iduilay1(FigW,10,5,lev2,[],[1.2 1.8]);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        XID.spa(7) = uicontrol(f,'pos',pos(10,:),'style','text',...
            'HorizontalAlignment','right','string','Model Name:');
        XID.spa(8)=uicontrol(f,'pos',pos(11,:),'style','edit','Horizontalalignment',...
            'left',...
            'backgroundcolor','white','callback',[]); % name
        XID.spa(9) = uicontrol(f,'pos',pos(8,:)+[-10,0,10,0],'style','text','string',...
            'Frequency Resolution:','HorizontalAlignment','right');
        XID.spa(10) = uicontrol(f,'pos',pos(9,:),'style','edit','Horizontalalignment',...
            'left',...
            'backgroundcolor','white','callback','iduispa(''name'');','string','Default',...
            'tooltip',['The resolution parameter (M) in SPA and ETFE. The possibly frequency ',...
                'dependent res (in rad/s) for SPAFDR.']);
        ttf = ['Number of frequencies or a frequency vector. Could be a workspace variable.'];
        XID.spa(1)=uicontrol(f,'pos',pos(7,:),'style','edit','Horizontalalignment',...
            'left',...
            'backgroundcolor','white','callback','iduispa(''name'');',...
            'tooltip',ttf,'string',int2str(100)); % number of points
        XID.spa(2)=uicontrol(f,'pos',pos(6,:),'style','text','Horizontalalignment',...
            'right','string','Frequencies:','tooltip',ttf);
        XID.spa(3)=uicontrol(f,'pos',pos(5,:),'style','pop','Horizontalalignment',...
            'left',...
            'Backgroundcolor','white',...
            'string','Linear|Logarithmic','callback','iduispa(''name'');');
        XID.spa(4)=uicontrol(f,'pos',pos(4,:),'style','text','Horizontalalignment',...
            'right',...
            'string','Frequency Spacing:');
        XID.spa(5)=uicontrol(f,'pos',pos(3,:),'style','pop','Horizontalalignment',...
            'left',...
            'Backgroundcolor','white',...
            'string','SPA (Blackman-Tukey)|SPAFDR (Freq. dep. resolution)|ETFE (Smoothed Fourier Trf)'...
            ,'callback','iduispa(''name'');');
        XID.spa(6)=uicontrol(f,'pos',pos(2,:),'style','text','Horizontalalignment',...
            'right',...
            'string','Method:');
        
        poslev=pos(1,2)+pos(1,4)+mEdgeToFrame;
        ScreenPos = get(0,'ScreenSize');
        FigWH=[FigW poslev];
        FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
        set(f,'pos',FigPos);
        set(get(f,'children'),'unit','norm')
        if length(XIDlayout)>32,if XIDlayout(33,3)
                eval('set(f,''pos'',XIDlayout(33,1:4))','')
            end,end
        set(f,'vis','on')
        iduistat('')
        set(Xsum,'UserData',XID);
    end
    iduispa('name')
elseif strcmp(arg,'name') % Set the default name
    opt = get(XID.plotw(16,1),'userdata');
    metnr = get(XID.spa(5),'value');
    respar = get(XID.spa(10),'string');
    if strcmp(lower(respar(1)),'d')
        respar = '[]';
    end
    try
     if length(eval(respar))>1
        respar = '[]';
    end
end
    opt = str2mat(opt(1,:),respar,int2str(metnr));
    set(XIDplotw(16,1),'userdata',opt);
    if metnr == 1
        nam = ['sp'];
    elseif metnr == 2
        nam = ['spfdr'];
    else
        nam = ['etf'];
    end
    if get(XID.spa(3),'value')==2
        nam = [nam,'lg'];
    end
    try
        nop = eval(get(XID.spa(1),'string'));
        if length(nop>3)
            nop = nop(1:3);
        end
        nam = [nam,int2str(nop)];
    catch
        nam = [nam,'d'];
    end
    set(XID.spa(8),'string',nam);
elseif strcmp(arg,'estimate')
    
    dat_n = get(XID.spa(8),'string');
    % First determine the frequency vector
    [dat,datinfo] = iduigetd('e','me');
    dat_n1 = pvget(dat,'Name');
    wstr = get(XID.spa(1),'string');
    fnr = [];
    try
        fnr = eval(wstr); 
        sfre = wstr;
    catch
        try
            fnr = evalin('base',wstr);
            sfre = wstr;
        catch
            try
                if strcmp(lower(wstr(1:3),'def'))
                    fnr = [];
                
                end
            catch
                warndlg(char({['The frequency variable could not be evaluated.',...
                            'It has been set to default.']}),'Warning','modal');
                set(XID.spa(1),'string','Default');
            end
        end
    end
     if  get(XID.spa(5),'value')==3 &get(XID.spa(3),'value')==2%etfe and log
            warndlg('For ETFE, linearly spaced frequency values are always used.','Warning','modal')
        end
    if isempty(fnr)
        freqs = [];
        sfre = '[]';
        set(XID.spa(1),'string','Default');
    elseif length(fnr)>1 % Is a frequency vector
        freqs = fnr(:);
        nop = length(freqs);
        if  get(XID.spa(5),'value')==3 %etfe
            warndlg('For ETFE frequency values cannot be specified, only the number of points.','Warning','modal')
        end
    else
        nop = fnr; % Then fnr is the number of points
        dom = pvget(dat,'Domain');
        ts = pvget(dat,'Ts'); ts = ts{1};
        spval = get(XID.spa(3),'value');  
        
        if strcmp(dom,'Frequency')
            fre1 = pvget(dat,'SamplingInstants');
            fre1 = fre1{1}; %%LL multiexp
            f1 = min(fre1); f2 = max(fre1);
            f10 = min(fre1(find(fre1>0)));
        else
            N = size(dat,'N');
            N = N(1);
            f1 = 1/N/ts; f2 = pi/ts;
        end
        
        if spval == 1
            freqs = linspace(f1,f2,nop);
            sfre = [num2str(f1),',',num2str(f2)];
            sfre = ['linspace(',sfre,',',int2str(nop),')'];
        else
            if f1 <= 0, f1 = f10; end 
            freqs = logspace(log10(f1),log10(f2),nop);
            sfre = ['log10(',num2str(f1),'),log10(',num2str(f2),')'];
            sfre = ['logspace(',sfre,',',int2str(nop),')'];
        end
    end
    metnr = get(XID.spa(5),'value');
    ress = get(XID.spa(10),'string');
    res = [];
    sres = '[]';
    try
        res = eval(ress); 
        sres = ress;
    catch
        try
            res = evalin('base',ress);
            sres = ress;
        catch
            try
                if strcmp(lower(ress(1:3)),'def')
                    res = [];
                    elseif strcmp(lower(ress(1:3)),'max')
                    res = 'max';
                end
            catch
                warndlg(char({['The resolution variable could not be evaluated.',...
                            'It has been set to default.']}),'Warning','modal');
                set(XID.spa(10),'string','Default');
            end
        end
    end
    was = warning;
    warning off
    lastwarn('')
    try
    switch metnr
        case 1
            dat1 = spa(dat,res,freqs);
            upd = [' ',dat_n,' = spa(',dat_n1,',',sres,',',sfre,')'];
        case 2
            dat1 = spafdr(dat,res,freqs);
            upd = [' ',dat_n,' = spafdr(',dat_n1,',',sres,',',sfre,')'];
        case 3
            dat1 = etfe(dat,res,nop);
            upd = [' ',dat_n,' = etfe(',dat_n1,',',sres,',',int2str(nop),')'];
    end
catch
    errordlg(lasterr,'Error Dialog','modal');
    return
end
    warning(was)
    if ~isempty(lastwarn)
        infstr=str2mat(datinfo,upd,['Warning: ',lastwarn]);
    else
        infstr=str2mat(datinfo,upd);
    end
    dat1 = iduiinfo('set',dat1,infstr);
    dat1 = pvset(dat1,'Name',dat_n);
    iduiinsm(dat1,1);
    idgwarn(lastwarn)
end
