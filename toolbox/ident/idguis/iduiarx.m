function goto_ws=iduiarx(arg,nnu,nny,onoff,nustr,nystr)
%IDUIARX Handles everything about ARX estimation in the ident GUI.
%   Arguments 
%   open     Opens up the arxstruc window
%   arx,iv   Handles the corresponding radio buttons
%   orders   Handles any changes in the order popups
%   ordedit  Handles changes in the model structure edit box
%   mname    Manages the Modelname box
%   estimate Handles the estimation phase
%   specsel  Callback for ARX choices in the SELSTRUC plot
%   comp     Callback for the best choice with given number of pars
%   close    Closes the dialog box

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.30.4.1 $ $Date: 2004/04/10 23:19:31 $

nongui=0;

try
    Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
    XID = get(Xsum,'Userdata');
    e=iduigetd('e');ts=pvget(e,'Ts');if iscell(ts),ts=ts{1};end
    
    usd=get(XID.hw(3,1),'userdata');
    nu=usd.nu;ny=usd.ny;
    warflag = strcmp(get(XID.warning,'checked'),'on');
    
catch
    Xsum =[];
    warflag = 1;
    ts = 1;
end
if strcmp(arg,'open')
    V=nnu;
    nr =size(V,1);
    if rem(nr-2,2)
        V = V(1:end-1,:);
    end
    
    nu = floor((size(V,1)-2)/2);
    
    if isempty(iduiwok(9))
        iduistat('Opening plot window ...')
        layout
        
        butwh=[mStdButtonWidth mStdButtonHeight];
        butw=butwh(1);buth=butwh(2);
        ftb=mFrameToText;  % Frame to button
        bb = 4; % between buttons
        etf = mEdgeToFrame;
        nongui = 0;
        if isempty(Xsum)
            Xsum=figure('pos',[10 10 10 10],'tag','sitb16','name','FAKE','vis','off');
            nongui = 1;
            set(0,'showhiddenhandles','on')
            set(Xsum,'closerequestfcn','delete(gcf);delete(findobj(0,''tag'',''sitb9''))')
        end
        fig=idbuildw(9); XID.plotw(9,1)=fig;
        XID = get(Xsum,'UserData');
        if nongui
            set(fig,'HandleVisibility','on');
            set(0,'showhiddenhandles','off')
        end
        %set(Xsum,'UserData',XID);
        set(fig,'units','pixels');
        FigWH=get(fig,'pos');FigWH=FigWH(3:4);
        lev1=max(0,(FigWH(2)-9*buth-8*bb)/2);
        pos = iduilay1([butw+2*ftb],9,9,lev1,bb);
        pos=pos+[(FigWH(1)-pos(1,1)-pos(1,3)-etf)*ones(10,1),zeros(10,3)];
        if strcmp(get(0,'blackandwhite'),'on'),BW=1;else BW=0;end
        s1='iduipoin(1);';
        s3='iduipoin(3);';
        uicontrol(fig,'pos',pos(1,:),'style','frame');
        uicontrol(fig,'Pos',pos(10,:),'style','push','callback',...
            'iduihelp(''selordax.hlp'',''Help: Choice of ARX Structure'');'...
            ,'string','Help');
        if nongui
            uicontrol(fig,'Pos',pos(9,:),'style','push','callback',...
                'iduiarx(''close_NG'');','string','Close');
        else
            uicontrol(fig,'Pos',pos(9,:),'style','push','callback',...
                'set(gcf,''vis'',''off'');','string','Close');
            
        end
        if nongui
            uicontrol(fig,'Pos',pos(8,:),'style','push','callback',...
                [s1,'iduiarx(''insert_NG'');',s3],'string','Select',...
                'Tooltip','Make choice and then hit ''Return'' in command window.');
        else
            uicontrol(fig,'Pos',pos(8,:),'style','push','callback',...
                [s1,'iduiarx(''insert'');',s3],'string','Insert');
        end
        
        uicontrol(fig,'pos',pos(7,:)+[0 0 -2*butw/3 0],'style','text',...
            'string','nk=','horizontalalignment','right');
        uicontrol(fig,'pos',pos(7,:)+[butw/3 0  -butw/3 0],'style','text',...
            'tag','nk','horizontalalignment','left');
        uicontrol(fig,'pos',pos(6,:)+[0 0 -2*butw/3 0],'style','text',...
            'string','nb=','horizontalalignment','right');
        uicontrol(fig,'pos',pos(6,:)+[butw/3 0  -butw/3 0],'style','text',...
            'tag','nb','horizontalalignment','left');
        uicontrol(fig,'pos',pos(5,:)+[0 0 -2*butw/3 0],'style','text',...
            'string','na=','horizontalalignment','right');
        uicontrol(fig,'pos',pos(5,:)+[butw/3 0  -butw/3 0],'style','text',...
            'tag','na','horizontalalignment','left');
        uicontrol(fig,'pos',pos(4,:)+[0 0 -1.8*butw/3 0],'style','text',...
            'string','Misfit=','horizontalalignment','left');
        uicontrol(fig,'pos',pos(4,:)+[butw/3 0 -butw/3 0],'style','text',...
            'tag','fit','horizontalalignment','left');
        uicontrol(fig,'pos',pos(3,:),'style','edit',...
            'string','','backgroundcolor','w','Horizontalalignment','left',...
            'callback',[s1,'iduiarx(''comp'');',s3],'tag','nupar');
        uicontrol(fig,'pos',pos(2,:),'style','text',...
            'string','Number of par''s','HorizontalAlignment','left');
        
        handl=findobj(fig,'type','uicontrol');
        set(handl,'unit','norm')
        try
            if length(XID.layout)>8,
                if XID.layout(9,3)
                    try
                        set(fig,'pos',XID.layout(9,1:4));
                    end
                end
            end
        catch
        end
        if nongui
            set(fig,'CloseRequestfcn','delete(gcf),delete(findobj(0,''name'',''FAKE''))')
        end
    end % end create window
    % Plot data
    [nl1,nm1]=size(V);
    zvnorm=V(2,nm1);
    
    if nu>0,sv=sum(V(2:2+nu,1:nm1-1));else sv=V(2,1:nm1-1);end %Cor 9007
    vv=V(1,1:nm1-1);bestfit=min(vv);
    kt=((2+2*nu)==nl1);
    Ind=[];
    nopar=min(sv):max(sv);
    msv=min(sv);
    y=zeros(size(nopar));
    for kk=nopar
        inx=find(sv==kk);
        if ~isempty(inx)
            [mv,index]=min(vv(inx));Ind=[Ind,inx(index)];
            y(kk-msv+1)=100*mv/zvnorm;
        else
            y(kk-msv+1)=0;
        end
    end
    figure(XID.plotw(9,1));
    V=[[V(:,Ind);sv(Ind)],[V(:,nm1);0]];sv=sv(Ind);vv=vv(Ind);
    
    handax=get(XID.plotw(9,1),'Userdata');
    set(handax(3),'vis','off'),axes(handax(3)),cla,axis('auto')
    set(XID.plotw(9,3),'userdata',V)
    axsv=[min(sv)-1 max(sv)+1];
    [dum,dum,dum,xx,yy]=makebars(nopar,y);
    barbottom=floor(10*bestfit/zvnorm)*10;
    %if barbottom==0,barbottom=-1;end
    zer=find(yy==0);
    yy(zer)=barbottom*ones(size(zer));
    line(xx,yy,'color','y');
    nndef=selstruc(V,0);
    nnaic=selstruc(V,'aic');
    nnmdl=selstruc(V,'mdl');
    ndef=sum(nndef(1:1+nu))-msv+1;naic=sum(nnaic(1:1+nu))-msv+1;
    nmdl=sum(nnmdl(1:1+nu))-msv+1;
    if nmdl>1,
        patch(xx(1:5*nmdl-3),yy(1:5*nmdl-3),'y');
    end
    patch(xx(5*nmdl-3:5*nmdl),yy(5*nmdl-3:5*nmdl),'g');
    if naic>nmdl+1
        patch(xx(5*nmdl:5*naic-3),yy(5*nmdl:5*naic-3),'y');
    end
    patch(xx(5*naic-3:5*naic),yy(5*naic-3:5*naic),'b');
    if ndef>naic+1
        patch(xx(5*naic:5*ndef-3),yy(5*naic:5*ndef-3),'y');
    end
    patch(xx(5*ndef-3:5*ndef),yy(5*ndef-3:5*ndef),'r');
    nxx=length(xx);
    if 5*ndef<nxx
        patch(xx(5*ndef:nxx),yy(5*ndef:nxx),'y');
    end
    set(handax(3),'vis','on')
    yl=get(handax(3),'ylim');ylen=length(y);ym=max(y(ceil(ylen/3):ylen));
    if ym>0.6*yl(2)
        set(handax(3),'ylim',[yl(1) ym/0.55])
    end
    iduital(9);
    if nmdl==ndef
        colm='Red: ';
    elseif nmdl==naic
        colm='Blue: ';
    else
        colm='Green: ';
    end
    if naic==ndef
        cola='Red: ';
    else
        cola='Blue: ';
    end
    text(0.97,0.75,'Red: Best Fit','units','norm','fontsize',10,...
        'Horizontalalignment','right')
    text(0.97,0.85,[cola,'AIC Choice'],'units','norm','fontsize',10,...
        'Horizontalalignment','right')
    text(0.97,0.95,[colm,'MDL Choice'],'units','norm','fontsize',10,...
        'Horizontalalignment','right')
    set(XID.plotw(9,1),'vis','on')
    set(findobj(XID.plotw(9,1),'tag','nupar'),'string',...
        int2str(sum(nndef(1:1+nu))));
    iduiarx('comp')
    if nongui
        set(XID.plotw(9,1),'handlevis','callback')
        set(Xsum,'handlevis','callback');
    end
elseif strcmp(arg,'arx')
    set(XID.arx(1,2),'value',1);
    set(XID.arx(1,5),'value',0);
    iduiarx('mname');
elseif strcmp(arg,'iv')
    set(XID.arx(1,5),'value',1);
    set(XID.arx(1,2),'value',0);
    iduiarx('mname');
elseif strcmp(arg,'orders')
    
    if ny>1
        na=get(XID.io(1,4),'value')-1;
        if nu>0
            nb=get(XID.io(1,1),'value')-1;
            nk=get(XID.io(1,3),'value')-1;
            nys=int2str(ny);nus=int2str(nu);
            nnstr=['[',int2str(na),'*ones(',nys,',',nys,') ',...
                    int2str(nb),'*ones(',...
                    nys,',',nus,') ',int2str(nk),'*ones(',nys,',',nus,')]'];
        else
            nys=int2str(ny);nus=int2str(nu);
            nnstr=['[',int2str(na),'*ones(',nys,',',nys,')]'];
        end     
        set(XID.parest(3),'string',nnstr);
        iduiarx('mname');
        return
    end
    XID = get(Xsum,'UserData');
    na=get(XID.io(1,4),'value')-1;
    if na==10,
        na=get(XID.io(1,4),'UserData');
        if isempty(na),na=10;end
        nnstr=int2str(na);
    elseif na==11
        nnstr='1:5';
    elseif na==12
        nnstr='1:10';
    else
        nnstr=int2str(na);
    end
    if nu>1
        nnstr=[nnstr,' ['];
        if ts>0,nkstr='[';else nkstr='';end
    else 
        nnstr=[nnstr,' '];nkstr=' ';
    end
    for ku1=1:nu
        if nu>3
            ku = 1;
        else
            ku = ku1;
        end
        
        nb=get(XID.io(ku,1),'value')-1;
        if nb==10
            nb=get(XID.io(ku,1),'UserData');
            if isempty(nb),nb=10;end
            nbstr=int2str(nb);
        elseif nb==11
            nbstr='1:5';
        elseif nb==12
            nbstr='1:10';
        else
            nbstr=int2str(nb);
        end
        if ts>0
            nk=get(XID.io(ku,3),'value')-1;
            if nk==10
                nk=get(XID.io(ku,3),'UserData');
                if isempty(nk),nk=10;end
                nkstrt=int2str(nk);
                
            elseif nk==11
                nkstrt='1:5';
            elseif nk==12
                nkstrt='1:10';
            else
                nkstrt=int2str(nk);
            end
        else
            nkstrt='';
        end
        nbv(ku)=nb;
        if ts>0,nkv(ku)=nk;end
        nnstr=[nnstr,' ',nbstr];nkstr=[nkstr,' ',nkstrt];
    end
    if nu>1,
        if ts>0,nnstr=[nnstr,'] ',nkstr,']'];
        else
            nnstr=[nnstr,']'];
        end
    else nnstr=[nnstr,nkstr];end
    set(XID.parest(3),'string',nnstr);
    iduiarx('mname');
elseif strcmp(arg,'ordedit')
    
    sl1=get(XID.parest(3),'string');
    if ~any(sl1==':'),
        stopp=0;
        
        eval('nn=eval([''['',sl1,'']'']);','stopp=1;');
        if stopp,iduiarx('mname');return,end
        [nnr,nnc]=size(nn);
        if ts==0,corrord=ny+nu;else corrord=ny+2*nu;end
        if nnc~=corrord|nnr~=ny
            errordlg('Incorrect number of orders specified.','Error Dialog','modal');
        else   
            na=nn(1,1);nb=nn(1,2:nu+1);
            if ts>0,nk=nn(1,nu+2:2*nu+1);end
            if nu>4|ny>1,nmu=min(1,nu);else nmu=nu;end
            set(XID.io(1,4),'value',min(na+1,11),'UserData',na);
            for ku=1:nmu
                set(XID.io(ku,1),'value',min(nb(ku)+1,11),'UserData',nb(ku));
                if ts>0,set(XID.io(ku,3),'value',min(nk(ku)+1,11),'UserData',nk(ku));end
            end
        end
    end
elseif strcmp(arg,'mname')
    method='arx';
    eval('if get(XID.arx(1,2),''value'')==0,method=''iv'';end','')
    goto_ws=0;
    sl1=get(XID.parest(3),'string');
    if any(sl1==':')
        mname='';
    else
        eval('nn=eval([''['',sl1,'']'']);','goto_ws=1;');
        if goto_ws==0
            if ts==0,corrord=ny+nu;else corrord=ny+2*nu;end
            
            if length(nn)~=corrord
                errordlg('Incorrect number of orders specified.','Error Dialog','modal');
                goto_ws=1;return
            end
            if nu==0
                ordstr=int2str(nn(1,1));
            elseif ts>0
                ordstr=[int2str(nn(1,1)),int2str(nn(1,ny+1)),...
                        int2str(nn(1,ny+nu+1))];
            else
                ordstr=[int2str(nn(1,1)),int2str(nn(1,ny+1))];
            end
            mname=[method,ordstr];
        else
            mname=sl1;
        end
    end
    set(XID.parest(7),'string',mname)
    
elseif strcmp(arg,'estimate')
    method='arx';
    try
        if get(XID.arx(1,2),'value')==0,
            method='iv';
        end
    end
    if nargin==3,nn=nnu;modn=nny;elseif nargin==2,nn=nnu;end
    goto_ws=0;
    if nargin==1
        sl1=get(XID.parest(3),'string');
        if any(sl1==':')
            if ny>1,
                errordlg(['The model structure selection feature ',...
                        'is not supported for multi-output systems.'],'Error Dialog','modal');
                return
            end % in ny>1
            NN=idarxstr(sl1);
            if isempty(NN)
                errordlg(['Orders cannot be evaluated.',...
                        '\nPlease check expression in Orders: edit field.'],'Error Dialog','modal');
                return
            end
            [nrNN,ncNN]=size(NN);
            [eDat,eDat_info]=iduigetd('e','me');
            [vDat,vDat_info]=iduigetd('v','me');
            kus=pvget(eDat,'InputName');  
            kys=pvget(eDat,'OutputName');  
            vDatc=vDat(:,kys,kus); %funkar ej f?r idfrd, inte heller forts
            [N,nye,nue] = size(eDat);
            [N,nyv,nuv] = size(vDatc);
            if ~(nye==nyv&nue==nuv)  
                errordlg(['The validation data do not contain ',...
                        'the inputs and outputs of the estimation data.'],'Error Dialog','modal');
                return
            end % if flag ..
            
            time=nrNN*XID.counters(6)/2.5;
            if time>60,
                exstr=['. (Could take some ',int2str(ceil(time/10)*10),' s)'];
            else
                exstr=' ...';
            end
            iduistat(['Computing all ',int2str(nrNN),' models',exstr])
            if ncNN~=ny+2*nu  % Then we make a forgiving interpretation
                NN=[NN(:,1),NN(:,2)*ones(1,nu),NN(:,ncNN)*ones(1,nu)];
            end
            if ~strcmp(pvget(eDat,'Domain'),pvget(vDatc,'Domain'))
                errordlg(['For Order selection to work, the Working and Validation Data',...
                    ' have to be the same domain (time or frequency).'],'Error Dialog',...
                'Modal')
            return
        end
            tic,V=arxstruc(eDat,vDatc,NN);etime=toc;
            if time>60,
                XID.counters(6)=etime*2.5/nrNN;
                set(Xsum,'UserData',XID);
            end
            iduiarx('open',V);
            iduistat('Ready to select models.')
            iduistat('Click on bars to inspect models.',0,9);
            return
        else  
            eval('nn=eval([''['',sl1,'']'']);','goto_ws=1;');
        end  % if any :
    end  % if nargin==1
    if goto_ws,return,end
    [nnr,nnc]=size(nn);
    if ts==0,corrord=ny+nu;else corrord=ny+2*nu;end
    
    if nnr~=ny|nnc~=corrord
        errordlg('Incorrect number of orders specified.','Error Dialog','modal');
    elseif any(nn<0)
        errordlg('No order or delay can be negative.','Error Dialog','modal');
    else   
        [eDat,eDat_info,eDat_n]=iduigetd('e',1);
        TSamp = pvget(eDat,'Ts');TSamp=TSamp{1};%eval(eDat_info(1,:));
        
        for sky1=1:ny
            nastrr=[];nbstrr=[];nkstrr=[];
            for sky2=1:ny
                nastrr=[nastrr,' ',int2str(nn(sky1,sky2))];
            end
            for sky2=1:nu
                nbstrr=[nbstrr,' ',int2str(nn(sky1,sky2+ny))];
                if ts>0
                    nkstrr=[nkstrr,' ',int2str(nn(sky1,sky2+ny+nu))];
                else
                    nkstrr='';
                end
            end
            if sky1==1,
                nastr=[' na = [',nastrr,']'];
                nbstr=[' nb = [',nbstrr,']'];
                nkstr=[' nk = [',nkstrr,']'];          
            else 
                nastr=str2mat(nastr,['         [',nastrr,']']);
                nbstr=str2mat(nbstr,['         [',nbstrr,']']);
                nkstr=str2mat(nkstr,['         [',nkstrr,']']);
            end
        end
        if nu==0
            ordstr=int2str(nn(1,1));ordstr2=ordstr;
        else
            if ts>0
                ordstr=[int2str(nn(1,1)),int2str(nn(1,ny+1)),int2str(nn(1,ny+nu+1))];
                ordstr2=[int2str(nn(1,1)),' ',int2str(nn(1,ny+1)),' ',...
                        int2str(nn(1,ny+nu+1))];
            else
                ordstr=[int2str(nn(1,1)),int2str(nn(1,ny+1))];
                ordstr2=[int2str(nn(1,1)),' ',int2str(nn(1,ny+1)),' ',];%...
                % int2str(nn(1,ny+nu+1))];
            end
        end
        iduistat('Computing the ARX model ...')
        if nargin<3,model=get(XID.parest(7),'string');else model=modn;end
        argin={};pretext = [];text1 = [];
        try
            focval = get(XID.parest(18),'value');
        catch
            focval = 1;
        end
        try
            cov = get(XID.parest(19),'Value');
        catch
            cov = 1;
        end
        
        if cov == 2 % no covariance
            argin = [argin,{'Cov'},{'None'}];
            text1 = [text1,'''Cov'',''None'''];
        end
        if focval >1
            focstr = get(XID.parest(18),'string');
            foc = focstr{focval};foc = lower(foc(1:2));
            
            if foc == 'si' % simulate
                argin = [argin,{'Focus'},{'Simulation'}];
                text1 = [text1,'''Focus'',''Sim'''];
            elseif foc == 'st' % Stability
                argin = [argin,{'Focus'},{'Stability'}];
                text1 = [text1,'''Focus'',''Stab''']; 
            elseif foc == 'fi'
                filtinfo = get(XID.parest(18),'UserData');
                if isempty(filtinfo)
                    errordlg(['The filter has not been computed. You must enter pass bands in the focus dialog and push',...
                            ' ''Estimate'' again.'],'Error Dialog','modal');
                    set(0,'Showhiddenhandles','off');
                    return
                end
                filt = filtinfo{1};
                
                pretext = '';%filtinfo{2};
                if ~isa(filt,'double')
                    [a,b,c,d]=ssdata(filt);
                    filt={a,b,c,d};
                end
                argin = [argin,{'Focus'},{filt}];
                text1 = [text1,['''Focus'',',filtinfo{2}]];%{a,b,c,d}']; 
            end
        end 
        if ts==0&(any(nn(2:end)-nn(1)>1))
            errordlg({'The demanded model is non-proper (numerator degree',...
                    ' larger than  denominator degree). Such modele are not',...
                    ' handled by the GUI.'})
            return
        end
         was = warning;
            lastwarn('');
            warning('off');
        if strcmp(method,'arx')
             try
                LASTM=arx(eDat,nn,argin{:});
                warmess = lastwarn;
            catch
                errordlg(lasterr,'Error Dialog','Modal')
                return
            end
%             if ~isempty(lastwarn)&warflag
%                 mess = '(Warning Dialogs can be turned off under the Options Menu in the main window)';
%                 warndlg({lastwarn,mess},'Warning','modal')
%             end
            warning(was);
            if ny==1&nu<2
                mod_info=str2mat(eDat_info,pretext,[' ',model,' = arx(',eDat_n,',[',...
                        ordstr2,'],',text1,')']);%[],',...
                %num2str(TSamp),')']);
            else
                mod_info=str2mat(eDat_info,pretext,nastr,nbstr,nkstr,...
                    [' ',model,' = arx(',eDat_n,',[na,nb,nk],',...%[],',...
                        text1,')']);
            end
        else
            if nu>0
                LASTM=iv4(eDat,nn,argin{:});
                meth=' = iv4(';exarg=[];
            else
                LASTM=ivar(eDat,nn);
                meth=' = ivar(';exarg='[],';
            end
            warmess = lastwarn;
            warning(was);
            if ny==1&nu<2
                mod_info=str2mat(eDat_info,pretext,[' ',model,meth,eDat_n,',[',...
                        ordstr2,'],',text1,')']); 
            else
                mod_info=str2mat(eDat_info,pretext,nastr,nbstr,nkstr,...
                    [' ',model,meth,eDat_n,',[na,nb,nk],[],',text1,')']);
            end
        end
         if ~isempty(warmess)
            mod_info = str2mat(mod_info,['Warning: ',warmess]);
        end
        mod_nam=model;
        mod_nam=mod_nam(find(mod_nam~=' '));
        LASTM =pvset(LASTM,'Name',mod_nam);
        LASTM = iduiinfo('set',LASTM,mod_info);
        iduiinsm(LASTM);
        idgwarn(warmess,1);
        XID = get(Xsum,'UserData');
        
    end
elseif strcmp(arg,'comp')
    figure(XID.plotw(9,1))
    V=get(XID.plotw(9,3),'userdata');
    [nl1,nm1]=size(V);
    nu=floor((nl1-3)/2);
    Nc=V(1,nm1);
    pp=eval(get(findobj(XID.plotw(9,1),'tag','nupar'),'string'),'-1');
    if pp<min(V(nl1,:))|pp>max(V(nl1,:))
        sfit='';sna='';snb='';snk='';
        iduistat('This number of parameters is not available.',0,9);
    else
        ind=find(V(nl1,:)==pp);
        if isempty(ind),
            sfit='';sna='';snb='';snk='';
        else
            nn=V(2:2+2*nu,ind);
            sfit=num2str(V(1,ind)/V(2,end)*100);
            sna=int2str(nn(1));
            snb='';snk='';
            for ku=1:nu
                snb=[snb,int2str(nn(1+ku)),' '];
                snk=[snk,int2str(nn(nu+1+ku)),' '];
            end
        end
        if ~isempty(findobj(gcf,'String','Insert'))
            iduistat('Press Insert to compute model or select other structure.',0,9);
        else
            iduistat('Inspect models by clicking bars or press SELECT.',0,9);
        end  
    end
    set(findobj(gcf,'tag','fit'),'string',sfit);
    set(findobj(gcf,'tag','na'),'string',sna);
    set(findobj(gcf,'tag','nb'),'string',snb);
    set(findobj(gcf,'tag','nk'),'string',snk);
elseif strcmp(arg,'down')
    cf=XID.plotw(9,1);
    figure(cf)
    V=get(XID.plotw(9,3),'userdata');
    [nl1,nm1]=size(V);
    nu=floor((nl1-3)/2);
    Nc=V(1,nm1);
    pt=get(gca,'currentpoint'); pp=round(pt(1,1));
    pp=max(min(V(nl1,1:nm1-1)),pp);pp=min(max(V(nl1,1:nm1-1)),pp);
    ind=find(V(nl1,:)==pp);
    if isempty(ind),
        sfit='';sna='';snb='';snk='';spp='';
    else
        nn=V(2:2+2*nu,ind);
        sfit=num2str(V(1,ind)/V(2,end)*100);
        sna=int2str(nn(1));spp=int2str(pp);
        snb='';snk='';
        for ku=1:nu
            snb=[snb,int2str(nn(1+ku)),' '];
            snk=[snk,int2str(nn(nu+1+ku)),' '];
        end
    end
    set(findobj(cf,'tag','fit'),'string',sfit);
    set(findobj(cf,'tag','na'),'string',sna);
    set(findobj(cf,'tag','nb'),'string',snb);
    set(findobj(cf,'tag','nk'),'string',snk);
    set(findobj(cf,'tag','nupar'),'string',spp);
    if ~isempty(findobj(gcf,'String','Insert'))
        iduistat('Press Insert to estimate model, or click on other bar.',0,9);
    else
        iduistat('Click other bar or press SELECT.',0,9);
    end
    
elseif strcmp(arg,'insert')
    na=get(findobj(gcf,'tag','na'),'string');
    if isempty(na),
        iduistat('No model selected.',0,9);
        return
    end
    nb=get(findobj(gcf,'tag','nb'),'string');
    nk=get(findobj(gcf,'tag','nk'),'string');
    err=0;
    eval('set(XID.parest(3),''string'',[na,'' '',nb,nk]);','err=1;')
    if err
        errordlg(['Cannot find the Parametric Models Window.',...
                '\nPlease reopen it.'],'Error Dialog','modal');return
    end
    set(XID.parest(4),'value',1);
    iduistat('Model being computed ...',0,9);
    iduiarx('mname');
    iduiarx('estimate');
    iduistat('New models may now be selected.',0,9);
elseif strcmp(arg,'insert_NG')
    na=get(findobj(gcf,'tag','na'),'string');
    if isempty(na),
        iduistat('No model selected.',0,9);
        return
    end
    nb=get(findobj(gcf,'tag','nb'),'string');
    nk=get(findobj(gcf,'tag','nk'),'string');
    err=0;
    na = eval(na); 
    if ~isempty(nb)
        nb = eval(nb); nk = eval(nk);
    else
        nb = [];nk = [];
    end
    
    assignin('base','xxxnn', [na nb nk]);
    iduistat('Hit ''Return'' in command window.',0,9);
    %disp(sprintf('\n'))
    %iduiarx('close_NG')
    %    
    %    try
    %       set(XID.parest(3),'string',[na,' ',nb,nk]);
    %    end
    %    iduistat('New orders may now be selected, but nn will be overwritten.',0,9);
    
elseif strcmp(arg,'close')
    set(XID.mse(1),'Visible','off')
elseif strcmp(arg,'close_NG')
    onoff = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on')
    delete(findobj(0,'tag','sitb9'))
    delete(findobj(0,'name','FAKE'));
    set(0,'showhiddenhandles',onoff)
end

