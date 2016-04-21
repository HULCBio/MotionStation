function [xsamp,xtime]=iduisel(flag,xdat,sampflag,arg4,arg5,arg6)
%IDUISEL Manages the selection of input/output data variables and data portions.
%   FLAG:
%   open_portions Opens the dialog box for selecting data portions.
%   open_io       Opens the dialog box for selection of inputs and outputs.
%   comput        Computes sample and time portions.
%   samples       Handles information for portions in terms of samples.
%   time          Handles information for portions in terms of time.
%   down,move,up  Handles the drawing of boxes in the plot window.
%   revert        Erases the last drawn rectangle.
%   insert        Inserts the data with selected portions.
%   done          Closes the dialog box on data portions.
%   detrend       Detrends data.
%   decim         Resamples data.
%   revert_io     Resets all edit boxes for selection of inputs and outputs.
%   insert_io     Inserts the data with selected inputs and outputs.
%   done_io       Closes the dialog box on input/output selection.

%   L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.23.4.3 $ $Date: 2004/04/10 23:19:56 $
set(0,'Showhiddenhandles','on');


Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');


if strcmp(flag,'open_portions')
    if isempty(iduiwok(14))
        iduistat('Opening dialog box ...')
        layout
        cb1='iduipoin(1);iduistat(''Compiling...'');';
        cb2='iduipoin(1);';
        cb3='iduipoin(2);';
        
        butwh=[mStdButtonWidth mStdButtonHeight];%butw=55;buth=25;
        butw=butwh(1);buth=butwh(2);
        ftb=2;  % Frame to button
        bb = mFrameToText; % between buttons, horizontally
        bbver = 4; % Between buttons, vertically
        etf = mEdgeToFrame;
        
        XID.plotw(14,1)=idbuildw(14);
        XID=get(Xsum,'Userdata');
        set(XID.plotw(14,1),'units','pixels');
        FigWH=get(XID.plotw(14,1),'pos');FigWH=FigWH(3:4);
        lev1=max(mEdgeToFrame,(FigWH(2)-10*buth-8*bbver-2*mFrameToText)/2)+buth;
        pos = iduilay1(mStdButtonWidth+2*mFrameToText,9,9,...
            lev1-mEdgeToFrame,bbver);
        pos=pos+[(FigWH(1)-butw-2*bb-2*etf)*ones(10,1),zeros(10,3)];
        XID.sel(3,1)=uicontrol(XID.plotw(14,1),'pos',pos(1,:),'style','frame');
        XID.sel(5,1)=uicontrol(XID.plotw(14,1),'Pos',pos(8,:),'style','push',...
            'callback',...
            [cb2,'iduisel(''insert'');',cb3],'string','Insert');
        uicontrol(XID.plotw(14,1),'Pos',pos(10,:),'style','push','callback',...
            'iduisel(''done'');','string','Close');
        uicontrol(XID.plotw(14,1),'Pos',pos(9,:),'style','push','callback',...
            'iduisel(''revert'');','string','Revert');
        
        
        uicontrol(XID.plotw(14,1),'pos',pos(6,:),'style','text',...
            'string','Data name:','HorizontalAlignment','left');
        XID.sel(2,1)=uicontrol(XID.plotw(14,1),'pos',...
            pos(7,:)+[0 5 0 0],'style',...
            'edit','backgroundcolor','white','horizontalalignment','left');
        
        XID.plotw(14,2)=uicontrol(XID.plotw(14,1),'pos',...
            pos(5,:)+[0 5 0 0],'style','edit',...
            'callback',[cb1,'iduisel(''samples'');',cb3],...
            'backgroundcolor','white', ...
            'horizontalalignment','left');
        set(XID.plotw(14,2),'userdata',get(XID.plotw(1,2),'userdata'));
        uicontrol(XID.plotw(14,1),'pos',pos(4,:),'HorizontalAlignment','left',...
            'style','text','string',...
            str2mat('Samples:'));
        XID.sel(4,1)=uicontrol(XID.plotw(14,1),'pos',...
            pos(3,:)+[0 5 0 0],'style',...
            'edit','callback',[cb2,'iduisel(''time'');',cb3],...
            'backgroundcolor','white','horizontalalignment','left');
        uicontrol(XID.plotw(14,1),'pos',pos(2,:),'HorizontalAlignment','left',...
            'style','text',...
            'string',str2mat('Time span:'));
        
        
        handl=findobj(XID.plotw(14,1),'type','uicontrol');
        set(handl,'unit','norm')
        if length(XID.layout)>30,
            if XID.layout(31,3)
                try
                    set(XID.plotw(14,1),'pos',XID.layout(31,1:4))
                end
            end,
        end
        set(Xsum,'UserData',XID);
    end % end create window
    
    % Plot data
    xax=findobj(XID.plotw(14,1),'type','axes');
    hbox=zeros(2,2);
    if strcmp(get(0,'blackandwhite'),'on')
        col=['y','y'];
    else
        col=['g','r'];
    end
    for kh=1:2
        axes(xax(kh));cla
        for kb=1:2
            hbox(kb,kh)=line('linestyle','--','color',col(kb),...
                'erasemode','xor','vis','off');
        end
    end
    set(XID.sel(3,1),'userdata',hbox);
    [dat,dat_inf,dat_n]=iduigetd('e');
    if size(dat,'Ne')>1
        errordlg('Selecting Range is not supported for multi-experiment data sets.','Error Dialog','modal');
        close(XID.plotw(14,1))%,'vis','off');
        set(0,'Showhiddenhandles','off'); 
        return
    end
    inf.ynames = pvget(dat,'OutputName');
    inf.unames = pvget(dat,'InputName');
    uynames ={};
    for kkk = 1:length(inf.unames)
        uynames{kkk} = inf.ynames;
    end
    inf.uynames = uynames;
    iduiiono('set',inf,14);
    iddatfig(0,14);
    iduital(14);
    tSamp = pvget(dat,'Ts');if iscell(tSamp),tSamp = tSamp{1};end
    [dl,dum]=size(dat);
    t0 = pvget(dat,'Tstart'); t0 = t0{1};
    set(XID.sel(4,1),'userdata',[tSamp,t0,dl]);
    set(XID.sel(2,1),'string',[dat_n,'e']);
    [xsamp,xtime]=iduisel('comput',[1 dl],1);
    set(XID.sel(4,1),'string',xtime);
    set(XID.plotw(14,2),'string',xsamp);
    set(XID.sel(2,1),'UserData',0);
    set(XID.plotw(14,1),'vis','on')
    drawnow
    iduistat('Ready to select data ranges.')
    iduistat('Mark data range using mouse or keyboard.',0,14)
    set(Xsum,'UserData',XID);
elseif strcmp(flag,'open_io')
    figname=idlaytab('figname',28);
    if ~figflag(figname,0)
        iduistat('Opening dialog box ...')
        layout
        f=figure('HandleVisibility','callback',...
            'DockControls','off',...
            'NumberTitle','off','Name',figname,'tag','sitb28',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),'vis','off');
        set(f,'Menubar','none');
        XID.sel(1,2)=f;
        FigW=iduilay2(2);
        cb1='iduipoin(1);iduistat(''Compiling...'');';
        cb2='iduipoin(1);';
        cb3='iduipoin(2);';
        
        % LEVEL 1
        
        pos = iduilay1(FigW,4,2);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'Pos',pos(2,:),'style','push','callback',...
            [cb2,'iduisel(''insert_io'');',cb3],'string','Insert');
        uicontrol(f,'Pos',pos(3,:),'style','push','callback',...
            [cb2,'iduisel(''revert_io'');',cb3],'string','Revert');
        uicontrol(f,'Pos',pos(4,:),'style','push','callback',...
            'iduisel(''done_io'');','string','Close');
        uicontrol(f,'Pos',pos(5,:),'style','push','callback',...
            'iduihelp(''idselio.hlp'',''Help: Select Channels'');','string','Help');
        
        % LEVEL 2
        lev2=pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,12,6,lev2);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'pos',pos(2,:),'style','text','string','Working data:',...
            'horizontalalignment','left')
        uicontrol(f,'pos',pos(3,:),'style','text','tag','wdname',...
            'horizontalalignment','left')
        
        uicontrol(f,'pos',pos(12,:),'style','text',...
            'string','Data name:','HorizontalAlignment','left');
        XID.sel(2,2)=uicontrol(f,'pos',pos(13,:),'style',...
            'edit',...
            'HorizontalAlignment','left',...
            'backgroundcolor','white');
        
        XID.sel(3,2)=uicontrol(f,'pos',pos(7,:)+[0 0 0 20],'style','listbox',...
            'HorizontalAlignment','left',...
            'backgroundcolor','white','max',4,'min',1,...
            'tooltip',['Use Ctlr+click for multiple' ...
                ' selection and deselection.']);
        uicontrol(f,'pos',pos(6,:),'style','text','string',...
            str2mat('Inputs:'),'HorizontalAlignment','left');
        XID.sel(4,2)=uicontrol(f,'pos',pos(11,:)+[0 0 0 20],'style',...
            'listbox',...
            'HorizontalAlignment','left',...
            'backgroundcolor','white','max',4,'min',1,...
            'tooltip',['Use Ctrl+click for multiple' ...
                ' selection and deselection.']);
        uicontrol(f,'pos',pos(10,:),'style','text',...
            'string',str2mat('Outputs:'),'HorizontalAlignment',...
            'left');
        FigWH=[iduilay2(2) pos(1,2)+pos(1,4)+mEdgeToFrame];
        ScreenPos = get(0,'ScreenSize');
        FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
        set(f,'pos',FigPos);
        set(get(f,'children'),'unit','norm');
        if length(XID.layout)>27,if XID.layout(28,3)
                eval('set(f,''pos'',XID.layout(28,1:4))','');
            end,end
        set(f,'vis','on')
    end
    set(Xsum,'UserData',XID);
    iduisel('revert_io')
    iduistat('Ready to select input output channels.')
    
elseif strcmp(flag,'open_exp')
    figname=idlaytab('figname',35);
    if ~figflag(figname,0)
        iduistat('Opening dialog box ...')
        layout
        f=figure('HandleVisibility','callback',...
            'DockControls','off',...
            'NumberTitle','off','Name',figname,'tag','sitb35',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),'vis','off');
        set(f,'Menubar','none');
        XID.sel(1,6)=f;
        FigW=iduilay2(2);
        cb1='iduipoin(1);iduistat(''Compiling...'');';
        cb2='iduipoin(1);';
        cb3='iduipoin(2);';
        
        % LEVEL 1
        
        pos = iduilay1(FigW,4,2);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'Pos',pos(2,:),'style','push','callback',...
            [cb2,'iduisel(''insert_exp'');',cb3],'string','Insert');
        uicontrol(f,'Pos',pos(3,:),'style','push','callback',...
            [cb2,'iduisel(''revert_exp'');',cb3],'string','Revert');
        uicontrol(f,'Pos',pos(4,:),'style','push','callback',...
            'set(gcf,''vis'',''off'');','string','Close');
        uicontrol(f,'Pos',pos(5,:),'style','push','callback',...
            'iduihelp(''idselexp.hlp'',''Help: Select Experiment'');','string','Help');
        
        % LEVEL 2
        lev2=pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,8,4,lev2);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'pos',pos(2,:),'style','text','string','Working data:',...
            'horizontalalignment','left')
        uicontrol(f,'pos',pos(3,:),'style','text','tag','wdname',...
            'horizontalalignment','left')
        
        uicontrol(f,'pos',pos(8,:),'style','text',...
            'string','Data name:','HorizontalAlignment','left');
        XID.sel(2,6)=uicontrol(f,'pos',pos(9,:),'style',...
            'edit',...
            'HorizontalAlignment','left',...
            'backgroundcolor','white');
        
        XID.sel(3,6)=uicontrol(f,'pos',pos(7,:)+[0 0 0 30],'style','listbox',...
            'HorizontalAlignment','left',...
            'backgroundcolor','white','max',4,'min',1,...
            'tooltip',['Use Ctlr+click for multiple' ...
                ' selection and deselection.']);
        uicontrol(f,'pos',pos(6,:)+[0 15 0 0],'style','text','string',...
            str2mat('Experiments:'),'HorizontalAlignment','left','tag','lltest');
        FigWH=[iduilay2(2) pos(1,2)+pos(1,4)+mEdgeToFrame];
        ScreenPos = get(0,'ScreenSize');
        FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
        set(f,'pos',FigPos);
        set(get(f,'children'),'unit','norm');
        if length(XID.layout)>34,if XID.layout(35,3)
                eval('set(f,''pos'',XID.layout(35,1:4))','');
            end,end
        set(f,'vis','on')
    end
    set(Xsum,'UserData',XID);
    iduisel('revert_exp')
    iduistat('Ready to select experiments.')
    
    
    
elseif strcmp(flag,'open_dec')
    figname=idlaytab('figname',41);
    if ~figflag(figname,0)
        iduistat('Opening dialog box ...')
        layout
        f=figure('HandleVisibility','callback',...
            'DockControls','off',...
            'NumberTitle','off','Name',figname,'tag','sitb41',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),'vis','off',...
            'Integerhandle','off');
        set(f,'Menubar','none');
        FigW=iduilay2(3);
        cb1='iduipoin(1);iduistat(''Compiling...'');';
        cb2='iduipoin(1);';
        cb3='iduipoin(2);';
        
        % LEVEL 1
        
        pos = iduilay1(FigW,3);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'Pos',pos(2,:),'style','push','callback',...
            [cb1,'iduisel(''decim'');',cb3],'string','Insert');
        uicontrol(f,'Pos',pos(3,:),'style','push','callback',...
            'set(gcf,''vis'',''off'');','string','Close');
        uicontrol(f,'Pos',pos(4,:),'style','push','callback',...
            'iduihelp(''iddec.hlp'',''Help: Resample Data'');','string','Help');
        
        % LEVEL 2
        lev2=pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,6,3,lev2,4,1.5);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'pos',pos(2,:),'style','text','string','Working data:',...
            'horizontalalignment','left')
        uicontrol(f,'pos',pos(3,:),'style','text','tag','wdname',...
            'horizontalalignment','left')
        uicontrol(f,'pos',pos(6,:),'style','text',...
            'string','Data name:','HorizontalAlignment','left');
        uicontrol(f,'pos',pos(7,:),'style',...
            'edit','backgroundcolor','white',...
            'HorizontalAlignment','left',...
            'tag','dataname');
        
        uicontrol(f,'pos',pos(5,:),'style','edit',...
            'HorizontalAlignment','left',...
            'backgroundcolor','white','tag','decfact','string','1');
        uicontrol(f,'pos',pos(4,:),'style','text','string',...
            'Resampling factor:','HorizontalAlignment','left');
        FigWH=[iduilay2(3) pos(1,2)+pos(1,4)+mEdgeToFrame];
        ScreenPos = get(0,'ScreenSize');
        FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
        set(f,'pos',FigPos);
        set(get(f,'children'),'unit','norm');
        if length(XID.layout)>40,if XID.layout(41,3)
                eval('set(f,''pos'',XID.layout(41,1:4))','')
            end,end
        set(f,'vis','on')
    end
    iduisel('revert_dec')
    iduistat('Enter the resampling factor, and press the Insert button.')
    
elseif strcmp(flag,'comput')
    Tinfo=get(XID.sel(4,1),'UserData');
    Ts=Tinfo(1);t0=Tinfo(2);DL=Tinfo(3);
    if sampflag
        xdat=Ts*(xdat-[1 1])+t0;
    end
    xdat=sort(xdat);
    if xdat(1)<t0|xdat(1)>t0+Ts*(DL-1),xdat(1)=t0;end
    if xdat(2)>t0+Ts*(DL-1)|xdat(2)<t0,xdat(2)=t0+Ts*(DL-1);end
    xsamp1=max(floor(10^4*eps+(xdat(1)-t0)/Ts)+1,1);
    xsamp2=min(ceil((xdat(2)-t0)/Ts)+1-10^4*eps,DL);
    xsamp=[int2str(xsamp1),' ',int2str(xsamp2)];
    xtime=[num2str(xdat(1),5),' ',num2str(xdat(2),5)];
elseif strcmp(flag,'samples')
    strsamp=get(XID.plotw(14,2),'string');
    err=0;
    eval('test=eval([''['',strsamp,'']'']);','err=1;')
    if err,
        errordlg(['The entered sample numbers could not be evaluated.',...
                '\nPlease check your entry.'],'Error Dialog','modal');iduisel('revert');
        set(0,'Showhiddenhandles','off');
        return
    end
    indcol=find(strsamp==':');
    if length(indcol)==1,strsamp(indcol)=' ';end
    if length(indcol)>1
        errordlg('Use Resample to change the sampling interval.','Error Dialog','modal');
        iduisel('revert');
        set(0,'Showhiddenhandles','off');
        return
    end
    x=idstrip(strsamp);
    if length(x)<2
        errordlg('You must supply both upper and lower bounds on the interval.','Error Dialog','modal');
        iduisel('revert');
        set(0,'Showhiddenhandles','off');
        return
    end
    [xsamp,xtime]=iduisel('comput',x,1);
    set(XID.sel(4,1),'string',xtime);
    set(XID.plotw(14,2),'string',xsamp);
    
    
elseif strcmp(flag,'time')
    strsamp=get(XID.sel(4,1),'string');
    err=0;
    eval('test=eval([''['',strsamp,'']'']);','err=1;')
    if err,
        errordlg(['The entered time span could not be evaluated.',...
                '\nPlease check your entry.'],'Error Dialog','modal');iduisel('revert');
        set(0,'Showhiddenhandles','off');
        return
    end
    indcol=find(strsamp==':');
    if length(indcol)==1,strsamp(indcol)=' ';end
    if length(indcol)>1
        errordlg('Use Resample to change the sampling interval.','Error Dialog','modal');
        iduisel('revert');
        set(0,'Showhiddenhandles','off');
        return
    end
    x=idstrip(strsamp);
    if length(x)<2
        errordlg('You must supply both upper and lower bounds on the interval.','Error Dialog','modal');
        iduisel('revert');
        set(0,'Showhiddenhandles','off');
        return
    end
    [xsamp,xtime]=iduisel('comput',x,0);
    set(XID.sel(4,1),'string',xtime);
    set(XID.plotw(14,2),'string',xsamp);
    
elseif strcmp(flag,'down'),
    % The following is due to the unreliability of 'gca':
    axhand1=findobj(gcf,'tag','axis1','vis','on');
    axhand2=findobj(gcf,'tag','axis2','vis','on');
    
    if ~isempty(axhand2)
        axhand=[axhand1 axhand2];
        morax=1;
        pos=get(gcf,'pos');
        x=get(gcf,'currentpoint');
        if x(2)>0.5*pos(4)
            curax=axhand(1);altax=axhand(2);
        else
            curax=axhand(2);altax=axhand(1);
        end
    else
        curax=axhand1;moreax=0;
    end
    axes(curax)
    frame_no=rem(get(XID.sel(2,1),'userdata'),2)+1;
    set(XID.sel(2,1),'UserData',frame_no);
    h=get(XID.sel(3,1),'userdata');
    h=h(frame_no,:);
    eval('if get(h(2),''parent'')==curax,h=h([2 1]);,end','');
    eval(['if strcmp(get(get(h(2),''parent''),''vis''),''off''),',...
            'h=[h(1),0];end'],'h=[h(1),0];')
    set(XID.sel(5,1),'userdata',h);
    pt=get(curax,'currentpoint');
    x=[pt(1,1) pt(1,1) pt(1,1) pt(1,1) pt(1,1)];
    y=[pt(1,2) pt(1,2) pt(1,2) pt(1,2) pt(1,2)];
    set(h(1),'xdata',x,'ydata',y);
    if h(2)>0
        othax=get(get(h(2),'parent'),'userdata');
        yd=get(othax(5,1),'ydata');
        m1=max(yd);s1=sign(m1);
        if s1>0,m1=1.1*m1;else m1=0.9*m1;end
        m2=min(yd);s2=sign(m2);
        if s2<0,m2=1.1*m2;else m2=0.9*m2;end
        yl=[m1 m2];
        y1=[yl(1) yl(1) yl(2) yl(2) yl(1)];
        set(h(2),'xdata',x,'ydata',y1);
    end
    set(idnonzer(h),'vis','on')
    set(XID.plotw(14,1),'windowbuttonmotionfcn','iduisel(''move'');');
    set(XID.plotw(14,1),'windowbuttonupfcn','iduisel(''up'');');
    iduistat('Draw rectangle with the mousebutton down.',0,14);
elseif strcmp(flag,'move'),
    h=get(XID.sel(5,1),'UserData');
    x=get(h(1),'xdata');
    y=get(h(1),'ydata');
    pt=get(gca,'currentpoint');
    x(2)=pt(1,1);
    x(3)=pt(1,1);
    y(3)=pt(1,2);
    y(4)=pt(1,2);
    set(h(1),'xdat',x,'ydat',y);
    if h(2)>0,set(h(2),'xdat',x);end
    [xsamp,xtime]=iduisel('comput',x(1:2),0);
    set(XID.sel(4,1),'string',xtime);
    set(XID.plotw(14,2),'string',xsamp);
    
elseif strcmp(flag,'up'),
    set(gcf,'windowbuttonmotionfcn','');
    set(gcf,'windowbuttonupfcn','1;');
    iduistat('Press Insert to accept marked data set.',0,14)
    
elseif strcmp(flag,'revert')
    Tinfo=get(XID.sel(4,1),'UserData');
    DL=Tinfo(3);
    [xsamp,xtime]=iduisel('comput',[1 DL],1);
    set(XID.sel(4,1),'string',xtime);
    set(XID.plotw(14,2),'string',xsamp);
    frame_no=get(XID.sel(2,1),'UserData');
    if frame_no<1,
        set(0,'Showhiddenhandles','off');
        return
    end
    hbox=get(XID.sel(3,1),'userdata');
    h=hbox(frame_no,:);
    eval('set(h,''vis'',''off'')','')
    newframe=frame_no-1;if newframe==0;newframe=2;end
    set(XID.sel(2,1),'UserData',newframe);
    iduistat('Mark new data set.',0,14);
    
elseif strcmp(flag,'insert')
    if nargin==1
        [dat,dat_info,dat_no]=iduigetd('e');
        xsamp=get(XID.plotw(14,2),'string');
        indcol=find(xsamp==':');
        if length(indcol)==1,xsamp(indcol)=' ';end
        if length(indcol)>1
            errordlg('Use Resample to change the sampling interval.','Error Dialog','modal');
            set(0,'Showhiddenhandles','off');
            return
        end
        xs=idstrip(xsamp);
    else
        dat=xdat;dat_info=sampflag;dat_no=arg4;xs=arg5;
    end
    Tsamp = pvget(dat,'Ts');Tsamp = Tsamp{1}; 
    t0 = pvget(dat,'Tstart'); t0 = t0{1};
    
    dat=dat([xs(1):xs(2)]);
    if nargin==1,
        dat_n=get(XID.sel(2,1),'string');
    else
        dat_n=arg6;
    end
    dat = iduiinfo('add',dat,[' ',dat_n,' = ',dat_no,'([',int2str(xs(1)),...
            ':',int2str(xs(2)),'])']);
    dat = pvset(dat,'Name',dat_n);
    xsamp = iduiinsd(dat);
    if nargin>1,
        set(0,'Showhiddenhandles','off');
        return
    end
    lstr=length(dat_n);
    if dat_n(lstr)=='e'
        set(XID.sel(2,1),'string',[dat_n(1:lstr-1),'v']);
    end
    iduistat('New data sets may now be chosen.',0,14)
elseif strcmp(flag,'done')
    frame_no=get(XID.sel(2,1),'UserData');
    indx=6:frame_no;
    if ~isempty(indx),delete(idnonzer(XID.sel(indx))),end
    set(XID.plotw(14,1),'visible','off')
    
elseif strcmp(flag,'dtrend')
    [dat,dat_info,dat_no]=iduigetd('e');
    dat=dtrend(dat,xdat);
    dat_no = pvget(dat,'Name');
    dat_n=[dat_no,'d'];
    dat = iduiinfo('add',dat,[' ',dat_n,' = dtrend(',dat_no,',',int2str(xdat),')']);
    if nargin<3,sampflag=1;end
    dat = pvset(dat,'Name',dat_n);
    xsamp=iduiinsd(dat,sampflag);
    
elseif  strcmp(flag,'decim')
    [dat,dat_info,dat_no]=iduigetd('e');
    cwin=gcf;
    erflag=0;R=0;
    try
        R=eval(get(findobj(cwin,'tag','decfact'),'string'));
    catch
        erflag=1;
    end
    if R<=0|erflag
        errordlg('The resampling factor must be positive number.','Error Dialog','modal');
        set(0,'Showhiddenhandles','off');
        return
    end
    [rz,cz]=size(dat);
    if R>rz/2
        errordlg('The resampling factor must be less than half the number of data points.','Error Dialog','modal');
        set(0,'Showhiddenhandles','off');
        return
    end
    [dat,Ract] = idresamp(dat,R);
    dat_n= get(findobj(cwin,'tag','dataname'),'string');
    
    dat = pvset(dat,'Name',dat_n);
    dat = iduiinfo('add',dat,[' ',dat_n,' = idresamp(',dat_no,',',num2str(R),')']);
    iduiinsd(dat);
    
elseif strcmp(flag,'revert_io')
    [dat,dat_info,dat_n]=iduigetd('e');
    dat_n = pvget(dat,'Name');
    [N,ny,nu] = size(dat);
    set(XID.sel(3,2),'string',pvget(dat,'InputName'),'value',1); 
    set(XID.sel(4,2),'string',pvget(dat,'OutputName'),'value',1); 
    set(XID.sel(2,2),'string',[dat_n,'r']);
    set(findobj(XID.sel(1,2),'tag','wdname'),'string',dat_n);
elseif strcmp(flag,'revert_exp')
    [dat,dat_info,dat_n]=iduigetd('e');
    dat_n = pvget(dat,'Name');
    [N,ny,nu] = size(dat);
    if isa(dat,'iddata')% close Exo-window otherwise
        set(XID.sel(3,6),'string',pvget(dat,'ExperimentName'),'value',1); 
        set(XID.sel(2,6),'string',[dat_n,'x']);
        set(findobj(XID.sel(1,6),'tag','wdname'),'string',dat_n);
    else
        close(XID.sel(1,6))
    end
    
elseif strcmp(flag,'revert_dec')
    [dat,dat_info,dat_n]=iduigetd('e');
    decwin=iduiwok(41);
    set(findobj(decwin,'tag','dataname'),'string',[dat_n,'c']);
    set(findobj(decwin,'tag','wdname'),'string',dat_n);
    
elseif strcmp(flag,'insert_io')
    [dat,dat_info,dat_n]=iduigetd('e');
    err=0;
    s_newun=get(XID.sel(3,2),'string');
    newuno = get(XID.sel(3,2),'Value');
    if ~isempty(s_newun)
        newuname = s_newun(newuno);
    else
        newuname={};
    end
    s_newyn=get(XID.sel(4,2),'string');
    newyno = get(XID.sel(4,2),'Value');
    newyname = s_newyn(newyno);
    if isempty(newyname)
        errordlg('At least one output channel must be included',...
            'Error Dialog','modal')
        return
    end
    
    newname=deblank(get(XID.sel(2,2),'string'));
    if isa(dat,'iddata')
        dat = dat(:,newyname,newuname);
    else
        if isempty(newuname), newuname = [];end
        dat = dat(newyname,newuname);
    end
    if length(newyname)>1
        nnyna='{''';
        for kk=1:length(newyname)
            if kk<length(newyname)
                nnyna = [nnyna,'''',newyname{kk},''','''];
            else
                nnyna = [nnyna,newyname{kk},'''}'];
            end
        end
        newyname = nnyna;
    else 
        newyname = ['''',newyname{1},''''];
    end
    if length(newuname)>1
        nnuna='{''';
        for kk=1:length(newuname)
            if kk<length(newuname)
                nnuna = [nnuna,'''',newuname{kk},''','''];
            else
                nnuna = [nnuna,newuname{kk},'''}'];
            end
        end
        newuname = nnuna;
    elseif length(newuname)==1
        
        newuname = ['''',newuname{1},''''];
    else
        newuname = '';
    end
    dat = iduiinfo('add',dat, [' ',newname,' = ',dat_n,'(:,',newyname,',', newuname,')']);
    dat = pvset(dat,'Name',newname);
    iduiinsd(dat);
elseif strcmp(flag,'insert_exp')
    [dat,dat_info,dat_n]=iduigetd('e');
    err=0;
    s_newexp=get(XID.sel(3,6),'string');
    newexp = get(XID.sel(3,6),'Value');
    newexpname = s_newexp(newexp);
    newname=deblank(get(XID.sel(2,6),'string'));
    if isempty(newexpname)
        errordlg('At least one experiment must be chosen','Error Dialog','modal');
        set(0,'Showhiddenhandles','off');
        return
    end
    dat = getexp(dat,newexpname);
    str =[];
    for kk = 1:length(newexpname)
        str = [str,newexpname{kk},','];
    end
    str = str(1:end-1);
    dat = iduiinfo('add',dat, [' ',newname,' = ',dat_n,'{',str ,'}']);
    dat = pvset(dat,'Name',newname);
    iduiinsd(dat);
    
elseif strcmp(flag,'done_io')
    set(XID.sel(1,2),'vis','off')
    
end
set(0,'Showhiddenhandles','off');
