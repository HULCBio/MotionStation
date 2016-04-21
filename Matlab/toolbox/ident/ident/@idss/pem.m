function m=pem(data,m0,varargin)
%PEM	Computes the prediction error estimate of a general linear model.
%   M = PEM(Z,Mi)  
%
%   M : returns the estimated model in the IDSS object format
%   along with estimated covariances and structure information. 
%   For the exact format of M see also help IDSS.
%
%   Z :  The estimation data in IDDATA object format. See help IDDATA
%
%   Mi: An IDSS model object that defines the model structure. 
%	 The minimization is initialized at the parameters given in Mi. 
%
%   By M = pem(Z,Mi,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See help IDSS or help IDPOLY for a list of
%   Property/Value pairs.

%	L. Ljung 10-1-86, 7-25-94
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.32 $  $Date: 2003/11/11 15:52:52 $

if nargin<1
    disp('       M = PEM(Z,Mi)  For IDSS model Mi')
    disp('       M = PEM(Z,Mi,Property_1,Value_1,...,Property_n,Value_n)')
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Parse the input arguments, and set data and model properties
% 1.1 Fix the data object
if isa(m0,'iddata')|isa(m0,'idfrd')|isa(m0,'frd')% forgive order confusion
    datn = inputname(2);
    z=m0;
    m0 = data;
    data = z;
else
    datn = inputname(1);
end
if isa(data,'frd')
    data = idfrd(data);
end
if isa(data,'idfrd')
    data = iddata(data);
end
% 1.2 Special test for focus filter:
if ~isa(m0,'idss')  % then there must be an IDSS focus filter in varargin
    for kk = 1:length(varargin)
        try
            if strcmp('fo',lower(varargin{kk}(1:2)))
                filt = varargin{kk+1};
                [a,b,c,d] = ssdata(filt);
                filt = {a,b,c,d,pvget(filt,'Ts')};
                varargin{kk+1}=filt;
            end   
        catch
        end
    end
    m = pem(data,m0,varargin{:}); 
    m = setdatid(m,getid(data),[]);
    return
end
if isa(data,'iddata')
    iddataflag = 1;
    dom = pvget(data,'Domain');
    data = setid(data);
    try
        data = estdatch(data,pvget(m0,'Ts'));
    end
else
    dom = 'Time';
end
ftdom = lower(dom(1)); 
[ny,nu]=size(m0);
if  ~isa(data,'iddata')
    iddataflag = 0;
    if ~isa(data,'double')
        error(['The data must either be an IDDATA object or a matrix' ...
                ' of reals.'])
    end
    nz = size(data,2);
    if nz~=ny+nu
        error(sprintf(['The model size is not consistent with the number of',...
                '\ncolumns in the data.']))
    end
    data = iddata(data(:,1:ny),data(:,ny+1:end));
    warning(sprintf(['The data sampling interval has been set to 1.'...
            '\nIf this is not correct, please supply the data as an IDDATA object.'...
            '\n (data = IDDATA(output,input,samplinginterval).)']))
end
[Ncap,nyd,nud,Ne]=size(data);
if nyd~=ny|nud~=nu
    error(sprintf(['The model size is not consistent with the number of',...
            ' inputs \nand outputs in the data.']))
end

% If Data properties are set in the input arguments, set these to data
% first:
[varargin,datarg] = pnsortd(varargin);
if ~isempty(datarg), data = pvset(data,datarg{:});end
if isempty(pvget(data,'Name'))
    data=pvset(data,'Name',datn);
end

Tsdata = pvget(data,'Ts');
Tsdata = Tsdata{1}; % all sampling intervals assumed to be the same.



% 1.3  Set model properties:
if length(varargin)>0
    if ~isstr(varargin{1})|...
            (strcmp(lower(varargin{1}),'trace')&...
            fix(length(varargin)/2)~=length(varargin)/2)% old syntax  
        npar=length(pvget(m0,'ParameterVector'));
        [Tss,varargin] = transf(varargin,npar);
        if ~isempty(Tss)&~iddataflag
            data = pvset(data,'Ts',Tss);
        end
        
    end
    set(m0,varargin{:}) 
end
% This finishes the input parsing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%2. Extract Model Info
Ts=pvget(m0,'Ts'); 
es = pvget(m0,'EstimationInfo');
ut = pvget(m0,'Utility');
algorithm=pvget(m0,'Algorithm');
Zstab = algorithm.Advanced.Threshold.Zstability;
Sstab = algorithm.Advanced.Threshold.Sstability;
par=pvget(m0,'ParameterVector'); 
if isstr(algorithm.MaxSize),...
        algorithm.MaxSize = idmsize(max(Ncap),length(par));
end
foc = algorithm.Focus;
if ischar(foc)&any(strcmp(foc,{'Stability','Simulation'}))
    stabenf = 1;
else
    stabenf = 0;
end
intd = pvget(data,'InterSample');
if isempty(intd) % Time series data
    intd = 'zoh';
else
    intd = intd{1,1}; % Assuming this be the same for all experiments and inputs
end

dm = pvget(m0,'DisturbanceModel');
sspar = m0.SSParameterization;
nk = pvget(m0,'nk');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3. Checks and warnings
[A,B,C,D,K] = ssdata(m0);

if ftdom =='f' 
    if ~strcmp(dm,'None')
        warning(sprintf(['DisturbanceModels cannot be estimated for Frequency',...
                ' Domain Data.\n DisturbanceModel has been set to ''None''.']));
        dm = 'None';
        m0=pvset(m0,'DisturbanceModel','None');
    end
    if isempty(B)
        error(['Time series models (no input) cannot be estimated using',...
                ' Frequency Domain  Data.'])
    end
    algorithm.LimitError = 0; % no robustification for FD data
end
nx = size(A,1);
if ftdom == 't'
    ei = eig(A-K*C);
    if  (Ts==0&max(real(ei))>Sstab)|(Ts>0&max(abs(ei))>Zstab)
        warning(sprintf(['The initial model has an unstable predictor.',...
                '\nMake sure',...
                ' that the model''s sampling interval ',num2str(Ts),' is correct.'...
                '\nINIT may',...
                ' be used to find a stable initial model.']))
    end
end
if stabenf
    ei = eig(A);
    if (Ts==0&max(real(ei))>Sstab&norm(K)==0)|(Ts>0&max(abs(ei))>Zstab)
        warning(sprintf(['The initial model is unstable.',...
                '\nMake sure',...
                ' that the model''s sampling interval ',num2str(Ts),' is correct.'...
                '\nINIT may',...
                ' be used to find a stable initial model.']))
    end
end

if Ts>0
    if abs(Ts-Tsdata)>1e4*eps
        warning(['Model sampling interval changed to ',num2str(Tsdata), ...
                ' (Data''s sampling interval).'])
        m0 = pvset(m0,'Ts',Tsdata);
    end
    if (strcmp(intd,'foh') | strcmp(intd,'bl')),
        warning(sprintf(['You are building a discrete time model.\nThe intersample',...
                ' behaviour of the input will then be ignored.']))
    end
elseif ~iddataflag
    ttes = pvget(m0,'Utility'); 
    try
        Tsdata = ttes.Tsdata;
        data = pvset(data,'Ts',Tsdata);
    catch
        error(sprintf('For a continuous time model, the DATA must be an IDDATA object.',...
            '\Use DATA = IDDATA(y,u,Ts).'))
    end
end    
if ~isempty(algorithm.FixedParameter)&strcmp(sspar,'Free')
    warning(sprintf(['The Free parameterization cannot handle Fixed Parameters.',...
            '\nUse Structured parameterization and model.As etc to fix parameters.\n']))
    algorithm.FixedParameter = [];
    m0 = pvset(m0,'FixedParameter',[]);
end 

% Kill old hidden models in starting model:
ut =pvget(m0,'Utility');
try
    ut.Pmodel = [];
    ut.Idpoly = [];
end
m0 = uset(m0,ut); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
was = warning;
warning off
[e,xi] = pe(data,m0);
warning(was)
e = pvget(e,'OutputData');
e = cat(1,e{:}); % vector of errors
lam = e'*e/length(e); % first estimate of lambda
if realdata(data), lam = real(lam); end
m0 = pvset(m0,'NoiseVariance',lam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Fix LimitError

if algorithm.LimitError~=0
    Ns=size(e,1);
    algorithm.LimitError = ...
        median(abs(e-ones(Ns,1)*median(e)))*algorithm.LimitError/0.7;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Shift Data if necessary

Inpd = pvget(m0,'InputDelay');
if Ts==0
    if Tsdata>0
        Inpd = Inpd/Tsdata;
        if any(abs(Inpd - round(Inpd))>1e4*eps)
            error(sprintf(['The InputDelay for a time continuous model must ',...
                    'be a multiple of the data sampling interval.']))
        end
        Inpd = round(Inpd);
    end
    if strcmp(m0.SSParameterization,'Free')&ftdom=='t'
        error(sprintf(['The ''Free'' SSParameterization is not supported for ',...
              'continuous time models.\nUse instead ''Structured'' or ''Canonical''',...
             ' (recommended) SSParameterization.\n (Add  ...,''ss'',''can'',.. to the',...
            ' list of arguments.']));
    end
end
% Also take out demanded time-delays for free parameterization:
if strcmp(m0.SSParameterization,'Free')
    dkx = [0,0,0];
    if nu>0
        if any(nk==0) 
            dkx(1)=1;
        end
        nks = max(nk-1,zeros(size(nk)));
        if any(nks>0)
            m0 = pvset(m0,'nk',nk>0);
        end
    else
        nks = 0;
    end
else
    nks = zeros(size(nk));
end
if ~isempty(Inpd) % To avoid problems for time series
    shift = Inpd' + nks;
    dats = nkshift(data,shift);
else
    dats = data;  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 4. Deal with Focus

foccase = 0;
if ~ischar(foc)
    foccase=1;
elseif strcmp(foc,'Simulation')&~strcmp(dm,'None')
    foccase = 1;
end
if foccase
    m0 = pvset(m0,'InputDelay',zeros(nu,1)); % not to shift  again
    m = pemfocus(dats,m0,foc);  
    if strcmp(m.SSParameterization,'Free')&any(nks>0)
        m = pvset(m,'nk',nk);
    end
    m = pvset(m,'InputDelay',Inpd);
    m = setdatid(m,getid(data),[]);
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 7. Deal with InitialState

init = m0.InitialState;

% Overrides 1: FRD data musr have zero init
frdflag = 0;
utd = pvget(data,'Utility');
try
    if utd.idfrd
        frdflag = 1;
    end
end
if frdflag
    switch init
        case {'Estimate','Model','Backcast'}
            warning(sprintf(['InitialState = ''Estimate'' or ''Model'' cannot be used ',...
                    'for data that are derived from an IDFRD.',...
                    '\nIt has been changed to ''Zero''.']));
            init = 'Zero';
            
        case 'Auto'
            init = 'Zero';
    end
end

% Overrides 2: Multiexperiment data cannot have estimte
if Ne>1
    switch init
        case 'Estimate'
            warning(sprintf(['InitialState = ''Estimate'' cannot be used for multiple experiment data.',...
                    '\nIt has been changed to ''Backcast''.']));
            init = 'Backcast'; %%m0.InitialState = 'Backcast' ??
            m0.X0s = zeros(size(m0.X0s));
        case 'Auto'
            init = 'Backcast';
            m0.X0s = zeros(size(m0.X0s));
        case 'Fixed'
            warning(sprintf(['InitialState = ''Fixed'', may not be suited for',...
                    ' multiexperiment data. Consider chaning it to ''Backcast''.']))
    end
end
autoflag = 0;
% Choose in Auto case
if strcmp(init,'Auto') % Then it comes with X0s = 0
    
    autoflag = 1;
    if algorithm.MaxIter == -1
        init = 'Zero';
        
    elseif any(strcmp(m0.SSParameterization,{'Structured','Canonical'}))
        if any(isnan(m0.X0s))
            init = 'Estimate';
        elseif norm(m0.X0s)==0
            init = 'Zero';
        else
            init = 'Fixed';
        end
    else
        ez = pe(data,m0,'z'); 
        ez = pvget(ez,'OutputData');
        ez = cat(1,ez{:}); % vector or errors
        nor1 = norm(ez);
        nor2 =norm(e);
        if nor1/nor2>algorithm.Advanced.Threshold.AutoInitialState
            init = 'Estimate';
            m0 = pvset(m0,'InitialState','Estimate');
            par = [par;xi];
        else
            init = 'Zero';
            m0 = pvset(m0,'InitialState','Zero'); 
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%8. Prepare for minimization
% 8.1 Set up the struc fields
struc.init = init;
sspar=m0.SSParameterization;
fixp = pvget(m0,'FixedParameter');
if ~isempty(fixp)
    fixflag = 1;
    if (iscell(fixp)|ischar(fixp))&isempty(pvget(m0,'PName'))
        m0 = setpname(m0);
    end
end
struc.pname = pvget(m0,'PName');
if ischar(pvget(m0,'CovarianceMatrix'))
    struc.cov = 0;
else
    struc.cov = 1;
end
nu=size(m0.Bs,2);
if strcmp(sspar,'Free')
    struc.type='ssfree';
elseif (strcmp(sspar,'Structured')|strcmp(sspar,'Canonical'))&Ts>0
    struc.type='ssnans';
else 
    struc.type='ssgen';
end
struc.lambda = pvget(m0,'NoiseVariance');
switch struc.type
    case {'ssnans','ssgen'}
        nans.as=m0.As;nans.bs=m0.Bs;nans.cs=m0.Cs;
        nans.ds=m0.Ds;nans.ks=m0.Ks;nans.x0s=m0.X0s;
        struc.filearg=nans;
        if strcmp(struc.type,'ssnans')
            struc.modT = -1; 
        else
            struc.modT = Tsdata;
            struc.intersample = intd;
            struc.Tflag = 1;
            struc.mfile = 'ssmodxx';
            struc.model = m0;
        end
        
    case 'ssfree'
        if Ts==0,
            struc.modT = 0; 
        else
            struc.modT = -1; 
        end
        dkx=[0,0,0];
        if any(isnan(m0.X0s))&~strcmp(struc.init,'Backcast')
            dkx(3)=1;
        end
        if any(any(isnan(m0.Ks))'),
            dkx(2)=1;
        end
        if any(any(isnan(m0.Ds))'),
            dkx(1)=1;
        end
        struc.dkx=dkx; 
        [a,b,c,d,k,x0]=ssdata(m0);  
        struc.a=a;struc.b=b;struc.c=c;
        struc.d=d;struc.k=k;struc.x0=x0; %%xi??
        struc.nu=size(b,2);struc.nx=size(a,1);
        struc.ny=size(c,1);
        struc.nk=(nk>0);
        par=[];
end
struc.domain = ftdom;

% 8.3 Display initial info

if any(strcmp(algorithm.Trace,{'Full','On'}))
    %clc
    disp(['Initial Estimate:'])
    disp(['   Initial loss: ' num2str(det(pvget(m0,'NoiseVariance')))])
    if strcmp(algorithm.Trace,'Full')&~strcmp(struc.type,'ssfree')
        disp(['   Par-vector'])
        disp(par)
    end
end
if algorithm.MaxIter(1)==0|...
        (any(strcmp(struc.type,{'ssnans','ssgen'}))&length(par)==0)
    m=m0;
    m = setdatid(m,getid(data),[]);
    
    return,
end % 
if ftdom == 't'
    [z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag,ynorm]=idprep(dats,0,inputname(1));
else
    struc.realflag = realdata(dats);
    dats = complex(dats);
    [z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag]=idprep_f(dats,0,inputname(1));
    ynorm =[];
end

error(errflag)

es = pvget(m0,'EstimationInfo');
[parnew,strucnew,it_inf,cov,lambda]=minloop(z,par,struc,algorithm,es);

m=m0;

%switch struc.type
if strcmp(struc.type,'ssfree')
    at=strucnew.a.';bt=strucnew.b.';ct=strucnew.c.';dt=strucnew.d;
    kt=strucnew.k.';dkx=strucnew.dkx;
    par=[at(:);bt(:);ct(:)];
    dtt=[];
    for ku = 1:nu
        if nk(ku)==0
            dtt =[dtt,dt(:,ku)];
        end
    end
    if ~isempty(dtt)
        dtt = dtt.';
        par = [par;dtt(:)];
    end
    
    if  dkx(2)
        par=[par,;kt(:)];
    end
    if dkx(3)
        par = [par;strucnew.x0];%par=[par;x0];
    end
    parnew=par;
end 
idmod=m.idmodel; 
it_inf.DataLength=sum(Ncaps); 
it_inf.DataTs=Tsdata;
it_inf.DataInterSample=pvget(data,'InterSample');
it_inf.Status='Estimated model (PEM)';
it_inf.DataName=pvget(data,'Name');
it_inf.Method = 'PEM';
if strcmp(pvget(idmod,'CovarianceMatrix'),'None')
    cov = 'None';
end
lamscale = 1;
if Ts==0
    lamscale = Tsdata;
end
idmod=pvset(idmod,'CovarianceMatrix',cov,'NoiseVariance',lamscale*lambda,...
    'EstimationInfo',it_inf,'ParameterVector',parnew,...
    'InputName',pvget(data,'InputName'),...
    'OutputName',pvget(data,'OutputName'),'InputUnit',...
    pvget(data,'InputUnit'),'OutputUnit',...
    pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'),'Approach','Pem');


m.idmodel=idmod;  
if strcmp(sspar,'Free')&any(nks>0) 
    m = pvset(m,'nk',nk);  
end

if  strcmp(struc.type,'ssfree')&~strcmp(pvget(m0,'CovarianceMatrix'),'None')
    try
        m2=m; ut=pvget(m2,'Utility'); 
        try 
            ut.Pmodel = [];
        end
        m2 = uset(m2,ut); % all this to really recompute can form
        m2=pvset(m2,'SSParameterization','Canonical');
        idmod=m2.idmodel;alg=idmod.Algorithm;
        maxi = pvget(idmod,'MaxIter');
        tr = pvget(idmod,'Trace'); 
        alg.MaxIter=-1;alg.Trace='Off';
        idmod=pvset(idmod,'MaxIter',-1,'Trace','Off');
        m2.idmodel = idmod; 
        m2=pem(data,m2);
        m2 = pvset(m2,'MaxIter',maxi,'Trace',tr);
        
        utility = pvget(idmod,'Utility'); 
        utility.Pmodel=m2;
        %utility.Idpoly=idpoly(m2);
        idmod=m.idmodel;
        idmod = pvset(idmod,'Utility',utility); 
        m.idmodel=idmod;
    catch
        disp('Calculation of covariance information failed.')
        disp('''CovarianceMatrix'' has been set to ''None''.')
        m = pvset(m,'CovarianceMatrix','None');
    end
end
if autoflag
    m.InitialState = 'Auto';
end
m = setdatid(m,getid(data),ynorm);
%if ~strcmp(idm.CovarianceMatrix,'None')
% 	setcov(m)
%end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = pemfocus(data,m0,foc)
ts = pvget(data,'Ts');ts = ts{1};
dom = pvget(data,'Domain'); 
foc = foccheck(foc,ts,[],lower(dom(1)),pvget(data,'Name'));
zf = data;
if ~isa(foc,'char')
    zf = idfilt(data,foc);
end

[a0,b0,c0,d0,k0] = ssdata(m0);
% stabilize initial model:
[a0,flag] = stab(a0,pvget(m0,'Ts'));
if flag,
    m0 = pvset(m0,'A',a0);
end
ny = size(d0,1);
m1 = pvset(m0,'Focus','Prediction','DisturbanceModel','None');
tr = pvget(m0,'Trace');
if ~strcmp(tr,'Off')
    disp(sprintf('\n   *** Finding the dynamics model ... ***\n'))
end

m1=pem(zf,m1);
if strcmp(m1.SSParameterization,'Free')
    ut=pvget(m1,'Utility'); 
    try
        idm = ut.Pmodel;
        cov1 = pvget(idm,'CovarianceMatrix');
        numx=sum(sum(isnan(idm.X0s))');
        cov1=cov1(1:end-numx,1:end-numx);
        excov = 1;
    catch
        cov1 =[];
        excov = 0;
    end
    
else
    cov1 = pvget(m1,'CovarianceMatrix');
    if ischar(cov1)|isempty(cov1)
        excov = 0;
    else
        numx=sum(sum(isnan(m1.X0s))');
        cov1=cov1(1:end-numx,1:end-numx);
        excov = 1;
    end
end
if any(any(isnan(m0.Ks))')
    [a,b,c,d,k,x0]=ssdata(m1);
    if (pvget(m1,'Ts')>0&max(abs(eig(a-k0*c)))>1)|...
            (pvget(m1,'Ts')==0&max(real(eig(a-k0*c)))>0)  
        % To secure a stable initial predictor
        if any(strcmp(m0.SSParameterization,{'Free','Canonical'}))&pvget(m1,'Ts')
            eval('k0 = ssssaux(''kric'',a,c,k0*k0'',eye(ny),k0);','');
        else
            k0 = zeros(size(c))';
        end
    end
    
    m1=pvset(m1,'As',a,'Bs',b,'Cs',c,'Ds',d,'Ks',m0.Ks,'K',k0);
    
    if ~strcmp(tr,'Off')
        disp(sprintf('\n   *** Finding the noise model ... ***\n'))
    end
    m=pem(data,m1);
    if excov
        cov2 = pvget(m,'CovarianceMatrix');
        cov=[[cov1,zeros(size(cov1,1),size(cov2,2))];...
                [zeros(size(cov2,1),size(cov1,2)),cov2]];
    else
        cov = 'none';
    end
    if strcmp(m0.SSParameterization,'Free')&excov
        m = pvset(m,'SSParameterization','Free','CovarianceMatrix',[]);
        [a,b,c,d,k,x0]=ssdata(idm);
        idm1=pvset(idm,'As',a,'Bs',b,'Cs',c,'Ds',d,'Ks',NaN*ones(size(k)));
        
        if ~strcmp(lower(tr),'off')
            disp(sprintf(['\n   *** Finding the noise model ',...
                    'for the canonical parameterization ... ***\n']))
        end
        
        idm1=pem(data,idm1,'MaxIter',pvget(m0,'MaxIter')); 
        %This is redone since idm has another parameterization
        if ~isempty(cov1)
            cov2 = pvget(idm1,'CovarianceMatrix');
            if isempty(cov2)
                cov = [];
            else
                cov=[[cov1,zeros(size(cov1,1),size(cov2,2))];...
                        [zeros(size(cov2,1),size(cov1,2)),cov2]];
            end
        else
            cov = [];
        end
        idm = pvset(idm,'Ks',idm1.Ks,'K',pvget(idm1,'K'));
        idm = pvset(idm,'CovarianceMatrix',cov);
        ut.Pmodel=idm;
        m.idmodel = pvset(m.idmodel,'Utility',ut);%gsutil(m.idmodel,ut,'s');
    else
        m = pvset(m,'As',m0.As,'Bs',m0.Bs,'Cs',m0.Cs,'Ds',m0.Ds);
        m = pvset(m,'CovarianceMatrix',cov);
    end
else 
    m = m1;
end
m = pvset(m,'Focus',foc);
es = pvget(m,'EstimationInfo');
es.Status='Estimated model (PEM with focus)';
es.Method = 'PEM with focus';
es.DataName = pvget(data,'Name');
m.idmodel=pvset(m.idmodel,'EstimationInfo',es);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [As,flag]=stab(A,T,thresh)
flag = 0;
if nargin<2
    T = 1;
end
if nargin<3
    if T
        thresh = 1;
    else
        thresh = 0;
    end
end
[V,D]=eig(A);
if cond(V)>10^8, [V,D]=schur(A);[V,D]=rsf2csf(V,D);end
if (T~=0&max(abs(diag(D)))<thresh)|(T==0&max(real(diag(D)))<thresh)
    As=A;
    return,
end
flag = 1;
[n,n]=size(D);
for kk=1:n
    if T~=0
        if abs(D(kk,kk))>thresh,D(kk,kk)=thresh^2/D(kk,kk);end
    else
        if real(D(kk,kk))>thresh,D(kk,kk)=2*thresh-real(D(kk,kk))+i*imag(D(kk,kk));end
    end
end
As=V*D*inv(V);
if isreal(A)
    As = real(As);
end
