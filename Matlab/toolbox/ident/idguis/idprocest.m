function idprocest(arg,onoff,enforce)
%IDPROCEST The basic callback function for estimation of procss models.
%   Arguments:
%   open   Creates the dialog box for idproc estimation
%   close  Makes the dialog invisible
%   struc  Updates the attributes based on changes in the structure propeties 
%   estimate estimates the model
%   filter   Performs proper filtering
%   parobj   Does the updates based on changes in the RHS parameter list
%   upop     Does the updates after a change in input number
%   more/less opens and closes the RHS part of the dialog

%   L. Ljung 12-29-03
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.22 $ $Date: 2003/11/11 15:51:57 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
warflag = strcmp(get(XID.warning,'checked'),'on');

if nargin<2,onoff='on';end
if strcmp(arg,'close')
    set(XID.procest(1,1),'Visible','off')
    try
        set(iduiwok(21),'vis','off');
    end
    try
        set(iduiwok(22),'vis','off');
    end
    set(Xsum,'Userdata',XID);
    return
end
usd=get(XID.hw(3,1),'userdata');
nu=usd.nu;ny=usd.ny;
dom = usd.dom;

if strcmp(arg,'open')
    if nargin<2,onoff='on';end
    FigName=idlaytab('figname',37);
    if nu==0|ny>1
        errordlg('Process Models only apply to MISO systems.','Error Dialog','modal')
        return 
    end
    if ~figflag(FigName,0)
        iduistat('Opening the Process Model dialog ...')
        
        layout
        butw = mStdButtonWidth;
        FigW = iduilay2(5);
        f = figure('NumberTitle','off','Name',FigName,...
            'userdata',[nu ny],'tag','sitb37','Integerhandle','off',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),'vis','off');
        XID.procest(1,1) = f;
        set(f,'Menubar','none','HandleVisibility','callback');
        s1='iduipoin(1);';s2='iduipoin(1);iduistat(''Compiling ...'');';
        s3='iduipoin(2);';
        % ******************
        % LEVEL 1 Bottom pushbuttons
        pos = iduilay1(FigW,5,1); 
        uicontrol(f,'pos',pos(1,:),'style','frame');
        cb=[s2,'idprocest(''estimate'');',s3];
        ttn = 'Before pushing ''estimate'' enter any model name to change default.';
        uicontrol(f,'pos',pos(2,:),'style','text','string','Name:',...
            'tooltip',ttn);
        XID.procest(1,2) = uicontrol(f,'pos',pos(3,:)+[-40 0 0 0],'style','edit',...
            'backgroundcolor','white','string','P1D','userdata',repmat({'P1D'},1,nu),...
            'tooltip',ttn);
        XID.procest(1,14)=uicontrol(f,'pos',pos(4,:),'string',...
            'Estimate','style','push','callback',cb,'Interruptible','on');
        set(XID.procest(1,14),'UserData',str2mat('[]','[]','[]','[]'))
        XID.procest(1,15)=uicontrol(f,'pos',pos(5,:),'string','Close',...
            'style','push','callback',[s1,'idprocest(''close'');',s3]);
        XID.procest(1,16)=uicontrol(f,'pos',pos(6,:),'string','Help','style',...
            'push','callback',...
            'iduihelp(''idprocest.hlp'',''Help: Estimating Process Models'');');
        
        %LEVEL 2 Iteration control
        lev2 = pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,5,1,lev2,[],[0.9 0.7 1.4 1 1]); 
        uicontrol(f,'pos',pos(1,:),'style','frame');
        
        XID.iter(13) = uicontrol(f,'pos',pos(2,:),'style','text','String','Iteration',...
            'HorizontalAlignment','left','tooltip',...
            'This line gives brief info about the progress of the iterative search for  model.');
        
        XID.iter(15) = uicontrol(f,'pos',pos(6,:),'style','text','string','Fit:',...
            'HorizontalAlignment','left',...
            'tooltip','Loss function at the current iteration');
        
        XID.iter(17) = uicontrol(f,'pos',pos(4,:),'style','text','string','Improvement',...
            'HorizontalAlignment','left','tooltip','Improvement in fit from previous iteration.');
        XID.iter(18) = uicontrol(f,'pos',pos(5,:),'style','check','string','Trace',...
            'tooltip','Check to give full details of iterations to command window.');
        XID.iter(11) = uicontrol(f,'pos',pos(6,:),'style','push','string','Stop Iterations',...
            'callback','idprocest(''stop'');','tooltip','Stop and save result after the current iteration.');
        
        %poss = iduilay1(FigW,5,1,lev4);
        %LEVEL 3 Various options
        lev3 = pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,10,2,lev3);
        
        
        
        %posr(:,1)=posr(:,1)+FigW;
        
        uicontrol(f,'pos',pos(1,:),'style','frame');
        
        uicontrol(f,'pos',pos(9,:),'style','text',...
            'string','Covariance:','HorizontalAlignment','right','tooltip',...
            'Should the covariance matrix of the parameters be estimated or not?');
        XID.procest(2,11) = uicontrol(f,'pos',pos(10,:),'style','pop',...
            'backgroundcolor','white',...
            'string','Estimate|None');
        uicontrol(f,'pos',pos(4,:),'style','text',...
            'string','Initial state:','HorizontalAlignment','right',...
            'tooltip','Options for the model''s initial state.');
        XID.procest(2,10) = uicontrol(f,'pos',pos(5,:),'style','pop',...
            'backgroundcolor','white',...
            'string','Auto|Zero|Estimate|Backcast|U-level est.','tooltip',...
            ['Fix it to zero, Estimate it, or Backcast it. Auto: Let the data decide.',...
                'U-level est: Estimate also the Input off-set Level.']);
        uicontrol(f,'pos',pos(7,:),'style','text',...
            'string','Focus:','HorizontalAlignment','right','tooltip',...
            'Over which frequency range should the model fit be focused?');
        tt1 = ['Simulation: The input power decides the frequency weighting.',...
                ' Filter: Choose a frequency range.'];
        XID.procest(2,9) = uicontrol(f,'pos',pos(8,:),'style','pop',...
            'backgroundcolor','white',...
            'string',{'Simulation','Filter...'},...
            'callback',[s1,'idprocest(''filter'');',s3],'tooltip',tt1);
        uicontrol(f,'pos',pos(2,:)+[-10 0 10 0],'style','text',...
            'string','Disturbance Model:','HorizontalAlignment','right',...
            'Tooltip','A possible additive disturbance model H as in y = Gu + He.');
        XID.procest(2,8) = uicontrol(f,'pos',pos(3,:),'style','pop',...
            'backgroundcolor','white',...
            'string','None|Order 1|Order 2','callback','idprocest(''noise'');',...
            'tooltip','No disturbance model or an ARMA model of order 1 or 2.');
        uicontrol(f,'pos',pos(11,:),'style','push','string','Options...',...
            'callback','iduiopt(''dlg_ioopt'',''ioopt'',1,1:4,1);',...
            'tooltip','Change options for the iterative estimation algorithm.');
        
        %LEVEL 4 RIGHT The table
        lev4 = pos(1,2)+pos(1,4);
        posf = iduilay1(FigW*3/5,50,11,lev4);%just for the frame
        %posf = iduilay1(FigW,50,11,lev4);%just for the frame
         posf2 = iduilay1(FigW*2/5,55,11,lev4);
       uicontrol(f,'pos',posf(1,:)+[FigW*2/5 0 0 0],'style','frame');
          uicontrol(f,'pos',posf2(1,:),'style','frame');
        %uicontrol(f,'pos',posf(1,:),'style','frame');

        %Level 4.a Initial model and initial guess
        
        %lev4 = lev4+30;
        posr = iduilay1(FigW*3/5,55,11,lev4,[],[0.35 0.35 0.65 0.65 0.7]);
        posr(:,1) = posr(:,1)+FigW*2/5;
        ttfix = 'Check box to fix this parameter';
        ttval = 'Estimation result or Fixed value.';
        ttvali = 'Initial guess: Enter ''Auto''  to estimate.';
        ttbd = 'Lower and Upper bound for the parameter';
        
        uicontrol(f,'pos',posr(2,:)+[-12 0 30 0],'style','text','string','Parameter','tooltip',...
            'Parameters of the Model Transfer function');
        uicontrol(f,'pos',posr(3,:)+[0 0 5 0],'style','text','string','Known',...
            'tooltip',ttfix);
        uicontrol(f,'pos',posr(4,:),'style','text','string','Value',...
            'tooltip',ttval);
        uicontrol(f,'pos',posr(5,:),'style','text','string','Initial Guess',...
            'tooltip',ttvali);
        uicontrol(f,'pos',posr(6,:),'style','text','string','Bounds','tooltip',ttbd);
        
        for kp = 1:6
            XID.procest(5,kp)=uicontrol(f,'pos',posr(5*kp+2,:),'style','text');
            
            XID.procest(2,kp) = uicontrol(f,'pos',posr(5*kp+3,:),'style','check',...
                'callback','idprocest(''parobj'');',...
                'tag',['status',int2str(kp)],'tooltip',ttfix);
            XID.procest(3,kp) = uicontrol(f,'pos',posr(5*kp+4,:),'style','edit','string','',...
                'callback','idprocest(''parobj'');','tag',['value',int2str(kp)],'tooltip',ttval,...
                'backgroundcolor','white');
            XID.procest(7,kp) = uicontrol(f,'pos',posr(5*kp+5,:),'style','edit','string','Auto',...
                'callback','idprocest(''parobj'');','tag',['value',int2str(kp)],'tooltip',ttvali,...
                'backgroundcolor','white');
            mstr = '[0.001 inf]';
            if kp == 1 | kp == 5 % Kp and Tz
                mstr = '[-inf inf]';
            end
            if kp == 6 % Td
                eDat = iduigetd('e');
                Ts = pvget(eDat,'Ts'); if iscell(Ts),Ts = Ts{1};end
                mstr = ['[',int2str(0),' ', num2str(30*Ts),']'];
            elseif ~any(kp==[2 3])
            end
            XID.procest(4,kp) = uicontrol(f,'pos',posr(5*kp+6,:),'style','edit',...
                'backgroundcolor','white','string',mstr,...
                'callback','idprocest(''parobj'');','tag',['bounds',int2str(kp)],...
                'tooltip',ttbd);
        end
        defusd(XID.procest,nu);
        set(XID.procest(5,1),'string','K');
        set(XID.procest(5,2),'string','Tp1');
        set(XID.procest(5,3),'string','Tp2');
        set(XID.procest(5,4),'string','Tp3');
        set(XID.procest(5,5),'string','Tz');
        set(XID.procest(5,6),'string','Td');
        set(XID.procest(2:5,[2:6]),'enable','off');
                ttini = 'Drag and Drop or Enter WS Model Name of IDPROC model.';
        hin = 10;% Indentation of radio buttons
        uicontrol(f,'pos',posr(37,:)+[hin -5 2*posr(44,3), 0],'style','text','string','Initial Guess',...
            'horizontalalignment','left',...
            'tooltip','Choice of initialization. Default: Do nothing here.');
        XID.procest(8,1) = uicontrol(f,'pos',posr(47,:)+[hin 0 2*posr(44,3) 0],...
            'style','radio','string','From existing model:',...
            'horizontalalignment','left',...
            'tooltip','Optionally initialize in given IDPROC model.','tag','modst',...
            'callback','idprocest(''radio'',[2 3],1);');
        
        XID.procest(1,6) = uicontrol(f,'pos',posr(50,:)+[0 0 posr(55,3) 0],'style','edit',...
            'backgroundcolor','white','string','','userdata','',...
            'tooltip',ttini,'callback','idprocest(''radio'',[2 3],1);idprocest(''model2gui'')','tag','modst');
        XID.procest(8,2)=uicontrol(f,'pos',posr(52,:)+[hin 0 posr(44,3) 0],...
            'style','radio','string','User-defined',...
            'callback','idprocest(''radio'',[1 3],2);','enable','on','tooltip',...
            'Enter initial guesses as numbers (Some may be kept as Auto) or move current values to initial guesses.');
        XID.procest(1,13)=uicontrol(f,'pos',posr(55,:)+[0 0 posr(55,3) 0],...
            'style','push','string','Value-->Initial Guess',...
            'callback',[s1,'idprocest(''radio'',[1 3],2);idprocest(''move'');',s3],'enable','on','tooltip',...
            'Move current values to initial guesses.');
        XID.procest(8,3) = uicontrol(f,'pos',posr(42,:)+[hin 0 2*posr(44,3) 0],'style','radio','string','Auto-selected',...
            'callback','idprocest(''reset'');','tooltip',...
            'Estimate automatically Initial Parameter value','value',1);
        

        
        % LEVEL 4
        pos = iduilay1(FigW*2/5,30,10,lev4,[],[0.5 0.75 0.75]);
        rindent = [0 -10 pos(23,3) 0];% indentation of Zero etc
        XID.procest(1,8)=uicontrol(f,'pos',pos(23,:)+rindent,...
            'string','Delay','style','check','value',1,...
            'HorizontalAlignment','left','callback',[s1,'idprocest(''struc'',''d'');',s3],...
            'tooltip','Allow time delay (dead-time) in process');
        XID.procest(1,7)=uicontrol(f,'pos',pos(26,:)+rindent,'string','Integrator',...
            'callback',[s1,'idprocest(''struc'',''i'');',s3],'style','check',...
            'tooltip','Enforce integration (''self-regulating process'')');
        XID.procest(1,9)=uicontrol(f,'pos',pos(20,:)+rindent,'string','Zero',...
            'callback',[s1,'idprocest(''struc'',''z'');',s3],...
            'style','check','tooltip','Add zero (extra numerator term)');
        XID.procest(1,10)=uicontrol(f,'pos',pos(17,:),'style','pop',...
            'backgroundcolor','white',...
            'callback',[s1,'idprocest(''struc'',''p'');',s3],'value',2,...
            'string',['0|1|2|3'],'tag','pnum','tooltip','Number of poles in model');
        XID.procest(1,17)=uicontrol(f,'pos',pos(14,:),...
            'HorizontalAlignment','left',...
            'string','Poles','style','text');
        XID.procest(1,11)=uicontrol(f,'pos',pos(18,:)+[0 0 0.75*pos(18,3) 0],'style','pop',...
            'backgroundcolor','white',...
            'callback',[s1,'idprocest(''struc'',''c'');',s3],'value',1,...
            'string',['All real|Underdamped'],'tag','pchar','tooltip',...
            'All poles constrained to be real or allow complex (underdamped) poles');
        XID.procest(1,3) = uicontrol(f,'pos',pos(7,:)+[0 20 0 0],'style','check',...
            'string','All same','value',1,'tooltip',['Check to let models from all inputs',...
                ' have the same structure.'],'callback',[s1,'idprocest(''same'');',s3]);
        XID.procest(1,5)=uicontrol(f,'pos',pos(5,:)+[0 20 0 0],'style','text','string','Input #');
        XID.procest(1,19)= uicontrol(f,'pos',pos(2,:)+[0 20 pos(2,3)+pos(3,3) 0],'style','text','string',...
            'Model Transfer Function');
        for ku = 1:nu
            strp{ku}=int2str(ku);
        end
        XID.procest(1,4) = uicontrol(f,'pos',pos(6,:)+[0 20 -20 0],'style','pop',...
            'backgroundcolor','white',...
            'string',strp,'callback','idprocest(''upop'');','tooltip',...
            ['Input number for which the current model structure applies.']);
        if nu==1
            set(XID.procest(1,[3 4 5]),'vis','off')
            addh = 30;
        else
            addh = 10;
        end
        %THese are the three windows for G(s) expression:
        XID.procest(6,1) = uicontrol(f,'pos',pos(8,:)+[-10 1+addh sum(pos(2:4,3))-pos(8,3)+20 -7],'style','text',...
            'string','G(s)=');
        XID.procest(6,2) = uicontrol(f,'pos',pos(8,:)+[-10 -12+addh sum(pos(2:4,3))-pos(8,3)+20 -7],'style','text',...
            'string','G(s)=');
        XID.procest(6,3) = uicontrol(f,'pos',pos(8,:)+[-10 -25+addh sum(pos(2:4,3))-pos(8,3)+20 -7],'style','text',...
            'string','G(s)=');
        
        % ******************************
        % LEVEL 5
        FigH=posf(1,2)+posf(1,4)+mEdgeToFrame;
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
        f = XID.procest(1,1);
        set(get(f,'children'),'units','norm');
        set(f,'vis',onoff)
        set(Xsum,'UserData',XID);
        idprocest('struc','a');
    end % if figflag
    % data dependent changes:
    
    if dom == 't'&strcmp(get(XID.procest(2,8),'style'),'text')
        set(XID.procest(2,8),'style','pop',...
            'backgroundcolor','white',...
            'string','None|Order 1|Order 2','callback','idprocest(''noise'');',...
            'tooltip','No disturbance model or an ARMA model of order 1 or 2.');
        idprocest('noise');
    elseif dom=='f'&~strcmp(get(XID.procest(2,8),'style'),'text')
        set(XID.procest(2,8),'style','text',...
            'backgroundcolor',get(0,'DefaultUIcontrolBackgroundColor'),...
            'string','None',...
            'tooltip','No disturbance model for frequency domain data.');
        idprocest('noise');
    end
    iduistat('Choose model Structure and Orders and then press the estimate button.')
    % ************************
elseif strcmp(arg,'same')
    if get(XID.procest(1,3),'value')
        idprocest('struc','a');
        %type2gui(XID.procest,nu);
    end
elseif strcmp(arg,'struc')
    call = onoff;%'a' (all) 'i','p','z','d','c' for integrator, poles,zero,delay,character
    allch = get(XID.procest(1,3),'value');
    ku = get(XID.procest(1,4),'value');
    oldpole = [];
    if any(call==['p','c','a']) % poles have been changed
        typec=get(XID.procest(1,2),'userdata');
        type = typec{ku};
        oldpole = eval(type(2));
    end
    type =  gui2type(XID.procest,nu);
    
    type2gui(XID.procest,nu);
    usd2gui(XID.procest)
    if any(type=='U')
        under = 1;
    else
        under = 0;
    end
    
    nop = eval(type(2));
    nopp = nop; %actual number of different poles. To be used
    % when double and tripe are implemented
    %allch = 
    if any(call==['a','p'])
        bset(nopp<3,4,XID.procest,allch,ku,nu); % set Tp3 right
    end
    if any(call==['a','p','c'])
        if (call=='p'&oldpole<2|(oldpole>nop))|any(call==['a','c'])
            bset(nopp<2,3,XID.procest,allch,ku,nu,under); % set Tp2 right
        end
        if  (call=='p'&(oldpole<1|oldpole>nop))|any(call==['a','c'])
            bset(nopp<1,2,XID.procest,allch,ku,nu,under); %set Tp1 right
        end
    end
    if any(call==['a','d']);
        bset(~any(type=='D'),6,XID.procest,allch,ku,nu);
    end
    if any(call==['a','z']);
        bset(~any(type=='Z'),5,XID.procest,allch,ku,nu);
    end
    idprocest('setstop');
elseif strcmp(arg,'noise') %adjust the focus popup
    if (~strcmp(get(XID.procest(2,8),'style'),'text'))&get(XID.procest(2,8),'value')>1
        str ={'Prediction','Simulation','Stability','Filter...'};
        tt1 = ['Predition/Simulation: Optimize the fit for prediction or simulation.',...
                ' Stability: Guarantee stability. Filter: Choose a frequency range.'];
    else
        str = {'Simulation','Filter...'};
        tt1 = ['Simulation: The input power decides the frequency weighting.',...
                ' Filter: Choose a frequency range.'];
    end
    set(XID.procest(2,9),'string',str,'tooltip',tt1,'value',1);
    idprocest('setstop')   
elseif strcmp(arg,'estimate')
    eDat = iduigetd('e');
    eDat_info = iduiinfo('get',eDat);
    eDat_n = pvget(eDat,'Name');
    argin={};text=[''];pretext=[];
    
    init = get(XID.procest(2,10),'Value');
    if init==2
        argin = [argin,{'Init'},{'Zero'}];
        text = [text,',''Init'',''Zero'''];
    elseif init==3
        argin = [argin,{'Init'},{'estimate'}];
        text = [text,',''Init'',''Est'''];
    elseif init==4
        argin = [argin,{'Init'},{'Back'}];
        text = [text,',''Init'',''Back'''];
    elseif init==5
        
        argin = [argin,{'Init'},{'estimate'},{'InputLevel'},...
                {repmat({'estimate'},1,nu)}];
        text = [text,',''Init'',''Est'',''Ulevel'',''Est'''];
    end
    try
        cov = get(XID.procest(2,11),'Value');
    catch
        cov = 1;
    end
    %% First set Disturbancemodel ...
    if ~strcmp(get(XID.procest(2,8),'style'),'text')
        dist = get(XID.procest(2,8),'Value');
        if dist == 2 % 1st order
            argin = [argin,{'Dist'},{'ARMA1'}];
            text = [text,'''Dist'',''ARMA1'''];
        elseif dist == 3 %2nd order
            argin = [argin,{'Dist'},{'ARMA2'}];
            text = [text,'''Dist'',''ARMA2'''];
        end
    end
    if cov == 2 % no covariance
        argin = [argin,{'Cov'},{'None'}];
        text = [text,'''Cov'',''None'''];
    end
    foc = get(XID.procest(2,9),'Value');
    if foc>1
        focstr = get(XID.procest(2,9),'String');
        foc = focstr{foc};
        if strcmp(lower(foc(1:2)),'fi')
            
            filt = get(XID.procest(2,9),'userData');
            if length(filt)<2
                errordlg('No filter selected. You must enter pass bands in the focus dialog.',...
                    'Data Filter Error','modal');
                err = 1;
                return
            end
            argin = [argin,{'Focus'},filt(1)];
            pretext = filt{2};
            text = [text,'''Focus'',{a,b,c,d}'];
        else
            argin = [argin,{'Focus'},{foc}];
            text = [text,'''Focus'',','''',foc,''''];
        end
    end
    usd=get(XID.citer(1),'UserData');
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
        text = [text,',''FixedP'',',index];
    end
    %tic
    [m0,estim] = gui2idp(XID.procest);
    if ischar(m0)&strcmp(m0,'error')
        return
    end
    type = get(XID.procest(1,2),'userdata');
    if estim
        try
            was = warning;
            warning off
            lastwarn('')
            idprocest('setstop')
            LASTM = pem(eDat,m0,argin{:}); 
            warmess = lastwarn;
            set(XID.iter(11),'Userdata',0);
            drawnow
            set(XID.iter(11),'string','Continue','callback','idprocest(''cont'');',...
                'tooltip','Press to continue iterations for the last model.');
%             if ~isempty(lastwarn)&warflag
%                 mess = '(Warning Dialogs can be turned off under the Options Menu in the main window)';
%                 idgwarn(lastwarn,1);
%             end
            warning(was)
        catch
            errordlg(lasterr,'Error  Using PEM','Modal')
            return
        end
    else
        m0 = pvset(m0,'InputName',pvget(eDat,'InputName'),'OutputName',pvget(eDat,'OutputName'),...
            'InputUnit',pvget(eDat,'InputUnit'),'OutputUnit',pvget(eDat,'OutputUnit'));
        ut = pvget(m0,'Utility');
        Ts = pvget(eDat,'Ts'); if iscell(Ts),Ts = Ts{1};end
        ut.Tsdata = Ts;
        m0 = uset(m0,ut);
        LASTM = m0;
        warmess = [];
    end
    if isempty(LASTM),iduiinsm([]);return,end
    % Now write out the values in the dialog box:
    model2gui(XID.procest,LASTM);
    
    model=get(XID.procest(1,2),'string');
    if length(type)>1
        tp = '{';
        for kt = 1:length(type)
            tp=[tp,'''',type{kt},''','];
        end
        tp(end)='}';
    else
        tp = ['''',type{1},''''];
    end
    mod_info=str2mat(eDat_info,pretext,...
        [model,' = pem(',eDat_n,',',tp,text,');']);
    if ~isempty(warmess)
        mod_info=str2mat(mod_info,['Warning: ',lastwarn]);
    end
    mod_nam=model;
    mod_nam=mod_nam(find(mod_nam~=' '));
    LASTM = pvset(LASTM,'Name',mod_nam); 
    LASTM = iduiinfo('set',LASTM,mod_info);
    iduiinsm(LASTM);
    idgwarn(warmess,1);
    XID = get(Xsum,'UserData');
elseif strcmp(arg,'filter')
    value = get(XID.procest(2,9),'Value');
    str = get(XID.procest(2,9),'string');
    set(XID.procest(2,9),'UserData',[]);
    if value == length(str)
        iduifoc('open');%iduifilt('open',[],'model');
    end
elseif strcmp(arg,'move') % Move to initial guesses
    for kp = 1:6
        set(XID.procest(7,kp),'userdata',get(XID.procest(3,kp),'userdata'))
    end
    usd2gui(XID.procest)
elseif strcmp(arg,'parobj')
    llo = gco;
    under = get(XID.procest(1,11),'value')-1;
    usd = get(llo,'userdata');
    ku = get(XID.procest(1,4),'value'); %input number
    tg = get(llo,'tag');
    if length(tg)==6%&strcmp(tg(1:5),'value')
        pnr = eval(tg(6));
        tg = tg(1:5);
    end
    if length(tg)==7%&strcmp(tg(1:5),'value')
        pnr = eval(tg(7));
        tg = tg(1:6);
    end
    if strcmp(tg,'status')%length(tg)>=6&strcmp(tg(1:6),'status') % known-checkbox
        %pnr = eval(tg(7));
        v = get(llo,'value');
        
        if v
            res = 'fixed';
            if isempty(deblank(get(XID.procest(3,pnr),'string')))
                try
                    inita=get(XID.procest(7,pnr),'string');
                    eval(inita);
                    set(XID.procest(3,pnr),'string',inita)
                end
            end
            if isempty(deblank(get(XID.procest(3,pnr),'string')))
                errordlg(['A fixed (known) parameter must be given a numeric',...
                        ' value.'],'Error Dialog','modal');
                set(llo,'value',0)
                return 
            else
                val = eval(get(XID.procest(3,pnr),'string'));
            end
            % check bounds
            [val,wrnm] = chbound(val,XID.procest,pnr,ku);
            
            if ~isempty(wrnm)
                warndlg(wrnm,'Bad Value','Modal')
            end
            set(XID.procest(3,pnr),'string',num2str(val));
            set(XID.procest(7,pnr),'string',get(XID.procest(3,pnr),'string'))
            set(XID.procest([4 7],pnr),'enable','off')
            
        else
            res = 'estimate';
            set(XID.procest([4 7],pnr),'enable','on')
            val = 0;
        end
        usdval = get(XID.procest(3,pnr),'userdata');
        usdinival = get(XID.procest(7,pnr),'userdata');
        
        if size(usd,1)==2
            if ~under
                usd{1,ku} = res;
                usd{2,ku} = 'zero';
                usdval(1,ku) = val;
                usdval(2,ku) = 0;
                usdinival(1,ku) = val;
                usdinival(2,ku) = 0;
            else
                usd{2,ku} = res;
                usd{1,ku} = 'zero';
                usdval(2,ku) = val;
                usdval(1,ku) = 0;
                usdinival(2,ku) = val;
                usdinival(1,ku) = 0;
            end
        else
            usd{ku} = res;
            usdval(ku) = val;
            usdinival(ku) = val;
        end
        if v
            set(XID.procest(3,pnr),'userdata',usdval);
            set(XID.procest(7,pnr),'userdata',usdinival);
        end
    elseif strcmp(tg,'value')
        if isempty(get(llo,'string'))|strcmp(lower(get(llo,'string')),'auto')
            res = NaN;
        else
            set(XID.procest(8,[1 3]),'value',0)% The radio buttons
            set(XID.procest(8,2),'value',1)
            try
                res = eval(get(llo,'string'));
            catch
                res =[];
            end
            if isempty(res)|~isnumeric(res)
                errordlg('Illegal value entered.','Error Dialog','Modal')
                set(llo,'string','')
                return
            end
        end
        % check bounds
        [res,wrnm] = chbound(res,XID.procest,pnr,ku);
        
        if ~isempty(wrnm)
            warndlg(wrnm,'Bad Value','Modal')
        end
        if isnan(res)
            lostr = 'Auto';
        else
            lostr = num2str(res);
        end
        set(llo,'string',lostr);
        %%LL AT this point one shiould check against bounds
        if size(usd,1)==2
            if ~under
                usd(1,ku) = res;
                usd(2,ku) = 0;
            else
                usd(2,ku) = res;
                usd(1,ku) = 0;
            end
        else
            usd(ku) = res;
        end
        %usd(ku) = res;
    elseif strcmp(tg,'bounds')
        try
            res = eval(['[',get(llo,'string'),']']);
        catch 
            errordlg('Illegal value for bounds','Error Dialog','modal')
            usd2gui(XID.procest);
            return
        end
        if size(res,2)~=2
            errordlg('The bounds must contain one upper and one lower bound.',...
                'Error Dialog','Modal');
            usd2gui(XID.procest);
            return
        end
        if res(2)<=res(1)
            errordlg('The lower bound must be strictly less than the upper bound.',...
                'Error Dialog','Modal');
            usd2gui(XID.procest);
            return
        end
        refr = 0;
        if any(pnr==[2 3 4])&res(1)<=0
            warndlg('The lower bound for time constants must be strictly positive.',...
                'Warning Dialog','Modal');
            res(1)=0.001; if res(2)<=res(1),res(2)=Inf;end
            refr = 1;
        end
        if pnr==6&res(1)<0
            warndlg('The lower bound for time delays must be non-negative.',...
                'Warning Dialog','Modal');
            res(1)=0; 
            if res(2)<=0,
                 eDat = iduigetd('e');
                Ts = pvget(eDat,'Ts'); if iscell(Ts),Ts = Ts{1};end
                res(2)=30*Ts;
            end
            refr = 1;
            
        end
        if refr
            set(llo,'string',['[',num2str(res(1)),' ',num2str(res(2)),']']);
        end
        %end
        if size(usd.min,1)== 2
            usd.min(under+1,ku)  = res(1);
            usd.max(under+1,ku) = res(2);
        else
            usd.min(1,ku) = res(1);
            usd.max(1,ku) = res(2);
        end
    end
    set(llo,'userdata',usd);
    idprocest('setstop')
elseif strcmp(arg,'upop') % Input number pop
    idprocest('setstop')
    type2gui(XID.procest,nu);
    usd2gui(XID.procest);
elseif strcmp(arg,'radio')
    set(XID.procest(8,onoff),'value',0)
    set(XID.procest(8,enforce),'value',1)
elseif strcmp(arg,'reset')
    set(XID.procest(8,[1 2]),'value',0);
    set(XID.procest(8,3),'value',1);
    idprocest('setstop')
    for kp = 1:6
        sta = get(XID.procest(2,kp),'Userdata');%status
        usdvi = zeros(size(sta(:)));
        usdvi(find(strcmp(sta(:),'estimate')))=NaN;
        usdvi = reshape(usdvi,size(sta));
        set(XID.procest(7,kp),'Userdata',usdvi)
    end
    usd2gui(XID.procest);
elseif strcmp(arg,'model2gui')
    idprocest('setstop')
    if strcmp(onoff,'drop') % A model has been dropped
        model = get(XID.procest(1,6),'userdata');
        
    else % parse the string
        str = get(XID.procest(1,6),'string');
        
        try
            model = evalin('base',str);
        catch
            model = [];
        end
        if isempty(model)
            try
                sumb=findobj(get(0,'children'),'flat','tag','sitb30');
                modeln=findobj([XID.sumb(1);sumb(:)],...
                    'type','text','string',str);
                modax=get(modeln(1),'parent');
                modax=modax(1);
                modlin=findobj(modax,'tag','modelline');
                model = get(modlin,'userdata');
            end
        end
        if isempty(model)
            errordlg(char({['The model ',str,' is neither in the',...
                        ' workspace nor on the model board.']}),'Model Not Found','modal');
            return
        elseif ~isa(model,'idproc')
            errordlg(char({['The model ',str,' is not a process model.']}),'Wrong Model','modal')
            return
        end 
    end
        num = size(model,'nu');
        if num~=nu
            errordlg('The number of inputs in the model is different from the data size.',...
                'Error Dialog','modal');
            set(XID.procest(1,6),'string','','userdata',[]);
            return
        end
        set(XID.procest(1,2),'userdata',pvget(model,'Type'),...
            'string',[get(XID.procest(1,6),'string'),'n'])
        
        type2gui(XID.procest,nu)
        model2gui(XID.procest,model);
        idprocest('move');
elseif strcmp(arg,'stop')
    set(XID.iter(11),'userdata',1);
    iduistat('Iterations will be stopped after the current one.')
elseif strcmp(arg,'setstop')
    set(XID.iter(11),'string','Stop Iterations','userdata',0,...
        'tooltip','Stop and save result after the current iteration.',...
        'callback','idprocest(''stop'');')
elseif strcmp(arg,'cont')
    set(XID.procest(1,2),'string',[get(XID.procest(1,2),'string'),'c']);
    idprocest('setstop')
    idprocest('move')
    idprocest('estimate')
end

%%%%%
function bset(cond,nr,hand,allch,ku,nu,aux,user)
% Sets enable and userdata according to type for channel ku
if nargin < 8
    user = 1;
end
if nargin<7
    aux = -1;
end
usd = get(hand(2,nr),'userdata');
usdv = get(hand(3,nr),'userdata');
usdi = get(hand(7,nr),'userdata');
if cond
    set(hand([2:5,7],nr),'enable','off')
    set(hand(2,nr),'value',0)
    set(hand([3,7],nr),'string','0')
    if nr==2|nr==3
        if allch
            usdv = zeros(2,nu);
        else
            usdv(:,ku) = [0;0];
        end
    else
        if allch
            usdv = zeros(1,nu);
        else
            usdv(ku) = 0;
        end
    end
    if nr==2|nr==3
        if allch
            usd = repmat({'Zero'},2,nu);
        else
            usd(1:2,ku)={'Zero';'Zero'};
        end
    else
        if allch    
            usd = repmat({'Zero'},1,nu);
        else
            usd{ku} = 'Zero';
        end
    end
    usdi = usdv;
else
    set(hand([2:5,7],nr),'enable','on')
    set(hand(2,nr),'value',0)
    if nr==2|nr==3 %tw zeta tp1 tp2
        if allch
            usd = repmat({'Zero'},2,nu);
            usdv(aux+1,1:nu) = repmat(NaN,1,nu);  
            usd(aux+1,1:nu)=repmat({'estimate'},1,nu);
        else
            usd(1:2,ku)={'Zero';'Zero'};
            usd(aux+1,ku)={'estimate'};
            usdv(aux+1,ku)=NaN;
        end
    else
        if allch
            usd = repmat({'estimate'},1,nu);
            usdv = repmat(NaN,1,nu);
        else
            usd{ku} = 'estimate';
            usdv(ku) = NaN;
        end
    end
    %end           
    set(hand([3],nr),'string','')
    set(hand(7,nr),'string','Auto');
end
%end
if user
    usdi = usdv;
    set(hand(2,nr),'Userdata',usd);
    set(hand(3,nr),'Userdata',usdv);
    set(hand(7,nr),'Userdata',usdi);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  bbset(nr,ku,hand,un)
% Restores Right hand side objects fields when input number is changed

%1. First value, min and max
us = get(hand(3,nr),'user');
set(hand(3,nr),'string',num2str(us(ku)));
us = get(hand(4,nr),'user');
set(hand(4,nr),'string',['[',num2str(us.min(ku)),' ',num2str(us.max(ku)),']'])

%2. Then status field:
us = get(hand(2,nr),'user');
if any(nr==[2,3])&un==1
    sta = lower(us{2,ku}(1));
else 
    sta = lower(us{1,ku}(1));
end
if sta=='z'|sta=='e'
    set(hand(2,nr),'value',0)
else
    set(hand(2,nr),'value',1)
end

%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
function type2gui(hand,nu)
% sets all the GUI features right according the the stored type.
allch = get(hand(1,3),'value');
ku = get(hand(1,4),'value'); 
typec = get(hand(1,2),'userdata');
type = typec{ku};
nop = eval(type(2));
nopp = nop; %actual number of different poles. To be used
% when double and tripe are implemented
if any(type=='U')
    under = 1;
else
    under = 0;
end 
if under
    set(hand(5,2),'string','Tw');
    set(hand(5,3),'string','Zeta');
else
    set(hand(5,2),'string','Tp1');
    set(hand(5,3),'string','Tp2');
end
% nop = eval(type(2));
set(hand(1,10),'value',nop+1);
if any(type=='D')
    set(hand(1,8),'value',1);
else
    set(hand(1,8),'value',0);
end
if any(type=='Z')
    set(hand(1,9),'value',1);
else
    set(hand(1,9),'value',0);
end
if any(type=='I')
    set(hand(1,7),'value',1);
else
    set(hand(1,7),'value',0);
end
if any(type=='U')
    set(hand(1,11),'value',2);
    un=1;
else
    set(hand(1,11),'value',1);
    un=0;
end
%%%
% 4. Set enable etc i right board, but don't touch userdata

bset(nopp<3,4,hand,allch,ku,nu,-1,0); % set Tp3 right
bset(nopp<2,3,hand,allch,ku,nu,under,0); % set Tp2 right
bset(nopp<1,2,hand,allch,ku,nu,under,0);
bset(~any(type=='D'),6,hand,allch,ku,nu,-1,0);
bset(~any(type=='Z'),5,hand,allch,ku,nu,-1,0);
%5. Write the model  
if any(type=='Z')
    line1 = 'K(1 + Tz s)';
else
    line1 = 'K';
end
line2 = [repmat('-',1,20*nop+20)];
if any(type=='D')
    line1 = [line1,' exp(-Td s)'];
end
if any(type=='I')
    line3 = 's ';
else
    line3 = '';
end
switch nop
    case 0
        % line3 = '';
    case 1
        line3 = [line3,'(1 + Tp1 s)'];
    case 2
        if any(type=='U')
            line3 = [line3,'(1 + (2 Zeta Tw) s + (Tw s)^2)'];
        else
            line3 = [line3,'(1 + Tp1 s)(1 + Tp2 s)'];
        end
    case 3
        if any(type=='U')
            line3 = [line3,'(1 + (2 Zeta Tw) s + (Tw s)^2)(1 + Tp3 s)'];
        else
            line3 = [line3,'(1+Tp1 s)(1+Tp2 s)(1+Tp3 s)'];
        end
end

set(hand(6,1),'string',line1);
set(hand(6,2),'vis','off')
set(hand(6,2),'string',line2);
set(hand(6,3),'string',line3);
ex1 = get(hand(6,1),'extent');
ex2 = get(hand(6,2),'extent');
ex3 = get(hand(6,3),'extent');
exm = max(ex1(1,3),ex3(1,3));
modnop = fix((20*nop+20)*exm/ex2(1,3))+3;
if nop == 0&isempty(line3)
    set(hand(6,2),'string','')
else
    set(hand(6,2),'string',repmat('-',1,modnop),'vis','on')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function usd2gui(hand)
% takes the current userdata and fills out the status, value and min/max
% fields
%1. First value, min and max
ku = get(hand(1,4),'value'); % current channel
pc = get(hand(1,11),'value'); %underdamped or not
if pc == 2
    un = 1;
else 
    un = 0;
end
for nr = 1:6
    usv = get(hand(3,nr),'user');
    usvi = get(hand(7,nr),'user');
    usmm = get(hand(4,nr),'user');
    usmi = usmm.min;
    usma = usmm.max;
    if any(nr==[2,3])
        usvi = usvi(un+1,:);
        usv = usv(un+1,:);
        usmi = usmi(un+1,:);
        usma = usma(un+1,:);
    end
    if isnan(usv(ku))
        strv = '';
    else
        strv = num2str(usv(ku));
    end
    if isnan(usvi(ku))
        strvi = 'Auto';
    else
        strvi = num2str(usvi(ku));
    end
    set(hand(3,nr),'string',strv);
    set(hand(7,nr),'string',strvi);
    set(hand(4,nr),'string',['[',num2str(usmi(ku)),' ',num2str(usma(ku)),']'])
    
    %2. Then status field:
    us = get(hand(2,nr),'user');
    if any(nr==[2,3])&un==1
        sta = lower(us{2,ku}(1));
    else 
        sta = lower(us{1,ku}(1));
    end
    if sta=='z'|sta=='e'
        set(hand(2,nr),'value',0)
    else
        set(hand(2,nr),'value',1)
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function type = gui2type(hand,nu)
% constructs and sets the type

allch = get(hand(1,3),'value');
ku = get(hand(1,4),'value');
% 1. Check consistency among choices
nop = get(hand(1,10),'value')-1;
zer = get(hand(1,9),'value');
polechar = get(hand(1,11),'value');
if nop<2 & polechar==2
    errordlg('You need at least two poles to allow underdamped modes','Error','modal');
    set(hand(1,10),'value',3)
    nop = 2;
end
if zer&nop==0
    errordlg('You need at least one pole to allow a zero.')
    set(hand(1,10),'value',2)
    nop = 1;
end

if nop<2 & polechar == 3
    errordlg('You need at least two poles to allow double-poles','Error','modal');
    set(hand(1,10),'value',3)
    nop =2;
end
if nop<3 & polechar == 4
    errordlg('You need at least three poles to allow triple-poles','Error','modal');
    set(hand(1,10),'value',4)
    nop = 3;
end
%%Check also that zero is allowed
%2. Determine nopp: number of different poles
nopp = nop;
if polechar == 4
    nopp = 1; %actual time constants
end
if polechar == 3
    nopp = 2;
end
%%%
%3. Now set the type

type = ['P',int2str(nop)];
if get(hand(1,8),'value'), 
    type = [type,'D'];
end
if get(hand(1,7),'value'), 
    type = [type,'I'];
end
if get(hand(1,9),'value'), 
    type = [type,'Z'];
end
if polechar == 2, 
    type = [type,'U'];
    under = 1;
else
    under = 0;
end
typec = get(hand(1,2),'userdata');
if allch % all inputs same structure
    typec = repmat({type},1,nu);
else
    typec{ku} = type;
end
set(hand(1,2),'string',type,'userdata',typec)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [usdstat,usdval,usdmm] = defusd(hand,nu)
% sets the userdata for the default model
for kp = 1:6
    
    ze= repmat({'estimate'},1,nu);
    clear usdstat
    if any(kp==[2,3]) %Tp1 and Tw, Tp2 and Zeta
        usdstat=repmat({'zero'},2,nu);
        if kp == 2, usdstat(1,:)=ze;end
    elseif kp==1 | kp==6 %Kp and Td
        usdstat = ze;
    else
        usdstat = repmat({'zero'},1,nu);
    end
    if any(kp==[1  6])
        usdval = repmat(NaN,1,nu);
    elseif kp==2;
        usdval(2,1:nu) = repmat(0,1,nu);
        usdval(1,1:nu) = repmat(NaN,1,nu);
    elseif kp==3
        usdval=repmat(0,2,nu);
    else
        usdval = repmat(0,1,nu);
        
    end
    
    mstr = '[0.001 inf]';
    if kp == 1 | kp == 5 % Kp and Tz
        usdmm.min = repmat(-inf,1,nu);
        mstr = '[-inf inf]';
    elseif kp==6 %Td
        usdmm.min = repmat(0,1,nu);
    elseif any(kp==[2 3])%Tp1 Tp2/Tw Zeta
        usdmm.min = repmat(0.001,2,nu);
        usdmm.max = repmat(inf,2,nu);
        % mstr ='[0 inf]';
    else
        usdmm.min = repmat(0.001,1,nu);
        %mstr = '[0 inf]';
    end
    if kp == 6 % Td
        eDat = iduigetd('e');
        Ts = pvget(eDat,'Ts'); if iscell(Ts),Ts = Ts{1};end
        usdmm.max = repmat(30*Ts,1,nu);
        mstr = ['[',int2str(0),' ', num2str(30*Ts),']'];
    elseif ~any(kp==[2 3])
        usdmm.max=repmat(inf,1,nu);
    end
    
    %end
    
    %for kp = 1:6
    set(hand(2,kp),'userdata',usdstat);
    set(hand([3,7],kp),'userdata',usdval);
    set(hand(4,kp),'userdata',usdmm);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function model2gui(hand,m)

Kp = pvget(m,'Kp');
set(hand(3,1),'UserData',Kp.value);
%% Set also bounds
Tp1 = pvget(m,'Tp1');
Tp2 = pvget(m,'Tp2');
Tp3 = pvget(m,'Tp3');
Tz = pvget(m,'Tz');
Td = pvget(m,'Td');
Tw = pvget(m,'Tw');
Zeta = pvget(m,'Zeta');
usdvtp1 = [Tp1.value;Tw.value];
usdvtp2 = [Tp2.value;Zeta.value];
usdstp1 =[Tp1.status;Tw.status];
usdstp2 =[Tp2.status;Zeta.status];
set(hand(3,2),'UserData',usdvtp1);
set(hand(3,3),'UserData',usdvtp2);
set(hand(3,4),'UserData',Tp3.value);
set(hand(3,5),'UserData',Tz.value);
set(hand(3,6),'UserData',Td.value);
set(hand(2,1),'Userdata',Kp.status);
set(hand(2,2),'UserData',usdstp1);
set(hand(2,3),'UserData',usdstp2);
set(hand(2,4),'UserData',Tp3.status);
set(hand(2,5),'UserData',Tz.status);
set(hand(2,6),'UserData',Td.status);
%min/max hand(4,*)

usd.min = Kp.min;
usd.max = Kp.max;
set(hand(4,1),'userdata',usd);
usd.min =[Tp1.min;Tw.min];
usd.max = [Tp1.max;Tw.max];
set(hand(4,2),'userdata',usd);
usd.min = [Tp2.min;Zeta.min];
usd.max  = [Tp2.max;Zeta.max];
set(hand(4,3),'userdata',usd);
usd.min = Tp3.min;
usd.max = Tp3.max;
set(hand(4,4),'userdata',usd);
usd.min = Tz.min;
usd.max = Tz.max;
set(hand(4,5),'userdata',usd);
usd.min = Td.min;
usd.max = Td.max;
set(hand(4,6),'userdata',usd);




usd2gui(hand);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [idp,estim] = gui2idp(hand)
type = get(hand(1,2),'userdata');
%m0 = idproc(type);
% Check that values are supplied for fixed variables:
estim = 0;
for pn=1:6
    stat = get(hand(2,pn),'UserData');
    if any(strcmp(stat(:),'estimate'))
        estim = 1;
    end
    val = get(hand(3,pn),'Userdata');
    inival = get(hand(7,pn),'Userdata');%%
    if any(pn==[2,3]),mp =[1,2];else mp =1;end
    for ind = mp
        fixp = strcmp(stat(ind,:),'fixed');
        fixpn = find(fixp);
        if any(fixp.*isnan(val(ind,:)))
            errordlg('A Known parameter must be given a numerical value',...
                'Error Dialog','Modal');
            idp = 'error';
            return
        end
        inival(ind,fixpn) = val(ind,fixpn);%%
        %set(hand(5,mp),'String',val,'userdata',val)%%%HEJHEJ
    end
    set(hand(7,pn),'Userdata',inival);%%
end
%K
m0.Kp.status = get(hand(2,1),'userdata');
usd = get(hand(4,1),'Userdata');
m0.Kp.min = usd.min;
m0.Kp.max = usd.max;
m0.Kp.value = get(hand(7,1),'userdata');

usds = get(hand(2,2),'userdata');

m0.tp1.status = usds(1,:);
m0.tw.status = usds(2,:);
usdmm = get(hand(4,2),'Userdata');
usdv = get(hand(7,2),'Userdata');
m0.tp1.min = usdmm.min(1,:);
m0.tp1.max = usdmm.max(1,:);
m0.tp1.value = usdv(1,:); get(hand(7,2),'userdata'); 

m0.tw.min = usdmm.min(2,:);
m0.tw.max = usdmm.max(2,:);
m0.tw.value=usdv(2,:); 
% 
%end
usds=get(hand(2,3),'userdata');
m0.tp2.status = usds(1,:);
m0.Zeta.status = usds(2,:);
usdv = get(hand(7,3),'userdata');
usdmm = get(hand(4,3),'Userdata');

m0.tp2.min = usdmm.min(1,:);
m0.tp2.max = usdmm.max(1,:);
m0.tp2.value = usdv(1,:); 
m0.Zeta.min = usdmm.min(2,:);
m0.Zeta.max = usdmm.max(2,:);
m0.Zeta.value = usdv(2,:); 

m0.tp3.status = get(hand(2,4),'userdata');
usd = get(hand(4,4),'Userdata');
m0.tp3.min = usd.min;
m0.tp3.max = usd.max;
m0.tp3.value = get(hand(7,4),'userdata');


m0.td.status = get(hand(2,6),'userdata');
usd = get(hand(4,6),'Userdata');
m0.td.min = usd.min;
m0.td.max = usd.max;
m0.td.value = get(hand(7,6),'userdata');


m0.tz.status = get(hand(2,5),'userdata');
usd = get(hand(4,5),'Userdata');
m0.tz.min = usd.min;
m0.tz.max = usd.max;
m0.tz.value = get(hand(7,5),'userdata');
try
    idp = idproc(type);
catch
    errordlg(lasterr,'Error Dialog','Modal');
end
idp = pvset(idp,'Kp',m0.Kp,'Tp1',m0.tp1,'Tp2',m0.tp2,'Tp3',m0.tp3,'Zeta',m0.Zeta,...
    'Tw',m0.tw,'Td',m0.td,'Tz',m0.tz);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55555%
function [val,wrnm] = chbound(val,h,pnr,ku);
wrnm ='';
usdbd = get(h(4,pnr),'Userdata');
pmin = usdbd.min(:,ku);
pmax = usdbd.max(:,ku);
if length(pmin)>1 % tp1/tp2
    ud = get(h(1,11),'value');
    pmin=pmin(ud);pmax=pmax(ud);
end
if val>pmax
    val = pmax;
    wrnm=['Value exceeds upper bound.'];%,'Bad value','modal');
    %set(XID.procest(3,pnr),'string',num2str(val));
end
if val<pmin
    val = pmin;
    wrnm = ['Value below lower bound.'];%'Bad value','modal');
    %set(XID.procest(3,pnr),'string',num2str(val));
end