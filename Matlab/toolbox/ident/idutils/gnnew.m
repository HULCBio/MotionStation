function [V,Vt,psi,e,Nobs] = gnnew(z,par,struc,algorithm,oeflag)
%GNNEW Computes The Gauss-Newton search direction

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.42.4.1 $  $Date: 2004/04/10 23:18:28 $
if nargin < 5
   oeflag = 0; % marks that e should be whitened, and psi filtered accordingly
end

try
    dom = struc.domain;
catch
    dom = 't';
end
if lower(dom(1))=='f'
    if nargout ==2
        if strcmp(struc.type,'poly')
            [V,Vt] = gnnew_fp(z,par,struc,algorithm,oeflag);
        else
            [V,Vt] = gnnew_f(z,par,struc,algorithm,oeflag);
        end
    else
        if strcmp(struc.type,'poly')
            [V,Vt,psi,e,Nobs] = gnnew_fp(z,par,struc,algorithm,oeflag);
            
        else
            [V,Vt,psi,e,Nobs] = gnnew_f(z,par,struc,algorithm,oeflag);
        end
    end
    return
end
switch struc.type
    case 'poly'
        switch lower(struc.init(1))
            case {'e','b'}
                if nargout==2
                    [V,Vt] = gnx(z,par,struc,algorithm,oeflag);
                else
                    [V,Vt,psi,e,Nobs] = gnx(z,par,struc,algorithm,oeflag); 
                end
                
            case 'z'
                if nargout==2
                    [V,Vt] = gntrad(z,par,struc,algorithm,oeflag);
                else
                    [V,Vt,psi,e,Nobs] = gntrad(z,par,struc,algorithm,oeflag);
                end
                
        end
        
    case 'ssnans'
        % gnll och sess om endast V behövs Tag som nr 3
        if nargout==2
            [V,Vt] = gnnans(z,par,struc,algorithm,oeflag);
        else
            [V,Vt,psi,e,Nobs] = gnnans(z,par,struc,algorithm,oeflag); 
        end
        
    case 'ssfree'
        if nargout==2
            [V,Vt] = gnfree(z,par,struc,algorithm);
        else
            [V,Vt,psi,e,Nobs] = gnfree(z,par,struc,algorithm);
        end
        
    case 'ssgen'
        
        if nargout==2
            [V,Vt] = gnns(z,par,struc,algorithm,oeflag);
        else
            [V,Vt,psi,e,Nobs] = gnns(z,par,struc,algorithm,oeflag);
        end
end

function [V,lamtrue,R,Re,nobs]=gntrad(zc,par,nn,algorithm,oeflag)
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
if ~iscell(zc)
    zc={zc};
end
lamtrue = inf;
V=inf;
R=[];
Re=[];
lim = algorithm.LimitError;
maxsize=algorithm.MaxSize;
index = algorithm.estindex;
stablim = algorithm.Advanced.Threshold.Zstability;
stab = strcmp(algorithm.Focus,'Stability');
nz = size(zc{1},2);
%[Ncap,nz]=size(z);
nu=nn.nu;na=nn.na;nb=nn.nb;nc=nn.nc;nd=nn.nd;nf=nn.nf;nk=nn.nk;
n=na+sum(nb)+nc+nd+sum(nf);
if nu~=nz-1
    disp('Incorrect number of data columns specified.') 
    disp(['Should be equal to the sum of the number of inputs'])
    disp('and the number of outputs.')
    error
end
a=[1 par(nn.nai).'];c=[1 par(nn.nci).'];d=[1 par(nn.ndi).'];
b=zeros(nu,max(nb+nk));nfm=max(nf);f=zeros(nu,nfm+1);
if max(abs(roots(c)))>stablim|(stab&(max(abs(roots(a)))>stablim))
    V=inf;grad=[];R=[];Re=[];lamtrue = V;nobs=1;
    return,
end
if nu>0
    for ku=1:nu
        b(ku,nk(ku)+1:nk(ku)+nb(ku))=par(nn.nbi{ku}).';
        f(ku,1:nf(ku)+1)=[1 par(nn.nfi{ku}).'];
        if nf(ku)>0,
            fst(ku)=max(abs(roots(f(ku,:))));
        else 
            fst(ku)=0;
        end
    end
    if max(fst)>stablim,
        V=inf;grad=[];R=[];Re=[];lamtrue=V;nobs=1;
        return,
    end
end
if nu>0
    nmax=max([na nb+nk-ones(1,nu) nc nd nf]);
else
    nmax= max([na nc]);
end


% *** Prepare for gradients calculations ***

ni=max([length(a)+nd-2 nb+nd-2 nf+nc-2 1]);
M=floor(maxsize/n);n1=length(index);
R1=zeros(0,n1+1); 

V=0;
lamtrue=0;
NNcap = 0;
nnobs = 0;
for kexp = 1:length(zc)
    z=zc{kexp};
    Ncap = size(z,1);
    nobs=Ncap-ni-sum([na nb nc nd nf]);
    v=filter(a,1,z(:,1));
    for k=1:nu, 
        if ~isempty(b)
            w(:,k)=filter(b(k,:),f(k,:),z(:,k+1));v=v-w(:,k);
        end
    end
    e=pefilt(d,c,v,zeros(1,ni)); % Note pefilt. This could be discussed.
    
    if lim==0
        el=e;
    else
        ll=lim*ones(size(e,1),1);
        la=abs(e)+eps*ll;
        regul=sqrt(min(la,ll)./la);
        el=e.*regul;
    end
    %ec{kexp}=e;
    %elc{kexp}=el;
    lamtrue = lamtrue+e'*e;
    V = V + el'*el;
    nnobs = nnobs+nobs;
    %if nargout<3,
    %  return,
    %end
    if nargout>2
        if oeflag
            try
                vmodel = n4sid(el,5,'cov','none');
                vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
            catch
                vmodel = idpoly(1,1,'noisevar',lamtrue);
            end
        end
        if sum(nf)==0 , clear w, end
        if na>0, yf=filter(-d,c,z(:,1));end
        if nc>0, ef=filter(1,c,e); end
        if nd>0, vf=filter([-1],c,v); end
        for k=1:nu
            gg=conv(c,f(k,:));
            uf(:,k)=filter(d,gg,z(:,k+1));
            if nf(k)>0, wf(:,k)=filter(-d,gg,w(:,k));end
        end
        
        % *** Compute the gradient PSI. If N>M do it in portions ***
        
        %M=floor(maxsize/n);n1=length(index);
        %R1=zeros(0,n1+1); 
        for k=nmax:M:Ncap-1  
            jj=(k+1:min(Ncap,k+M));
            psi=zeros(length(jj),n);
            for kl=1:na, psi(:,kl)=yf(jj-kl);end
            ss=na;ss1=na+sum(nb)+nc+nd;
            for ku=1:nu
                for kl=1:nb(ku), psi(:,ss+kl)=uf(jj-kl-nk(ku)+1,ku);end
                for kl=1:nf(ku), psi(:,ss1+kl)=wf(jj-kl,ku);end
                ss=ss+nb(ku);ss1=ss1+nf(ku);
            end
            for kl=1:nc, psi(:,ss+kl)=ef(jj-kl);end 
            ss=ss+nc;
            for kl=1:nd, psi(:,ss+kl)=vf(jj-kl);,end
            
            psi=psi(:,index);  
            if lim~=0
                psi=psi.*(regul(jj)*ones(1,n1)); 
            end
            if oeflag
                [num,den]=tfdata(vmodel,'v');
                psi = filter(num,den,psi(end:-1:1,:))*sqrt(pvget(vmodel,'NoiseVariance'));
            end
            R1=triu(qr([R1;[psi,el(jj)]]));[nRr,nRc]=size(R1);
            R1=R1(1:min(nRr,nRc),:);
        end
        R=R1(1:n1,1:n1);Re=R1(1:n1,n1+1);
    end
    clear w uf wf
end
V = V/nobs;
lamtrue=lamtrue/nobs;




%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
function [V,lamtrue,Hess,grad,Nobs]=gnx(z,par,nn,algorithm,oeflag)
init=nn.init;
lim=algorithm.LimitError;
index=algorithm.estindex;
maxsize=algorithm.MaxSize;
stablim = algorithm.Advanced.Threshold.Zstability;
stab = strcmp(algorithm.Focus,'Stability');

if nargout==2,grest=0;else grest=1;end

nu=nn.nu;na=nn.na;nb=nn.nb;nc=nn.nc;nd=nn.nd;nf=nn.nf;nk=nn.nk;
a=[1 par(nn.nai).'];c=[1 par(nn.nci).'];d=[1 par(nn.ndi).'];
b=zeros(nu,max(nb+nk));nfm=max(nf);f=zeros(nu,nfm+1);
if max(abs(roots(c)))>stablim|(stab&(max(abs(roots(a)))>stablim))
   V=inf;grad=[];Hess=[];lamtrue = V;Nobs=1;
   return,
end

for ku=1:nu
   b(ku,nk(ku)+1:nk(ku)+nb(ku))=par(nn.nbi{ku}).';
   f(ku,1:nf(ku)+1)=[1 par(nn.nfi{ku}).'];
   
   if nf(ku)>0,
      fst(ku)=max(abs(roots(f(ku,:))));
   else 
      fst(ku)=0;
   end
end
if nu>0 
   if max(fst)>stablim,
      V=inf;grad=[];Hess=[];lamtrue=V;Nobs=1;
      return,
   end
end

try
   xi=par(nn.xi);
catch
   xi=[];
end

if isempty(nfm),nfm=0;end  
if nfm==0&nd==0
   afd=a;bfdt=b;cf=c;nft=zeros(1,nu);
else
   ff=1;
   for ku=1:nu
      bd(ku,:)=conv(b(ku,:),d);
      ff=conv(ff,f(ku,:));
   end
   for ku=1:nu
      ftt=1;nft(ku)=0;
      for kk=1:nu
         if kk~=ku
            ftt=conv(ftt,f(kk,:));nft(ku)=nft(ku)+nf(kk);
         end
      end
      ft(ku,1:length(ftt))=ftt;
      lltemp=conv(bd(ku,:),ft(ku,:));
      bfdt(ku,1:length(lltemp))=lltemp;
   end
   ff=ff(1:sum(nf)+1);
   afd=conv(conv(a,ff),d);cf=conv(ff,c);
end

if grest&max(sum(nf),nd)>0
   
   nbb=sum(nft)+sum(nb)+nd*nu;
   dbdb=zeros(sum(nb),nbb);
   csb=[0,cumsum(nb)];s1=0;dbdd=[];dadf=[];dcdf=[];
   for ku=1:nu
      fttemp=ft(ku,1:nft(ku)+1);
      dbdb(csb(ku)+1:csb(ku+1),s1+1:s1+nd+nb(ku)+nft(ku))=...
         chvar(conv(d,fttemp),nb(ku),0);
      s1=s1+nd+nb(ku)+nft(ku);
      bftemp=conv(b(ku,:),ft(ku,:));
      bftemp=bftemp(nk(ku)+1:nk(ku)+nb(ku)+nft(ku));
      dbdd=[dbdd,chvar(bftemp,nd,1)];
      dadf=[dadf;chvar(conv(a,conv(d,fttemp)),nf(ku),0)];
      dcdf=[dcdf;chvar(conv(c,fttemp),nf(ku),0)];
   end
   
   dbdf=[];
   for ku=1:nu % This is the column loop
      dbdfrow=[];
      for kku=1:nu % This is the row loop
         if kku~=ku
            ftilde=1;ftord=0;
            for kt=1:nu
               if kt~=ku&kt~=kku,
                  ftilde=conv(ftilde,f(kt,:));ftord=ftord+nf(kt);
               end
            end
            dbdfrow=[dbdfrow,chvar(...
                  conv(ftilde(1:ftord+1),bd(kku,nk(kku)+1:nk(kku)+nb(kku)+nd)),...
                  nf(ku),1)];
         else
            dbdfrow=[dbdfrow,zeros(nf(ku),nft(ku)+nb(ku)+nd)];
         end
      end
      dbdf=[dbdf;dbdfrow];
   end
   
   trfm=[chvar(conv(d,ff),na,0),zeros(na,nbb+nc+sum(nf))];
   trfm=[trfm;zeros(sum(nb),na+nd+sum(nf)),dbdb,zeros(sum(nb),nc+sum(nf))];
   trfm=[trfm;zeros(nc,na+nd+sum(nf)+nbb),chvar(ff,nc,0)];
   trfm=[trfm;chvar(conv(a,ff),nd,0),dbdd,zeros(nd,nc+sum(nf))];
   trfm=[trfm;dadf,dbdf,dcdf];
   if lower(init(1))=='e'
      [nllr,nllc]=size(trfm);
      trfm=[[trfm,zeros(nllr,length(xi))];...
            [zeros(length(xi),nllc),eye(length(xi))]];
   end
else
   trfm=[];
end

if lower(init(1))=='e'
   
   [V,grad,Hess,Nobs,lamtrue]=...
      gnaxss2(z,afd,bfdt,cf,nft+nb+nd,nk,lim,init,grest,xi,index,...
      trfm,maxsize,oeflag,length(par));
   
else  % i-e. Torben Knudsen
   [V,grad,Hess,Nobs,lamtrue]...
      =gntk(z,afd,bfdt,cf,nft+nb+nd,nk,lim,grest,index,trfm,maxsize,...
      oeflag,length(par));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat=chvar(a,n,ind)
if n==0,mat=zeros(0,length(a)-1+ind);return,end
if n==1,if ind==0,mat=a;else mat=[0 a];end,return,end
if ind==0
   mat=toeplitz([a zeros(1,n-1)].',[a(1) zeros(1,n-1)]).';
else
   mat=toeplitz([0 a zeros(1,n-1)].',zeros(1,n)).';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,Re,R,nobs,lamtrue]=...
   gnaxss2(z,a,b,c,nb,nk,lim,init,grest,xi,index,trfm,maxsize,oeflag,truenpar);
Re=[];R=[];nobs = 0;
if nargin<10, 
   xi=[];
end
%if max(abs(roots(c)))>1,
%   V=inf;Re=[];R=[];lamtrue = V;
%   return,
%end
[Ncap,nz]=size(z);nu=nz-1;y=z(:,1);
na=length(a)-1;nc=length(c)-1;[nu,nbb]=size(b);
nss=max([na,nc,nbb-1]);
if length(xi)~=nss,
    xi = [];
    [nrtrf,nctrf] = size(trfm);
    ext = nss+na+sum(nb)+nc-nctrf;
    if ext~=0
        trfm(nrtrf+[1:ext],nctrf+[1:ext])=eye(ext);
    end
    
end

if isempty(xi),
   xi=zeros(nss,1);
end
AKC=[[-c(2:nc+1).';zeros(nss-nc,1)],[eye(nss-1);zeros(1,nss-1)]];
bb=[b,zeros(nu,nss-nbb+1)];
B=bb(:,2:end).';
K=zeros(nss,1);Kc=K;
Kc(1:nc)=c(2:end).';K=Kc;
try
   K(1:na)=K(1:na)-a(2:end).';
end
C=[1,zeros(1,nss-1)];
if isempty(b)
   if isempty(nb)
      BKD=[];D=[];%BKD = B; D =0; %was []  and  [];
   else
      BKD = B; D =0;
   end 
else
   D=b(:,1).';
   BKD=B-Kc*D;
end
% *** Compute the gradient PSI. If N>M do it in portions ***
nx=nss;n=length(index);ny=1;npar=na+nc+sum(nb);
if grest,rowmax=max(npar,nx+nz);else rowmax=nx;end
M=floor(maxsize/rowmax);

V=0;lamtrue = 0;
X0=xi;dx0=zeros(nx,1);
dXk=zeros(nx,npar);
if isempty(trfm),nr1=n;else nr1=size(trfm,1);end
nr1=length(index);
R1=zeros(0,nr1+1);
nobs = Ncap;
for kc=1:M:Ncap  
   jj=(kc:min(Ncap,kc-1+M));
   if jj(length(jj))<Ncap,jjz=[jj,jj(length(jj))+1];else jjz=jj;end
   
   psi=zeros(length(jj),npar);
   
   x=ltitr(AKC,[K BKD],z(jjz,:),X0);
   yh=(C*x.'+[0 D]*z(jjz,:).').';
   e=z(jj,1:ny)-yh(1:length(jj),:);
   X0=x(end,:).';
   if lim==0
      el=e;
   else
      ll=lim*ones(size(e,1),1);
      la=abs(e)+eps*ll;
      regul=sqrt(min(la,ll)./la);
      el=e.*regul;
   end
   V=V+el'*el;
   lamtrue = lamtrue + e'*e;
   if oeflag
      try
         vmodel = n4sid(el,5,'cov','none');
         vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
      catch
         vmodel = idpoly(1,1,'noisevariance',lamtrue/length(e));
      end
   end
   if grest
      if kc==1,beg=2;endx=1;else beg=1;endx=0;end
      psix0=ltitr((AKC).',C.',[endx;zeros(length(jjz),1)],dx0);
      psix0=psix0(2:length(jj)+1,:);
      dx0=psix0(end,:).';
      
      kl=1;
      
      for kk=1:na
         Bfake=zeros(nss,1);Bfake(kk)=[-1];
         dX=dXk(:,kl);
         psix=ltitr(AKC,Bfake,y(jjz),dX);
         
         psi(:,kl)=psix(1:length(jj),:)*C.';
         dXk(:,kl)=psix(end,:).';
         kl=kl+1;
      end
      col=na;
      for ku=1:nu
         for kk=1:nb(ku)
            if kk==1&nk(ku)==0
               psi(:,kl)=filter(1,c,z(jj,ku+1));
            else
               Bfake=zeros(nss,1);Bfake(nk(ku)-1+kk)=1;
               dX=dXk(:,kl);
               psix=ltitr(AKC,Bfake,z(jjz,ku+1),dX);
               psi(:,kl)=psix(1:length(jj),:)*C.';
               dXk(:,kl)=psix(end,:).';
               
            end
            kl=kl+1;
         end
         
      end
      for kk=1:nc
         Bfake=zeros(nss,1);Bfake(kk)=1;
         dX=dXk(:,kl);
         psix=ltitr(AKC,Bfake,y(jjz)-yh,dX);
         psi(:,kl)=psix(1:length(jj),:)*C.';
         dXk(:,kl)=psix(end,:).';
         kl=kl+1;
      end
      
      psi=[psi,psix0];  
      if ~isempty(trfm),psi=psi*trfm.';end
      
      psi=psi(:,index);  
      
      if lim~=0
         psi=psi.*(regul*ones(1,size(psi,2))); 
      end
      if oeflag
         [num,den]=tfdata(vmodel,'v');
         psi = filter(num,den,psi(end:-1:1,:))*sqrt(pvget(vmodel,'NoiseVariance'));
      end
      
      R1=triu(qr([R1;[psi,el]]));[nRr,nRc]=size(R1);
      R1=R1(1:min(nRr,nRc),:);
   end %if grest
end % end loop
if grest,R=R1(1:nr1,1:nr1);Re=R1(1:nr1,nr1+1);end
V=V/length(z); 
lamtrue = lamtrue/(length(z)-truenpar);%%%

%%%%%%%%%%%%
function [V,Re,R,Nobs,lamtrue]=gntk(ze,a,b,c,nb,nk,lim,grest,index,...
   trfm,maxsize,oeflag,truenpar);
%% Here z is a cell array
if ~iscell(ze);
   ze = {ze};
end
Re = []; R =[];
%if max(abs(roots(c)))>1,V=inf;Re=[];R=[];Nobs=1;lamtrue = V;return,end
na=length(a)-1;nc=length(c)-1;nn=[na nb nc];
npar=na+sum(nb)+nc;n=npar;
tstart=1+max([na nb+nk-1]);
tstart = max(tstart,max([nk,1])+2);

V = 0; Nobs = 0; lamtrue = 0;
for kexp = 1:length(ze);
   z = ze{kexp};
   [Ncap,nz]=size(z);nu=nz-1;
   
   nobs=Ncap-tstart+1;
   y=z(:,1);u=z(:,2:end);
   v=zeros(Ncap,1);
   for ku=1:nu
      v=v+filter(b(ku,:),1,u(:,ku));
   end
   
   w=filter(a,1,y)-v;w=w(tstart:end);
   ecb=filter(1,c,w(end:-1:1));
   wc=filter(c(end:-1:2),1,ecb(Ncap-tstart+1:-1:Ncap-tstart+2-nc));
   wc=filter(c,1,zeros(1,nc),wc(end:-1:1));
   ei=filter(1,c,wc(nc:-1:1));
   e=filter(c(end:-1:2),1,ei(end:-1:1));
   e=filter(1,c,w,-e(end:-1:1));%e(1) svsrar mot z(tstart)
   if lim==0
      el=e;
   else
      ll=lim*ones(size(e,1),1);
      la=abs(e)+eps*ll;
      regul=sqrt(min(la,ll)./la);
      el=e.*regul;
      regule{kexp} = regul;
   end
   V = V + el'*el;
   lamtrue = lamtrue + e'*e;
   Nobs = Nobs + nobs;
   ec{kexp} = e;
   eic{kexp} = ei;
   elc{kexp} = el;
end
V = V/Nobs; 
lamtrue = lamtrue/(Nobs-truenpar);
if isnan(V)
   V = inf;lamtrue = inf;
   return
end

if ~grest,
   
   return,
end
if oeflag
   dat = iddata(elc,[]);
   try
      vmodel = n4sid(dat,5,'cov','none');
      vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
   catch
      vmodel = idpoly(1,1,'noisevariance',V);
   end
end

nr1=length(index);
R1=zeros(0,nr1+1);
M=floor(maxsize/n);
%grad=zeros(n,1);
if isempty(trfm),nr1=n;else nr1=size(trfm,1);end

for kexp = 1:length(ze);
   z = ze{kexp};
   [Ncap,nz]=size(z);nu=nz-1;
   ei = eic{kexp};
   el = elc{kexp};
   e = ec{kexp};
   nobs=Ncap-tstart+1;
   y=z(:,1);u=z(:,2:end);
   dec = ltk2(y,u,ecb,c,nc,tstart,na,nb,nk,nobs,ei);
   elong=[zeros(tstart-nc-1,1);ei.';e];
   y(1:tstart-na-1)=zeros(tstart-na-1,1);
   for ku=1:nu
      u(1:tstart-nk(ku)-nb(ku),ku)=zeros(tstart-nk(ku)-nb(ku),1);
   end
   
   y=[zeros(nc-tstart+1,1);y];u=[zeros(nc-tstart+1,nu);u];
   ef=filter(1,c,elong);
   yf=filter(1,c,y);uf=[];
   for ku=1:nu
      uf(:,ku)=filter(1,c,u(:,ku));  
   end
   
   ir=filter(1,c,[1;zeros(length(yf),1)]);
   zf=[-yf uf ef elong];
   [N,nz]=size(zf);zi=-dec; 
   if kexp==1
      nk1=[1 nk 1];
      end
   if isempty(nk1)
      nm = max(nn);
   else
      nm = max(nn+nk1)-1;
      if nm-max(nk1)<1
          nm  = nm + 1;
      end
   end
   tstart1=nm+1;
   z=[-y u elong];
   if nc>0
   mod=-zi*toeplitz(c(end:-1:2),[c(end),zeros(1,length(c)-2)]);
   mod1=zeros(tstart1-1,n);psis=[];
   ss=0;
   for kz=1:nz-1
      if nn(kz)>0
         
         mod1(1+nk1(kz):end,ss+1:ss+nn(kz))=...
            toeplitz(z(1:tstart1-1-nk1(kz),kz),[z(1,kz),zeros(1,nn(kz)-1)]);
      end
      ss=ss+nn(kz);
      
   end
   ll=conv2(ir,mod.'); 
   l2=conv2(ir,mod1);
else
    l1=ir; l2=ir;
end
   for kloop=nm:M:N-1
      jj=[kloop+1:min(N,kloop+M)];
      psi=zeros(length(jj),n);
      
      ss=0;
      for kz = 1:nz-1
         for kk=1:nn(kz)
            psi(:,ss+kk)=zf(jj-kk+1-nk1(kz),kz);
         end
         ss=ss+nn(kz);
      end
      try
      psi=psi+ll(1+jj(1)-tstart1:length(jj)+jj(1)-tstart1,:)...
         -l2(jj,:);
 end
      if ~isempty(trfm),psi=psi*trfm.';end
      psi=psi(:,index);
      jjarg = jj-tstart1+1;
      if max(jjarg)>size(psi,1);%(regule{kexp})
          jjarg = jjarg(1:end-1);
          psi = psi(1:end-1,:);
      end
      if lim~=0
          regul = regule{kexp};
          
         psi=psi.*(regul(jjarg)*ones(1,size(psi,2))); 
         
      end
      if oeflag
         [num,den]=tfdata(vmodel,'v');
         psi = filter(num,den,psi(end:-1:1,:))*sqrt(pvget(vmodel,'NoiseVariance'));
      end
      
      R1=triu(qr([R1;[psi,el(jjarg)]]));[nRr,nRc]=size(R1);
      R1=R1(1:min(nRr,nRc),:);
   end
end % loop over kexp
nr1=size(psi,2);
R=R1(1:nr1,1:nr1);Re=R1(1:nr1,nr1+1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,Nobs] = gnns(ze,par,struc,algorithm,oeflag);
back = 0;
if strcmp(lower(struc.init(1)),'b')
   back = 1;
end

if ~iscell(ze)
   ze = {ze};
end
V=inf;R=[];Re=[];lamtrue = V;Nobs = 0;

maxsize=algorithm.MaxSize;
lim=algorithm.LimitError;
stablim = algorithm.Advanced.Threshold.Zstability;
stab = strcmp(algorithm.Focus,'Stability');

T=struc.modT;
m0=struc.model;
dt=nuderst(par.')/100;  
try
    dflag = struc.dflag;
    dflag = dflag(:,1); % the parameter numbers
catch
    dflag = 0;
end

if any(dflag) 
    for kd = 1:length(dflag)
        dflagg = dflag(kd);
        pardel = par(dflagg);
        
        if floor((pardel-dt(dflagg)/2)/struc.modT-1e4*eps)~=...
                floor((pardel+dt(dflagg)/2)/struc.modT+1e4*eps)
            pardel=pardel+1.1*dt(dflagg); 
            dt(dflagg)=min(dt(dflagg),struc.modT);% To avoid numerical derivative over different sample-delays     
        end
        par(dflagg) = pardel;
    end
end

m0=parset(m0,par);
if ~struc.Tflag,m0=tset(m0,T);end
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
    stabtest = max(abs(eig(A)))>stablim;
else
    stabtest = 0;
end

if max(abs(ei))>stablim|stabtest
    return
end
rowmax=nx; 
if rowmax>0
    M=floor(maxsize/rowmax);
else
    M = maxsize;
end
V = zeros(ny,ny); lamtrue = V;
Nobs = 0;
Ne = length(ze);
for kexp = 1:Ne
    z = ze{kexp};
    Ncap = size(z,1);
    nobs = Ncap;
    if back
        X00 = x0est(z,A,B,C,D,K,ny,nu,maxsize);
        X0e{kexp} = X00;
   end
   X0 = X00;
   for kc=1:M:Ncap
      jj=(kc:min(Ncap,kc-1+M));
      if jj(length(jj))<Ncap,
         jjz=[jj,jj(length(jj))+1];
      else 
         jjz=jj;
      end
      xh=ltitr(A-K*C,[K B-K*D],z(jjz,:),X0);
      yh(jj,:)=(C*xh(1:length(jj),:).'+[zeros(ny,ny) D]*z(jj,:).').';
      [nxhr,nxhc]=size(xh);X0=xh(nxhr,:).';
   end
   e=z(:,1:ny)-yh;
   if lim==0
      el=e;
   else
      ll=ones(size(e,1),1)*lim;
      la=abs(e)+eps*ll;
      regul=sqrt(min(la,ll)./la);
      el=e.*regul;
   end
   ele{kexp} = el;
   V = V + (el'*el);  
   
   lamtrue = lamtrue + e'*e;  
   Nobs = Nobs + nobs;
   clear yh
end %kexp
TrueNobs = max(Nobs -length(par)/ny,1);
if back
   TrueNobs = max(TrueNobs -length(X0)*Ne/ny,1);
end
V = V/Nobs; lamtrue = lamtrue/TrueNobs; 
if isreal(z), V = real(V); lamtrue = real(lamtrue);end

if isnan(V)
   V = inf; lamtrue = V;
   return
end
if nargout==2
   return
end
sqrlam=struc.sqrlam;

if oeflag
   dat=iddata(ele,[]);
   try
      vmodel = n4sid(dat,3*ny,'cov','none');
      vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
      esqr = sqrtm(pvget(vmodel,'NoiseVariance'));
      [av,bv,cv,dv,kv] = ssdata(vmodel); cv1 = cv;
      av=av';cv=esqr*kv';kv=cv1'*(sqrlam*sqrlam');
      dv=esqr*(sqrlam*sqrlam');
   catch
      av = zeros(1,1);cv=zeros(ny,1);kv=zeros(1,ny);
      dv = sqrlam;
   end
   sqrlam = eye(ny);
end

index=algorithm.estindex;  
nd=length(par);
n=length(index);nd=n;
% *** Compute the gradient PSI. If N>M do it in portions ***
rowmax=max(n*ny,nx+nz);
M=floor(maxsize/rowmax);
R1=zeros(0,nd+1);
%dt=nuderst(par.')/100;  
for kexp = 1:length(ze);
   z = ze{kexp};
   Ncap = length(z);
   if back
      X0 = X0e{kexp};
   else
      X0 = X00;
   end
   
   for kc=1:M:Ncap
      jj=(kc:min(Ncap,kc-1+M));
      if jj(length(jj))<Ncap,jjz=[jj,jj(length(jj))+1];else jjz=jj;end
      psitemp=zeros(length(jj),ny);
      psi=zeros(ny*length(jj),n);
      x=ltitr(A-K*C,[K B-K*D],z(jjz,:),X0);
      yh=(C*x(1:length(jj),:).'+[zeros(ny,ny) D]*z(jj,:).').';
      e=z(jj,1:ny)-yh;
      [nxr,nxc]=size(x);X0=x(nxr,:).';
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
         th1=par;th1(kl)=th1(kl)+dt(kl)/2;
         th2=par;th2(kl)=th2(kl)-dt(kl)/2;
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
         try
             dA=(A1-A2)/dt(kl);dB=(B1-B2)/dt(kl);dC=(C1-C2)/dt(kl);
             dD=(D1-D2)/dt(kl); dK=(K1-K2)/dt(kl);
         catch
             th2=par;th2(kl)=th2(kl)+3*dt(kl)/2;
             m0=parset(m0,th2);
             [A2,B2,C2,D2,K2,X2] = ssdata(m0);
             if T>0&struc.Tflag
                  [A2,B2,Cc,D2,K2] = idsample(A2,B2,C2,D2,K2,T,struc.intersample);
             end
             dA=(A2-A1)/dt(kl);dB=(B2-B1)/dt(kl);dC=(C2-C1)/dt(kl);
             dD=(D2-D1)/dt(kl); dK=(K2-K1)/dt(kl);
         end
         if kc==1,
            if back
               X1 = x0est(z,A1,B1,C1,D1,K1,ny,nu,maxsize);
               X2 = x0est(z,A2,B2,C2,D2,K2,ny,nu,maxsize);
            end
            dX=(X1-X2)/dt(kl);
         else 
            dX=dXk(:,kl);
         end
         %dX
         psix=ltitr(A-K*C,[dA-dK*C-K*dC,dK,dB-K*dD-dK*D],[x,z(jjz,:)],dX);
         [rpsix,cpsix]=size(psix);
         dXk(:,kl)=psix(rpsix,:).';
         psitemp=(C*psix(1:length(jj),:).' + ...
            [dC,zeros(ny,ny),dD]*[x(1:length(jj),:),z(jj,:)].').'*sqrlam;
         if ~(lim==0),psitemp=psitemp.*regul;end
         if oeflag
            psitemp1=ltitr(av,kv,psitemp(end:-1:1,:));
            psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
         end
         
         psi(:,kkl)=psitemp(:);kkl=kkl+1;   
      end
      
      R1=triu(qr([R1;[psi,evec]]));[nRr,nRc]=size(R1);
      R1=R1(1:min(nRr,nRc),:);
   end
end %kexp
if any(any(isnan(R1))') | any(any(isinf(R1))')
   R = []; Re =[]; V = inf;
else
   R=R1(1:nd,1:nd);Re=R1(1:nd,nd+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,Nobs] = gnfree(ze,par,struc,algorithm)
if ~iscell(ze)
   ze={ze};
end

back = 0;
if strcmp(lower(struc.init(1)),'b')
   back = 1;
end
step = 0.0001; %%LL%%
V=inf;R=[];Re=[];lamtrue = V;Nobs = 0;
if ~isempty(par)
    struc = ssfrupd(par,struc); 
end
[p,n]=size(struc.c);
[n,m]=size(struc.b);

maxsize=algorithm.MaxSize;
lim=algorithm.LimitError;
stablim = algorithm.Advanced.Threshold.Zstability;
stab = strcmp(algorithm.Focus,'Stability');

if stab
   stabtest = max(abs(eig(struc.a)))>stablim;
else
   stabtest = 0;
end
ei = eig(struc.a - struc.k*struc.c);
if max(abs(ei))>stablim|stabtest
   return
end

rowmax=size(struc.a,1);
M=floor(maxsize/rowmax);
X01=struc.x0;
V = zeros(p,p); lamtrue =V;
Nobs = 0;
for kexp = 1:length(ze)
   z = ze{kexp};
   y=z(:,1:p);u=z(:,p+1:end);
   clear yh
   Ncap=size(z,1);
   nobs = Ncap;  
   if back
      X01=x0est(z,struc.a,struc.b,struc.c,struc.d,struc.k,p,m,maxsize);
      X01e{kexp} = X01;
      nobs = nobs - length(X01)/p;
   end
   for kc=1:M:Ncap
      jj=(kc:min(Ncap,kc-1+M));
      if jj(length(jj))<Ncap,
         jjz=[jj,jj(length(jj))+1];
      else 
         jjz=jj;
      end
      if kc == 1
         X0 = X01;
      end
      xh=ltitr(struc.a-struc.k*struc.c,[struc.k struc.b-struc.k*struc.d],z(jjz,:),X0);
      yh(jj,:)=(struc.c*xh(1:length(jj),:).'+ struc.d*z(jj,p+1:end).').';
      [nxhr,nxhc]=size(xh);X0=xh(nxhr,:).';
   end
   e=z(:,1:p)-yh;
   if lim==0
      el=e;
   else
      ll=ones(Ncap,1)*lim;
      la=abs(e)+eps*ll;
      regul=sqrt(min(la,ll)./la);
      el=e.*regul;
      regule{kexp}=regul; 
   end
   ele{kexp}=el;
   V = V+ el'*el;
   lamtrue = lamtrue + e'*e;
   Nobs = Nobs + nobs;
end % over kexp
V = V/Nobs; lamtrue = lamtrue/(Nobs-length(par)/p);
if isnan(V)
   V = inf; lamtrue = V;
   return
end

if nargout==2
   return
end

Qperp=struc.Qperp;
dkx=struc.dkx;
if back
   dkx(3)=0;
end
sqrlam=struc.sqrlam;
A=struc.a;B=struc.b;
C=struc.c;D=struc.d;
K=struc.k;x0=struc.x0;

nk=struc.nk;
if isempty(nk)
   snk=0;
else
   snk=sum(nk==0);
end

npar = n*(p+m) + dkx(1)*snk*p+ dkx(2)*n*p + dkx(3)*n;

npar1=size(Qperp,2);
ncol=npar1+1;size(C,1); 
M=floor(maxsize/ncol/p); % max length of a portion of psi
R1=zeros(0,ncol); 
for kexp = 1:length(ze)
   z = ze{kexp};
   u=z(:,p+1:end); 
   el =ele{kexp};
   if ~(lim==0),regul=regule{kexp};end
   
   Ncap = size(z,1);
   if back
      X01 = X01e{kexp};
      x0 = X01;
   end
   
   if ~isempty(B), % If not time series
      for kc=1:M:Ncap
         jj=(kc:min(Ncap,kc-1+M));
         if jj(end)<Ncap, jjz=[jj,jj(end)+1]; else jjz=jj;end
         psi = zeros(length(jj)*p,npar);
         X = ltitr((A-K*C),[K B],[z(jjz,:)],x0);
         nXr = size(X,1); x0=X(end,:).';
         
         a0 = zeros(n,n);
         b0 = zeros(n,m);
         c0 = zeros(p,n);
         d0 = zeros(p,m);
         k0 = zeros(n,p);
         dcur =1;
         for j = 1:n*(p*(1+dkx(2))+m),   % Gradients w.r.t. A,B,C and K
            a = a0; b = b0; c = c0; d = d0; k = k0;
            idx = 1; len = n*n; 
            a(:) = Qperp(idx:len,j);
            idx = idx+len; len = n*m;
            b(:) = Qperp(idx:idx+len-1,j);
            if dkx(2),
               idx = idx+len; len = n*p;
               k(:) = Qperp(idx:idx+len-1,j);
            end
            idx = idx+len; len = n*p;
            c(:) = Qperp(idx:idx+len-1,j);
            if kc==1
               if back
                  x0p = x0est(z,A+step*a,B+step*b,C+step*c,D,K+step*k,p,m,maxsize);
                  x0d=(x0p-X01)/step;
               else
                  x0d = zeros(n,1);
               end
            else
               x0d=x0dk(:,dcur);
            end
            
            Xbar = ltitr(A-K*C, [a-k*C-K*c, k, b-k*D], [X z(jjz,:)], x0d);
            x0dk(:,dcur) = Xbar(end,:).';
            psitmp = (Xbar(1:length(jj),:)*C.' + X(1:length(jj),:)*c.')*sqrlam;
            if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
            
            psi(:,dcur) = psitmp(:);
            dcur = dcur+1;
         end  % for j
         
         if dkx(1), % Gradient w.r.t. D
            for j=1:m*p,
               if any(ceil(j/p)==find(nk==0))
                  dd = d0(:);
                  dd(j) = 1;
                  d(:) = dd;
                  if dkx(2),
                     if kc==1
                        if back
                           x0p = x0est(z,A,B,C,D+step*d,K,p,m,maxsize);
                           x00=(x0p-X01)/step;
                        else
                           x00 = zeros(n,1);
                        end
                     else
                        x00=x0dk(:,dcur);
                     end
                     
                     Xbar = ltitr(A-K*C, -K*d, u(jjz,:) , x00);
                     x0dk(:,dcur)=Xbar(end,:).';
                     psitmp = ( Xbar(1:length(jj),:)*C.' + u(jj,:)*d.' )*sqrlam;
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
               if kc==1
                  x00 = zeros(n,1);
                  x00(j) = 1;
               else
                  x00=x0dk(:,dcur);
               end
               
               % We hit an assertion with LTITR(A,B,u) when A is complex
               % and the inner dimension of B*u is zero.  This needs to be
               % fixed, but for now I am working around it.  It's also not
               % clear to me that A-K*C should ever really be complex..
               % currently I'm only seeing the assertion on the IBM.  GJW
               %
               % Xbar = ltitr(A-K*C, zeros(n,0), zeros(length(jjz),0) , x00);
               Xbar = ltitr(A-K*C, zeros(n,1), zeros(length(jjz),1) , x00);
               x0dk(:,dcur) = Xbar(end,:).'; 
               psitmp = Xbar(1:length(jj),:)*C.'*sqrlam;
               if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
               psi(:,dcur) = psitmp(:);
               dcur = dcur+1;
            end   % for
         end  % if x0
         
         elt=el(jj,:)*sqrlam;  
         evec=elt(:);
         R1 = triu(qr([R1;[psi,evec]]));[nRr,nRc]=size(R1);
         R1 = R1(1:min(nRr,nRc),:);
      end % kc-loop 
      
   else  % If time series  
      [n,p]=size(K);
      y = z;
      N = length(y);
      
      npar = 2*n*p + dkx(3)*n;
      for kc=1:M:N-1
         jj=(kc:min(N,kc-1+M));
         if jj(end)<N, jjz=[jj,jj(end)+1]; else jjz=jj;end
         psi = zeros(length(jj)*p,npar);
         X = ltitr((A-K*C),[K],[y(jjz,:)],x0);
         nXr = size(X,1); x0=X(end,:).';
         
         
         a0 = zeros(n,n);
         c0 = zeros(p,n);
         k0 = zeros(n,p);
         dcur =1;
         for j = 1:n*p*2,   % Gradients w.r.t. A,C and K
            a = a0;
            c = c0;
            k = k0;
            b = B;
            d = D;
            idx = 1; len = n*n; 
            a(:) = Qperp(idx:len,j);
            idx = idx+len; len = n*p;
            k(:) = Qperp(idx:idx+len-1,j);
            idx = idx+len; len = n*p;
            c(:) = Qperp(idx:idx+len-1,j);
            if kc==1
               if back
                  x0p = x0est(z,A+step*a,B+step*b,C+step*c,D+step*d,K+step*k,p,m,maxsize);
                  x0d=(x0p-X01)/step;
               else
                  x0d = zeros(n,1);
               end
            else
               x0d=x0dk(:,dcur);
            end
            
            Xbar = ltitr(A-K*C, [a-k*C-K*c, k], [X y(jjz,:)], x0d);
            x0dk(:,dcur) = Xbar(end,:).';
            psitmp = (Xbar(1:length(jj),:)*C.' + X(1:length(jj),:)*c.')*sqrlam;
            if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
            psi(:,dcur) = psitmp(:);
            dcur = dcur+1;
         end
         
         if dkx(3), % Gradient w.r.t x0
            for j=1:n,
               if kc==1
                  x00 = zeros(n,1);
                  x00(j) = 1;
               else
                  x00 = x0dk(:,dcur);
               end
               
               Xbar = ltitr(A-K*C, zeros(n,1), y(jjz,1) , x00 );
               x0dk(:,dcur) = Xbar(end,:).';
               psitmp = (Xbar(1:length(jj),:)*C.')*sqrlam;
               if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
               psi(:,dcur) = psitmp(:);
               dcur = dcur+1;
            end;
         end
         elt=el(jj,:)*sqrlam;  
         evec=elt(:);
         R1 = triu(qr([R1;[psi,evec]]));[nRr,nRc]=size(R1);
         R1 = R1(1:min(nRr,nRc),:);
      end % kc-loop 
      
   end %kexp loop
   R=R1(1:npar,1:npar);Re=R1(1:npar,npar+1:ncol);
   if any(any(isnan(R1))') | any(any(isinf(R1))')
      R = []; Re =[]; V = inf; lamtrue = V;
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






