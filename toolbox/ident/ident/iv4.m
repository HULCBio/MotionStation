function m=iv4(varargin)
%IV4    Computes approximately optimal IV-estimates for ARX-models.
%   MODEL = IV4(DATA,NN)
%
%   MODEL: returned as the estimate of the ARX model
%   A(q) y(t) = B(q) u(t-nk) + v(t)
%   along with estimated covariances and structure information.
%   For the exact format of MODEL see also HELP IDPOLY and HELP IDARX (for
%   multi-output models.)
%
%   DATA: the output-input data  and an IDDATA object. See HELP IDDATA. 
%
%   NN: NN = [na nb nk], the orders and delays of the above model.
%   For multi-output systems, NN has as many rows as there are outputs
%   na is then an ny|ny matrix whose i-j entry gives the order of the
%   polynomial (in the delay operator) relating the j:th output to the
%   i:th output. Similarly nb and nk are ny|nu matrices. (ny:# of outputs,
%   nu:# of inputs).
%
%   An alternative syntax is MODEL = IV4(DATA,'na',na,'nb',nb,'nk',nk)
%
%   Some parameters associated with the algorithm are accessed by
%   MODEL = IV4(DATA,ORDERS,'MaxSize',MAXSIZE)
%   where MAXSIZE controls the memory/speed trade-off. See the manual.
%   When property/value pairs are used, they may come in any order.
%   Omitted ones are given default values.
%   The MODEL properties 'FOCUS' and 'INPUTDELAY' may be set as a
%   Property/Value pair as in
%   M = IV4(DATA,[na nb nk],'Focus','Simulation','InputDelay',[3 2]);
%   See IDPROPS ALGORITHM and IDPROPS IDMODEL.
%    
%   See also ARX, ARMAX, BJ, N4SID, OE, PEM.

%   L. Ljung 10-1-86,4-15-90
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.1 $  $Date: 2004/04/10 23:19:04 $
if nargin < 2
    disp('Usage: MODEL = IV4(Z,ORDERS)')
    disp('       MODEL = IV4(Z,ORDERS,Prop/Value pairs)')
    if nargout, m=[];end
    return
end
[mdum,data,p] = arxdecod(varargin{:});
if isa(data,'iddata')
    data = setid(data);
    if isempty(pvget(data,'Name'))
        data = pvset(data,'Name',inputname(1));
    end
    mdum = setdatid(mdum,getid(data));

end
if isa(mdum,'idarx')
    try
        m = iv4(data,mdum); % what about p?
    catch
        error(lasterr)
    end
    return
end
% if isa(data,'iddata')
%     if strcmp(lower(pvget(data,'Domain')),'frequency')
%         m = iv4_f(data,mdum);
%         return
%     end
% end

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
    data = nkshift(data,Inpd); 
    [ze,Ne,ny,nu,Ts,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
    error(errflag)
    maxsize = pvget(mdum,'MaxSize'); 
    if ischar(maxsize)|isempty(maxsize),
        maxsize=idmsize(max(Ncaps));
    end
    
end
n=na+sum(nb);
if n==0,
    th=[];
    if p>0, disp('All orders are zero. No model returned.');end
    return
end
if (ischar(foc)&any(strcmp(foc,{'Simulation','Stability'})))|~ischar(foc) ...
        %% The focus
    foc0 =foc;
    mdum = pvset(mdum,'Focus','Prediction','InputDelay',zeros(nu,1));
    m0 = arx(data,mdum);
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
            m1 = iv4(datat,m0,'na',0);
            m = pvset(m1,'a',a,'InputDelay',Inpd);
            es = pvget(m,'EstimationInfo');
            es.Method = 'IV4 (Stabilized)';
            m = pvset(m,'EstimationInfo',es,'Focus',foc0);
        else
            m = pvset(m0,'Focus',foc0,'InputDelay',Inpd);
        end
        return
        
    elseif isa(foc,'idmodel')|isa(foc,'lti') |iscell(foc)
        ts = pvget(data,'Ts');ts=ts{1};
        foc = foccheck(foc,ts,pvget(m0,'a'));
    elseif strcmp(foc,'Simulation')
        foc = {1,fstab(pvget(m0,'a'))};
    end
    zf = idfilt(data,foc);
    m = iv4(zf,mdum,'focus','Stability');
    es = pvget(m,'EstimationInfo');
    es.Method = 'IV4 with focus';
    
    m = pvset(m,'EstimationInfo',es,'InputDelay',Inpd,'Focus',foc0);
    m = setdatid(m,getid(data));
    return
end
if isa(data,'iddata')
    if strcmp(lower(pvget(data,'Domain')),'frequency')
        mdum = pvset(mdum,'MaxSize',maxsize);
        m = iv4_f(data,mdum);
        m = pvset(m,'InputDelay',Inpd);
            m = setdatid(m,getid(data));

        return
    end
end

%
% *** First stage: compute an LS model ***
%
th=arx(ze,[na nb nk],maxsize,Ts,0);
if na>0, 
    a=fstab([1 th(1:na).']);
else 
    a=1;
end
b=zeros(nu,max(nb+nk));
NBcum=cumsum([na nb]);
for k=1:nu, 
    b(k,nk(k)+1:nk(k)+nb(k))=th(NBcum(k)+1:NBcum(k+1)).';,
end
%
% *** Second stage: Compute the IV-estimates using the LS
%     model a, b for generating the instruments ***
%
th=iv(ze,[na nb nk],a,b,maxsize,Ts,0);
if na>0,
    a=[1 th(1:na).'];
else 
    a=1;
end
for k=1:nu,
    b(k,nk(k)+1:nk(k)+nb(k))=th(NBcum(k)+1:NBcum(k+1)).';
end
%
% *** Third stage: Compute the residuals, v, associated with the
%     current model, and determine an AR-model, A, for these ***
%
for kexp = 1:Ne
    z = ze{kexp};
    v{kexp}=filter(a,1,z(:,1));
    for k=1:nu, 
        v{kexp}=v{kexp}-filter(b(k,:),1,z(:,k+1));
    end
end

art=arx(v,na+sum(nb),maxsize,Ts,0);
Acap=[1 art.'];
%
% *** Fourth stage: Use the optimal instruments ***
%
for kexp= 1:Ne
    z = ze{kexp};
    yf=filter(Acap,[1],z(:,1));
    clear uf
    for k=1:nu, 
        uf(:,k)=filter(Acap,[1],z(:,k+1));
    end
    if p~=0, p=2;,end
    if na>1
        a=fstab(a);
    else
        a=1;
    end
    zfi{kexp}=[yf uf];
end

m1=iv(zfi,[na nb nk],a,b,maxsize,Ts,p);

m=m1.model;
cov = m1.cov;
try
    norm(cov);
catch
    disp('Covariance Matrix Ill-conditioned. Not stored.')
    cov = [];
end
e = pe(m,data);
ey = pvget(e,'OutputData');
ey = cat(1,ey{:});
loss1 = ey'*ey;
V = loss1/length(ey);
nv = loss1/(length(ey)-length(pvget(m,'ParameterVector')));

%V = m1.V;

idm = pvget(m,'idmodel');
it_inf = pvget(idm,'EstimationInfo');
it_inf.Method = 'IV4';
it_inf.DataLength=sum(Ncaps);
it_inf.DataTs=Ts;
it_inf.DataInterSample=pvget(data,'InterSample'); 
it_inf.Status='Estimated model (IV4)';
it_inf.DataName=Name;
it_inf.InitialState = pvget(m,'InitialState');
it_inf.LossFcn = V;
it_inf.FPE = V*(1+length(th)/sum(Ncaps))/(1-length(th)/sum(Ncaps));
idm = pvset(idm,'MaxSize',maxsize,'CovarianceMatrix',cov,...
    'EstimationInfo',it_inf,'Ts',Ts,'NoiseVariance',nv,'InputDelay',Inpd); 
idm = idmname(idm,data);
m = llset(m,{'idmodel'},{idm});
    m = setdatid(m,getid(data));

m = timemark(m);

% *** Reference: Equations (15.221) - (15.26) in Ljung(1987) ***
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = iv4_f(data,mdum)
% check also nkshift focus
if realdata(data)
    realflag = 1;
else
    realflag = 0;
end
data = complex(data);
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
    data = pvset(data,'InputData',Uc); % check intersample here
end
%nkshift fixed outside this routine
ma = arx(data,[na nb nk],'ini','z');
mb = iv(data,[na nb nk],pvget(ma,'a'),pvget(ma,'b'),pvget(mdum,'MaxSize'));
e = pe(data,mb);
mv = arx(e,na+sum(nb));
try
dataf = idfilt(data,{pvget(mv,'a'),1});
catch
    dataf = data;
end
m = iv(dataf,[na nb nk],pvget(mb,'a'),pvget(mb,'b'),pvget(mdum,'MaxSize'));
if lower(ini(1))~='z' 
    m = m(1,1:nuorig);
    data = data(:,:,1:nuorig);
end
%%% set initmodell mm?
%return
e = pe(data,m); ey = pvget(e,'OutputData');
 
th = pvget(m,'ParameterVector');
if realflag
    m = pvset(m,'ParameterVector',real(th));
    m = pvset(m,'CovarianceMatrix',real(pvget(m,'CovarianceMatrix')));
end
ey = cat(1,ey{:});
loss1 = ey'*ey;
loss = loss1/length(ey);
nv = loss1/(length(ey)-length(th));
idm = pvget(m,'idmodel');
it_inf = pvget(idm,'EstimationInfo');
it_inf.Method = 'IV4';
Ncaps = size(data,'N');
it_inf.DataLength=sum(Ncaps);
Ts = pvget(data,'Ts'); Ts = Ts{1};
it_inf.DataTs=Ts;
it_inf.DataInterSample=pvget(data,'InterSample'); 
it_inf.Status='Estimated model (IV4)';
it_inf.DataName=pvget(data,'Name');
it_inf.LossFcn = loss;
it_inf.DataDomain = 'Frequency';
%cov = [];%%LL
it_inf.FPE = loss*(1+length(th)/sum(Ncaps))/(1-length(th)/sum(Ncaps));
idm = pvset(idm,'MaxSize',maxsize,...%'CovarianceMatrix',cov,...
    'EstimationInfo',it_inf,'Ts',Ts,'NoiseVariance',nv); 
idm = idmname(idm,data);
m = llset(m,{'idmodel'},{idm});

m = timemark(m);
