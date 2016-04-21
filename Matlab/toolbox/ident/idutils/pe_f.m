function [el,xic,rmzflag]=pe_f(m,data,init,residcall,realflag)
%PE Computes prediction errors.
%   E = PE(Model,DATA)
%   E = PE(Model,DATA,INIT)
%
%   E : The prediction errors. An IDDATA object, with E.OutputData 
%       containing the errors.
%   DATA : The output-input data as an IDDATA object. (See help IDDATA)
%   Model: The model as any IDMODEL object, IDPOLY, IDSS, IDARX or IDGREY.
%   INIT: The initialization strategy: one of
% 	    'e': Estimate initial state so that the norm of E is minimized
%	         This state is returned as X0, see below.
%       'd': Same as 'e', but if Model.InputDelay is non-zero, these delays
%            are first converted to explicit model delays, so that the are
%            contained in X0.
%	    'z': Take the initial state as zero
%	    'm': Use the model's internal initial state.
%            X0: a column vector of appropriate length to be used as
%                initial value.
%   If INIT is not specified, Model.InitialState is used, so that
%      'Estimate', 'Backcast' and 'Auto' gives an estimated initial state,
%      while 'Zero' gives 'z' and 'Fixed' gives 'm'.
%
%   [E,X0] = PE(Model,DATA) returns the used initial state X0. If DATA contains
%      multiple experiments, X0 is a matrix containing the initial states for
%      each experiment.
%

%	L. Ljung 10-1-86,2-11-91
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.13.4.1 $  $Date: 2004/04/10 23:18:44 $



e1 = [];xic =[];
zi=[];fi=[];
if nargin < 2
    disp('Usage: E = pe(MODEL,DATA);')
    disp('       [E,X0] = pe(MODEL,DATA,INIT);')
    disp(sprintf(['       INIT is one of ''e(stimate)'', ''z(ero)'',',...
            '\n                 or ''m(odel)'', or a vector X0.']))
    return
end
if isa(data,'idmodel')
    m1 = data;
    data = m;
    m = m1;
end

if ~(isa(m,'idss') | isa(m,'idgrey')| isa(m,'idproc'))
    error('Model must be an idss object.')
end


if nargin<5
    realflag = 1;
end
if nargin < 4
    residcall = 0; % Residcall makes the returned E a matrix with
    % the possibly different experiments concatenated.
end
if nargin<3
    init = [];
end
if strcmp(init(1),'o') % This is for a special call from compare
    init = 'e';
    killK = 1;
else
    killK = 0;
end
if isa(data,'iddata')
    realflag = realdata(data);
end
if isempty(init)
    if isa(m,'idarx')
        init='z';
    else
        init=get(m,'InitialState');
    end
    init=lower(init(1));
    
    if init=='a'|init=='b',
        init='e';
    elseif init=='f'|init=='n'
        init = 'm';   
    end
elseif ischar(init)
    init=lower(init(1));
    if ~any(strcmp(init,{'m','z','e','d'}))
        error('Init must be one of ''E(stimate)'',''D(elayconvert)'', ''Z(ero)'', ''M(odel)'' or a vector.')
    end
    
end
%% Now init is either a vector or the values 'e', 'm', 'z' 'd'

[ny,nu] = size(m);
%  inp=m.udel;
 % data = nkshift(data,[0 0 1],'append');
Ts = pvget(m,'Ts');
sample = 0;
[a,b,c,d,k] = ssdata(m);
[nym,num] = size(d);
if ~isa(data,'iddata')
    if ~iscell(data),
        data = {data};
        nexp = 1;
    else
        nexp = length(data);
    end
    for kexp=1:nexp,
        Y{kexp}  = data{kexp}(:,1:ny);
        U{kexp}  = data{kexp}(:,ny+1:ny+nu);
        farg{kexp} = data{kexp}(:,end); %%LL this is TMC!
    end
else
    % first check if integration and frequency zero:
zfflag = 0;
rmzflag = 0;
fre=pvget(data,'SamplingInstants');
for kexp = 1:length(fre)
    if any(fre{kexp}==0)
        zfflag = 1;
    end
end
if zfflag
    was = warning;
    warning off
    fr = freqresp(m,0);
    warning(was)
    if any(isinf(fr))|any(isnan(fr))
        warning(sprintf(['Frequency zero has been removed from the data set',...
                '\nsince the model contains an integration.']));
        rmzflag = 1;
        data = rmzero(data);
    end
end

    [dum,nyd,nud] = size(data);
    if (nyd~=nym)|(nud~=num)
        error('Number of inputs and outputs in data and model do not match.')
    end
    Y =  pvget(data,'OutputData');
    U =  pvget(data,'InputData');
    freq = pvget(data,'Radfreqs');
    Tsdata = pvget(data,'Ts');
    inters = pvget(data,'InterSample');
    
    nexp = length(Y);
    uni = pvget(data,'Tstart');
    
    for kexp = 1:nexp
        picorr = 1;
        if strcmp(uni{kexp},'Hz')
            picorr = 2*pi;
        end
        %if strcmp(inters{1},'bl')|Tsdata{kexp}==0, 
        if Tsdata{kexp}==0
            %BL-Continous time system %%LL modification
            farg{kexp} = i*freq{kexp}*picorr;
        elseif Ts>0,
            if Ts ~= Tsdata{kexp}
                warning(sprintf(['Model''s sampling interval different from data''s',...
                        '\nModel sampling interval is used, but could give misleading result.']))
            end
            farg{kexp} = exp(i*freq{kexp}*Ts*picorr);
        else % cont time model
            farg{kexp} = exp(i*freq{kexp}*Tsdata{kexp}*picorr);
            sample = 1;
        end
    end
end

[nx,nu] = size(b);
ny = size(c,1);

if Ts==0 & ~sample, %Continuous time system
    if init=='e'&~residcall
        warning('No initial state estimate for continuous time data and model.')
    end
    init = 'z'; 
    
else
    if nexp>1 & init=='m',
        init = 'e'; % Estimate instead
    end
end
for kexp=1:nexp,
    N = length(farg{kexp});
    if sample,
        md = c2d(m,Tsdata{kexp},inters{kexp});%%LL was m0 here and below
        [a,b,c,d,k,x0] = ssdata(md);
        [nx,nu] = size(b);
    else
        md = m;
    end
    Inpd = pvget(md,'InputDelay'); % 
    
    if any(Inpd>0)&sum(Inpd)<50&pvget(md,'Ts')>0&init=='d' % This is to extend
        %the initial state for proper Xi
        md = inpd2nk(md);%pvset(md,'InputDelay',zeros(size(Inpd)));
       % md = idss(md);
        %md.nk = [Inpd+1]'; %LL m's own nk should be added
        [a,b,c,d,k]=ssdata(md);
        [nx,nu]=size(b);
    elseif any(Inpd~=0) % SHIFT THE DATA if inputdelay!
        data = nkshift(data,Inpd','append');
         Y =  pvget(data,'OutputData');
    U =  pvget(data,'InputData');
    end
    if killK
        k = zeros(size(k));
    end
   % err  = ssfreqresp(a-k*c,[b-k*d,k],-c,[-d eye(ny)],[U{kexp},Y{kexp}],farg{kexp});
    xerr =  freqkern(a-k*c,[b-k*d,k],[U{kexp},Y{kexp}],farg{kexp});
    err =  -(c*xerr).'+[U{kexp},Y{kexp}]*[-d eye(ny)].';  %(C*Xout).' + U*D.';
    %% Estimate the initial state
    switch init
        case {'e','d'}
            R = zeros(N*ny,nx);
            idx0 = (0:N-1)*ny;
            fd = spdiags(farg{kexp},0,N,N);
            fr = mimofr(a,eye(nx),c,[],farg{kexp});
            if any(any(abs(fr)>1/eps))
                %error('Remove frequency zero from data set, due to the integration in model.')
            end
            for kc=1:ny,
                if nx==1,
                    R(idx0+kc,:) = fd*squeeze(fr(kc,:,:));
                else
                    R(idx0+kc,:) = fd*squeeze(fr(kc,:,:)).';
                end
            end
            H = err.';
            H = H(:);
            
            if realflag
                Rr = [real(R); imag(R)]; 
                Hr = [real(H); imag(H)];
            else
                Rr =R;
                Hr = H;
            end
            X0 = pinv(Rr)*Hr;%Rr\Hr;
            err = H-R*X0;
            err = reshape(err,N,ny);
            try % changing size of nx!
                xic(1:length(X0),kexp) = X0;
            end
        case 'm'
            x0 = pvget(md,'X0');
            xerr = freqkern(a,x0,farg{kexp},farg{kexp});
            err = err - (c*xerr).';
            %err = err - ssfreqresp(a,x0,c,zeros(ny,1),farg{kexp},farg{kexp});
            xic = x0;
        otherwise % Do nothing
    end
    e{kexp} = err;
end

if residcall
    el = e{1};
elseif ~isa(data,'iddata');
    el = e;
else
    el = data;
    yna = pvget(data,'OutputName');
    npr = noiprefi('e');
    for ky = 1:length(yna)
        yna{ky}=[npr,yna{ky}];
    end
    el = pvset(el,'OutputData',e,'InputData',[],'OutputName',yna);
end

