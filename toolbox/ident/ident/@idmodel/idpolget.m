function [idp,sys1,flag] = idpolget(sys,noises,ab)
% IDPOLGET Help function to idpoly. 
% IDPOLGET computes the IDPOLY equvalents of IDSS models
%   and stores them in .Utility.Idpoly
%   [idpol, sys1, flag] = IDPOLGET(sys,noises,ab)
%
%   idpol: an array of IDPOLY models, one for each output
%          
%   sys1: sys with idpol stored in sys1.Utility.Idpoly
%         These are computed for noisecnv(sys).
%   flag = 1 if the IDPOLY models were not previously computed
%
%   noises = 'g' : All noise sources are treated as input, and 
%   the correlation among them is accounted for.
%   noises = 'd': It is assumed that the noise filter H is diagonal.
%
%   If ab = 'a', idpolget returns  IDPOLY models corresponding to
%     noisecnv(sys,'norm')-treatment of noise (default).
%     (Note that it is still the noisecnv(sys)-polynomials that are
%      stored.)
%   if ab = 'b' idpolget returns IDPOLY models corresponding to 
%     noisecnv(sys)-treatment of noise.  

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $ $Date: 2004/04/10 23:17:27 $ 

cc = pvget(sys,'NoiseVariance');
sys1 = sys;
if nargin<3
    ab = 'a';
end
ab = lower(ab(1)); 
if nargin<2
    noises = [];
end
if isempty(noises)
    noises='g'; % d:Diagonal noise structure. %
    %Ignore contributions from off-diagonal noise sources
    % g: all noise sources treated as inputs.
end
noises = lower(noises(1));
if noises == 'd'
    ab = 'b';
end
if isa(sys,'idpoly')
    if ab(1)=='a',ab = 'allx9';else ab = 'bothx9';end
    try
    idp = {sys(:,ab)};
catch
    idp = {sys};
end
    flag = 0;
    return   
end
flag =0;
if ab == 'a'
    [idp,sys1,flag] = idpolget(sys,'g','b'); 
    if ~isempty(idp)
        lam = sys.NoiseVariance;
        if norm(lam)>0
            L = chol(lam)';
            N = sum(sys.EstimationInfo.DataLength);
            covL = covlamb(L,N);
            for kk = 1:length(idp)
                idp{kk} = idpole2v(idp{kk},L,covL,size(sys,'nu'));
            end
        end
    end
%     for ky=1:length(idp)
%         idp{ky}=pvset(idp{ky},'NoiseVariance',cc(ky,ky));
%     end
    return
end 
if strcmp(sys.CovarianceMatrix,'None')
    idp = [];
    return
end 
idu = sys.Utility;
try 
    idp = idu.Idpoly; 
catch
    idp = [];
end
if ~isempty(idp)
    if noises == 'd' % then we must extract the right B make it C
        % and delete the correpsonding cov-cross, unless it is an allmeasured model
        if norm(sys.NoiseVariance)>0
            
            [Ny,Nu] = size(sys);
            for ky = 1:Ny
                pol = idp{ky};
                pol = pol(1,[1:Nu,Nu+ky]);
                B = pvget(pol,'b');
                B1 = B(1:Nu,:);
                F = pvget(pol,'f');
                F1 = F(1:Nu,:);
                nb = pvget(pol,'nb');
                nf = pvget(pol,'nf');
                C = B(Nu+1,1:nb(Nu+1));
                cov = pvget(pol,'CovarianceMatrix');
                nend = size(cov,1);
                ncnr = nend-nb(Nu+1)-sum(nf);
                cov = cov([1:ncnr,ncnr+2:nend],[1:ncnr,ncnr+2:nend]);
                pol = pvset(pol,'b',B1,'c',C,'f',F1);
                idp{ky}= pvset(pol,'CovarianceMatrix',cov);%,'NoiseVariance',cc(ky,ky));
            end
        end    
    end
    return
end
if isa(sys,'idarx') 
    sys =idss(sys);
end
T=pvget(sys,'Ts');
noP=0;
if isa(sys,'idss')&isempty(pvget(sys,'CovarianceMatrix')) % här problem om
    % sys är en subrefad idarx
    try
        sys=idu.Pmodel;
    catch
        sys = [];
    end
end
if isempty(sys)
    idp = [];
    sys1.CovarianceMatrix = 'None';
    flag = 1;
    return
end
lambda = pvget(sys,'NoiseVariance');
if isempty(lambda)|norm(lambda)==0
    noises = 'g';
end 
if strcmp(lower(noises(1)),'g')
    if ab(1)=='a', ab='allx9';else ab='bothx9';end
    try
        sysa = sys(:,ab);
    catch
        sysa = sys;
    end
else
    sysa = sys;
end
syspar=sysa.ParameterVector;
nd=length(syspar);
p = sysa.CovarianceMatrix; 
if isempty(p)|ischar(p)
    noP = 1;
end
lambda = sysa.NoiseVariance;
if length(syspar)==0,syspar=0;end
dt=nuderst(syspar);

[a,b,CC,d,k,x0]=ssdata(sysa); 
[ny,nx]=size(CC);nu=size(b,2);
if norm(lambda)==0%|isa(sysa,'idgrey')
    all=1;
else 
    all=0;
end

if all
    ny1=0;
    bk=b;DEf=d;
else
    ny1 = ny;
    bk=[b k];DEf=[d,eye(ny)];
end

Apol=poly(a);

nny=1:ny;
if T>0 &(isa(sysa,'idarx')|(isa(sysa,'idss')&...
        any(strcmp(pvget(sysa,'SSParameterization'),{'Structured','Canonical'}))))
    test=1;
else
    test=0;
end

complex1 = length(syspar)^2.8; %Check if a waitbar should be used
if isa(sys,'idarx')
    complex1 = complex1*35;
end
if test == 0
    complex = complex1*ny*2; 
end
wb = 0;
if complex1>5*10^5
    wb = 1;
end
if wb 
    wbhand=idwb('Covariance Calculations',0,'create');
else 
    wbhand=[];
end

if test&~noP, 
    [J,stopp]=thsshelp(sysa,wbhand);
    if stopp
        idp = [];
        idwb(wbhand,0,'close')
        if stopp == 2;
            sys1 = pvset(sys1,'CovarianceMatrix','None');
            flag = 1;
        end
        return
    end
    
    [nd]=size(J,2);p=p(1:nd,1:nd);
    nmsd=(nx+1)*nu;nmpsd=nmsd*ny;np=nx*ny;
    ial=1:nx; ibe=nx+(1:nmsd); iga=nx+nmpsd+(1:np); 
    ds=nx+nmsd+np;
end

ynam = pvget(sysa,'OutputName');
for iy=nny
    c=CC(iy,:);
    de=DEf(iy,:);
    Apol=poly(a);
    
    for kk=1:nu+ny1
        Bpol(kk,:)=poly(a-bk(:,kk)*c)+(de(kk)-1)*Apol;
        if kk<=nu % Don't destroy C-polynomials
            bs=(abs(Bpol(kk,:))>10^-8*norm(Bpol));
        Bpol(kk,:)=bs.*Bpol(kk,:);
    end
    end
    if strcmp(noises,'d')
        Cpol=Bpol(nu+iy,:);
        Bpol=Bpol(1:nu,:);
        lambb=lambda(iy,iy);
        if T>0,ic=max(find(abs(Cpol)>eps));Cpol=Cpol(1:ic);end
    else
        Cpol=1;
        lambb=0;
    end
    if T>0,ia=max(find(abs(Apol)>eps));Apol=Apol(1:ia);end
    
    Es = pvget(sysa,'EstimationInfo');
    Ncap=Es.DataLength;
    wss = warning;
    warning off
    th=idpoly(Apol,Bpol,Cpol,1,ones(size(Bpol,1),1),lambb,T);
    th = inherit(th,sysa);
     warning(wss);
     yna = ynam(iy);
    th = pvset(th,'OutputName',yna);
    [ap,bp,cp,dp,fp]=polydata(th);
    na=pvget(th,'na');nb=pvget(th,'nb');
    nc=pvget(th,'nc');ndd=pvget(th,'nd');
    nf=pvget(th,'nf');nk=pvget(th,'nk');
    nu1=size(nb,1);
    if strcmp(noises,'d'),nu1=nu;else nu1=nu+ny1;end
    if ischar(p),
       p=[];
    end
    try 
        norm(p);
    catch
        p =[];
    end
    if ~isempty(p), 
        if norm(p)>0
            if ~test
                for kl=1:nd
                    if ~isempty(wbhand)
                        ind = idwb(wbhand,0.05+((kl+(nd)*(iy-1))/(ny*nd))*0.9,'update');
                        if ind,
                            idp = [];
                            idwb(wbhand,0,'close');
                            if ind == 2;
                                sys1 = pvset(sys1,'CovarianceMatrix','None');
                                flag = 1;
                            end
                            return,end
                    end
                    
                    drawnow
                    th1=syspar;th1(kl)=th1(kl)+dt(kl)/2;
                    th2=syspar;th2(kl)=th2(kl)-dt(kl)/2;
                    sysa=parset(sysa,th1); 
                    [A1,B1,C1,D1,K1,X1]=ssdata(sysa); 
                    sysa=parset(sysa,th2);
                    [A2,B2,C2,D2,K2,X2]=ssdata(sysa); 
                    BK1=[B1 K1];BK2=[B2 K2];DE1=[D1 eye(ny)];DE2=[D2 eye(ny)];
                    Apol1=poly(A1);Apol2=poly(A2);C1=C1(iy,:);C2=C2(iy,:);
                    DE1=DE1(iy,:);DE2=DE2(iy,:);
                    
                    for kk=1:nu+ny1
                        B1pol(kk,:)=poly(A1-BK1(:,kk)*C1)+(DE1(kk)-1)*Apol1;
                        B2pol(kk,:)=poly(A2-BK2(:,kk)*C2)+(DE2(kk)-1)*Apol2;
                    end
                    if strcmp(noises,'d')
                        C1pol=B1pol(nu+iy,:);
                        B1pol=B1pol(1:nu,:);
                        C2pol=B2pol(nu+iy,:);
                        B2pol=B2pol(1:nu,:); 
                    else
                        C1pol=1;C2pol=1; 
                    end
                    
                    if na>0, diff(kl,1:na)=(Apol1(2:na+1)-Apol2(2:na+1))/dt(kl);end
                    if nc>0, diff(kl,na+sum(nb)+1:na+nc+sum(nb))=... 
                            (C1pol(2:nc+1)-C2pol(2:nc+1))/dt(kl);end
                    
                    sb=na;sf=na+sum(nb)+nc+ndd;
                    for k=1:nu1
                        if nb(k)>0,
                            diff(kl,sb+1:sb+nb(k))=...
                                (B1pol(k,nk(k)+1:nk(k)+nb(k))-B2pol(k,nk(k)+1:nk(k)+nb(k)))/dt(kl);
                        end
                        sb=sb+nb(k);
                        
                    end
                end
            else
                
                ibell=[];
                for iu=1:nu
                    ibell=[ibell,(iu-1)*(nx+1)+[nk(iu)+1:nk(iu)+nb(iu)]];
                end
                
                if strcmp(noises,'g'),
                    iinoise=[];
                    for iiy=1:ny1
                        if iiy==iy, add=1;else add=0;end
                        iinoise=[iinoise,nx+nmpsd+(iy-1)*np+(iiy-1)*nx+[1:nb(iiy+nu)-add]];
                    end
                else 
                    iinoise=iga((iy-1)*nx+1:(iy-1)*nx+ic-1)+(iy-1)*np;
                end
                ii=[1:ia-1 nx+ibell+(iy-1)*nmsd iinoise];
                nopar=length(ii);
                if strcmp(noises,'g')
                    Nnb=[0 cumsum(nb)];
                    if ny1>0
                        iii=[1:na+Nnb(nu+iy),na+Nnb(nu+iy)+2:nopar+1];
                    else
                        iii = 1:nopar;
                    end
                else 
                    iii=1:nopar;
                end
                
                diff=zeros(nd,nopar);
                diff(:,iii)=J(ii,:)';
            end % if ~test
            
            PTH=diff'*p*diff; 
            [d,nd]=size(diff');
            if nd>0,
                th=pvset(th,'CovarianceMatrix',PTH);
            end
            
        end,
    end % If p
    %if length(nny)==1,
    %   idp=th;
    %else 
    th = pvset(th,'Ts',T);
    idp{iy}=th;
    %end
    clear Bpol Cpol
end % for iy
if ~isempty(wbhand)
    idwb(wbhand,0,'close')
end

% for ky=1:length(idp)
%     idp{ky}=pvset(idp{ky},'NoiseVariance',cc(ky,ky));
% end
%if ab=='b'
%   idu.Idpolyboth = idp;
%else
idu.Idpoly = idp;
%end
sys1.Utility = idu;
flag = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Jth_xi,stopp]=thsshelp(xi,wbhand)
% JSS2TH_FULL(TH): jacobian from state-space (full) to 
%			(I/O and N/O) transfer function parameterization
%
%	TH: TH-format from "state-space"-PEM

%	P. Carrette, March 1998 

% Jacobian from full to diagonal parametrization
%	xi=[vec(A.'); vec(B.'); vec(C.'); vec(D.'); vec(K.'); X0]
%	Dxi=[LA; vec(DB); vec(DC); vec(DD); vec(DK); DX0]

%   - initials

Jth_xi = [];
stopp = 0;
[A,B,C,D,K,X0]=ssdata(xi); [n,m]=size(B); [p,n]=size(C); 
nn=n*n; nm=n*m; np=n*p; mp=m*p; nmp=n*mp; pp=p*p; npp=n*pp; 

sd=0; if max(abs(D(:)))~=0, sd=1; end,sd=1;
sk=0; if max(abs(K(:)))~=0, sk=1; end
sx=0; if max(abs(X0))~=0, sx=1; end;
if isa(xi,'idarx')
    ms = getarxms(pvget(xi,'na'),pvget(xi,'nb'),pvget(xi,'nk'));
    arx = 1;
    An = ms.As; Bn = ms.Bs; Cn = ms.Cs;
    Dn = ms.Ds; Kn = ms.Ks; X0n = ms.X0s;
else
    ms = xi;
    arx = 0;
    An = pvget(ms,'As'); 
    Bn=pvget(ms,'Bs');
    Cn=pvget(ms,'Cs');
    Kn=pvget(ms,'Ks');
    X0n=pvget(ms,'X0s');
end
in=1:n; nb=n; nc=nb+m;nd=nc+p; nk=nd+m; nx=nk+p; 
na=sum(isnan(An(:))); sna=1; 
if na==0, sna=0; end
nb=sum(isnan(Bn(:))); snb=1; 
if nb==0, snb=0; end
if arx,
    Cn=An(1:p,:);Dn=Bn(1:p,:);
else 
    Dn=pvget(ms,'Ds');
end

nc=sum(isnan(Cn(:))); snc=1; if nc==0, snc=0; end
nd=sum(isnan(Dn(:))); snd=1; if nd==0, snd=0; end,snd=1;
nk=sum(isnan(Kn(:))); snk=1; if nk==0, snk=0; end
nx=sum(isnan(X0n)); snx=1; if nx==0, snx=0; end

dxi=na+nb+nc+nd+nk+nx; 
Im=eye(m); In=eye(n); Ip=eye(p); Imp=eye(mp);

%   - eigenvalue decomposition of A -> DA,VA
stat = randn('state');
randn('state',0);
A=A+1e-10*randn(size(A)); [VA,DA]=eig(A); LA=diag(DA); VAI=inv(VA); 
randn('state',stat);
%   - corresponding representation -> DB,DC,DK
DB=VAI*B; DC=C*VA; if sd, DD=D; end; if sk, DK=VAI*K; end

%   - Jacobian matrix
dDxi=n+nm+np+sd*mp+sk*np; JDxi_xi=zeros(dDxi,dxi);
if ~isempty(wbhand)
    drawnow
    stopp = idwb(wbhand,0.04,'update');
    drawnow
    if stopp;return,end
end
if snb, ib=n+(1:nm); lb=na; 
    for i=1:n, 
        inan=find(isnan(Bn(i,:))); ln=length(inan); iib=lb+(1:ln); lb=lb+ln;
        JDxi_xi(ib,iib)=kron(Im(:,inan),VAI(:,i)); 
    end
end

if snc, ic=n+nm+(0:n-1)*p; lc=na+nb;
    for i=1:p, 
        inan=find(isnan(Cn(i,:))); ln=length(inan); iic=lc+(1:ln); lc=lc+ln;
        JDxi_xi(ic+i,iic)=VA(inan,:).'; 
    end
end


if snd, stid=vec(ones(m,1)*(1:p)+p*(0:m-1)'*ones(1,p)); 
    inan=find(isnan(vec(Dn'))); iic=na+nb+nc+(1:length(inan));
    JDxi_xi(n+nm+np+(1:mp),iic)=Imp(:,stid(inan));
end

if snk, ik=n+nm+np+sd*mp+(1:np); lk=na+nb+nc+nd; 
    for i=1:n, 
        inan=find(isnan(Kn(i,:))); ln=length(inan); iik=lk+(1:ln); lk=lk+ln;
        JDxi_xi(ik,iik)=kron(Ip(:,inan),VAI(:,i)); 
    end
end

dLA=zeros(nn,1); in=0; 
for j=1:n; i=[1:j-1,j+1:n]; 
    if sum(abs(LA(j)-LA(i))<1e-8)==0, dLA(in+i)=1./(LA(j)-LA(i)); end, in=in+n; 
end

Vp=zeros(nn,na); VVA=VA'*VA; VAt=VA.'; la=0; ia=1:n;
for i=1:n, inan=find(isnan(An(i,:))); ln=length(inan); onan=ones(1,ln); 
    iia=la+(1:ln); la=la+ln; VAIi=VAI(:,i); VAti=VAt(:,inan);
    JDxi_xi(ia,iia)=(VAIi*onan).*VAti; Vp(:,iia)=kron(VAti,VAIi).*(dLA*onan);
    for j=1:n, Vp((j-1)*n+j,iia)=-VVA(j,:)*Vp((j-1)*n+ia,iia); end
end 
if ~isempty(wbhand)
    drawnow
    stopp = idwb(wbhand,0.07,'update');
    drawnow
    if stopp,return,end
end
JDxi_xi(n+(1:nm+np),1:na)=[kron(DB.',-In); kron(In,DC)]*Vp;
if ~isempty(wbhand)
    drawnow
    stopp = idwb(wbhand,0.20,'update');
    drawnow
    if stopp,return,end
end
if sk, JDxi_xi(n+nm+np+sd*mp+(1:np),1:na)=kron(DK.',-In)*Vp; end
if ~isempty(wbhand)
    drawnow
    stopp = idwb(wbhand,0.25,'update');
    drawnow
    if stopp,return,end
end
% Jacobian from diagonal to transfer function
%	Dxi=[LA; vec(DB); vec(DC); vec(DD); vec(DK); DX0]
%	th=[al; (d,be)_11, ..., (d,be)_1m, ..., (d,be)_p1, ..., (d,be)_pm; 
%		... ga_11, ..., ga_1p, ..., ga_p1, ..., ga_pp]		

nsd=n+sd; nmsd=nsd*m; nmpsd=nmsd*p; dth=n+nmpsd+npp; Jth_Dxi=zeros(dth,dDxi);
ial=1:n; iibe=n+(0:mp-1)*nsd; iiga=n+nmpsd+(0:pp-1)*n; 
ibe=vec(nmsd*ones(n,1)*(0:p-1)+(1:n)'*ones(1,p));
if sd, 
    idbe=n+vec(((1:n)+sd)'*ones(1,mp)+nsd*ones(n,1)*(0:mp-1)); vDD=vec(DD.');
end
if sk, iga=nmpsd+vec(np*ones(n,1)*(0:p-1)+(1:n)'*ones(1,p)); end
ifga=n+nmpsd+(find(vec(Ip)==1)-1)*n;
pol=[1 -LA(1)]; for i=2:n, pol=conv(pol,[1 -LA(i)]); end
step =1;
for i=1:n, 
    if ~isempty(wbhand)
        if i/step==fix(i/step)
            stopp = idwb(wbhand,0.25+(i/n)*0.65,'update');drawnow
        end
        if  stopp
            break
        end
    end   
    tempa=deconv(pol,[1 -LA(i)]); Jth_Dxi(ial,i)=-tempa.';
    
    tempb=vec((DC(:,i)*tempa).'); 
    for j=1:m, Jth_Dxi(ibe+j*nsd,i+j*n)=tempb; end
    
    tempc=vec(tempa.'*DB(i,:)); 
    ic=n+nm+(i-1)*p; jc=n+vec((sd+(1:n))'*ones(1,m)+nsd*ones(n,1)*(0:m-1));
    for j=1:p, 
        Jth_Dxi(jc+(j-1)*nmsd,ic+j)=tempc; 
    end
    
    S=zeros(nn,1); jS=n:n:nn-n;
    for j=1:n, if j~=i, S(j+jS)=-deconv(tempa,[1 -LA(j)]); end; end
    for j=2:n, Jth_Dxi(j+sd+iibe,i)=vec((DC*diag(S((1:n)+(j-1)*n))*DB).'); end
    
    if sd, Jth_Dxi(idbe,i)=Jth_Dxi(idbe,i)+kron(vDD,-tempa.'); end
    
    if sk, 
        tempc=vec(tempa.'*DK(i,:)); ik=nm+np+mp*sd+i; jc=n+nmpsd+(1:np);
        for j=1:p, 
            Jth_Dxi(iga+j*n,ik+j*n)=tempb; Jth_Dxi(jc+(j-1)*np,ic+j)=tempc;   
        end
        for j=2:n, Jth_Dxi(j+iiga,i)=vec((DC*diag(S((1:n)+(j-1)*n))*DK).'); end
    end
    for j=1:p, Jth_Dxi(ifga(j)+ial,i)=Jth_Dxi(ifga(j)+ial,i)-tempa.'; end
end
if stopp,return,end
if sd, 
    iid=n+nm+np+vec(ones(m,1)*(1:p)+p*(0:m-1)'*ones(1,p));
    for i=1:nsd, Jth_Dxi(iibe+i,iid)=pol(i)*Imp; end
end


% Final jacobian matrix

Jth_xi=real(Jth_Dxi*JDxi_xi); clear Jth_Dxi JDxi_xi
if ~isempty(wbhand)
    stopp = idwb(wbhand,0.98,'update');
    if stopp,return,end
end
if arx
    Jth_xi=Jth_xi*[eye(na+nb);eye(na+nb)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y=vec(x)
% VEC(X): vectorizes the matrix X ... vector of columns.

y=x(:);
