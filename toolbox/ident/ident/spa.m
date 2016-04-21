function [GH,PV,ZSP] = spa(data,M,W,maxsize,T,inhib)
%SPA    Performs spectral analysis.
%   G = SPA(DATA)  
%
%   DATA: The output-input data as an IDDATA object. (see help IDDATA)
%   G: Returned frequency response and uncertainty as an IDFRD object.
%      See IDPROPS IDFRD for a description of this object.
%   G also contains the spectrum of the additive noise v in the
%   model y = G u + v. See IDPROPS IDFRD.
%
%   If DATA is a time series G is returned as the estimated
%   spectrum, along with its estimated uncertainty.
%
%   The spectra are computed using a Hamming window of lag size 
%   min(length(DATA)/10,30), which can be changed to M by
%   G = SPA(DATA,M)   
% 
%   The functions are computed at 128 equally spaced frequency-values
%   between 0 (excluded) and pi. The functions can be computed at 
%   arbitrary frequencies w (a row vector, generated e.g. by
%   LOGSPACE) by G = SPA(DATA,M,w).
%
%   With G = SPA(DATA,M,w,maxsize) also the memory trade-off can
%   be changed. See IDPROPS ALGORITHM.
%
%   When data contains a measured input
%   [Gtf,Gnoi,Gio] = SPA(DATA, ... )
%   returns the information as 3 different IDFRD models:
%   Gtf contains the transfer function estimate from the input to 
%       the output.
%   Gnoi contains the spectrum of the output disturbance v.
%   Gio contains the spectrum matrix for the output and input channels
%       taken together.
%
%   See also IDMODEL/BODE, IDMODEL/NYQUIST, ETFE, and IDFRD.

%   L. Ljung 10-1-86, 29-3-92 (mv-case),11-11-94 (complex data case)
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.29.4.1 $ $Date: 2004/04/10 23:19:17 $

if nargin<1
    disp('Usage: G = SPA(Z)')
    disp('       [G,NSP,Z_SPECT] = SPA(Z,RES_PAR,FREQUENCIES,MAXSIZE,T)')
    return
end
Tsflag=0;
advflag = 0; % To inhibit note about ny
if isa(data,'frd'), data = idfrd(data);end
if isa(data,'idfrd')
    data = iddata(data);
end
if ~isa(data,'iddata')
    advflag = 1;
    if nargin<2|isempty(M)
        ny=1;
    else   
        ny=size(M,2);
    end
    data = iddata(data(:,1:ny),data(:,ny+1:end));
    
end

if nargin>4, data = pvset(data,'Ts',T);end

dom = pvget(data,'Domain');
[Ncaps,ny,nu]=size(data);
if ny==0
    data = pvset(data,'InputData',[],'OutputData',pvget(data,'InputData'),...
        'OutputName',pvget(data,'InputName'),'OutputUnit',...
        pvget(data,'InputUnit'),'InputName','');
    ny = nu; nu = 0;
end

nz = ny+nu;
T = pvget(data,'Ts');
Td = unique(cat(1,T{:}));
if length(Td)>1
    warning(sprintf(['The data contains experiments with different sampling intervals.',...
            '\nThe result may be unreliable. The first sampling interval, ',num2str(T{1}),...
            ', will be used.']))
end
T = T{1}; 
i=sqrt(-1); dw=0;
% *** Set up default values ***
maxsdef = idmsize(max(Ncaps)); %Mod 89-10-31
if nargin<6,inhib=0;end
if nargin<2, M=[]; end %Mod 89-10-31
if dom=='t'
    Mdef=min(30,floor(mean(Ncaps)/10));
else
    Mdef=min(30,floor(mean(2*Ncaps)/10));
end
if isempty(M), M=Mdef;end       %Mod 89-10-31
if any(M<0), M=Mdef*ones(1,length(M));end       
M=M(:)';
if any(M-M(1)~=0), 
    warning('The same window size has to be applied to all outputs')
    warning('The first entry will by used by spa')
end
if nargin<4, maxsize=[]; end
if isempty(maxsize), maxsize=maxsdef;end
if maxsize<0, maxsize=maxsdef;end
if nargin<3, W=[];end
if isempty(W)&T>0, W=[1:128]*pi/128/T; dw=1;end
if any(W<0), W=[1:128]*pi/128/T; dw=1;end
W=W(:)';
M=M(1);
if lower(dom(1))=='f'
    fre = pvget(data,'Radfreqs');
    mx = max(fre{1});
    nam = pvget(data,'Name');
    if isempty(nam);
        nam = inputname(1);
        data = pvset(data,'Name',nam);
    end
    GH = spafdr(data,pi*mx/M,W); %% This may be a bad default
    es = pvget(GH,'EstimationInfo');
    es.Method = 'SPA';
    es.WindowSize = M;
    GH = pvset(GH,'EstimationInfo',es);
    return
end

if ~isreal(data)|nargout==3
    spec_case = 1;
else
    spec_case = 0;
end

if dw==1 & M>128 & ny==1 & nu<2
    % disp('Suggestion: For large M, use etfe(z,M) instead!')
end %mod 91-11-11
if M>=min(Ncaps)
    M=min(Ncaps)-1;
    warning(['Resolution parameter M changed to ',int2str(M)])
end
[nrw,rcw]=size(W);if nrw>rcw,W=W.';end 
if ~isreal(M)|floor(M)~=M|M<2
    error('The Lag Window length M must be a positive integer > 1.')
end

n=length(W);
iddum = idfrd;
est = pvget(iddum,'EstimationInfo');
est.Status = 'Estimated model';
est.Method='spa';
est.WindowSize=M;

Name = pvget(data,'Name');
if isempty(Name), 
    Name = inputname(1);
end
est.DataName = Name;
est.DataLength=Ncaps;
est.DataTs = get(data,'Ts');
est.DataInterSample = get(data,'InterSample');

% *** Compute the covariance functions ***

R=covf(data,M,maxsize);
covdata=zeros(ny,nu,length(W),2,2);
response=zeros(ny,nu,length(W));
spect = zeros(ny,ny,length(W));
zspect = zeros(nu+ny,ny+nu,length(W));
noisecov =spect;
% *** Form the Hamming lag window ***

pd=pi/(M-1);
window=[1 0.5*ones(1,M-1)+0.5*cos(pd*[1:M-1])];
if dw~=1 | nz>2 | spec_case | (nz==2&ny==2), window(1)=window(1)/2;end

if nz<3&ny==1 & ~spec_case,
    % *** For a SISO system with equally spaced frequency points
    %     we compute the spectra using FFT for highest speed ***
    
    noll=zeros(1,2*(n-M)+1);
    order=2:n+1;
    nfft = 2.^nextpow2(2*n);
    if nz==2
        if dw==1
            rtem=R(4,:).*window;
            FIU=real(fft([rtem noll rtem(M:-1:2)],nfft));FIU=FIU(order);
            rtem=R(3,:).*window;
            FIYU=fft([R(2,1:M).*window noll rtem(M:-1:2)],nfft);
            FIYU=FIYU(order);
        end
        
        % *** For arbitrary frequency points we use POLYVAL for the
        %      computation of spectra ****
        
        if dw~=1
            rtem=R(4,:).*window;
            FIU=2*real(polyval(rtem(M:-1:1),exp(-i*W*T)));
            rtem=R(2,:).*window; rtemp=R(3,:).*window;
            FIYU=polyval(rtem(M:-1:1),exp(-i*W*T)) + ...
                polyval(rtemp(M:-1:1),exp(i*W*T));
        end
        
        % *** Now compute the transfer function estimate ***
        
        response(1,1,:)=FIYU./FIU;
    end %if nz==2
    
    % *** Compute the noise spectrum (= the output spectrum for
    %     a time series) ***
    
    
    rtem=R(1,:).*window;
    if dw==1
        FIY=real(fft([rtem noll rtem(M:-1:2)],nfft)); FIY=FIY(order);
    end
    if dw~=1
        FIY=2*real(polyval(rtem(M:-1:1),exp(-i*W*T)));
    end
    if nz==2, FFV=(FIYU.*conj(FIYU))./FIU;,else FFV=zeros(1,n);end
    PV1 = T*abs(FIY-FFV)'; spect(1,1,:)=PV1; 
    noisecov(1,1,:)=real((0.75*M/sum(Ncaps))*(T*abs(FIY-FFV)').^2);
    if nz==2
        covdata(1,1,:,1,1)=(real(0.75*M/sum(Ncaps)/2*(PV1/T)./abs(FIU)'));
        covdata(1,1,:,2,2)=covdata(1,1,:,1,1);
    end
    
    
else  % end case nz<3
    %
    % 
    % *** Now we have to deal with the multi-variable case ***
    %
    if ny==1&~inhib&nz>2&advflag, 
        warning(['Your data is interpreted as single output with ',...
                int2str(nu) ,' inputs'])
        warning(['If you have multi-output data, let the argument M have as ',...
                'many elements as the number of outputs!'])
    end
    FI=zeros(nz,n);
    for k=1:nz^2
        rtem=R(k,:).*window;
        FI(k,:)=polyval(rtem(M:-1:1),exp(i*W*T));
    end
    outputs=[1:ny];inputs=[ny+1:nz];ZSPE=zeros(nz^2,n);
    for k=1:n
        FIZ=zeros(nz); FIZ(:)=FI(:,k); FIZ=FIZ+FIZ';ZSPE(:,k)=FIZ(:);
        FIZ = T*FIZ;
        zspect(:,:,k)=FIZ;
        if nu>0, 
            GCk=((FIZ(outputs,inputs))/FIZ(inputs,inputs));%.'; %%LL%% check
            PHIUINV=inv(FIZ(inputs,inputs));
            for kd=1:nu
                diagCOV(k,kd)=PHIUINV(kd,kd);
            end
            spect(:,:,k)=real((FIZ(outputs,outputs) -FIZ(outputs,inputs)*conj(GCk.'))');
            response(:,:,k)=GCk;%PVC(k,:)=diag(PVCk)';
        else 
            spect(:,:,k) = FIZ;
            %PVC(k,:)=diag(FIZ)';
        end
    end
    noisecov = (0.75*M/sum(Ncaps))*spect.^2;
    if nargout==3
        znoisecov = (0.75*M/sum(Ncaps))*zspect.^2;
    end
    %PA=abs(PVC);
    if nu>0
        for ky=1:ny
            for ku=1:nu
                covdata(ky,ku,:,1,1)=abs((0.75*M/sum(Ncaps)/2*...
                    squeeze((spect(ky,ky,:))).*diagCOV(:,ku)));
                covdata(ky,ku,:,2,2)=covdata(ky,ku,1,1);
            end
        end
        
    end
end
OutputName = pvget(data,'OutputName');
InputName = pvget(data,'InputName');
OutputUnit = pvget(data,'OutputUnit');
InputUnit = pvget(data,'InputUnit');
if any(nargout == [0 1])
    GH=idfrd(response,W',T,'CovarianceData',covdata,...
        'SpectrumData',spect,'NoiseCovariance',noisecov,'EstimationInfo',est,...
        'InputName',InputName,'OutputName',OutputName,...
        'InputUnit',InputUnit,'OutputUnit',OutputUnit);
else % This is to honor old syntax
    
    GH=idfrd(response,W',T,'CovarianceData',covdata,...
        'EstimationInfo',est,...
        'InputName',InputName,'OutputName',OutputName,...
        'InputUnit',InputUnit,'OutputUnit',OutputUnit);
    PV=idfrd([],W',T,'CovarianceData',[],...
        'SpectrumData',spect,'NoiseCovariance',noisecov,'EstimationInfo',est,...
        'InputName',InputName,'OutputName',OutputName,...
        'InputUnit',InputUnit,'OutputUnit',OutputUnit);
    PV=tsflag(PV,'set');
    if nargout==3
        ZSP=idfrd([],W',T,'CovarianceData',[],...
            'SpectrumData',zspect,'NoiseCovariance',znoisecov,'EstimationInfo',est,...
            'InputName',[],'OutputName',[OutputName;InputName],...
            'InputUnit',[],'OutputUnit',[OutputUnit;InputUnit]);
    end
end
   

