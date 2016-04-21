function [V,Vt,psi,e,Nobs] = gnnew_f(z,par,struc,algorithm,oeflag)
%GNNEW Computes The Gauss-Newton search direction

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2004/04/10 23:18:29 $
if nargin < 5
    oeflag = 0; % marks that e should be whitened, and psi filtered accordingly
end

switch struc.type
    case 'ssnans'
        if nargout==2
            [V,Vt] = gnnans_f(z,par,struc,algorithm,oeflag);
        else
            [V,Vt,psi,e,Nobs] = gnnans_f(z,par,struc,algorithm,oeflag); 
        end
    case 'ssfree'
        if nargout==2
            [V,Vt] = gnfree_f(z,par,struc,algorithm);
        else
            [V,Vt,psi,e,Nobs] = gnfree_f(z,par,struc,algorithm);
        end
    case 'ssgen'
        if nargout==2
            [V,Vt] = gnns_f(z,par,struc,algorithm,oeflag);
        else
            [V,Vt,psi,e,Nobs] = gnns_f(z,par,struc,algorithm,oeflag);
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,Nobs] = gnns_f(ze,par,struc,algorithm, ...
    oeflag);

realflag = struc.realflag;
back = 0;
if strcmp(lower(struc.init(1)),'b')
    back = 1;
end
if ~iscell(ze)
    ze = {ze};
end
V=inf;R=[];Re=[];lamtrue = V;Nobs = [];
maxsize=algorithm.MaxSize;
lim=algorithm.LimitError;
T=struc.modT;
if T==0
    stablim = algorithm.Advanced.Threshold.Sstability;
else
    stablim = algorithm.Advanced.Threshold.Zstability;
end
stab = 0;
if ischar(algorithm.Focus)&any(strcmp(algorithm.Focus,{'Stability','Simulation'}));
    stab = 1;
end

m0=struc.model;
dt=nuderst(par.')/1000;  
try
    dflag = struc.dflag;
catch
    dflag = 0;
end
par1=par;
nkint=[];
zeorig = ze;
if ~isempty(dflag)
    dflag1 = dflag(:,1);
else
    dflag1 = [];
end
if any(dflag1) 
    for kd = 1:length(dflag1)
        dflagg = dflag1(kd);
        pardel = par(dflagg);
        if floor((pardel-dt(dflagg)/2)/struc.modT)~=floor((pardel+dt(dflagg)/2)/struc.modT)
            pardel=pardel+1.1*dt(dflagg); % To avoid numerical derivative over different sample-delays     
        end
        par(dflagg) = pardel;
    end
    par1 = par;
    nu = size(ze{1},2)-3;
    nkint = zeros(1,nu);
    if ~back
        for kd = 1:length(dflag1);
            ku = dflag(kd,2);
            nkint(ku) = floor(par(dflag1(kd))/T);
            par1(dflag1(kd))=par1(dflag1(kd))-nkint(ku)*T;
        end
        for kexp=1:length(ze);
            Fre = ze{kexp}(:,end);
            for ku = 1:size(ze{kexp},2)-3
                ze{kexp}(:,1+ku) =ze{kexp}(:,1+ku).*(Fre.^(-nkint(ku))); %%ku
            end
        end
    end
end
m0=parset(m0,par1);
if ~struc.Tflag,
    m0=pvset(m0,'Ts',T);
end
[A,B,C,D,K,X00] = ssdata(m0);

if T>0&struc.Tflag
    [A,B,Cc,D,K] = idsample(A,B,C,D,K,T,struc.intersample);
end

if any(any(isnan(A)))
    return
end
[nx,nu]=size(B);[ny,nx]=size(C);n=length(par);nz=ny+nu;

try
    ei=eig(A-K*C);
catch
    return
end
if stab
    if T==0,
        if any(real(eig(A))>stablim);
            return
        end
        % when K is is estimated, add tests on eig(ei) 
    else
        if max(abs(eig(A)))>stablim;
            return
        end
    end
end
rowmax=max(nx,1); 

M=floor(maxsize/rowmax);
V = zeros(ny,ny); lamtrue = V;
Nobs = 0;
Ne = length(ze);
if nargout==2 % just compute the function value
    for kexp = 1:Ne
        z = ze{kexp};
        zorig = zeorig{kexp};
        Ncap = size(z,1);
        nobs = Ncap;
        X0 = X00;
        if back
            X0 = x0est_f(zorig,A,B,C,D,K,ny,nu,maxsize,M);
        end
        yh = zeros(Ncap,ny);
        for kc=1:M:Ncap
            jj=(kc:min(Ncap,kc-1+M));
             yh(jj,:)=idltifr(A,[B X0],C,[D,zeros(size(D,1),1)],z(jj,ny+1:end-1),z(jj,end));        end
         e=z(:,1:ny)-yh;
         V = V + (e'*e);  
        
        lamtrue = lamtrue + e'*e;  
        Nobs = Nobs + nobs;
    end %kexp
    TrueNobs = max(Nobs -length(par)/ny,1);
    
    V = V/Nobs; lamtrue = lamtrue/TrueNobs; 
    V = (V+V')/2; lamtrue = (lamtrue+lamtrue')/2;
    if isnan(V)
        V = inf; lamtrue = V;
    end
    
else % compute both value and gradient
    sqrlam=struc.sqrlam;
    
    if oeflag
        sqrlam = sqrlam*sqrlam';
    end
    
    index=algorithm.estindex;  
    nd=length(par);
    n=length(index);nd=n;
    % *** Compute the gradient PSI. If N>M do it in portions ***
    rowmax=max(n*ny,nx+nz);
    M=floor(maxsize/rowmax);
    R1=zeros(0,nd+1);
    dt=nuderst(par1.')/1000; % fix (improved convergence);  
    if back % use original pars
        par1 = par;
        m0=parset(m0,par); % original pars.
        [A,B,C,D,K,X00] = ssdata(m0);
    end
    
    for kexp = 1:length(ze);
        z = ze{kexp};
        if back
            z = zeorig{kexp}; % No shift
        else
            z = ze{kexp};
        end
        Ncap = size(z,1);
       
        if back
             X0 = x0est_f(z,A,B,C,D,K,ny,nu,maxsize,M);
        else
            X0 = X00;
        end
        
        for kc=1:M:Ncap
            jj=(kc:min(Ncap,kc-1+M));
            Njj = length(jj);
            psitemp=zeros(length(jj),ny);
            psi=zeros(ny*length(jj),n);
            
            x=freqkern(A,[B X0],z(jj,ny+1:end-1),z(jj,end)).';
            yh=(C*x.' + D*z(jj,ny+1:end-2).').'; %om back, så finns yh.
            CHX = mimofr(A,eye(nx),C,[],z(jj,end));
            CHX = mimprep1(CHX);
            e=z(jj,1:ny)-yh;
            if lim==0
                el=e*sqrlam;
            else 
                ll=ones(length(jj),1)*lim; 
                la=abs(e)+eps*ll;regul=sqrt(min(la,ll)./la);el=e.*regul*sqrlam;
            end
            
            evec=el(:);
            kkl=1;
            for kl=index(:)'
                drawnow
                th1=par1;th1(kl)=th1(kl)+dt(kl)/2;
                th2=par1;th2(kl)=th2(kl)-dt(kl)/2;
                m0=parset(m0,th1);
                [A1,B1,C1,D1,K1,X1] = ssdata(m0);
                if T>0&struc.Tflag
                    [A1,B1,Cc,D1,K1] = idsample(A1,B1,C1,D1,K1,T,struc.intersample);
                end
                m0=parset(m0,th2);
                [A2,B2,C2,D2,K2,X2] = ssdata(m0);
                if T>0&struc.Tflag
                    [A2,B2,Cc,D2,K2] = idsample(A2,B2,C2,D2,K2,T,struc.intersample);
                end
                
                dA=(A1-A2)/dt(kl);dB=(B1-B2)/dt(kl);dC=(C1-C2)/dt(kl);
                dD=(D1-D2)/dt(kl); dK=(K1-K2)/dt(kl);
                if back
                    X1 = x0est_f(z(jj,:),A1,B1,C1,D1,K1,ny,nu,maxsize,M); %jj??
                    X2 = x0est_f(z(jj,:),A2,B2,C2,D2,K2,ny,nu,maxsize,M); %jj??
                end
                dX=(X1-X2)/dt(kl);
                
                Z = [dA,dB,dX]*[x,z(jj,ny+1:end-1)].';
                psitemp = (mimprep2(CHX,Z,Njj,ny)+dC*x.'+dD*z(jj,ny+1:end-2).').'*sqrlam;
                 if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag
                    psitemp = psitemp(:);
                    ekk = e;
                    psitemp = abs(ekk(:)).*psitemp;
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;   
            end
            if realflag
                psi = [real(psi);imag(psi)];
                evec = [real(evec);imag(evec)];
            end
            R1=triu(qr([R1;[psi,evec]]));[nRr,nRc]=size(R1);
            R1=R1(1:min(nRr,nRc),:);
            V = V+e'*e;
            Nobs = Nobs+Njj;
        end
    end %kexp
    V = V/Nobs; V =(V+V')/2;
    if isnan(V), 
        V = inf;
    end
    lamtrue = V;
    if any(any(isnan(R1))') | any(any(isinf(R1))')
        R = []; Re =[]; V = inf;
    else
        R=R1(1:nd,1:nd);Re=R1(1:nd,nd+1);
    end
end % if nargout
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,Nobs] = gnfree_f(ze,par,struc,algorithm)

realflag = struc.realflag;
if ~iscell(ze)
    ze={ze};
end

back = 0;
if strcmp(lower(struc.init(1)),'b')
    back = 1;
end
step = 0.00001; 
V=inf;R=[];Re=[];lamtrue = V;Nobs=[];
if ~isempty(par)
    struc = ssfrupd(par,struc); 
end
A = struc.a;
B = struc.b;
C = struc.c;
D = struc.d;
K = struc.k;
X01 = struc.x0;
[ny,n]=size(C);
[n,nu]=size(B);
T = struc.modT;

maxsize=algorithm.MaxSize;
lim=algorithm.LimitError;
if T==0
    stablim = algorithm.Advanced.Threshold.Sstability;
else
    stablim = algorithm.Advanced.Threshold.Zstability;
end
stab = 0;
if ischar(algorithm.Focus)&any(strcmp(algorithm.Focus,{'Stability','Simulation'}));
    stab = 1;
end

if stab 
    if T==0,
        stabtest = any(real(eig(A))>stablim);
    else
        stabtest = max(abs(eig(A)))>stablim;
    end
else
    stabtest = 0;
end
if stabtest
    return
end
rowmax=size(A,1);
M=floor(maxsize/rowmax);
V = zeros(ny,ny); lamtrue =V;
Nobs = 0;
if nargout == 2 % just compute the error
    for kexp = 1:length(ze)
        z = ze{kexp};
        y=z(:,1:ny);u=z(:,ny+1:end-2);ux0=z(:,end-1);farg=z(:,end);
        clear yh
        Ncap=size(z,1);
        nobs = Ncap;  
        if back
            X01=x0est_f(z,A,B,C,D,struc.k,ny,nu,maxsize,M);
              nobs = nobs - length(X01)/ny;
        end
        for kc=1:M:Ncap
            
            jj=(kc:min(Ncap,kc-1+M));
             Njj = length(jj);
            X0 = X01;
            yh(jj,:) = idltifr(A,[B X0],C,[D,zeros(size(D,1),1)],z(jj,ny+1:end-1),z(jj,end));
        end
        e=z(:,1:ny)-yh;
        V = V+ e'*e;
        lamtrue = lamtrue + e'*e;
        Nobs = Nobs + nobs;
    end % over kexp
    V = V/Nobs; lamtrue = lamtrue/(Nobs-length(par)/ny);
    V = (V+V')/2; lamtrue = (lamtrue+lamtrue')/2;
    if isnan(V)
        V = inf; lamtrue = V;
    end
else % compute also gradient
    Qperp=struc.Qperp;
    dkx=struc.dkx;
    if back
        dkx(3)=0;
    end
    sqrlam=struc.sqrlam;
    nk=struc.nk;
    if isempty(nk)
        snk=0;
    else
        snk=sum(nk==0);
    end
    
    npar = n*(ny+nu) + dkx(1)*snk*ny+ dkx(2)*n*ny + dkx(3)*n;
    npar1=size(Qperp,2);
    ncol=npar1+1;size(C,1); 
    M=floor(maxsize/ncol/ny); % max length of a portion of psi
    R1=zeros(0,ncol); 
    for kexp = 1:length(ze)
        
        z = ze{kexp};
        u=z(:,ny+1:end-2); 
        Ncap = size(z,1);
        nobs = Ncap;
        yh = zeros(Ncap,ny);
        if back
            X01 = x0est_f(z,A,B,C,D,K,ny,nu,maxsize,M);
        end
        for kc=1:M:Ncap
            jj=(kc:min(Ncap,kc-1+M));
            Njj = length(jj);
            x0 = X01;
            psi = zeros(length(jj)*ny,npar);
            X = freqkern((A),[B x0],[z(jj,ny+1:end-1)],z(jj,end)).';
            CXH = mimprep1(mimofr(A,eye(n),C,[],z(jj,end)));
            Z1 = [B x0]*z(jj,ny+1:end-1).';
            YH1 = mimprep2(CXH,Z1,Njj,ny);
            yh(jj,:) = YH1.' + z(jj,ny+1:end-2)*D.';
            
            nXr = size(X,1);          
            a0 = zeros(n,n);
            b0 = zeros(n,nu);
            c0 = zeros(ny,n);
            d0 = zeros(ny,nu);
            k0 = zeros(n,ny);
            dcur =1;
            for j = 1:n*(ny*(1+dkx(2))+nu),   % Gradients w.r.t. A,B,C and K
                a = a0; b = b0; c = c0; d = d0; k = k0;
                idx = 1; len = n*n; 
                a(:) = Qperp(idx:len,j);
                idx = idx+len; len = n*nu;
                b(:) = Qperp(idx:idx+len-1,j);
                if dkx(2),
                    idx = idx+len; len = n*ny;
                    k(:) = Qperp(idx:idx+len-1,j);
                end
                idx = idx+len; len = n*ny;
                c(:) = Qperp(idx:idx+len-1,j);
                if back
                    x0p = x0est_f(z(jj,:),A+step*a,B+step*b,C+step*c,D,K+step*k,...
                        ny,nu,maxsize,M); %% jj??
                    x0d=(x0p-X01)/step;
                else
                    x0d = zeros(n,1);
                end
                Z = [a,b,x0d]*[X z(jj,ny+1:end-1)].';
                YH = mimprep2(CXH,Z,Njj,ny);
                psitmp = (YH.' + X(1:length(jj),:)*c.')*sqrlam;
                if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
                psi(:,dcur) = psitmp(:);
                dcur = dcur+1;
            end  % for j
            
            if dkx(1), % Gradient w.r.t. D
                for j=1:nu*ny,
                    if any(ceil(j/ny)==find(nk==0))
                        dd = d0(:);
                        dd(j) = 1;
                        d(:) = dd;
                        if dkx(2),
                            error('Estimation of K not yet operational');
                            if back
                                x0p = x0est_f(z(jj,:),A,B,C,D+step*d,K,ny,nu,maxsize,M);
                                x00=(x0p-X01)/step;
                            else
                                x00 = zeros(n,1);
                            end
                             Z = x00*z(jj,end-1).';
                            psitmp = (mimprep2(CXH,Z,Njj,ny) + d*u(jj,:)).'*sqrlam;
                        else
                            psitmp = (u(jj,:)*d.')*sqrlam;
                        end
                        if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
                        psi(:, dcur)= psitmp(:);
                        dcur = dcur+1;
                    end  % for
                end % ceil
            end % if D
            
            if dkx(3), % Gradient w.r.t x0
                for j=1:n,
                    x00 = zeros(n,1);
                    x00(j) = 1;
                     Z = x00*z(jj,end-1).';
                    psitmp1=mimprep2(CXH,Z,Njj,ny).'*sqrlam;
                     if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
                    psi(:,dcur) = psitmp(:);
                    dcur = dcur+1;
                end   % for
            end  % if x0
            e(jj,:) = z(jj,1:ny) - yh(jj,:);
            elt=e(jj,:)*sqrlam;  
            evec=elt(:);
            if realflag
                psi = [real(psi);imag(psi)];
                evec = [real(evec);imag(evec)];
            end
            R1 = triu(qr([R1;[psi,evec]]));[nRr,nRc]=size(R1);
            R1 = R1(1:min(nRr,nRc),:);
        end % kc-loop
        e = z(:,1:ny) - yh;
        V = V + e'*e;
        Nobs = Nobs +nobs;
    end %kexp-loop
    V = V/Nobs;
    V = (V+V')/2;
    if isnan(V)
        V = inf;
    end
    lamtrue = V;
    
    R=R1(1:npar,1:npar);Re=R1(1:npar,npar+1:ncol);
    if any(any(isnan(R1))') | any(any(isinf(R1))')
        R = []; Re =[]; V = inf; lamtrue = V;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,Nobs]=gnnans_f(ze,par,struc,algorithm,oeflag)
%GNNANS_F  private function

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2004/04/10 23:18:29 $

realflag = struc.realflag;
maxsize=algorithm.MaxSize;
lim=algorithm.LimitError;
stab = 0;
if ischar(algorithm.Focus)&any(strcmp(algorithm.Focus,{'Stability','Simulation'}));
    stab = 1;
end

sqrlam=struc.sqrlam; %sqrlam = eye(size(sqrlam));
modarg=struc.filearg;
T=struc.modT;
if T==0
    stablim = algorithm.Advanced.Threshold.Sstability;
else
    stablim = algorithm.Advanced.Threshold.Zstability;
end
index=algorithm.estindex;  
nd=length(par);
n=length(index);
V = inf;
lamtrue = inf;
Re =[];
R = [];
Nobs = [];
[A,B,C,D,K,X0]=ssmodxx(par,modarg); %No sampling here

if any(any(isnan(A)))
    return
end
try
    ei=eig(A-K*C);
catch
    return
end

if stab 
    if T==0,
        stabtest = any(real(eig(A))>stablim);
    else
        stabtest = max(abs(eig(A)))>stablim;
    end
else
    stabtest = 0;
end
% activate ei-test when K is estimated:
%ei = eig(str.a - str.k*str.c);
% if T==0,
%     if any(real(ei))>stablim|stabtest
%         return
%     end
% else
%     if max(abs(ei))>stablim|stabtest
%         return
%     end
% end
if stabtest
    return
end
[nx,nu]=size(B);[ny,nx]=size(C);nz=ny+nu;
p = ny;
if oeflag == 1
    ee = gnnans_f(ze,par,struc,algorithm,2);
    sqr = sqrlam*sqrlam';
    sqrlam = eye(ny);
end
back = 0;
if strcmp(lower(struc.init(1)),'b')
    back = 1;
end
step = 0.0000001;
if ~iscell(ze)
    ze = {ze};
end
V=inf;R=[];Re=[];lamtrue = V;
if nargout<=2
    grest=0;
else
    grest=1;
end
% *** Prepare for gradients calculations ***
% 
% *** Compute the gradient PSI. If N>M do it in portions ***
rowmax=max(n*ny,nx+nz);
V=zeros(ny,ny); lamtrue = V;
Nobs = 0;
M=floor(maxsize/rowmax);
R1=zeros(0,n+1);  
for kexp = 1:length(ze)
    if oeflag == 2
        ee{kexp} = zeros(0,ny);
    end
    z = ze{kexp};
    Ncap = size(z,1);
    nobs = Ncap;
    if back
        X0 = x0est_f(z,A,B,C,D,K,ny,nu,maxsize,M);
        nobs = nobs - length(X0)/ny;
    end
    
    for kc=1:M:Ncap
        jj=(kc:min(Ncap,kc-1+M));
        Njj = length(jj);
        if grest
            psitemp=zeros(length(jj),ny);
            psi=zeros(ny*length(jj),n);
            x=freqkern(A,[B X0],z(jj,ny+1:end-1),z(jj,end)).';
            CHX = mimofr(A,eye(nx),C,[],z(jj,end));
            CHX = mimprep1(CHX);
            Z1 = [B X0]*z(jj,ny+1:end-1).';
            e = z(jj,1:ny) - mimprep2(CHX,Z1,Njj,ny).'-z(jj,ny+1:end-2)*D.';
        else
            e = z(jj,1:ny)-idltifr(A,[B X0],C,[D,zeros(size(D,1),1)],z(jj,ny+1:end-1),z(jj,end));
        end
        if lim==0
            el=e;
        else 
            ll=ones(length(jj),1)*lim; 
            la=abs(e)+eps*ll;regul=sqrt(min(la,ll)./la);el=e.*regul;
        end
        if oeflag == 2
            ee{kexp}=[ee{kexp};el];
        end
        if grest  
             elt=el*sqrlam;
            evec=elt(:);
            kkl=1;
            An=modarg.as';
            Nrna=find(isnan(An(:)));zv=zeros(nx*nx,1);
            for ka=Nrna'
                zv(ka)=1;
                dA=reshape(zv,nx,nx)';zv(ka)=0;
                if back
                    x0p = x0est_f(z,A+step*dA,B,C,D,K,ny,nu,maxsize,M);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end
                 Z = [dA dX]*[x z(jj,end-1)].';
                psitemp = mimprep2(CHX,Z,Njj,ny).'*sqrlam;
                 if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag   
                    eew = ee{kexp}(jj,:)*sqr;
                    psitemp = abs(eew(:)).*psitemp(:);
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;  
            end
            Bn=modarg.bs';
            Nrnb=find(isnan(Bn(:)));zv=zeros(nx*nu,1);
            for ka=Nrnb'
                zv(ka)=1;
                dB=reshape(zv,nu,nx)';zv(ka)=0;
                if back
                    x0p = x0est_f(z,A,B+step*dB,C,D,K,ny,nu,maxsize,M);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end 
               
                Z = [dB dX]*[z(jj,ny+1:end-1)].';
                psitemp = mimprep2(CHX,Z,Njj,ny).'*sqrlam;
                 if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag  
                    eew = ee{kexp}(jj,:)*sqr;
                    psitemp = abs(eew(:)).*psitemp(:);
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;   
            end
            Cn=modarg.cs;
            Nrnc=find(isnan(Cn(:)));zv=zeros(ny*nx,1);
            for ka=Nrnc'
                zv(ka)=1;
                dC=reshape(zv,nx,ny)';zv(ka)=0;
                if back
                    x0p = x0est_f(z,A,B,C+step*dC,D,K,ny,nu,maxsize,M);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end 
                 Z = [dX]*[z(jj,end-1)].';
                psitemp = (mimprep2(CHX,Z,Njj,ny)+dC*x(1:Njj,:).').'*sqrlam;
                if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag  
                    eew = ee{kexp}(jj,:)*sqr;
                    psitemp = abs(eew(:)).*psitemp(:);
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;
            end
            Dn=modarg.ds';%Dn';
            Nrnd=find(isnan(Dn(:)));zv=zeros(ny*nu,1);
            for ka=Nrnd'
                zv(ka)=1;
                dD=reshape(zv,nu,ny)';zv(ka)=0;
                if back
                    x0p = x0est_f(z,A,B,C,D+step*dD,K,ny,nu,maxsize,M);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end 
                 
                Z = [dX]*z(jj,end-1).';
                psitemp = (mimprep2(CHX,Z,Njj,ny)+dD*z(jj,ny+1:ny+nu).').'*sqrlam;
                 if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag  
                    eew = ee{kexp}(jj,:)*sqr;
                    psitemp = abs(eew(:)).*psitemp(:);
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;   
            end
            if ~back
                Nrnx=find(isnan(modarg.x0s(:)));zv=zeros(nx,1); 
                for ka=Nrnx'
                    dX = zeros(nx,1);
                    dX(ka)=1;
                   
                    Z = dX*z(jj,end-1).';
                    psitemp = (mimprep2(CHX,Z,Njj,ny)).'*sqrlam;
                     if ~(lim==0),psitemp=psitemp.*regul;end
                    if oeflag
                        eew = ee{kexp}(jj,:)*sqr;
                        psitemp = abs(eew(:)).*psitemp(:);
                    end
                    psi(:,kkl)=psitemp(:);kkl=kkl+1;
                end
            end
            psi=psi(:,index(:)'); 
            if realflag
                psi = [real(psi);imag(psi)];
                evec = [real(evec);imag(evec)];
            end
            R1=triu(qr([R1;[psi,evec]]));[nRr,nRc]=size(R1);
            R1=R1(1:min(nRr,nRc),:);
        end %grest
        if oeflag ~=2
            V = V +el'*el;
            lamtrue = lamtrue + e'*e;
            
        end
    end % loop
    Nobs = Nobs +nobs;
end %kexp

if grest
    R=R1(1:n,1:n);Re=R1(1:n,n+1);
end

V = V/Nobs; lamtrue = lamtrue/(Nobs-length(index)/ny);
Vd = diag(V);
V = V-diag(real(Vd)-Vd);
ltd = diag(lamtrue); 
lamtrue = lamtrue+ diag(real(ltd)-ltd);

if isnan(V) | any(any(isnan(R1))') | any(any(isinf(R1))')
    lamtrue = V; 
    V = inf;
    R =[];
    Re =[];
end
if oeflag ==2
    V = ee;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function CHX = mimprep1(CHX)
 [p,n,N]=size(CHX);
 CHX = reshape(shiftdim(CHX,1),n,N*p);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y = mimprep2(CHX,Z,N,p)
if ndims(CHX)==2&min(size(CHX))==1
    Y = CHX.*repmat(Z,1,p);
else
 Y = reshape(sum(CHX.*repmat(Z,1,p)).',N,p).';
end 