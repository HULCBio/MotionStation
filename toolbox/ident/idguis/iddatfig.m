function iddatfig(datas,figures)
%IDDATFIG Generates all view curves for ident data objects.
%   The function generates all curves associated with models DATAS
%   in viewwindows FIGURES. The handle numbers of these curves are
%   stored in the userdata of the corresponding AXES, so that row
%   number 2*K+1 of the userdata contains the handles of lines
%   associated with model number K,

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $ $Date: 2004/04/10 23:19:21 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
nnu=XID.counters(3);
sumbs=findobj(get(0,'children'),'flat','tag','sitb30');
modaxs=get(XID.sumb(1),'children');
for kk=sumbs(:)'
    modaxs=[modaxs;get(kk,'children')];
end
for Figno=figures
    figure(XID.plotw(Figno,1)),
    xusd=get(XID.plotw(Figno,1),'Userdata');
    xax=xusd(3:length(xusd));
    if isempty(get(xax(1),'children')),newplot=1;else newplot=0;end
    Opthand=XID.plotw(Figno,2);
    opt=get(Opthand,'UserData');
    hnr=findobj(XID.plotw(Figno,1),'label',menulabel('Erasemode &xor'));
    if strcmp(get(hnr,'checked'),'on')
        ermode='xor';
    else
        ermode='normal';
    end
    %ermode='normal';
    [kydes,kudes]=iduiiono('unpack',Figno);
    if any(Figno==[1,14])   % This is the time plot case
        iduistat('Preparing the time plots ...')
        stairplot=eval(deblank(opt(1,:)));
        
        for k=datas
            doplot=1;docalc=1;
            if k==0
                [data_o,data_info,data_n,hand]=iduigetd('e');
                khax=hand(1);klin=hand(2);kstr=hand(3);
                kn=k+2;
            else
                khax=findobj(modaxs,'flat','tag',['data ',int2str(k)]);
                kstr=findobj(khax,'tag','name');
                klin=findobj(khax,'tag','dataline');
                %data_info=get(kstr,'userdata');
                %data_n=get(kstr,'string');
                data_o=get(klin,'userdata');
                data_n = pvget(data_o,'Name');
                kn=k;
            end
            if isa(data_o,'idfrd')
                iduistat([data_n,' is Frequency Function Data (IDFRD)'],0,1);
                doplot = 0;
                y ={[]};
            else
                y = pvget(data_o,'OutputData');
            end
            if length(y)>1 % multiple experiments
                expnr = iduiexp('find',1,pvget(data_o,'ExperimentName'));
            else
                expnr = 1;
            end
            if ~isempty(expnr)
                y= y{expnr}; ny =size(y,2);
                if ~isa(data_o,'idfrd')
                    u = pvget(data_o,'InputData'); u = u{expnr}; 
                else
                    u =[];
                end
                nu =size(u,2);
                data=[y,u];  
                tSamp = pvget(data_o,'Ts');
            else 
                data =[]; ky =[]; ku=[];
                doplot=0;
            end
            if doplot
                tSamp = tSamp{expnr};
                dLen=length(data);
                t0 = pvget(data_o,'Tstart');t0 = t0{expnr}; 
                ky = find(strcmp(pvget(data_o,'OutputName'),kydes));
                ku = find(strcmp(pvget(data_o,'InputName'),kudes));
                if ~isempty(ku), 
                    if ku==0,
                        ku=[];
                    end
                end
                %                     else
                %                         data =[];ky=[];ku=[];
                %                     end
                %end
                if Figno==14,nnu=nu;end
                %doplot=1;
                dom = pvget(data_o,'Domain');dom=lower(dom(1));
                if Figno==1&dom=='f'
                    iduistat([data_n,' is Frequency Domain Data'],0,1);
                    doplot = 0;
                end
                if isempty(ky)|(isempty(ku)&nu>0)|(nu==0&kudes{1}~=0)
                    iduistat('Data set(s) incompatible with chosen channels.',0,Figno);
                    doplot=0;  figure(XID.plotw(Figno,1)),
                end
            end
            if doplot
                axes(xax(1))
                color=get(klin,'color');
                xusd1=get(xax(1),'userdata');
                
                if dom=='t'
                    xval = t0+tSamp*[0:dLen-1];
                    yval = data(:,ky);
                else
                    
                    xval = pvget(data_o,'SamplingInstants');
                    xval = xval{expnr};
                    yval = abs(data(:,ky));
                end
                xusd1(2*kn+1,1)=line(xval,yval,'color',color,...
                    'erasemode',ermode,'userdata',kstr);
                set(xax(1),'vis','on'),vy=axis;
                set(xax(1),'userdata',xusd1);
                plha=xusd1(2*kn+1,1);
                if Figno==1,
                    pos = idlayout('axes',1);posy =pos(1,:);
                    posyts = idlayout('axes',7);
                else
                    pos = idlayout('axes',14); posy = pos(1,:);
                    posyts = idlayout('axes',3);
                end
                if ~isempty(ku)
                    
                    set(xax(1),'pos',posy,'xticklabel',[]);
                    axes(xax(2))
                    xusd2=get(xax(2),'userdata');
                    ys=u(:,ku);
                    if dom=='f'
                        ys = abs(ys);
                    end
                    if stairplot==1
                        [xs,ys]=stairs(xval,ys);
                    else
                        xs = xval;
                    end
                    xusd2(2*kn+1,1)=line(xs,ys,'color',color,'erasemode',ermode,...
                        'userdata',kstr);
                    set(xax(2),'vis','on','userdata',xusd2)
                    haxe=[xax(1) xax(2)];
                    plha=[plha,xusd2(2*kn+1,1)];
                elseif nnu==0
                    set(xax(1),'pos',posyts,'xticklabelmode','auto');
                    axes(xax(2)),cla,
                    set(xax(2),'vis','off')
                end % if isempty(ku)
                if Figno==1,
                    usd=[idnonzer(get(khax,'userdata'));plha(:)];
                    set(khax,'userdata',usd);
                end
                if dom=='f'
                    un = pvget(data_o,'Tstart');
                    un = un{expnr};
                    
                    xlabel(['Frequency (',un,')'])
                end
            end % if doplot
            %    end
    end  % for k=dates
elseif any(Figno==[13,15])  % This is the spectral case
    iduistat('Preparing the spectral plots ...')
    isfft=eval(deblank(opt(5,:)))-1;
    W=eval(deblank(opt(4,:)));
    hz=eval(opt(3,:))-1;
    plx=eval(opt(1,:))-1;
    ply=eval(opt(2,:))-1;
    for k=datas   % k=-1 means filtered data in plot 15, k=0 is current data
        doplot=1;docalc=1;
        if any(k==[0,-1])
            [data_o,data_info,data_n,hand]=iduigetd('e','me');
            khax=hand(1);klin=hand(2);kstr=hand(3);
            if k==-1,
                khax=XID.filt(1,1);
                data_o=get(khax,'userdata');
                if isempty(data_o),return,end
            end
            kn=k+2;
        else
            khax=findobj(modaxs,'flat','tag',['data ',int2str(k)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','dataline');
            %data_info=get(kstr,'userdata');
            %data_n=get(kstr,'string');
            data_o=get(klin,'userdata');
            if isa(data_o,'idfrd')
                [ny,nu] = size(data_o);
                if nu>0
                    iduistat(['No plot for multiinput IDFRD ',pvget(data_o,'Name'),'.'],0,Figno);
                    doplot = 0;    
                end
                data_o = iddata(data_o,'me');
            end
            data_n = pvget(data_o,'Name');
            kn=k;
        end
        y=pvget(data_o,'OutputData');
        if length(y)>1 % multiple experiments
            expnr = iduiexp('find',13,pvget(data_o,'ExperimentName'));
        else
            expnr = 1;
        end
        if ~isempty(expnr)
            y = y{expnr};  
            u = pvget(data_o,'InputData');u = u{expnr};
            ny = size(y,2);
            nu = size(u,2);
            data = [y,u];
            yna = pvget(data_o,'OutputName');        
            una = pvget(data_o,'InputName');
            tSamp = pvget(data_o,'Ts');tSamp = tSamp{expnr};
            dl = size(data_o,'N');
            dl = dl(expnr);
            dom = pvget(data_o,'Domain'); dom= lower(dom(1));
            t0 = pvget(data_o,'Tstart'); t0 = t0{expnr};
            ky = find(strcmp(yna,kydes));
            ku = find(strcmp(una,kudes));
            if ~isempty(ku)&ku==0,ku=[];end
        else
            data =[];ky=[];ku=[];
        end
        
        if Figno==15,nnu=nu;end
        %doplot=1;
        if isempty(ky)|(isempty(ku)&nu>0)|(nu==0&kudes{1}~=0)
            if doplot==1
                iduistat('Data set(s) incompatible with chosen channels.',0,Figno);
            end
            doplot=0;  figure(XID.plotw(Figno,1)),
        end
        if doplot
            
            %Compute spectra
            if dom=='t'
                iduistat('Performing spectral analysis ...')
                
                if ~isfft
                    usd=get(XID.plotw(16,1),'UserData');
                    OPt=usd([2,3],:);
                    TYpe=eval((OPt(2,:)));
                    MSpa=eval((OPt(1,:)));
                    if isempty(W)
                        LW=128;
                    else
                        LW=2^nextpow2(W);
                    end
                    if isempty(MSpa)
                        %  MSpa=30;
                    end
                    if TYpe==3  % This is ETFE
                        if nu>0
                            gu=etfe(data(:,[ny+ku]),MSpa,LW,tSamp);
                            [ggwu,ggau]=getff(gu);
                        end
                        gy=etfe(data(:,ky),MSpa,LW,tSamp);
                        
                    elseif TYpe==1     % This is SPA
                        gy=spa(data(:,ky),MSpa,W,[],tSamp);
                        if nu>0
                            gu=spa(data(:,ny+ku),MSpa,W,[],tSamp);
                            [ggwu,ggau]=getff(gu);
                        end
                    else
                        gy=spafdr(iddata(data(:,ky),[],tSamp),MSpa,W);
                        if nu>0
                            gu=spafdr(iddata([],data(:,ny+ku),tSamp),MSpa,W);
                            [ggwu,ggau]=getff(gu);
                        end
                    end % if Type
                    [ggwy,ggay]=getff(gy);
                    
                else %  is fft , i.e. we do fft
                    
                    ggwy=[0:dl-1]/dl*2*pi/tSamp;kmax=floor(dl/2);
                    ggwy=ggwy(1:kmax+1)';ggwu=ggwy;
                    yf=fft(data(:,ky),dl);ggay=abs(yf(1:kmax+1)).^2*tSamp/dl;
                    if nu>0,
                        uf=fft(data(:,ny+ku),dl);ggau=abs(uf(1:kmax+1)).^2*tSamp/dl;
                    end
                end  % if isfft
            else %dom=='f'
                ggay = abs(data(:,ky));%%LL 2??
                ggau = abs(data(:,ny+ku));
                ggwy = pvget(data_o,'SamplingInstants');
                ggwy = ggwy{expnr};
                ggwu = ggwy;
                %HZ RAD/SEC??
            end
            % Plot the result
            if hz ggwy=ggwy/2/pi;hztex=' (hz)';else hztex=' (rad/s)';end
            if plx, set(xax,'Xscale','log'),else set(xax,'Xscale','linear'),end
            if ply, set(xax,'Yscale','log'),else set(xax,'Yscale','linear'),end
            if k==-1,
                [axh,texh,linh]=idnextw('data');color=get(linh,'color'); % color needed
            else
                color=get(klin,'color');
            end
            newbox1=0;newbox2=0;
            if k==0,
                set(XID.filt(5,1),'string',['Range',hztex]);
                hb=get(XID.filt(2,1),'userdata');newbox1=1;newbox2=1;
                if length(hb)>0,if ishandle(hb(1)),newbox1=0;end,end
                if length(hb)>1,if ishandle(hb(2)),newbox2=0;end,end
            end
            axes(xax(1));xusd1=get(xax(1),'userdata');
            if k==-1
                try
                    delete(xusd1(7,1))
                end
                try
                    xusd1(7,1)=xusd1(3,1);
                end
            end
            xusd1(2*kn+1,1)=line(ggwy,ggay,'color',color,'erasemode',ermode,...
                'userdata',kstr);
            if newbox1, hb(1)=line('color','g','linestyle','--','erasemode','xor',...
                    'vis','off');
            end
            set(xax(1),'vis','on','userdata',xusd1)
            handpl=xusd1(2*kn+1,1);
            if k==-1,hnrf=[xusd1(3,1),xusd1(7,1)];end
            if Figno==13,
                pos = idlayout('axes',1);posy =pos(1,:);
                posyts = idlayout('axes',7);
            else
                pos = idlayout('axes',14); posy = pos(1,:);
                posyts = idlayout('axes',3);
            end
            if ~isempty(ku)
                set(xax(1),'pos',posy,'xticklabel',[]);
                axes(xax(2));xusd2=get(xax(2),'userdata');
                if k==-1
                    try
                        delete(xusd2(7,1))
                    end
                    try
                        xusd2(7,1)=xusd2(3,1);
                    catch
                        xusd2(7,1)=-1;
                    end
                end
                if hz ggwu=ggwu/2/pi;end
                xusd2(2*kn+1,1)=line(ggwu,ggau,'color',color,'erasemode',ermode,...
                    'userdata',kstr);
                if newbox2,
                    hb(2)=line('color','g','linestyle','--','erasemode','xor',...
                        'vis','off');
                end
                set(xax(2),'vis','on','userdata',xusd2)
                haxe=[xax(1) xax(2)];
                if k==-1,hnrf=[hnrf,xusd2(3,1),xusd2(7,1)];end
                handpl=[handpl,xusd2(2*kn+1,1)];
            elseif nnu==0 % i.e. nu=0
                set(xax(1),'pos',posyts,'xticklabelmode','auto');
                axes(xax(2)),cla,
                set(xax(2),'vis','off');if k==0,hb=hb(1);end
            end  % if nu
            if k>0,usd=[idnonzer(get(khax,'userdata'));handpl(:)];
                set(khax,'userdata',usd);end
            if k==-1,set(XID.filt(3,1),'userdata',hnrf);end
            if k==0,
                set(XID.filt(2,1),'userdata',hb);
            end
        end % if doplot
    end  % for k=
elseif Figno==40   % This is the Bode Case
    iduistat('Computing Frequency functions...')
    w=eval(deblank(opt(4,:)));
    [rw,cw]=size(w);if cw>rw w=w'; rw=cw;end,if rw==0,rw=128;end
    hz=eval(opt(3,:))-1;
    plx=eval(opt(1,:))-1;
    ply=eval(opt(2,:))-1;
    for k=datas
        isconf=0;
        doplot=1;docalc=1;
        khax=findobj(modaxs,'flat','tag',['data ',int2str(k)]);
        kstr=findobj(khax,'tag','name');
        klin=findobj(khax,'tag','dataline');
        data_o=get(klin,'userdata');
        ky = find(strcmp(pvget(data_o,'OutputName'),kydes));
        ku = find(strcmp(pvget(data_o,'InputName'),kudes));
        if ~isempty(ku), 
            if ku==0,
                ku=[];
            end
        else
            data =[];ky=[];ku=[];
        end
        if isempty(ky)|isempty(ku)
            iduistat('Data set(s) incompatible with chosen channels.',0,Figno);
            doplot=0;  figure(XID.plotw(Figno,1)),
        end
        [N,ny,nu]=sizedat(data_o);
        if nu==0
            iduistat(['No plot for ',pvget(data_o,'Name'),' which has no input.'],0,Figno)
            doplot = 0;
        end
        if doplot
            if isa(data_o,'iddata')
                data_o = data_o(:,ky,ku);
            else
                data_o = data_o(ky,ku);
            end
            gc=[];
            if isa(data_o,'iddata')
                data_o =etfe(data_o);
            end
            axes(xax(1))
            xusd1=get(xax(1),'UserData');set(xax(1),'userdata',[]);
            [gga,ggp,ggw] = boderesp(data_o);
            gga = squeeze(gga); ggp = squeeze(ggp);
            if hz ggw=ggw/2/pi;end
            if plx, set(gca,'Xscale','log'),else set(gca,'Xscale','linear'),end
            if ply, set(gca,'Yscale','log'),else set(gca,'Yscale','linear'),end
            color=get(klin,'color');
            xusd1(2*k+1,1)=line(ggw,gga,'color',color,'erasemode',ermode,...
                'visible','off','userdata',kstr);
            hnr=[xusd1(2*k+1,1)];
        else
            xusd1(2*k+1,1)=-1;
        end %if doplot
        set(xax(1),'userData',xusd1);
        if doplot
            axes(xax(2))
            xusd2=get(xax(2),'UserData');set(xax(2),'userdata',[]);
            if plx, set(gca,'Xscale','log'),else set(gca,'Xscale','linear'),end
            xusd2(2*k+1,1)=line(ggw,ggp,'color',color,'erasemode',ermode,...
                'visible','off','userdata',kstr);
            hnr=[hnr,xusd2(2*k+1,1)];
            set(xax(2),'userdata',xusd2)
            usd=[idnonzer(get(khax,'userdata'));hnr(:)];
            set(khax,'userdata',usd);
            
        end %if doplot
    end % for models
end  % if Figno
end % for Figno=
iduital(Figno);
iduistat('')
