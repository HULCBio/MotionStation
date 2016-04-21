function gtws=idparest(arg,onoff,enforce)
%IDPAREST  The basic callback function for parametric estimation.
%   Arguments:
%   open   Creates the dialog box for parametric estimation
%   mstype Creates the correct dialog box for model structure editor
%   mspop  Sets the correct pop-up menu for the various  supported
%              model structures. (This depends on the inputs and outputs
%          in the estimation data.)

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.22.4.1 $ $Date: 2004/04/10 23:19:30 $

set(0,'Showhiddenhandles','on');
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
if nargin<2,onoff='on';end

gtws=[];
if strcmp(arg,'close')
    set(XID.parest(1),'Visible','off')
    try
        set(iduiwok(21),'vis','off');
    end
    try
        set(iduiwok(22),'vis','off');
    end
    set(0,'Showhiddenhandles','off');
    set(Xsum,'Userdata',XID);
    return
end
usd=get(XID.hw(3,1),'userdata');
nu=usd.nu;ny=usd.ny;dom =usd.dom;

if strcmp(arg,'open')
    if nargin<2,onoff='on';end
    FigName=idlaytab('figname',20);
    if ~figflag(FigName,0)
        iduistat('Opening the Parametric Models dialog ...')
        if ~exist('XID.mse'), XID.mse=[0 0 0 0];end
        
        layout
        butw = mStdButtonWidth;
        FigW = iduilay2(3);
        f = figure('NumberTitle','off','Name',FigName,...
            'userdata',[nu ny],'tag','sitb20','Integerhandle','off',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),'vis','off');
        XID.parest(1) = f;
        set(f,'Menubar','none','HandleVisibility','callback');
        s1='iduipoin(1);';s2='iduipoin(1);iduistat(''Compiling ...'');';
        s3='iduipoin(2);';
        % ******************
        % LEVEL 1
        pos = iduilay1(FigW,3); 
        uicontrol(f,'pos',pos(1,:),'style','frame');
        cb=[s2,'goto_ws=iduiarx(''estimate'');',...
                'if goto_ws,XIDarg=''arx'';idgtws;end,',s3];
        XID.parest(2)=uicontrol(f,'pos',pos(2,:),'string',...
            'Estimate','style','push','callback',cb,'Interruptible','on','tooltip',...
            'Press to estimate the model in the currently defined structure.');
        %set(XID.parest(2),'UserData',str2mat('[]','[]','[]','[]'))
        uicontrol(f,'pos',pos(3,:),'string','Close',...
            'style','push','callback',[s1,'idparest(''close'');',s3]);
        uicontrol(f,'pos',pos(4,:),'string','Help','style',...
            'push','callback',...
            'iduihelp(''idparest.hlp'',''Help: Estimating Models'');');
        
        
        %  LEVEL 2
        lev2 = pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,2,1,lev2,[],1.5);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        XID.parest(5)=uicontrol(f,'pos',pos(2,:),...
            'style','push','string','Iteration control...','enable','off',...
            'callback',[s1,'iduiiter(''open'');',s3]);
        XID.parest(6)=uicontrol(f,'pos',pos(3,:),...
            'style','push','string','Order Editor...',...
            'callback',[s1,'idparest(''mse'');',s3],'tooltip',...
            'Open a dialog that helps setting the model orders and options.');
        % LEVEL 2.5 Iter info
        lev25 = pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,6,2,lev25,[],[0.6 1 1.4]);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        %uicontrol(f,'pos',pos(2,:),'style','text','string','Iter:');
        XID.iter(4) = uicontrol(f,'pos',pos(2,:)+[-5 0 10 0],'style','text','string','Iteration');
        %uicontrol('pos',pos(4,:),'style','text','string','Fit:');
        XID.iter(5) = uicontrol(f,'pos',pos(3,:),'style','text','string','Fit: ',...
            'tooltip','Loss function at the current iteration');
        %uicontrol('pos',pos(6,:),'style','text','string','Improv (%):');
        XID.iter(6) = uicontrol(f,'pos',pos(4,:),'style','text','string','Improvement',...
            'tooltip','Improvement in fit from previous iteration.');
        XID.iter(2) = uicontrol(f,'pos',pos(6,:),'style','check','string',...
            'Trace','callback','drawnow',...
            'tooltip','Check to give full details of iterations to command window.');
        XID.iter(7) = uicontrol(f,'pos',pos(7,:),'style','push','string',...
            'Stop Iterations','callback','idparest(''stop'');','tooltip',...
            'Stop iterations and save result after the current iteration.');
        
        % LEVEL 3
        lev3 = pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,8,2,lev3,[],[0.6 0.9 0.6 0.9]);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'pos',pos(8,:),'style','text',...
            'string','Covariance:','HorizontalAlignment','left',...
            'tooltip',...
            'Should the covariance matrix of the parameters be estimated or not?');%cov
        XID.parest(19) = uicontrol(f,'pos',pos(9,:),'style','pop',...
            'backgroundcolor','white',...
            'string','Estimate|None');
        
        uicontrol(f,'pos',pos(4,:)+[0 0 20 0],'style','text',...
            'string','Initial state:','HorizontalAlignment','left',...
            'tooltip','Options for the model''s initial state.');
        XID.parest(17) = uicontrol(f,'pos',pos(5,:),'style','pop',...
            'backgroundcolor','white',...
            'tooltip',...
            'Fix it to zero, Estimate it, or Backcast it. Auto: Let the data decide.',...
            'string','Auto|Zero|Estimate|Backcast');
        uicontrol(f,'pos',pos(2,:),'style','text',...
            'string','Focus:','HorizontalAlignment','left',...
            'tooltip',...
            'Over which frequency range should the model fit be focused?');
        XID.parest(18) = uicontrol(f,'pos',pos(3,:),'style','pop',...
            'backgroundcolor','white',...
            'string','Prediction|Simulation|Filter|Stability','callback',...
            [s1,'idparest(''filter'');',s3],...
            'tooltip',['Predition/Simulation: Optimize the fit for prediction or simulation.',...
                ' Stability: Guarantee stability. Filter: Choose a frequency range.']);
        uicontrol(f,'pos',pos(6,:),'style','text',...
            'string','Dist.model:','HorizontalAlignment','left',...
            'Tooltip','A possible additive disturbance model H as in y = Gu + He.');
        XID.parest(20) = uicontrol(f,'pos',pos(7,:),'style','pop',...
            'backgroundcolor','white',...
            'string','Estimate|None','callback','idparest(''setfocus'');');
        % LEVEL 4
        lev4 = pos(1,2)+pos(1,4);
        
        pos = iduilay1(FigW,10,5,lev4,[],[1 2.2]);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        
        uicontrol(f,'pos',pos(8,:),...
            'string','Method:','style','text',...
            'HorizontalAlignment','left');
        posmeth1=pos(9,:)+[0 0 -1.1*mStdButtonWidth 0];
        posmeth1 = posmeth1 + [0 0 -mEdgeToFrame 0];
        posmeth2=pos(9,:)+[1.1 0 -1.1 0]*mStdButtonWidth;
        posmeth2 = posmeth2 + [mEdgeToFrame 0 -mEdgeToFrame 0];
        XID.arx(1,2)=uicontrol(f,'pos',posmeth1,'string','ARX',...
            'callback',[s1,'iduiarx(''arx'');idparest(''mstype'');',s3],...
            'style','radio');
        XID.arx(1,5)=uicontrol(f,'pos',posmeth2,'string','IV',...
            'callback',[s1,'iduiarx(''iv'');idparest(''mstype'');',s3],...
            'style','radio');
        XID.ss(1,2)=uicontrol(f,'pos',posmeth1,'string','PEM',...
            'callback',[s1,'iduiss(''pem'');idparest(''mstype'');',s3],...
            'style','radio','vis','off');
        XID.ss(1,5)=uicontrol(f,'pos',posmeth2,'string','N4SID',...
            'callback',[s1,'iduiss(''ssss'');idparest(''mstype'');',s3],...
            'style','radio','vis','off');
        XID.parest(11)=uicontrol(f,'pos',pos(9,:),...
            'style','text','string','Prediction error method',...
            'vis','off','HorizontalAlignment','left');
        set(XID.arx(1,2),'value',1);set(XID.ss(1,5),'value',1);
        
        % ******************************
        % LEVEL 4
        
        uicontrol(f,'pos',pos(6,:),'style','text',...
            'HorizontalAlignment','left','string','Equation:');
        XID.parest(10)=uicontrol(f,'pos',pos(7,:),'style','text',...
            'HorizontalAlignment','left','string','x');
        XID.parest(4)=uicontrol(f,'pos',pos(3,:),'style','popup',...
            'backgroundcolor','white',...
            'callback',[s1,'idparest(''mstype'',''off'');',s3],'value',1,...
            'string','x|x|x|x|x|x');
        XID.parest(3)=uicontrol(f,'pos',pos(5,:),...
            'style','edit','callback',[s1,'idparest(''ordedit'');',s3],...
            'HorizontalAlignment','left',...
            'backgroundcolor','white','tag','modst');
        XID.parest(9)=uicontrol(f,'pos',pos(2,:),...
            'HorizontalAlignment','left',...
            'string','Structure:','style','text','tooltip',...
            'Choose the model structure');
        uicontrol(f,'pos',pos(10,:),...
            'HorizontalAlignment','left',...
            'string','Name:','style','text','tooltip',...
            'The Model name, that will identify the model in GUI.');
        XID.parest(16)=uicontrol(f,'pos',pos(4,:),...
            'HorizontalAlignment','left',...
            'string','Orders:','style','text','tooltip',...
            'Enter the model orders that define the model structure. These are context dependent.');
        XID.parest(7)=uicontrol(f,'pos',pos(11,:),...
            'style','edit','string','arx441',...
            'HorizontalAlignment','left',...
            'backgroundcolor','white','tooltip',...
            'A default name will be suggested. If desired, enter another name before pressing ''Estimate''.');
        
        FigH=pos(1,2)+pos(1,4)+mEdgeToFrame;
        FigWH=[FigW,FigH];
        sumbpos=get(XID.sumb(1),'pos');
        FigXY=max([sumbpos(1) sumbpos(2)-FigH],[0 50]);
        set(f,'pos',[FigXY FigWH]);
        set(get(f,'children'),'units','normal')
        if length(XID.layout)>19,
            if XID.layout(20,3)
                try
                    set(f,'pos',XID.layout(20,1:4));
                end
            end,
        end
        set(f,'vis',onoff)
        set(Xsum,'UserData',XID);
        
        idparest('setpop');
        %idparest('mse');
        idparest('mstype','off');
        %idparest('ordedit');
        if nu==0
            set(XID.parest(18),'enable','off','value',1)
        else
            set(XID.parest(18),'enable','on')
        end
    end % if figflag
    nn=get(XID.parest(1),'userdata');
    %if ~all(nn==[nu ny])
    set(XID.parest(1),'userdata',[nu ny])
    [flag,hnr]=figflag(idlaytab('figname',21),1);
    if flag
        viss=get(hnr,'vis');set(hnr,'vis','off');
    else
        viss='off';
    end
    idparest('setpop');
    idparest('mstype','off');
    if nu==0
        set(XID.parest(18),'enable','off','value',1)
    else
        set(XID.parest(18),'enable','on')
    end
    
    if strcmp(viss,'on'),idparest('mse');XID=get(Xsum,'UserData');end
    %end
    iduistat('Choose model Structure and Orders and then press the Estimate button.')
    % ************************
elseif strcmp(arg,'stop')
    set(XID.iter(7),'userdata',1);
elseif strcmp(arg,'continue')
    mod = get(XID.iter(7),'userdata');
    set(XID.iter(7),'string','Stop Iterations','callback','idparest(''stop'');',...
        'userdata',0);drawnow
    edat = iduigetd('e','me');
    modcn = [get(XID.parest(7),'string'),'c'];
    set(XID.parest(7),'string',modcn)
    modc = pem(edat,mod);
    set(XID.iter(7),'userdata',modc,'string','Continue iter','callback',...
        'idparest(''continue'');','tooltip',...
        'Continue iterative estimation from the current model.')
    modc = pvset(modc,'Name',modcn);
    iduiinsm(modc);
elseif strcmp(arg,'mstype')
    edat = iduigetd('e','me');
    dom = pvget(edat,'Domain');
    Ts = pvget(edat,'Ts');Ts = Ts{1};
    Mtype=get(XID.parest(4),'value');
    newMtype = 1;
    err=0;
    dom = lower(dom(1));
    if dom=='f'
        if any(Mtype==[2 4]),err = 1;text='frequency domain data.';end
        if Mtype==1&Ts==0&ny>1,err = 1;newMtype=5;text='continuous time, multi-output data.';end
    end
    if ny>1
        if any(Mtype==[2 3 4]), err=1;text='multi-output systems.';end
    end
    if nu==0
        if any(Mtype==[3 4]),err=1;text='time-series data (no input).';end
    end
    if err,
        mse=0;%oldMtype=1;
        ll1=iduiwok(21);if ishandle(ll1),if strcmp(get(ll1,'vis'),'on')
                mse=1;
            end,end
        if mse,
            oldMtype=get(XID.parest(15),'userdata');
            if oldMtype>0;newMtype=oldMtype;end
        end
        
        errordlg(['This Model Structure is not supported for ' text]...
            ,'Error Dialog','modal');
        set(XID.parest(4),'value',newMtype)
        set(0,'Showhiddenhandles','off');
        set(Xsum,'Userdata',XID); 
        return
    end
    %set disturbance Model popup
    if Mtype==3 %oe
        set(XID.parest(20),'style','text','string','None','tooltip',...
            'OE models use no disturbance model.','backgroundcolor',...
            get(0,'DefaultUIcontrolBackgroundColor'),'horizontalalignment','left');
        
    elseif Mtype == 5&dom=='f'%SS
        set(XID.parest(20),'style','text','string','Fix K = 0','tooltip',...
            'SS models use no disturbance model for frequency domain data.','backgroundcolor',...
            get(0,'DefaultUIcontrolBackgroundColor'),'horizontalalignment','left');
    elseif Mtype == 5
        set(XID.parest(20),'style','pop','string',{'Fix K = 0','Estimate K'},...
            'backgroundcolor','white','tooltip',['Include the matrix K to estimate a ',...
                'disturbance model. Fix K to zero otherwise.'],'value',2);
    else
        set(XID.parest(20),'style','text','string','Estimate','tooltip',...
            'ARX, ARMAX and BJ models estimate a disturbance model.',...
            'backgroundcolor',...
            get(0,'DefaultUIcontrolBackgroundColor'),'horizontalalignment','left');
    end
    
    idparest('setfocus');
    if (Mtype==1&ny==1&get(XID.arx(1,2),'value'))|... %%%
            (Mtype==5&get(XID.ss(1,5),'value'))               %%%
        % These are the cases for order select      %%%
        set(XID.parest(5),'string','Order Selection','enable','on',... %%%
            'callback','idparest(''ord_sel'');','tooltip',...
            ['Set ranges of orders in the ''Orders'' box. All these orders will be',...
                ' tested when you press ''Estimate''.',...
                'The ranges in the ''Orders'' box can be changed at will.'])          %%%
        onoffiter='off';
        set(XID.iter([2 4 5 6 7]),'enable','off')
    else                                                %%%
        set(XID.parest(5),'string','Iteration Options...',...  %%%
            'callback',['iduiopt(''dlg_ioopt'',''ioopt'',1,1:4);'],'tooltip',...
            ['Open a dialog to set optional values of parameters ',...
                'for the iterative search for an estimate.']) %%%
        
        set(XID.iter([2 4 5 6 7]),'enable','on')
        
        onoffiter='on';itval=1;
        if Mtype==1,onoffiter='off';itval=0;end
        if Mtype==5&get(XID.ss(1,5),'value'),onoffiter='off';itval=0;end
        set(XID.parest(5),'enable',onoffiter)
    end
    try
        if strcmp(onoffiter,'off'),
            set(iduiwok(22),'vis','off');
        end
    end
    XID = get(Xsum,'UserData');
    if strcmp(onoff,'off')
        iduims('both',Mtype,nu,ny);
        XID = get(Xsum,'UserData');
        idparest('ordedit');
    end
    % set the tooltips in the orders box:
    ss = '';
    if nu>1
        ss='s';
    end
    switch Mtype
        case 1 %ARX
            if ~(dom=='f'&Ts==0)
                if nu>0
                    tt=['Enter ',int2str(1+2*nu),' integers: 1 for na (# of poles) and ',...
                            int2str(nu),' for each of nb and nk (# of numerator',...
                            ' coefficients and delays).'];
                else
                    tt = ['Enter one integer na for the order of the AR-model.'];
                end
            else
                tt=['Enter ',int2str(1+nu),' integers: 1 for na (# of poles) and ',...
                        int2str(nu),' for nb (# of numerator',...
                        ' coefficients).'];
            end
        case 2 % ARMAX
            if nu>0
                tt=['Enter ',int2str(2+2*nu),' integers: 1 for na, ',...
                        int2str(nu),' for nb, 1 for nc and ',int2str(nu)',' for the ',...
                        'delay',ss,' nk. na, nb and nc are the orders of',...
                        ' the A, B and C polynomials.'];
            else
                tt = ['Enter 2 integers na and nc for the orders of the A and C polynomials.'];
            end
        case 3 %OE  
            if ~(dom=='f'&Ts==0)
                if nu>1
                    tt=['Enter ',int2str(3*nu),' integers: ',int2str(nu),' for each of, ',...
                            ' nb, nf and the delays nk.',...
                            ' nb and nf are the orders of the B and F polynomials, one for each input.'];
                else
                    tt = ['Enter 3 integers nb, nf and nk, giving the orders of the B and F polynomials',...
                            ' and the delay.'];
                end
            else
                tt=['Enter ',int2str(2*nu),' integers: ',int2str(nu),' for each of',...
                        ' nb, and nf.',...
                        ' nb is the number of numerator coefficients and nf the number of poles.'];
            end
        case 4 % BJ
            if nu>1
                tt = ['Enter ',int2str(2+3*nu),' integers. They are nb(',int2str(nu), ' values), nc nd ',...
                        '(both scalars) and nf(',int2str(nu),' values).'];
            else
                tt = ['Enter 5 integers: nb, nc, nd, nf, the orders of the B,C,D and F polynomials',...
                        ', and nk, the delay from input to output.'];
            end
        case 5 %SS
            tt = ['Enter one integer n, the order of the state-space model.'];
            if nu==1
                if Ts>0
                    tt=[tt,' Optionally enter an integer nk within brackets. This is',...
                            ' the delay from the input (default 1).'];
                else
                    tt=[tt,' Optionally enter an integer nk (0 or 1) within brackets. This is',...
                            ' the relative degree from the input (default 1 meaning D = 0).'];
                end
                
                
            elseif nu>1
                if Ts>0
                    tt=[tt,' Optionally enter ',int2str(nu),' integers nk within brackets. These are',...
                            ' the delays from each of the inputs (default all 1).'];
                else
                    tt=[tt,' Optionally enter ',int2str(nu),' integers nk (0 or 1) within brackets. These are',...
                            ' the relative degrees from each of the inputs (default all 1 meaning D= 0).'];
                end
            end
        case 6 %Initial
            tt=['Drag and drop a model from the GUI or enter the name of a Workspace model.'];
    end
    set(XID.parest(3),'tooltip',tt);
    
    iduistat('Select orders and press the Estimate button.')
elseif strcmp(arg,'setfocus')
    if strcmp(lower(get(XID.parest(20),'style')),'text')
        tx = lower(get(XID.parest(20),'string'));
    elseif get(XID.parest(20),'value')==2
        tx = 'es';
    else
        tx = 'no';
    end
    tx = tx(1:2);
    if tx == 'es'
        str = {'Prediction','Simulation','Stability','Filter...'};
        tt1 = ['Predition/Simulation: Optimize the fit for prediction or simulation.',...
                ' Stability: Guarantee stability. Filter: Choose a frequency range.'];
    elseif lower(dom(1))=='t'
        str = {'Simulation','Filter...'};
        tt1 = ['Simulation: The input power decides the frequency weighting.',...
                ' Filter: Choose a frequency range.'];
    else
        str = {'None','Simulation','Stability','Filter...'};
        tt1 = ['None: Unstable models allowed. Simulation/Stability:',...
                ' Stability guaranteed and the input power decides the frequency weighting.',...
                ' Filter: Choose a frequency range.'];
    end
    val = get(XID.parest(18),'value');
    if val > length(str),val = length(str); end
    set(XID.parest(18),'string',str,'tooltip',tt1,'value',val);
    
elseif strcmp(arg,'orders')
    
    if ~ishandle(iduiwok(21)),
        set(0,'Showhiddenhandles','off');
        set(Xsum,'Userdata',XID); 
        return
    end
    Mtype=get(XID.parest(4),'value');
    if Mtype==1,
        iduiarx('orders');
    elseif any(Mtype==[2 3 4]), 
        iduiio('orders');
    elseif Mtype==5, 
        iduiss('orders');
    end
    iduistat('Press Estimate to estimate model.');
elseif strcmp(arg,'ordedit')
    set(XID.iter(7),'string','Stop Iterations','callback','idparest(''stop'');',...
        'userdata',0,'tooltip','Stop and save result after the current iteration.'); % Resetting the continue button
    set(XID.iter(4),'string','Iteration')
    set(XID.iter(5),'string','Fit:')
    set(XID.iter(6),'string','Improvement')
    flag=0;
    set(XID.parest(3),'userdata',[]);
    Mtype=get(XID.parest(4),'value');
    if Mtype==1,
        flag=iduiarx('mname');
    elseif any(Mtype==[2 3 4]),
        flag=iduiio('mname');
    elseif Mtype==5,
        flag=iduiss('mname');
    elseif Mtype==6
        set(XID.parest(7),'string',[get(XID.parest(3),'string'),'c'])
    end
    if flag,
        set(0,'Showhiddenhandles','off');
        return
    end
    mse=0;
    [fl,fi]=figflag(idlaytab('figname',21),1);
    if fl,if strcmp(get(fi,'vis'),'on'),mse=1;end,end
    if mse
        if Mtype==1,iduiarx('ordedit')
        elseif any(Mtype==[2 3 4]), iduiio('ordedit')
        elseif Mtype==5, iduiss('ordedit');
        end
    end
    iduistat('Press Estimate to estimate model.')
    
elseif strcmp(arg,'setpop')
    edat = iduigetd('e','me');
    dom = pvget(edat,'Domain');
    Ts = pvget(edat,'Ts');Ts=Ts{1};
    val = get(XID.parest(4),'Value');
    [str,val]=idmspop(nu,ny,val,lower(dom(1)),Ts);
    set(XID.parest(4),'string',str,'Value',val)
elseif strcmp(arg,'mse')
    iduiio('open');
    XID = get(Xsum,'UserData');
    idparest('ordedit');
elseif strcmp(arg,'estimate')
    Mtype=get(XID.parest(4),'value');
    if Mtype==1
        gtws=iduiarx('estimate');
    elseif any(Mtype==[2 3 4 6])
        gtws=iduiio('estimate');
    elseif Mtype==5
        iduiss('estimate');
    end
elseif strcmp(arg,'ord_sel')
    Mtype=get(XID.parest(4),'value');
    if Mtype==1&nu>0
        str='[1:10 1:10 1:10]';
    else
        str='1:10';
    end
    
    set(XID.parest(3),'string',str)
    set(XID.parest(7),'string','')
    if iduiwok(21)
        set(XID.io(1,4),'value',13);
        if Mtype==5
            nks = get(XID.ss(1,8),'string');
            nks = get(XID.ss(1,8),'string');
            pnr1 = find(nks == '[');
            pnr2 = find(nks == ']');
            if isempty(pnr1),pnr1 = 0;end
            if isempty(pnr2),pnr2 = length(nks)+1;end
            if ~isempty(nks)
                str = [str,' [',nks(1+pnr1:pnr2-1),']'];
            end
            set(XID.parest(3),'string',str)
        end
        if Mtype==1
            if ny>1|nu>4,nmu=min(1,nu);else nmu=nu;end
            set(XID.io(1:nmu,[1 3]),'value',13);
        end
    end
    iduistat('Press Estimate and select order in plot that will open.')
elseif strcmp(arg,'filter')
    value = get(XID.parest(18),'Value');
    set(XID.parest(18),'UserData',[]);
    str = get(XID.parest(18),'String');
    fil = str{value};
    if lower(fil(1:2))=='fi'
        iduifoc('open');%iduifilt('open',[],'model');
    end
    
end

set(0,'Showhiddenhandles','off');
%set(Xsum,'Userdata',XID);
