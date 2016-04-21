function m=pem_f(data,m0,varargin)
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
%	$Revision: 1.3.4.1 $  $Date: 2004/04/10 23:17:59 $

if nargin<1
    disp('       M = PEM(Z,Mi)  For IDSS model Mi')
    disp('       M = PEM(Z,Mi,Property_1,Value_1,...,Property_n,Value_n)')
    return
end
%
%  *** Set up default values ***

if isa(m0,'iddata') | isa(m0,'idfrd')% forgive order confusion
    datn = inputname(2);
    z=m0;
    m0 = data;
    data = z;
else
    datn = inputname(1);
end

if isa(data,'idfrd')
    data = iddata(data);
    forcenox0 = 1;
else
    forcenox0 = 0;
end


if ~isa(m0,'idss')  % then there must be an IDSS focus filter in varargin
    for kk = 1:length(varargin)
        try
            if strcmp('fo',lower(varargin{kk}(1:2)))
                filt = varargin{kk+1};
                [a,b,c,d] = ssdata(filt);
                filt = {a,b,c,d};
                varargin{kk+1}=filt;
            end   
        catch
        end
    end
    m = pem_f(data,m0,varargin{:}); 
    return
end

% imatch = strmatch('wfoc',lower(varargin(1:2:end))); 
% if ~isempty(imatch)
%   Wfoc = varargin{2*imatch};
%   varargin = varargin([1:2*imatch-2,2*imatch+1:end]);
% else
%   Wfoc = [];
% end
% 


[ny,nu]=size(m0);
if  ~isa(data,'iddata')
    if ~isnumeric(data),
        error(['The data must be an IDDATA object or a matrix.']);
    end
    nz = size(data,2);
    if nz~=ny+nu+1
        error(sprintf(['The model size is not consitent with the number of',...
                '\ncolumns in the data.']))
    end
    ddata = iddata(data(:,1:ny),data(:,ny+1:end-1));
    data = pvset(ddata,'Domain','Frequency','SamplingInstants',data(:,end));
    iddataflag = 0;
else
    iddataflag = 1;
    Tsdata = pvget(data,'Ts');
    [N,nyd,nud]=size(data);
    if nyd~=ny|nud~=nu
        error(sprintf(['The model size is not consistent with the number of',...
                ' inputs \nand outputs in the data.']))
    end
end
if ~strcmp(pvget(data,'Domain'),'Frequency'),
    error('This code is for Domain=Frequency only' );
end
if isempty(pvget(data,'Name'))
    data = pvset(data,'Name',datn);
end

if nargin>2&length(varargin)>0
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

%chkmdinteg(pvget(m0,'Ts'),pvget(data,'Ts'),pvget(data,'InterSample'),1);


[A,B,C,D,K] = ssdata(m0);
ei = eig(A-K*C);
Ts = pvget(m0,'Ts');
algorithm=pvget(m0,'Algorithm');
Zstab = algorithm.Advanced.Threshold.Zstability;
Sstab = algorithm.Advanced.Threshold.Sstability;

if (Ts==0&max(real(ei))>Sstab)|(Ts>0&max(abs(ei))>Zstab)
    warning(sprintf(['The initial model has an unstable predictor.\nMake sure',...
            ' that the model''s sampling interval ',num2str(Ts),' is correct.\nINIT may',...
            ' be used to find a stable initial model.']))
end

idm = pvget(m0,'idmodel');

foc = algorithm.Focus;
if ~isempty(foc)
    if ischar(foc) % Stability, Simulation, Predition .. Nothing to do ...
    else
        foc = foccheck(foc,Tsdata{1},[],'f');
        data = idfilt(data,foc); % exceptional case of cellarray of length==Ne=2=4
    end
end

% if nu == 0 & ~any(strcmp(foc,{'Prediction','Stability'}))
%    disp('WARNING: For time-series ''Focus'' = ''Simulation'' or filter does not apply.')
%    algorithm.Focus = 'Prediction';
%    foc = 'Prediction';
% end
% 

% Now the input parsing is finished.
% First check if the data should be shifted.
Inpd = pvget(m0,'InputDelay');
if Ts==0
    Tsdata = pvget(data,'Ts'); Tsdata = Tsdata{1};
    if Tsdata==0, 
        %This might happen when data is an idfrd object
    else
        Inpd = Inpd/Tsdata;%%LL check this!!
    end
    if any(Inpd ~= fix(Inpd))
        error(sprintf(['The InputDelay for a time continuous model must ',...
                'be a multiple of the data sampling interval.']))
    end
    % $$$    if strcmp(m0.SSParameterization,'Free')
    % $$$       error(sprintf(['The ''Free'' SSParameterization is not supported for ',...
    % $$$             'continuous time models.\nUse instead ''Structured'' or ''Canonical''',...
    % $$$             ' (recommended) SSParameterization.\n (Add  ...,''ss'',''can'',.. to the',...
    % $$$             ' list of arguments.']));
    % $$$    end
end
nk = pvget(m0,'nk');
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
if ~isempty(Inpd) % Just for safety. normally Inpd = 0
    shift = Inpd' + nks;
    dats = nkshift(data,shift); %%LL was _f
else
    dats = data;  
end
% foccase = 0;
% if ~isstr(foc)
%    foccase=1;
% elseif strcmp(foc,'Simulation')&~strcmp(pvget(m0,'DisturbanceModel'),'None')
%    foccase = 1;
% end
% if foccase
%    m0 = pvset(m0,'InputDelay',zeros(nu,1));
%    m = pemfocus_f(dats,m0,foc);  
%    if strcmp(m.SSParameterization,'Free')&any(nks>0)
%       m = pvset(m,'nk',nk);
%    end
%    m = pvset(m,'InputDelay',Inpd);
%    return
% end



[z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag]=idprep_f(dats,0,datn);
error(errflag)

% if ~isempty(Wfoc), % Do weighting
%   if ~iscell(Wfoc),
%     Wfoc = {Wfoc};
%   end
%   for kexp = 1:length(z),
%     z = [spdiags(Wfoc{kexp},0,length(Wfoc{kexp}),length(Wfoc{kexp}))* ...
% 	 z{kexp}(:,1:end-1),z{kexp}(:,end)];  %% ??TM also freq??
%   end
% end

Ts=pvget(idm,'Ts');  
if Ts>0
    if abs(Ts-Tsdata)>eps
        disp(['Model sampling interval changed to ',num2str(Tsdata), ...
                ' (Data''s sampling interval).'])
        m0 = pvset(m0,'Ts',Tsdata);
    end
else
    if ~iddataflag
        ttes = pvget(m0,'Utility'); 
        try
            Tsdata = ttes.Tsdata;
            data = pvset(data,'Ts',Tsdata);
        catch
            error(sprintf('For a continuous time model, the DATA must be an IDDATA object.',...
                '\Use DATA = IDDATA(y,u,Ts).'))
        end
    end    
end
inters = pvget(data,'InterSample');
inters = inters{1};
sspar=pvget(m0,'SSParameterization');
struc.pname = pvget(m0,'PName');
struc.realflag = realdata(data);
data = complex(data); %% this is to give correct covariance matrix
if ischar(pvget(m0,'CovarianceMatrix'))
    struc.cov = 0;
else
    struc.cov = 1;
end
nu=size(m0.Bs,2);
if strcmp(sspar,'Free')&~(Ts==0 & strcmp(inters,'zoh'))
    struc.type='ssfree';
elseif (strcmp(sspar,'Structured')|strcmp(sspar,'Canonical'))&Ts>0
    struc.type='ssnans'; 
elseif (strcmp(sspar,'Structured')|strcmp(sspar,'Canonical'))&Ts==0 ...
        & strcmp(inters,'bl')
    struc.type='ssnans'; 
else 
    struc.type='ssgen';
end
struc.lambda = pvget(m0,'NoiseVariance');

par=pvget(idm,'ParameterVector'); 
if isstr(algorithm.MaxSize)
    algorithm.MaxSize = idmsize(max(Ncaps),length(par));
end
Ks = m0.Ks;
if ~isempty(algorithm.FixedParameter)&strcmp(sspar,'Free')
    disp(sprintf(['The Free parameterization cannot handle Fixed Parameters.',...
            '\nUse Structured parameterization and model.As etc to fix parameters.\n']))
    algorithm.FixedParameter = [];
    m0 = pvset(m0,'FixedParameter',[]);
end 
m00 = m0; % to let m0 be sampled just once, if necessary
algorithm.LimitError = 0;% No lim for FD data
if algorithm.LimitError~=0
    if pvget(m0,'Ts')==0 & strcmp(inters,'zoh');
        if Tsdata>0
            m00 = c2d(m0,Tsdata); % cov 'None' when this feature is included
        else
            m00 = m0;
        end
    end
    e=pe_f(z,m00,'e');   %%TM - what if z is multi-experiment 
    if iscell(e), 
        e = e{1};
    end
    Ncap=size(e,1);
    algorithm.LimitError=median(abs(e-ones(Ncap,1)*median(e)))*algorithm.LimitError/0.7;
end
if any(strcmp(algorithm.Trace,{'Full','On'}))
    %clc
    disp(['Initial Estimate:'])
    disp(['   Initial loss: ' num2str(real(det(idm.NoiseVariance)))])
    if strcmp(algorithm.Trace,'Full')&~strcmp(struc.type,'ssfree')
        disp(['   Par-vector'])
        disp(par)
    end
end
if algorithm.MaxIter(1)==0|...
        (any(strcmp(struc.type,{'ssnans','ssgen'}))&length(par)==0)
    m=m0;
    return,
end % 

% *** Minimize the prediction error criterion *** 
struc.init = m0.InitialState;

if Ne>1&strcmp(struc.init,'Estimate')
    warning(sprintf(['InitialState = ''Estimate'' cannot be used for multiple experiment data.',...
            '\nIt has been changed to ''Backcast''.']));
    struc.init = 'Backcast';
    m0.X0s = zeros(size(m0.X0s));
    m0.InitialState = 'Backcast';
end
autoflag = 0;
if strcmp(struc.init,'Auto') % Then it comes with X0s = 0
    
    autoflag = 1;
    if algorithm.MaxIter == -1
        struc.init = 'zero';
    elseif Ne>1
        struc.init = 'Backcast';
        %m0.InitialState = 'Backcast';
    elseif strcmp(m0.SSParameterization,'Structured')
        if any(isnan(m0.X0s))
            struc.init = 'Estimate';
        elseif norm(m0.X0s)==0
            struc.init = 'Zero';
        else
            struc.init = 'Fixed';
        end
    else
        e1 = pe_f(z,m00,'z',1); 
        [e2,xi] = pe_f(z,m00,'e',1); 
        nor1 = norm(e1);
        
        nor2 =norm(e2);
        
        if nor1/nor2>algorithm.Advanced.Threshold.AutoInitialState
            struc.init = 'Estimate';
            m0 = pvset(m0,'InitialState','Estimate');
            par = [par;xi];
        else
            struc.init = 'Zero';
            m0 = pvset(m0,'InitialState','Zero'); 
        end
    end
end

if forcenox0,
    m0.X0s = zeros(size(m0.X0s));
    m0.InitialState = 'Zero';
    struc.init = 'Zero';
end


isint = pvget(data,'InterSample');
struc.intersample = isint{1};

switch struc.type
    case {'ssnans','ssgen'}
        nans.as=m0.As;nans.bs=m0.Bs;nans.cs=m0.Cs;
        nans.ds=m0.Ds;nans.ks=m0.Ks;nans.x0s=m0.X0s;
        struc.filearg=nans;
        if strcmp(struc.type,'ssnans')
            if Ts==0,
                struc.modT = 0; 
            else
                struc.modT = -1; 
            end
        else
            struc.modT = Tsdata;
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

es = idm.EstimationInfo;
struc.domain = 'f';


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
idmod=pvget(m,'idmodel'); 
it_inf.DataLength=sum(Ncaps); 
it_inf.DataTs=Tsdata;
it_inf.DataInterSample=pvget(data,'InterSample');
it_inf.Status='Estimated model (PEM)';
it_inf.DataDomain = 'Frequency';
it_inf.DataName=pvget(data,'Name');
it_inf.Method = 'PEM';
if strcmp(pvget(idmod,'CovarianceMatrix'),'None')
    cov = 'None';
end

idmod=pvset(idmod,'CovarianceMatrix',cov,'NoiseVariance',lambda,...
    'EstimationInfo',it_inf,'ParameterVector',parnew,...
    'InputName',pvget(data,'InputName'),...
    'OutputName',pvget(data,'OutputName'),'InputUnit',...
    pvget(data,'InputUnit'),'OutputUnit',...
    pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'));


m = pvset(m,'idmodel',idmod);  
if strcmp(sspar,'Free')&any(nks>0) 
    m = pvset(m,'nk',nk);  
end

if  strcmp(struc.type,'ssfree')&~strcmp(idm.CovarianceMatrix,'None')
    m2=m; ut=pvget(m2,'Utility'); 
    try 
        ut.Pmodel = [];
    end
    m2=pvset(m2,'Utility',ut); % all this to really recompute can form
    m2=pvset(m2,'SSParameterization','Canonical');
    idmod=pvget(m2,'idmodel'); 
    alg=idmod.Algorithm;
    maxi = pvget(idmod,'MaxIter');
    tr = pvget(idmod,'Trace'); 
    alg.MaxIter=-1;alg.Trace='Off';
    idmod=pvset(idmod,'MaxIter',-1,'Trace','Off');
    m2 = pvset(m2,'idmodel', idmod); 
    m2=pem_f(data,m2);
    m2 = pvset(m2,'MaxIter',maxi,'Trace',tr);
    
    utility = pvget(idmod,'Utility'); 
    utility.Pmodel=m2;
    %utility.Idpoly=idpoly(m2);
    idmod = pvget(m,'idmodel');
    idmod = pvset(idmod,'Utility',utility); 
    m = pvset(m,'idmodel',idmod);
end
if autoflag
    m.InitialState = 'Auto';
end

% if ~strcmp(idm.CovarianceMatrix,'None')
% 	setcov(m)
% end






% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function m = pemfocus_f(dat,mprel,foc)
% 
% w = pvget(dat,'SamplingInstants'); % Frequency
% InD = pvget(dat,'InputData'); 
% OutD = pvget(dat,'OutputData'); 
% nexp = length(InD);
% 
% % Discrete or continuos time are possible
%   
% if isnumeric(foc) % Matrix with frequency intervalls = Brick Wall filtering
%   [nr,nc] = size(foc); 
%   if size(foc,2)~=2, 
%     error('Numeric Focus argument (brick wall filter) should have two columns');
%   end
%   for kexp = 1:nexp % If multiple experiments
%     wkeep = zeros(length(w{kexp}),1);
%     for r = 1:size(foc,1)
%       wkeep = wkeep | (w{kexp}>=foc(r,1) & w{kexp}<=foc(r,2));
%     end
%     idx = find(wkeep);
%     InD{kexp} = InD{kexp}(idx,:);
%     OutD{kexp} = OutD{kexp}(idx,:);
%     w{kexp} = w{kexp}(idx);
%     Wfoc = [];
%   end
% else
%   if isa(foc,'idmodel')|isa(foc,'lti')
%     ts = get(foc,'Ts');
%     if ts==0
%       type = 'c';
%       tsc = 1;
%     else 
%       type = 'd';
%       tsc = ts;
%     end
%     [a,b,c,d] = ssdata(foc);
%     foc={a,b,c,d};
%   else
%     type = 'd';
%     tsc = 1; % We assume sampling frequency 1
%   end
%   if length(foc)==2,
%     ifoc = 1:2; %tfmodel
%   else
%     ifoc = 1:4; %ssmodel
%   end
%   for kexp = 1:nexp % If multiple experiments
%     Wfoc{kexp} = fresp(foc{ifoc},w{kexp}*tsc,type);
%   end
% end
% 
% dat1 = pvset(dat,'OutputData',OutD,'InputData',InD, ...
% 	     'SamplingInstants',w);
% 
% mprel = pvset(mprel,'Focus','Predictor'); %%????
% m = pem_f(dat1,mprel,'Wfoc',Wfoc);    
% m = pvset(m,'Focus',foc);
% es = pvget(m,'EstimationInfo');
% es.Status='Estimated model (PEM with focus)';
% es.Method = 'PEM with focus';
% es.DataName = pvget(dat,'Name');
% m=pvset(m,'EstimationInfo',es,'Focus',foc);
% 
% %% End pemfocus_f %%%%
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
