function [V,lamtrue,R,Re,Nobs]=gnnans_f(ze,par,struc,algorithm,oeflag)
%GNNANS_F  private function

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/10 23:20:18 $

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
        X0 = x0est_f(z,A,B,C,D,K,ny,nu,maxsize);
        nobs = nobs - length(X0)/ny;
    end
    
    for kc=1:M:Ncap
        jj=(kc:min(Ncap,kc-1+M));
        psitemp=zeros(length(jj),ny);
        psi=zeros(ny*length(jj),n);
        x=freqkern(A-K*C,[K B-K*D X0],z(jj,1:end-1),z(jj,end)).'; 
        e = z(jj,1:ny)-x(1:length(jj),:)*C.'-z(jj,ny+1:ny+nu)*D.';
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
            An=modarg.as';%An';
            Nrna=find(isnan(An(:)));zv=zeros(nx*nx,1);
            for ka=Nrna'
                zv(ka)=1;
                dA=reshape(zv,nx,nx)';zv(ka)=0;
                if back
                    x0p = x0est_f(z,A+step*dA,B,C,D,K,ny,nu,maxsize);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end
                psix=freqkern(A-K*C,[dA dX],[x z(jj,end-1)],z(jj,end)).'; 
                psitemp=(C*psix.').'*sqrlam;
                if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag   
                    eew = ee{kexp}(jj,:)*sqr;
                    psitemp = abs(eew(:)).*psitemp(:);
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;  
            end
            Bn=modarg.bs';%Bn';
            Nrnb=find(isnan(Bn(:)));zv=zeros(nx*nu,1);
            for ka=Nrnb'
                zv(ka)=1;
                dB=reshape(zv,nu,nx)';zv(ka)=0;
                if back
                    x0p = x0est_f(z,A,B+step*dB,C,D,K,ny,nu,maxsize);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end 
                psix=freqkern(A-K*C,[dB dX],[z(jj,ny+1:end-1)],z(jj,end)).'; 
                psitemp=(C*psix.').'*sqrlam;
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
                    x0p = x0est_f(z,A,B,C+step*dC,D,K,ny,nu,maxsize);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end 
                psix=freqkern(A-K*C,[-K*dC dX],[x z(jj,end-1)],z(jj,end)).'; 
                psitemp=(C*psix.' + ...
                    [dC]*[x(1:length(jj),:)].').'*sqrlam;
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
                    x0p = x0est_f(z,A,B,C,D+step*dD,K,ny,nu,maxsize);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end 
                psix=freqkern(A-K*C,[-K*dD dX],[z(jj,ny+1:end-1)],z(jj,end)).'; 
                psitemp=(C*psix.' + ...
                    dD*[z(jj,ny+1:ny+nu)].').'*sqrlam;
                if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag  
                    eew = ee{kexp}(jj,:)*sqr;
                    psitemp = abs(eew(:)).*psitemp(:);
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;   
            end
            Kn=modarg.ks';%Kn';
            Nrnk=find(isnan(Kn(:)));zv=zeros(ny*nx,1);
            for ka=Nrnk'
                error('Estimation of K not yet implemented'); 
                zv(ka)=1;
                dK=reshape(zv,ny,nx)';zv(ka)=0;
                if back
                    x0p = x0est(z,A,B,C,D,K+step*dK,ny,nu,maxsize);
                    dX=(x0p-X0)/step;
                else
                    dX = zeros(nx,1);
                end 
                psix=freqkern(A-K*C,[-dK*C,dK,-dK*D,dX],[x z(jj,1:end-1)],z(jj,end)).'; 
                psitemp=(C*psix.').'*sqrlam;
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
                    psix=freqkern(A-K*C,dX,[z(jj,end-1)],z(jj,end)).'; 
                    psitemp=(C*psix.').'*sqrlam;
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