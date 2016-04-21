function m = pem(z,m0,varargin)
% IDPROC/PEM Estimates IDPROC models with a prediction error method
%   MODEL = PEM(DAT,IDP) or MODEL = PEM(DATA,IDP,Property/Value pairs)
%  
%   MODEL is the estimated model, delivered as an IDPROC model object.
%   (See HELP IDPROC)
%   DAT is the input/output data as an IDDATA object.
%   IDP is an IDPROC model containing the initial parameters.
%   For a default IDPROC object, like IDPROC('P1D'), a special
%   initialization is invoked to produce an initial guess. See
%   HELP IDPROC or IDPROPS IDPROC for a description of the acrynoms
%   that define the model type and  other Property/Value pairs.
%
%   Note that an extended syntax allows to set the fields of the parameters
%   directly, as in
%   M = PEM(DAT,'P1D','kp',15)
%   to initialize the gain parameter Kp in the value 15,
%   M = PEM(DAT,'p1d','kp',{'max',3},'kp',{'min',2})
%   to constrain the gain to lie between 2 and 3 or
%   M = PEM(DAT,'P2Z','kp',1.2,'kp','fix')
%   to fix the gain to the value 1.2
%
%   Any Property/Value pair can be added after the input arguments.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $ $Date: 2004/04/10 23:17:13 $


if isa(z,'idfrd')|isa(z,'frd')
    z = iddata(idfrd(z));
end
if ~isa(z,'iddata')
    error('The first argument must be an IDDATA object. Use DAT = IDDATA(y,u,Ts).')
end
z = setid(z);
if ~realdata(z)
    error(sprintf(['IDPROC models can only be estimated from real-valued data.\n',...
            '(Frequency Domain data corresponding to real-valued time data are OK.)']))
    end
z = estdatch(z,0);
[varargin,datarg] = pnsortd(varargin);
if ~isempty(datarg), z = pvset(z,datarg{:});end
if isempty(pvget(z,'Name'))
    z = pvset(z,'Name',inputname(1));
end
frdflag = 0;
utd = pvget(z,'Utility');
try
    if utd.idfrd
        frdflag = 1;
    end
end

dom = pvget(z,'Domain');
dom = lower(dom(1));
[Nc,ny,nu,Nexp] = size(z,'nu');
if length(varargin)>0
    set(m0,varargin{:});
end
[nym,num] = size(m0);
if ny>1
    error('Process Models only support single output data.')
end
if num~=nu
    if num ==1
        m1 = m0;
        for ku = 2:nu
            m1 = [m1,m0];
        end
        m0 = m1;
        warning('All inputs assigned the same Type.')
        
    else
        error(sprintf(['The  data has %d inputs, while a model with %d inputs',...
                ' has been defined.\nUse cell arrays of the type {''P1D'',''P3''}',...
                '\nto define process models with several inputs.'],nu,num));
    end
end
if dom=='f'&~strcmp(pvget(m0,'DisturbanceModel'),'None')
    error('Disturbance Model estimation not supported for Frequency Domain data.')
end
typec = pvget(m0,'Type');
if dom=='f'&(~isempty(findstr('I',[typec{:}])))
    samp = pvget(z,'SamplingInstants');
    y = pvget(z,'OutputData');
    u = pvget(z,'InputData');
    for kexp=1:Nexp
        zerfr = find(abs(samp{kexp})<100*eps);
        y{kexp}(zerfr,:)=[];
        u{kexp}(zerfr,:)=[];
        samp{kexp}(zerfr)=[];
    end
    z = pvset(z,'OutputData',y,'InputData',u,'SamplingInstants',samp);
end

Td = pvget(m0,'Td');% check upper bound on Td:
tdmax = Td.max;
Tsdat = pvget(z,'Ts');
if Tsdat{1}==0
    error('Currently, IDPROC models cannot be estimated from continuous time data.')
end
flagtd = 0;
for ku = 1:length(tdmax)
    if Td.status{ku}(1)=='e'&isinf(tdmax(ku))
        tdmax(ku)= 30*Tsdat{1};
        flagtd = 1;
    end
end

if flagtd
    Td.max = tdmax;
    m0 = pvset(m0,'Td',Td);
    if length(tdmax)>1
        br1 = '['; br2 =']';
    else
        br1 ='';br2=br1;
    end
    warning(['Td.max has been set to ',br1,sprintf(' %0.5g',tdmax),br2,' sec (30 samples).'])
end
foc = pvget(m0,'Focus');
foccase = 0;
focch = 0;
dist = pvget(m0,'DisturbanceModel');
if iscell(dist)
    dist=dist{1};
end

if ~ischar(foc)
    foccase = 1;
elseif strcmp(foc,'Simulation') 
    if ~strcmp(dist,'None')
        foccase = 1;
    end
end
if foccase
    ts = pvget(z,'Ts');ts = ts{1};
    dataname = pvget(z,'Name');
    foc = foccheck(foc,ts,0,dom,dataname);
    
    if strcmp(dist,'None')% first the simple filtering
        z = idfilt(z,foc,'causal');
        m0 = pvset(m0,'Focus','Prediction');
        focch = 1;
    else
        m = pemfocus(z,m0,foc); 
        return
    end
end
% sort out fixedparameters from parameter properties
fixp = getfixpar(m0);
m0 = pvset(m0,'FixedParameter',fixp);
[par,pmax,pmin,pnr,dnr,bnr] = pbounds(m0);
bounds = [bnr,pmin(bnr),pmax(bnr)];
filea = pvget(m0,'FileArgument');
filea{7} = bounds; 
m0.idgrey = pvset(m0.idgrey,'FileArgument',filea,'FixedParameter',fixp);
init = pvget(m0,'InitialState');
type = pvget(m0,'Type');
if frdflag
    if any(lower(init(1))==['b','e'])
        warning(sprintf(['InitialState has been changed to ''Zero'' since the',...
                '\ndata originate from IDFRD data.']))
    end
    init='zero';
end
if any(lower(init(1))==['a','e']) & ~isempty(findstr('d',lower([type{:}]))); 
    if lower(init(1))=='e'
        warning('InitialState has been changed to ''BackCast'' since a delay is estimated.')
    end
    if dom=='f'
        tsw = sprintf('%s ',type{:});
             tsw = tsw(1:end-1);
             if length(type)>1
                 tsw = ['{',tsw,'}'];
             end
    warning(sprintf(['Consider using InitialState = ''Zero'', possibly followed',...
            ' by some ''Backcast'' iterations,\n',...
           'since estimating large delays with frequency domain data may',...
            ' be slow:',... 
            '\nm = pem(data,%s,''ini'',''z''); m = pem(data,m,''ini'',''b'').'],tsw))
end
    m0 = pvset(m0,'InitialState','BackCast');
    init = 'backcast';
end
ulev = pvget(m0,'InputLevel');
if any(strcmp(ulev.status,'estimate'))&dom=='f'
    error('The InputLevel cannot be estimated for frequency domain data.')
end
if any(lower(init(1))=='a')
    if any(strcmp(ulev.status,'estimate'))
        m0=pvset(m0,'InitialState','Estimate');
        init = 'estimate';
    elseif any(strcmp(ulev.status,'fixed'))
        m0 = pvset(m0,'InitialState','fixed');
        init = 'fixed';
    end
end
if any(strcmp(ulev.status,'estimate'))
    if any(lower(init(1))==['f','z'])
        error('You cannot estimate the InputLevel if the InitialState is ''Fixed'' or ''Zero''.')
    end
end
if any(strcmp(ulev.status,'fixed'))
    if any(lower(init(1))==['b','e'])
        error('You cannot Estimate or Backcast the InitialState if the InputLevel is ''Fixed'' (''Zero'' is OK).')
    end
end
par = pvget(m0,'ParameterVector');

if any(isinf(par))|any(isnan(par))
    ulev = pvget(m0,'InputLevel');
    if any(strcmp(ulev.status,'estimate'))
        zd = diff(z);
    else
        zd = z;
    end
    m = inival(zd,m0);
    par = pvget(m,'ParameterVector');
else
    m = m0;
end
if ~isempty(bounds)
    par(bounds(:,1)) = min(max(par(bounds(:,1)),bounds(:,2)),bounds(:,3));
    m = parset(m,par);
end
tsd = pvget(z,'Ts');tsd = tsd{1};
Td = pvget(m,'Td');
%if td ....
if Td.value/tsd>40
    warning(sprintf(['The initial guess of the time delay is more than 40 samples.',...
            '\nEither increase the sampling interval or shift the data.',...
            '\nTd has been adjusted to 40 samples.']))
    m= pvset(m,'Td',40*tsd);
end
it_inf = pvget(m,'EstimationInfo');
Ncaps = size(z,'N');
Nobs = sum(Ncaps);
it_inf.DataLength=Nobs;
it_inf.DataTs=tsd;
e = pe(z,m);
ey = pvget(e,'OutputData');
ee = cat(1,ey{:});
V1 = ee'*ee/length(ee);
it_inf.LossFcn = V1;
nparfpe = length(par) - length(pvget(m,'FixedParameter'));
it_inf.FPE = V1*(1+nparfpe/Nobs)/(1-nparfpe/Nobs);
it_inf.DataInterSample=pvget(z,'InterSample'); 
it_inf.Status='Estimated model (IDPROC/PEM)';
it_inf.DataName=pvget(z,'Name');
it_inf.Method = 'PEM';
it_inf.WhyStop = 'No Iterations demanded';
it_inf.Iterations = 0;
it_inf.InitialState = init;
m = pvset(m,'EstimationInfo',it_inf,'InputName',pvget(z,'InputName'),...
    'OutputName',pvget(z,'OutputName'),'InputUnit',pvget(z,'InputUnit'),...
    'OutputUnit',pvget(z,'OutputUnit'),'TimeUnit',pvget(z,'TimeUnit'));%'InitialState',init);
ll = m.idgrey;
dai = pvget(z,'InterSample');
fa = pvget(ll,'FileArgument');
fa{2} = dai;
ll=pvset(ll,'FileArgument',fa);
ll= pem(z,ll,'InputDelay',zeros(nu,1),'DisturbanceModel','Model'); % InputDelay =0
m.idgrey = ll;
Td = pvget(m,'Td'); Td = Td.value;
ll = pvset(ll,'InputDelay',Td,'Focus',foc,'noexit');
m.idgrey = ll;
ulev = pvget(m,'InputLevel');
if any(strcmp(ulev.status,'estimate'))
    uul = ulev.value;
    [a,b,c,d,k,x0,xnr,levnr] = procmod(ll.par,z.Ts,ll.file);
    if strcmp(lower(ll.es.InitialState(1)),'b')
        [e,xi] = pe(z,inpd2nk(c2d(ll,z.Ts)));
    else
        xi = ll.x0;
    end
    for ku = 1:length(uul)
        if levnr(ku)~=0
            uul(ku) = xi(levnr(ku));
        end
    end
    m = pvset(m,'InputLevel',uul);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = pemfocus(z,m0,foc) %stability not supported/not necessary

if ischar(foc)&strcmp(lower(foc),'simulation')
    foc = {1,1};
end
dist = pvget(m0,'DisturbanceModel');
zf = idfilt(z,foc,'causal');
m0 = pvset(m0,'DisturbanceModel','None','Focus','Prediction');
m = pem(zf,m0);
v = pe(z,m);
if dist{1}(1)=='A'
    ord = eval(dist{1}(5));
    dm = armax(v,[ord ord]);
    dm = d2c(dm);
    cp = pvget(dm,'c');
    if any(cp<0)
        cp = fstab(cp,0);
        dm = pvset(dm,'c',cp);
    end
else % fixed
    dm = dist{2};
end
covdm = pvget(dm,'CovarianceMatrix');
cov = pvget(m,'CovarianceMatrix');
if isempty(covdm)|ischar(covdm)|ischar(cov)|isempty(cov)
    covv=[];
else
covv = [[cov,zeros(size(cov,1),size(covdm,1))];[zeros(size(covdm,1),size(cov,1)),covdm]];
end
m = pvset(m,'DisturbanceModel',dm);
m = pvset(m,'CovarianceMatrix',covv,'NoiseVariance',pvget(dm,'NoiseVariance'));

