function goto_ws=iduiss(arg,nu,ny,onoff)
%IDUISS Handles estimation of models in state-space form.
%   ARG:
%  open     Opens the dialog box
%  pem      Marks the selection of PEM option
%  ssss     Marks the selection of N4SID option
%  orders   Callback for order choice via popups
%  ordedit  Callback for order choices via edit box
%  mname    Manages the chosen model name
%  estimate Effectuates the estimation
%  qsestimate Effectuates the estimation for quickstart
%  specsel  Effectuates the estimation when structure is chosen
%                from the special order selection plot.
%  close    Closes the dialog
%
%  NU and NY are the number of inputs and outputs in the data
%  ONOFF flag for dialog visibility

%  L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.29.4.1 $ $Date: 2004/04/10 23:19:59 $


Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
warflag = strcmp(get(XID.warning,'checked'),'on');

try
    usd=get(XID.hw(3,1),'userdata');nu=usd.nu;ny=usd.ny;
catch
    [N,ny,nu] = sizedat(iduigetd('e'));
end
goto_ws=0;
if strcmp(arg,'open')
    if isempty(iduiwok(10))%~iduigetp(10,'check');
        iduistat('Opening dialog box ...')
        layout
        
        butwh=[mStdButtonWidth mStdButtonHeight];%butw=55;buth=25;
        butw=butwh(1);buth=butwh(2);
        ftb=mFrameToText;  % Frame to button
        bb = 4; % between buttons
        etf = mEdgeToFrame;
        fig=idbuildw(10); XID.plotw(10,1)=fig;
        set(fig,'units','pixels');
        FigWH=get(fig,'pos');FigWH=FigWH(3:4);
        lev1=max(0,(FigWH(2)-6*buth-5*bb)/2);
        pos = iduilay1([butw+2*ftb],6,6,lev1,bb);
        pos=pos+[(FigWH(1)-pos(1,1)-pos(1,3)-etf)*ones(7,1),zeros(7,3)];
        if strcmp(get(0,'blackandwhite'),'on'),BW=1;else BW=0;end
        s1='iduipoin(1);';s2='iduipoin(1);iduistat(''Compiling ...'');';
        s3='iduipoin(3);';
        XID.plotw(10,3)=uicontrol(fig,'pos',pos(1,:),'style','frame');
        uicontrol(fig,'Pos',pos(7,:),'style','push','callback',...
            'iduihelp(''selordss.hlp'',''Help: Choice of ARX Structure'');'...
            ,'string','Help');
        uicontrol(fig,'Pos',pos(6,:),'style','push','callback',...
            'set(gcf,''vis'',''off'');','string','Close');
        uicontrol(fig,'Pos',pos(5,:),'style','push','callback',...
            [s1,'iduiss(''specsel'');',s3],'string','Insert');
        uicontrol(fig,'pos',pos(4,:)+[0 0 -butw/2 0],'style','text',...
            'string','S.v. =','horizontalalignment','left');
        uicontrol(fig,'pos',pos(4,:)+[butw/2 0  -butw/2 0],'style','text',...
            'tag','sv','horizontalalignment','left');
        uicontrol(fig,'pos',pos(3,:),'style','edit',...
            'tag','order','horizontalalignment','left',...
            'backgroundcolor','w','callback',[s1,'iduiss(''ordsv'');',s3]);
        uicontrol(fig,'pos',pos(2,:),'style','text',...
            'string','Order','horizontalalignment','left');
        
        handl=findobj(fig,'type','uicontrol');
        set(handl,'unit','norm')
        if length(XID.layout)>9,if XID.layout(10,3)
                try
                    set(fig,'pos',XID.layout(10,1:4))
                end
            end,end
        iduistat('')
    end % end create window
    
elseif strcmp(arg,'pem')
    set(XID.ss(1,2),'value',1);
    set(XID.ss(1,5),'value',0);
    set(XID.parest(5),'enable','on');
    iduiss('mname');
    
elseif strcmp(arg,'ssss')
    set(XID.ss(1,5),'value',1);
    set(XID.ss(1,2),'value',0);
    set(XID.parest(5),'enable','off');
    try
        set(iduiwok(22),'vis','off');
    end
    iduiss('mname');
    
elseif strcmp(arg,'orders')
    na=get(XID.io(1,4),'value')-1;
    if na==12, 
        nnstr='1:10';
    elseif na==11
        nnstr='1:5';
    else
        if na==10,na=get(XID.io(1,4),'UserData');if isempty(na),na=10;end,end
        nnstr=int2str(na);
    end
    try,nks = get(XID.ss(1,8),'string');catch, nks =[];end
    if ~isempty(nks)
        pnr1 = find(nks == '[');
        pnr2 = find(nks == ']');
        if isempty(pnr1),pnr1 = 0;end
        if isempty(pnr2),pnr2 = length(nks)+1;end
        if ~isempty(nks)
            nnstr = [nnstr,' [',nks(1+pnr1:pnr2-1),']'];
        end
    end
    set(XID.parest(3),'string',nnstr);
    iduiss('mname');
elseif strcmp(arg,'ordedit')
    sl1=get(XID.parest(3),'string');
    [nn,nk,auxord,badname] = readnk(sl1,nu);
    if badname
        set(XID.parest(4),'value',6);
        iduiio('mname');
        iduims('both',6,nu,ny,0);
        return
    end
    
    if length(nn)>1&get(XID.ss(1,2),'value')
        errordlg(['The multi-model feature is available only',...
                ' for the N4SID option.'],'Error Dialog','modal');
        set(XID.parest(3),'string',int2str(min(nn)));
        %     iduiss('ssss')
    end
    set(XID.io(1,4),'value',min([nn+1,11]),'UserData',nn);
    try, set(XID.ss(1,8),'string',int2str(nk));end
    
    
elseif strcmp(arg,'mname')
    sl1=get(XID.parest(3),'string');
    nrr=find(sl1=='(');
    if ~isempty(nrr),if nrr>1,sl1=sl1(1:nrr-1);end,end
    nrr=find(sl1=='[');
    if ~isempty(nrr),if nrr>1,sl1=sl1(1:nrr-1);end,end
    
    if any(sl1==':')
        mname='';
    else
        method='n4s';
        try
            if get(XID.ss(1,2),'value')
                method='pss';
            end
        end
        badname=0;
        try
            nn=eval(['[',sl1,']']);
        catch
            badname=1;
        end
        if badname
            set(XID.parest(4),'value',6); 
            iduims('both',6,nu,ny,0);
            mname=[sl1,'c'];
        else
            mname=[method,int2str(nn)];
        end
    end 
    set(XID.parest(7),'string',mname);
elseif strcmp(arg,'estimate')
    cmdstr=['if strcmp(get(XID.parest(2),''interruptible''),''On''),',...
            'set(XID.iter(1),''pointer'',''arrow'');',...
            'end,set(XID.iter(7),''userdata'',0);'];
    eval(cmdstr,'')  %Resetting the Stop-button
    usdss='[]';
    [nn,nk,auxord,argin,text,method,badname,err,pretext] = findssn(XID,nu);
    
    XID = get(Xsum,'UserData');
    if err
        return
    end
    
    if badname, % By name
        set(XID.parest(4),'value',6);
        iduims('both',6,nu,ny,0);
        iduiio('estimate');
        return,
    end   
    eDat = iduigetd('e');
    eDat_info = iduiinfo('get',eDat);
    eDat_n = pvget(eDat,'Name');
    
    if strcmp(method,'pem')
        
        usd=get(XID.citer(1),'UserData');
        %usd = usdd{2};
        slim=usd(1,:);%deblank(usd(1,:));
        lim = eval(slim);
        if ~isempty(lim) 
            argin = [argin,{'Lim'},{lim}];
            text =[text,',''Lim'',',slim];
        end
        
        stol=usd(2,:);%deblank(usd(2,:));
        tol=eval(stol);
        if ~isempty(tol)
            argin=[argin,{'Tol'},{tol}];
            text = [text,',''Tol'',',stol];
        end
        
        smaxiter=usd(3,:);%deblank(usd(3,:));
        maxiter=eval(smaxiter);
        if ~isempty(maxiter)
            argin =[argin,{'MaxIter'},{maxiter}];
            text =[text,',''MaxIter'',',smaxiter];
        end
        
        sindex=deblank(usd(4,:));index=eval(['[',sindex,']']);
        if ~isempty(index)
            if iscell(index)
                newa = index;
                newt = sprintf(' %s',index{:});
            else
                newa = {index};
                newt = index;
            end
            argin=[argin,{'FixedP'},newa];
            text = [text,',''FixedP'',',newt];
        end
        if (2*ny+nu)*max(nn)>200
            kor = questdlg({['This model structure involves more than 200 essential',...
                        ' parameters. It will take some time to do the',...
                        ' estimation.'],'N4SID may be a better method in this case.',...
                    'Do you want to go on?',...
                    '','Push YES to carry out the calculation',...
                    'Push NO to abort.'},...
                'Question','Yes','No','No');
            switch kor
                case 'No'
                    return
                case 'Yes'
            end
        end
        was = warning;
        lastwarn('')
        warning('off')
        try
            set(XID.iter(7),'userdata',0);
            LASTM = pem(eDat,nn,argin{:}); 
            warmess = lastwarn;
            set(XID.iter(7),'userdata',LASTM,'string','Continue iter','callback',...
                'idparest(''continue'');')
        catch
            errordlg(lasterr,'Error  Using PEM','Modal')
            return
        end
%         if ~isempty(lastwarn)&warflag
%             mess = '(Warning Dialogs can be turned off under the Options Menu in the main window)';
%             warndlg({lastwarn,mess},'Warning','modal');
%         end
        warning(was);
        if isempty(LASTM),iduiinsm([]);return,end
        model=get(XID.parest(7),'string');
        mod_info=str2mat(eDat_info,pretext,...
            [model,' = pem(',eDat_n,',',int2str(nn),text,');']); 
        if ~isempty(warmess)
            mod_info = str2mat(mod_info,['Warning: ',warmess]);
        end
    else %n4sid
        if length(nn)>1
            iduiss('open');
            if isempty(iduiwok(10)),
                XID.plotw(10,1)=idbuildw(10);
            end
            XID=get(Xsum,'UserData');
            iduistat('N4SID calculates models of several orders ...')
        end   
        model = get(XID.parest(7),'string');
        [Ncap,nyutest]=sizedat(eDat);
        
        if isempty(auxord),testa=max(nn)*1.2+3;else testa=max(auxord);end
        if Ncap<(ceil(max(nn)/ny+1)+ceil((max(nn)-ny+1)/(nu+ny)))*(1+nu+ny)%1.5*ny+2.5*nu)*(max(nn)+2)+ny
            errordlg({'There are too few data points for this choice of orders.',...
                    'You need at least twice as many data as the model order.'},'Error Dialog','modal');
            iduistat('No model estimated.');
            return
        end
        if (2*ny+nu)*max(nn)>200&(get(XID.parest(19),'value')==1)
            kor = questdlg({['With this order, the calculation of covariance information',...
                        ' may take some time'],'Do you want to go on?',...
                    '','Push YES to carry out the calculation',...
                    'Push NO to abort. (Then select Covariance as ''None'' and repeat)'},...
                'Question','Yes','No','No');
            switch kor
                case 'No'
                    return
                case 'Yes'
            end
        end
        
        lastwarn('');
        was = warning;
        warning('off')
        try
            [LASTM,best_i,dum,failflag]=n4sid(eDat,nn,argin{:},'gui');
            warmess = lastwarn;
        catch
            errordlg(lasterr,'Error Dialog','modal')
            iduistat('No model estimated.');
            return
        end
%         if ~isempty(lastwarn)&warflag
%             mess = '(Warning Dialogs can be turned off under the Options Menu in the main window)';
%             warndlg(lastwarn,'Warning','modal');
%         end
        warning(was)
        if failflag==1,iduiinsm([]);return,end
        if failflag==2,
            errordlg('Too few data points for this choice of order.','Error Dialog','modal');
            iduistat('No model estimated.');
            return
        end
        if isempty(LASTM)
            figure(XID.plotw(10,1)) % Filling out the default
            V=get(XID.plotw(10,3),'userdata');
            set(findobj(gcf,'tag','sv'),'string',num2str(V(2,1)));
            set(findobj(gcf,'tag','order'),'string',int2str(V(1,1)));
            iduistat('Ready to select models.')
            iduistat('Click on bars to inspect models.',0,10);
            return
        end
        mod_info=str2mat(eDat_info,pretext,...
            [model,' = n4sid(',eDat_n,',',int2str(nn),',',text,')']);
         if ~isempty(warmess)
            mod_info = str2mat(mod_info,['Warning: ',warmess]);
        end
    end
    mod_nam=model;%[model,'_',eDat_n];
    mod_nam=mod_nam(find(mod_nam~=' '));
    LASTM = pvset(LASTM,'Name',mod_nam); 
    LASTM = iduiinfo('set',LASTM,mod_info);
    iduiinsm(LASTM);
    idgwarn(warmess,1);
    XID = get(Xsum,'UserData');
elseif strcmp(arg,'specsel')
    if nargin==1
        sord=get(findobj(XID.plotw(10,1),'tag','order'),'string');
        if isempty(sord)
            iduistat('No model selected.',0,10);
            return
        end
        err=0;
        try
            nn=eval(sord);
        catch
            err=1;
        end
        if err,
            iduistat('Order cannot be evaluated.',0,10);
            return
        end
        nn=floor(nn);
    else
        nn=get(XID.plotw(10,3),'userdata');nn=nn(1,1);
    end
    
    try
        [dum,nk] = readnk(get(XID.parest(3),'string'),nu);
    catch
        errordlg(str2mat('Cannot find the Parametric Models Window.',...
            'Please reopen it.'),'Error Dialog','modal');return
    end
    str = int2str(nn);
    if ~all(nk==1)
        str = [str,' [',int2str(nk),']'];
    end
    set(XID.parest(3),'string',str);
    
    set(XID.parest(4),'value',5); %%
    
    iduistat([int2str(nn),'th order model being estimated ...'],0,10);
    iduistat([int2str(nn),'th order model calculated using N4SID ...'])
    set(XID.plotw(10,1),'pointer','watch');
    
    iduiss('mname');
    [nn,nk,auxord,argin,text,method,badname,err] = findssn(XID,nu);
    if err
        return
    end
    eDat = iduigetd('e');
    eDat_info = iduiinfo('get',eDat);
    eDat_n = pvget(eDat,'Name');
    was = warning;
    warning off
    lastwarn('');
    [LASTM,best_i]=n4sid(eDat,nn,argin{:},'guichoice');
    warmess = lastwarn;
    warning(was)
    %      model=['n4s',int2str(nn)];
    if isempty(LASTM)
        iduistat('No model computed.')
        return
    end
    model=get(XID.parest(7),'string');
    mod_info=str2mat(eDat_info,...
        [model,' = n4sid(',eDat_n,',',int2str(nn),text,')']);
     if ~isempty(warmess)
            mod_info = str2mat(mod_info,['Warning: ',warmess]);
        end
    
    mod_nam=model;%[model,'_',eDat_n];
    mod_nam=mod_nam(find(mod_nam~=' '));
    iduistat('');
    LASTM =pvset(LASTM,'Name',mod_nam);
    LASTM = iduiinfo('set',LASTM,mod_info);
    iduiinsm(LASTM);
    iduistat('New models may now be selected.',0,10);
    idgwarn(warmess,1);
elseif strcmp(arg,'qsestimate')
    [eDat,eDat_info,eDat_n]=iduigetd('e');
    TSamp = pvget(eDat,'Ts');
    if iscell(TSamp),TSamp=TSamp{1};end
    %DKX=[0,1,0];
    was = warning;
    warning off
    lastwarn('')
    [LASTM,best_i,nn]=n4sid(eDat,'best');
    warmess = lastwarn;
    warning(was)
    model=['n4s',int2str(nn)];
    mod_info=str2mat(eDat_info,...
        [' ',model,' = n4sid(',eDat_n,',',int2str(nn),',''N4H'',[',...
            int2str(best_i),'])']); 
    mod_nam=model;
 if ~isempty(warmess)
            mod_info = str2mat(mod_info,['Warning: ',warmess]);
        end
    mod_nam=mod_nam(find(mod_nam~=' '));
    LASTM =pvset(LASTM,'Name',mod_nam); 
    LASTM =iduiinfo('set',LASTM,mod_info);
    iduiinsm(LASTM);
    idgwarn(warmess,1);
elseif strcmp(arg,'down')
    iduistat('Press Insert to estimate model or click on other bar.',0,10)
    figure(XID.plotw(10,1))
    V=get(XID.plotw(10,3),'userdata');
    [nl1,nm1]=size(V);
    vv=V(:,2:nm1);
    pt=get(gca,'currentpoint'); pp=round(pt(1,1));
    pp=max(min(vv(1,:)),pp);pp=min(max(vv(1,:)),pp);
    ind=find(vv(1,:)==pp);if isempty(ind),return,end
    sfit=num2str(vv(2,ind));
    ord=int2str(pp);
    set(findobj(gcf,'tag','sv'),'string',sfit);
    set(findobj(gcf,'tag','order'),'string',ord);
elseif strcmp(arg,'ordsv')
    figure(XID.plotw(10,1))
    V=get(XID.plotw(10,3),'userdata');
    [nl1,nm1]=size(V);
    vv=V(:,2:nm1);
    horder=findobj(XID.plotw(10,1),'tag','order');
    pp=get(horder,'string');
    err=0; 
    try
        pp=eval(pp);
    catch
        err=1;
    end
    if err,
        iduistat('Order cannot be evaluated.',0,10);
        set(horder,'string','');
        return
    end
    if length(pp)>1|length(pp)<1
        iduistat('Order must be a positive integer.',0,10);
        set(horder,'string','');
        return
    end
    if pp<min(vv(1,:))|pp>max(vv(1,:))
        err=1;
    else
        ind=find(vv(1,:)==pp);if isempty(ind),err=1;end
    end
    if err
        iduistat('This order is not an available choice.',0,10);
        set(horder,'string','');set(findobj(gcf,'tag','sv'),'string','');
        return
    end  
    sfit=num2str(vv(2,ind));
    set(findobj(gcf,'tag','sv'),'string',sfit);
    iduistat('Press Insert to compute model or select other order.',0,10);
    
end

set(Xsum,'UserData',XID);


%%%%%%%%%%%%%%%%%%%%%%%%
function [nn,nk,auxord,argin,text,method,badname,err,pretext] = findssn(XID,nu)
text =[];
nn = [];nk=[];auxord=[];
pretext = [];
argin ={};
badname = 0;
err = 0;
method = 'n4sid';
DisturbanceModel = 'Estimate';
try
    if get(XID.parest(20),'value')==1%get(XID.ss(1,6),'value')==1
        DisturbanceModel='None';
    end
end
try
    if get(XID.ss(1,2),'value')
        method='pem';
    end
end
sl1=get(XID.parest(3),'string');nnstr=sl1;
if any(sl1==':')&strcmp(method,'pem')
    errordlg(str2mat('PEM does not allow several orders.',...
        'Change the selected order.'),'Error Dialog','modal');
    iduistat('Error.');
    err = 1;
    return
end
[nn,nk,auxord,badname,err] = readnk(sl1,nu); 
if err|badname
    return
end

if length(nn)>1&length(auxord)>1
    errordlg('The order and the auxiliary order cannot both be vectors.','Error Dialog','modal');
    iduistat('Error.');
    err = 1;
    return
end
if any(nn<1)|any(floor(nn)~=nn)
    errordlg('The order must be a positive integer.','Error Dialog','modal');
    iduistat('Error.');
    err = 1;
    return
end
if ~isempty(auxord),
    if min(auxord)<max(nn+1)
        if length(auxord)>1
            auxord=auxord(find(auxord>nn));
        else
            auxord=max(nn+1);
        end
        errordlg(['N4Horizon must be larger than ORDER.',...
                '\nIt has been changed accordingly.'],'Error Dialog','modal');
    end,
end
N4weight = 'Auto';
try
    nwei = get(XID.ss(3,7),'value');
    if nwei == 2 
        N4weight = 'MOESP';
    elseif nwei == 3
        N4weight = 'CVA';
    end
catch
end
if ~strcmp(N4weight,'Auto');
    argin =[argin,{'N4weight'},{N4weight}];
    text = [text,',''N4W'',''',N4weight,''''];
end
N4H = 'Auto';
try
    N4Hs = get(XID.ss(1,7),'string');
    try
        N4H = eval(['[',N4Hs,']']);
    catch
        try
            N4H = evalin('base',N4Hs);
        catch
            errordlg(['The variable ',N4Hs,' does not exist in workspace.'],'Error Dialog','modal')
        end
    end
catch
end
if ~strcmp(N4H,'Auto');
    nauxr = size(N4H,1);
    if strcmp(method,'n4sid')& nauxr>1
        if isempty(iduiwok(11)),XID.plotw(11,1)=idbuildw(11);end
        iduistat('Models for different horizons being calculated ...')
    end   
    argin =[argin,{'N4Horizon'},{N4H}];
    text = [text,',''N4H'',',['[',N4Hs,']']];
end


if strcmp(method,'n4sid')
    iduistat('Estimating model using N4SID ...')
else
    iduistat('Estimating model by iterative search using PEM ...')
end

[eDat,eDat_info,eDat_n]=iduigetd('e');
TSamp=pvget(eDat,'Ts');
if iscell(TSamp)
    TSamp = TSamp{1};
end 
model=get(XID.parest(7),'string');
if ~all(nk==1)
    argin = [argin,{'nk'},{nk}];
    text = [text,',''nk'',',int2str(nk)];
end
if ~strcmp(DisturbanceModel,'Estimate');
    argin =[argin,{'DisturbanceModel'},{DisturbanceModel}];
    text = [text,',''DisturbanceModel'',''None'''];
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
if foc >1
    focstr = get(XID.parest(18),'string');
    foc = focstr{foc};foc = lower(foc(1:2));
    if foc == 'si'
        argin = [argin,{'Focus'},{'Sim'}];
        text = [text,',''Focus'',''Sim'''];
    elseif foc == 'st' % Stability
        argin = [argin,{'Focus'},{'Stability'}];
        text = [text,'''Focus'',''Stab''']; 
    elseif foc == 'fi'
        filt = get(XID.parest(18),'userData');
        if length(filt)<2
            errordlg('No filter selected. You must enter pass bands in the focus dialog.',...
                'Data Filter Error','modal');
            err = 1;
            return
        end
        argin = [argin,{'Focus'},filt(1)];
        pretext = '';%filt{2};
        text = [text,[',''Focus'',',filt{2}]];%{a,b,c,d}'];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nn,nk,auxord,badname,err] = readnk(sl1,nu); 
nnstr = sl1;
err = 0;
badname = 0;
auxord =[];
nn=[];
nk=[];
parnr=find(sl1=='(');
if ~isempty(parnr)
    nnstr=sl1(1:parnr-1);
    parnr2=find(sl1==')');
    if isempty(parnr2)
        errordlg('The auxiliary order must be contained in parentheses.','Error Dialog','modal');
        iduistat('Error.');
        err = 1;
        return
    end
    sauxord=sl1(parnr+1:parnr2-1);
else
    sauxord='[]';
end
auxord=eval(sauxord);
starnr = find(nnstr=='[');
if isempty(starnr)
    nk = ones(1,nu);
    nns = nnstr;
else
    pnr2 = find(nnstr==']');
    if isempty(pnr2)
        errordlg('The input delay must be enclosed in brackets: [nk].','Error Dialog','modal')
        return
    end
    
    nns = nnstr(1:starnr-1);
    try
        nk = eval(['[',nnstr(starnr+1:pnr2-1),']']);
    catch
        errordlg('The delay in the Order entry could not be evaluated.','Error Dialog','modal')
        err = 1;
    end
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
        err =1;
        return
    end
    
end
try
    nn=eval(['[',nns,']']);
catch
    badname=1;
end
