function m = inival_pm1(z,m)

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/10 23:17:11 $

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
for ku = 1:nu
    type = typec{ku};
    if any(type=='I')
        for kexp = 1:Nexp
            if ~fd
                yd{kexp} = y{kexp}(2:end,:);
                ud{kexp}(:,ku) = cumsum(u{kexp}(1:end-1,ku))*Ts{kexp};
            else
                yd{kexp} = y{kexp};
                if Ts{kexp}>0
                    rat = 1-exp(-i*samp{kexp}*Ts{kexp});
                else
                    rat = i*samp{kexp};
                end
                ud{kexp}(:,ku)=u{kexp}(:,ku)./(rat)*Ts{kexp};
                if eval(type(2))>0,adjustfd(ku) = 1;end
            end
            int{ku,kexp} = 'foh';
        end
        z = pvset(z,'OutputData',yd,'InputData',ud,'InterSample',int(ku));%,...
    end% end of adjusting data for integration
    % adjust data to include possible info about static gain:
    kpiku = kpi(ku);
    if ~isinf(kpiku)&~isnan(kpiku) %% nu>1
        Nm = sum(N)*5;
        zm = iddata(kpiku*ones(Nm,1),[zeros(Nm,ku-1),ones(Nm,1),zeros(Nm,nu-ku)],Ts{1});
        if fd
            zm = fft(zm);
        end
        z = merge(z,zm);
        kflag(ku) = 1;
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
            if fhold|~fd
                nb(ku) = 3;
                nk(ku) = 0;
            end
        case {'P2D','P2DI','P2DU','P2DIU'}
            nf(ku) = 2; nb(ku) = 3; nk(ku) = 1;
            if fhold
                nb(ku) = 4;
                nk(ku) = 0;
            end
        case {'P2DZ','P2DZI','P2DZU','P2DZIU'}
            nf(ku) = 2; nb(ku) = 3;
            if fhold
                nb(ku) = 4;
            end
            
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
        case {'P3D','P3DI','P3DU','P3DIU'}
            nf(ku) = 3; nb(ku) = 4;
            if fhold
                nb(ku) = 5;
            end
        case {'P3DZ','P3DZI','P3DZU','P3DZIU'}
            nf(ku) = 3; nb(ku) = 4;
            if fhold
                nb(ku) = 5;
            end
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
            nk(ku) = delayest(z(:,1,ku),nf1(ku),nb(ku),m.Td.min(ku)/Ts{1},m.Td.max(ku)/Ts{1});
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
%[nb nf nk]
mstart = bj(z,[nb ncd ncd nf nk],'cov','none','ini','e');
%mstart.cov = 'none';
if any(adjustfd)
    b = pvget(mstart,'b');
    bb= zeros(size(b));
    [dum1,nbbt]=size(bb);
    for ku=1:nu
        if adjustfd(ku)
            bb(ku,1:nbbt-1) = b(ku,2:end);
        end
    end
    mstart = pvset(mstart,'b',bb);
end
if ncd >0
    mc = d2c(mstart);
    noisem = idpoly(mc.d,[],mc.c,'Ts',0);
else
    noisem = [];
end
zeta = zeros(nu,1);
Tp1 = zeros(nu,1);
Tres = zeros(nu,1);
Tp2 = zeros(nu,1);
Tp3 = zeros(nu,1);
Td = zeros(nu,1);
intc = pvget(z,'InterSample');
p1z=0;
if eval(type(2))==1&any(type=='Z')
    p1z = 1;
end
for ku = 1:nu
    type = typec{ku};
    int = intc{ku};% Same for all experiments
    hold = lower(int(1)); %cf intorig
    msta = mstart(1,ku);
    
    if any(type=='D')
        nk1 = pvget(msta,'nk');  
        if hold=='z'& ~p1z  
            msta = pvset(msta,'nk',1);
        else
            msta = pvset(msta,'nk',0);
            nk1 = nk1 +1;
        end
        if eval(type(2))==0&any(type=='I')&fhold&~fd
            nk1 = nk1+1;
        end
        if p1z&~fhold|(~fhold& (eval(type(2))==0)&any(type=='I')&fd) 
            nk1 = nk1-1;
        end
        if pvget(msta,'nf')==0
            b = pvget(msta,'b');
            if hold == 'z'
                Td(ku)= (nk1-1)*Ts{1}+0.001
            else
                Td(ku) = (nk1-1)*Ts{1}+b(end)/sum(b)*Ts{1}
            end
            ms = msta;
            ms = pvset(ms,'b',sum(b));
        else
            try
                [ms,tau1]=idfindtau2(msta,p1z);
            catch
                ms = d2c(msta);tau1=0;
            end
            Td(ku) = tau1 + (nk1-1)*Ts{1};
        end
    else
        if nf==0
            msta.b = sum(msta.b);
        end
        try
            ms = d2c(msta);
        catch
            error('Conversion to continuous time failed.')
        end
    end
    % Now extract The process parameters.
    b = pvget(ms,'b');
    f = pvget(ms,'f');
    if eval(type(2))==0
        Kp(ku)=b(end);
    elseif eval(type(2))==1&nb(ku)==2
        Kp(ku) = b(end)/f(end);
        msd=pvset(mstart(1,ku),'nk',0);
        mss = idpoly(d2c(idss(msd)));
        b1 = pvget(mss,'b');
        
        a = pvget(mss,'a');
        Tp1(ku) = 1/a(end);
        Tz(ku) = b1(2)/b1(1);
    else % order larger than 1 or equal to and no zero
        
        Kp(ku) = b(end)/f(end);
        rr = roots(f);
        if eval(type(2))==1 %%LL 
            Tp1(ku) = -1/rr(1); %%LL 
            Tp2(ku) = 0; %%
        elseif eval(type(2))==2
            if any(type=='U')
                Tres(ku) = 1/sqrt(abs(rr(1)*rr(2)));
                zeta(ku) = abs(1/rr(1)+1/rr(2))/Tres(ku)/2;
            else
                if isreal(rr(1))
                    Tp1(ku) = -1/rr(1);
                    Tp2(ku) = -1/rr(2);
                else % we have to estimate in two steps
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
                        uf{kexp} = filter(1,f,u{kexp});
                    end
                    zf = iddata(z.y,uf,pvget(z,'Ts'));
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
                    cnr = [1 2]; rnr = 3;
                end
                Tp3(ku) = -1/rr(rnr);
                Tres(ku) = 1/sqrt(rr(cnr(1))*rr(cnr(2)));
                zeta(ku) = -(1/rr(cnr(2))+1/rr(cnr(1)))/Tres(ku)/2;
            else
                if isreal(rr)
                    Tp1(ku)=-1/rr(1);Tp2(ku)=-1/rr(2);Tp3=-1/rr(3);
                else
                    disp(sprintf(['There is an indication that the poles may',...
                            ' be underdamped.\nConsider the possibility to',...
                            ' use an underdamped model. \n(Include ''U'' in the model',...
                            ' definition.)']));
                    Tp1(ku) = -1/rr(rnr);
                    Tp2(ku) = -1/real(rr(cnr(1)))/1.5;
                    Tp3(ku) = -1/real(rr(cnr(1)))*1.5;
                end       
            end
        end
    end
    if any(type=='Z')
        Tztemp = -ones(size(roots(b)))./roots(b);
        [dum,bnr]=max(abs(Tztemp));
        Tz(ku)=real(Tztemp(bnr));
        if isempty(Tztemp), Tz(ku) = 0.1;end %%LL
    else
        Tz(ku) = 0;
    end
    
    if kflag(ku)  
        Kp(ku) = kpi(ku);
    end
    
end %ku
m = pvset(m,'Kp',Kp,'Tp1',Tp1,'Tp2',Tp2,'Tw',Tres,'Zeta',zeta','Tp3',Tp3,...
    'Td',Td,'Tz',Tz);%,'Type',m.Type);
if ncd>0
    m = pvset(m,'DisturbanceModel',{fa{3},noisem});
end



