function sys = idfrd(varargin)
%IDFRD  Creation of or conversion to  Identified Frequency Response Data model.
%
%   Identified Frequency Response Data (IDFRD) models are useful for storing 
%   frequency responses of linear systems as well as their uncertainties. 
%   IDFRD also stores experimental response data, and directly estimated frequency 
%   responses obtained from SPA, SPAFDR and ETFE.
%   Parts of the response can be selected by FSELECT.
%
%  Creation:
%    MF = IDFRD(RESPONSE,FREQS,TS) 
%    creates an IDFRD model MF with response data in RESPONSE at frequency 
%    points in FREQS.  TS is the sample time. Use TS = 0 to denote the 
%    response from a continuous time system. See "Data format" below for details.
%
%    To add information about the uncertainty (covariance) of the response use  
%    MF = IDFRD(RESPONSE,FREQS,TS,'CovarianceData',COVARIANCE)
%    where COVARIANCE contains the covariance of RESPONSE in a format
%    described below.
%
%    To include information about the spectrum of additive disturbances
%    (noise), or to store the spectrum of a time series use the Properties
%    'SpectrumData', and 'NoiseCovariance' for the uncertainty:
%    MF = IDFRD(RESPONSE,FREQS,TS,'CovarianceData',COVARIANCE,...
%               'SpectrumData',SPECTRUM,'NoiseCovariance',COVSPECT)
%    See below for the data formats.
%
%    An IDFRD model can also be created by converting any IDMODEL or LTI
%    model MOD to frequency response data:
%
%    MF = IDFRD(MOD)   or  MF = IDFRD(MOD,FREQS)
%
%    The frequency response and the output noise spectra, as well as
%    their covariances are then computed from MOD and stored in MF.
%    Any InputDelay in MOD is transformed to phase lag so MF will in
%    this case have InputDelay = zeros(nu,1);
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of IDFRD models (type IDPROPS IDFRD 
%    for details). 
%
%  Data format:
%    For SISO models, FREQS is a vector of real frequencies, and RESPONSE is
%    a vector of response data, where RESPONSE(i) represents the system
%    response at FREQS(i).
%
%    For MIMO IDFRD models with NY outputs, NU inputs, and NF frequency points,
%    RESPONSE is a NY-by-NU-by-NF array where RESPONSE(i,j,k) specifies the
%    frequency response from input j to output i at frequency FREQS(k).
%
%    COVARIANCE is a 5D-array where COVARIANCE(KY,KU,k,:,:)) is the 2-by-2 
%    covariance matrix of RESPONSE(KY,KU,k). The 1,1 element
%    is the variance of the real part, the 2,2 element the variance
%    of the imaginary part and the 1,2 and 2,1 elements the covariance
%    between the real and imaginary parts. SQUEEZE(COVARIANCE(KY,KU,k,:,:))
%    gives the covariance matrix of the corresponding response.
%
%    SPECTRUM is a NY-by-NY-by-NF array, such that SPECTRUM(ky1,ky2,k)
%    is the cross spectrum between the disturbance at output ky1 and at 
%    output ky2 for frequency FREQS(k).
%
%    COVSPECT is an array of the same dimension as SPECTRUM such that  
%    COVSPECT(ky1,ky2,k) is the variance of SPECTRUM(k1,k2,k). 
%
%    By default, the units of the frequencies in FREQS are 'rad/s'.
%    Alternately, you can change the units to 'Hz' by modifying the 'Units'
%    property.  Note that changing this property value does not
%    change the numerical frequency values.  Use CHGUNITS(SYS,UNITS) to change
%    the frequency units of an IDFRD model, performing the necessary conversion.
%
%    See also IDFRD/FSELECT, SPA, SPAFDR, ETFE, IDFRD/FCAT, IDFRD/CHGUNITS.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.1 $  $Date: 2004/04/10 23:16:47 $


ni = nargin;
if ni>1
    if ~isa(varargin{2},'double')
        error('The second argument to idfrd (if any) must contain the frequency vector.')
    end
end
idx = [];
try
    superiorto('lti','zpk','ss','tf')
end
try 
    inferiorto('idmodel','idss','idproc','idpoly','idarx','idgrey')
end
if nargin == 0
    sys = idfrd([],[]);
    return
end
mod = varargin{1};
modin = mod;
if ni & isa(mod,'idfrd'),
    % Quick exit  
    if ni==1
        sys = modin;
    else
        error('Use SET to modify the properties of IDFRD objects.');
    end
    return
end
if ni & (isa(mod,'idmodel') | isa(mod,'lti'))
    % first check if units is 'hz':
    hzflag = 0;
    if nargin>2
        for ka=3:nargin
            try 
                if strcmp(lower(varargin{ka}(1:3)),'uni')&...
                        strcmp(lower(varargin{ka+1}(1)),'h')
                    hzflag = 1;
                    
                end
            end
        end
    end
    if isa(mod,'lti')
        if ~isa(mod,'frd') 
            try
                mod=idss(mod);
            catch
                
                if nargin>1
                    mod=frd(varargin{:});
                else
                    wdef = iddefw(mod,'b');
                    %if hzflag, wdef=wdef*2*pi;end
                    %wdef=logspace(log10(pi/100),log10(10*pi),128)';
                    mod=frd(mod,wdef);
                end
                sys=idfrd(mod);
                return
            end
            %                 if ~isempty(idx)
            %                     ut = pvget(sys,'Utility')
            %                     ut.bodeidx = idx;
            %                     sys=uset(sys,ut);
            %                     return
            %                 end
            
            %return
        else % FRD
            frdo = mod;
            sys = idfrd(frdo.ResponseData,frdo.Frequency,[],[]);
            sys.Units=pvget(frdo,'Units');
            sys.Ts=pvget(frdo,'Ts');
            ino=frdo.InputName;
            if ~isempty(ino{1})
                sys =pvset(sys,'InputName',ino);
            end
            ono = frdo.OutputName;
            if ~isempty(ono{1})
                sys =pvset(sys,'OutputName',ono);
            end
            return  
        end
    end
    
    [bb,mod,flag] = idpolget(mod);
    if flag&isa(modin,'idmodel')
        try
            assignin('caller',inputname(1),mod)
        catch
        end
    end
    varargin{1}=mod; % To make use of possible updates of model
    if length(varargin)==1,ea=1;else ea=2;end
    if ea==1, 
        w = iddefw(mod,'b');
         varargin{2} = w;
        ea =2;
    end
    if hzflag % hzflag cannot be set if ea==1
        varargin{2}=varargin{2}*2*pi;
    end
    nu = size(mod,'nu');
    if nu == 0
        [spect,w,covspec]=freqresp(varargin{1:ea}); 
        frre = []; covfr =[];
    else
        [frre,w,covfr]=freqresp(varargin{1:ea}); 
        modn = mod(:,'noise');
        if ~isempty(modn)
            %if ea==1
            
            %   [spect,w,covspec]=freqresp(modn);
            %else
            [spect,w,covspec]=freqresp(modn,varargin{2});
            %end
        else
            spect =[]; covspec=[];
        end
    end
    if hzflag
        w=w/2/pi;
    end
    Ts = pvget(mod,'Ts');
    sys = idfrd(frre,w(:),Ts);
    sys = pvset(sys,'CovarianceData',covfr,...
        'SpectrumData',spect,'NoiseCovariance',covspec,...
        'InputName',pvget(varargin{1},'InputName'),...
        'OutputName',pvget(varargin{1},'OutputName'),...
        'InputUnit',pvget(mod,'InputUnit'),...
        'OutputUnit',pvget(mod,'OutputUnit'),...
        'Notes',pvget(mod,'Notes'),...
        'EstimationInfo',pvget(mod,'EstimationInfo'));
    %         if ~isempty(idx)
    %             ut = pvget(sys,'Utility');
    %             ut.bodeidx = idx;
    %             sys = uset(sys,ut);
    %         end
    if length(varargin)>2
        if hzflag
            was = warning;
            warning off
        end
        try
            set(sys,varargin{3:end})
        catch
            error(lasterr)
        end
        if hzflag
            warning(was)
        end
    end
    return
end

% Define default property values
est.Status = 'Not estimated from data.';
est.Method=[];
est.WindowSize=[];
est.DataName=[];
est.DataLength=[];
est.DataTs = 1;
est.DataDomain ='Time';
est.DataInterSample = 'zoh';
PVstart = 0;
for kk=1:length(varargin)
    if ischar(varargin{kk})
        PVstart = kk;
        break
    end
end
if length(varargin)<2|(PVstart<3&PVstart)
    error('Syntax: MF = IDFRD(Response,Freqs,Ts).')
end
if PVstart
    numarg = varargin(1:PVstart-1);
    newargs = varargin(PVstart:end);
else
    numarg = varargin;
    newargs = {};
end
if length(newargs)/2~=floor(length(newargs)/2);
    error('Property/Value arguments must come in pairs.')
end
fr = varargin{2};
if ~isempty(fr)
    nd = ndims(fr);
    m = min(size(fr));
    if nd~=2 | m ~= 1 
        error('FREQS must be a vector of nonnegative real values.')
    end
    if any(imag(fr)~=0)%any(fr<0)|any(imag(fr)~=0)
        error('FREQS must be a vector of real values.')
    end
    fr = fr(:);
end
Nf = length(fr);
re = varargin{1};
if ~isempty(re)
    if Nf>1
        nd = ndims(re);
        if nd == 2
            nd = min(size(re));
        end
        if ~any(nd==[1 3]) 
            error(sprintf(['The response data must be a vector for SISO systems',...
                    '\nor a 3-D array RESPONSE(NY,NU,NF) for MIMO, MISO and SIMO,'...
                    '\nsuch that RESPONSE(i,j,k) specifies the ',...
     'frequency response \nfrom input j to output i at frequency FREQS(k).']))
        end  
        
        if nd == 1
            Va = zeros(1,1,length(re));
            Va(1,1,:) = re;
            re = Va;
        end
    end
end
if length(numarg)>2
    ts = numarg{3};
else
    ts =[];
end
if isempty(ts),  
    ts = 1;  
end
if ndims(ts)>2 | length(ts)~=1 | ~isreal(ts) | ~isfinite(ts),
    error('Sample time must be a real number.')
elseif ts<0 
    error('Negative sample time not allowed.');
end
if length(numarg)>3
    cov = numarg{4};
else
    cov = [];
end
if ~isempty(cov)
    nd = ndims(cov)
    if nd~=5
        error(sprintf(['The covariance data must be a 5-D',...
                ' array COVARIANCE(NY,NU,FREQS,:,:)\nwhere the last two',...
                ' dimensions hold the 2-by-2 covariance matrix.']))
    end
    [n1,n2,n3,n4,n5]=size(cov);
    if ~(n4==2&n5==2)
        error(sprintf(['The covariance data must be a 5-D',...
                ' array COVARIANCE(NY,NU,FREQS,:,:)\nwhere the last two',...
                ' dimensions hold the 2-by-2 covariance matrix.']))
    end
end

sys = struct('Name','','Frequency',fr,'ResponseData',re,...
    'SpectrumData',[],...
    'CovarianceData',cov,'NoiseCovariance',[],...
    'Units','rad/s',...
    'Ts',ts,'InputDelay',[],...
    'EstimationInfo',est,'InputName',{{''}},'OutputName',{{''}},...
    'InputUnit',{{''}},'OutputUnit',{{''}},'Notes',[],'UserData',[],...
    'Version',1.0,'Utility',[]);

sys = class(sys,'idfrd');
sys = timemark(sys,'c');
% Finally, set any PV pairs

if length(newargs)>0
    try
        set(sys,newargs{:}) 
    catch
        error(lasterr)
    end
    
else
    sys=pvset(sys); % To do exit checks
end


