function [e1,r1,adv]=resid(varargin)
%RESID  Computes and tests the residuals associated with a model.
%   RESID(MODEL,DATA) or RESID(MODEL,DATA,MODE)
%
%   DATA: The output-input data as an IDDATA or IDFRD object.
%   MODEL: The model to be evaluated on the given data set.  
%       This is an IDMODEL object, like IDPOLY, IDPROC, IDSS,IDARX or IDGREY.
%   MODE: One of 
%    'CORR' (default). Correlation analysis performed.
%    'IR' : The impulse response from the input to the residuals is shown
%    'FR' : The (amplitude) frequency response from the input to the
%           residuals is shown.
%    (For frequency domain data, 'FR' is default.)
%
%   The model residuals (prediction errors) E from MODEL when applied to 
%   DATA are computed. 
%   When MODE = 'CORR', the autocorrelation function of E and the 
%   cross correlation between E and the input(s) is computed and displayed. 
%   When MODE = 'IR' or 'FR' a model from the inputs to E is computed, and
%   displayed either as an impulse response or a frequency response.
%
%   All these response curves should be "small". In all cases, 99 % confidence
%   regions around zero limits for these values are also given. 
%   For a model to pass the residual test, the curves should thus ideally 
%   be inside the yellow regions. 
%
%   The correlation functions for MODE = 'CORR' are given up to lag 25, which
%   can be changed to M by RESID(MODEL,DATA,M). If M is specified, this will also
%   be the number of positive lags used for the impulse response in the 'IR' case.
%
%   (Note that the confidence intervals obtained for IDFRD data may be
%   misleading depending on the amount of data compression in the data
%   set.)
%
%   E = RESID(MODEL,DATA) produces not plot but returns
%   E : The residuals associated with MODEL and DATA. 
%       This is an IDDATA object with the residuals as output and
%       the input of DATA as input.
%
%   See also PE.

%   L. Ljung 10-1-86,1-25-92
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.1 $  $Date: 2004/04/10 23:17:36 $

if nargin < 1
    disp('Usage: RESID(MODEL,DATA)')
    disp('       E = RESID(MODEL,DATA,No_OF_LAGS,MODE)')
    return
end

M = 25;
mode = 'corr';
fflag = 't';
setmode  = 0;
for kk = 1:length(varargin)
    arg = varargin{kk};
    if isa(arg,'frd')|isa(arg,'idfrd')
        arg = iddata(idfrd(arg));end
    if isa(arg,'idmodel')
        th = arg;
        inpn=inputname(kk);
    elseif ischar(arg)
        mode = arg;
        setmode = 1;
    elseif isa(arg,'iddata')
        z = arg;
        if strcmp(pvget(z,'Domain'),'Frequency')
            fflag = 'f';
        end
        
    elseif isa(arg,'double')
        if length(arg)==1
            M = arg;
        else
            z = arg;
        end
    end
end
if strcmp(mode,'corr')&fflag=='f'
    mode = 'fr';
    if setmode
        warning('The ''CORR'' option is not supported for frequency domain data.')
    end
end
M = floor(M);
if M<=0
    error('The number of lags to show must be a positive integer.')
end


% ** Set up the default values **
iddatflag = 1;
if ~isa(z,'iddata')
    iddatflag = 0;
    [ny,nu]=size(th);
    z=iddata(z(:,1:ny),z(:,ny+1:end));
end
plotflag = 1;
[Ncaps]=size(z,'N');
maxsize = th.Algorithm.MaxSize;
if ischar(maxsize)|isempty(maxsize)
    maxsize = idmsize(max(Ncaps));
end
if nargin==1,
    [nz2,M1]=size(z);nz=sqrt(nz2);
    M=M1-2;
    N=z(1,M1-1);
    ny=z(1,M1);
    nu=nz-ny;
    r=z(:,1:M);
end
if nargin>1,
    % *** Compute the residuals and the covariance functions ***
    [ny,nu]=size(th);  
    [Ncap,nyd,nud] = size(z);
    if nyd~=ny|nud~=nu
        error('Mismatch in numer of inputs and outputs in data and model.')
    end
    nz=ny+nu;
    if fflag=='f'&nu==0
        error('RESID cannot be applied to time-series models (nu=0) and frequency domain data.')
    end
    
    e=pe(z,th,[],0);
    e = pvset(e,'InputData',pvget(z,'InputData'));
    if fflag=='t'
        r = covf(e,M,maxsize);
    else
        r = [];
    end
end
if nargout
    if ~iddatflag % to honor old syntax
        e1 = pvget(e,'OutputData'); e1 =e1{1};
    else
        e1 = e;
    end
    r1 = r;
    r1(1,M+1:M+2)=[Ncaps(1),ny]; % To honor old syntax
    
    if iddatflag
        plotflag = 0;
        if fflag=='t'
            mode = 'corr';
        end
    end
end
% First figure out the number of degrees of freedom for chi2tests
adm = getadv(th);
modid = -1;
try
    modid = adm.estimation.DataId;
end
utd = pvget(z,'Utility');
try
    adv.DataId = datenum(utd.last);
catch
    adv.DataId = 0;
end
if modid==adv.DataId %same validation and estimation data
    xiextrauy = 0;
    xiextrae = 0;
else % find the number of par
    [Nm,npar] = getncap(th);
    if isempty(Nm)
        Nm = inf;
    end
    [ny,nu] = size(th);
    [Ncap,ny,nu]=size(e);
    N = sum(Ncap);
    if nu>0
        xiextrauy = floor(npar/ny/nu*N/Nm);
        xiextrae = floor(xiextrauy*nu);
    else
        xiextrae = 0;
    end
end

[ny,nu] = size(th);
if nu>0&fflag=='t'
    test = chi(e,M,xiextrauy);
end
if strcmp(lower(mode(1)),'f')&plotflag % frequency respose of MEM
    if nu == 0
        error('The ''FR'' option cannot be applied to time series models.')
    end
    N = size(e,'N'); N =sum(N);
    firorder =  floor(min([N/3/nu,70/nu,25]));
    for ky = 1:ny
        m1 = arx(e(:,ky),[0 firorder*ones(1,nu) zeros(1,nu)]);
        bode(m1,'sd',2.58,'fill','ap','a','resid'),if ky<ny,pause,end
    end
elseif strcmp(lower(mode(1)),'i')&plotflag % Impulse response
    if nu == 0
        error('The ''IR'' option cannot be applied to time series models.')
    end
    Ts = pvget(e,'Ts'); Ts = Ts{1};
    impulse(e,'sd',2.58,'fill',M*Ts)
elseif lower(mode(1))=='c'
    
    %end
    if plotflag
        newplot  
    end
    nr=0:M-1;plotind=0;
    oname = pvget(z,'OutputName');
    iname= pvget(z,'InputName');
    N = sum(Ncaps);
    for ky=1:ny
        ind=ky+(ky-1)*nz;
        % ** Confidence interval for the autocovariance function **
        sdre=2.58*(r(ind,1))/sqrt(N)*ones(M,1);
        if nz==1, 
            spin=111;
        else 
            spin=210+plotind+1;
        end,
        if plotflag
            subplot(spin)
            xax=[nr(1);nr(end);nr(end);nr(1)]; 
            yax=[sdre(1);sdre(1);-sdre(1);-sdre(1)]/r(ind,1); 
            fill(xax,yax,'y'),hold on
            stem(nr,r(ind,:)'/r(ind,1)),hold off
            title(['Correlation function of residuals. Output ',oname{ky}])
            xlabel('lag')
            plotind=rem(plotind+1,2);
            if plotind==0,
                pause,newplot;
            end
        end
        chiteste(ky) = 100*idchi2(r(ind,2:end)*r(ind,2:end)'/r(ind,1)^2*sum(Ncaps),...
            M-1+xiextrae);%OK
        outteste(ky) = sum(abs(r(ind,2:end))>1.5*sdre(1));
    end
    
    nr=-M+1:M-1;
    % *** Compute confidence lines for the cross-covariance functions **
    outtestue=zeros(ny,nu,M);
    for ky=1:ny
        for ku=1:nu
            ind1=ky+(ny+ku-1)*nz;ind2=ny+ku+(ky-1)*nz;indy=ky+(ky-1)*nz;
            indu=(ny+ku)+(ny+ku-1)*nz;
            sdreu=2.58*sqrt(r(indy,1)*r(indu,1)+2*(r(indy,2:M)*r(indu,2:M)'))/sqrt(N)*ones(2*M-1,1); % corr 890927
            if plotflag
                spin=210+plotind+1;subplot(spin)
                xax=[nr(1);nr(end);nr(end);nr(1)]; 
                yax=[sdreu(1);sdreu(1);-sdreu(1);-sdreu(1)]/(sqrt(r(indy,1)*r(indu,1))); 
                fill(xax,yax,'y'),hold on
                stem(nr,[r(ind1,M:-1:1) r(ind2,2:M) ]'/(sqrt(r(indy,1)*r(indu,1)))),hold off
                
                title(['Cross corr. function between input ',iname{ku},...
                        ' and residuals from output ',oname{ky}])
                xlabel('lag')
                plotind=rem(plotind+1,2);
                if ky+ku<nz & plotind==0,
                    pause,newplot;
                end
            end
            test1 = find(abs(r(ind2,2:M))>1.5*sdreu(1));
            outtestue(ky,ku,:) = abs(r(ind2,1:M)/sdreu(1));
        end,
    end
    r(1,M+1:M+2)=[N,ny];
    if plotflag
        set(gcf,'NextPlot','replace');
    end
end
ut = pvget(th,'Utility');
try
    adv = ut.advice.resid;
catch
    adv.chitestue = [];
    adv.chitestuefb = [];
    adv.chiteste =[];
    adv.outtestue =[];
    adv.outteste = [];
end
if nu>0&fflag=='t'
    adv.chitestue = test.chidyn;
    adv.chitestuefb = test.chifb;
end
adv.r = r;
if strcmp(mode,'corr');
    adv.chiteste = chiteste;
    adv.outtestue = outtestue;
    adv.outteste = outteste;
end


utd = pvget(z,'Utility');
try
    adv.DataId = datenum(utd.last);
catch
    adv.DataId = 0;
end

ut.advice.resid = adv;
th = uset(th,ut);
try
    assignin('caller',inpn,th);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test = chi(e,M,plus)
% computes the chi^2 tests for Reu

[Ncap,ny,nu]=size(e);
N = sum(Ncap);
for ky = 1:ny
    me = ar(e(:,ky,[]),10); %%LL carry out prewhitening if necessary
    a = pvget(me,'a');
    for ku = 1:nu
        et = e(:,ky,ku);
        r = covf(et,M);
        re0=r(1,1); % the variance of e
        Ru = toeplitz(r(4,:));
        %% r(3,1)=r(2,1) could be attributed either to forward or feebdack 
        %% path. Now ignored.
        %% direct= inlcudes dircet term. nodir excludes it
        direct = 1:size(r,2);
        nodir = 2:size(r,2);
        chitestfb(ky,ku) = ...
            100*idchi2(r(3,nodir)*inv(Ru(nodir,nodir))*r(3,nodir)'*N/re0,M+plus);
        chitestdyn(ky,ku) = ...
            100*idchi2(r(2,nodir)*inv(Ru(nodir,nodir))*r(2,nodir)'*N/re0,M+plus);
        
    end
    
end
test.chifb = chitestfb;
test.chidyn = chitestdyn;


