function m=arx(varargin)
%ARX    Computes LS-estimates of ARX-models.
%   M = ARX(DATA,ORDERS)
%
%   M: returned with the estimated parameters of the ARX model
%   A(q) y(t) = B(q) u(t-nk) + e(t)
%   along with estimated covariances and structure information.
%   For single output systems, M is an IDPOLY model object, while
%   for multi-outputs systems, M is an IDARX object. 
%   See IDPROPS, IDPROPS IDPOLY, or IDPROPS IDARX for all details.
%
%   DATA: The estimation data as an IDDATA or IDFRD object. 
%         See  HELP IDDATA or HELP IDFRD.
%   
%   ORDERS = [na nb nk], the orders and delays of the above model.
%   For multi-output systems, ORDERS has as many rows as there are outputs
%   na is then an ny|ny matrix whose i-j entry gives the order of the
%   polynomial (in the delay operator) relating the j:th output to the
%   i:th output. Similarly nb and nk are ny|nu matrices. (ny:# of outputs,
%   nu:# of inputs). For a time series, ORDERS = na only.
% 
%   An alternative syntax is m = ARX(DATA,'na',na,'nb',nb,'nk',nk)
%
%   In the multi-output case, ARX minimizes the norm E'*E, where E are the 
%   prediction errors. This can be changed to an arbitrary quadratic norm
%   E'*inv(LAMBDA)*E by M = ARX(DATA,M0), where M0 is an initial model of
%   the desired orders with M0.NoiseVariance = LAMBDA. 
%
%   Parameters and options associated with the algorithm can be set as property/
%   value pairs in any order. Omitted properties are given default values. Typical
%   options to use are:
%   
%   FOCUS ('Prediction', 'simulation', 'stability' or a prefilter.)
%   INPUTDELAY
%   FIXEDPARAMETER (Parameters in a nominal model to remain fixed.)
%   NOISEVARIANCE (Determines the output norm in the multioutput case.)
%   MAXSIZE  (Determines the size of the largest matrix to be formed.)
%
%   See also IDPROPS ALGORITHM and IDPROPS IDMODEL for more details,
%   ARXSTRUC, SELSTRUC for how to estimate the order parameters, and
%   AR, ARMAX, BJ, IV4, N4SID, OE, PEM for other estimation routines.

%   L. Ljung 10-1-86,12-8-91
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.35.4.2 $  $Date: 2004/04/10 23:18:51 $


wtxt1 = []; wtxt2 =[]; %variables fos possible warnings in EstimationInfo
if nargin <2
    disp('Usage: M = ARX(DATA,ORDERS)')
    disp('       M = ARX(DATA,ORDERS,Prop/Value pairs)')
    if nargout, m = [];end
    return
end
try
    [mdum,data,p,fixflag,fixp] = arxdecod(varargin{:});
catch
    error(lasterr)
end
Name ='';
if isa(data,'iddata')
    dom = pvget(data,'Domain');
    data = setid(data);
    if isempty(pvget(data,'Name'))
        data = pvset(data,'Name',inputname(1));
    end
    mdum = setdatid(mdum,getid(data));
    
else
    dom = 'Time';
end
if isa(mdum,'idarx')
    try
         m = arx(data,mdum); % what about p?
    catch
        error(lasterr)
    end
    if fixflag
        try
            m = idpoly(m);
        catch
            error(sprintf(['The fixed parameters are such that they correspond to a',...
                    '\nchange of na, nb and/or nk. Do that correct definition of model orders',...
                    '\nrather than fixing parameters.']))
        end
    end
    return
end


if p~=1 % This is a call from inival or iv
    maxsize = varargin{3};
    ze = data;
    if ~iscell(ze),ze={ze};end
    Ne = length(ze);
    ny = 1;
    Ncaps =[];
    nz = size(ze{1},2);
    nu = nz-1;
    for kexp = 1:Ne
        Ncaps = [Ncaps,size(ze{kexp},1)];
    end
    if isempty(maxsize)|ischar(maxsize)
        maxsize=idmsize(max(Ncaps));
    end
    na = mdum(1);
    nb = mdum(2:nu+1);
    nk = mdum(nu+2:end);
    foc = 'Prediction';
else
    na =pvget(mdum,'na');
    nb = pvget(mdum,'nb');
    nk = pvget(mdum,'nk');
    Inpd = pvget(mdum,'InputDelay');
    foc = pvget(mdum,'Focus');
    foc0 = foc;
    data = nkshift(data,Inpd); 
    [ze,Ne,ny,nu,Ts,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
    error(errflag)
    if nu == 0 & ~strcmp(foc,'Prediction')
        warning('For time-series ''Focus'' does not apply.')
        mdum = pvset(mdum,'Focus','Prediction');
        foc = 'Prediction';
    end
    
    maxsize = pvget(mdum,'MaxSize'); 
    if ischar(maxsize)|isempty(maxsize),
        maxsize=idmsize(max(Ncaps));
    end
    
end
n=na+sum(nb);
if n==0,
    th=[];
    if p>0, warning('All orders are zero. No model returned.');end
    return
end
if (ischar(foc)&any(strcmp(foc,{'Simulation','Stability'})))|~ischar(foc) %% The focus
    mdum = pvset(mdum,'Focus','Prediction','InputDelay',zeros(nu,1));
    m0 = arx(data,mdum);
    if ischar(foc)&strcmp(foc,'Stability')
        a = pvget(m0,'a');
        alg = pvget(m0,'Algorithm');
        Ts = pvget(m0,'Ts');
        if Ts>0
            thresh = alg.Advanced.Threshold.Zstability;
        else
            thresh = alg.Advanced.Threshold.Sstability;
        end
        if (Ts>0&any(abs(roots(a))>thresh))|(Ts==0&any(real(roots(a))>thresh)) 
             a = fstab(a,Ts,thresh);
            %m0 = pvset(m0,a);
            if Ts>0 %No filtering in CT since filter is not proper.
            y = data(:,:,[]);
            yt = idfilt(y,{a,1});
            datat = data;
            datat(:,:,[]) = yt;
            m1 = arx(datat,m0,'na',0);
        else
            m1 = m0;
        end
            m = pvset(m1,'a',a,'InputDelay',Inpd);
            es = pvget(m,'EstimationInfo');
            es.Method = 'ARX (Stabilized)';
            m = pvset(m,'EstimationInfo',es,'Focus',foc0);
        else
            m = pvset(m0,'Focus',foc0,'InputDelay',Inpd);
        end
        return
        
    elseif isa(foc,'idmodel')|isa(foc,'lti') |iscell(foc)
        ts = pvget(data,'Ts');ts=ts{1};
        foc = foccheck(foc,ts,pvget(m0,'a'));
        
        %         if isa(foc,'idmodel')|isa(foc,'lti')%check Ts and stab
        %             [num,den] = tfdata(foc,'v');
        %             foc={num,conv(den,pvget(m0,'a'))};% wshat if a unstable? allpass!
        %         end
        
    elseif strcmp(foc,'Simulation')
        foc = foccheck({1,1},1,pvget(m0,'a'));
    end
    
    zf = idfilt(data,foc);
    m = arx(zf,mdum,'focus','stability');
    es = pvget(m,'EstimationInfo');
    es.Method = 'ARX with focus';
    
    m = pvset(m,'EstimationInfo',es,'InputDelay',Inpd,'Focus',foc0);
    return
end
if lower(dom(1))=='f'
    mdum = pvset(mdum,'MaxSize',maxsize);
    [mdum,V,Ncapeff,cov,Rp,rankflag] = arx_f(data,mdum);
    
    if rankflag
        warning('InitialState set to ''z''. Data info do not support estimation of InitialState.')
        mdum = pvset(mdum,'InitialState','z');
        [mdum,V,Ncapeff,cov,Rp,rankflag] = arx_f(data,mdum);
    end
    th = pvget(mdum,'ParameterVector');
    if na==0
        try
            Rpf = covoe_f(data,mdum);
        catch
            Rpf = eye(size(Rp));
        end
        cov = (Rp*Rp')*(Rpf'*Rpf)*(Rp*Rp');
    end
    
else
    nmax=max([na+1 nb+nk])-1;
    M=floor(maxsize/n);
    R1 = zeros(0,n+1);
    for kexp = 1:Ne
        z = ze{kexp}; 
        [Ncap,nz]=size(z);
        % *** construct regression matrix ***
        for k=nmax:M:Ncap-1
            jj=(k+1:min(Ncap,k+M));
            phi=zeros(length(jj),n);
            for kl=1:na, phi(:,kl)=-z(jj-kl,1);end
            ss=na;
            for ku=1:nu
                for kl=1:nb(ku), phi(:,ss+kl)=z(jj-kl-nk(ku)+1,ku+1);end
                ss=ss+nb(ku);
            end
            R1 = triu(qr([R1;[phi,z(jj,1)]]));[nRr,nRc]=size(R1);
            R1 = R1(1:min(nRr,nRc),:);
        end
    end
    %
    % *** compute estimate ***
    %
    if size(R1,1)<n+1
        error(['There are too many parameters to estimate for this amount' ...
                ' of data.'])
    end
    regm = R1(1:n,1:n);
    if rank(regm)<n
        warning(sprintf(['The input is apparently not sufficiently '...
                'exciting for the chosen model order.',...
                '\nRun ADVICE(',Name,') for more information',...
                '\nThe resulting model and its covariance matrix may be unreliable.']));
        wtxt1 ='Non-persisting input. Model and Covariance Matrix Unreliable.';
    end
    Rp = pinv(R1(1:n,1:n)); 
    th = Rp * R1(1:n,n+1);
    Ncapeff = sum(Ncaps) - Ne*nmax -length(th);
    V = R1(n+1,n+1)^2/Ncapeff;
    if p==0, m=th;return,end
    Rpp = Rp*Rp';
    if p==2|(isa(mdum,'idpoly')&~strcmp(pvget(mdum,'CovarianceMatrix'),'None'))
        if na == 0 % Make a variance estimate adjusted to the OE-structure.
            if (M > Ncap-1)&Ne==1  % PHI still alive
                e = z(jj,1) - phi*th;
                try
                    was = warning;
                    warning off
                    me = n4sid(e,5,'cov','none');
                    warning(was)
                    me = pvset(me,'A',oestab(pvget(me,'A'),0.99,1));
                catch
                    me = idpoly(1,1,'Noisevariance',V);
                end
                [num,den] = tfdata(me,'v');
                phif = filter(num,den,phi(end:-1:1,:));
                cov = pvget(me,'NoiseVariance')*Rpp*(phif'*phif)*Rpp;
            else
                cov = covoe(ze,th,nmax,n,nb,nk,Rpp,M,V);
            end
        else
            cov = V*Rpp;
        end
        try
            norm(cov);
        catch
            wtxt2 = 'Covariance Matrix Ill-conditioned. Not stored.'
            warning(wtxt2)
            cov = [];
        end
        
    else
        cov = 'None';
    end
    if p==2, m.par = th; m.sd = sqrt(diag(cov));m.cov = V*(Rp*Rp');return,end
end % if domain == 'f'
idm = pvget(mdum,'idmodel');
it_inf = pvget(idm,'EstimationInfo');
if ~isempty(wtxt1)
    it_inf.Warning = wtxt1;
elseif ~isempty(wtxt2)
    it_inf.Warning = wtxt2;
end
it_inf.Method = 'ARX';
it_inf.DataLength=sum(Ncaps);
it_inf.DataTs=Ts;
it_inf.DataDomain = pvget(data,'Domain');
it_inf.DataInterSample=pvget(data,'InterSample'); 
it_inf.Status='Estimated model (ARX)';
it_inf.DataName=Name;
it_inf.InitialState = pvget(mdum,'InitialState');
it_inf.LossFcn = V*Ncapeff/sum(Ncaps); 
it_inf.FPE = it_inf.LossFcn*(1+length(th)/sum(Ncaps))/(1-length(th)/sum(Ncaps));
if ~ischar(cov)&~isempty(cov)
    if size(cov,1)~=size(cov,2)|size(cov,1)~=length(th)
        cov =[];
        warning('Calculation of covariance matrix failed.');
    end
end
idm = pvset(idm,'ParameterVector',th,'CovarianceMatrix',cov,...
    'EstimationInfo',it_inf,'Ts',Ts,'NoiseVariance',V);
idm = idmname(idm,data);
m = llset(mdum,{'idmodel'},{idm});

m = timemark(m);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cov = covoe(ze,th,nmax,n,nb,nk,Rp,M,V);
Ne = length(ze);
R1 = zeros(0,n+1);
nu = length(nb);
for kexp = 1:Ne
    z = ze{kexp}; 
    [Ncap,nz]=size(z);
    e{kexp} = zeros(Ncap-nmax,1);
    % *** construct regression matrix ***
    for k=nmax:M:Ncap-1
        jj=(k+1:min(Ncap,k+M));
        phi=zeros(length(jj),n);
        ss=0;
        for ku=1:nu
            for kl=1:nb(ku),
                phi(:,ss+kl)=z(jj-kl-nk(ku)+1,ku+1);
            end
            ss=ss+nb(ku);
        end
        e{kexp}(jj) = z(jj,1) - phi*th;
    end
end
data = iddata(e,[]);
try
    me = n4sid(data,5,'cov','none');
    me = pvset(me,'A',oestab(pvget(me,'A'),0.99,1));
catch
    me = idpoly(1,1,'NoiseVariance',V);
end
[num,den] = tfdata(me,'v');
for kexp = 1:Ne
    z = ze{kexp}; 
    [Ncap,nz]=size(z);
    % *** construct regression matrix ***
    for k=nmax:M:Ncap-1
        jj=(k+1:min(Ncap,k+M));
        phi=zeros(length(jj),n);
        
        ss = 0;
        for ku=1:nu
            for kl=1:nb(ku), phi(:,ss+kl)=z(jj-kl-nk(ku)+1,ku+1);end
            ss=ss+nb(ku);
        end
        phif = filter(num,den,phi(end:-1:1,:));
        R1 = triu(qr([R1;[phif,z(jj,1)]]));[nRr,nRc]=size(R1);
        R1 = R1(1:min(nRr,nRc),:);
    end
end
Rpf = R1(1:n,1:n);
cov = pvget(me,'NoiseVariance')*Rp*(Rpf'*Rpf)*Rp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m,V,Nc,cov,Rp,rankflag] = arx_f(data,mdum)
m = mdum;
V = [];
cov=[];
Rp =[];
if realdata(data)
    realflag = 1;
else
    realflag = 0;
end
rankflag = 0;
data = complex(data);
na = pvget(mdum,'na');
nb = pvget(mdum,'nb');
n0=na+sum(nb);
nk = pvget(mdum,'nk');
idfrdflag = 0;
try
    ut = pvget(data,'Utility');
    if ut.idfrd
        idfrdflag = 1;
    end
end
if idfrdflag
    mdum = pvset(mdum,'InitialState','Zero');
end
ini = pvget(mdum,'InitialState');
ini = lower(ini(1));
T = pvget(mdum,'Ts');
maxsize = mdum.maxsize;
Yc = pvget(data,'OutputData');
Uc = pvget(data,'InputData');
Wc = pvget(data,'Radfreqs');
Tsdat = pvget(data,'Ts');
Nexp = length(Uc);
nuorig = size(Uc{1},2);
if ini~='z' % Then add extra inputs
    if ~isempty(nb)
    nb = [nb,max(na,max(nb+nk))*ones(1,Nexp)]; %%LL order max(na,nb+nk)??
    end
    if isempty(nb)
        nk = nb;
    else
    nk = [nk,ones(1,Nexp)];
end
    for kexp = 1:Nexp
        Uc{kexp} = [Uc{kexp},zeros(size(Uc{kexp},1),Nexp)];
        Uc{kexp}(:,nuorig+kexp) = exp(i*Wc{kexp}*Tsdat{kexp});
    end
end
nm = max([na,nb+nk-1]);
nu = length(nb);
n1 = na + sum(nb);
R1=zeros(0,n1+1);
N = 0;
if isempty(maxsize)|ischar(maxsize) % safety
    maxsize = idmsize;
end

M = floor(maxsize/(nm+1));
for kexp = 1:Nexp
    Y1 =Yc{kexp};
    U1 = Uc{kexp};
    w1 = Wc{kexp};
    Ncap = size(Y1,1);

    N=N+Ncap;
    for kM = 1:M:Ncap
         jj=(kM:min(Ncap,kM-1+M));
         w = w1(jj);
         Y = Y1(jj,:);
         U = U1(jj,:);
    if Tsdat{kexp}>0,
        OM=exp(-i*[0:nm]'*w'*Tsdat{kexp});
        inda = 2:na+1;
        YY = Y;
    else 
        OM=ones(1,length(w));
        for kom=1:nm
            OM=[OM;(i*w').^kom];
        end
        inda = na:-1:1;
        YY = Y.*OM(na+1,:).';
    end
    D = (OM(inda,:).').*(-Y*ones(1,na));
    for ku = 1:nu
        if Tsdat{kexp}>0, 
            ind=nk(ku)+1:nk(ku)+nb(ku);
        else 
            ind=nb(ku):-1:1;
        end	
        temp=(OM(ind,:).').*(U(:,ku)*ones(1,nb(ku)));
        D=[D temp]; 
    end
    if realflag
        R1=triu(qr([R1;[[real(D);imag(D)],[real(YY);imag(YY)]]]));
    else
        R1=triu(qr([R1;[D,YY]]));
    end
    [nRr,nRc]=size(R1);
    R1=R1(1:min(nRr,nRc),:);
end
end
R=R1(1:n1,1:n1);Re=R1(1:n1,n1+1);
V = R1(end,end).^2/(N-na-sum(nb));
Nc = N-na-sum(nb);
if (rank(R)<size(R,1))&ini~='z'
    rankflag = 1;
    return
end
t = pinv(R)*Re;
a = [1 t(1:na).'];
b = [];
ind = na;
for ku = 1:nuorig
    b = idextmat(b,[zeros(1,nk(ku)),t(ind+1:ind+nb(ku)).'],Tsdat{1});
    ind = ind + nb(ku);
end
m = pvset(mdum,'a',a,'b',b,'Ts',Tsdat{1});%%LL Ts
Rp = pinv(R(1:n0,1:n0)); 
cov = V*Rp*Rp';
%  e = pe(m,data,'z');
%  ee=e.y;%pvget(e,'OutputData');
%  V = ee'*ee/length(ee)%%LL adjust with parameter length

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Rpf] = covoe_f(data,mdum)
if realdata(data)
    realflag = 1;
else
    realflag = 0;
end
data = complex(data);
was = warning;
warning('off')
e = pe(data,mdum);
%lastwarn('')
warning(was)
ec = pvget(e,'OutputData');
na = pvget(mdum,'na');
nb = pvget(mdum,'nb');
n0=na+sum(nb);
nk = pvget(mdum,'nk');
ini = pvget(mdum,'InitialState');
T = pvget(mdum,'Ts');
maxsize = pvget(mdum,'MaxSize');
Yc = pvget(data,'OutputData');
Uc = pvget(data,'InputData');
Wc = pvget(data,'Radfreqs');
Tsdat = pvget(data,'Ts');
Nexp = length(Uc);
nuorig = size(Uc{1},2);
if lower(ini(1))~='z' % Then add extra inputs
    nb = [nb,na*ones(1,Nexp)];
    nk = [nk,ones(1,Nexp)];
    for kexp = 1:Nexp
        Uc{kexp} = [Uc{kexp},zeros(size(Uc{kexp},1),Nexp)];
        Uc{kexp}(:,nuorig+kexp) = exp(i*Wc{kexp}*Tsdat{kexp});
    end
end
nm = max([na,nb+nk-1]);
nu = length(nb);
n1 = na + sum(nb);
R1=zeros(0,n1+1);
N = 0;
if isempty(maxsize)|ischar(maxsize) % safety
    maxsize = idmsize;
end

M = floor(maxsize/(nm+1));
for kexp = 1:Nexp
    Y1 =Yc{kexp};
    U1 = Uc{kexp};
    w1 = Wc{kexp};
    Ncap = size(Y1,1);

    N=N+Ncap;
    for kM = 1:M:Ncap
         jj=(kM:min(Ncap,kM-1+M));
         w = w1(jj);
         Y = Y1(jj,:);
         U = U1(jj,:);

% for kexp = 1:Nexp
%     Y =Yc{kexp};
%     U = Uc{kexp};
%     w = Wc{kexp};
%     N=N+size(Y,1);
%     
    if Tsdat{kexp}>0,
        OM=exp(-i*[0:nm]'*w'*Tsdat{kexp});
        inda = 2:na+1;
        YY = Y;
    else 
        OM=ones(1,length(w));
        for kom=1:nm
            OM=[OM;(i*w').^kom];
        end
        inda = na:-1:1;
        YY = Y.*OM(na+1,:).';
    end
    D = (OM(inda,:).').*(-Y*ones(1,na));
    for ku = 1:nu
        if Tsdat{kexp}>0, 
            ind=nk(ku)+1:nk(ku)+nb(ku);
        else 
            ind=nb(ku):-1:1;
        end	
        temp=(OM(ind,:).').*(U(:,ku)*ones(1,nb(ku)));
        D=[D temp]; 
    end
    % For the filtering in the OE case
    D = D .* abs(ec{kexp}*ones(1,size(D,2)));
    % end filtering
    if realflag
        R1=triu(qr([R1;[[real(D);imag(D)],[real(YY);imag(YY)]]]));
    else
        R1=triu(qr([R1;[D,YY]]));
    end
    [nRr,nRc]=size(R1);
    R1=R1(1:min(nRr,nRc),:);
end
end
R=R1(1:n1,1:n1);Re=R1(1:n1,n1+1);
V = R1(end,end).^2/(N-na-sum(nb));
Nc = N-na-sum(nb);
t = pinv(R)*Re;
a = [1 t(1:na).'];
b = [];
ind = na;
for ku = 1:nuorig
    b = idextmat(b,[zeros(1,nk(ku)),t(ind+1:ind+nb(ku)).'],Tsdat{1});
    ind = ind + nb(ku);
end
m = pvset(mdum,'a',a,'b',b);
Rpf = R(1:n0,1:n0); 
% cov = V*Rp*Rp';
%  e = pe(m,data,'z');
%  ee=e.y;%pvget(e,'OutputData');
%  V = ee'*ee/length(ee)%%LL adjust with parameter length