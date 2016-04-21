function idgenfig(models,figures)
%IDGENFIG Generates all view curves for ident.
%   The function generates all curves associated with models MODELS
%   in view windows FIGURES. The handle numbers of these curves are
%   stored in the userdata of the corresponding axes, so that row
%   number 2*K+1 of the userdata contains the handles of lines
%   associated with model number K, while row 2*K+2 contains the
%   corresponding confidence interval lines

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.33.4.1 $  $Date: 2004/04/10 23:19:23 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
XIDplotw = XID.plotw;
XIDsumb = XID.sumb;
warflag = strcmp(get(XID.warning,'checked'),'on');
hnr=[]; gc=[];

Plotcolors=idlayout('plotcol');
textcolor=Plotcolors(6,:);  %To be used for validation data and outlines

sumbs=findobj(get(0,'children'),'flat','tag','sitb30');
modaxs=get(XIDsumb(1),'children');
for kk=sumbs(:)'
    modaxs=[modaxs;get(kk,'children')];
end
chmess='Model(s) incompatible with chosen channels.';
chmess2='Model(s) incompatible with chosen channel.';
 lastwarn('');
                    was = warning;
                    warning('off')
for Figno=figures
    hsd=findobj(XIDplotw(Figno,1),'tag','confonoff');
    SD=get(hsd,'Userdata');
    figure(XIDplotw(Figno,1)),
    xusd=get(XIDplotw(Figno,1),'Userdata');
    xax=xusd(3:length(xusd));
    if isempty(get(xax(1),'children')),newplot=1;else newplot=0;end %%LL
    Opthand=XIDplotw(Figno,2);
    opt=get(Opthand,'UserData');
    hnrxor=findobj(XIDplotw(Figno,1),'label',menulabel('Erasemode &xor'));
    if strcmp(get(hnrxor,'checked'),'on')
        ermode='xor';
    else
        ermode='normal';
    end
    %ermode='normal';
    [kydes,kudes]=iduiiono('unpack',Figno);
    if Figno==2   % This is the Bode Case
        iduistat('Computing Frequency functions...')
        w=eval(deblank(opt(4,:)));
        [rw,cw]=size(w);if cw>rw w=w'; rw=cw;end,if rw==0,rw=128;end
        hz=eval(opt(3,:))-1;
        plx=eval(opt(1,:))-1;
        ply=eval(opt(2,:))-1;
        for k=models
            isconf=1;
            doplot=1;docalc=1;
            khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            
            if nu==0&~(isempty(ku)|isempty(ku))
                errordlg(['The model ',name,' is a time series model.',...
                        '\nUse ''Noise spectrum'' instead of the frequency plot.'],'Error Dialog','modal');
                docalc=0;doplot=0;
                figure(XIDplotw(Figno,1)),
            elseif isempty(ku)|isempty(ky)
                iduistat(chmess,0,Figno);
                docalc=0;doplot=0;  figure(XIDplotw(Figno,1)),
            end
            gc=[];
            if docalc
                nam = 'dum';
                if isa(model,'nlwh') %%NLModels
                    model = pvget(model,'LinearModel');
                elseif isa(model,'nlarx')
                    iduistat('No frequency response for NLARX model.',0,Figno);
                    doplot=0;
                end
                if isa(model,'idfrd') 
                    gc=model; 
                    es = pvget(gc,'EstimationInfo');
                    nam = 'spa';
                    if strcmp(lower(es.Method),'etfe')
                        isconf = 0;
                    end
                    [ggw,gga,ggp,ggsda,ggsdp]=getff(gc,ku,ky);
                elseif ~isaimp(model) 
                    [gga,ggp,ggw,ggsda,ggsdp]=boderesp(model,w);
                    gga=squeeze(gga(ky,ku,:));
                    ggp=squeeze(ggp(ky,ku,:));
                    if ~isempty(ggsda), 
                        ggsda=squeeze(ggsda(ky,ku,:));
                        if norm(ggsda)==0
                            isconf = 0;
                        end
                    else
                        isconf = 0;
                    end
                    if ~isempty(ggsdp),
                        ggsdp=squeeze(ggsdp(ky,ku,:));
                    end
                else
                    iduistat('No frequency response for IMPULSE RESPONSE model.',0,Figno);
                    doplot=0;
                end
            end %if docalc
            axes(xax(1))
            xusd1=get(xax(1),'UserData');set(xax(1),'userdata',[]);
            if doplot
                
                if isempty(ggsda),isconf=0;end
                if hz ggw=ggw/2/pi;end
                if plx, set(gca,'Xscale','log'),else set(gca,'Xscale','linear'),end
                if ply, set(gca,'Yscale','log'),else set(gca,'Yscale','linear'),end
                color=get(klin,'color');
                xusd1(2*k+1,1)=line(ggw,gga,'color',color,'erasemode',ermode,...
                    'visible','off','userdata',kstr);
                hnr=[xusd1(2*k+1,1)];
                if isconf
                    xusd1(2*k+2,1:2)=line([ggw ggw],[gga+SD*ggsda max(gga-SD*ggsda,0)],...
                        'color',color,'linestyle','-.','erasemode',ermode,...
                        'Visible','off','userdata',kstr,'tag','conf')';
                    hnr=[hnr,xusd1(2*k+2,1:2)];
                else
                    
                    if nam(1:3)=='spa'
                        noconf=-2;
                    else
                        noconf=-1;
                    end
                    xusd1(2*k+2,1:2)=[noconf,noconf];
                end
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
                if isconf
                    xusd2(2*k+2,1:2)=line([ggw ggw],[ggp+SD*ggsdp ggp-SD*ggsdp],...
                        'color',color,'linestyle','-.','erasemode',ermode,...
                        'Visible','off','userdata',kstr,'tag','conf')';
                    hnr=[hnr,xusd2(2*k+2,1:2)];
                else
                    if nam(1:3)=='spa'
                        noconf=-2;
                    else
                        noconf=-1;
                    end
                    xusd2(2*k+2,1:2)=[noconf,noconf];
                end
                set(xax(2),'userdata',xusd2)
                usd=[idnonzer(get(khax,'userdata'));hnr(:)];
                set(khax,'userdata',usd);
                
            end %if doplot
        end % for models
    elseif Figno==7,   % This is the Spectrum Case
        iduistat('Computing Spectra...')
        w=eval(deblank(opt(4,:)));
        [rw,cw]=size(w);if cw>rw w=w'; rw=cw;end,if rw==0,rw=128;end
        hz=eval(opt(3,:))-1;
        plx=eval(opt(1,:))-1;
        ply=eval(opt(2,:))-1;
        for k=models
            isconf=1;
            doplot=1;docalc=1;
            khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            if isempty(ky)
                iduistat(chmess2,0,Figno);
                docalc=0;doplot=0;  figure(XIDplotw(Figno,1)),
                
            end
            if isa(model,'nlwh')|isa(model,'nlmodel')
                doplot = 0;docalc = 0;
                iduistat('No output spectra for nonlinear model.',0,Figno);
            end
            if docalc
                nam='dum'; 
                if isa(model,'idfrd') 
                    g=model;spe=g('n');
                    [ggw,gga,dum,ggsda,dum]=getff(spe,0,ky); %%LL%% add w here
                     if isempty(gga)
                        doplot=0;
                        iduistat(['No spectrum for model ',pvget(model,'Name'),'.'],0,Figno);
                    end
                    es = pvget(g,'EstimationInfo');
                    if strcmp(lower(es.Method),'etfe')
                        isconf=0;
                        if nu>0
                            iduistat('No disturbance spectrum for EFTE model.',0,Figno);
                            doplot=0;
                        end
                    end
                    if norm(ggsda)==0
                        isconf =  0;
                    end
                    
                elseif ~isaimp(model) 
                    spe = model('n'); 
                    [gga,dum,ggw,ggsda,dum]=boderesp(spe,w);
                    if isempty(gga)
                        doplot=0;
                        iduistat(['No spectrum for model ',pvget(model,'Name'),'.'],0,Figno);
                    end
                    gga=squeeze(gga(ky,ky,:));
                    if ~isempty(ggsda), ggsda=squeeze(ggsda(ky,ky,:));end
                    if norm(ggsda)==0
                        isconf =  0;
                    end
                else
                    iduistat('No spectrum for IMPULSE RESPONSE model.',0,Figno);
                    doplot=0;
                end
            end % if docalc
            axes(xax(1))
            xusd1=get(xax(1),'UserData');set(xax(1),'UserData',[]);
            if doplot
                
                if isempty(ggsda),isconf=0;end
                if hz ggw=ggw/2/pi;end
                if plx, set(gca,'Xscale','log'),else set(gca,'Xscale','linear'),end
                if ply, set(gca,'Yscale','log'),else set(gca,'Yscale','linear'),end
                color=get(klin,'color');
                xusd1(2*k+1,1)=line(ggw,gga,'color',color,'erasemode',ermode,...
                    'visible','off','userdata',kstr);
                hnr=[xusd1(2*k+1,1)];
                if isconf
                    xusd1(2*k+2,1:2)=line([ggw ggw],[gga+SD*ggsda max(gga-SD*ggsda,0)],...
                        'color',color,'linestyle','-.','erasemode',ermode,...
                        'Visible','off','userdata',kstr,'tag','conf')';
                    hnr=[hnr,xusd1(2*k+2,1:2)];
                else
                    if nam(1:3)=='spa'
                        noconf=-2;
                    else
                        noconf=-1;
                    end
                    xusd1(2*k+2,1:2)=[noconf,noconf];
                end
                usd=[idnonzer(get(khax,'userdata'));hnr(:)];
                set(khax,'userdata',usd);
            else
                xusd1(2*k+1,1)=-1;
            end %if doplot
            set(xax(1),'userData',xusd1);
            
        end % for models
        
    elseif Figno==3   % This is Compare
        if any(models==0)
            iduistat('Adjusting fit table ...',0,3);
        else
            iduistat('Computing simulation/prediction ...')
            if isempty(get(gca,'children')) %%LL
                newplot=1;
            else
                newplot=0;
            end
            try
                [vDato,vDat_info,vDat_name,kv]= ...
                    iduigetd('v');
                if isa(vDato,'idfrd')
                    frdflag = 1;
                    vDato = iddata(vDato,'me');
                    kdesu = find(strcmp(pvget(vDato,'InputName'),kudes));
                    if isempty(kdesu)
                        errordlg(['Model output views are not supported for ',...
                                'frequency function data with no input.'],...
                            'Error Dialog','modal');
                        return
                    end
                    vDato = getexp(vDato,kdesu);
                else
                    frdflag = 0;
                end
                dom = pvget(vDato,'Domain');dom = lower(dom(1));
                
            catch
                errordlg(['A Validation Data set must be' ...
                        ' supplied'],'Error Dialog','modal')
                return
            end
            if dom=='f'
                hz = 0;plx = 1; ply = 1;
                hand = XID.plotw(3,1);
                try
                    hzh = findobj(hand,'tag','hz');
                    if strcmp(get(hzh,'checked'),'on')
                        hz = 1;
                    end
                end
                try
                    hzh = findobj(hand,'tag','linfreq');
                    if strcmp(get(hzh,'checked'),'on')
                        plx = 0;
                    end
                end
                try
                    hzh = findobj(hand,'tag','linamp');
                    if strcmp(get(hzh,'checked'),'on')
                        ply = 0;
                    end
                end
            end
            
            yv=pvget(vDato,'OutputData');uv=pvget(vDato,'InputData');
            if length(yv)>1&~frdflag % multiple experiments
                expnr = iduiexp('find',3,pvget(vDato,'ExperimentName'));
            else
                expnr = 1;
            end
            if isempty(expnr)
                errordlg(['The experiment selected in the model output view is not present',...
                        ' in the validation data'],'Error Dialog', 'modal');
                return 
            end
            
            yv = yv{expnr}; uv =uv{expnr};  
            dny = size(yv,2); dnu = size(uv,2);
            vDat =[yv,uv];
            TSamp = pvget(vDato,'Ts');TSamp =TSamp{expnr};
            
            t0 = pvget(vDato,'Tstart');t0 = t0{expnr};
            inters = pvget(vDato,'InterSample'); 
            try
                inters = inters{1,kexp};
            catch
                inters = 'zoh';
            end
            
            dky = find(strcmp(pvget(vDato,'OutputName'),kydes));
            if isempty(dky)
                errordlg(['The validation data ',vDat_name,' does not contain ',...
                        'the chosen output channel for the model output plot.'],'Error Dialog','modal');
                docalc=0;doplot=0;return
            end
            unad = pvget(vDato,'InputName');
            ynad = pvget(vDato,'OutputName');
            dom = pvget(vDato,'Domain');
            dom = lower(dom(1));
            gc=vDat(:,dky);
            yval=gc;
            try
                PH=eval(opt(1,:));
            catch
                PH=0;
            end
            if isempty(PH),PH=5;end
            if length(PH)>1|PH(1)<1|floor(PH(1))~=PH(1)
                errordlg('The prediction horizon must be a positive integer.','Error Dialog','modal');
                return
            end
            
            isdiff=eval(opt(4,:));
            if eval(opt(2,:))==2,
                ISSim=0;
            else 
                ISSim=1;
            end,
            if isinf(PH),ISSim=1;end
            if dnu==0&ISSim,
                hmpred=findobj(XIDplotw(3,1),'tag','predict');
                hmsim=findobj(XIDplotw(3,1),'tag','simul');
                idopttog('check',hmpred);set(hmsim,'enable','off');
                return;
            end
            flag=0;
            try
                sumsamp=eval(['[',deblank(opt(3,:)),']']);
            catch
                flag=1;
            end
            if flag
                errordlg(['The time span for computing the model fit ',...
                        'cannot be evaluated. Please check the text you typed in ',...
                        'the Options dialog box.'],'Error Dialog','modal');
                return
            end
            if isempty(sumsamp),
                sumsamp=1:length(gc);
            else
                sumsamp=(sumsamp(1)-t0)/TSamp:(sumsamp(length(sumsamp))-t0)/TSamp;
            end
            indss=find(sumsamp<=length(gc)&sumsamp>0);
            if isempty(indss)
                errordlg(['Warning: The time span for computing the fit that ',...
                        'you have specified does not overlap with the time span of the ',...
                        'validation data.'],'Error Dialog','modal');
            end
            sumsamp=round(sumsamp(indss));
        end % if models==0
        for k=models
            if k>0
                khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
                kstr=findobj(khax,'tag','name');
                klin=findobj(khax,'tag','modelline');
                [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
                u_ind=[];y_ind=[];stopflag=0;
                
                if length(una)==0&length(unad)~=0 
                    stopflag=1;
                end
                for kku=1:length(una)
                    kuindex= find(strcmp(una{kku},unad));
                    %kuindex=find(kku==dat_u_ind);
                    if isempty(kuindex)
                        stopflag=1;
                    else
                        u_ind=[u_ind,kuindex];
                    end
                end
                %if ~ISSim
                for kky=1:length(yna)%mod_y_ind
                    kyindex = find(strcmp(yna{kky},ynad));
                    %kyindex=find(kky==dat_y_ind);
                    if isempty(kyindex)
                        if ~ISSim, stopflag=1;end
                    else
                        y_ind=[y_ind,kyindex];
                    end
                end
                %end
                if stopflag
                    errordlg(...
                        ['The model ',name,' requires input/output channels ',...
                            'that are not available in the validation data.'],'Error Dialog','modal');
                    docalc=0;  figure(XIDplotw(Figno,1)),
                    
                elseif isempty(ky)
                    iduistat(chmess2,0,Figno);
                    docalc=0;  figure(XIDplotw(Figno,1)),
                    
                else
                    docalc=1;
                end
                doplot=0;
                
                % if ~isa(model,'idmodel')|isaimp(model)%%NLmodel
                if ~(isa(model,'idmodel')|isa(model,'nlmodel')|isa(model,'nlwh'))|isaimp(model)
                    iduistat('No model output for SPA and CRA models.',0,Figno);
                elseif docalc
                    doplot=1;
                    if pvget(model,'Ts')==0  %cont model & cont time!
                        if TSamp>0
                        model = c2d(model,TSamp,inters); 
                    end
                    end
                    if isa(model,'idmodel') %%NLmodel
                        modelky = iduicalc('extract',model,ky,0);
                    else 
                        modelky = model;
                    end
                    if isa(model,'nlmodel')|isa(model,'nlwh')%%NLmodel
                        sdgc = [];
                        if ISSim
                            gc = sim(model,vDat(:,dny+u_ind));
                        else
                            gc = predict(vDat(:,[y_ind,dny+u_ind]),model,PH);
                        end
                    else
                        if ISSim
                            if dom=='f'
                                
                                % First check freq zero and integration
                            %    try
                                [vDato,kzz] = zfcheck(vDato,model);
                                if ~isempty(kzz{expnr})
                                sumsamp = sumsamp(1:end-length(kzz{expnr}));
                                
                            vDat(kzz{expnr},:)=[];
                        end
                                if ~frdflag
                                    [e,xi] = pe(vDato(:,y_ind,u_ind),model);
                                else
                                    xi =[];
                                end
                                if TSamp==0&pvget(model,'Ts')>0
                                    errordlg(['Using continuous time validation data with ',...
                                            'the discrete time model ',pvget(model,'Name'),...
                                            ' is not supported.'],'Error Dialog','modal');
                                    return
                                end
                                gc = sim(model,vDato(:,[],u_ind),xi);
                                gc = pvget(gc,'OutputData');gc = gc{expnr};
                                sdgc = [];
                            else
                                [e,xi]=pe(vDat(:,[y_ind,dny+u_ind]),model,'oe',0,1); 
                                if ~isempty(modelky)                                           
                                    [gc,sdgc]=sim(modelky,vDat(:,dny+u_ind),[],1);
                                    gc=sim(model,vDat(:,dny+u_ind),xi,1);
                                    
                                else %% Here xi should also be computed %%LL%%
                                    [gc,sdgc]=sim(model,vDat(:,dny+u_ind),xi,1);
                                end
                            end
                        else
                            if dom=='f'
                                if nu>0
                                errordlg(['Prediction is not a possible choice for ',...
                                        'frequency domain data.'],'Error Dialog','Modal');
                            else
                                errordlg(['Model output plots are not supported for frequency ',...
                                        'domain data with no input.'],'Error Dialog','Modal');
                            end
                                    return
                                end
                            gc=predict(vDat(:,[y_ind,dny+u_ind]),model,PH,'e',1);sdgc=[];
                        end
                    end
                    gc=gc(:,ky);
                    if isempty(sdgc),isconf=0;else isconf=1;end
                    err=norm(gc(sumsamp)-vDat(sumsamp,dky));
                    meanerr=norm(vDat(sumsamp,dky)-mean(vDat(sumsamp,dky)));
                    fit = 100*(1-err/meanerr);
                end
                xusd1=get(xax(1),'UserData');set(xax(1),'userdata',[]);
                if strcmp(get(hsd,'checked'),'on')
                    onoff='on';
                else
                    onoff='off';
                end
            else % i.e. if k==0
                doplot=1;
            end % if k>0
            if doplot
                xaxtab=findobj(XIDplotw(3,1),'tag','table');
                if k>0
                    [rgc,cgc]=size(gc);
                    if isdiff,gc=yval-gc;end
                    color=get(klin,'color');
                    if dom=='f'
                        TImeC = pvget(vDato,'SamplingInstants');
                        TImeC = TImeC{expnr};
                    else
                        TImeC=[0:rgc-1]*TSamp+t0;TImeC=TImeC'*ones(1,cgc);
                    end
                    axes(xax(1))
                    if dom=='f'
                        if hz 
                            TImeC=TImeC/2/pi;
                            xlab = 'Hz';
                        else
                            xlab = 'rad/s';
                        end
                        if plx, set(gca,'Xscale','log'),else set(gca,'Xscale','linear'),end
                        if ply, set(gca,'Yscale','log'),else set(gca,'Yscale','linear'),end
                    end
                    if isreal(gc)
                        ydat = gc;
                    else
                        ydat = abs(gc);
                    end
                    xusd1(2*k+1,1)=line(TImeC,ydat,'color',color,'erasemode',ermode,...
                        'userdata',kstr);
                    axes(xaxtab);
                    fz=idlayout('fonts',100);
                    xusd1(2*k+1,2)=text(0,0,...
                        [get(kstr,'string'),': ',num2str(fit,4)],'color',color,...
                        'units','points','HorizontalAlignment','left',...
                        'userdata',fit,'tag','fits','fontsize',fz);
                end % if k>0
                axes(xaxtab);
                fits=findobj(xaxtab,'tag','fits');
                vals=[];
                for kf=fits'
                    vals=[vals,get(kf,'userdata')];
                end
                [dum,indv]=sort(-vals);
                kp=15;
                xlead=findobj(xaxtab,'tag','leader');
                set(xlead,'units','points');xlpos=get(xlead,'pos');
                set(xlead,'units','norm');
                invindv=indv(:)';
                for kf=invindv
                    set(fits(kf),'pos',[1 xlpos(2)-kp]);
                    kp=kp+15;
                end
                if k==0,iduistat('',0,3);return,end
                % k=0 has just been a response to resizing.
                hnr=[xusd1(2*k+1,1:2)];
                axes(xax(1))
                if ISSim
                    if isconf
                        xusd1(2*k+2,1:2)=line([TImeC TImeC],[gc+SD*sdgc gc-SD*sdgc],...
                            'color',color,'linestyle','-.','erasemode',ermode,...
                            'Visible',onoff,'userdata',kstr,'tag','conf')';
                        hnr=[hnr,xusd1(2*k+2,1:2)];
                    else
                        xusd1(2*k+2,1:2)=[-1,-1];
                    end
                end
                if xusd1(2,2)==0&~isdiff
                    if isreal(vDat(:,dky))
                        ydat = vDat(:,dky);
                    else
                        ydat = abs(vDat(:,dky));
                    end
                    xusd1(2,2)=line(TImeC,ydat,'color',textcolor,'erasemode',...
                        ermode,'userdata',kv(3));
                end
                usd=[idnonzer(get(khax,'userdata'));hnr(:)];
                set(khax,'userdata',usd);
            else
                xusd1(2*k+1,1)=-1;
            end % end doplot
            set(xax(1),'UserData',xusd1)
        end %for models
        if newplot,axis(axis),axis('auto'),end
        
    elseif Figno==4  % ZPPLOT
        iduistat('Computing Poles and Zeros...')
        axes(xax(1))
        
        newc=findobj(xax(1),'tag','zpucl');
        om = 2*pi*[0:100]/100;
        w = exp(om*sqrt(-1));
        if isempty(newc)
            
            huc=line(real(w),imag(w),'color',textcolor,'vis','off','tag','zpucl');
            ucmen=findobj(XIDplotw(4,1),'tag','zpuc');
            if ~isempty(ucmen),if strcmp(get(ucmen,'checked'),'on')
                    set(huc,'vis','on');
                end,end
            hreiem(1)=line([-1 1],[0 0],'color',textcolor,'vis','off','tag','zpaxr');
            hreiem(2)=line([0 0],[-1 1],'color',textcolor,'vis','off','tag','zpaxi');
            ucmen=findobj(XIDplotw(4,1),'tag','zpax');
            if ~isempty(ucmen),if strcmp(get(ucmen,'checked'),'on')
                    set(hreim,'vis','on');
                end,end
            axis('equal'),%set(XIDmen(4,15),'checked','on'); %%LL
        end
        
        for kcount=models
            khax=findobj(modaxs,'flat','tag',['model',int2str(kcount)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            %        nam=get(kstr,'userdata');
            %       name=get(kstr,'string');
            doplot=1;docalc=1;
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            if isa(model,'nlwh') %%%NLModel
                model = pvget(model,'LinearModel');
            elseif isa(model,'nlarx')
                docalc=0;doplot=0;
                iduistat('No plot for nonlinear models.',0,Figno);
            end
            
            
            %[ny,nu,ky,ku]=iduiiono('old',nam,'mod',[kudes,kydes]);
            if isempty(ky)|isempty(ku)
                iduistat(chmess,0,Figno);
                docalc=0;doplot=0;  figure(XIDplotw(Figno,1)),
                
            end
            if docalc
                if isa(model,'idfrd')|isaimp(model)%nam(1,1:3)=='cra' | nam(1,1:3)=='spa'
                    doplot=0;
                    iduistat('No plot for CRA and SPA models.',0,Figno);
                else
                    doplot=1;
                    %zepo=iduicalc('zp',model,ky,ku);
                end
            end %if docalc
            
            xusd=get(xax(1),'UserData');set(xax(1),'UserData',[]);
            [nrxusd,ncxusd]=size(xusd);
            if doplot
                if ku>0
                    [zz,pp,k,zzsd,ppsd]=zpkdata(model);
                else
                    [zz,pp,k,zzsd,ppsd]=zpkdata(model('n'));
                end
                if ku>0
                    kup = ku;
                else
                    kup = -ku;
                end
                zz = zz{ky,kup};
                pp = pp{ky,kup};
                if isempty(zzsd)&isempty(ppsd),isconf=0;else isconf=1;end
                if isconf
                    zzsd = zzsd{ky,kup};
                    ppsd = ppsd{ky,kup};
                end
                
                %getzp(zepo,ku,ky);
                color=get(klin,'color');
                MATLABversion = version;
                if MATLABversion(1)=='4',
                    PropertyName = 'LineStyle';
                else
                    PropertyName = 'Marker';
                end
                sl1=line(real(zz),imag(zz),...
                    'color',color,PropertyName,'o','erasemode',ermode,...
                    'userdata',kstr);
                sl2=line(real(pp),imag(pp),...
                    'color',color,PropertyName,'x','erasemode',ermode,...
                    'userdata',kstr);
                if MATLABversion(1)~='4',
                    set(sl1,'Linestyle','none');
                    set(sl2,'Linestyle','none');
                end
                % Now follows the confidence regions
                
                sl3=[];sl4=[];nc=[];
                if isempty(zzsd)
                    zeros_cf=0;
                else
                    zeros_cf=1;
                    %zepo=[zz,zzsd];[nrll,nc]=size(zepo);
                    for k=1:size(zz,1)
                        sl31 = [];
                        z = zz(k,:); dz = zzsd(:,:,k);
                        if imag(z)==0
                            rp=real(z+SD*sqrt(dz(1,1))*[-1 1]);
                            [mr,nr] = size(rp);
                            sl31 = line(rp,zeros(mr,nr),'color',color,'linestyle','-',...
                                'erasemode',ermode,'visible','off','userdata',kstr);
                        else  
                            [V,D]=eig(dz); z1=real(w)*SD*sqrt(D(1,1));
                            z2=imag(w)*SD*sqrt(D(2,2)); X=V*[z1;z2];
                            if imag(z)<0,X(2,:)=-X(2,:);end
                            
                            X=[X(1,:)+real(z);X(2,:)+imag(z)];
                            sl31 = line(X(1,:),X(2,:),'color',color,...
                                'linestyle','-','erasemode',ermode,'visible','off'...
                                ,'userdata',kstr);
                            sl=line(X(1,:),-X(2,:),'color',color,...
                                'linestyle','-','erasemode',ermode,'visible','off'...
                                ,'userdata',kstr);
                            
                            sl31=[sl31;sl];
                        end
                        sl3=[sl3;sl31];
                        
                    end  %for k=
                end % if isempty(zzsd)
                
                if isempty(ppsd)
                    poles_cf=0;
                else
                    poles_cf=1;
                    %zepo=[pp,ppsd];[nrll,nc]=size(zepo);
                    for k=1:size(pp,1)
                        sl41 = [];
                        z = pp(k,:); dz = ppsd(:,:,k);
                        if imag(z)==0
                            rp=real(z+SD*sqrt(dz(1,1))*[-1 1]);
                            [mr,nr] = size(rp);
                            sl41 = line(rp,zeros(mr,nr),'color',color,'linestyle','-',...
                                'erasemode',ermode,'visible','off','userdata',kstr);
                        else  
                            [V,D]=eig(dz); z1=real(w)*SD*sqrt(D(1,1));
                            z2=imag(w)*SD*sqrt(D(2,2)); X=V*[z1;z2];
                            if imag(z)<0,X(2,:)=-X(2,:);end
                            
                            X=[X(1,:)+real(z);X(2,:)+imag(z)];
                            sl41 = line(X(1,:),X(2,:),'color',color,...
                                'linestyle','-','erasemode',ermode,'visible','off'...
                                ,'userdata',kstr);
                            sl=line(X(1,:),-X(2,:),'color',color,...
                                'linestyle','-','erasemode',ermode,'visible','off'...
                                ,'userdata',kstr);
                            
                            sl41=[sl41;sl];
                        end
                        sl4=[sl4;sl41];
                        
                    end  %for k=
                end % if isempty(ppsd)
                l1=length(sl1)+length(sl2);l2=length(sl3)+length(sl4);
                if ncxusd<l1+l2+2,xusd=[xusd,zeros(nrxusd,l1+l2+2-nc)];end
                if l1>0,xusd(2*kcount+1,1:l1)=[sl1' sl2'];hnr=[sl1',sl2'];end
                if l2>0,
                    xusd(2*kcount+2,1:l2)=[sl3',sl4'];hnr=[hnr,sl3',sl4'];
                else
                    xusd(2*kcount+2,1)=-1;
                end
                if strcmp(get(hsd,'checked'),'on')
                    set(idnonzer([sl3',sl4']),'visible','on');
                end
            else
                xusd(2*kcount+1,1)=-1;
            end  %if doplot
            set(xax(1),'Userdata',xusd)
            usd=[idnonzer(get(khax,'userdata'));hnr(:)];
            set(khax,'userdata',usd);
            
        end %for kcount
        hre=findobj(XIDplotw(4,1),'tag','zpaxr');
        set(hre,'xdata',get(get(hre,'parent'),'xlim'));
        him=findobj(XIDplotw(4,1),'tag','zpaxi');
        set(him,'ydata',get(get(hre,'parent'),'ylim'));
    elseif Figno==5  % This is transient response
        iduistat('Computing transient response...')
        TImespan=eval(deblank(opt(2,:)));
        if isempty(TImespan),TImespan=1:40;end
        if eval(opt(3,:))==1,ISStep=1;else ISStep=0;end
        if eval(opt(1,:))==2,ISStem=1;else ISStem=0;end
        
        for k=models
            khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            doplot=1;docalc=1;
            if isempty(ky)|isempty(ku)
                iduistat(chmess,0,Figno);
                docalc=0;doplot=0;  
                figure(XIDplotw(Figno,1)),
                
            end
            if docalc
                if isa(model,'idmodel')&isaimp(model); 
                    if ku<0
                        iduistat('No noise response for IMPULSE model.',0,Figno);
                        doplot=0;
                    else
                        if ISStep
                            [IR,timeIR,sdIR] = step(model,[TImespan*pvget(model,'Ts')]);
                        else
                            [IR,timeIR,sdIR]=impulse(model,[TImespan*pvget(model,'Ts')]);
                        end
                        sdIR = squeeze(sdIR(:,ky,ku));
                        IR = squeeze(IR(:,ky,ku));
                        isconf=1;
                    end
                elseif isa(model,'idfrd') 
                    iduistat('No transient response for SPA model.',0,Figno);
                    doplot=0;
                else
                    
                    try
                        TSamp=pvget(model,'Ts'); 
                    catch
                        TSamp = 1;
                    end
                    if TSamp == 0
                        est = pvget(model,'EstimationInfo');
                        ut = pvget(model,'Utility');
                        try
                            TSamp = ut.Tsdata;
                        catch
                            try
                                TSamp = es.DataTs;
                               
                            catch
                                TSamp = 1;
                            end
                        end
                         if TSamp==0;[dum,TSamp]=iddeft(model);end %%%%
                        %if TSamp>0
                        model = c2d(model,TSamp);
                        %end
                        modelky = iduicalc('extract',model,ky,ku);
                    else
                        if isa(model,'idmodel') %%NLMODel
                            modelky = iduicalc('extract',model,ky,ku,klin);
                        else
                            modelky = [];
                        end
                    end
                    MSamp=TImespan;%/TSamp; %as simple as this to change
                    if ISStep
                        uu=ones(MSamp,1);
                    else
                        uu=[1;zeros(MSamp-1,1)]/TSamp;
                    end
                    if ku<0,kku=nu-ku;else kku=ku;end
                    if isa(model,'idmodel') %%NLMODEL
                        uuu=[zeros(MSamp,kku-1),uu,zeros(MSamp,nu+ny-kku)]; 
                    else
                        uuu=[zeros(MSamp,kku-1),uu,zeros(MSamp,nu-kku)]; 
                    end
                    
                    
                    model =pvset(model,'NoiseVariance',eye(ny));
                    %lastwarn('');
                    %was = warning;
                    %warning('off')
                    IR = sim(model,uuu,'z',1); %% For nu<0 we get a scaling with lam
%                     warning(was)
%                     if ~isempty(lastwarn)
%                         warndlg(lastwarn,'Warning','modal');
%                     end
                    IR = IR(:,ky);
                    if ~isempty(modelky)
                        sdIR =idsimcov(modelky,uuu,IR); 
                    else
                        sdIR =[];
                    end
                    if isempty(sdIR)
                        isconf=0;
                    else
                        isconf=1;
                    end
                end
            end % if docalc
            xusd=get(xax(1),'userdata');set(xax(1),'UserData',[]);
            if doplot
                if isaimp(model) 
                    TImeS = timeIR';
                else
                    TImeS=[0:length(IR)-1]'*TSamp;
                end
                color=get(klin,'color');
                if strcmp(get(hsd,'checked'),'on')
                    onoff='on';
                else
                    onoff='off';
                end
                axes(xax(1))
                if ISStem
                    xx=[TImeS';TImeS';nan*ones(size(TImeS'))];
                    yy=[zeros(1,length(TImeS));IR';nan*ones(size(IR'))];
                    MATLABversion = version;
                    if MATLABversion(1)=='4',
                        PropertyName = 'LineStyle';
                    else
                        PropertyName = 'Marker';
                    end
                    
                    sl1=line(TImeS',IR','color',color,...
                        'erasemode',ermode,PropertyName,'o','userdata',kstr);
                    
                    sl2=line(xx(:),yy(:),'color',color,'erasemode',ermode,...
                        'userdata',kstr);
                    set(sl1,'Linestyle','none');
                    xusd(2*k+1,1:2)=[sl1' sl2'];hnr=[sl1',sl2'];
                    
                else
                    xusd(2*k+1,1)=line(TImeS,IR,'color',color,'erasemode',ermode...
                        ,'userdata',kstr);
                    hnr=xusd(2*k+1,1);
                end
                if isconf
                    if ISStem&~ISStep
                        curves=[SD*sdIR -SD*sdIR];
                    else
                        curves=[IR+SD*sdIR  IR-SD*sdIR];
                    end
                    xusd(2*k+2,1:2)=line([TImeS TImeS],curves,'color',color,...
                        'erasemode',ermode,'linestyle','-.',...
                        'visible',onoff,'userdata',kstr,'tag','conf')';
                    hnr=[hnr,xusd(2*k+2,1:2)];
                else %noconf
                    xusd(2*k+2,1:2)=[-1,-1];
                end
            else
                xusd(2*k+1,1)=-1;
            end
            set(xax(1),'Userdata',xusd)
            usd=[idnonzer(get(khax,'userdata'));hnr(:)];
            set(khax,'userdata',usd);
            if newplot, axis(axis),axis('auto'),end
        end %for k=
    elseif Figno==6
        iduistat('Computing residuals...')
        maxsize=idmsize;
        try
            [z,z_info,vDat_name]=iduigetd('v');
            if isa(z,'idfrd')
                z = iddata(z,'me');
                idfrdflag = 1;
            else
                idfrdflag = 0;
            end
        catch
            errordlg(['A Validation Data set must be' ...
                    ' supplied'],'Error Dialog','modal')
            
            return
        end
        M=eval(opt);if isempty(opt),M=21;else M=M+1;end
        [N,dny,dnu]=size(z);
        
        %y = pvget(z,'OutputData'); y = y{1}; dny = size(y,2);%%Only exp 1
        %u = pvget(z,'InputData'); u = u{1}; dnu = size(u,2);
        ynad = pvget(z,'OutputName');
        unad = pvget(z,'InputName');
        dky = find(strcmp(ynad,kydes));
        dku = find(strcmp(unad,kudes));
        if isempty(dky)
            errordlg(['The validation data ',vDat_name,' does not contain ',...
                    'the chosen output channel for the residual plot.'],'Error Dialog','modal');
            docalc=0;doplot=0;return
        end
        for k=models
            khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            
            % if ~isa(model,'idmodel')|(isa(model,'idmodel')&isaimp(model)) %%NLMODEL
            if isa(model,'idfrd')|isaimp(model)
                iduistat('No plot for CRA and SPA models.',0,Figno);
                docalc=0;doplot=0;
            else
                docalc=1;doplot=1;
            end
            if docalc
               
                u_ind=[];y_ind=[];stopflag=0;
                for kku=1:length(una) 
                    kuindex = find(strcmp(una{kku},unad));
                    
                    if isempty(kuindex)
                        stopflag=1;
                    else
                        u_ind=[u_ind,kuindex];
                    end
                end
                for kky=1:length(yna) 
                    kyindex = find(strcmp(yna{kky},ynad));
                    if isempty(kyindex)
                        stopflag=1;
                    else
                        y_ind=[y_ind,kyindex];
                    end
                end
              
                if stopflag
                    errordlg(...
                        ['The model ',name,' requires input/output channels ',...
                            'for the residual plot that are not available ',...
                            'in the validation data.'],'Error Dialog','modal');
                    doplot=0;  figure(XIDplotw(Figno,1)),
                elseif isempty(ky)
                    iduistat(chmess2,0,Figno);
                    doplot=0;  figure(XIDplotw(Figno,1)),
                else
                    doplot=1;
                end
                if doplot
                    was = warning;
                    warning off
                     [e,dum,flag] = pe(z(:,y_ind,u_ind),model);
                     if flag
                        z = rmzero(z);
                    end
                     warning(was)
                    pos = idlayout('axes',1);posy = pos(1,:);
                    posyts = idlayout('axes',7);
                    if nu>0
                        set(xax(1),'pos',posy,'xticklabel',[]);
                    else
                        set(xax(1),'pos',posyts,'xticklabelmode','auto');
                        axes(xax(2)),cla,
                        set(xax(2),'vis','off')
                    end
                   % th= get(klin,'UserData'); 
                    xusd1=get(xax(1),'userdata');set(xax(1),'userdata',[]);
                    color=get(klin,'color');
                     ee = [e,z(:,[],:)];
                     dom = pvget(ee,'Domain'); dom = lower(dom(1));
                    if dom=='t'
                        r=covf(ee(:,dky,dku),M,maxsize);
                        
                        nr=1:M-1;
                        ind=1;
                        sdre=SD*(r(ind,1))/sqrt(sum(N))*ones(2*M-1,1);
                        
                        axes(xax(1));[nllr,nllc]=size(r);
                        %set(xax(1),'yscale','lin')
                        xusd1(2*k+1,1)=line(nr,r(ind,2:nllc)'/r(ind,1),'color',color,...
                            'erasemode',ermode,'userdata',kstr);
                        xusd1(2*k+1,2)=line(-nr,r(ind,2:nllc)'/r(ind,1),'color',color,...
                            'erasemode',ermode,'userdata',kstr);
                        
                        xusd1(2*k+2,1:2)=line([-M+1:M-1],[sdre -sdre]/r(ind,1),'color',color,...
                            'linestyle',':','erasemode',ermode,'Visible','off',...
                            'tag','conf','userdata',kstr)';
                        hnr=[xusd1(2*k+1,1:2),xusd1(2*k+2,1:2)];
                        if newplot,axis(axis),axis('auto'),end
                        if nu>0
                            nr=-M+1:M-1;
                            set(xax(2),'vis','on')
                            ind1=3;ind2=2;indy=1;indu=4;
                            sdreu=SD*sqrt(r(indy,1)*r(indu,1)+2*(r(indy,2:M)*r(indu,2:M)'))...
                                /sqrt(sum(N))*ones(2*M-1,1);
                            axes(xax(2))
                            xusd2=get(xax(2),'userdata');set(xax(2),'userdata',[]);
                            xusd2(2*k+1,1)=line(nr,...
                                [r(ind1,M:-1:1) r(ind2,2:M) ]'/(sqrt(r(indy,1)*r(indu,1))),...
                                'Erasemode',ermode,'color',color,'userdata',kstr);
                            
                            xusd2(2*k+2,1:2)=line(nr,[sdreu -sdreu]/(sqrt(r(indy,1)*r(indu,1))),...
                                'LineStyle',':','EraseMode',ermode,'Visible','off','color',color...
                                ,'userdata',kstr,'tag','conf')';
                            if newplot,axis(axis),axis('auto')
                            end
                            set(xax(2),'userdata',xusd2)
                            hnr=[hnr,xusd2(2*k+1,1),xusd2(2*k+2,1:2)];
                        end %if nu>0
                    else % FD calculations
                        my = arx(ee(:,dky,[]),M,'ini','z');
                        [magy,ph,w,dmagy] = boderesp(my);
                        magy = squeeze(magy);
                        dmagy = squeeze(dmagy);
                        axes(xax(1));
                        %     set(xax(1),'yscale','log')
                        xusd1(2*k+1,1)=line(w,magy,'color',color,...
                            'erasemode',ermode,'userdata',kstr);
                        % xusd1(2*k+1,2)=line(-nr,r(ind,2:nllc)'/r(ind,1),'color',color,...
                        %    'erasemode',ermode,'userdata',kstr);
                        
                        xusd1(2*k+2,1)=line(w,magy+SD*dmagy,'color',color,...
                            'linestyle',':','erasemode',ermode,'Visible','off',...
                            'tag','conf','userdata',kstr)';
                        xusd1(2*k+2,2)=line(w,max(magy-SD*dmagy,0),'color',color,...
                            'linestyle',':','erasemode',ermode,'Visible','off',...
                            'tag','conf','userdata',kstr)';
                        hnr=[xusd1(2*k+1,1:2),xusd1(2*k+2,1:2)];
                        if newplot,axis(axis),axis('auto'),end
                        
                        if nu>0
                            if idfrdflag
                                ini = 'z';
                            else
                                ini = 'a';
                            end
                            m = arx(ee(:,dky,:),[ 0 M*ones(1,nu) zeros(1,nu)],'ini',ini);
                            [mag,ph,w,dmag] = boderesp(m);
                            mag=squeeze(mag(1,dku,:));
                            dmag=squeeze(dmag(1,dku,:));
                            set(xax(2),'vis','on')
                            axes(xax(2))
                            xusd2=get(xax(2),'userdata');set(xax(2),'userdata',[]);
                            xusd2(2*k+1,1)=line(w,mag,...
                                'Erasemode',ermode,'color',color,'userdata',kstr);
                            
                            xusd2(2*k+2,1)=line(w,mag+SD*dmag,...
                                'LineStyle',':','EraseMode',ermode,'Visible','off','color',color...
                                ,'userdata',kstr,'tag','conf')';
                            
                            xusd2(2*k+2,2)=line(w,max(mag-SD*dmag,0),...
                                'LineStyle',':','EraseMode',ermode,'Visible','off','color',color...
                                ,'userdata',kstr,'tag','conf')';
                            if newplot,
                                axis(axis),axis('auto')
                            end
                            set(xax(2),'userdata',xusd2)
                            hnr=[hnr,xusd2(2*k+1,1),xusd2(2*k+2,1:2)];
                        end %if nu>0
                        
                    end
                    if strcmp(get(hsd,'checked'),'on')
                        set(idnonzer(xusd1(2*k+2,1:2)),'Visible','on')
                        if nu >0
                            try
                                set(idnonzer(xusd2(2*k+2,1:2)),'Visible','on')
                            end
                        end
                    end
                    
                    usd=[idnonzer(get(khax,'userdata'));hnr(:)];
                    set(khax,'userdata',usd);
                else
                    xusd1(2*k+1,1)=-1;
                end  % if doplot
                set(xax(1),'Userdata',xusd1)
            end % if docalc
        end %for k=models
        iduital(6);
        
    end %if Figno
    
    
end % for figures
warning(was)
idgwarn(lastwarn)
% if ~isempty(lastwarn)&warflag
%     mess = '(Warning Dialogs can be turned off under the Options Menu in the main window)';
%     warndlg({lastwarn,mess},'Warning','modal');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m,ny,nu,ky,ku,yna,una,mna] =getchan(klin,kydes,kudes)
m = get(klin,'UserData');
%if isa(m,'idmodel')|isa(m,'idfrd')
yna = pvget(m,'OutputName');
una = pvget(m,'InputName');
mna = pvget(m,'Name');

ny = length(yna);
nu = length(una);
ky = find(strcmp(yna,kydes));
ku = find(strcmp(una,kudes));
if isempty(ku)&length(kudes{1})>2
    if strcmp(kudes{1}(1:2),noiprefi('e'))
        kudes = kudes{1}(3:end);
        ku  = find(strcmp(yna,kudes));
        ku = -ku;
    end
end
