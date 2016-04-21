function [V,Vt,psi,e,Nobs] = gnnew_fp(z,par,struc,algorithm,oeflag)
%GNNEW Computes The Gauss-Newton search direction

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2004/04/10 23:18:30 $

if nargin < 5
    oeflag = 0; % marks that e should be whitened, and psi filtered accordingly
end
if nargout==2
    [V,Vt] = gnx(z,par,struc,algorithm,oeflag);
else
    [V,Vt,psi,e,Nobs] = gnx(z,par,struc,algorithm,oeflag); 
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,nobs]=gnx(ze,par,nn,algorithm,oeflag)
%GN     Computes the Gauss-Newton direction for PE-criteria
%
%   [G,R] = gn(Z,TH,LIM,MAXSIZE,INDEX)
%
%   G : The Gauss-Newton direction
%   R : The Hessian of the criterion (using the GN-approximation)
%
%   The routine is intended primarily as a subroutine to MINCRIT.
%   See PEM for an explanation of arguments.


% *** Set up the model orders ***
realflag = nn.realflag;
back = 0;
if strcmp(lower(nn.init(1)),'b')
    back = 1;
end

if ~iscell(ze)
    ze = {ze};
end

lamtrue = inf;
V=inf;
R=[];
Re=[];
lim = algorithm.LimitError;
maxsize=algorithm.MaxSize;
index = algorithm.estindex;
stablim = algorithm.Advanced.Threshold.Zstability;
stablimc = algorithm.Advanced.Threshold.Sstability;
stab = 0;
if ischar(algorithm.Focus)&any(strcmp(algorithm.Focus,{'Stability','Simulation'}));
    stab = 1;
end
nu=nn.nu;na=nn.na;nb=nn.nb;nc=nn.nc;nd=nn.nd;nf=nn.nf;nk=nn.nk;
Ts = nn.T;
T = Ts;
n=sum(nb)+sum(nf);

if Ts== 0, nk = zeros(1,nu);end
b=zeros(nu,max(nb+nk));nfm=max(nf);f=zeros(nu,nfm+1);
if nu>0
    for ku=1:nu
        if Ts>0
            b(ku,nk(ku)+1:nk(ku)+nb(ku))=par(nn.nbi{ku}).'; %%%
            f(ku,1:nf(ku)+1)=[1 par(nn.nfi{ku}).'];
        else
            b(ku,max(nb)-nb(ku)+1:end) = par(nn.nbi{ku}).';
            f(ku,max(nf)-nf(ku)+1:end) = [1 par(nn.nfi{ku}).'];
        end
        if nf(ku)>0
            if Ts >0
                fst(ku)=max(abs(roots(f(ku,:))));
            else
                fst(ku) = max(real(roots(f(ku,:))));
            end
        else 
            fst(ku)=0;
        end
    end
    if stab
        if (Ts>0&max(fst)>stablim)|(Ts==0&max(real(fst))>stablimc), %TC stablim
            V=inf;grad=[];R=[];Re=[];lamtrue=V;nobs=1;
            return
        end
    end
end

nmax=max([nb+nk-ones(1,nu) nf]);
n1=sum(nb);n2=sum(nb)+sum(nf);
[nu,dum]=size(b);
nbb=max(nb+nk+1);
nm=max([na+nf,nb+nk-1]);
if back
    nxx = max(nf,nb+nk-ones(size(nk)));
    nx = sum(nxx);
    nm = nx;%max([sum(nf),nb+nk-1]);
end

if T>0
    indb=1:nbb-1;indf=1:max(nf)+1;
else
    indb=nbb-1:-1:1;indf=max(nf)+1:-1:1;
end


V = 0; lamtrue = V;
Nobs = 0;
Ne = length(ze);
n1 = length(index);
R1 = zeros(0,n1+1);
M = floor(maxsize/(nm+1));
for kexp = 1:Ne
    z1 = ze{kexp};
    w1 = z1(:,end); 
    Y1 = z1(:,1);
    U1 = z1(:,2:end-1);
    N = size(Y1,1);
    for kM=[1:M:N]
        jj = [kM:min(N,kM-1+M)];
        w = w1(jj);
        Y = Y1(jj,:);
        U = U1(jj,:);
        z = z1(jj,:);
        OM = (w.').^0; %LL T=0
        if T==0
            sgn = 1;
        else
            sgn = -1;
        end
        for kom = 1:nm
            OM = [OM;(w.').^(sgn*kom)];
        end
        if back
            [B0,fb0] = b0est(z,par,nn,realflag,OM);
        end
        % To find the gradient db0dpar:
        % First derivatives wrt A, B and F
        
        Db=[];GC=zeros(size(Y));Df =[];
        % Adjust for backcast input
        nf1 = nf;
        if back
            nk(nu+1) = 1;
            nf1(nu+1) = nx;
            nb(nu+1) = nx;%nf1(nu+1);
            f1 = idextmat(f,fb0,T);
            nu1 = nu+1;
            if T>0
                b0 = [0 B0];
            else
                b0 =B0;
            end
            b1 = idextmat(b,b0,T);
            if T>0 
                indf =  [1:size(f1,2)];
                indb = [1:size(b1,2)];
            else
                indf = [size(f1,2):-1:1];
                indb = [size(b1,2):-1:1];
            end
            U(:,nu+1) =w;%exp(i*w*T);%%LL
        else
            nu1 = nu;
            b1=b;
            f1=f;
        end
        for ku=1:nu1
            if T>0, 
                indtb1=nk(ku)+1:nk(ku)+nb(ku);indtf1=2:nf1(ku)+1;
            else 
                indtb1=nb(ku):-1:1;indtf1=nf1(ku):-1:1;
            end
            %%check if f*OM==0 for OM(1) (common case) and skip that
            GC=GC+(((b1(ku,:)*OM(indb,:))./(f1(ku,:)*OM(indf,:))).').*U(:,ku);
            GC1=(((b1(ku,:)*OM(indb,:))./(f1(ku,:)*OM(indf,:))).').*U(:,ku);
            if ku<=nu
                Df=[Df (OM(indtf1,:).').*((GC1./((f1(ku,:)*...
                        OM(indf,:)).'))*ones(1,nf(ku)))]; 
                Db =[Db -(OM(indtb1,:).').*((U(:,ku))./((f1(ku,:)*...
                        OM(indf,:)).')*ones(1,nb(ku)))];
            else
                db0 =(OM(indtb1,:).').*((U(:,ku))./((f1(ku,:)*...
                    OM(indf,:)).')*ones(1,nb(ku)));
            end
        end
        e=Y-GC;
        V = V +e'*e;
        Nobs = Nobs + length(e);
        if nargout > 2
            de1 = [Db Df];
            if back
                dp = nuderst(par(:)');
                db0dpar = zeros(length(par),length(B0));
                for kp = 1:length(dp)
                    par1=par;
                    par1(kp) = par1(kp)+dp(kp);
                    B01 = b0est(z,par1,nn,realflag,OM);
                    db0dpar(kp,:)=(B01-B0)/dp(kp);
                end
                de1=de1-db0*db0dpar.';%.*(wf*ones(1,n2));
            end %if back
            % *** Prepare for gradients calculations ***
            
            ni=max([nb-2 nf-2 1]);
            
            if oeflag
                de1 = de1.*abs(e*ones(1,size(de1,2))); %%LL OEFLAG
            end
            de1 = de1(:,index);
            if realflag
                R1=triu(qr([R1;[[real(de1);imag(de1)],[-real(e);-imag(e)]]]));
            else
                R1 = triu(qr([R1;[de1,-e]]));
            end
            [nRr,nRc]=size(R1);
            R1=R1(1:min(nRr,nRc),:);
            R=R1(1:n1,1:n1);Re=R1(1:n1,n1+1);
        end % nargout
    end % for kexp
end
V = real(V)/Nobs; %%lamtrue
lamtrue = V*Nobs/(Nobs - length(par));
nobs = Nobs;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [b0,fb0] = b0est(z,par,nn,realflag,OM)
[Ncap,nz]=size(z);
nu=nn.nu;na=nn.na;nb=nn.nb;nc=nn.nc;nd=nn.nd;nf=nn.nf;nk=nn.nk;
nbb=max(nb+nk+1); %was +1
Ts = nn.T;
T = Ts;
n=na+sum(nb)+nc+nd+sum(nf);

w = z(:,end); %% Ne =1
Y = z(:,1);
U = z(:,2:end-1);

a=[1 par(nn.nai).'];c=[1 par(nn.nci).'];d=[1 par(nn.ndi).'];
if Ts== 0, nk = zeros(1,nu);end
b=zeros(nu,max(nb+nk));nfm=max(nf);f=zeros(nu,nfm+1);
if nu>0
    for ku=1:nu
        if Ts>0
            b(ku,nk(ku)+1:nk(ku)+nb(ku))=par(nn.nbi{ku}).'; %% check this for cont time 
            f(ku,1:nf(ku)+1)=[1 par(nn.nfi{ku}).'];
        else
            b(ku,max(nb)-nb(ku)+1:end) = par(nn.nbi{ku}).';
            f(ku,max(nf)-nf(ku)+1:end) = [1 par(nn.nfi{ku}).'];
        end
    end
end
if T>0
    inda=1:na+1;inda1=2:na+1;indb=1:nbb-1;indf=1:max(nf)+1;
else
    inda=na+1:-1:1;inda1=na:-1:1;indb=nbb-1:-1:1;indf=max(nf)+1:-1:1;
end
a1=fstab(a,T);
i=sqrt(-1);
nxx = max(nf,nb+nk-ones(size(nk)));
nx = sum(nxx);
nm = max([nx,nb+nk-1])+1;

% First derivatives wrt A, B and F
%Da=(OM(inda1,:).').*((Y)*ones(1,na));		
Db=[];GC=zeros(size(Y));Df =[];
if T>0
    indb = 1:size(b,2);
else
    indb = size(b,2):-1:1;
end
for ku=1:nu
    %%check if f*OM==0 for OM(1) (common case) and skip that
    GC=GC+(((b(ku,:)*OM(indb,:))./(f(ku,:)*OM(indf,:))).').*U(:,ku);
end
etemp=Y-GC;
nbb0=nx;
fb0 = f(1,:);
for ku=2:nu
    fb0  = conv(fb0,f(ku,:));
end

fb0 = fb0(1:sum(nf)+1);
Ub0 = w; %%
if T>0, 
    indtb1=2:1+nbb0;indtf1=2:sum(nf)+1;
else 
    indtb1=nbb0:-1:1;indtf1=sum(nf):-1:1;
end

Db = -(OM(indtb1,:).').*((Ub0)./((fb0*OM(1:length(fb0),:)).')*ones(1,nbb0)); 
if realflag
    R1=triu(qr([[real(Db);imag(Db)],[real(-etemp);imag(-etemp)]]));
else
    R1 = triu(qr([Db,-etemp]));
end
[nRr,nRc]=size(R1);
R1=R1(1:min(nRr,nRc),:);
%end
nl = nbb0;
R=R1(1:nl,1:nl);Re=R1(1:nl,nl+1);
b0 = (inv(R)*Re).';
