function [el,xic,rmzflag]=pe(m,data,init,residcall,guicall)
%PE Computes prediction errors.
%   E = PE(Model,DATA)
%   [E,X0e] = PE(Model,DATA,INIT)
%
%   E : The prediction errors. An IDDATA object, with E.OutputData 
%       containing the errors.
%   DATA : The output-input data as an IDDATA object. (See help IDDATA)
%   Model: The model as any IDMODEL object, IDPOLY, IDSS, IDARX or IDGREY.
%   INIT: The initialization strategy: one of
% 	    'e': Estimate initial state so that the norm of E is minimized
%	         This state is returned as X0e.
%       'd': Same as 'e', but if Model.InputDelay is non-zero, these delays
%            are first converted to explicit model delays, so that the are
%            contained in X0e.
%	    'z': Take the initial state as zero
%	    'm': Use the model's internal initial state.
%       X0: a column vector of appropriate length to be used as
%           initial value, for multiexperiment DATA X0 may be a matrix
%           with columns giving the initial states for each experiment.
%   If INIT is not specified, Model.InitialState is used, so that
%      'Estimate', 'Backcast' and 'Auto' gives an estimated initial state,
%      while 'Zero' gives 'z' and 'Fixed' gives 'm'.
%
%   [E,X0e] = PE(Model,DATA) returns the used initial state X0. If DATA contains
%      multiple experiments, X0e is a matrix with the columns containing the 
%      initial states for each experiment.
%

%	L. Ljung 10-1-86,2-11-91
%	Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.30.4.2 $  $Date: 2004/04/10 23:19:11 $


rmzflag = 0; %This is intended for pe_f and used in  idgenfig
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
if nargin < 5
    guicall = 0; % Guicall allows inputdelays even for non iddata
end
if nargin < 4
    residcall = 0; % Residcall makes the returned E a matrix with
    % the possibly different experiments concatenated.
end
if nargin<3
    init = [];
end
if isa(data,'frd'), data = idfrd(data);end
if isa(data,'idfrd'), data = iddata(data);end
if strcmp(init,'oe') % This is for a special call from compare
    if (isa(data,'iddata')&strcmp(pvget(data,'Domain'),'Frequency'))
        init = 'o';
        killK = 1;
    else
    init = 'e';
    killK = 1;
end
else
    killK = 0;
end
setinit = 1;
if isempty(init)
    setinit = 0;
    if isa(m,'idarx')
        init='z';
    else
        init=pvget(m,'InitialState');
    end
    init=lower(init(1));
    if init=='d'
        inpd= pvget(m,'InputDelay');
        if norm(inpd)==0
            init = 'e';
        end
    end
    if init=='a'|init=='b',
        init='e';
    elseif init=='f'|init=='n'
        init = 'm';   
    end
elseif ischar(init)
    init=lower(init(1));
    if ~any(strcmp(init,{'m','z','e','d','o'}))
        error('Init must be one of ''E(stimate)'', ''Z(ero)'', ''M(odel)'', ''D(elayconvert)'', or a vector.')
    end
    
end
frdflag = 0;
try
    ut = pvget(data,'Utility');
    if ut.idfrd
        frdflag = 1;
    end
end
if frdflag
    if setinit&init(1)~='z'
        warning(sprintf(['Data do not support estimation of initial states.',...
                '\nInit has been set to ''Zero''.']))
    end
    init = 'z';
end
%% Now init is either a vector or the values 'e', 'm', 'z','d'.

if isa(data,'iddata')
    dom = pvget(data,'Domain');
else
    dom = 'Time';
end
if lower(dom(1))=='f'
    m = pvset(m,'CovarianceMatrix',[]);
    if ~isa(m,'idproc') % this is not to destroy sampling
        m = idss(m);
    end
    [el,xic,rmzflag] = pe_f(m,data,init,residcall);
    return
end
Ts = pvget(m,'Ts');
if Ts == 0
    if killK % This can also happen to state space models, calls from Compare
        if isa(m,'idss')
        ks = pvget(m,'Ks');
        m = pvset(m,'K',zeros(size(ks))); %%LL was Ks
    elseif strcmp(class(m),'idgrey') % idproc has a problem with varying dimensions of K
        m = pvset(m,'DisturbanceModel','None');
    end
    end
    if ~isa(data,'iddata')
        error('Data must be an iddata object for continuous time models.')
    end
    Inpd = pvget(m,'InputDelay');
    
    y = pvget(data,'OutputData');
    [yh,xic] = predict(data,m,1,init);  
    yyh = pvget(yh,'OutputData');
    for kexp = 1:length(yyh)
        e{kexp} = y{kexp}-yyh{kexp};
    end
    if residcall
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
    return
end
Inpd = pvget(m,'InputDelay');
if isa(data,'iddata')
    data = nkshift(data,Inpd,'append');
    [ze,Ne,ny,nu,Ts,Name,Ncaps,errflag] = idprep(data,0,'dummy');
    % warn above for different sampling intevals
    iddatflag = 1;
else
    if norm(Inpd)>eps
        if ~iscell(data)&~guicall % The latter to supress in calls from ARX etc
            warning(['The model''s InputDelay can be handled only if',...
                    ' the data is an IDDATA object.']);
        end
        if guicall % we do the shift anyway
            [Ncap,nudum] = size(data);
            nk1 = Inpd';
            ny = nudum - length(nk1);
            Ncc = min([Ncap,Ncap+min(nk1)]);
            for ku = 1:length(nk1)
                u1 = data(max([nk1,0])-nk1(ku)+1:Ncc-nk1(ku),ny+ku);
                newsamp = Ncap-length(u1);
                if nk1(ku)>0
                    u1= [zeros(newsamp,1);u1];
                else
                    u1 = [u1;zeros(newsamp,1)];
                end
                data(:,ny+ku) = u1;
            end
        end
    end
    iddatflag= 0;
    if ~iscell(data)
        ze = {data};
    else
        ze = data;
    end
    
    Ncaps(1) = size(data,1);
    Ts =[];
    Ne = 1;
end


alg=pvget(m,'Algorithm');
maxsize=alg.MaxSize;

[A,B,C,D,K,X0]=ssdata(m);
if killK
    K = zeros(size(K));
end
nx=length(A);
if isstr(maxsize)
    maxsize = idmsize(length(ze{1}),nx);
end

AKC=A-K*C;
[ny,nx]=size(C);
nu=size(B,2);
el=zeros(0,ny);
xic = zeros(nx,0);
Ne = length(ze);
for kexp = 1:Ne
    z = ze{kexp};
    [Ncap,nz]=size(z);
    if nu+ny~=nz, 
        error(sprintf(['Incorrect number of data columns specified.',...
                '\nShould be equal to the sum of the number of inputs',...
                '\nand the number of outputs.']))
    end
    
    if strcmp(init,'e')
        nz=ny+nu;[Ncap,dum]=size(z);n=nx;
        rowmax=nx+nz;X0=zeros(nx,1);
        M=floor(maxsize/rowmax);
        if ny>1|M<Ncap
            R=zeros(n,n);Fcap=zeros(n,1);R1=[];
            for kc=1:M:Ncap
                jj=(kc:min(Ncap,kc-1+M));
                if jj(length(jj))<Ncap,jjz=[jj,jj(length(jj))+1];else jjz=jj;end
                psitemp=zeros(length(jj),ny);
                psi=zeros(ny*length(jj),n);
                x=ltitr(AKC,[K B-K*D],z(jjz,:),X0); 
                yh=(C*x(1:length(jj),:).').'; 
                sqrlam=pinv(sqrtm(pvget(m,'NoiseVariance'))); 
                if ~isempty(D),yh=yh+(D*z(jj,ny+1:ny+nu).').';end
                
                e=(z(jj,1:ny)-yh)*sqrlam;
                [nxr,nxc]=size(x);X0=x(nxr,:).';
                evec=e(:);
                kl=1;
                for kx=1:nx
                    if kc==1
                        x0dum=zeros(nx,1);x0dum(kx,1)=1;
                    else
                        x0dum=X00(:,kl);
                    end
                    psix=ltitr(AKC,zeros(nx,1),zeros(length(jjz),1),x0dum);
                    [rp,cp]=size(psix);
                    X00(:,kl)=psix(rp,:).';
                    psitemp=(C*psix(1:length(jj),:).').'*sqrlam;
                    psi(:,kl)=psitemp(:);kl=kl+1;   
                end
                if ~isempty(R1)
                    if size(R1,1)<n+1
                        error('Too small value of MaxSize to estimate the initial state.')
                    end
                    R1=R1(1:n+1,:);end 
                H1=[R1;[psi,evec] ];R1=triu(qr(H1));   
                
            end
            try
                xi=pinv(R1(1:n,1:n))*R1(1:n,n+1);  
            catch
                warning(sprintf(['Failed to estimate initial conditions.',...
                        '\nCheck model stability.',...
                        '\nX0 has been set to zero.']))
                xi = zeros(n,1);
            end
        else
            %% First estimate new value of xi
            x=ltitr(AKC,[K B-K*D],z); 
            y0=x*C';
            if ~isempty(D),
                y0=y0+(D*z(:,ny+1:ny+nu).').';
            end
            psix0=ltitr(AKC.',C.',[1;zeros(Ncap,1)]);
            psix0=psix0(2:end,:);
            try
                xi=pinv(psix0)*(z(:,1)-y0); 
            catch
                warning(sprintf(['Failed to estimate initial conditions.',...
                        '\nCheck model stability.',...
                        '\nX0 has been set to zero.']))
                xi = zeros(n,1);
            end
        end
    elseif strcmp(init,'z')
        xi=zeros(nx,1);  
    elseif strcmp(init,'m')
        xi=X0;
    else % the vector case  
        xii = init;
        [nrxi,ncxi]=size(xii);
        if ncxi~=1 & ncxi~=Ne
            error(sprintf(['When the initial state is specified, the number of columns'...
                    '\nmust either be 1 or the number of experiments.']))
        end
        
        if nrxi~=nx,
            error(['The length of the initial state must be ',int2str(nx)]);
        end
        if ncxi==1
            xi = xii;
        else
            xi = xii(:,kexp);
        end
    end
    xic = [xic,xi];
    x=ltitr(AKC,[K B-K*D],z,xi);
    if any(any(isnan(x)'))
        error(sprintf(['Failed to compute prediction errors.',...
                '\nPredictor model probably too unstable.']))
    end
    e=z(:,1:ny)-(C*x.').';
    if ~isempty(D)
        e=e-(D*z(:,ny+1:ny+nu).').';
    end
    el =[el;e];
    ec{kexp} = e;
end
if iddatflag&~residcall
    el = data;
    yna = pvget(data,'OutputName');
    npr = noiprefi('e');
    for ky = 1:ny
        yna{ky}=[npr,yna{ky}];
    end
    el = pvset(el,'OutputData',ec,'InputData',[],'OutputName',yna);
end

