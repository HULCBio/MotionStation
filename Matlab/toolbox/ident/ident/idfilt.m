function [data,thf]=idfilt(data,n,varargin)
%IDFILT Filters data.
%   ZF = IDFILT(Z,FILTER)
%
%   Z : The output-input data as a matrix or an IDDATA object. 
%   ZF: The filtered data.  If Z is IDDATA, so is ZF. Otherwise the
%       columns of ZF correspond to those of Z.
%   FILTER: The filter can be defined in two ways, either as pass-band(s)
%       or as filter coefficients.
%       1) PASS BANDS: FILTER is a p-by-2 matrix where each row defines a
%          pass band expressed in RAD/S. A stop band between W1 and W2 is
%          thus expressed as FILTER = [0 W1;W2 NF], where NF is the Nyquist
%          frequency.
%       2) FILTER COEFFICIENTS: FILTER is either an IDMODEL or an LTI
%          object, or a cell array {A,B,C,D} (state-space matrices) or
%          {num,den} (numerator and denominator). In the cell array case
%          the sampling interval is assumed to be the same as that of the
%          data (continuous time filter if the data is continuous time.)
%          If FILTER is given as a discrete time object, its sampling interval
%          is supposed to be the same as the data. If it is continuous
%          time, it is sampled to the (possibly different) sampling
%          intervals of the data.
%          (If Z is given as a matrix, the sampling interval is assumed to
%          be 1.)
%       If Z is an IDDATA Frequency Domain object FILTER can also be defined as
%       3) FILTER = W, where W is a column vector of length Z.Frequency, meaning
%          that the input and output at frequency Z.Frequency(kw) are
%          multiplied by W(kw). For multiexperiment data W is a cell array
%          of length = # of experiments.
%
%   For time domain data the filtering is carried out in the time domain as a
%   CAUSAL filter. This can be changed to NONCAUSAL (zero-phase shift)
%   filtering by adding a last argument 'CAUSAL'/'NONCAUSAL' to the input
%   arguments: ZF = IDFILT(Z,...,'Noncausal').
%   For frequency domain data, the filtering is done by multiplication in
%   the frequency domain. The pass bands will then be implemented by
%   perfect "brickwall filters".
%
%   The time domain filters in the pass band case are calculated as
%   cascaded Butterworth pass band and stop band filters. The orders of
%   these filters are 5 by default, which can be changed to an arbitrary
%   interger  NA by inlcuding the property/value pair
%   ...,'FilterOrder',NA,... after the first two arguments in the input argument lisr.
% 
%   See also FOCUS, IDDATA/DETREND and IDATA/RESAMPLE.

%   L. Ljung 10-1-89, 23-6-03.
%   The Butterworth and filtering code is adopted from several routines in the
%   Signal Processing Toolbox.
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.24 $  $Date: 2003/11/11 15:52:24 $

%% Add filter order

if nargin<2
    disp('Usage: zf = IDFILT(DATA,[Wp1 Wp2;Wp3 Wp4;...]);')
    disp('       zf = IDFILT(DATA,FILTER);')
    disp('       FILTER is an LTI or IDMODEL object.')
    if nargout, data=[];thf=[];end
    return
end
tfiltmat={};
cfilter  = []; %continuous time filter
nbwf = 5;
for kv = 1:length(varargin)
    if ischar(varargin{kv})&~isempty(findstr(lower(varargin{kv}),'filterorder'))
        if length(varargin)<kv+1
            error('FilterOrder must be followed by an integer.')
        end
        nbwf = varargin{kv+1};
        if nbwf<=0|floor(nbwf)~=nbwf
            error('The  filter order must be a positive integer.')
        end
        varargin([kv,kv+1])=[];
        break
    end
end
if isa(data,'frd'),data = idfrd(data);end
if isa(data,'idfrd'),data=iddata(data);end
if isa(data,'iddata')
    dom = pvget(data,'Domain');
else
    dom = 'Time';
end
dom = lower(dom(1));
causal = 1;
if length(varargin)>0
    caus = varargin{end};
    if ischar(caus)&length(caus)>2
        if strcmp(lower(caus(1:3)),'non')
            causal = 0;
            %  nargin = nargin -1;lengt
            varargin = varargin(1:end-1);
        elseif strcmp(lower(caus(1:3)),'cau')
            % nargin = nargin -1;
            varargin = varargin(1:end-1);
        end
    end
end
Weights = [];
if isa(n,'lti')|isa(n,'idmodel')|iscell(n) % Directly defined TD model
    if iscell(n)% this could be either abcd, numden or a cell of weights
        if dom=='f'
            Ne = size(data,'Ne');
        else
            Ne = 1;
        end
        if length(n)==4
            a=n{1};b=n{2};c=n{3};d=n{4};
            if Ne==4 % then there is a possible ambiguity
                [ra,ca]=size(a);
                if min(ra,ca)==1%&ra=~1 % then a is a vector, likely to be a weight vector
                    Weights = n;
                end
            end
        elseif length(n)==2
            num = n{1}; den = n{2};
            if Ne==2 % then there is a possible ambiguity
                if size(num,2)==1&size(den,2)==1 % likely to be a weight vector
                    Weights = n;
                end
            end
            if isempty(Weights)
                % The below only for Ts>0
                den = [den,zeros(1,length(num)-length(den))];
                [a,b,c,d]=tf2ss(num,den);
            end
        elseif length(n)==Ne
            Weights = n;
        else
            error(sprintf(['If FILTER is a cell array it should either be of',...
                    ' length 2 ({Numerator,Denominator})\nor of length 4',...
                    ' ({A,B,C,D})\nor of length = Number of Experiments in Z',...
                    ' (Weight vectors)']))
        end
    else      %idmodel/lti
        [a,b,c,d] = ssdata(n);
       
        if ~isempty(a)
            b=b(:,1); c=c(1,:);
        end
        d=d(1,1); % to make it SISO
         if pvget(n,'Ts')==0
            cfilter = idss(a,b,c,d,zeros(size(c')),'Ts',0);
        end
    end
    
elseif isa(n,'double')
    if length(n)>1 % Then it is [Wl Wh] or Weights
        %         if dom~='f'
        %             
        %             error(sprintf(['Direct definition of pass band or weights is possible',...
        %                     '\nonly for frequency domain data. \nDo FFT(Z) first.']))
        %         end
        if size(n,2)==2% [Wl Wh]
            % check consistency of definition:
            chkpb(n);
            if dom=='f'
                fre = pvget(data,'SamplingInstants');
                for kexp = 1:length(fre)
                    Weights{kexp} = zeros(size(fre{kexp}));
                    freno = [];%find(fre{kexp}>=n(1,1)&fre{kexp}<=n(2,1));
                    for kp = 1:size(n,1);
                        freno = [freno;find(fre{kexp}>=n(kp,1)&fre{kexp}<=n(kp,2))];
                        Weights{kexp}(freno) = ones(size(freno));
                    end
                end
            else %time domain: Build corresnponding filters using butter
                % Complication: Possibly different sampling intervals
                if isa(data,'iddata')
                    Ts = pvget(data,'Ts');
                else
                    Ts = {1};
                end
                [pbnd,stpbnds] = trfpband(n); % convert to overall pass-band + stopbands
               % tfiltmat = cell(size(n,1),length(Ts));
                [mxf,mxfnr] = max(n(:,2));
                for kp = 1:size(stpbnds,1)+1
                    for kexp = 1:length(Ts)
                        if kp==1
                            hs = [];
                            wn = pbnd;
                        else
                            hs = 'stop';
                            wn = stpbnds(kp-1,:);
                        end
                       %% Warning if above the Nyquist frequency?
                      if any(wn*Ts{kexp}/pi>1)
                          warning('Some specified frequency higher than the Nyquist frequency.')
                      end
                        [a,b,c,d] = butter(nbwf,wn*Ts{kexp}/pi,hs);
                        tfiltmat(kp,kexp)= {{a,b,c,d}};
                    end
                end
            end
        else
            if dom~='f'
                error(sprintf(['Direct definition of frequency weights is possible',...
                        '\nonly for frequency domain data. \nDo FFT(Z) first.']))
            end
            Weights = {n};
        end
    else % n is an integer
        if length(varargin)<1
            disp('Usage: zf = IDFILT(DATA,ORDER,BAND);')
            disp('       zf = IDFILT(DATA,ORDER,BAND,''HIGH'');')
            disp('       with ORDER = an integer.')
            return
        end
        if n<0,
            n=abs(n);
            warning('The causality of the filter is determined by the last argument ''causal''/''noncausal''.')
        end
        nbwf = n;
        hs =[];
        Wn = varargin{1};
        if length(varargin)>1
            hs = 'high';
        end
        
        if length(Wn)>1,
            if Wn(1)>=Wn(2)
                error('The band is ill-defined. Should be Wn = [a b] with a < b.')
            end
            if abs(Wn(1))<eps
                Wn=Wn(2);
            elseif abs(Wn(2)-1)<eps,
                Wn=Wn(1);
                if isempty(hs),hs='high';else hs=[];end
            end
        end
        ndat = size(data,1);
        if any(ndat<3*abs(n))
            error('The data record length must be at least three times the filter order')
        end
        [a,b,c,d] = butter(nbwf,Wn,hs);
    end
end
if isempty(Weights)
    if isempty(cfilter)
    thf=idss(a,b,c,d);
else
    thf = cfilter;
end
else
    thf = [];
end
if dom=='f'&isempty(Weights)
    data = nyqcut(data);
    fre = pvget(data,'SamplingInstants');
    ts = pvget(data,'Ts');
    for kexp = 1:length(fre)
        if ts{kexp}>0&pvget(thf,'Ts')==0
            thf1 = c2d(thf,ts{kexp});
        else
        thf1 = pvset(thf,'Ts',ts{kexp});
    end
        %else
        %thf1 = d2c(thf);
        %end
        %             if ts{kexp}>0&any(fre{kexp}>pi/ts{kexp}+1e4*eps)
        %                 if isa(data,'iddata')
        
        fresp = freqresp(thf1,fre{kexp}); %%LL problem with Ts (thf.Ts =1)
        Weights{kexp} = squeeze(fresp(1,1,:));
    end
end
if isa(data,'iddata')
    y = pvget(data,'OutputData'); 
    u = pvget(data,'InputData');
    [N,ny,nu] = size(data);
    for kexp = 1:length(y)
        zc{kexp} = [y{kexp},u{kexp}];
    end
elseif ~iscell(data)
    zc = {data};
else
    zc = data;
end
nyu = size(zc{1},2);

% Now do the filtering    
if dom=='t'&isempty(tfiltmat)
    if isa(data,'iddata')&~isempty(cfilter)
        Tsdat = pvget(data,'Ts');
        for kexp = 1:length(Tsdat)
            if Tsdat{kexp}==0
                [a,b,c,d] = ssdata(cfilter);
            else
                [a,b,c,d] = ssdata(c2d(cfilter,Tsdat{kexp}));
            end
            tfiltmat{1,kexp}={a,b,c,d};
        end
    else
        tfiltmat = repmat({{a,b,c,d}},1,length(zc));
    end
end
for kexp = 1:length(zc)
    z = zc{kexp};
    if dom=='f'
        if length(zc)~=length(Weights)
            error(sprintf(['When specifying FILTER as weights, it must be a cell array of'...
                    '\n length = number of Experiments.']))
        end
        for k = 1:nyu
            if size(z(:,k),1)~=size(Weights{kexp},1)
                error(sprintf(['When specifying FILTER as a column vector of weights, the number of elements'...
                        '\n must be equal to the length of the data vector.']))
            end
            if size(Weights{kexp},2)~=1
                error(sprintf(['When specifying FILTER as a vector of weights,'...
                        '\nit must be a column vector (or cell array of column vectors).']))
            end
            zf(:,k) = z(:,k).*Weights{kexp};
        end
    else
        zf = z;
        for kf = 1:size(tfiltmat,1)
            abcd = tfiltmat{kf,kexp};
         zf = tfilt(abcd{1},abcd{2},abcd{3},abcd{4},zf,causal);
    end
end
    zfc{kexp} = zf;
    if isa(data,'iddata')
        yf{kexp} = zf(:,1:ny);
        uf{kexp} = zf(:,ny+1:nyu);
    end
    clear zf
end
if isa(data,'iddata')
    data = pvset(data,'OutputData',yf,'InputData',uf);
elseif iscell(data)
    data = zfc;
else
    data = zfc{1};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  chkpb(n)
np = size(n,1);
for kp = 1:np
    if n(kp,1)>n(kp,2)
        error(sprintf(['In row number %d, the first element is larger than the',...
                ' second one in the filter definition.',...
                '\nEach passband must be well defined.']))
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b,c,d] = butter(n,Wn,hs);
if length(Wn)>1,
    if Wn(1)>=Wn(2)
        error('The band is ill-defined. Should be Wn = [a b] with a < b.')
    end
    if Wn(1)<0,Wn(1)=0;end
    if Wn(2)>1;Wn(2)=1;end
    if abs(Wn(1))<1e4*eps
        Wn=Wn(2);
    elseif abs(Wn(2)-1)<1e4*eps,
        Wn=Wn(1);
        if isempty(hs),hs='high';else hs=[];end
    end
end
btype = 1;
if ~isempty(hs),btype=3;end

if length(Wn) == 2
    btype = btype + 1;
end

% step 1: get analog, pre-warped frequencies
fs = 2;
u = 2*fs*tan(pi*Wn/fs);

% step 2: convert to low-pass prototype estimate
if btype == 1   % lowpass
    Wn = u;
elseif btype == 2       % bandpass
    Bw = u(2) - u(1);
    Wn = sqrt(u(1)*u(2));   % center frequency
elseif btype == 3       % highpass
    Wn = u;
elseif btype == 4       % bandstop
    Bw = u(2) - u(1);
    Wn = sqrt(u(1)*u(2));   % center frequency
end

% step 3: Get N-th order Butterworth analog lowpass prototype
p = exp(sqrt(-1)*(pi*(1:2:2*n-1)/(2*n) + pi/2)).';
k = real(prod(-p));

% Transform to state-space
% Strip infinities and throw away.
p = p(finite(p));

% Group into complex pairs
np = length(p);
nz= 0;%= length(z);
p = cplxpair(p,1e6*np*norm(p)*eps + eps);

% Initialize state-space matrices for running series
a=[]; b=[]; c=zeros(1,0); d=1;

% If odd number of poles only, convert the pole at the
% end into state-space.
%  H(s) = 1/(s-p1) = 1/(s + den(2))
if rem(np,2)
    a = p(np);
    b = 1;
    c = 1;
    d = 0;
    np = np - 1;
end

% Now we have an even number of poles and zeros, although not
% necessarily the same number - there may be more poles%.
%   H(s) = (s^2+num(2)s+num(3))/(s^2+den(2)s+den(3))
% Loop thru rest of pairs, connecting in series to build the model.
i = 1;

% Take care of any left over unmatched pole pairs.
%   H(s) = 1/(s^2+den(2)s+den(3))
while i < np
    den = real(poly(p(i:i+1)));
    wns = sqrt(prod(abs(p(i:i+1))));
    if wns == 0, wns = 1; end
    t = diag([1 1/wns]);    % Balancing transformation
    a1 = t\[-den(2) -den(3); 1 0]*t;
    b1 = t\[1; 0];
    c1 = [0 1]*t;
    d1 = 0;
    %       [a,b,c,d] = series(a,b,c,d,a1,b1,c1,d1);
    % Next lines perform series connection
    [ma1,na1] = size(a);
    [ma2,na2] = size(a1);
    a = [a zeros(ma1,na2); b1*c a1];
    b = [b; b1*d];
    c = [d1*c c1];
    d = d1*d;
    
    i = i + 2;
end
% Apply gain k:
c = c*k;
d = d*k;
% step 4: Transform to lowpass, bandpass, highpass, or bandstop of desired Wn
wo = Wn;
if btype == 1           % Lowpass
    at = wo*a;
    bt = wo*b;
    ct = c;
    dt = d;
    
elseif btype == 2       % Bandpass
    [ma,nb] = size(b);
    [mc,ma] = size(c);
    
    % Transform lowpass to bandpass
    q = wo/Bw;
    at = wo*[a/q eye(ma); -eye(ma) zeros(ma)];
    bt = wo*[b/q; zeros(ma,nb)];
    ct = [c zeros(mc,ma)];
    dt = d;
    
elseif btype == 3       % Highpass
    
    at =  wo*inv(a);
    bt = -wo*(a\b);
    ct = c/a;
    dt = d - c/a*b;
    
elseif btype == 4       % Bandstop
    [ma,nb] = size(b);
    [mc,ma] = size(c);
    
    % Transform lowpass to bandstop
    q = wo/Bw;
    at =  [wo/q*inv(a) wo*eye(ma); -wo*eye(ma) zeros(ma)];
    bt = -[wo/q*(a\b); zeros(ma,nb)];
    ct = [c/a zeros(mc,ma)];
    dt = d - c/a*b;
    
end
a=at;b=bt;c=ct;d=dt;
% step 5: Use Bilinear transformation to find discrete equivalent:

t = 1/fs;
r = sqrt(t);
t1 = eye(size(a)) + a*t/2;
t2 = eye(size(a)) - a*t/2;
ad = t2\t1;
bd = t/r*(t2\b);
cd = r*c/t2;
dd = c/t2*b*t/2 + d;
a = ad;b = bd; c = cd; d = dd;
den = poly(a);
num = poly(a-b*c)+(d-1)*den;
%end % End of filter calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zf = tfilt(a,b,c,d,z,causal)
nyu = size(z,2);
if causal
    for k=1:nyu
        if ~isempty(a)
            x=ltitr(a,b,z(:,k));
            zf(:,k)=x*c'+d*z(:,k);
        else 
            zf(:,k) = d*z(:,k);
        end
    end
else
    den = poly(a);
    num = poly(a-b*c)+(d-1)*den;
    for k = 1:nyu
        x=z(:,k);
        len = size(x,1);   % length of input
        b = num(:).';
        a = den(:).';
        nb = length(b);
        na = length(a);
        nfilt = max(nb,na);
        
        nfact = 3*(nfilt-1);  % length of edge transients
        
        if nb < nfilt, b(nfilt)=0; end   % zero-pad if necessary
        if na < nfilt, a(nfilt)=0; end
        zi = ( eye(nfilt-1) - [-a(2:nfilt).' ...
                [eye(nfilt-2); zeros(1,nfilt-2)]] ) \ ...
            ( b(2:nfilt).' - a(2:nfilt).'*b(1) );
        
        y = [2*x(1)-x((nfact+1):-1:2);x;...
                2*x(len)-x((len-1):-1:len-nfact)];
        
        % filter, reverse data, filter again, and reverse data again
        y = filter(b,a,y,[zi*y(1)]);
        y = y(length(y):-1:1);
        y = filter(b,a,y,[zi*y(1)]);
        y = y(length(y):-1:1);
        
        % remove extrapolated pieces of y
        y([1:nfact len+nfact+(1:nfact)]) = [];
        zf(:,k)=y;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pbnd,stpbnds] = trfpband(wn)
% transforms the list of passbands to one
% passband and possibly several stopbands
stpbnds = [];
if size(wn,1) == 1
    pbnd = wn;
    return 
end
wn = sort(wn,1);
[minfr,minfrnr] = min(wn(:,1));
[maxfr,maxfrnr] = max(wn(:,2));
pbnd = [minfr,maxfr];
stnr = 1;
for kp = 2:size(wn,1)
    whmax = max(wn(1:kp-1,2));
    if wn(kp,1)>whmax;
        stpbnds(stnr,1:2) = [whmax wn(kp,1)];
        stnr = stnr + 1;
    end
end

