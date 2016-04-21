function m=pem(data,m0,varargin)
%IDPOLY/PEM	Estimate of a general linear polynomial model.
%
%   M = PEM(Z,Mi)  
%
%   Mi = [na nb nc nd nf nk] gives a general polynomial model:
%	  A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%     with the indicated orders (For multi-input data nb, nf and
%     nk are row vectors of lengths equal to the number of input channels.)
%     An alternative syntax is MODEL = PEM(DATA,'na',na,'nb',nb,...) with
%     omitted orders taken as zero.  
%
%   CONTINUOUS TIME MODEL ORDERS: If Z is continuous time frequency domain
%   data, then continuous time Output Error models (na = nc = nd = 0) can be
%   estimated directly. Nf then denotes the number of denominator coefficients
%   and nb the number of numerator coefficients. Nk is then of no
%   consequence and should be omitted. In this case it is easier to use OE.
%   Example: Mi = [0 2 0 0 3 0] gives a model
%   (b1*s + b2)/(s^3 + f1*s^2 + f2*s + f3)
%
%   M : returns the estimated model in the IDPOLY  object format
%   along with estimated covariances and structure information. 
%   For the exact format of M see also help IDPOLY.
%
%   Z :  The estimation data in IDDATA object format. See help IDDATA.
%
%   Mi: An IDPOLY model object that defines the model structure. 
%	 The minimization is initialized at the parameters given in Mi. 
%
%   By M = pem(Z,Mi,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See help IDSS or help IDPOLY for a list of
%   Property/Value pairs.

%	L. Ljung 10-1-86, 7-25-94
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.32.4.2 $  $Date: 2004/04/10 23:16:37 $

if nargin<1
    disp('       M = PEM(Z,Mi)  For IDPOLY model Mi')
    disp('       M = PEM(Z,Mi,Property_1,Value_1,...,Property_n,Value_n)')
    return
end
[m0,data,order] = pemdecod('pem',data,m0,varargin{:});

if isa(data,'iddata')
    dom = pvget(data,'Domain');
    data = setid(data);
else
    dom = 'Time';
end
if ~isa(m0,'idpoly')  % then there must be an IDPOLY focus filter in varargin
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
    
    m = pem(data,order,varargin{:});
    %m = setdataid(m,getid(data),ynorm);

    return
end    
if strcmp(lower(dom(1)),'f')
    m = pem_f(data,m0,varargin{:});
    m = setdatid(m,getid(data),[]);

    return
end
%
% Now the input parsing is finished.
% First check if the data should be shifted.
%idm=m0.idmodel;

Ts = pvget(m0,'Ts');
[ny,nu]=size(m0);
if Ts == 0
    error(sprintf(['PEM does not handle continuous time IDPOLY models.'...
            ' \nUse Canonical IDSS models instead for continuous' ...
            ' time models,\n'...
            'or build discrete time model and convert with' ...
            ' d2c.']))
end
if  ~isa(data,'iddata')
    if ~isa(data,'double')
        error(['The data must either be an IDDATA object or a matrix' ...
                ' of reals.'])
    end
    
    data = iddata(data(:,1),data(:,2:end),Ts);
else
    %utd = pvget(data,'Utility');
    %try
     %   dataid = getid(data);
        %catch
        %dataid = 0;
        %end
    [N,nyd,nud]=size(data);
    if nyd~=1|nud~=nu
        error(sprintf(['The model size is not consistent with the number of ',...
                'inputs \nand outputs in the data.']))
    end
end 

Inpd = pvget(m0,'InputDelay');
dats = nkshift(data,Inpd);
[ze,Ne,ny,nu,Tsdata,Name,Ncaps,errflag,ynorm]=idprep(dats,0,inputname(1));
error(errflag)
if abs(Ts-Tsdata)>10*eps
    disp(['Model sampling interval changed to ',num2str(Tsdata), ...
            ' (Data''s sampling interval).'])
    m0 = pvset(m0,'Ts',Tsdata);
end
algorithm=pvget(m0,'Algorithm'); 
foc = algorithm.Focus;
if nu == 0 & ~any(strcmp(foc,{'Prediction','Stability'}))
    warning('For time-series ''Focus'' does not apply.')
    algorithm.Focus = 'Prediction';
    foc = 'Prediction';
end

if isstr(algorithm.MaxSize),...
        algorithm.MaxSize = idmsize(max(Ncaps),sum([m0.na,m0.nb,m0.nc,m0.nd,m0.nf]));
end

pfoc = 1;
if ischar(foc)
    if any(strcmp(foc,{'Prediction','Stability'}))|...
            (sum([m0.na,m0.nc,m0.nd])==0&strcmp(foc,'Simulation'))
        pfoc = 0;
    end
end
if pfoc
    m = pemfocus(data,m0,foc); % Data not shifted
    m = setdatid(m,getid(data),ynorm);

    return
end

par=pvget(m0.idmodel,'ParameterVector');

parempt = 0;
if isempty(par)
    parempt = 1;
    m0=inival(ze,m0);
    par=pvget(m0.idmodel,'ParameterVector'); 
    
end

parini = par;
fixflag = 0;
fixp = pvget(m0,'FixedParameter');
if ~isempty(fixp)
    fixflag = 1;
    if (iscell(fixp)|ischar(fixp))&isempty(pvget(m0,'PName'))
        m0 = setpname(m0);
        %idm = pvget(m0,'idmodel');
        fixp=pnam2num(fixp,pvget(m0,'PName'));
    end
end
if fixflag&parempt
    par(fixp) = zeros(length(fixp),1);
    m0 = parset(m0,par);
end
[A,B,C,D,K] = ssdata(m0);

if max(abs(eig(A-K*C))) > algorithm.Advanced.Threshold.Zstability
    warning(sprintf(['The initial model has an unstable predictor.\nMake sure',...
            ' that the C-polynomial and the F-polynomials are stable.\nFSTAB may',...
            ' be used for the stabilization.']))
    if fixflag
        disp(sprintf(['The instabilty is most likely caused by fixing a parameter in',...
                '\nthe C or F polynomial to zero, which makes the startup model unstable.'...
                '\nYou will have to create a stable initial predictor yourself.']))
    else
        m0 = pvset(m0,'c',fstab(pvget(m0,'c')));
        par=pvget(m0.idmodel,'ParameterVector'); 
    end
end
if max(abs(eig(A)))>algorithm.Advanced.Threshold.Zstability & strcmp(pvget(m0,'Focus'),'Stability')
    m0 = pvset(m0,'a',fstab(pvget(m0,'a')));
    par=pvget(m0.idmodel,'ParameterVector'); 
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
if ischar(pvget(m0,'CovarianceMatrix'))
    struc.cov = 0;
else
    struc.cov = 1;
end

struc.pname = pvget(m0,'PName');
if nn.nc+sum(nn.nf)==0 & strcmp(struc.init,'Backcast')
    warning(sprintf(['For a model with nc=nf=0, ''Estimate'' is used',...
            ' instead of ''Backcast''.']));
    struc.init = 'Estimate';
    %m0.InitialState = 'Estimate';
end
if Ne>1&(strcmp(struc.init,'Estimate'))%|strcmp(struc.init,'Zero'))
    warning(sprintf(['InitialState = ''Estimate''  cannot be used for multiple experiment data.',...
            '\nIt has been changed to ''Backcast''.']));
    struc.init = 'Backcast';
    %m0.InitialState = 'Backcast';
end

if strcmp(struc.init,'Auto')
    if Ne>1
        struc.init = 'Backcast';
        %m0.InitialState = 'Backcast';
    else
        e1 = pe(data,m0,'z');e1=pvget(e1,'OutputData');
        [e2,xi] = pe(data,m0,'e');e2 =pvget(e2,'OutputData');
        nor1 = norm(e1{1}); nor2 =norm(e2{1});
        if nor1/nor2>algorithm.Advanced.Threshold.AutoInitialState
            %if nn.nc+sum(nn.nf)==0
            initval = 'Estimate';
            %else
            %   initval = 'Backcast';
            %end
            struc.init = initval;
            %m0.InitialState = initval;
        else
            struc.init = 'Zero';
            %m0.InitialState = 'Zero'; 
        end
    end
end

if lower(struc.init(1))=='e'  
    [e,xi]=pe(ze,m0);
    if isempty(xi)
        warning('No need to estimate initial state in this case. InitialState set to ''zero''.')
        struc.init = 'Zero';
    end
    struc.xi=[Nfcum+1:Nfcum+length(xi)];
    par = [par;xi];
else
    e = pe(ze,m0);
    struc.xi=[];
end
struc.lambda = e'*e/length(e); 
if algorithm.LimitError~=0
    Ncap = length(e);
    algorithm.LimitError=median(abs(e-ones(Ncap,1)*median(e)))*algorithm.LimitError/0.7;
end

it_inf = pvget(m0.idmodel,'EstimationInfo');
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
%%%%% testing for the future
% try
%     if ~isempty(algorithm.BoundParameter)
%         struc.bounds = algorithm.BoundParameter; 
%         bounds = struc.bounds;
%         par(bounds(:,1)) = min(max(par(bounds(:,1)),bounds(:,2)),bounds(:,3));
%         
%     end%%LL
% end
%%%%% end testing
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
Nobs = sum(Ncaps);
it_inf.DataLength=Nobs;
it_inf.DataTs=Tsdata;
V1 = det(struc.lambda);
it_inf.LossFcn = V1;
nparfpe = length(par) - length(algorithm.FixedParameter);
it_inf.FPE = V1*(1+nparfpe/Nobs)/(1-nparfpe/Nobs);
it_inf.DataInterSample=pvget(data,'InterSample'); 
it_inf.Status='Estimated model (PEM)';
it_inf.DataName=pvget(data,'Name');
it_inf.Method = 'PEM';
it_inf.WhyStop = 'No Iterations demanded';
it_inf.Iterations = 0;
lambda = struc.lambda;
cov = [];
parnew = parini;
if ~(algorithm.MaxIter(1)==0|length(par)==0)
    % prepared for new code
    %switch algorithm.OptimizationRoutine
    %   case 'sitb'
            [parnew,strucnew,it_inf,cov,lambda]=minloop(ze,par,struc,algorithm,it_inf);
%         case 'lsqnonlin'
%             ind1 = algorithm.FixedParameter;
%             np = length(par);
%             ind2 = [1:np]';
%             if isempty(ind1)
%                 ind3=ind2;
%             else
%                 indt = ind2*ones(1,length(ind1))~=ones(npar,1)*ind1(:)';
%                 if size(indt,2)>1, indt=all(indt');end
%                 ind3 = ind2(find(indt));
%             end
%             algorithm.estindex=ind3;
%             
%             arg.z = ze; arg.struc = struc;arg.oeflag = 0;arg.algorithm=algorithm;
%             opt=optimset('lsqnonlin');opt.GradObj = 'on';
%             bounds = repmat([-inf inf],np,1);
%             bounds = [[1:np]',bounds];
%             bounds(struc.bounds(:,1),[2 3])= struc.bounds(:,[2 3]);
%             parnew = lsqnonlin('testres',par,bounds(:,2),bounds(:,3),opt,arg);
%             [e,psi] = testres(parnew,arg);
%             lambda = e'*e/length(e);
%             cov = lambda * inv(psi'*psi);
%             %it_inf=[];
%     end
    
    if lower(struc.init(1))=='e'
        ppn = length(parnew);
        ppn = ppn-length(xi);
        ut = pvget(m0.idmodel,'Utility');
        ut.x0 = parnew(ppn+1:end);
        m0.idmodel = pvset(m0.idmodel,'Utility',ut);
        parnew = parnew(1:ppn);
        if ~isempty(cov)&~ischar(cov)
            cov = cov(1:ppn,1:ppn);
        end
    end
end
utm = pvget(m0.idmodel,'Utility');
 
m.idmodel=pvset(m.idmodel,'CovarianceMatrix',cov,'NoiseVariance',lambda,...
    'EstimationInfo',it_inf,'ParameterVector',parnew,...
    'InputName',pvget(data,'InputName'),...
    'OutputName',pvget(data,'OutputName'),'InputUnit',...
    pvget(data,'InputUnit'),'OutputUnit',...
    pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'),'Approach','Pem',...
    'Utility',utm);
%m.idmodel=idm;
m = timemark(m);
m = setdatid(m,getid(data),ynorm);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = pemfocus(data,m0,foc)
if isempty(pvget(m0,'ParameterVector'))
m1 = m0;
m1.na = 0;
m1.nb = m0.nb; nu = size(m0.nb,2);
m1.nc = 0;
m1.nd = 0;
m1.nf = m0.na+m0.nf;
else
    nu = size(m0.nb,2);
    if ~(nu>1&m0.na>0) 
        if nu>1
            f = pvget(m0,'f');
        else
            f = conv(pvget(m0,'a'),pvget(m0,'f'));
        end
    m1=pvset(m0,'a',1,'c',1,'d',1,'f',f);
    end
end
   
if nu>1&m0.na>0
    m = misoarm(data,m0,foc);
    return
   % error('For multi-input ARMAX models with a focus, use state-space models.')
    % The reason is that OE cannot enforce all F-polynomials to be the same
end
if m0.na>0&any(m0.nf)>0
    error('For polynomial models with a focus, either A or F should be 1.')
end

%if isa(foc,'idmodel')|isa(foc,'lti')|iscell(foc) 
ts = pvget(data,'Ts');ts = ts{1};
dom = pvget(data,'Domain'); 
foc = foccheck(foc,ts,[],lower(dom(1)),pvget(data,'Name'));
zf = data;
if ~isa(foc,'char')
    zf = idfilt(data,foc);
end
%else
%   warning(sprintf(['Defining a focus filter by weights or passbands is',...
%      '\npossible only for frequency domain data.']))
% zf = data;
%end

m1 = pvset(m1,'Focus','Prediction');
tr = pvget(m0,'Trace');
if ~strcmp(tr,'Off')
    disp('Finding the model dynamics ...')
end
m1=pem(zf,m1);
if m0.nc + m0.nd == 0
    m = m1;
    m=pvset(m,'Focus',pvget(m0,'Focus'));
    
    return
end
cov1 = pvget(m1,'CovarianceMatrix');
f = pvget(m1,'f');
w = pe(data,m1,'e'); % No split between A and F here
if m0.nf==0
    wfilt = idpoly(1,f); 
    [a,b,c,d] = ssdata(wfilt);
    wfilt = {a,b,c,d};
    w = idfilt(w,wfilt); 
end
if ~strcmp(tr,'Off')
    disp('Finding the noise model ...')
end
mts = armax(w,[m0.nd m0.nc],'trace',tr); 
cov2=pvget(mts,'CovarianceMatrix');
if isempty(cov2),cov1=[];end
m=m1;
ind2 = [m0.nd+1:m0.nd+m0.nd,1:m0.nc]+m0.na+sum(m0.nb);
cov = cov1;
if ~ischar(cov)&~isempty(cov)
    cov = [[cov1,zeros(size(cov1,1),size(cov2,2))];...
            [zeros(size(cov2,1),size(cov1,2)),cov2]];
end

if m0.nf==0
    a = f; f = 1;
    if ~ischar(cov)&~isempty(cov)
        ind1 = [sum(m0.nb)+1:sum(m0.nb)+m0.na,1:sum(m0.nb)];
        cov = cov([ind1,ind2],[ind1,ind2]); 
    end
else
    a = 1;
    if ~ischar(cov)&~isempty(cov)
        ind = [1:sum(m0.nb),sum(m0.nb)+sum(m0.nf)+m0.nd+1:length(cov),...
                sum(m0.nb)+sum(m0.nf)+1:sum(m0.nb)+sum(m0.nf)+m0.nd,...
                sum(m0.nb)+1:sum(m0.nb)+sum(m0.nf)];
        cov=cov(ind,ind);
    end
end

m=pvset(m,'a',a,'c',pvget(mts,'c'),'d',pvget(mts,'a'),'f',f); 
e = pe(m,data); ee=pvget(e,'OutputData');
ee=cat(1,ee{:}); V = ee'*ee/length(ee);
m=pvset(m,'CovarianceMatrix',cov,'Focus',pvget(m0,'Focus'),'NoiseVariance',V);
es = pvget(m,'EstimationInfo');
es.LossFcn = V;
Nobs = size(data,'N'); Nobs = sum(Nobs);
npar = size(cov,1);
es.FPE = V*(1+npar/Nobs)/(1-npar/Nobs);
es.Status='Estimated model (PEM with focus)';
es.DataName = pvget(data,'Name');
m.idmodel=pvset(m.idmodel,'EstimationInfo',es,'Approach','Pem'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = misoarm(data,m0,foc)
nu = size(data,'nu');
foc0 = foc;
Inpd = pvget(m0,'InputDelay');
mp = pem(data,m0,'foc','prediction','InputDelay',zeros(nu,1));
a = pvget(mp,'a');
if ischar(foc)&strcmp(foc,'Stability')
    a = pvget(m0,'a');
    alg = pvget(m0,'Algorithm');
    if any(abs(roots(a))>alg.Advanced.Threshold.Zstability)
        a = fstab(a);
        %m0 = pvset(m0,a);
        y = data(:,:,[]);
        yt = idfilt(y,{a,1});
        datat = data;
        datat(:,:,[]) = yt;
        m1 = armax(datat,m0,'na',0);
        m = pvset(m1,'a',a,'InputDelay',Inpd);
        es = pvget(m,'EstimationInfo');
        es.Method = 'ARMAX (Stabilized)';
        m = pvset(m,'EstimationInfo',es,'Focus',foc0);
    else
        m = pvset(mp,'Focus',foc0,'InputDelay',Inpd);
    end
    return
end
if isa(foc,'idmodel')|isa(foc,'lti') |iscell(foc)
    ts = pvget(data,'Ts');ts=ts{1};
    foc = foccheck(foc,ts,a);
elseif strcmp(foc,'Simulation')
    foc = foccheck({1,1},1,a);
end

zf = idfilt(data,foc);
m = pem(zf,m0,'focus','stability');
es = pvget(m,'EstimationInfo');
es.Method = 'PEM with focus';

m = pvset(m,'EstimationInfo',es,'InputDelay',Inpd,'Focus',foc0);




