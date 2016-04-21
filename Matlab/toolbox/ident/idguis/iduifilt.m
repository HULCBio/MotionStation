function iduifilt(flag,filter,call)
%IDUIFILT Handles prefiltering of data for ident.
%   FLAG:
%   open         Opens the dialog box.
%   spectra      Computes and plots the spectra.
%                If FILTER has the value 'filt' this is done for
%                the filtered data, otherwise for the estimation data.
%   down,move,up Draws the box that defines the frequency range
%   filter       Applies the selected filter to estimation data and stores
%                the result as userdata of XIDfilt(1,1).
%   revert       One push removes the outline box, the next clears the
%                filtered data, if any.
%   insert       Inserts the filtered data into the data summary board.
%   mark         Marks the outline box, based on information in XIDfilt(3,1).
%   done         Closes the dialog box.

%   L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $ $Date: 2004/04/10 23:19:39 $

% Userdata Used: 
%       XIDfilt(1,1) The filtered data, if any
%       XIDfilt(2,1) The handle number of the drawn box, if any
%       XIDfilt(3,1) The handle numbers of the filtered spectra plots
%       XIDfilt(4,1) The sampling interval
%       XIDfilt(5,1) The string that describes the filtering

%global XIDmen XIDfilt XIDplotw
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
if nargin<3
    call = 'data';
end

if nargin<2, filter='nofilter';end
if isempty(filter)
    filter = 'nofilter';
end
 [dat,dat_info,dat_n]=iduigetd('e','me');
    dom = pvget(dat,'Domain'); dom = lower(dom(1));
if strcmp(flag,'open')
    figname='Prefilter Data';
    s1='iduipoin(1);';s2='iduipoin(1);iduistat(''Compiling ...'');';
    s3='iduipoin(2);';
    %[dat,dat_info,dat_n]=iduigetd('e','me');
    %dom = pvget(dat,'Domain'); dom = lower(dom(1));
    if isempty(iduiwok(15))
        iduistat('Opening dialog box ...')
        layout
        butwh=[1.3*mStdButtonWidth mStdButtonHeight];%butw=55;buth=25;
        butw=butwh(1);buth=butwh(2);
        ftb=2;  % Frame to button
        bb = 2; % between buttons, horizontally
        bbver = 4; % Between buttons, vertically
        etf = mEdgeToFrame;
        XID.plotw(15,1)=idbuildw(15);
        XID = get(Xsum,'UserData');
        set(XID.plotw(15,1),'units','pixels');
        FigWH=get(XID.plotw(15,1),'pos');FigWH=FigWH(3:4);
         if dom=='f'
            lvnr = 8; lvv=8;
        else
            lvnr = 10; lvv=11;
        end
        lev1=max(etf,(FigWH(2)-(lvv)*buth-9*bbver-2*mFrameToText)/2)+buth;
       
        pos = iduilay1(mStdButtonWidth+2*mFrameToText,lvnr,lvnr,...
            lev1-mEdgeToFrame,bbver);
       % pos=pos+[(FigWH(1)-butw-2*bb-2*etf)*ones(lvnr+1,1),zeros(1vnr+1,3)];
        % pos=pos+[(FigWH(1)-butw-2*bb-2*etf)*ones(11,1),zeros(11,3)];
              pos=pos+[(FigWH(1)-butw-2*bb-2*etf)*ones(lvnr+1,1),zeros(lvnr+1,3)];  
        XID.filt(1,1)=uicontrol(XID.plotw(15,1),'pos',pos(1,:),'style','frame');
        ttip='Enter lower and upper limits for the frequency band.';
        XID.filt(5,1)=uicontrol(XID.plotw(15,1),'pos',pos(2,:),'style',...
            'text','tooltip',ttip,'string',str2mat('Range'),'HorizontalAlignment','left');
        XID.filt(3,1)=uicontrol(XID.plotw(15,1),'pos',pos(3,:)+[0 5 0 0],...
            'style','edit','tooltip',ttip,...
            'callback',[s1,'iduifilt(''mark'');',s3],'backgroundcolor','white',...
            'HorizontalAlignment','left');
        uicontrol(XID.plotw(15,1),'pos',pos(4,:),'style','text',...
            'string',str2mat('Range is'),'HorizontalAlignment','left');
        
        XID.filt(4,1)=uicontrol(XID.plotw(15,1),'pos',pos(5,:)+[0 5 0 0],...
            'style','popupmenu','string','Pass band|Stop band',...
            'Backgroundcolor','white',...
            'value',1,'userdata',1);
        uicontrol(XID.plotw(15,1),'pos',pos(6,:),'style','text',...
            'string','Data name:','HorizontalAlignment','left');
        XID.filt(2,1)=uicontrol(XID.plotw(15,1),'pos',pos(7,:)+[0 5 0 0],...
            'style','edit','backgroundcolor','white',...
            'HorizontalAlignment','left');
        if dom=='t'
            XID.filt(6,1)= uicontrol(XID.plotw(15,1),'Pos',pos(10,:),'style',...
                'push','callback',...
                [s1,'iduifilt(''revert'');',s3],'string','Revert');
            uicontrol(XID.plotw(15,1),'Pos',pos(8,:),'style','push','callback',...
                [s2,'iduifilt(''filter'');',s3],'string','Filter','tooltip',...
                'Press to perform filtering according to pass/stop band');
            cbi = [s1,'iduifilt(''insert'');',s3];
            lvinsert = 9;
            lvadj = 0;
        else 
            cbi =[s1,'iduifilt(''filter'');iduifilt(''insert'');',s3];
            lvinsert = 8;
            lvadj = 2;
        end
        
        
        XID.filt(7,1)=uicontrol(XID.plotw(15,1),'Pos',pos(lvinsert,:),'style','push','callback',...
            cbi,'string','Insert','enable','on');
        
        uicontrol(XID.plotw(15,1),'pos',pos(11-lvadj,:),'style','push','callback',...
            'set(gcf,''vis'',''off'');','string','Close');
        uic=findobj(XID.plotw(15,1),'type','uicontrol');
        set(uic,'units','norm');
        eval('set(XID.plotw(15,1),''pos'',XID.layout(37,1:4))','')
        set(XID.plotw(15,1),'vis','on')
        set(Xsum,'Userdata',XID);
    end %if figflag
    ax=findobj(XID.plotw(15,1),'type','axes');
    for kax=ax(:)',axes(kax),cla,end
    %[dat,dat_info,dat_n]=iduigetd('e','me');
    inf.ynames = pvget(dat,'OutputName');
    inf.unames = pvget(dat,'InputName');
    uynames={};
    for kkk = 1:length(inf.unames)
        uynames{kkk} = inf.ynames;
    end
    inf.uynames = uynames;
    tit = get(XID.plotw(15,1),'Name');
    col = findstr(tit,':'); tit=tit(col:end);
    %   dom = pvget(dat,'Domain'); dom =lower(dom(1));
    if dom=='t'
        tit = ['Filter',tit];
    else
        tit = ['Select Range',tit];
    end
    set(XID.plotw(15,1),'Name',tit)
    iduiiono('set',inf,15);
    iddatfig(0,15);
    ax = axis;
    set(XID.filt(3,1),'string',[num2str(ax(1)),' ',num2str(ax(2))])
    iduital(15);
    set(XID.filt(2,1),'string',[dat_n,'f']);
    if strcmp(call,'data')
        if dom=='f'
            cbi = [s1,'iduifilt(''filter''),iduifilt(''insert'');',s3];
        else
            cbi = [s1,'iduifilt(''insert'');',s3];
        end
        set(XID.filt(7,1),'callback',cbi,'string','Insert','Enable','on');
    else
        if dom=='f'
            set(XID.filt(7,1),'callback',...
                [s1,'iduifilt(''filter'');',s3],'string','Use','Enable','on');
        else
            set(XID.filt(7,1),'callback',...
                [s1,'iduifilt(''focus'');',s3],'string','Insert','Enable','off');
        end
    end
    set(XID.plotw(15,1),'vis','on')
    iduistat('Ready to prefilter.')
    iduistat('Mark desired frequency range using mouse or keyboard.',0,15)
    
elseif strcmp(flag,'down'),
    % The following is due to the unreliability of 'gca':
    axhand1=findobj(gcf,'tag','axis1','vis','on');
    axhand2=findobj(gcf,'tag','axis2','vis','on');
    
    if ~isempty(axhand2)
        axhand=[axhand1 axhand2];
        morax=1;
        pos=get(gcf,'pos');
        x=get(gcf,'currentpoint');
        if x(2)>0.5*pos(4),
            curax=axhand(1);altax=axhand(2);
        else 
            curax=axhand(2);altax=axhand(1);
        end
    else
        curax=axhand1;moreax=0;
    end
    axes(curax)
    
    
    h=get(XID.filt(2,1),'userdata');
    eval(['if get(h(2),''parent'')==curax,h=h([2 1]);end'],'h=[h(1),0];')
    set(XID.filt(2,1),'userdata',h);
    pt=get(curax,'currentpoint');
    x=[pt(1,1) pt(1,1) pt(1,1) pt(1,1) pt(1,1)];
    y=[pt(1,2) pt(1,2) pt(1,2) pt(1,2) pt(1,2)];
    set(h(1),'xdata',x,'ydata',y);
    if h(2)>0
        othax=get(get(h(2),'parent'),'userdata');
        yd=get(othax(5,1),'ydata');
        yl=[0.8*max(yd),1.2*min(yd)];
        y1=[yl(1) yl(1) yl(2) yl(2) yl(1)];
        set(h(2),'xdata',x,'ydata',y1);
    end
    set(idnonzer(h),'vis','on')
    set(XID.plotw(15,1),'windowbuttonmotionfcn','iduifilt(''move'');');
    set(XID.plotw(15,1),'windowbuttonupfcn','iduifilt(''up'')');
    iduistat('Draw a rectangle with the mousebutton down.',0,15);
elseif strcmp(flag,'move')
    
    h=get(XID.filt(2,1),'UserData');
    x=get(h(1),'xdata'); 
    y=get(h(1),'ydata'); 
    pt=get(gca,'currentpoint');
    x(2)=pt(1,1); 
    x(3)=pt(1,1);
    y(3)=pt(1,2); 
    y(4)=pt(1,2);
    set(h(1),'xdat',x,'ydat',y);
    if h(2)>0
        set(h(2),'xdat',x);
    end
    fre=sort([x(1) x(2)]);
    set(XID.filt(3,1),'string',[num2str(fre(1)),' ',num2str(fre(2))]);
    
elseif strcmp(flag,'up'),
    
    set(gcf,'windowbuttonmotionfcn','');
    set(gcf,'windowbuttonupfcn','1;');
    if dom=='t'
    iduistat('Press Filter to compute filtered data.',0,15)
    else
            iduistat('Press Insert to insert data with chosen range.',0,15)
end
elseif strcmp(flag,'mark')
    h=get(XID.filt(2,1),'userdata');
    freqs = eval(['[',get(XID.filt(3,1),'string'),']'],'[]');
    if length(freqs)<2
        errordlg('Two frequency range limits must be supplied.','Error Dialog','modal');
        return
    end
    
    x(1)=freqs(1);x(2)=freqs(2);x(3)=freqs(2);x(4)=freqs(1);x(5)=freqs(1);
    a=get(XID.plotw(15,1),'userdata');hh=idnonzer(h);
    for kk=hh(:)'%1:length(idnonzer(h))
        yl=get(get(kk,'parent'),'ylim');yl=[1.2*yl(1) 0.8*yl(2)];
        y1=[yl(1) yl(1) yl(2) yl(2) yl(1)];
        set(kk,'xdata',x,'ydata',y1);%,'vis','on');
        set(kk,'vis','on')
    end
    iduistat('Press Filter to compute filtered data.',0,15)
    
elseif strcmp(flag,'revert')
    delete(idnonzer(get(XID.filt(3,1),'Userdata')));
    set(XID.filt(1,1),'UserData',[]);
    iduistat('Select new frequency range.',0,15)
    
elseif strcmp(flag,'filter')
    
    [dat,dat_info,dat_n]=iduigetd('e',1);  
    dom = pvget(dat,'Domain');
    dom = lower(dom(1));
    
    Tsamp = pvget(dat,'Ts');Tsamp = Tsamp{1};%eval(deblank(dat_info(1,:)));
    freqs=eval(['[',get(XID.filt(3,1),'string'),']'],'[]');%*Tsamp*2;
    if dom=='t'
        freqs = freqs*Tsamp*2;
    else
        fre = pvget(dat,'SamplingInstants');fre = fre{1};%%LL experiments!!
        fend = fre(end);
    end
    if length(freqs)<2
        errordlg('Two frequency range limits must be supplied.','Error Dialog','modal');
        return
    end
    freqs=sort(freqs);
    usd=get(XID.plotw(15,2),'userdata');
    if dom=='t'
        if eval(usd(3))==1,freqs=freqs/pi/2;end % If unit rad/s
    end
    if get(XID.filt(4,1),'value')-1,BP=0;else BP=1;end
    if dom=='t'
        if freqs(1)<0.01, 
            freqs=freqs(2); 
            if BP,
                type=1;
            else 
                type=0;
            end
            %type=1 means low pass here
        elseif freqs(2)>0.95,
            freqs=freqs(1); 
            if BP,
                type=0;
            else 
                type=1;
            end,
        end
    end
    if length(freqs)>1,
        sfreqs=['[',num2str(freqs(1)),',',num2str(freqs(2)),']'];
        if BP, type=1;else type=0;end
    else
        sfreqs=num2str(freqs);
    end
    ord=5;
    
    if type
        if dom=='t'
            [zf,filt]=idfilt(dat,ord,freqs); 
            text = ['5,',sfreqs];
            filtstr=['idfilt(',dat_n,',',text,')'];
            eststr = ['[a,b,c,d] = butter(',text,');'];
        else
            filt = freqs;
            zf = idfilt(dat,freqs);
            filtstr=['idfilt(',dat_n,',',sfreqs,')'];
            eststr = [];
        end
    else
        if dom=='t'
            [zf,filt]=idfilt(dat,ord,freqs,'high');
            if length(freqs)>1
                sstop = 'stop';
            else
                sstop = 'high';
            end
            text = ['5,',sfreqs,',''',sstop,''''];
            filtstr=['idfilt(',dat_n,',',text,')'];
            eststr = ['[a,b,c,d] = butter(',text,');'];
        else
            if freqs(2)<fend
                filt = [0 freqs(1);freqs(2) fend];
            else
                filt = [0 freqs(1)];
            end
            zf = idfilt(dat,filt);
            filtstr = ['idfilt(',dat_n,',[0 ,',sfreqs,' ',num2str(fend),'])'];
            eststr = [];
        end
    end
    set(XID.filt(1,1),'userdata',zf);set(XID.filt(5,1),'userdata',filtstr);
    try
        set(XID.procest(2,9),'Userdata',{filt,eststr});
    end
    try
        set(XID.parest(18),'Userdata',{filt,eststr});
    end
    
    iddatfig(-1,15);
    XID = get(Xsum,'UserData');
    callcase = get(XID.filt(7,1),'enable');
    if strcmp(lower(callcase),'on')
        iduistat('Filtered data spectra shown. Press Insert to accept.',0,15)
    else
        iduistat('Filtered spectra shown. This filter will be used for Estimaton Focus.',0,15)
    end
    
elseif strcmp(flag,'insert')
    
    zf=get(XID.filt(1,1),'userdata');
    if isempty(zf),
        errordlg({'No filtered data selected.',...
                'Press Filter to filter the working data set.'},'Error Dialog','modal')
        return
    end
    [dat,dat_info,dat_no]=iduigetd('e');
    dat_n=get(XID.filt(2,1),'string');
    addendum=[' ',dat_n,' = ',get(XID.filt(5,1),'userdata')];
    zf = iduiinfo('add',zf,addendum);%dat_info=str2mat(dat_info,addendum);
    zf = pvset(zf,'Name',dat_n);
    iduiinsd(zf);
    XID = get(Xsum,'UserData');
    if dom=='t'
    iduistat('New filter can now be defined.',0,15);
    else
         iduistat('New range can now be selected.',0,15);
    end
elseif strcmp(flag,'done')
    
    set(XID.plotw(15,1),'vis','off');
    
end
set(Xsum,'UserData',XID);
