function [yh1,fit1] = compare(varargin)
%COMPARE Compares the simulated/predicted output with the measured output.
%   COMPARE(DATA,SYS,M)
%
%   DATA : The data (an IDDATA or IDFRD object) for which the
%           comparison is made (the validation data set).
%   SYS: The model in an IDMODEL object format
%
%   M : The prediction horizon. Old outputs up to time t-M are used to
%       predict the output at time t. All relevant inputs are used.
%       M = inf gives a pure simulation of the system. (Default M=inf).
%   COMPARE  plots the simulated/predicted output together with the 
%       measured output in DATA, and displays how much of the output 
%       variation has been explained by the model. 
%       When DATA is frequency domain, the absolute value of the
%       corresponding frequency functions are shown. When DATA is frequency
%       response data (IDFRD), the amplitude of the models's and the data's
%       frequency functions are shown in a log-log diagram. A table of
%       model fit to data is also shown. The fit is calculated as
%       fit = 100(1-norm(y-yhat)/norm(y-mean(y))) (in %) where y is the
%       output of the validation data and yhat is the model output.
%       The matching of input/output channels in DATA and SYS is based 
%       on the channel names. It is thus possible to evaluate models that
%       do not use all input channels available in DATA.
%   Several Models:
%   COMPARE(DATA,SYS1,SYS2,...,SYSn,M) compares several models.  You can also
%       specify a color, line style, and marker for each system, as in  
%       COMPARE(DATA,sys1,'r',sys2,'y--',sys3,'gx').
%
%   If DATA contains multiple experiments, one plot for each experiment
%   is produced.
%
%   Further Options:
%   After the list of regular input argumenents Property value pairs can
%   be added:
%   COMPARE(DATA,SYS,..,SYSn,M,Prop_1,Value_1,Prop_2,Value_2)
%   Useful Property/Value pairs are
%   'Samples'/SAMPNR: Here SAMPNR are the sample numbers in DATA to be 
%         plotted and used for the computation of FIT.
%         For multi-experiment data, SAMPNR must be a cell array of the same
%         size as the number of experiments.
%   'InitialState'/INIT Handles the initial state of the model/predictor.
%         INIT='e' (default when data is iddata): Estimate the initial state for best fit
%         INIT='m': Use the model's internally stored initial state
%         INIT='z'(deafault when data is idfrd): Set the initial state to zero
%         INIT=X0, where X0 is a column vector of the same length as
%                  the state vector: Use X0 for the initial state.
%   'OutputPlots'/YPLOTS: Here YPLOTS is a cell array of those OutputNames
%         in DATA to be plotted. All outputs in DATA are used for the
%         computation of the predictions, though.
%   
%   Output arguments: [YH,FIT] = COMPARE(DATA,SYS,..,SYSn,M)
%   produces no plot, but returns the simulated/predicted model 
%   output YH, and FIT the %  of the measured output that was explained 
%   by the model. The formula for computing FIT was given above.
%   YH is a cell array of IDDATA data sets, one for each model.
%   FIT is a 3-D array with element FIT(Kexp,Kmod,Ky) containing
%   the fit for experiment Kexp, model Kmod, and output Ky.
%   See also IDMODEL/SIM and PREDICT.

%   YH: The resulting simulated/predicted output.

%   L. Ljung 10-1-89,10-10-93
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.31.4.1 $  $Date: 2004/04/10 23:17:21 $

no = nargout;
if nargin<2
    disp('Usage: COMPARE(DATA,MODEL)')
    disp('       [YH,FIT] = COMPARE(DATA,MODEL1,...MODELn,PRED_HOR,''Samples'',SAMPNR,''InitialState'',INIT,''OutputPlots'',YPLOTs)')
    return
end   
ni = nargin;
no = nargout;
adv = [];
% First pars for the special PV-pairs
init = []; nr = []; ychan = [];
hitnr = [];
chansel = 0;

for ki=1:ni
    try
        pnmatchd(varargin{ki},{'InitialState'});
        init = varargin{ki+1};
        hitnr = [hitnr,ki,ki+1];
    end
    try
        pnmatchd(varargin{ki},{'Samples'});
        nr = varargin{ki+1};
        hitnr = [hitnr,ki,ki+1];
    end
    try
        pnmatchd(varargin{ki},{'OutputPlots'});
        ychan = varargin{ki+1};
        chansel = 1;
        hitnr = [hitnr,ki,ki+1];
    end
end
varargin(hitnr)=[];
ni = length(varargin);
% Parse input list
% First take out YCHANNELS if defined
%chansel = 0;
ychantest = varargin{end};
if iscell(ychantest)&ischar(ychantest{1}) % then channels are specified
    ychan = ychantest;
    varargin = varargin(1:end-1);
    ni = ni-1;
    chansel = 1;
end
nsys = 0;      % counts LTI systems
nstr = 0;      % counts plot style strings 
nw = 0;
sys = cell(1,ni);
sysname = cell(1,ni);
PlotStyle = cell(1,ni);
m=inf;
inpn=cell(1,length(varargin));
for kk = 1:length(varargin)
    inpn{kk} = inputname(kk);
end

for kk = 2:length(varargin)
    if strcmp(class(varargin{kk}),'iddata')
        varargin = [varargin(kk),varargin([1:kk-1,kk+1:end])];
        inpn = [inpn(kk),inpn([1:kk-1,kk+1:end])];
        break
    end
end

z=varargin{1};
if isa(z,'frd')
    z = idfrd(z);
end
if isa(z,'idfrd')
    z = iddata(z,'me');
    frdflag = 1;
else
    frdflag = 0;
end
m1=varargin{2};
[ny,nu]=size(m1);
if ~isa(z,'iddata')
    if ~isa(z,'double')
        error('A data set must be supplied')
    end
    tsm = pvget(m1,'Ts');
    if tsm == 0
        ttes = pvget(m1,'Utility'); % This is really to honor old syntax
        try
            tsm = ttes.Tsdata;
        catch
            error(sprintf(['  For a continuous time model the input data must be ',...
                    'given as an IDDATA object.\n  Use U = iddata([],u,Ts).']))
        end
    end
    z = iddata(z(:,1:ny),z(:,ny+1:end),tsm);
end
if isnan(z)
    error('The data set in COMPARE cannot contain NaNs.')
end
zfflag = 0; % To flag the presence of frequency 0 in FD data set
if strcmp(pvget(z,'Domain'),'Frequency')
    fre=pvget(z,'SamplingInstants');
    for kexp = 1:length(fre)
        if any(fre{kexp}==0)
            zfflag = 1;
        end
    end
    if size(z,'nu')==0
        error('Compare does not accept frequency domain data for time series (no input).')
    end
end
realflag = isreal(z);

ud = pvget(z,'Utility');
dataid = datenum(ud.last);
lastsyst = 0;
%lastplot = j;
modflag = 0;
for jj=2:ni,
    argj = varargin{jj};
        if isa(argj,'idfrd')|isa(argj,'frd')
            error(sprintf(['COMPARE does not accept frequency function data (IDFRD or FRD)',...
                    ' as models.\nUse BODE instead.']))
        end
    if isa(argj,'lti'),
        argj=idss(argj);
    end
    if isa(argj,'idmodel')
        if ~isempty(argj)
            nsys = nsys+1;   
            sys{nsys} = argj;
            sysname{nsys} = inpn{jj};lastsyst=jj;
            modflag=1;
        end
    elseif isa(argj,'char')&modflag
        nstr = nstr+1;   
        PlotStyle{nsys} = argj; lastplot=jj;
        modflag = 0;
    else
        break
    end
end
if ~modflag 
    lastsyst=lastsyst+1;
end 
kk=1;
if ni>lastsyst
    for jj=lastsyst+1:ni
        newarg{kk}= varargin{jj};kk=kk+1;
    end
else
    newarg={};
end
[nrow,ny,nu,Ne]=size(z); 
narg=size(newarg,2);
if narg>=3, init=newarg{3};end
if narg>=2, nr = newarg{2};end
if narg<1, m=[];else m=newarg{1};end
if isempty(init),
    if frdflag
        init = 'z';
    else
        init='e';
    end
end
if isempty(nr),
    for kexp = 1:Ne
        nr{kexp}=1:nrow(kexp);
    end
end
if ~iscell(nr)
    nr ={nr};
end
if length(nr)~=Ne
    error(sprintf(['When the Sample Numbers are specified, they must be given as',...
            '\na cellarray of length equal to the number of experiments.']))
end

sa = pvget(z,'SamplingInstants'); 

for kexp = 1:Ne % translate intervals to absolute time
    sam = sa{kexp};
    timebeg{kexp}=sam(nr{kexp}(1));
    timeend{kexp}=sam(nr{kexp}(end));
end

if isempty(m),m=inf;end
if ~isstr(init),xi=init;init='s';end
[nrr,nrc]=size(nr);if nrr>nrc,nr=nr';end
if ~isinf(m),
    if m>=min(size(z,'N'))
        warning(sprintf(['The prediction horizon must be less that the data length.',...
                '\nPrediction has been replaced by simulation.']))
        m = inf;
    end
    if m<1|m~=floor(m)
        error('The prediction horizon M must by a positive integer.')
    end
    if strcmp(pvget(z,'Domain'),'Frequency')
        warning(sprintf(['For frequency domain data you cannot use a finite prediction horizon.',...
                '\nIt has been replaced by Inf (meaning simulation).']))
        m = inf;
    end
end

if ~no
    cols=get(gca,'colororder');
    if sum(cols(1,:))>1.5  
        colord=['y','m','c','r','g','b']; % Dark background
    else
        colord=['b','g','r','c','m','y']; % Light background
    end
end
y = pvget(z,'OutputData');
u = pvget(z,'InputData'); 
ynam = pvget(z,'OutputName');
unam = pvget(z,'InputName');
Td= pvget(z,'Ts'); 
sampdata = pvget(z,'SamplingInstants');

fit=zeros(Ne,nsys,ny);

for ksys=1:nsys
    th = sys{ksys};
    if zfflag
        was = warning;
        warning off
        fr = freqresp(th,0);
        warning(was)
        if any(isinf(fr))|any(isnan(fr))
            warning(sprintf(['Frequency zero has been removed from the data set',...
                    '\nsince model ',sysname{ksys},' contains an integration.']))
            z = rmzero(z);
        end
    end
     th = pvset(th,'CovarianceMatrix','None');
    if ~isa(th,'idgrey'); th = idss(th);end
    aa = pvget(th,'A'); nx=size(aa,1);
    una = th.InputName;
    yna = th.OutputName;
    if length(una)==0 & strcmp(pvget(z,'Domain'),'Frequency')
        error('You cannot have time-series models and frequency domain data.')
    end
    if length(una)==0 & m==inf
        error(sprintf(['For a time series model, there must be a finite prediction horizon.' ...
                '\n(The argument M must be less than inf.)']))
    end
    
    yni = ynam(find(ismember(ynam,yna)));
    uni = unam(find(ismember(unam,una)));
    if isempty(yni)
        warning(sprintf(['All outputs required for model ',sysname{ksys},...
                ' are missing in the data set.\nPlease check output names',...
                ' for data and this model.']))
        yh{ksys}=[];
        fit(:,ksys,:)=inf;
    else
        if length(yni)~=length(yna) | length(uni)~=length(una)% not all model channels present in data
            % th = pvset(th,'CovarianceMatrix',[]);
            if isempty(uni),uni=[];end
            th = th(yni,uni);
            if length(yni)~=length(yna) & ~isinf(m)
                warning(sprintf(['Some outputs required for the predictions of model ',sysname{ksys},...
                        '\nare missing in the data set. These will ignored.']))
            end
            if length(uni)~=length(una) 
                if isempty(uni)
                    utxt = 'All';
                    etxt = 'Please check input names for this model and the data.';
                else
                    utxt = 'Some';
                    etxt = [];
                end
                warning(sprintf([utxt,' inputs required for model ',sysname{ksys},...
                        ' are missing in the data set.\nThese will ignored. ',etxt]))
            end
        end
        
        z1 = z(:,yni,uni); 
        th = th(yni,uni);
        %         inpd = th.InputDelay; 
        %         if init == 'e' & sum(inpd)>0 % To allow also inputdelays to be estimated
        %             th = idss(th);
        %             th = pvset(th,'nk',inpd'+1);
        %             th.Inputdelay = zeros(size(inpd));
        %         end
        [Nt,nty,ntu] = size(z1);
        simdone = 0;
        init=lower(init(1));
        if init=='e'
            if any(pvget(th,'InputDelay')>0)
                ts = pvget(z1,'Ts');
                int = pvget(z1,'InterSample');
                %tss = unique(cat(1,ts{:}));
                for kexp=1:Ne
                    tss=ts{kexp};
                    if th.Ts==0
                    ths = c2d(th,tss,int{1,kexp});
                else
                    ths = th;
                end
                    ths = inpd2nk(ths);
                    init1 = init;
                    if isinf(m), 
                        init1 = 'oe';
                    end
                    try
                    [e,xi]=pe(getexp(z1,kexp),ths,init1);
                catch
                    error(lasterr)
                end
                    if m==inf,
                        yhh{kexp}=sim(ths,getexp(z1(:,[],:),kexp),xi);
                    else 
                        yhh{kexp}=predict(getexp(z1,kexp),ths,m,xi);
                    end
                end
                yh{ksys}=merge(yhh{:});
                simdone = 1;
            else
                
                % This would be the place to do c2d, idss, nk, udel etc
                % if the different data exp have different Ts then loop and
                % construct yhh{kexp},
                init1 = init;
                if isinf(m), 
                    init1 = 'oe';
                end
                try
                [e,xi]=pe(z1,th,init1);
            catch
                error(lasterr)
            end
            end   
        elseif init=='z'
            xi=init;%zeros(nx,1);
        elseif init=='m'
            xi=[];
        else
            [nxr,nxc]=size(xi);
            if nxr<nxc 
                xi=xi.';
                nxr=nxc;
            end
            if nxr~=nx
                error(['The size of the initial state must be ',int2str(nx)])
            end
        end  
        if ~simdone
            if m==inf,
                yh{ksys}=sim(th,z1(:,[],:),xi);
            else 
                yh{ksys}=predict(z1,th,m,xi);
            end
        end
        yhh = pvget(yh{ksys},'OutputData');
        yhnam = pvget(yh{ksys},'OutputName');
        sampc = pvget(yh{ksys},'SamplingInstants');
        for kexp=1:Ne
            %{kexp};
            samp =sampc{kexp};%(nr{kexp});
            sampi = find(samp>=timebeg{kexp}&samp<=timeend{kexp});
            samp = samp(sampi);
            datsamp = sampdata{kexp};
            datsampi = find(datsamp>=min(samp)&datsamp<=max(samp)+0.00001/max(samp));
            for ky=1:ny
                kyy = find(strcmp(ynam{ky},yhnam));
                if ~isempty(kyy)
                    
                    err=norm(yhh{kexp}(sampi,kyy)-y{kexp}(datsampi,ky));
                    meanerr=norm(y{kexp}(datsampi,ky)-mean(y{kexp}(datsampi,ky)));
                    fit(kexp,ksys,ky) = 100*(1-err/meanerr);
                else
                    fit(kexp,ksys,ky) = inf;
                end
            end
        end
        adv = getadv(sys{ksys});
        samedat = 0;
        try
            fitadv = adv.compare.fit;
            if dataid == adv.compare.DataId;
                samedat = 1;
            end
        catch
            fitavd = [];
        end
        fff = squeeze(fit(:,ksys,:));
        if ~samedat % If not the same data as for previous fit, delete old info
            adv.compare.DataId = dataid;
            
            adv.compare.fit =[m*ones(size(fff)), fff];
        else
            fitadv = [fitadv;[m*ones(size(fff)),fff]];
            adv.compare.fit = fitadv;
        end
    end
    % also pred horizon
    ut = pvget(sys{ksys},'Utility');
    ut.advice = adv;
    th = uset(sys{ksys},ut);
    try
        assignin('caller',sysname{ksys},th);
    end
end % if notempty yni
%end % end of calculations
if ~no
    % Plotting. First check if all outputs shall be plotted:
    if chansel
        yshow = [];
        for kch = 1:length(ychan)
            ynumb = find(strcmp(ychan{kch},ynam));
            if isempty(ynumb)
                warning(['Output ',ychan{kch},' is not found in the data.'])
            end
            yshow = [yshow,ynumb];
        end
        ny = length(yshow);
    else
        yshow = [1:ny];
    end
    if ny == 0
        return
    end
    newplot
    for kexp = 1:Ne
        subplot(ny,1,1)
        if Ne>1
            exptext = [z.ExperimentName{kexp},': '];
        else
            exptext = [];
        end
        %{kexp};
        sampdat = sampdata{kexp}(nr{kexp});
        kyy = 1; %counting the subplots
        for ky=yshow%1:ny
            subplot(ny,1,kyy)
            color=get(0,'BlackandWhite');
            yplot=y{kexp}(nr{kexp},ky);
            if ~realflag
                yplot=abs(yplot);
            end
            if color(1:2)=='of', 
                plot(sampdat,yplot,'k'),
                if ~realflag
                    ylab = ['abs(',ynam{ky},')'];
                    
                else
                    ylab = ynam{ky};
                end
                ylabel(ylab) 
            else 
                plot(sampdat,yplot,'--'),
            end
            if isinf(m)
                txt='Simulated';
            else
                txt = [int2str(m),'-step Ahead Predicted'];
            end
            if kyy==1
                if frdflag
                    title([exptext,'Frequency Functions.'])
                else
                    title([exptext,'Measured Output and ',txt,' Model Output'])
                end
            end
            if frdflag
                if isempty(inpn{1})
                    frdtxt = ['Given Function'];
                else
                    frdtxt = ['Function ',inpn{1}];
                end
                legtext{kyy,1} = frdtxt;
            else
                legtext{kyy,1}='Measured Output';
            end
            hold on
            kyy = kyy+1;
        end % of y-plots
        
        actsys = 0;% number of systems actually shown
        for ksys = 1:nsys
            if ~isempty(yh{ksys})
                yhh = pvget(yh{ksys},'OutputData');
                yhnam = pvget(yh{ksys},'OutputName');
                sampc = pvget(yh{ksys},'SamplingInstants');%{kexp};
                samp =sampc{kexp};%(nr{kexp});
                sampi = find(samp>=timebeg{kexp}&samp<=timeend{kexp});
                samp = samp(sampi);
                actsys = actsys+1;
            else
                yhh=[];
            end
            kyyc = 0;
            for ky = yshow%1:ny
                kyyc = kyyc+1;
                if ~isempty(yhh);
                    subplot(ny,1,kyyc)
                    kyy = find(strcmp(ynam{ky},yhnam));
                    if ~isempty(kyy)
                        if isempty(PlotStyle{ksys})
                            PStyle=[colord(mod(ksys-1,6)+1),'-'];
                        else
                            PStyle=PlotStyle{ksys};
                        end
                        %subplot(ny,1,ky)
                        color=get(0,'BlackandWhite');
                        yplot = yhh{kexp}(sampi,kyy);
                        if ~realflag
                            yplot = abs(yplot);
                        end
                        if color(1:2)=='of', 
                            plot(samp,yplot,PStyle),
                        else 
                            plot(samp,yplot,'-'),
                        end
                        if frdflag
                            set(gca,'xscale','log','yscale','log')
                        end
                    end
                end %notempty yhh
                legtext{kyyc,ksys+1}=[sysname{ksys},' Fit: ',sprintf('%0.4g',fit(kexp,ksys,ky)),'%'];
                
                if ksys==nsys, 
                    set(gca,'NextPlot','replace'); 
                    mods = find(~isinf(fit(kexp,:,ky)));
                    legend(legtext{kyyc,[1,1+mods]},-1);
                    %if kexp~=Ne,pause,end
                end
            end%  for ky        
        end  % for ksys
        if kexp~=Ne,pause,end
    end % for kexp
    hold off
    subplot(111)
    set(gca,'NextPlot','replace');
    set(gcf,'NextPlot','replace')
else% if no
    yh1 = yh;
    fit1 = fit;
end



