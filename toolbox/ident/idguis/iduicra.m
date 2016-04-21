function iduicra(arg)
%IDUICRA Handles the correlation analysis dialog.

%   L. Ljung 9-27-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $ $Date: 2004/04/10 23:19:33 $

%global XIDplotw XIDlayout
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if strcmp(arg,'open')
    figname=idlaytab('figname',32);
    if ~figflag(figname,0)
        iduistat('Opening the correlation analysis dialog box ...')
        layout
        FigW = iduilay2(3);
        
        f=figure('vis','off',...
            'NumberTitle','off','Name',figname,'HandleVisibility','callback',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),...
            'DockControls','off',...
            'tag','sitb32');
        set(f,'Menubar','none');
        
        % LEVEL1
        
        pos = iduilay1(FigW,3);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'Pos',pos(2,:),'style','push',...
            'string','Estimate','callback',...
            ['iduipoin(1);iduistat(''Compiling ...'');',...
                'iduicra(''estimate'');iduipoin(2);']);
        uicontrol(f,'Pos',pos(3,:),'style','push',...
            'callback','set(gcf,''visible'',''off'')','string','Close');
        uicontrol(f,'Pos',pos(4,:),'style','push','string','Help',...
            'callback','iduihelp(''cra.hlp'',''Help: Correlation Analysis'');');
        
        % LEVEL 2
        
        lev2 =pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,6,3,lev2,[],[1.2 1.8]);
        
        uicontrol(f,'pos',pos(1,:),'style','frame');
        %       h1=uicontrol(f,'pos',pos(3,:),'style','edit','Horizontalalignment',...
        %          'left',...
        %          'backgroundcolor','white','callback',...
        %          'iduipoin(1);iduicra(''filt_ord'');iduipoin(2);');
        tt =  ['The Impulse response will be estimated over this time interval.',...
                ' Negative lags show feedback effects.'];
        XID.cra(4)=uicontrol(f,'pos',[pos(2,:)+[10 0 0 0]],'style','text','string',...
            'Time Span:','HorizontalAlignment','right','tooltip',tt);
        XID.cra(3) = uicontrol(f,'pos',pos(3,:),'HorizontalAlignment','left',...
            'style','edit','backgroundcolor','w','tooltip',tt);
        tt = ['Order of AR-filter to prewhiten the input. Default order: 10.'];
        uicontrol(f,'pos',pos(4,:)+[-10 0 20 0],'style','text','string',...
            'Order of whitening filter:','HorizontalAlignment','right','tooltip',tt);
        XID.cra(1) = uicontrol(f,'pos',pos(5,:),'HorizontalAlignment','left',...
            'style','edit','backgroundcolor','w','string','Default',...
            'callback','iduicra(''filt_ord'');','tooltip',tt);
        uicontrol(f,'pos',[pos(6,:)+[10 0 0 0]],'style','text','string',...
            'Model Name:','HorizontalAlignment','right');
        XID.cra(2) = uicontrol(f,'pos',pos(7,:),'HorizontalAlignment','left',...
            'style','edit','backgroundcolor','w','string','Imp',...
            'tooltip','Enter any string to be used as the model name.');
        usd=get(XID.plotw(16,1),'userdata');
        %usd = usdd{1};
        if isempty(usd)
            str = 'Default';
        else
            str = deblank(usd(1,:));
        end
        set(XID.cra(1),'string',deblank(usd(1,:)));
        
        poslev=pos(1,2)+pos(1,4)+mEdgeToFrame;
        ScreenPos = get(0,'ScreenSize');
        FigWH=[FigW poslev];
        FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
        set(f,'pos',FigPos);
        set(get(f,'children'),'unit','norm')
        if length(XID.layout)>39,if XID.layout(40,3)
                eval('set(f,''pos'',XID.layout(40,1:4))','')
            end,end
        set(f,'vis','on')
        iduistat('')
    end
    set(Xsum,'UserData',XID)
    iduicra('tspan')
    
elseif strcmp(arg,'filt_ord')
    usd=get(XID.plotw(16,1),'userdata');
    %usd = usd{1};
    fo=get(iduigco,'string');
    if isempty(fo),fo='Default';end
    %if ~ischar(fo)&isempty(eval(fo))
    %  fo='Default';
    %end
    flag=0;
    if ~strcmp(lower(fo(1)),'d')
        ifo=0;
        try
            ifo=eval(fo);
        catch
            flag=1;
        end
        if ifo<0|floor(ifo)~=ifo|ifo>100,flag=1;end
    end
    if flag,
        set(iduigco,'string',usd(1,:));
        errordlg('The filter order must be an integer between 0 and 100.'...
            ,'Error Dialog','modal');
        return
    end
    usd=str2mat(fo,usd(2,:),usd(3,:));
    %usdd{1}=usd;
    set(XID.plotw(16,1),'userdata',usd);
elseif strcmp(arg,'tspan')
    [eDat,eDat_info,eDat_n]=iduigetd('e');
    TSamp=pvget(eDat,'Ts'); 
    try
        tu = pvget(eDat,'TimeUnit');
    catch
        tu='';
    end
    if isempty(tu),
        tu = 's';
    end
    if iscell(TSamp)
        TSamp =TSamp{1}; 
    end
    [N,ny,nu]=sizedat(eDat); 
    usd=get(XID.plotw(16,1),'userdata');
    OPt=get(XID.plotw(5,2),'UserData');
    Tspan = ['[',num2str(-5*TSamp,3),' ',num2str(eval(deblank(OPt(2,:)))*TSamp,3),']'];
    set(XID.cra(4),'string',['Time span (',tu,'):'])
    set(XID.cra(3),'string',Tspan);
    %TSpan=eval(deblank(OPt(2,:)));
    
elseif strcmp(arg,'estimate')
    [eDat,eDat_info,eDat_n]=iduigetd('e');
    TSamp=pvget(eDat,'Ts'); 
    if iscell(TSamp)
        TSamp =TSamp{1}; 
    end
    [N,ny,nu]=sizedat(eDat); 
    usd=get(XID.plotw(16,1),'userdata');
    
    %if strcmp(arg,'cra')
    iduistat('Performing correlation analysis ...')
    if nu==0
        errordlg(['Correlation Analysis cannot be applied to',...
                ' time series to estimate the impulse response.'],'Error Dialog','modal');
    else
        NA=eval(usd(1,:));
        if isempty(NA)|strcmp(lower(NA(1)),'d')
            NA = 10;
        end
        mnam = get(XID.cra(2),'string');
        sTSpan = get(XID.cra(3),'string');
        TSpan = eval(['[',sTSpan,']']);
        %OPt=get(XID.plotw(5,2),'UserData');
        %TSpan=eval(deblank(OPt(2,:)));
        IR=[];
        lastwarn('');
        was = warning;
        warning off
        try
            IR = impulse(eDat,TSpan,'PW',NA);
        catch
            errordlg(lasterr,'Error Dialog','modal');
            return
        end
        if length(pvget(IR,'B'))<2
            warndlg('Input not sufficently exciting to estimate impulse response',...
                'Warning Dialog','modal')
            return
        end
        IR = pvset(IR,'Name',mnam);
        infstr = str2mat(eDat_info,...
            [' ',mnam,' = impulse(',eDat_n,',',sTSpan...
                ,',''PW'',',deblank(usd(1,:)),')']);
        if ~isempty(lastwarn)
            infstr = str2mat(infstr,['Warning: ',lastwarn]);
        end
        IR = iduiinfo('set',IR,infstr);
        iduiinsm(IR,1);
        warning(was)
        idgwarn(lastwarn)
        %       if ~isempty(lastwarn)&strcmp(get(XID.warning,'checked'),'on')
        %           warndlg(lastwarn,'Warning from ''Impulse''','modal')
        %       end
    end
end

