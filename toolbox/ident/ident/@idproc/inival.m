function m = inival(z,m)
%IDPROC/INIVAL Sets intial values for process models
% 
%   Auxiliary function to IDPROC/PEM

%   L. Ljung 31-12-02

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/04/10 23:17:10 $


try
    Xsum = findobj(get(0,'children'),'tag','sitb16');
    XID = get(Xsum,'UserData');
    set(XID.iter(13),'string','Initialization ..')
    set(XID.iter(15),'string','')
    set(XID.iter(17),'string','')
end

typec = i2type(m);

if ~iscell(typec)
    typec={typec};
end
[N,ny,nu,Nexp] = size(z);
num = length(typec);
Ts = pvget(z,'Ts');
int = pvget(z,'InterSample');
samp = pvget(z,'SamplingInstants');
y = pvget(z,'OutputData');
u = pvget(z,'InputData');
intorig = pvget(z,'InterSample');
adjustfd = zeros(1,nu);
dom = pvget(z,'Domain');
if lower(dom(1))=='f'
    fd = 1;
else 
    fd = 0;
end

% First, if any integration is involved and it is FD data, remove zero
% frequency:

if fd&(~isempty(findstr('I',[typec{:}])))
    for kexp=1:Nexp
        zerfr = find(abs(samp{kexp})<100*eps);
        y{kexp}(zerfr,:)=[];
        u{kexp}(zerfr,:)=[];
        samp{kexp}(zerfr)=[];
    end
    z = pvset(z,'OutputData',y,'InputData',u,'SamplingInstants',samp);
end
kpi = pvget(m,'Kp');
kpi = kpi.value;
kflag = zeros(1,nu);
tp1flag = zeros(1,nu);
tp1i = pvget(m,'Tp1');
tp1i = tp1i.value;
tp2flag = zeros(1,nu);
tp2i = pvget(m,'Tp2');
tp2i = tp2i.value;

tp3flag = zeros(1,nu);
tp3i = pvget(m,'Tp3');
tp3i = tp3i.value;

twflag = zeros(1,nu);
twi = pvget(m,'Tw');
twi = twi.value;

zetaflag = zeros(1,nu);
zetai = pvget(m,'Zeta');
zetai = zetai.value;

tzflag = zeros(1,nu);
tzi = pvget(m,'Tz');
tzi = tzi.value;

tdflag = zeros(1,nu);
tdi = pvget(m,'Td');
tdi = tdi.value;


for ku = 1:nu
    type = typec{ku};
    if any(type=='I')
        for kexp = 1:Nexp
            if ~fd
                % y{kexp} = y{kexp}(2:end,:);
                u{kexp}(:,ku) =[0; cumsum(u{kexp}(1:end-1,ku))*Ts{kexp}];
            else
                y{kexp} = y{kexp};
                if Ts{kexp}>0
                    rat = 1-exp(-i*samp{kexp}*Ts{kexp});
                else
                    rat = i*samp{kexp};
                end
                u{kexp}(:,ku)=u{kexp}(:,ku)./(rat)*Ts{kexp};
                if eval(type(2))>0,adjustfd(ku) = 1;end
            end
            int{ku,kexp} = 'foh';
        end
    end
end
z = pvset(z,'OutputData',y,'InputData',u,'InterSample',int);%,...
%%LL fel ovan: ku, ud etc ej konsistenta
%    end% end of adjusting data for integration
% adjust data to include possible info about static gain:
for ku = 1:nu
    kpiku = kpi(ku);
    if ~isinf(kpiku)&~isnan(kpiku) %% nu>1
        Nm = sum(N)*5;
        zm = iddata(kpiku*ones(Nm,1),[zeros(Nm,ku-1),ones(Nm,1),zeros(Nm,nu-ku)],Ts{1});
        if fd
            zm = fft(zm);
        end
        zm.una = z.una; zm.yna=z.yna;
        zm.uu = z.uu; zm.yu=z.yu;%%LL FIX
        z = merge(z,zm);
        kflag(ku) = 1;
    end
    
    if ~isinf(tp1i(ku))&~isnan(tp1i(ku));
        tp1flag(ku) = 1;
    end
    if ~isinf(tp2i(ku))&~isnan(tp2i(ku));
        tp2flag(ku) = 1;
    end
    if ~isinf(tp3i(ku))&~isnan(tp3i(ku));
        tp3flag(ku) = 1;
    end
    if ~isinf(twi(ku))&~isnan(twi(ku));
        twflag(ku) = 1;
    end
    if ~isinf(zetai(ku))&~isnan(zetai(ku));
        zetaflag(ku) = 1;
    end
    if ~isinf(tzi(ku))&~isnan(tzi(ku));
        tzflag(ku) = 1;
    end
    if ~isinf(tdi(ku))&~isnan(tdi(ku));
        tdflag(ku) = 1;
    end
end 
% Prepare for delay info
nk = ones(1,nu);
adjustfd = zeros(1,nu);

nkest = zeros(1,nu);
if ~isempty(findstr('D',[typec{:}]))
    [tdc{1:7}] = procpar(m);
    tdi = tdc{7};
    Tdini = pvget(m,'Td');
    Tdini = Tdini.value;
end
% Now orders
for ku = 1:nu
    type = typec{ku};
    p = eval(type(2));
    int = (any(type=='I'));
    hold = intorig{ku,1}; %same for all exp
    hold = lower(hold(1));
    fhold = 0;
    if hold=='f'
        fhold = 1;
    end
    switch  type
        case 'P0'
            nf(ku) = 0; nb(ku) = 1; nk(ku) = 0;
        case 'P0D'
            nf(ku) = 0; nb(ku) = 1; nk(ku) = 0;
            if fhold
                nb(ku) = 2;
            end
        case 'P0I'
            nf(ku) = 0;nb(ku) = 1;nk(ku) =0;
            if fhold 
                nb(ku) = 2; 
            end
            if fd&~fhold
                adjustfd(ku) = 1;
            end
        case 'P0DI'
            nf(ku) = 0;
            nb(ku) = 2;
            if fhold
                nb(ku) = 3;
            end
        case {'P1'}
            nf(ku) = 1;nb(ku) = 1;nk(ku) =1;
            if fhold
                nb(ku) = 2;
                nk(ku) = 0;
            end
        case {'P1I'}
            nf(ku) = 1;nb(ku) = 2; nk(ku) = 0;
            if fd
                adjustfd(ku) = 1;
            end
            if fhold
                nb(ku) = 2;
                nk(ku) = 0;
            end
        case 'P1Z'
            nf(ku) = 1;
            nb(ku) = 2;
            nk(ku) = 0;
        case 'P1ZI'
            nf(ku) = 1;
            nb(ku) = 2;
            nk(ku) = 0;
            if fd & ~fhold
                adjustfd(ku) = 1;
            end
        case {'P1D'}
            nf(ku) = 1; nb(ku) = 2;
            if fhold
                nb(ku) = 3;
            end
        case {'P1DI'}
            nf(ku) = 1; nb(ku) = 3;
            if fhold
                nb(ku) = 3;
            end
        case {'P1DZ'}
            nf(ku) = 1; nb(ku) = 2;
            if fhold
                nb(ku) = 3;
            end
        case {'P1DZI'}
            nf(ku) = 1; nb(ku) = 3;
            if fhold
                nb(ku) = 3;
            end
        case {'P2','P2U'}
            nf(ku) = 2;nb(ku) = 2; nk(ku) = 1;
            if fhold
                nb(ku) = 3;
                nk(ku) = 0;
            end
        case {'P2I','P2IU'}
            nf(ku) = 2;nb(ku) = 3; nk(ku) = 0;
            if fd
                adjustfd(ku)  =1;
            end
            if fhold
                nb(ku) = 3;
                nk(ku) = 0;
            end
        case {'P2ZI','P2ZIU'}
            nf(ku) = 2;
            nb(ku) = 3;
            nk(ku) = 0;
            if fd&~fhold
                adjustfd(ku)  =1;
            end
            
        case {'P2Z','P2ZU'}
            nf(ku)  = 2;
            nb(ku) = 2;
            nk(ku) = 1;
            if fhold&~fd
                nb(ku) = 3;
                nk(ku) = 0;
            end
        case {'P2D','P2DU'}
            nf(ku) = 2; nb(ku) = 3; 
            if fhold
                nb(ku) = 4;
                
            end
        case {'P2DI','P2DIU'}
            nf(ku) = 2; nb(ku) = 4;
        case {'P2DZ','P2DZU'}
            nf(ku) = 2; nb(ku) = 3;
            if fhold
                nb(ku) = 4;
            end
        case {'P2DZI','P2DZIU'}
            nf(ku) = 2;
            nb(ku) = 4;
        case {'P3','P3U'}
            nf(ku) = 3;nb(ku) = 3;nk(ku) = 1;
            if fhold
                nb(ku) = 4;
                nk(ku) = 0;
            end
        case {'P3I','P3IU'}
            nf(ku) = 3;nb(ku) = 4;nk(ku) = 0;
            if fhold
                nb(ku) = 4;
                nk(ku) = 0;
            end
            if fd
                adjustfd(ku)  =1;
            end
        case {'P3Z','P3ZU'}
            nf(ku) = 3;
            nb(ku) = 3;
            nk(ku) = 1;
            if fhold
                nb(ku) = 4;
                nk(ku) = 0;
            end
        case {'P3ZI','P3ZIU'}
            nf(ku) = 3;
            nb(ku) = 4;
            nk(ku) = 0;
            if fhold
                nb(ku) = 4;
                nk(ku) = 0;
            end
            if fd
                adjustfd(ku)  =1;
            end
        case {'P3D','P3DU'}
            nf(ku) = 3; nb(ku) = 4;
            if fhold
                nb(ku) = 5;
            end
        case {'P3DZ','P3DZU'}
            nf(ku) = 3; nb(ku) = 4;
            if fhold
                nb(ku) = 5;
            end
        case {'P3DZI','P3DZIU','P3DI','P3DIU','P3DZI','P3DZIU'}
            nf(ku)=3; nb(ku) = 5;
        otherwise
            disp('MISSING TYPE')
    end
    
    % Now for the delays
    if any(type=='D') % all inputs one by one
        if isnan(Tdini(ku))
            if any(type=='I')&fd
                nf1(ku)=nf(ku)+1;
            else
                nf1(ku)=nf(ku);
            end
            nk(ku) = delayest(z(:,1,ku),nf1(ku),nb(ku),...
                floor(m.Td.min(ku)/Ts{1}),ceil(m.Td.max(ku)/Ts{1}));
        else
            nk(ku) = Tdini(ku)/Ts{1}+1;
            if hold=='f'|(eval(type(2))==1&any(type=='Z'))
                nk(ku)=nk(ku)-1;
            end
        end
    end
end % end ku

fa = pvget(m,'FileArgument');
dm = fa{3};
if strcmp(dm(1:2),'AR')
    ncd = eval(dm(5));
else
    ncd = 0;
end
nk = adjustfd + nk;
nk = floor(nk);
[nb nf nk];
%keyboard
inoe = pvget(m,'InitialState'); inoe =lower(inoe(1));
if inoe=='f'|inoe=='m'
    inoe= 'z';
end
try % This is just due to possible problems in very special structures with inoe='b';
    if ncd>0
        mstart = bj(z,[nb ncd ncd nf nk],'cov','none','ini',inoe); %was 'e'
    else
        mstart = oe(z,[nb nf nk],'cov','none','ini',inoe);
    end
catch
    inoe='z';
    if ncd>0
        mstart = bj(z,[nb ncd ncd nf nk],'cov','none','ini',inoe); %was 'e'
    else
        mstart = oe(z,[nb nf nk],'cov','none','ini',inoe);
    end  
end
loss = mstart.es.LossFcn;

if any(adjustfd)
    b = pvget(mstart,'b');
    bb= zeros(size(b));
    [dum1,nbbt]=size(bb);
    for ku=1:nu
        if adjustfd(ku)
            bb(ku,1:nbbt-1) = b(ku,2:end);
        else
            bb(ku,:)=b(ku,:);
        end
    end
    mstart = pvset(mstart,'b',bb);
end
if ncd >0
    noisem = d2c(mstart('n'));
else
    noisem = [];
end

zeta = zeros(nu,1);
Tp1 = zeros(nu,1);
Tw= zeros(nu,1);
Tp2 = zeros(nu,1);
Tp3 = zeros(nu,1);
Td = zeros(nu,1);
Tz = zeros(nu,1);
intc = pvget(z,'InterSample');
Tsm = pvget(mstart,'Ts');
for ku = 1:nu
    type = typec{ku};
    if eval(type(2))==1&any(type=='Z')
        p1z = 1;
    else
        p1z = 0;
    end
    
    int = intc{ku};% Same for all experiments
    hold = lower(int(1)); %cf intorig
    msta = mstart(1,ku);
    %%  1. The static gain:
    
    Kp(ku) = sum(pvget(msta,'b'))/sum(pvget(msta,'f'));
    
    %% 2. The Time constants
    if eval(type(2))>0
        F = pvget(msta,'f');
        
        nf = length(F)-1;
        af=diag(ones(nf-1,1),1);
        try
            af(:,1)=-F(2:end).';
        catch
            error('Initialization failed. Data might not be sufficiently exciting.')
        end
        ac = real(logm(af)/Tsm); % The continuous time A-matrix
        if any(isnan(ac(:)))
            error('Initialization failed. Data might not be sufficiently exciting.')
        end
        rr = eig(ac);
        
        if eval(type(2))==1 
            Tp1(ku) = -1/rr(1);  
        elseif eval(type(2))==2
            if any(type=='U')
                Tw(ku) = 1/sqrt(abs(rr(1)*rr(2)));
                zeta(ku) = abs(1/rr(1)+1/rr(2))/Tw(ku)/2;
            else
                if isreal(rr(1))
                    Tp1(ku) = -1/rr(1);
                    Tp2(ku) = -1/rr(2);
                else % we have to estimate in two steps. Think over nb(ku)!
                    disp(sprintf(['There is an indication that the poles may',...
                            ' be underdamped.\nConsider the possibility to',...
                            ' use an underdamped model \n(Include ''U'' in the model',...
                            ' definition.)']));
                    mstart1 = oe(z(:,:,ku),[1 1 nk(ku)]);
                    f = pvget(mstart1,'f');
                    
                    mc1=d2c(mstart1);
                    f1 = roots(mc1.f);
                    u = pvget(z(:,:,ku),'InputData');
                    for kexp = 1:length(u)
                        uf{kexp} = filter(1,f,u{kexp});%%LL funkar ej om FDDATA
                    end
                    zf = iddata(z.y,uf,pvget(z,'Ts'));
                    zf = idfilt(z(:,:,ku),{1,f});
                    m2=oe(zf,[1,1,nk(ku)]);
                    m2c = d2c(m2);
                    f2=roots(pvget(m2c,'f'));
                    Tp1(ku) = -1/f1;
                    Tp2(ku)=-1/f2;
                end    
            end    % end type 2
        else %type = 3
            rnr = find(imag(rr)==0);
            cnr = find(abs(imag(rr))>0);
            if any(type=='U')
                if isempty(cnr),
                    if rr(1)*rr(2)>0
                        cnr = [1 2]; rnr = 3;
                    elseif rr(2)*rr(3)>0
                        cnr = [2 3]; rnr = 1;
                    else
                        cnr = [1 3]; rnr = 2;
                    end
                    
                end
                Tp3(ku) = -1/rr(rnr); % To ensure stability
                Tw(ku) = real(1/sqrt(rr(cnr(1))*rr(cnr(2))));
                zeta(ku) = -(1/rr(cnr(2))+1/rr(cnr(1)))/Tw(ku)/2;
            else
                if isreal(rr)
                    Tp1(ku)=-1/rr(1);Tp2(ku)=-1/rr(2);Tp3(ku)=-1/rr(3);
                else % consider doing the same as above
                    disp(sprintf(['There is an indication that the poles may',...
                            ' be underdamped.\nConsider the possibility to',...
                            ' use an underdamped model. \n(Include ''U'' in the model',...
                            ' definition.)']));
                    Tp1(ku) = -1/rr(rnr);
                    Tp2(ku) = -1/real(rr(cnr(1)))/1.5;
                    Tp3(ku) = -1/real(rr(cnr(1)))*1.5;
                end       
            end
        end    % time constants/poles
    end
    % 3 Now find the zero and time delay if applicable
    
    if any(type=='D') & ~tdflag(ku)
        if eval(type(2))==0
            b = pvget(msta,'b');
            nk1 = pvget(msta,'nk');
            if int=='foh'
                nk1=nk1+1;
            end
            if hold == 'z'
                Td(ku)= (nk1-1)*Ts{1}+0.001;
            else
                Td(ku) = (nk1-1)*Ts{1}+b(end)/sum(b)*Ts{1};
            end
            if any(type=='I') & fd
                Td(ku)=Td(ku)-Tsm; %%WHY
            end
        else
            
            if any(type=='Z')
                zflag = 1;
            else 
                zflag =0;
            end
            yh= sim(msta,z(:,[],ku));
            zt = z(:,:,ku); zt.y = yh.y; nk1 = pvget(msta,'nk');
            F = pvget(msta,'f');
            nf = length(F)-1;
            af=diag(ones(nf-1,1),1);
            af(:,1)=-F(2:end).';
            ac = real(logm(af)/Tsm); % The continuous time A-matrix
            acp = poly(ac); %observer can form
            kcomp = acp(end);
            kk = kcomp*Kp(ku);
            
            m0 = idpoly(1,kk,1,1,acp,'ts',0);
            m0 = pvset(m0,'InputName',get(zt,'InputName'),'OutputName',pvget(zt,'OutputName'));
            % first a broader scan:
            for ktau = 1:30
                tautest = ((nk1-2)+(ktau-1)/30*4)*Tsm;
                if tautest>0
                    tfit(ktau) = findtau(tautest,m0,Tsm,zt,zflag);
                else
                    tfit(ktau)= inf;
                end
            end
            [dum,ktaumin] = min(tfit);
            uulim = ((nk1-2)+(ktaumin-1)/30*4)*Tsm;
            %ulim = uulim + Tsm;
            llim = max(0,uulim - Tsm);
            ulim = llim + 2*Tsm;
            % Now minimize
            Td(ku) = fminbnd('findtau',llim,ulim,[],m0,Tsm,zt,zflag);
            
            if zflag
                [dum,Tz(ku)] = findtau(Td(ku),m0,Tsm,zt,zflag);
            end
            if any(type=='I') & fd
                Td(ku)=Td(ku)-Tsm; %%WHY
            end
        end
        
    elseif any(type=='Z')
        yh= sim(msta,z(:,[],ku));
        zt = z(:,:,ku); zt.y = yh.y; nk1 = pvget(msta,'nk');
        F = pvget(msta,'f');
        nf = length(F)-1;
        af=diag(ones(nf-1,1),1);
        af(:,1)=-F(2:end).';
        ac = real(logm(af)/Tsm); % The continuous time A-matrix
        acp = poly(ac); %observer can form
        kcomp = acp(end);
        kk = kcomp*Kp(ku);
        
        m0 = idpoly(1,kk,1,1,acp,'ts',0);
        m0 = pvset(m0,'InputName',get(zt,'InputName'),'OutputName',pvget(zt,'OutputName'));
        % yh= sim(msta,z(:,[],ku));
        %zt = z(:,:,ku); zt.y = yh.y; nk1 = pvget(msta,'nk');
        [dum,Tz(ku)] = findtau(0,m0,Tsm,zt,1);
    end
    
    if kflag(ku)  
        Kp(ku) = kpi(ku);
    end
    if tp1flag(ku)
        Tp1(ku) = tp1i(ku);
    end
    if tp2flag(ku)
        Tp2(ku) = tp2i(ku);
    end
    if tp3flag(ku)
        Tp3(ku) = tp3i(ku);
    end
    if twflag(ku)
        Tw(ku) = twi(ku);
    end
    if zetaflag(ku)
        zeta(ku) = zetai(ku);
    end
    if tzflag(ku)
        Tz(ku) = tzi(ku);
    end
    if tdflag(ku)
        Td(ku) = tdi(ku);
    end
end %ku
m = pvset(m,'Kp',Kp,'Tp1',Tp1,'Tp2',Tp2,'Tw',Tw,'Zeta',zeta,'Tp3',Tp3,...
    'Td',Td,'Tz',Tz);%,'Type',m.Type);
if ncd>0
    noisem = pvset(noisem,'ParameterVector',abs(pvget(noisem,'ParameterVector')));
    m = pvset(m,'DisturbanceModel',{fa{3},noisem});
end

