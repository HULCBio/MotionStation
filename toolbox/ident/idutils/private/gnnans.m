function [V,lamtrue,R,Re,Nobs]=gnnans(ze,par,struc,algorithm,oeflag)
%GNNANS  private function

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $  $Date: 2004/04/10 23:20:17 $

maxsize=algorithm.MaxSize;
lim=algorithm.LimitError;
stablim = algorithm.Advanced.Threshold.Zstability;
stab = strcmp(algorithm.Focus,'Stability');
sqrlam=struc.sqrlam;
modarg=struc.filearg;
T=struc.modT;
stablim = algorithm.Advanced.Threshold.Zstability;
   % Note models are always discrete time in this routine
index=algorithm.estindex;  
nd=length(par);
n=length(index);
V = inf;
lamtrue = inf;
Re =[];
R = [];
Nobs = 0;
[A,B,C,D,K,X01]=ssmodxx(par,modarg);
if any(any(isnan(A)))
    return
end
try
    ei=eig(A-K*C);
catch
    return
end
if stab
    stabtest = max(abs(eig(A)))>stablim;
else
    stabtest = 0;
end

if max(abs(ei))>stablim|stabtest
    return
end

[nx,nu]=size(B);[ny,nx]=size(C);nz=ny+nu;
if oeflag == 1
    ee = gnnans(ze,par,struc,algorithm,2);
    dat=iddata(ee,[]);
    try
        vmodel = n4sid(dat,3*ny,'cov','none');
        vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
        esqr = sqrtm(pvget(vmodel,'NoiseVariance'));
        [av,bv,cv,dv,kv] = ssdata(vmodel); cv1 = cv;
        av=av';cv=esqr*kv';kv=cv1'*(sqrlam*sqrlam');
        dv=esqr*(sqrlam*sqrlam');
    catch
        av = zeros(1,1);cv=zeros(ny,1);kv=zeros(1,ny);
        dv=sqrlam;%esqr*(sqrlam*sqrlam)';
    end
    sqrlam = eye(ny);
end
back = 0;
if strcmp(lower(struc.init(1)),'b')
    back = 1;
end
step = 0.0001;
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
        X01 = x0est(z,A,B,C,D,K,ny,nu,maxsize);
        nobs = nobs - length(X01)/ny;
    end
    
    for kc=1:M:Ncap
        jj=(kc:min(Ncap,kc-1+M));
        if jj(length(jj))<Ncap,
            jjz=[jj,jj(length(jj))+1];
        else 
            jjz=jj;
        end
        psitemp=zeros(length(jj),ny);
        psi=zeros(ny*length(jj),n);
        if kc == 1
            X0 = X01;
        end
        x=ltitr(A-K*C,[K B-K*D],z(jjz,:),X0); 
        e = z(jj,1:ny)-x(1:length(jj),:)*C.'-z(jj,ny+1:end)*D.';
        [nxr,nxc]=size(x);X0=x(nxr,:).';
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
                if kc==1
                    if back
                        x0p = x0est(z,A+step*dA,B,C,D,K,ny,nu,maxsize);
                        dX=(x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end
                else 
                    dX=dXk(:,kkl);
                end
                psix=ltitr(A-K*C,[dA],x,dX);
                [rpsix,cpsix]=size(psix);
                dXk(:,kkl)=psix(rpsix,:)';
                psitemp=(C*psix(1:length(jj),:).').'*sqrlam;
                if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag
                    psitemp1=ltitr(av,kv,psitemp(end:-1:1,:));
                    psitemp = psitemp1*cv.'+ psitemp(end:-1:1,:)*dv.';
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;  
            end
            Bn=modarg.bs';%Bn';
            Nrnb=find(isnan(Bn(:)));zv=zeros(nx*nu,1);
            for ka=Nrnb'
                zv(ka)=1;
                dB=reshape(zv,nu,nx)';zv(ka)=0;
                if kc==1,
                    if back
                        x0p = x0est(z,A,B+step*dB,C,D,K,ny,nu,maxsize);
                        dX=(x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end 
                else 
                    dX=dXk(:,kkl);
                end
                psix=ltitr(A-K*C,[dB],[z(jjz,ny+1:ny+nu)],dX); 
                [rpsix,cpsix]=size(psix);
                dXk(:,kkl)=psix(rpsix,:)';
                psitemp=(C*psix(1:length(jj),:).').'*sqrlam;
                if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag
                    psitemp1=ltitr(av,kv,psitemp(end:-1:1,:));
                    psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
                end
                
                psi(:,kkl)=psitemp(:);kkl=kkl+1;   
            end
            Cn=modarg.cs;%Cn';
            Nrnc=find(isnan(Cn(:)));zv=zeros(ny*nx,1);
            for ka=Nrnc'
                zv(ka)=1;
                dC=reshape(zv,nx,ny)';zv(ka)=0;
                if kc==1,
                    if back
                        x0p = x0est(z,A,B,C+step*dC,D,K,ny,nu,maxsize);
                        dX=(x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end 
                else 
                    dX=dXk(:,kkl);
                end
                psix=ltitr(A-K*C,[-K*dC],[x],dX); 
                [rpsix,cpsix]=size(psix);
                dXk(:,kkl)=psix(rpsix,:)';
                psitemp=(C*psix(1:length(jj),:).' + ...
                    [dC]*[x(1:length(jj),:)].').'*sqrlam;
                if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag
                    psitemp1=ltitr(av,kv,psitemp(end:-1:1,:));
                    psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
                end
                
                psi(:,kkl)=psitemp(:);kkl=kkl+1;
            end
            Dn=modarg.ds';%Dn';
            Nrnd=find(isnan(Dn(:)));zv=zeros(ny*nu,1);
            for ka=Nrnd'
                zv(ka)=1;
                dD=reshape(zv,nu,ny)';zv(ka)=0;
                if kc==1,
                    if back
                        x0p = x0est(z,A,B,C,D+step*dD,K,ny,nu,maxsize);
                        dX=(x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end 
                else 
                    dX=dXk(:,kkl);
                end
                psix=ltitr(A-K*C,[-K*dD],[z(jjz,ny+1:ny+nu)],dX); 
                [rpsix,cpsix]=size(psix);
                dXk(:,kkl)=psix(rpsix,:)';
                psitemp=(C*psix(1:length(jj),:).' + ...
                    [zeros(ny,ny),dD]*[z(jj,:)].').'*sqrlam;
                if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag
                    psitemp1=ltitr(av,kv,psitemp(end:-1:1,:));
                    psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
                end
                
                psi(:,kkl)=psitemp(:);kkl=kkl+1;   
            end
            Kn=modarg.ks';%Kn';
            Nrnk=find(isnan(Kn(:)));zv=zeros(ny*nx,1);
            for ka=Nrnk'
                zv(ka)=1;
                dK=reshape(zv,ny,nx)';zv(ka)=0;
                if kc==1,
                    if back
                        x0p = x0est(z,A,B,C,D,K+step*dK,ny,nu,maxsize);
                        dX=(x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end 
                else 
                    dX=dXk(:,kkl);
                end
                psix=ltitr(A-K*C,[-dK*C,dK,-dK*D],[x,z(jjz,:)],dX); 
                [rpsix,cpsix]=size(psix);
                dXk(:,kkl)=psix(rpsix,:)';
                psitemp=(C*psix(1:length(jj),:).').'*sqrlam;
                if ~(lim==0),psitemp=psitemp.*regul;end
                if oeflag
                    psitemp1=ltitr(av,kv,psitemp(end:-1:1,:));
                    psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
                end
                psi(:,kkl)=psitemp(:);kkl=kkl+1;
            end
            if ~back
                Nrnx=find(isnan(modarg.x0s(:)));zv=zeros(nx,1); 
                for ka=Nrnx'
                    if kc==1,dX=zeros(nx,1);dX(ka)=1;else dX=dXk(:,kkl);end
                    psix=ltitr(A-K*C,zeros(size(A,1),1),zeros(length(jj),1),dX); 
                    [rpsix,cpsix]=size(psix);
                    dXk(:,kkl)=psix(rpsix,:)';
                    psitemp=(C*psix(1:length(jj),:).').'*sqrlam;
                    if ~(lim==0),psitemp=psitemp.*regul;end
                    if oeflag
                        psitemp1=ltitr(av,kv,psitemp(end:-1:1,:));
                        psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
                    end
                    psi(:,kkl)=psitemp(:);kkl=kkl+1;
                end
            end
            psi=psi(:,index(:)');  
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
if isnan(V) | any(any(isnan(R1))') | any(any(isinf(R1))')
    lamtrue = V; 
    V = inf;
    R =[];
    Re =[];
end
if oeflag ==2
    V = ee;
end