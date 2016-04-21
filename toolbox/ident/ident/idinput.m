function [u,freq] = idinput(N,type,band,levels,nosine)
%IDINPUT Generates input signals for identification.
%   U = IDINPUT(N,TYPE,BAND,LEVELS)
%
%   U: The generated input signal. A column vector or a N-by-nu matrix. 
%   N: The length of the input.
%   N = [N Nu] gives a N-by-Nu input (Nu input channels).
%   N = [P Nu M] gives a M*P-by-Nu input, periodic with period P 
%       and with M periods.
%   Default values are Nu = 1 and M =1 ;
%   TYPE: One of the following:
%         'RGS': Generates a Random, Gaussian Signal.
%         'RBS': Generates a Random, Binary Signal.
%         'PRBS': Generates a Pseudo-random, Binary Signal.
%         'SINE': Generates a sum-of-sinusoid signal.
%         Default: TYPE = 'RBS'.
%   BAND: A 1 by 2 row vector that defines the frequency band for the
%         input's frequency contents.
%         For the 'RS', 'RBS' and 'SINE' cases BAND = [LFR,HFR], where
%         LFR and HFR are the lower and upper limits of the passband,
%         expressed in fractions of the Nyquist frequency (thus always
%         numbers between 0 and 1).
%         For the 'PRBS' case BAND = [0,B], where B is such that the
%         signal is constant over intervals of length 1/B (the Clock Period). 
%         Default: BAND =[0 1].
%   LEVELS = [MI, MA]: A 2 by 1 row vector, defining the input levels.
%         For 'RBS', 'PRBS', and 'SINE', the levels are adjusted so
%         that the input signal always is between MI and MA.
%         For the 'RGS' case, MI is the signal's mean value minus one
%         standard deviation and MA is the signal's mean plus one standard
%         deviation.
%         Default LEVELS = [-1 1].
%
%   In the 'PRBS' case, if M > 1, the length of the data sequence and the 
%   period is adjusted so that always an integer number of maximum length PRBS
%   periods are obtained. If M = 1 the period is chosen so that it becomes
%   longer than P = N. In the multiinput case the signals are maximally shifted.
%   This means that P/Nu is an upper bound for the model orders that can be used
%   to identify systems excited by such a signal.
%
%   In the 'SINE' case, the sinusoids are chosen from the frequency grid
%   freq = 2*pi*[1:Grid_Skip:fix(P/2)]/P intersected with pi*[BAND(1) BAND(2)].
%   (for Grid_Skip see below.) For multi-input signals, the different inputs
%   use different frequencies from this grid. An integer number of
%   full periods is always delivered. The selected frequencies are obtained 
%   as [U,FREQS] = IDINPUT(....), where row ku of FREQS contains the 
%   the frequencies of input number ku. The resulting signal is affected by a
%   5th input argument SINEDATA:
%   U = IDINPUT(N,TYPE,BAND,LEVELS,SINEDATA)
%   where 
%   SINEDATA= [No_of_Sinusoids, No_of_Trials, Grid_Skip],
%   meaning that No_of_Sinusoids are equally spread over the indicated 
%   BAND, trying No_of_Trials different, random, relative phases, 
%   until the lowest amplitude signal is found. 
%   Default SINEDATA = [10,10,1];
%   See also IDMODEL/SIM.

%   L. Ljung 3-3-95
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.2.2 $  $Date: 2004/04/10 23:19:01 $
freq = [];
if nargin < 1
    disp('Usage: U =  IDINPUT(N); N = [Period, No_of_Inputs, No_of_Periods]')
    disp('       U =  IDINPUT(N,TYPE,BAND,LEVELS,NUMBERS);')
    disp('       with TYPE one of ''RGS'', ''RBS'', ''PRBS'', ''SINE''.')
    return
end
if nargin < 5
    nosine=[];
end
if nargin < 4
    levels = [];
end
if nargin < 3
    band = [];
end
if nargin < 2
    type =[];
end
if size(N,2)==3
    P = N(1); nu = N(2); M = N(3);
elseif size(N,2)==2
    P = N(1); nu =N(2); M = 1;
elseif size(N,2)==1
    nu = 1; P = N; M = 1;
else
    error('N must be a row vector with 1, 2, or 3 elements.')
end
if isempty(nosine),nosine=[10,10,1];end
nosine = nosine(:).';
if length(nosine)==1
    nosine = [nosine,10,1];
elseif length(nosine)==2
    nosine = [nosine,1];
end

if isempty(levels),levels=[-1,1];end
if isempty(band),band=[0 1];end
if isempty(type),type='rbs';end
if band(2)<band(1)&~strcmp(lower(type),'prbs')
    error('The first component of BAND must be less than the second one.')
end
if levels(2)<levels(1)
    error('The first component of LEVELS must be less than the second one.')
end
if nosine(1)<1|nosine(2)<1
    error('The number of sinusoids and the number of trials must be larger than 1.')
end
if ~isstr(type)
    error('The argument TYPE must be one of ''rgs'', ''rbs'', ''prbs'' or ''sine''.')
end
if strcmp(lower(type),'rs')|strcmp(lower(type),'rgs')
    u=randn(5*P,nu);
    if ~all(band==[0 1])
        u = idfilt(u,8,band);
    end
    u = u(2*P+1:end-2*P,:); % to take out transients
    %u = u - ones(P,1)*mean(u)+(levels(2)+levels(1))/2;
    for ku = 1:nu
        u(:,ku) = u(:,ku)-mean(u(:,ku));%Now it is zero mean.
        % The standdard deviation shall be (lev(2)-lev(1))/2
        % and the mean shall be (lev(2)+lev(1))/2
        u(:,ku)=(levels(2)+levels(1))/2 + u(:,ku)*(levels(2)-levels(1))/2/...
            sqrt(u(:,ku)'*u(:,ku)/length(u(:,ku)));
        %u(:,ku) = u(:,ku)/norm(u(:,ku))*sqrt(P)*(levels(2)-levels(1))/2;
    end
    
elseif strcmp(lower(type),'rbs')
    u=randn(5*P,nu);
    if ~all(band==[0 1]),u = idfilt(u,8,band);end
    u = sign(u(2*P+1:end-2*P,:)); % to take out transients
    u = (levels(2)-levels(1))*(u+1)/2+levels(1);
    
elseif strcmp(lower(type),'prbs')
  
    clockP = floor(1/band(2));
    possP = 2.^[3:18]-1;autoP = 0;
    P1 = max(possP(find(P/clockP-possP>=0)));
    if isempty(P1)
        P1 = 7;
    end
    n = find(P1==possP)+2;
    
    if (clockP*P1~=P)
        if M>1
            disp(sprintf('The period of the PRBS signal has been changed to %d.',clockP*P1))
            disp(sprintf('Accordingly, the length of the input will be %d.',P1*M*clockP))
            P = P1*clockP;
        else
            n = min(n+1,18);
            P1 = 2^n -1;
            disp(sprintf('The PRBS signal delivered is the %d first values of a full sequence of length %d.',P,clockP*P1))
        end
    end
    
    P1 = 2^n-1;
    
    if n<3|n>18,
        error('The period of the PRBS sequence, must be between 7 and 262143.')
        return
    end
    fi=-ones(n,1);
    if n==3
        ind=[1,3];
    elseif n==4
        ind=[1,4];
    elseif n==5
        ind=[2,5];
    elseif n==6
        ind=[1,6];
    elseif n==7
        ind=[1,7];
    elseif n==8
        ind=[1,2,7,8];
    elseif n==9
        ind=[4,9];
    elseif n==10
        ind=[3,10];
    elseif n==11
        ind=[9,11];
    elseif n==12
        ind=[6,8,11,12];
    elseif n==13
        ind=[9,10,12,13];
    elseif n==14
        ind=[4,8,13,14];
    elseif n==15
        ind=[14,15];
    elseif n==16
        ind=[4,13,15,16];
    elseif n==17
        ind=[14,17];
    elseif n==18
        ind=[11,18];
    end
    for t=1:clockP:P1*clockP
        u(t:t+clockP-1,1)=ones(clockP,1)*fi(n); %%LL%% multivariable !!
        fi=[prod(fi(ind));fi(1:n-1,1)];
    end
    u=(levels(2)-levels(1))*(u+1)/2+levels(1);
    
    u = u(1:P,1);
    if nu >1
        u1 = [u;u];
        shift = floor(P/nu);
        for ku = 2:nu
            u = [u,u1(shift*(ku-1)+1:P+shift*(ku-1))];
        end
    end
    
elseif strcmp(lower(type),'sine')
    odd = nosine(3);
    possfreq = 2*pi*[1:odd:fix(P/2)]/P;
    possfreq = possfreq(find(possfreq>band(1)*pi));
    possfreq = possfreq(find(possfreq<band(2)*pi));
    nl = length(possfreq);
    if nl<nu*nosine(1)
        error(sprintf(['   The indicated band cannot be covered by %d sinusoids',...
                ' over the DFT frequency grid. \n   Either increase the period or the band, or ',...
                'decrease the number of sinusoids.'],nosine(1)))
    end
    fnr = choose(nl,nu*nosine(1));
    numtrial=nosine(2);
    for ku = 1:nu
        freqs = possfreq(fnr(ku:nu:end)); 
        freq(ku,:) = freqs;
        for kn=1:numtrial
            ut=zeros(P,1);
            for ks=1:nosine(1)
                ut=ut+cos([0:P-1]'*freqs(ks)+rand(1,1)*2*pi);
            end
            mm=max(ut);mn=min(ut);
            if kn==1,u1=ut;bestamp=mm-mn;end
            if mm-mn<bestamp,u1=ut;bestamp=mm-mn;end
        end
        mn=min(u1);mm=max(u1);mm=max(mm,-mn);mn=-mm;
        u(:,ku)=(levels(2)-levels(1))*(u1-mn)/(mm-mn)+levels(1);
    end
else
    error('The argument TYPE must be one of ''rgs'', ''rbs'', ''prbs'' or ''sine''.')
end
if M>1
    uu = u;
    for km = 2:M
        u = [uu;u];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fnr = choose(nr,nl)
%Choose nl values from integers 1:nr as evenly spread as possible
nnr = [1:nr];
s = 1;
fnr = zeros(1,nl);
while nl>0
    nr = length(nnr);
    if nl == 3
        fnr(s) = nnr(1);
        fnr(s+1)= nnr(ceil(nr/2));
        fnr(s+2) = nnr(end);
        nl = 0;
    elseif nl>1
        k = floor(nr/(nl-1));
        fnr(s)=nnr(1);
        fnr(s+1)=nnr(end);
        s=s+2;
        nnr=nnr(k+1:end-k);
        nl = nl-2;
    else
        k=ceil(nr/2);
        fnr(s) = nnr(k);
        s=s+1;
        nl = nl -1;
    end
end
fnr = sort(fnr);
%&&&&&&&&&&&&
%  u = iddata([],u);
%  if M>1
%      set(u,'Period',P*ones(nu,1))
%  end
%  
