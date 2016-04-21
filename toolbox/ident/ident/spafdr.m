function g = spafdr(data,res,w)
%SPAFDR   Computes Spectral Analysis Estimates with Frequency Dependent Resolution.
%   G = SPAFDR(DATA)   or   G = SPAFDR(DATA,RES,FREQS)
%
%   DATA is an IDDATA object and contains the input-output data or a time series. 
%   See HELP IDDATA.  
%   G: Returned frequency response and uncertainty as an IDFRD object.
%   G also contains the spectrum of the additive noise v in the
%   model y = G u + v. See help IDFRD.
%
%   If DATA is a time series, G is returned as the estimated
%   spectrum, along with its estimated uncertainty.
%
%   The resolution of the resulting estimate is determined by the input argument
%   RES, which gives the frequency resolution in rad/s. This is a way to control
%   the bias/variance trade-off in the estimate: A small value gives small variance,
%   at the risk of large bias. Setting RES to 'max' gives maximum resolution, i.e.
%   no smoothing over frequencies takes place.
% 
%   The functions are computed at the frequencies in the vector FREQS.
%   If FREQS ={WMIN,WMAX} (note the curly brackets), the frequency interval between
%   WMIN and WMAX will be covered with logarithmically spaced points. 
%   With FREQS = {WMIN,WMAX,NP} this is done using NP points. 
%   The unit of FREQS is rad/s. 
%
%   The frequency resolution can be frequency dependent. Then choose RES as a vector
%   of the same size as FREQS, so RES(k) gives the resolution around FREQS(k).
%
%   The default value of FREQS are 100 logarithmically spaced points from the
%   smallest to the largest frequency in DATA. If DATA is time domain this means
%   1/N*Ts to pi/Ts, where Ts is the sampling interval and N is the number of data.
%
%   The default value of RES (also obtained by letting RES =[]) is 
%   RES(k) = 2(FREQS(k+1) - FREQS(k)), adjusted upwards so that a
%   reasonable estimate is guaranteed. The actual value of RES is given in
%   G.EstimationInfo.WindowSize.


%   See also IDFRD, BODE, NYQUIST, FFPLOT, ETFE and SPA.

%   L. Ljung  
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/10 23:19:18 $

if nargin < 1
    disp('Usage: G = SPAFDR(Z)')
    disp('       G = SPAFDR(Z,FREQ_RESOL,FREQS)')
    return
end


if nargin<3
    w = [];
end
if nargin<2,
    res=[];
end
if isa(data,'frd'),data = idfrd(data);end
if isa(data,'idfrd'),
    data = iddata(data);
end
if ~isa(data,'iddata')
    error('The first argument should be an IDDATA object.'),
end
nam = pvget(data,'Name');
if isempty(nam)
    nam = inputname(1);
end
[Ncaps,ny,nu]=size(data);
   if ny==0
      data = pvset(data,'InputData',[],'OutputData',pvget(data,'InputData'),...
		   'OutputName',pvget(data,'InputName'),'OutputUnit',...
		   pvget(data,'InputUnit'));
      ny = nu; nu = 0;
   end
ts = pvget(data,'Ts');
ts = ts{1};%%LL there is a a problem with discrete  time data with
%different sampling intervals perhaps
domes = pvget(data,'Domain');
dom = lower(domes);
if strcmp(dom,'time')
    
    data = fft(data);
    timeflag = 1;
    %fmint = 1/ts/Ncap;
    %%LL actual length/frequencies could be taylored to w
end

[N,ny,nu,nexp] = size(data);
if nexp>1
    dat = getexp(data,1);
    for kexp = 2:nexp
        dat = [dat;getexp(data,kexp)];
    end
    N = sum(N);
else
    dat = data;
end
freqsc = pvget(dat,'Radfreqs');
freqs = freqsc{1};
fmin = min(freqs);fmax = max(freqs);

y = pvget(dat,'OutputData');
y = y{1};
u = pvget(dat,'InputData');
u = u{1};

if ((length(freqs)==length(w))&sort(freqs(:))==sort(w(:)))&...
        (isempty(res)|ischar(res)|res==0)
    % This is the ETFE case
    g = spa_etfe(w,y,u,ts);
    g = idmname(g,dat);
    est = pvget(g,'EstimationInfo');
    est.Status='Estimated model';
    est.Method= 'SPAFDR';
    est.DataLength = N;
    est.DataTs = get(dat,'Ts');
    est.DataInterSample = pvget(dat,'InterSample');
    est.DataDomain = domes;
    est.DataName = nam;
    est.WindowSize = 'Max Resolution';
    g = pvset(g,'EstimationInfo',est);
    return
end

% if nu==0
%     spe = abs(y).^2;
%     resp = [];
% end
if iscell(w)
    if size(w)<2
        error('When frequencies are defined by a range, if must be FREQS={Wmin,Wmax}.')
    end
    if size(w)==2
        NP = 50;
    else
        NP = w{3};
    end
    w = logspace(log10(w{1}),log10(w{2}),NP);
end
if isempty(w)
    if fmin<0
        negflag = 1;
    else
        negflag = 0;
    end
    if fmin<=0
        fmin = min(freqs(find(freqs>0)));
    end
    %c = 0.14/ts/sqrt(fmin*fmax);%%LL 0.14 is tuning variable
    %NP = log10(fmax/fmin)/log10(c);%min(100,N/5);
    NP=ceil(min(N/5,100));
if isempty(fmin)|NP<2
    w = fmax;
else
    w = logspace(log10(fmin),log10(fmax),NP);
end
    if negflag
        w=[-w(end:-1:1),w];
    end
end
if length(w)==1&floor(w)==w&w>1 % then it is "number of points"
    w = [fmin:((fmax-fmin)/(w-1)):fmax]';
end

reses = res;
if ischar(res) %'max' but not etfe case
    res = 0;
end

if isempty(res)
    if length(w)>1
    res = 2*[w(2)-w(1), diff(w(:))'];  
    if length(diff(freqs))>1
    res = max(res,nu*5*max(diff(freqs)));
else
    res = 1;
end
    reses = res;
else
    res = 1;
end
end
if length(res)==1
    reses = res;
    res = ones(size(w))*res;
end
if length(res)~=length(w)
    error(sprintf(['If the RESOLUTION argument is given as a vector, ',...
            'it must have the same length\nas the vector of FREQUENCIES.']))
end
y = [y(end:-1:1,:);y;y(end:-1:1,:)];
u = [u(end:-1:1,:);u;u(end:-1:1,:)];
freqs=[-freqs(end:-1:1);freqs];
spe = zeros(ny,ny,length(w));
respsmooth = zeros(ny,nu,length(w));
cov = zeros(ny,nu,length(w),2,2);
nois = zeros(ny,ny,length(w));
miss = 0;
for k = 1:length(w)
    d = abs(w(k)-freqs);
    ind = find(d<res(k)/2);
    if isempty(ind)
        [dum,ind] = min(abs(d));
    end
    if res(k)==0,res(k)=1;end
    weight = cos((w(k)-freqs(ind))/res(k)*pi);
    weight = weight/sum(weight);
    %sum(weight);
    for ku = 1:nu
        for ky = 1:ny
            ryu(ky,ku)=(y(ind,ky).*conj(u(ind,ku))).'*weight;
        end
        for ku2 = 1:nu
            ruu(ku,ku2)=(u(ind,ku).*conj(u(ind,ku2))).'*weight;
            ruuw(ku,ku2)=(u(ind,ku).*conj(u(ind,ku2))).'*(weight.^2);
        end
    end
    for ky1=1:ny
        for ky2=1:ny
            ryy(ky1,ky2) = ((y(ind,ky1).*conj(y(ind,ky2))).'*weight);
        end
    end
    if nu>0
        if rank(ruu)==nu
            ruin = inv(ruu);
        else  
            miss = 1;
            ruin = inv(diag(diag(ruu)));
        end
        gg = ryu*ruin;
        nrm = 1 - trace(ruuw*ruin);%%normalization to take no of obs into account
        if nrm >10*eps
            fi = (ryy-ryu*gg')/nrm; 
            fi = (fi+fi')/2; 
        else
            fi = NaN*ones(ny,ny);
        end
    else 
        fi = ryy; fi = (fi+fi')/2;
        gg = [];
    end
    for ky=1:ny
        if ~isnan(fi(ky,ky))
            fi(ky,ky)=max(fi(ky,ky),0);
        end
    end
    if nu>0
        respsmooth(:,:,k)=gg;
        pm = ruin*ruuw*ruin;
        for ky=1:ny
            for ku = 1:nu
                cov(ky,ku,k,1,1) = fi(ky,ky)*real(pm(ku,ku)); 
                cov(ky,ku,k,2,2) = cov(ky,ku,k,1,1);
            end
        end
    end
    spe(:,:,k)=fi;
    nois(:,:,k)=2*fi.^2*sum(weight.^2)*ts^2;
end
freqs = w;
resp = respsmooth;
if any(isnan(spe))
    warning(sprintf(['The resolution is so small that the noise spectrum'...
            ' and uncertainties could not\n be estimated at certain frequencies.']))
end
if miss
    warning(sprintf(['The resolution is so small that the frequency response'...
            ' could not\n be reliably estimated at certain frequencies.']))
end
ts = pvget(dat,'Ts');
ts = ts{1};
g = idfrd(resp,freqs,ts,'SpectrumData',spe*ts,'CovarianceData',cov,...
    'NoiseCovariance',nois);
est = pvget(g,'EstimationInfo');
est.Status='Estimated model';
est.Method= 'SPAFDR';
est.DataLength = N;
est.DataDomain = domes;
est.DataName = nam;
est.WindowSize = reses;
est.DataTs = get(dat,'Ts');
est.DataInterSample = pvget(dat,'InterSample');
g = pvset(g,'EstimationInfo',est,...
    'InputName',pvget(data,'InputName'),'OutputName',pvget(dat,'OutputName'),...
    'InputUnit',pvget(data,'InputUnit'),'OutputUnit',pvget(dat,'OutputUnit'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = spa_etfe(w,y,u,Ts);
[N,ny] = size(y); nu = size(u,2);
if nu == 0
    resp = [];
    spe=zeros(ny,ny,N);
    for ky1 = 1:ny
        for ky2 = 1:ny
            spe(ky1,ky2,:)=y(:,ky1).*conj(y(:,ky2))*Ts;
        end
    end
else
    spe = [];
    resp = zeros(ny,nu,N);
    for ky=1:ny
        for ku=1:nu
            zer = find(abs(u(:,ku))==0);
            u(zer,ku) = ones(length(zer),1); 
            resp(ky,ku,:) =  y(:,ky)./u(:,ku);
            resp(ky,ku,zer)=inf*ones(length(zer),1);  
        end
    end
end
g = idfrd(resp,w,Ts,'SpectrumData',spe);

