function m=pem_f(data,m0,varargin)
%IDPOLY/PEM_F	Frequency domain data version of IDPOLY/PEM
%
%   Auxiliary routine to IDPOLY/PEM

%	L. Ljung 10-1-02,
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.10.4.1 $  $Date: 2004/04/10 23:16:38 $


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First check that the orders are OK for FD data:
if m0.na 
    
    warning(sprintf(['With frequency domain data only OE models are currently supported.',...
            '\n The A-polynomial has been converted to an F-polynomial']))
    if isempty(pvget(m0,'ParameterVector'))
        m0.nf = m0.na+m0.nf;
        m0.na = 0;
    else
        a = pvget(m0,'a'); f = pvget(m0,'f');
        
        ff = zeros(size(f,1),size(f,2)+length(a)-1);
        for ku=1:size(f,1)
            ff(ku,:)=conv(a,f(ku,:));
        end
        m0 = pvset(m0,'f',ff,'a',1);
    end
    
end
if  m0.nc |m0.nd
    warning(sprintf(['With frequency domain data only OE models are currently supported.',...
            '\n NC and ND have been set to sero.']))
    m0 = pvset(m0,'na',0,'nc',0,'nd',0);
end
idm = pvget(m0,'idmodel');
algorithm=pvget(idm,'Algorithm'); 
Ts = pvget(idm,'Ts');

% Next examine the data
[ny,nu]=size(m0);
[N,nyd,nud]=size(data);
if nyd~=1|nud~=nu
    error(sprintf(['The model size is not consistent with the number of ',...
            'inputs \nand outputs in the data.']))
end
Ne = get(data,'Ne');
Tsdat = pvget(data,'Ts'); 

% FILTER AND SHIFT DATA IF NECESSARY

foc = algorithm.Focus;
stabenf = 0;
if ~isempty(foc)
    if ischar(foc) 
        if strcmp(lower(foc),'stability')|strcmp(lower(foc),'simulation')
            stabenf = 1;
        end 
    else
        foc = foccheck(foc,Tsdat{1},[],'f');
        data = idfilt(data,foc); % exceptional case of cellarray of length==Ne=2=4
    end
end
 realflag= realdata(data);
data = complex(data); %%LL
% Now data checks and data massaging are finished
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up for the initial state (estimate, backcast or zero)
init = pvget(m0,'InitialState');
eflag =0;
iniwasa = 0;
if lower(init(1))=='a' %% always estimate without test
    iniwasa = 1;
    init = 'Estimate'; 
end
if Ne>1&(strcmp(init,'Estimate') )% allOW ZERO 
    if strcmp(pvget(m0,'InitialState'),'Estimate')
        warning(sprintf(['InitialState = ''Estimate'' cannot be used for multiple experiment data.',...
                '\nIt cas been changed to ''Backcast''.']));
    end
    m0.InitialState = 'Backcast';
    init = 'back';
end
par = pvget(m0,'ParameterVector');
% If 'e' and fixpar move to 'b'!:
if ~isempty(pvget(m0,'FixedParameter'))&any(lower(init(1))==['e','a'])
    m0 = pvset(m0,'InitialState','BackCast');
    if lower(init(1))=='e'
        disp('InitialState changed to ''BackCast'', due to fixed parameter.')
    end
    init = 'back';
end
% if 'a' and apparently an idfrd-conversion change to 'z'. If 'e' give a
% warning
if any(lower(init(1))==['e','a','b'])
    ut = pvget(data,'Utility');
    try
        if ut.idfrd
            if ~iniwasa%lower(init(1))=='a'
                warning(sprintf(['Apparently the data will not support estimation of',...
                        ' initial conditions.\nConsider setting ',...
                        '''InitialState'' to ''Zero''.']))
            else
                init = 'zero';
            end
        end
    end
end
%%Check if number of data will support estimation of initial values>
Ncap=sum(N);
if Tsdat{1}==0, m0.nk = zeros(size(m0.nk));end
nxx = max(m0.nf,m0.nb+m0.nk-ones(size(m0.nk)));
nx = sum(nxx);
npar = nx+sum(m0.nb)+sum(m0.nf);
if npar>Ncap
    if lower(init(1))=='e'&~iniwasa
        warning('Too few data points to support estimation of initial states.');
    end
    init='zero';
end
if any(lower(init(1))==['e','a'])|(lower(init(1))=='b'&isempty(par)); %LL Problem då par ej empty och back
    uold = pvget(data,'InputData');
    fre = pvget(data,'Radfreqs');
    int = pvget(data,'InterSample');
    for kexp = 1:Ne
        u{kexp} = [uold{kexp},exp(i*fre{kexp}*Tsdat{kexp})]; 
        int{nu+1,kexp}='zoh';
    end
    data = pvset(data,'InputData',u,'InterSample',int);
    if isempty(par) % modify orders for extra input
        nxx = max(m0.nf,m0.nb+m0.nk-ones(size(m0.nk)));
        nx = sum(nxx);
        m0 = pvset(m0,'nb',[m0.nb nx],...
            'nf',[m0.nf nx],...
            'nk',[m0.nk 1],...
            'InputDelay',[pvget(m0,'InputDelay')',0]','InitialState','z');
    else % Retrieve hidden initial model
        ut = pvget(m0,'Utility');
        try
            minit = ut.minit;
        catch
            minit = [];
        end
        b = pvget(m0,'b');  
        f = pvget(m0,'f');  
        if ~isempty(minit)
            fi = pvget(minit,'f');
            bi = pvget(minit,'b');
        else
            ford = sum(m0.nf);
            fi = zeros(1,ford+1);
            fi(1) = 1;
            fi(end) = 0.9;% To avoid division by zero at start
            fi = fstab(fi,Ts);
            bi = zeros(1,ford+1);
            bi(2:end) = eps*ones(1,ford);
            
        end
        ff = idextmat(f,fi,Ts);
        bb = idextmat(b,bi,Ts);
        m0 = pvset(m0,'b',bb,'f',ff,...
            'InputDelay',[pvget(m0,'InputDelay')',0]','InitialState','z');
    end 
    idm = pvget(m0,'idmodel');
    eflag = 1;
end
%%LL Pname is mixed up in the above
% Now initial state is finished
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial estimate:
Inpd = pvget(m0,'InputDelay');
dats = nkshift(data,Inpd);

[ze,Ne,ny,nu,Tsdata,Name,Ncaps,errflag]=idprep_fp(dats,0,inputname(1));
if isstr(algorithm.MaxSize),...
        algorithm.MaxSize = idmsize(max(Ncaps),sum([m0.na,m0.nb,m0.nc,m0.nd,m0.nf]));
end

error(errflag)
if abs(Ts-Tsdata)>10*eps
    disp(['Model sampling interval changed to ',num2str(Tsdata), ...
            ' (Data''s sampling interval).'])
    m0 = pvset(m0,'Ts',Tsdata);
end
par=pvget(idm,'ParameterVector');
parempt = 0;
if isempty(par)
    parempt = 1;
    mcov = pvget(m0,'CovarianceMatrix');
    m0=inival_f(dats,m0,eflag,realflag);
    if stabenf
        Ts = pvget(m0,'Ts');
        if Ts>0
            thresh = algorithm.Advanced.Threshold.Zstability;
        else
            thresh = algorithm.Advanced.Threshold.Sstability;
        end
        m0 = pvset(m0,'f',fstab(pvget(m0,'f'),Ts,thresh));
    end
    if ischar(mcov)
        m0 =  pvset(m0,'CovarianceMatrix','None');
    end
    par=pvget(pvget(m0,'idmodel'),'ParameterVector');
    if lower(init(1))=='b' % remove the extra model
        nu = size(m0,'nu');
        lsub.type='()';
        lsub.subs = {[1],[1:nu-1]};
        m0 = subsref(m0,lsub);
        eflag = 0;
        m0 = pvset(m0,'InitialState','backcast');
        init = 'b';
        nu = nu-1;
        for kexp = 1:length(ze);
            ze{kexp} = ze{kexp}(:,[1:nu+1,nu+3]);
        end
        par = pvget(m0,'ParameterVector');
    end
end


parini = par;
fixflag = 0;
fixp = pvget(m0,'FixedParameter');
if ~isempty(fixp)
    fixflag = 1;
    if (iscell(fixp)|ischar(fixp))&isempty(pvget(m0,'PName'))
        m0 = setpname(m0);
        idm = pvget(m0,'idmodel');
        fixp=pnam2num(fixp,pvget(m0,'PName'));
    end
end
if fixflag&parempt
    par(fixp) = zeros(length(fixp),1);
    m0 = parset(m0,par);
end

% *** Minimize the prediction error criterion ***
nn.na=m0.na;nn.nb=m0.nb;nn.nc=m0.nc;nn.nd=m0.nd;
nn.nf=m0.nf;nn.nk=m0.nk;nn.nu=nu;
Nbcum=nn.na+sum(nn.nb);Nccum=Nbcum+nn.nc;Ndcum=Nccum+nn.nd;
Nfcum=Ndcum+sum(nn.nf);
nn.nai=[1:nn.na];nn.nci=[Nbcum+1:Nccum];
nn.ndi=[Nccum+1:Ndcum];
s=1;s1=1;
for ku=1:nu
    nn.nbi(ku)={nn.na+s:nn.na+s+nn.nb(ku)-1};
    nn.nfi(ku)={Ndcum+s1:Ndcum+nn.nf(ku)+s1-1};
    s=s+nn.nb(ku);s1=s1+nn.nf(ku);
end
struc = nn;
struc.init = m0.InitialState;
struc.realflag = realflag;
struc.T = pvget(m0,'Ts');
if ischar(pvget(m0,'CovarianceMatrix'))
    struc.cov = 0;
else
    struc.cov = 1;
end

struc.pname = pvget(m0,'PName');
struc.domain ='f'; %%LL
peini = 'e';
if lower(init(1))=='z'
    peini = 'z';
end
num = size(m0,'nu');
was = warning;
warning off
e = pe_f(data(:,:,1:nu),idss(m0),peini,1,realflag);
warning(was)
struc.xi=[];

struc.lambda = e'*e/length(e); 
algotithm.LimitError = 0; % No lim for FD data
if algorithm.LimitError~=0
    Ncap = length(e);
    algorithm.LimitError=median(abs(e-ones(Ncap,1)*median(e)))*algorithm.LimitError/0.7;
end

it_inf = pvget(idm,'EstimationInfo');
struc.type='poly';
if Ne == 1
    ze = ze{1};
end
trace=0;
if strcmp(lower(algorithm.Trace),'on')
    trace=1;
elseif strcmp(lower(algorithm.Trace),'full')
    trace=2;
end

% *** Display the initial estimate ***
if trace
    disp(['Initial Estimate:'])
    disp(['   Current loss:' num2str(det(struc.lambda))])
    if trace>1
        disp(['   ParVector'])
        disp(par) 
    end
end
m=m0;
num = size(m,'nu');
it_inf.DataLength=sum(Ncaps);
it_inf.DataTs=Tsdata;
it_inf.LossFcn = det(struc.lambda);
it_inf.DataInterSample=pvget(data(:,:,1:nu),'InterSample'); 
it_inf.Status='Estimated model (PEM)';
it_inf.DataName=pvget(data,'Name');
it_inf.DataDomain = 'Frequency';
it_inf.Method = 'PEM';
it_inf.WhyStop = 'No Iterations demanded';
it_inf.Iterations = 0;
lambda = struc.lambda;
cov = [];
parnew = parini;
if ~(algorithm.MaxIter(1)==0|length(par)==0)
    [parnew,strucnew,it_inf,cov,lambda]=minloop(ze,par,struc,algorithm,it_inf);
    
    if lower(struc.init(1))=='e'
        ppn = length(parnew);
        ppn = ppn-length(xi);
        ut = pvget(idm,'Utility');
        ut.x0 = parnew(ppn+1:end);
        idm = pvset(idm,'Utility',ut);
        parnew = parnew(1:ppn);
        if ~isempty(cov)&~ischar(cov)
            cov = cov(1:ppn,1:ppn);
        end
    end
end
lambda = (lambda+lambda')/2;
idm=pvset(idm,'CovarianceMatrix',cov,'NoiseVariance',lambda,...
    'EstimationInfo',it_inf,'ParameterVector',parnew,...
    'InputName',pvget(data,'InputName'),...
    'OutputName',pvget(data,'OutputName'),'InputUnit',...
    pvget(data,'InputUnit'),'OutputUnit',...
    pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'),'Approach','Pem');
m = pvset(m,'idmodel',idm);
m = timemark(m);
idm = pvget(m,'idmodel');
es = pvget(idm,'EstimationInfo');
es.InitialState = init;

if eflag
    nu = size(m,'nu');
    lsub.type='()';
    lsub.subs = {[1],[nu]};
    minit = subsref(m,lsub);
    lsub.subs = {[1],[1:nu-1]};
    m = subsref(m,lsub);
    idm = pvget(m,'idmodel');
    ut = pvget(idm,'Utility');
    ut.minit = minit;
    idm = uset(idm,ut);
    es.Status = 'Estimated model (PEM)';
    m = pvset(m,'InitialState',init);
end
idm = pvset(idm,'EstimationInfo',es);
m = llset(m,{'idmodel'},{idm});
