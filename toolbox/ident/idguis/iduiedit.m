function [dat,dat_n,dat_i,outarg]=iduiedit(arg,wi_no)
%IDUIEDIT Handles various edit functions.
%      Arguments: 
%   new            Clears (deletes) all models and data from the summary board
%   close_all      Closes all ident windows
%   pres           Fills out the Text Info dialog box
%   present        Activates the presentation of the model/data to the command window
%   slide          Handles the slider in the Text Info window
%   present_update Handles the update of info from the Text Info box
%   clwin          Closes the wiev windows
%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.22.4.1 $ $Date: 2004/04/10 23:19:36 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

sumb=findobj(get(0,'children'),'flat','tag','sitb30');
sumbs=[XID.sumb(1);sumb(:)];
iduistat('');
if strcmp(arg,'new')
    try
        PathFileName=XID.path;
    catch
        PathFileName = [];
    end
    if isempty(PathFileName),
        PathFileName='Untitled.sid';
    end
    if strcmp(PathFileName,'Untitled.sid')
        quest=['Save Session before closing it?'];
        untitflag=1;
    else
        quest=['Save to ',PathFileName,' before closing session?'];
        untitflag=0;
    end
    if XID.counters(5)
        click=questdlg(quest,'Save Session');
    else
        click='No';
    end
    lasterr('')
    if strcmp(click,'Cancel')
        return
    elseif strcmp(click,'Yes')
        if untitflag
            iduisess('save_as');
        else
            iduisess('save',PathFileName);
        end
    end
    if ~isempty(lasterr),
        % Saving errored, so return
        return
    end
    %   if strcmp(click,'Yes')|strcmp(click,'No')
    iduiwast('kill');
    XID.path =[];
    set(Xsum,'userdata',XID);
    set(XID.sumb(1),'name',idlaytab('figname',16));
    mod=findobj(XID.sumb(1),'tag','modelline');
    dat=findobj(XID.sumb(1),'tag','dataline');
    dat1=findobj(XID.sumb(1),'tag','seles');
    dat2=findobj(XID.sumb(1),'tag','selva');
    set([get(dat1,'children');get(dat2,'children')],'vis','off');
    set(dat1,'userdata',[]);
    set(get(dat1,'zlabel'),'userdata','');
    set(get(dat2,'zlabel'),'userdata','');
    for ka=[mod(:)',dat(:)']
        try
            nam=findobj(get(ka,'parent'),'tag','name');
        catch
            nam=[];
        end
        set([ka,nam],'vis','off','userdata',[]);
        set(get(ka,'parent'),'userdata',[],'color',get(XID.sumb(1),'color'));
        tag=get(ka,'tag');
        if strcmp(tag,'modelline'),set(ka,'tag','modelline0','linewidth',0.5),end
        if strcmp(tag,'dataline'),set(ka,'tag','dataline0','linewidth',0.5),end
    end
    XID.counters(3:4)=[0 0];
    XID.names =[];
    close(sumb)
    for kwin=[1:15,40]
        if iduiwok(kwin),
            
            close(iduiwok(kwin))
        end
    end
    set(XID.plotw([1 13 3 6 5 2 4 7 40],2),'enable','off');
    close(iduiwok(20));close(iduiwok(21));close(iduiwok(22));
    XID.counters(5)=0;
    set(XID.sbmen([3 4 5]),'enable','off')
    [label,acc]=menulabel('&Open session... ^o');
    set(XID.sbmen(1),'label',label,'tag','open');
    iduistat('Ready to open new session or import data.')
    %   end % if click etc
elseif strcmp(arg,'close_all')
    %XID=get(XID.sumb(1),'userdata');
    try
        PathFileName=XID.path; 
    catch
        PathFileName = [];
    end
    
    if isempty(PathFileName),
        PathFileName='Untitled.sid';
    end
    if strcmp(PathFileName,'Untitled.sid')
        quest=['Save Session before exiting?'];
        untitflag=1;
    else
        quest=['Save to ',PathFileName,' before exiting?'];
        untitflag=0;
    end
    if XID.counters(5)
        click=questdlg(quest,'Save Session');
    else
        click='No';
    end
    lasterr('')
    if strcmp(click,'Cancel')
        return
    elseif strcmp(click,'Yes')
        if untitflag
            iduisess('save_as');
        else
            iduisess('save',PathFileName);
        end
    end
    if ~isempty(lasterr),
        % Saving errored, so return
        return
    end
    % 
    if isempty(XID.laypath)
        click=questdlg(['Do you wish to save start-up information ',...
                ' for the next IDENT session?'],'Save Preferences'); 
        
        if strcmp(lower(click),'yes')
            click=questdlg(['Use the file-finder to select a directory to store ', ...
                    'idprefs.mat. The directory should be on your ',...
                    'MATLABPATH. Press CONTINUE to open the file-finder. ', ...
                    'Press CANCEL here or in the file-finder to ',...
                    'abort.'] ,...
                'Choose a Directory for Start-Up Information',...
                'Continue','Cancel','Continue');
            if strcmp(lower(click),'continue') 
                midprefs(1,1);idlaytab('save_file');
            end  
        elseif strcmp(lower(click),'cancel')
            return
        end
    end	
    figs=get(0,'children');
    idtoolw=findobj(figs,'flat','tag','sitb16');
    iduistat('Closing all ident windows.')
    for kf=figs(:)'
        tag=get(kf,'tag');
        if length(tag)>=4,
            if strcmp(tag(1:4),'sitb')&~strcmp(tag,'sitb16')
                delete(kf)
            end
        end
    end
    delete(idtoolw),XID.counters(5)=0;
    %   end % if strcmp(click,...
end

if strcmp(arg,'pres')
    cura=wi_no;   %This is the handle of the desired axes
    ismodel=0;
    
    hand1=findobj(cura,'tag','modelline');ismodel=1;
    if isempty(hand1);hand1=findobj(cura,'tag','dataline');ismodel=0;end
    if isempty(hand1)
        iduistat('This object cannot be opened')
        return
    end
    iduipw(8);iduistat('');
    XID = get(Xsum,'UserData');
    fig=XID.plotw(8,1);h=get(fig,'userdata');
    hand2=findobj(cura,'tag','name');
    hand3=hand2;
    dat=get(hand1,'UserData');
    try
        dat_n = pvget(dat,'Name');
    catch
        dat_n = dat.Name;
    end
    dat_i = iduiinfo('get',dat,'str');%get(hand2,'UserData');
    set(fig,'name',['Data/model Info: ',dat_n])
    [Ndat,Nz]=size(dat);
    [sl1,sl2]=size(dat_i);
    isparmod=0;
    if ismodel,
        set(h(4),'string','Model name:','userdata',...
            [hand1;hand2]);
    else
        set(h(4),'string','Data name:','userdata',...
            [hand1;hand2]);
    end
    set(h(5),'string',dat_n,'userdata',dat_n);
    col=get(hand1,'color');
    cols=['[',num2str(col(1)),',',num2str(col(2)),',',num2str(col(3)),']'];
    set(h(6),'string',cols,...
        'userdata',[hand1]);
    if ~isaimp(dat)%isa(dat,'iddata')|isa(dat,'idpoly')
        if isa(dat,'idproc')
            dashfactor = XID.dash;
            infostr = display(dat,0,0,0,dashfactor(2),dashfactor(1));%1.5,1.8);
        else
        infostr=display(dat);
    end
        kkdel = [];
        for kk = 1 : size(infostr,1)
            if strcmp(infostr(kk,:),blanks(size(infostr,2)))
                kkdel = [kkdel;kk];
            end
        end
        infostr(kkdel,:)=[];
        
    elseif isa(dat,'idarx')&isaimp(dat) % Impulse reponse case
        ny = size(dat,'ny');
        nu = size(dat,'nu');
        es = pvget(dat,'EstimationInfo');
        try
            datn = es.DataName;
        catch
            datn = '';
        end
        
        infostr = str2mat('Impulse response model.',...
            sprintf('%d outputs and %d inputs',ny,nu),...
            sprintf('Estimated from data set %s',datn) );
    end
    set(h(3),'string',infostr);
    
    set(h(1),'userdata',dat_i,...
        'string',dat_i) % 8  var 6
    minslide=min(-2,-sl1);
    set(h(2),'max',-1,'min',minslide,'userdata',1,'value',-1);  
    figure(XID.plotw(8,1));
elseif strcmp(arg,'slide')
    h=get(gcf,'userdata');
    text=get(h(1),'userdata');
    [sl1,dum]=size(text);
    first_row=-floor(get(h(2),'value'));
    first_row=max(first_row,1);
    set(h(1),'string',text(first_row:sl1,:));
    set(h(2),'userdata',first_row);  
elseif strcmp(arg,'present')
    h=get(gcf,'userdata');
    usd=get(h(4),'userdata');
    dat=get(usd(1),'userdata');
    str=get(h(4),'string');
    if strcmp(str(1:3),'Dat')
        iduistat('The data are displayed at MATLAB command line.')
        dat
    else
        usd1=get(h(3),'userdata');
        [rusd1,cusd1]=size(usd1);
        if cusd1>2,Method=usd1(1,1:3);else Method=[];end
        if ~strcmp(Method,'spa')&~strcmp(Method,'cra')
            iduistat('Information on the model is presented at MATLAB command line.');
            present(dat)%(iduicalc('unpack',dat,1))
        else
            iduistat('The response is displayed at MATLAB command line.')
            dat
        end 
    end
    
elseif strcmp(arg,'update_name')
    XID.counters(5)=1;
    h=get(gcf,'userdata');
    handles=get(h(4),'userdata');
    oldnam=get(h(5),'userdata');
    newnam=deblank(get(h(5),'string'));
    if strcmp(oldnam,newnam),return,end
    add=[' ',newnam,' = ',oldnam,'  % Rename'];
    set(handles(2),'string',newnam)
    set(h(5),'userdata',newnam)
    inf=get(h(1),'string');
    set(h(1),'string',str2mat(inf,add),'userdata',str2mat(inf,add));
    usd=get(h(3),'UserData');
    objhand = handles(1);
    dat = get(objhand,'UserData');
    if isa(dat,'iddata')
        ismodel = 0;
    else
        ismodel = 1;
    end
    
    flag=0;
    
    newstr=get(h(1),'string');
    first_row=get(h(2),'userdata');
    begstr=get(h(1),'userdata');
    if first_row>1
        begstr=begstr(1:first_row-1,:);
        sl=str2mat(begstr,newstr);
    else
        sl=newstr; 
    end
    
    axpar=get(handles(2),'parent');
    dat = pvset(dat,'Name',newnam);
    dat = iduiinfo('set',dat,sl);
    set(objhand,'userdata',dat);
    if ismodel
        plots=get(axpar,'userdata');
        fittext=findobj(plots,'flat','tag','fits');
        if ~isempty(fittext)
            set(fittext,'string',[newnam,': ',num2str(get(fittext,'userdata'))])
        end
    end
    if strcmp(get(axpar,'tag'),get(get(XID.hw(3,1),'zlabel'),'userdata'))
        % then we are changing the color of the working data
        set(findobj(XID.hw(3,1),'tag','name'),'string',newnam)
    end
    if strcmp(get(axpar,'tag'),get(get(XID.hw(4,1),'zlabel'),'userdata'))
        % then we are changing the color of the validation data
        set(findobj(XID.hw(4,1),'tag','name'),'string',newnam)
    end
    
elseif strcmp(arg,'update_info')
    XID.counters(5)=1;
    h=get(gcf,'userdata');
    handles=get(h(4),'userdata');
    usd=get(h(3),'UserData');
    flag=0;
    hand = get(h(4),'userdata');
    objhand = hand(1);
    dat = get(objhand,'UserData');
    
    newstr=get(h(1),'string');
    first_row=get(h(2),'userdata');
    begstr=get(h(1),'userdata');
    if first_row>1
        begstr=begstr(1:first_row-1,:);
        sl=str2mat(begstr,newstr);
    else
        sl=newstr; 
    end
    dat = iduiinfo('set',dat,sl);
    set(objhand,'UserData',dat);
    set(h(1),'UserData',sl);
    minslide=min(-2,-size(sl,1));
    set(h(2),'max',-1,'min',minslide,'userdata',1,'value',-1);  
    
elseif strcmp(arg,'update_color');
    XID.counters(5)=1;
    err=0;
    try
        col=eval(get(iduigco,'string'));
    catch
        err=1;
    end
    obj=get(iduigco,'userdata');   % The handle to the icon line
    axh=get(obj,'parent');     % The handle of the icon axes
    lines=get(get(obj,'parent'),'userdata');
    try
        set(idnonzer([obj;lines(:)]),'color',col);
    catch
        err=1;
    end
    if err
        errordlg(['Invalid color specification.',...
                '\nPlease enter either a color name within quotes (e.g. ''y'') ',...
                'or an RGB triple within brackets (e.g. [0.3 0.6 0.7]).'],...
            'Error Dialog','modal');
        return
    end
    if strcmp(get(axh,'tag'),get(get(XID.hw(3,1),'zlabel'),'userdata'))
        % then we are changing the color of the working data
        set(findobj(XID.hw(3,1),'tag','selline'),'color',col)
        for kn=[14,15]
            hw14=iduiwok(kn);
            if ~isempty(hw14)
                xax=get(hw14,'userdata');
                hl1=get(xax(3,1),'userdata');set(hl1(5,1),'color',col);
                hl1=get(xax(4,1),'userdata');set(hl1(5,1),'color',col);
            end % isempty hw14
        end  % for kn
    end   % if strcmp
    
    %% Check to see if a valid ltiviewer is stored in the ident GUI.
    try 
        kk = XID.ltiview;
        if ~isa(kk,'viewgui.ltiviewer');
            kk =[];
        end
    catch
        kk= [];
    end
    
    %% If the ltiview has been created and is valid, update the color of the 
    %% system that has been modified.  
    if ishandle(kk)
        oldnames = get(kk.Systems,'Name');
        dat_n = get(findobj(axh,'tag','name'),'string');
        nrdup = strmatch(dat_n,oldnames,'exact');
        %% Update the color of the system that has been modified.
        if ~isempty(nrdup)
            kk.setstyle(kk.Systems(nrdup),'Color',col,'LineStyle','-','Marker','none'); 
        end
    end
elseif strcmp(arg,'clwin')
    if any(wi_no==[1 2 3 4 5 6 7 13,40])
        eval('set(XID.plotw(wi_no,2),''value'',0);','');
    end
    
    delete(XID.plotw(wi_no,1))
end % elseif
try
    set(Xsum,'Userdata',XID);
catch
end


