function iduitrf(arg)
%IDUITRF Transforms Working Data.

%   L. Ljung 9-27-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/10 23:20:01 $


Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
XIDplotw = XID.plotw;
XIDlayout = XID.layout;

if strcmp(arg,'open')
    figname=idlaytab('figname',39);
    if ~figflag(figname,0)
        iduistat('Opening the data transformation dialog box ...')
        layout
        FigW = iduilay2(3);
        
        f=figure('vis','off',...
            'DockControls','off',...
            'NumberTitle','off','Name',figname,'HandleVisibility','callback',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),...
            'tag','sitb39');
        set(f,'Menubar','none');
        
        % LEVEL1
        
        pos = iduilay1(FigW,3);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'Pos',pos(2,:),'style','push',...
            'string','Transform','callback',...
            'iduipoin(1);iduitrf(''trf'');iduipoin(2);');
        uicontrol(f,'Pos',pos(3,:),'style','push',...
            'callback','set(gcf,''visible'',''off'')','string','Close');
        uicontrol(f,'Pos',pos(4,:),'style','push','string','Help',...
            'callback','iduihelp(''trf.hlp'',''Help: Data Transformation'');');
        
        % LEVEL 2e
        lev2 = pos(1,2)+pos(1,4);
        boxno=1;
        pos = iduilay1(FigW,8,4,lev2,[],1.5);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        XID.trf(7) = uicontrol(f,'pos',pos(8,:),'style','text',...
            'HorizontalAlignment','right','string','Name of new data');
        XID.trf(8)=uicontrol(f,'pos',pos(9,:),'style','edit','Horizontalalignment',...
            'left',...
            'backgroundcolor','white','callback',[]); % number of points
        XID.trf(1)=uicontrol(f,'pos',pos(7,:),'style','edit','Horizontalalignment',...
            'left',...
            'backgroundcolor','white','callback',[],'string',int2str(100)); % number of points
        XID.trf(2)=uicontrol(f,'pos',pos(6,:),'style','text','Horizontalalignment',...
            'right','string','Number of Frequencies');
        XID.trf(3)=uicontrol(f,'pos',pos(5,:),'style','pop','Horizontalalignment',...
            'left',...
            'Backgroundcolor','white',...
            'string','linear|logarithmic','callback','iduitrf(''pop2'');');
        XID.trf(4)=uicontrol(f,'pos',pos(4,:),'style','text','Horizontalalignment',...
            'right',...
            'string','Frequency Spacing');
        XID.trf(5)=uicontrol(f,'pos',pos(3,:),'style','pop','Horizontalalignment',...
            'left',...
            'Backgroundcolor','white',...
            'string','Frequency Function|Frequency Domain Data','callback','iduitrf(''pop1'');');
        XID.trf(6)=uicontrol(f,'pos',pos(2,:),'style','text','Horizontalalignment',...
            'right',...
            'string','Transform to:');
        
        %       usd=get(XIDplotw(16,1),'userdata');
        %       mspa=deblank(usd(2,:));
        %       if isempty(eval(mspa))
        %          mspa = 'Default';
        %       end
        %       set(h1,'string',mspa);
        %       set(h2,'value',eval(usd(3,:)));
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
    dat = iduigetd('e');
    [N,ny,nu] = sizedat(dat);
    if isa(dat,'idfrd')
        if nu==0
            strpop = '(Frequency Function)|Frequency Domain Data';
        else
            strpop = 'Frequency Function|Frequency Domain Data';
        end
        set(XID.trf(5),'string',strpop,'value',2);
    elseif strcmp(pvget(dat,'Domain'),'Frequency')
         if nu==0
            strpop = '(Frequency Function)|(Frequency Domain Data)|Time Domain Data';
            val = 3;
        else
            strpop = 'Frequency Function|(Frequency Domain Data)|Time Domain Data';
            val = 1;
        end
        set(XID.trf(5),'string',strpop,'value',val);
    else
         if nu==0
            strpop = '(Frequency Function)|Frequency Domain Data|(Time Domain Data)';
            val = 2;
        else
            strpop = 'Frequency Function|Frequency Domain Data|(Time Domain Data)';
            val = 1;
        end
        set(XID.trf(5),'string',strpop,'value',val);
    end
    nam = pvget(dat,'Name');
    set(XID.trf(8),'string',[nam,'f']);
    iduitrf('pop1')
elseif strcmp(arg,'pop1')
    dat = iduigetd('e');
    nam = pvget(dat,'Name');
    
    val = get(XID.trf(5),'value');
    if val == 2
        set(XID.trf([1 2 3 4]),'enable','off')
        set(XID.trf(8),'string',[nam,'fd']);
    elseif val==1
        set(XID.trf([1 2 3 4]),'enable','on')
        set(XID.trf(8),'string',[nam,'ff']);
    else
        set(XID.trf([1 2 3 4]),'enable','off')%to time domain
        set(XID.trf(8),'string',[nam,'td']);
    end
elseif strcmp(arg,'trf')
    dat = iduigetd('e');
    [N,ny,nu]=sizedat(dat);
    td = 0; fd = 0; fr = 0;
    if isa(dat,'idfrd')
        fr = 1;
    elseif strcmp(pvget(dat,'Domain'),'Frequency')
        fd = 1;
    else
        td = 1;
    end
    val = get(XID.trf(5),'value');
    dat_n1 = pvget(dat,'Name');
    if (val==1)&fr
        % errordlg([dat_n1,' is already a frequency function.'],'Error Dialog','modal');
        %return
    elseif (val==2)&fd
        errordlg([dat_n1,' is already frequency domain data.'],'Error Dialog','modal');
        return
    elseif (val==3)&td
        errordlg([dat_n1,' is already time domain data.'],'Error Dialog','modal');
        return
    end
    
    dat_n = get(XID.trf(8),'string');
    if val == 2
        if isa(dat,'iddata')
            try
                dat1 = fft(dat);
            catch
                erm = lasterr;
                errordlg(erm,'Error in Transformation','modal');
                return
            end
            upd = [' ',dat_n,' = fft(',dat_n1,')'];
        else % idfrd
            dat1 = iddata(dat,'me');
            upd = [' ',dat_n,' = iddata(',dat_n1,',''me'')'];
        end
        
    elseif val==1
        nop = eval([get(XID.trf(1),'string')]);
        spval = get(XID.trf(3),'value');
        if isa(dat,'idfrd')
            dat = iddata(dat);
        end
        dom = pvget(dat,'Domain');
        
        ts = pvget(dat,'Ts'); ts = ts{1};
        
        if strcmp(dom,'Frequency')
            fre1 = pvget(dat,'SamplingInstants');
            fre1 = fre1{1}; %%LL multiexp
            f1 = min(fre1); f2 = max(fre1);
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
            if f1 == 0, f1 = f2/1000; end %%LL
            freqs = logspace(log10(f1),log10(f2),nop);
            sfre = ['log10(',num2str(f1),'),log10(',num2str(f2),')'];
            sfre = ['logspace(',sfre,',',int2str(nop),')'];
        end
        if nu==0
            errordlg('Data with no input cannot be transformed to frequency function data.',...
                'Error Dialog','modal');
            return
        end
        dat1 = spafdr(dat,[],freqs);
        upd = [' ',dat_n,' = spafdr(',dat_n1,',[],',sfre,')'];
    else % to time domain
        try
            dat1 = ifft(dat);
        catch
            errordlg(lasterr,'Error in IFFT','modal');
            return
        end
        upd = [' ',dat_n,' = ifft(',dat_n1,')'];
    end
    %%LL info
    
    dat1 = pvset(dat1,'Name',dat_n,'Notes',pvget(dat,'Notes'));
    dat1 = iduiinfo('add',dat1,upd);%%LL text
    try
    iduiinsd(dat1);
catch
    errordlg('Transformation failed. Check original data.','Error Dialog','Modal')
end
end