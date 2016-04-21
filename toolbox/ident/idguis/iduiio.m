function goto_ws=iduiio(arg,arg2,arg3,onoff)
%IDUIIO Handles estimation of parametric models in input-output form.
%   Arguments:
%   open      Creates the model structure editor for this case
%   orders    Adjusts the information after that a change in the
%             order popups has been made
%   ordedit   Adjusts the popups after a change in the chosen
%             model structure has been made
%   mname     Puts a default model name in the corresponding box
%   estimate  Effectuates the actual estimation
%   close     Closes the dialog box

%   L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.25.4.2 $ $Date: 2004/04/10 23:19:45 $

set(0,'Showhiddenhandles','on');
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
e=iduigetd('e');ts=pvget(e,'Ts');if iscell(ts),ts=ts{1};end

warflag = strcmp(get(XID.warning,'checked'),'on');

usd=get(XID.hw(3,1),'userdata');

nu=usd.nu;ny=usd.ny;
nustr=usd.unames;
nystr=usd.ynames;
if nargin<2,update=1;else update=0;end
if strcmp(arg,'open')
    iduistat('Adjusting the Orders Editor ...')
    
    if nargin<4,
        ll1=iduiwok(20);onoff='off';
        if ishandle(ll1),onoff=get(ll1,'vis');end
    end
    FigName=idlaytab('figname',21);
    [fl,fi]=figflag(FigName,1);oldpos=[50 200];
    if fl
        nn=get(fi,'userdata');oldpos=get(fi,'pos');
        %close(fi)
        if any([nn.ny,nn.nu]~=[ny nu])|nn.ts~=usd.ts
            close(fi)
        else
            for kk= 1:length(nn.unames)
                if isempty(find(strcmp(nn.unames{kk},usd.unames)))
                    close(fi)
                end
            end
        end
    end
    if ~figflag(FigName,0)
        iduistat('Opening the Orders Editor ...')
        layout
        butw=0.75*mStdButtonWidth;
        
        PW = iduilay2(3*0.75+1.1); 
        pos = iduilay1(PW,2);
        if ny>1|nu>4,nmu=min(1,nu);else nmu=nu;end
        Lay2Pos = iduilay1(PW,2,nmu+4);
        
        figpos = [oldpos(1:2) PW pos(1,2)+pos(1,4)+Lay2Pos(1,2)+Lay2Pos(1,4)];
        f = figure('tag','sitb21','NumberTitle','off','Name',FigName,...
            'HandleVisibility','callback','vis','off',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),...
            'Menubar','none','Integerhandle','off',...
            'Position',figpos,...
            'DockControls','off',...
            'userdata',usd);
        XID.mse(2) = f;
        s1='iduipoin(1);';s2='iduipoin(1);iduistat(''Compiling ...'');';
        s3='iduipoin(3);';
        
        % ******************
        % LEVEL 1
        
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'pos',pos(2,:),'string','Close',...
            'style','push',...
            'callback','iduiio(''close'')');
        uicontrol(f,'pos',pos(3,:),'string','Help','style','push',...
            'callback',...
            'iduihelp(''iduiarx.hlp'',''Help: The ARX structure'');');
        
        
        % ****************
        % LEVEL 2
        
        lev2 = pos(1,2)+pos(1,4);
        pos=iduilay1(PW,4*(nmu+3),nmu+3,lev2,[],[1.1 0.75 0.75 0.75]);
        
        
        uicontrol(f,'Style','frame','Position', ...
            [pos(1,1:2) figpos(3)-2*mEdgeToFrame figpos(4)-pos(1,2)-mEdgeToFrame])
        kbas=4*(nmu+1)+4;
        %        XID.ss(1,6)=uicontrol(f,'pos',pos(kbas+3,:)+[0 0 2*butw 0],...
        %            'style','text','string','Use 
        %           'vis','off','style','popup','string',...
        %           'K=0 (Output Error)| Estimate K','userdata',[],'value',2,'enable','off');
        XID.io(1,6)=uicontrol(f,'pos',pos(kbas+3,:)); %nd
        XID.io(1,5)=uicontrol(f,'pos',pos(kbas+4,:)); %nc
        XID.ss(1,6)=uicontrol(f,'pos',[pos(kbas+2,:)],...
            'style','text','string','Noise input',...
            'Horizontalalignment','left');
        
        %*****************
        
        %LEVEL 3: ALL THE INPUTS
        kbas=4;
        XID.ss(1,7)=uicontrol(f,'pos',pos(3+kbas,:)+[butw 0 butw 0],...
            'style','edit','vis','off','tooltip',...
            'Model horizon(s) (N4Horizon). Leave empty for default',...
            'backgroundcolor','w','string','');
        XID.ss(3,7)=uicontrol(f,'pos',pos(3+kbas,:),...  
            'style','pop','vis','on','string',...
            'Auto|MOESP|CVA',...
            'backgroundcolor','white',...	    
            'Tooltip','The weighting used (N4Weight)');
        
        XID.ss(2,7)=uicontrol(f,'pos',pos(2+kbas,:),...
            'style','text','vis','off','string',...
            'N4sid Options','Horizontalalignment','left');
        if nu>0
            if ts>0
                tt = 'Row vector NK. NK(ku) is the delay from input # ku.';
            else
                tt =['Row vector NK of zeros or ones. NK(ku)=0 means that there is a',...
                        ' direct term (relative degree 0) from input # ku.'];
            end
            XID.ss(1,8)=uicontrol(f,'pos',pos(7+kbas,:)+[0 0 2*butw 0],...
                'style','edit','vis','off','Horizontalalignment','left',...
                'backgroundcolor','w',...
                'Tooltip',tt,...
                'Callback','iduiio(''nkupdate'')');
            if ts>0
                str = 'Delay from u';
            else
                str = 'Relative degree';
            end
            XID.ss(2,8)=uicontrol(f,'pos',pos(6+kbas,:),...
                'style','text','vis','off','string',...
                str,'Horizontalalignment','left');
            for kk=1:nmu
                XID.io(kk,2)=uicontrol(f,'pos',pos(kbas+3+4*kk,:)); %nf
                XID.io(kk,1)=uicontrol(f,'pos',pos(kbas+4+4*kk,:)); %nb
                if ts>0
                    XID.io(kk,3)=uicontrol(f,'pos',pos(kbas+5+4*kk,:)); %nk
                end
                if nu>4|ny>1
                    str='All Inputs';
                else
                    str=['From ',nustr{kk}];
                end
                XID.io(kk,7)=uicontrol(f,'pos',pos(kbas+2+4*kk,:),'style',...
                    'text','string',str,'Horizontalalignment','left');
            end %for kk=
            XID.io(nmu+1,1)=uicontrol(f,'pos',pos(kbas+3,:),'style','text',...
                'string','Poles','Horizontalalignment','left');
            XID.io(nmu+1,2)=uicontrol(f,'pos',pos(kbas+4,:),'style','text',...
                'string','Zeros+1','Horizontalalignment','left');
            if ts>0
                XID.io(nmu+1,3)=uicontrol(f,'pos',pos(kbas+5,:),'style','text',...
                    'string','Delay','Horizontalalignment','left');
            end
            %          if nu>4|ny>1,str='';else str='Inputs';end
            str = '';
            XID.io(nmu+1,7)=uicontrol(f,'pos',pos(kbas+2,:),'style','text',...
                'string',str,'Horizontalalignment','left');
        end % if nu>0
        
        % *******************
        % LEVEL 4
        
        XID.parest(12)=uicontrol(f,'pos',pos(2,:),...
            'style','text','string','Common poles:',...
            'Horizontalalignment','left');
        XID.io(1,4)=uicontrol(f,'pos',pos(3,:)); %na
        
        % LEVEL 5
        
        lev5 = pos(1,2)+pos(1,4);
        % Make the text uicontrol which holds the equation
        XID.parest(15)=uicontrol(f,'pos',[pos(2,1) lev5 PW-2*pos(2,1) pos(2,4)],...
            'style','text','userdata',0);
        s4=[s1,'idparest(''orders'');',s3];
        s5=[s1,'iduiio(''orders'');',s3];
        set(XID.io([1:nmu],[1]),'style','popup',...
            'backgroundcolor','white',...	    
            'callback',s4,'value',2);
        if ts>0
            set(XID.io([1:nmu],[3]),'style','popup',...
                'backgroundcolor','white',...	    
                'callback',s4,'value',2);
        end
        set(XID.io([1:nmu],[2]),'style','popup','string',...
            'nf=0|nf=1|nf=2|nf=3|nf=4|nf=5|nf=6|nf=7|nf=8|nf=9|nf>9',...
            'backgroundcolor','white',...	    
            'callback',s5);
        set(XID.io(1,4),'style','popup',...
            'backgroundcolor','white',...	    
            'callback',s4);
        set(XID.io(1,5),'style','popup',...
            'backgroundcolor','white',...	    
            'string',...
            'nc=0|nc=1|nc=2|nc=3|nc=4|nc=5|nc=6|nc=7|nc=8|nc=9|nc>9',...
            'callback',s5);
        set(XID.io(1,6),'style','popup',...
            'backgroundcolor','white',...	    
            'string',...
            'nd=0|nd=1|nd=2|nd=3|nd=4|nd=5|nd=6|nd=7|nd=8|nd=9|nd>9',...
            'callback',s5);
        set(get(f,'children'),'units','normal')
        if length(XID.layout)>20,
            if XID.layout(21,3)
                try
                    set(f,'pos',XID.layout(21,1:4))
                end
            end,
        end
        set(Xsum,'user',XID);
        
    end
    Mtype=get(XID.parest(4),'value');
    iduims('setpop',Mtype,nu,ny);
    set(XID.parest(15),'string',get(XID.parest(10),'string'));
    idparest('ordedit');
    set(XID.mse(2),'vis',onoff)
    iduistat('')
    
elseif strcmp(arg,'orders')
    if nu>4,nmu=min(1,nu);else nmu=nu;end
    na=get(XID.io(1,4),'value')-1;
    if na==10,na=get(XID.io(1,4),'UserData');if isempty(na),na=10;end,end
    nc=get(XID.io(1,5),'value')-1;
    if nc==10,nc=get(XID.io(1,5),'UserData');if isempty(nc),nc=10;end,end
    nd=get(XID.io(1,6),'value')-1;
    if nd==10,nd=get(XID.io(1,6),'UserData');if isempty(nd),nd=10;end,end
    
    for ku=1:nmu
        nb=get(XID.io(ku,1),'value')-1;
        if nb==10,nb=get(XID.io(ku,1),'UserData');if isempty(nb),nb=10;end,end
        if ts>0,
            nk=get(XID.io(ku,3),'value')-1;
            if nk==10,nk=get(XID.io(ku,3),'UserData');if isempty(nk),nk=10;end,end
        else
            nk = 0;
        end
        nf=get(XID.io(ku,2),'value')-1;
        if nf==10,nf=get(XID.io(ku,2),'UserData');if isempty(nf),nf=10;end,end
        nbv(ku)=nb;
        if ts>0,nkv(ku)=nk;end
        nfv(ku)=nf;
    end
    if nu>4,nbv=nb*ones(1,nu);nkv=nk*ones(1,nu);nfv=nf*ones(1,nu);end
    
    if nu>1
        nbstr='[';nfstr='[';nkstr='[';
        for ku=1:nu
            nbstr=[nbstr,int2str(nbv(ku))];if ku~=nu,nbstr=[nbstr,' '];end
            nfstr=[nfstr,int2str(nfv(ku))];if ku~=nu,nfstr=[nfstr,' '];end
            if ts>0 nkstr=[nkstr,int2str(nkv(ku))];if ku~=nu,nkstr=[nkstr,' '];end,end
        end
        nbstr=[nbstr,']'];
        nkstr=[nkstr,']'];
        nfstr=[nfstr,']'];
    elseif nu==1
        nbstr=int2str(nbv(1));
        if ts>0,nkstr=int2str(nkv(1));end
        nfstr=int2str(nfv(1));
    else
        nbstr=[];nkstr=[];nfstr=[];
    end
    Mtype=get(XID.parest(4),'value');
    str=' ';
    if any(Mtype==[1 2])
        str=[str,int2str(na),' '];
    end
    if any(Mtype==[1 2 3 4])&nu>0
        str=[str,nbstr,' '];
    end
    if any(Mtype==[2 4])
        str=[str,int2str(nc),' '];
    end
    if any(Mtype==[4])
        str=[str,int2str(nd),' '];
    end
    if any(Mtype==[3 4])
        str=[str,nfstr,' '];
    end
    if any(Mtype==[1 2 3 4])&nu>0&ts>0
        str=[str,nkstr];
    end
    set(XID.parest(3),'string',str)
    iduiio('mname');
elseif strcmp(arg,'ordedit')
    if nu>4, nmu = 1;else nmu = nu;end
    stopp=0;
    Mtype=get(XID.parest(4),'value');
    if Mtype==5,
        set(0,'Showhiddenhandles','off');
        return
    end % LL%
    sl1=get(XID.parest(3),'string');
    if any(sl1==':')&any(Mtype==[2 3 4])
        errordlg('Multiple model estimation is not supported for this model structure.','Error Dialog','modal');
        set(0,'Showhiddenhandles','off');
        return
    end
    try
        nn=eval(['[',sl1,']']);
    catch
        stopp=1;
    end
    if stopp,
        iduiio('mname');
        set(0,'Showhiddenhandles','off');
        return
    end
    if ts == 0 oelen=2*nu;else oelen=3*nu;end
    corleng=[2*nu+1 2*nu+2 oelen 3*nu+2 0 length(nn)];
    if length(nn)~=corleng(Mtype),
        errordlg('Incorrect number of orders specified.','Error Dialog','modal');
        set(0,'Showhiddenhandles','off');
        return
    end
    na=[];nb=[];nc=[];nd=[];nf=[];nk=[];
    if Mtype==1,
        na=nn(1);nb=nn(2:nu+1);
        if ts>0,nk=nn(nu+2:2*nu+1);end
    elseif Mtype==2, 
        na=nn(1);nb=nn(2:nu+1);nc=nn(nu+2);nk=nn(nu+3:2*nu+2);
    elseif Mtype==3,
        nb=nn(1:nu);nf=nn(nu+1:2*nu);
        if ts>0,nk=nn(2*nu+1:3*nu);end
    elseif Mtype==4, 
        nb=nn(1:nu);nc=nn(nu+1);nd=nn(nu+2);...
            nf=nn(nu+3:2*nu+2);nk=nn(2*nu+3:3*nu+2);
    end
    
    if ~isempty(na),set(XID.io(1,4),'value',min(na+1,11),'UserData',na);end
    if ~isempty(nc),set(XID.io(1,5),'value',min(nc+1,11),'UserData',nc);end
    if ~isempty(nd),set(XID.io(1,6),'value',min(nd+1,11),'UserData',nd);end
    for ku=1:nmu
        if ts>0
            set(XID.io(ku,3),'value',min(nk(ku)+1,11),'UserData',nk(ku));
            %else
            %set(XID.io(ku,3),'enable','off');
        end
        set(XID.io(ku,1),'value',min(nb(ku)+1,11),'UserData',nb(ku));
        if ~isempty(nf),
            set(XID.io(ku,2),'value',min(nf(ku)+1,11),'UserData',nf(ku));
        end
    end
    
elseif strcmp(arg,'mname')
    goto_ws=0;na=[];nb=[];nc=[];nd=[];nf=[];nk=[];
    modnam=deblank(get(XID.parest(3),'string'));
    Mtype=get(XID.parest(4),'value');
    if any(modnam==':')&any(Mtype==[2 3 4])
        errordlg('Multiple model estimation is not supported for this model structure.','Error Dialog','modal');
        goto_ws=1;
        set(0,'Showhiddenhandles','off');
        return
    end
    
    modnam=deblank(get(XID.parest(3),'string'));
    try
        nn=eval(['[',modnam,']']);
    catch
        goto_ws=1;
    end
    if goto_ws==1
        mname=modnam;
    else
        Mtype=get(XID.parest(4),'value');
        if Mtype==1,
            if nu==0 ordstr=['na=nn(1);'];
            else       ordstr=['na=nn(1);nb=nn(2);nk=nn(nu+2);'];end
        elseif Mtype==2
            if nu==0 ordstr=['na=nn(1);nc=nn(2);'];
            else ordstr=['na=nn(1);nb=nn(2);nc=nn(nu+2);nk=nn(nu+3);'];end
        elseif Mtype==3
            if ts>0
                ordstr=['nb=nn(1);nf=nn(nu+1);nk=nn(2*nu+1);'];
            else
                ordstr=['nb=nn(1);nf=nn(nu+1);'];
            end
        elseif Mtype==4
            ordstr=['nb=nn(1);nc=nn(nu+1);nd=nn(nu+2);nf=nn(nu+3);nk=nn(2*nu+3);'];
        end
        eval(ordstr,'errordlg(''Incorrect number of orders specified.'',''Error Dialog'',''modal'');');
        nastr=int2str(na);ncstr=int2str(nc);ndstr=int2str(nd);
        nkstr=int2str(nk);nfstr=int2str(nf);nbstr=int2str(nb);
        if Mtype==2
            mname=['amx',nastr,nbstr,ncstr,nkstr];
        elseif Mtype==3
            mname=['oe',nbstr,nfstr,nkstr];
        elseif Mtype==4
            mname=['bj',nbstr,ncstr,ndstr,nfstr,nkstr];
        elseif Mtype==1
            mname=['arx',nastr,nbstr,nkstr];
        end
    end
    set(XID.parest(7),'string',mname);
elseif strcmp(arg,'estimate') % Covers I/O and 'By name'
    iduistat('Estimating model by iterative search ...')
    goto_ws=0;
    %cmdstr=['if strcmp(get(XID.parest(2),''interruptible''),''On''),',...
    %       'set(XID.iter(1),''pointer'',''arrow'');',...
    %      'end,set(XID.iter(7),''userdata'',0);'];
    %eval(cmdstr,'')  %Resetting the Stop-button
    Mtype=get(XID.parest(4),'value');
    if nargin>1,Mtype=6;end
    usepem=0;
    argin={};
    text =[];
    pretext = [];
    usd=get(XID.citer(1),'UserData');
    %usd = usd{2};
    slim=deblank(usd(1,:));
    lim = eval(slim);
    if ~isempty(lim) 
        argin = [argin,{'Lim'},{lim}];
        text =[text,',''Lim'',',slim];
    end
    stol=deblank(usd(2,:));tol=eval(stol);
    if ~isempty(tol)
        argin=[argin,{'Tol'},{tol}];
        text = [text,',''Tol'',',stol];
    end
    
    smaxiter=deblank(usd(3,:));maxiter=eval(smaxiter);
    if ~isempty(maxiter)
        argin =[argin,{'MaxIter'},{maxiter}];
        text =[text,',''MaxIter'',',smaxiter];
    end
    
    sindex=deblank(usd(4,:));index=eval(['[',sindex,']']);
    if ~isempty(index)
        argin=[argin,{'FixedP'},{index}];
        text = [text,',''FixedP'',',sindex];
    end
    init = get(XID.parest(17),'Value');
    if init==2
        argin = [argin,{'Init'},{'Zero'}];
        text = [text,',''Init'',''Zero'''];
    elseif init==3
        argin = [argin,{'Init'},{'Estimate'}];
        text = [text,',''Init'',''Est'''];
    elseif init==4
        argin = [argin,{'Init'},{'Back'}];
        text = [text,',''Init'',''Back'''];
    end
    try
        cov = get(XID.parest(19),'Value');
    catch
        cov = 1;
    end
    
    if cov == 2 % no covariance
        argin = [argin,{'Cov'},{'None'}];
        text = [text,'''Cov'',''None'''];
    end
    foc = get(XID.parest(18),'Value');
    %foc = get(XID.parest(18),'Value');
    if foc >1
        focstr = get(XID.parest(18),'string');
        foc = focstr{foc};foc = lower(foc(1:2));
        
        if foc == 'si'
            argin = [argin,{'Focus'},{'Sim'}];
            text = [text,',''Focus'',''Sim'''];
        elseif foc == 'st'
            argin = [argin,{'Focus'},{'Stab'}];
            text = [text,',''Focus'',''Stab'''];
        elseif foc == 'fi'
            filt = get(XID.parest(18),'userData');
            if isempty(filt)
                errordlg(['The filter has not been specified. Enter the filter information in the Estimation Focus Dialog'],...
                    'Error Dialog','modal');
                set(0,'Showhiddenhandles','off');
                return
            end
            argin = [argin,{'Focus'},filt(1)];
            pretext = '';%filt{2};
            text = [text,[',''Focus'',',filt{2}]];
        end
    end
    if ~isempty(index),usepem=1;end
    if nargin==1
        modnam=deblank(get(XID.parest(3),'string'));
        if isempty(modnam)
            errordlg('You must supply model orders or a name in the Orders: edit box.','Error Dialog','modal');
            set(0,'Showhiddenhandles','off');
            return
        end
        try
            nn=eval(['[',modnam,']']);
        catch
            goto_ws=1;
        end
        % Here we must distinguish the case when orders have been
        % given in the ws
        if goto_ws %
            sumb=findobj(get(0,'children'),'flat','tag','sitb30');
            modtag=get(XID.parest(3),'userdata');
            if isempty(modtag)
                modeln=findobj([XID.sumb(1);sumb(:)],...
                    'type','text','string',modnam);
                if ~isempty(modeln),
                    modax=get(modeln(1),'parent');
                else
                    modax=[];
                end
            else
                modax=findobj([XID.sumb(1);sumb(:)],...
                    'type','axes','tag',modtag);
            end
            if ~isempty(modax)
                modax=modax(1);
                modlin=findobj(modax,'tag','modelline');
                if ~isempty(modlin)
                    nn=iduicalc('unpack',get(modlin,'UserData'),1);
                    goto_ws=0;
                end
            end % ~isempty(modeln)
        end % if goto_ws
        if goto_ws,
            goto_ws = 0;
            try
                nn = evalin('base',modnam);
            catch
                errordlg(['The model name ',modnam,' does not exist on the model board',...
                        ' nor in the workspace.'],'Error Dialog','modal')
                set(0,'Showhiddenhandles','off');
                return
            end
        end
    else
        nn=arg2;
    end
    if any(Mtype==[2,3,4])
        if any(nn<0)
            errordlg('No order or delay can be negative.','Error Dialog','modal');
            set(0,'Showhiddenhandles','off');
            return
        end
        na=[];nb=[];nc=[];nd=[];nf=[];nk=[];
        if Mtype==2
            ordstr=['na=nn(1);nb=nn(2:nu+1);nc=nn(nu+2);nk=nn(nu+3:2*nu+2);'];
        elseif Mtype==3
            if ts>0
                ordstr=['nb=nn(1:nu);nf=nn(nu+1:2*nu);nk=nn(2*nu+1:3*nu);'];
            else
                ordstr=['nb=nn(1:nu);nf=nn(nu+1:2*nu);'];
            end
        elseif Mtype==4
            ordstr=['nb=nn(1:nu);nc=nn(nu+1);nd=nn(nu+2);nf=nn(nu+3:2*nu+2);',...
                    'nk=nn(2*nu+3:3*nu+2);'];
        end
        stopp=0;
        
        eval(ordstr,'stopp=1;')
        if stopp,
            errordlg('Incorrect number of orders specified.','Error Dialog','modal');
            set(0,'Showhiddenhandles','off');
            return
        end
        
    end %if any(Mtype ...
    if ts == 0 oelen=2*nu;else oelen=3*nu;end
    corleng=[2*nu+1 2*nu+2 oelen 3*nu+2 0 length(nn)];
    if length(nn)~=corleng(Mtype),
        errordlg('Incorrect number of orders specified.','Error Dialog','modal');
        set(0,'Showhiddenhandles','off');
        return
    end
    model=get(XID.parest(7),'string');
    [eDat,eDat_info,eDat_n]=iduigetd('e');
    TSamp = pvget(eDat,'Ts');
    if iscell(TSamp),TSamp=TSamp{1};end
    if any(Mtype==[2 3 4 5])
        if isempty(na),na=0;end
        if isempty(nc),nc=0;end
        if isempty(nd)&nu>0,nd=0;end
        if isempty(nf),nf=zeros(1,nu);end
        if ~isempty(na),nastr=int2str(na);end
        if ~isempty(nc),ncstr=int2str(nc);end
        if ~isempty(nd),ndstr=int2str(nd);end
        
        for sku=1:nu
            if sku==1,
                if ~isempty(nb),nbstr=int2str(nb(sku));end
                if ~isempty(nk),nkstr=int2str(nk(sku));end
                if ~isempty(nf),nfstr=int2str(nf(sku));end
            else
                if ~isempty(nb) nbstr=[nbstr,' ',int2str(nb(sku))];end
                if ~isempty(nk) nkstr=[nkstr,' ',int2str(nk(sku))];end
                if ~isempty(nf) nfstr=[nfstr,' ',int2str(nf(sku))];end
            end
        end
        if nu>1,
            nbstr=[' nb = [',nbstr,']'];
            if ts>0,nkstr=[' nk = [',nkstr,']'];end
            if ~isempty(nf),nfstr=[' nf = [',nfstr,']'];end
            if ~isempty(na),nastr=[' na = ',nastr];end
            if ~isempty(nc), ncstr=[' nc = ',ncstr];end
            if ~isempty(nd),ndstr=[' nd = ',ndstr];end
        end
        set(XID.iter(7),'userdata',0); %reset stop button
        if ts==0&(any(nb-nf>1))
            errordlg({'The demanded model is non-proper (numerator degree',...
                    ' larger than  denominator degree). Such modele are not',...
                    ' handled by the GUI.'})
            return
        end
        was = warning;
        lastwarn('')
        warning('off')
        try
            LASTM=pem(eDat,[na nb nc nd nf nk],argin{:});
            warmess = lasterr;
        catch
            errordlg(lasterr,'Error','Modal');
            return
        end
%         if ~isempty(lastwarn)&warflag
%             mess = '(Warning Dialogs can be turned off under the Options Menu in the main window)';
%             warndlg({lastwarn,mess},'Warning','Modal');
%         end
        warning(was)
        
        set(XID.iter(7),'userdata',LASTM,'string','Continue iter','callback',...
            'idparest(''continue'');')
    end
    if Mtype==2&~usepem  %ARMAX
        if nu==0
            ordstr=[int2str(na),int2str(nc)];ordstr2=ordstr;
        else
            ordstr=[int2str(na(1)),int2str(nb(1)),int2str(nc),...
                    int2str(nk(1))];
            ordstr2=[int2str(na),' ',int2str(nb(1)),' ',int2str(nc),...
                    ' ',int2str(nk(1))];
        end
        if nu<2
            mod_info=str2mat(eDat_info,pretext,[' ',model,' = armax(',eDat_n,',[',...
                    ordstr2,'],',text,')']);...
            else
            mod_info=str2mat(eDat_info,pretext,nastr,nbstr,ncstr,nkstr,...
                [' ',model,' = armax(',eDat_n,',[na nb nc nk],',...
                    text,')']);
        end
        
    elseif Mtype==3&~usepem   %OE
        if sum(nb)==0
            errordlg(['The OE model does not make sense',...
                    '  if all NB-orders are zero.'],'Error Dialog','modal');
            set(0,'Showhiddenhandles','off');
            return
        end
        if nu<2,
            mod_info=str2mat(eDat_info,pretext,[' ',model,' = oe(',eDat_n,',[',...
                    int2str(nb),' ',int2str(nf),' ',int2str(nk),'],',...
                    text,')']);
        else
            if ts==0,nkstr='';nk=[];end
            mod_info=str2mat(eDat_info,nbstr,nfstr,nkstr,pretext,...
                [' ',model,' = oe(',eDat_n,',[nb nf nk],',...
                    text,')']);
        end
        
    elseif Mtype==4&~usepem    %BJ
        if nu<2,
            mod_info=str2mat(eDat_info,pretext,[' ',model,' = bj(',eDat_n,',[',...
                    int2str(nb),' ',int2str(nc),' ',int2str(nd),...
                    ' ',int2str(nf),' ',int2str(nk),'],',...
                    text,')']);
        else
            mod_info=str2mat(eDat_info,pretext,nbstr,ncstr,ndstr,nfstr,nkstr,...
                [' ',model,' = bj(',eDat_n,',[nb nc nd  nf nk],',...
                    text,')']);
        end
        
    elseif usepem&Mtype~=6           % PEM
        if nu<2
            mod_info=str2mat(eDat_info,pretext,[' ',model,' = pem(',eDat_n,...
                    ',[',int2str(nn(1)),...
                    int2str(nn(2)),' ',int2str(nn(3)),' ',int2str(nn(4)),' ',...
                    int2str(nn(5)),' ',int2str(nn(6)),'],',...
                    text,')']);
        else
            mod_info=str2mat(eDat_info,pretext,nastr,nbstr,ncstr,ndstr,nfstr,...
                nkstr,[' ',model,' = pem(',eDat_n,...
                    ',[na nb nc nd nf nk],',...
                    text,')']);
        end
        
        if nargin==3,model=arg3;end
    elseif Mtype==6  % Model by name
        oldmod=nn; 
        if ~isa(nn,'idmodel')%nro<3 | nco<7
            errordlg(str2mat(['The entry in the Initial model field is ', ...
                    'not a model of IDMODEL type.'],'',['You may also have' ...
                    ' chosen an unfortunate name, coinciding with an ',...
                    'internal variable name. If so, change the model',...
                    ' name by double-clicking on its icon, and edit',...
                    ' accordingly.']),'Error Dialog','modal');
            set(0,'Showhiddenhandles','off');
            return
        end
        set(XID.iter(7),'userdata',0); %reset stop button
        lastwarn('')
        was = warning;
        warning off
        try
            LASTM=pem(eDat,oldmod,argin{:}); %6
            warmess = lastwarn;
        catch
            errordlg(lasterr,'Error Dialog','modal');
            return
        end
%         if ~isempty(lastwarn)&warflag
%             mess = '(Warning Dialogs can be turned off under the Options Menu in the main window)';
%             warndlg({lastwarn,mess},'Warning','modal');
%         end
        warning(was)
        set(XID.iter(7),'userdata',LASTM,'string','Continue iter','callback',...
            'idparest(''continue'');')
        model_old=deblank(get(XID.parest(3),'string'));
        
        if nargin>2
            mod_info=arg3;firstrow=2;
        else
            mod_info=eDat_info;firstrow=1;
        end
        [rmi,cmi]=size(mod_info);
        mod_info=str2mat(mod_info(firstrow:rmi,:),...
            [model,' = pem(',eDat_n,',',model_old,',',...
                text,')']);
    end %  if Mtype
     if ~isempty(warmess)
         mod_info = str2mat(mod_info,['Warning: ',warmess]);
     end
    mod_nam=model;
    mod_nam=mod_nam(find(mod_nam~=' '));
    LASTM =pvset(LASTM,'Name',mod_nam);
    LASTM = iduiinfo('set',LASTM,mod_info);
    iduiinsm(LASTM);
    idgwarn(warmess);
    XID = get(Xsum,'UserData');
    
elseif strcmp(arg,'close')
    set(XID.mse(2),'Visible','off')
    set(XID.parest(15),'userdata',0);
    
elseif strcmp(arg,'nkupdate')
    sl1 = get(XID.parest(3),'string');
    snk = get(XID.ss(1,8),'string');
    try
        nk = eval(['[',snk,']']);
    catch
        errordlg('The Delay from u cannot be evluated. Please check entry.','Error Dialog','modal')
    end
    usd = get(XID.parest(1),'Userdata');
    nu = usd(1);
    testnk = 0;
    if ~isa(nk,'double')
        testnk = 1;
        
    elseif length(nk)~=nu
        testnk = 1;
    else
        for ku = 1:nu
            if floor(nk(ku))~=nk(ku)
                testnk = 1;
            end
        end
        if any(nk<0)
            testnk = 1;
        end
    end
    if testnk
        errordlg(['The delays from the input must be a row vector of non-negative ',...
                'integers. The length must equal the number of inputs.'],'Error Dialog','modal');
        return
    end
    pnr1 = find(snk=='[');
    if ~isempty(pnr1)
        pnr2 = find(snk==']');
        if isempty(pnr2)
            pnr2= length(snk)+1;
        end
        
        snk = snk(pnr1+1:pnr2-1);
    end
    pnr1 = find(sl1=='[');
    if ~isempty(pnr1)
        pnr2 = find(sl1==']');
        if isempty(pnr2)
            sl1 = [sl1(1:pnr1-1),' [',snk,']'];
        else
            sl1 = [sl1(1:pnr1),snk,sl1(pnr2:end)];
        end
    else
        sl1 = [sl1,' [',snk,']'];
    end
    set(XID.parest(3),'string',sl1);
    
end

set(0,'Showhiddenhandles','off');
%set(Xsum,'UserData',XID);
