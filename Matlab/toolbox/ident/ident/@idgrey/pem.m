function m=pem(data,m0,varargin)
%IDGREY/PEM	Computes the prediction error estimate of a general linear model.
%   MODEL = PEM(DATA,Mi)  
%
%   MODEL: returns the estimated model in IDGREY object format
%   along with estimated covariances and structure information. 
%   For the exact format of M type  IDPROPS IDGREY.
%
%   DATA:  The estimation data in IDDATA object format. See help IDDATA.
%
%   Mi: A IDGREY object that defines the model structure. See help IDGREY.
%
%  By MODEL = PEM(DATA,Mi,Property_1,Value_1, ...., Property_n,Value_n)
%  all properties associated with the model structure and the algorithm
%  can be affected. Type IDPROPS IDGREY and IDPROPS ALGORITHM for a list of
%  Property/Value pairs. Note in particular that the properties
%  'InitialState' and 'DisturbanceModel' can be set to values that
%  extend or override the parameterization in the m-file.


%	L. Ljung 10-1-86, 7-25-94
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.23 $ $Date: 2003/11/11 15:52:19 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Parse the input arguments, and set data and model properties
if isa(m0,'iddata')|isa(m0,'idfrd')|isa(m0,'frd') % forgive order confusion
    z = m0;
    m0 = data;
    data = z;
    datn = inputname(2);
else
    datn = inputname(1);
end
if isa(data,'frd')
    data = idfrd(data);
end
if isa(data,'idfrd')
    data = iddata(data);
end
if isa(data,'iddata')
    dom = pvget(data,'Domain');
    data = setid(data);
    data = estdatch(data,pvget(m0,'Ts'));
else
    dom = 'Time';
end
ftdom = lower(dom(1)); 
[ny,nu]=size(m0);
if  ~isa(data,'iddata')
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

% Set model properties:
if length(varargin)>0
    if ~isstr(varargin{1})|...
            (strcmp(lower(varargin{1}),'trace')&...
            fix(length(varargin)/2)~=length(varargin)/2)% old syntax 
        npar=length(pvget(m0,'ParameterVector'));
        varargin = transf(varargin,npar);
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
if strcmp(m0.MfileName,'procmod')
    dm = m0.FileArgument{3};
else
dm = pvget(m0,'DisturbanceModel');
end
%% if iscell(dm), dm = dm{1};end %procmodel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3. Checks and warnings
[A,B,C,D,K] = ssdata(m0);

if ftdom =='f' 
    if ~strcmp(dm,'None')
        warning(sprintf(['DisturbanceModels cannot be estimated for Frequency',...
                ' Domain Data.\n DisturbanceModel has been set to ''None''.']));
        dm = 'None';
        m0.DisturbanceModel = 'None';
    end
    if isempty(D)
        error(['Time series models (no input) cannot be estimated using',...
                ' Frequency Domain  Data.'])
    end
    algorithm.LimitError = 0; % no robustification for FD data
    % check for integrations and zero frequency
    mcheck = pvset(m0,'ParameterVector',randn(size(pvget(m0,'ParameterVector'))));
    data = zfcheck(data,mcheck);
    
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
    if Ts~=Tsdata
        warning(['Model sampling interval changed to ',num2str(Tsdata), ...
                ' (Data''s sampling interval).'])
        m0 = pvset(m0,'Ts',Tsdata);
    end
end
if strcmp(m0.CDmfile,'d') & (strcmp(intd,'foh') | strcmp(intd,'bl')),
    warning(sprintf(['You are building a discrete time model.\nThe intersample',...
            ' behaviour of the input will then be ignored.']))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 4. Deal with Focus
foccase = 0;
if ~ischar(foc)
    foccase = 1;
elseif strcmp(foc,'Simulation') %Stability?
    if strcmp(dm,'Model')|strcmp(dm,'Fixed')
        m0ktest = parset(m0,randn(size(par)));
        if norm(pvget(m0ktest,'K')) > 0
            foccase = 1;
        end
    elseif strcmp(dm,'Estimate')
        foccase = 1;
    end
end
if foccase & isempty(B)
    warning('''Focus'' has no effect on time series models.')
    foccase = 0;
end
if foccase 
    m0ktest = parset(m0,randn(size(par)));
    if (any(strcmp(dm,{'Model','Fixed'}))&norm(pvget(m0ktest,'K'))==0)...
            | strcmp(dm,'None')% first the simple filtering
        foc = foccheck(foc,Tsdata);
        data = idfilt(data,foc,'causal');
        if stabenf
            algorithm.Focus='Simulation';
        else
            algorithm.Focus = 'Prediction';
        end
    else
        m = pemfocus(data,m0,foc);
        m = setdatid(m,getid(data));
        return
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[e,xi] = pe(data,m0);
e = pvget(e,'OutputData');
e = cat(1,e{:}); % vector or errors
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
    end
    if any(Inpd ~= fix(Inpd))
        error(sprintf(['The InputDelay for a time continuous model must ',...
                'be a multiple of the data sampling interval.']))
    end
end
dats = nkshift(data,Inpd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 7. Deal with InitialState
init = m0.InitialState; 
% Overrides:
frdflag = 0;
utd = pvget(data,'Utility');
try
    if utd.idfrd
        frdflag = 1;
    end
end
if frdflag
    switch m0.InitialState
        case {'Estimate','Model','Backcast'}
            warning(sprintf(['InitialState = ''Estimate'' or ''Model'' cannot be used ',...
                    '\nfor data that are derived from an IDFRD.',...
                    '\nIt has been changed to ''Zero''.']));
            init = 'Zero';
            
        case 'Auto'
            init = 'Zero';
    end
end
if Ne>1
    switch init
        case 'Estimate'
            warning(sprintf(['InitialState = ''Estimate'' cannot be used ',...
                    'for multiple experiment data.',...
                    '\nIt has been changed to ''Backcast''.']));
            init= 'Backcast';
            
        case 'Auto'
            init = 'Backcast';
        case 'Model'
            warning(sprintf(['InitialState = ''Model'' may not be suited ',...
                    'for multiple experiment data.',...
                    '\nThe same initial state will be used for all the experiments.',...
                    '\nConsider changing it to ''Backcast''.']));
            
    end
end
if strcmp(init,'Auto')
    ez = pe(data,m0,'z');ez=pvget(ez,'OutputData');
    nor1 = norm(e); norz =norm(cat(1,ez{:}));%e2{1});
    if norz/nor1>algorithm.Advanced.Threshold.AutoInitialState
        if strcmp(m0.MfileName,'procmod')
            init = 'BackCast';
        else
            init= 'Estimate';
        end
    else
        init= 'Model';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%8. Prepare for minimization

% 8.1 Fix modifications in case of X0 and/or K estimation
ut = pvget(m0,'Utility');
if strcmp(dm,'Estimate')% for internal use during minimization
    m0.DisturbanceModel = 'K';
    try
        Ki = ut.K;
    catch
        Ki = zeros(nx,ny);
    end
    par = [par;Ki(:)];
    m0 = parset(m0,par);
end


if strcmp(init,'Estimate') % for internal use during minimization
    m0.InitialState = 'x0';
    par = [par;xi];
    m0 = parset(m0,par);
end
% 8.2 Set ut the struc-fields:

struc.model = m0;
struc.type = 'ssgen';
struc.modT = Tsdata;
struc.lambda = pvget(m0,'NoiseVariance');
if ischar(pvget(m0,'CovarianceMatrix'))
    struc.cov = 0;
else
    struc.cov = 1;
end

if strcmp(pvget(m0,'MfileName'),'procmod')
    arg = pvget(m0,'FileArgument');
    dnr = arg{6}; %parameter numbers for the delay parameters
    bnr = arg{7}; %parameter number and bounds [dn-by-3]
    struc.dflag = dnr;
    if ~isempty(bnr)
        struc.bounds = bnr;
    end
end
struc.intersample = intd;
if strcmp(m0.CDmfile,'c')
    struc.Tflag = 1; % Sample system (not if bl though)
    if strcmp(intd,'bl'),
        if Tsdata
            warning(sprintf(['You have bandlimited frequency domain data with sampling interval ',...
                    num2str(Tsdata),'.\nSince you estimate a continuous time model',...
                    '\nthe data will be interpreted as continuous time.']))
        end
        struc.Tflag = 0; % No sampling 
        struc.modT = 0;  % CT model
    end
else
    struc.Tflag = 0;
end
struc.pname = pvget(m0,'PName');
struc.init = init;
struc.domain = ftdom;

% 8.3 Display the initial estimate ***
if strcmp(algorithm.Trace,'On')|strcmp(algorithm.Trace,'Full')
    disp([' INITIAL ESTIMATE'])
    disp(['Current loss: ' num2str(det(pvget(m0,'NoiseVariance')))])
    disp(['par-vector:'])
    disp(par)
end
if algorithm.MaxIter(1)==0,m=m0;return,end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 9. Minimize the prediction error criterion ***
if ftdom=='t'
[z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag,ynorm]=idprep(dats,0,datn);
else
    struc.realflag = realdata(dats);
    dats = complex(dats);
    [z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag]=idprep_f(dats,0,datn);
    ynorm =[];
end

error(errflag)

[parnew,strucnew,it_inf,cov,lambda]=minloop(z,par,struc,algorithm,es);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%10. Build up the result
if strcmp(m0.InitialState,'x0')
    ut.X0 = parnew(end-nx+1:end,1);
    parnew = parnew(1:end-nx,1);
    if ~ischar(cov)
        try
            cov = cov(1:end-nx,1:end-nx);
        end
    end
    m0.InitialState = 'Estimate';
end
if strcmp(m0.DisturbanceModel,'K')
    Kvec  = parnew(end-nx*ny+1:end,1);
    ut.K = reshape(Kvec,nx,ny);
    parnew = parnew(1:end-nx*ny,1);
    if ~ischar(cov)
        try
            cov = cov(1:end-nx*ny,1:end-nx*ny);
        end
    end
    
    m0.DisturbanceModel = 'Estimate';
end
m=m0;
idmod=m.idmodel;

it_inf.DataLength=Ncap; 
it_inf.DataTs=Tsdata;
it_inf.DataInterSample=pvget(data,'InterSample');
it_inf.Status='Estimated model (PEM)';
it_inf.DataName=pvget(data,'Name');
it_inf.Method = 'PEM';
if pvget(idmod,'Ts') == 0
    lambda = lambda*Tsdata;
end
idmod=pvset(idmod,'CovarianceMatrix',cov,'NoiseVariance',lambda,...
    'EstimationInfo',it_inf,'ParameterVector',parnew,...
    'InputName',pvget(data,'InputName'),...
    'OutputName',pvget(data,'OutputName'),'InputUnit',...
    pvget(data,'InputUnit'),'OutputUnit',...
    pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'),'Utility',ut,'Approach','Pem');


m.idmodel=idmod;  
if pvget(m,'Ts')==0&strcmp(m.CDmfile,'cd')&...
        strcmp(pvget(m,'DisturbanceModel'),'Estimate') % make K continuous time
    A = pvget(m,'A');
    tsd = pvget(data,'Ts'); tsd = tsd{1};
    
    Kd = ut.K; [nx,ny] = size(Kd);
    Ad = sample(A,zeros(nx,0),zeros(0,nx),zeros(0,0),zeros(nx,0),tsd,'zoh',1);
    [Ac,Kc] = sample(Ad,Kd,zeros(ny,nx),zeros(ny,ny),zeros(nx,0),tsd,'zoh',0);
    ut.K = Kc;
    m = uset(m,ut);
end
m = setdatid(m,getid(data),ynorm);
%if ~strcmp(cov,'None')
%	setcov(m)
%end

 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = pemfocus(data,m0,foc)
%if isa(foc,'idmodel')|isa(foc,'lti') |iscell(foc)
ts = pvget(data,'Ts');ts = ts{1};
dom = pvget(data,'Domain'); 
foc = foccheck(foc,ts,[],lower(dom(1)),pvget(data,'Name'));
zf = data;
if ~isa(foc,'char')
    zf = idfilt(data,foc);
end
% First test if K has common parameters with A,B,C,D:
par = pvget(m0,'ParameterVector');
m0test = parset(m0,randn(size(par)));
par0 = pvget(m0test,'ParameterVector');
[a,b,c,d,k] = ssdata(m0test);
dynpar=zeros(size(par));
kpar = zeros(size(par));
for kp = 1:length(par)
    par = par0;
    par(kp)=randn(1,1);
    m1 = parset(m0test,par);
    [a1,b1,c1,d1,k1] = ssdata(m1);
    if norm([a1(:);b1(:);c1(:);d1(:)]-[a(:);b(:);c(:);d(:)])>0
        dynpar(kp)=1;
    end
    if norm(k1(:)-k(:))>0
        kpar(kp) = 1;
    end
end
if norm(kpar.*dynpar)>0
    warning(sprintf(['Your model parameterization has parameters that are shared by K on the one hand',...
            '\n and A,B,C, and D on the other. The effect of ''Focus'' may then be questionable.',...
            '\n Use ''DisturbanceModel'' = ''None'' to ignore K or ''Estimate'' to estimate it',...
            '\n with free, independent parameters. Then the effect of ''Focus'' is more clear.']))
end
% Now for the dynamics model:
m1 = pvset(m0,'Focus','Prediction','DisturbanceModel','None');
tr = pvget(m0,'Trace');
if ~strcmp(tr,'Off')
    disp(sprintf('\n   *** Finding the dynamics model ... ***\n'))
end
m1=pem(zf,m1);
cov1 = pvget(m1,'CovarianceMatrix');

% Now to estimate K:
Kcase = pvget(m0,'DisturbanceModel');
if strcmp(Kcase,'Model')&(norm(k)==0|isempty(find(kpar==1)))
    Kcase = 'None';
end
switch Kcase
    case 'Estimate' % make an independent estimate of K
        [a,b,c,d,k] = ssdata(m1);
        ts = pvget(m1,'Ts');
        mk = idss(a,b,c,d,k,'Ts',ts,'As',a,'Bs',b,'Cs',c,'Ds',d,'Ks',NaN*ones(size(k)),...
            'InputDelay',pvget(m1,'InputDelay'),'Trace',pvget(m1,'Trace'));
        
        if ~strcmp(tr,'Off')
            disp(sprintf('\n   *** Finding the noise model ... ***\n'))
        end
        mk=pem(data,mk);
        K = pvget(mk,'K');
        m = pvset(m1,'DisturbanceModel','Estimate');
        m = pvset(m,'K',K);
    case 'None'
        m = m1;
    case 'Model'
        dparnr = find(dynpar==1);
        m1 = pvset(m1,'FixedParameter',dparnr,'DisturbanceModel','Model');
        if ~strcmp(tr,'Off')
            disp(sprintf('\n   *** Finding the noise model ... ***\n'))
        end
        m1 = pem(data,m1);
        m = m1;
        cov2 = pvget(m1,'CovarianceMatrix');
        if isempty(cov2)|ischar(cov2)
            cov1=[];
        end
        if ~(ischar(cov1)|isempty(cov1))
             cov = zeros(length(par),length(par));
            cov(dparnr,dparnr) = cov1(dparnr,dparnr);
            cov(find(kpar==1),find(kpar==1)) = cov2(find(kpar==1),find(kpar==1));
            m = pvset(m1,'CovarianceMatrix',cov);
        end
end
m = pvset(m,'Focus',foc);

es = pvget(m,'EstimationInfo');
es.Status='Estimated model (PEM with focus)';
es.Method = 'PEM with focus';
es.DataName = pvget(data,'Name');
m.idmodel=pvset(m.idmodel,'EstimationInfo',es);



