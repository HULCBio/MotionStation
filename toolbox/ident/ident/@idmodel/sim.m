function [y,ysd] = sim(data,thmod,init,inhib)
%SIM  Simulates a given dynamic system.
%   Y = SIM(MODEL,UE)
%
%   MODEL: contains the parameters of the model in  any of the IDMODEL
%   formats, IDSS, IDPOLY, IDARX, IDGREY or IDPROC.
%
%   UE: the input-noise data UE = [U E]. Here U is the input data, that
%   could be given as an IDDATA object (with the signal defined as input)
%   or as a matrix U = [U1 U2 ..Un] with the column vector Uk as the k:th
%   input. Similarly, E is either an IDDATA object or a matrix of noise
%   inputs (as many columns as there are output channels). If E is omitted
%   a noise-free simulation is obtained.
%
%   Example: U = iddata([],idinput(200),'Ts',0.1); 
%            E = iddata([],randn(200,1),'Ts',0.1); Y = SIM(MODEL,[U E]);
%
%   The noise contribution is scaled by the variance information con-
%   tained in MODEL (that is, MODEL.NoiseVariance). This means that E should
%   be white noise with unit covariance matrix to obtain the correct noise 
%   contribution according to the model.
%
%   Y: The simulated output. If UE is an IDDATA object, Y is also 
%   delivered as an IDDATA object, otherwise as a matrix, whose k:th
%   column is the k:th output channel.
%
%   If UE is a multiple experiment IDDATA object, so will Y be.
%
%   If MODEL is continuous time, it is first sampled according to the 
%   information in the input UE which then must be an IDDATA object,
%   ('Ts' and 'InterSample' properties). For discrete time models the
%   intersample data properties are ignored, and the returned Y has the same
%   sampling interval as UE, regardless of the model's sampling interval.
%
%   If UE is a frequency domain IDDATA object, the simulation is performed in
%   the frequency domain and Y is returned as a frequency domain IDDATA object.
%   If UE is continuous time frequency domain data, the MODEL should also be
%   continuous time. Bandlimited frequency domain data is treated as
%   continuous time data in the simulation.
%
%   With  [Y,YSD] = SIM(MODEL,UE)  the estimated standard deviation of the
%   simulated output, YSD, is also computed. YSD is of the same format as Y.
%   See also IDMODEL/SIMSD for a Monte Carlo method to compute the standard
%   deviation.
%
%   Y = SIM(MODEL,UE,INIT) gives access to the initial state:
%       INIT = 'm' (default) uses the model's initial state.
%       INIT = 'z' uses zero initial conditions.
%       INIT = X0 (column vector). Uses X0 as the initial state.
%            For multiexperiment data UE, X0 may have as many columns as 
%            there are experiments to allow for different initial conditions.
%
%   See also IDINPUT, IDMODEL for input generation and model creation
%   and COMPARE, PREDICT for model evaluation.

%   L. Ljung 10-1-86, 9-9-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.24.4.2 $  $Date: 2004/04/10 23:17:40 $

if nargin < 2
    disp('Usage: Y = SIM(MODEL,DATA)')
    disp('       [Y,YSD] = SIM(MODEL,DATA,INIT)')
    return
end

y=[];ysd=[];

if nargin < 4, inhib = 0;end
if nargin<3,init=[];end % Inhib = 1 is a call from the GUI

if isa(data,'idmodel') % Forgive order
    data1 = thmod;
    thmod = data;
    data = data1;
end
if isnan(thmod)
    error('Model contains NaN-parameters and cannot be simulated.')
end
if nargout<2
    thmod = pvset(thmod,'CovarianceMatrix','None'); % To avoid extra calculations
end
% First check data sizes
if isa(data,'iddata')
    [N,nyd,nud,Nexp] = size(data);
    if ~isreal(thmod);
        if realdata(data)&strcmp(pvget(data,'Domain'),'Frequency')
            warning(sprintf(['You have a complex model and an input that is real in the time domain,\n',...
                    'To build an output-input data set you must do [y, complex(u)];']))
            data = complex(data); % To handle simulation of complex model with real FD data.
        end
    end
       
else
    nud = size(data,2);
end
[ny,nu] = size(thmod);
enableE = 0;
if nu~=nud,
    if nud == nu + ny,
        enableE = 1;
    else
        error(sprintf(['Data and model sizes are incompatible.',...
                '\nTo simulate without noise, UE should have %d inputs, and',...
                '\nfor a simulation with noise, UE should have %d inputs.'],nu,nu+ny))
    end
end

if isempty(init), init = 'm'; end
if iscell(init)
    error('INIT should either be a string (''m'',''z'') or a column vector or a matrix.')
end
if ischar(init),
    init = lower(init(1)); 
    if init == 'e'
        error('Init = ''e'' is not an option for SIM.')
    end
end
if isa(data,'iddata')
    dom = pvget(data,'Domain');
else
    dom = 'Time';
end
dom = lower(dom(1));
Tdflag = 0; diffTd = 0;
T=pvget(thmod,'Ts');
if T==0
    if ~isa(data,'iddata')
        ttes = pvget(thmod,'Utility'); % This is really to honor old syntax
        try
            Td = ttes.Tsdata; method = 'z';
            if Td == 0, Td=1;end
        catch
            error(sprintf(['  For a continuous time model the input data must be ',...
                    'given as an IDDATA object.\n  Use U = iddata([],u,Ts).']))
        end
        th{1} = c2d(thmod,Td,'zoh');
    else
        Tdcc = pvget(data,'Ts');
        inters = pvget(data,'InterSample');
        if isempty(inters)
            error('The IDDATA set must contain an input signal.')
        end
        Intu = unique(inters);
        Tdc = unique(cat(1,Tdcc{:})); 
        if length(Tdc)==1&length(Intu)==1
            ints = Intu{1};
            if Tdc>0&~(strcmp(ints,'bl')&dom=='f')
                % For a BL discrete time FD data set no sampling should be done
                if strcmp(ints,'bl')
                    warning(sprintf(['You have Band Limited Input Data in the time domain.',...
                            '\nTo take advantage of this you should do the simulation in the frequency domain:',...
                            '\n   Y = IFFT(SIM(Model,FFT(UE));',...
                            '\nNow the model is sampled according to first order hold.']))
                    ints = 'foh';
                end
                th{1} = c2d(thmod,Tdc,ints);
            else
                th{1} = thmod;
            end
        else
            for kt = 1:length(Tdcc)
                ints = inters{1,kt};
                if Tdcc{kt}>0&~(strcmp(ints,'bl')&dom=='f')
                    % For a BL discrete time FD data set no sampling should be done
                    if strcmp(ints,'bl')
                        warning(sprintf(['You have Band Limited Input Data in the time domain.',...
                                '\nTo take advantage of this you should do the simulation in the frequency domain:',...
                                '\nY = IFFT(SIM(Model,FFT(UE));',...
                                '\nNow the model is sampled according to first order hold.']))
                        ints = 'foh';
                    end
                    th{kt} = c2d(thmod,Tdcc{kt},ints); % same intersample in all inputs
                else
                    th{kt} = thmod;
                end
            end
        end
    end
else % Discrete time model
    % if some data data set is cont time transform?
    th = {thmod};
    if isa(data,'iddata')
        Tdc = pvget(data,'Ts'); Td = cat(1,Tdc{:});
        if any(abs(Td-T)>10*eps)
            warning(sprintf([' The data and model sampling intervals are '...
                    'different.\nThe data sampling interval will be used.']))
            if any(Td==0)
                error(sprintf(['You have supplied a discrete time model '...
                        'and a continuous time data set.',...
                        '\nThe model should in that case be given in continuous time.']))
            end
        end
    end
end

[a,b,c,d,k,x0]=ssdata(th{1});
LAM=pvget(th{1},'NoiseVariance');
adv = pvget(th{1},'Advanced');
if dom=='t'
if pvget(th{1},'Ts')==0
    if max(real(eig(a)))>adv.Threshold.Sstability
        warning(' System unstable.')
    end
else
    stablim = adv.Threshold.Zstability;
    if max(abs(eig(a)))>stablim, 
        warning(' System unstable.'),
    end
end
end
for kt = 1:length(th)
    Inpd{kt} = pvget(th{kt},'InputDelay')'; 
end
[ny,n]=size(c);
[n,nu]=size(b);
if isa(data,'iddata')
    
    iddatflag = 1;
    if any(cat(1,Inpd{:})~=0)  
        if enableE
            for kexp = 1:length(Inpd)
                Inpd{kexp} = [Inpd{kexp},zeros(ny,1)];
            end
        end
        data = nkshift(data,Inpd,'append');  % This works for CT too in the FD
    end
    zee = pvget(data,'InputData');
    fre = pvget(data,'Radfreqs');
else
    iddatflag= 0;
    zee = {data};
    if iscell(Inpd)
        Inpd=Inpd{1};
    end
    if norm(Inpd)>eps
        if ~inhib
            warning(['The model''s InputDelay can be handled only if',...
                    ' the data is an IDDATA object.']);
        else
            [Ncap,nudum] = size(data);
            nk1 = Inpd;
            Ncc = min([Ncap,Ncap+min(nk1)]);
            for ku = 1:length(nk1)
                u1 = data(max([nk1,0])-nk1(ku)+1:Ncc-nk1(ku),ku);
                newsamp = Ncap-length(u1);
                if nk1(ku)>0
                    u1= [zeros(newsamp,1);u1];
                else
                    u1 = [u1;zeros(newsamp,1)];
                end
                data(:,ku) = u1;
            end
        end
    end
    zee = {data};
end
Ne = length(zee);


for kexp=1:Ne
    if length(th)>1
        [a,b,c,d,k,x0]=ssdata(th{kexp});
        LAM=pvget(th{kexp},'NoiseVariance');
        th1 = th{kexp};
    else
        th1 = th{1};
    end
    tsmod = pvget(th1,'Ts');
    ze = zee{kexp};
    [Ncap,nze]=size(ze); 
    if ~any(nze==[nu nu+ny])
        error('An incorrect number of inputs/noises have been specified!')
    end
    if ~strcmp(lower(init(1)),'m') ,
        if strcmp(lower(init(1)),'z')
            x0 = zeros(n,1);
        else
            [nxr,nxc] = size(init);  
            if nxr~=n,
                error(['The number of rows of the initial state must be ',int2str(n)])
            end
            if nxc~=1 & nxc~=Ne
                error(sprintf(['When the initial state has been specified, the number'...
                        '\nof columns must either be 1 or the number of experiments.']))
            end
            if nxc>1
                x0 = init(:,kexp);
            else
                x0 = init;
            end
        end
        
    end
    if nze==ny+nu,
        sqrlam=sqrtm(LAM);
        b = [b k*sqrlam];
        d = [d sqrlam];
    end
    if dom=='t' 
        x=ltitr(a,[b],[ze],x0);
        yc{kexp}=(c*x.' +[d]*[ze].').';
    else
        if tsmod == 0
            frejust = i*fre{kexp};
        else
            if iscell(Tdc),Tdf = Tdc{kexp};else Tdf = Tdcc{kexp};end
            frejust = exp(i*fre{kexp}*Tdf);
        end
        xh=freqkern(a,[b x0],[ze,frejust],frejust);
        yc{kexp}=(c*xh+d*ze.').';
    end
    y = yc{kexp};
    
    if nargout>1
        if dom=='f'
            warning('No covariance Information for Frequency Domain Data')
        end
        ysd = [];
        nue = size(ze,2);
        mbb = idpolget(th1);
        if ~isempty(mbb)
            if ~isempty(pvget(mbb{1},'CovarianceMatrix'))
                for kk = 1:length(mbb)
                    mb = mbb{kk}(:,1:nue);  
                    temp = idsimcov(mb,ze,y(:,kk));
                    if ~isempty(temp)
                        ysd(:,kk) = temp;
                    end
                end
            end
            ysdc{kexp} = ysd;
        else
            ysdc{kexp} = [];
        end
    end
end % kexp
if iddatflag
    una = pvget(data,'InputName');
    unam = pvget(thmod,'InputName');
    war = 0;
    for ku = 1:length(unam);
        if ~strcmp(una{ku},unam{ku})
            war = 1;
        end
    end
    if war
        warning('The InputNames of the data and the model do not coincide.')
    end
    y = data;
    y = pvset(y,'OutputData',yc,'InputData',[],'OutputName',pvget(thmod,'OutputName'),...
        'OutputUnit',pvget(thmod,'OutputUnit'));
    if nargout>1
        if isempty(ysdc{1})
            ysd = [];
        else
            ysd = data;
            ysd= pvset(ysd,'OutputData',ysdc,'InputData',[],'OutputName',pvget(thmod,'OutputName'),...
                'OutputUnit',pvget(thmod,'OutputUnit'));
        end
    end
else % no iddata
    y = yc{1};
    if nargout>1
        if isempty(ysdc{1})
            ysd = [];
        else
            ysd = ysdc{1};
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 