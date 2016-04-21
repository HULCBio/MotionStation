function m=ivx(data,nn,xe,maxsize,Tsamp,p);
%IDARX/IVX  Estimates (multivariate) ARX-models using instrumental variables
%
%   TH = ivx(Z,MODEL,X)
%
%   Z: The output-input data Z = [Y U] with the outputs Y
%   and the inputs U arranged in column vectors
%   MODEL is an IDARX model, with model orders [NA NB NK].
%     or directly given as MODEL = [NA NB NK].
%     [NA NB NK]: defines the model structure as follows:
%      NA: an ny|ny matrix whose i-j entry is the order of the
%       polynomial (in the delay operator) that relates the
%       j:th output to the i:th output
%      NB: an ny|nu matrix whose i-j entry is the order of the
%       polynomial that related the j:th input to the i:th output
%      NK: an ny|nu matrix whose i-j entry is the delay from
%       the j:th input to the i:th output
%   (ny: the number of outputs, nu: the number of inputs)
%   The parameters of MODEL play no role, just the orders.
%   X:  The instrumental variables. Same format as Y.
%
%   TH: the resulting model, given as an IDARX model object.
%
%   With TH=ivx(Z,MODEL,X,MAXSIZE,T) some additional
%   options can be achieved. See IDPROPS ALGORITHM for details.

%   L. Ljung 10-3-90
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $ $Date: 2004/04/10 23:15:09 $
na=nn.na;nb=nn.nb;nk=nn.nk; [ny,nu]=size(nb);

if nargin<6, p=1;end
if nargin<5, Tsamp=[];end
if p==1
   if  ~isa(data,'iddata')
      if isempty(Tsamp),Tsamp=1;end
      data = iddata(data(:,1:ny),data(:,ny+1:end),Tsamp);
   elseif ~isempty(Tsamp) 
      data = pvset(data,'Ts',Tsamp);
   end
   [ze,Ne,nyd,nud,Tsamp,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
   error(errflag)
   nz =nyd+nud;
   if ~iscell(xe), xe={xe};end
else % This is a call from  iv4
   
   ze = data;
   if ~iscell(ze),ze={ze};end
   Ne = length(ze);
   Ncaps =[];
   nz = size(ze{1},2);
   nud = nz-ny;
   nyd = ny;
   if length(xe)~=Ne
      error('The number of experiment in the data set must match the number of cells in x.')
   end
   
   for kexp = 1:Ne
      [Nc,nx] = size(xe{kexp});
      Ncaps = [Ncaps,size(ze{kexp},1)];
      if Ncaps(kexp)~=Nc | nx~=ny,
         error('The x-vector should be a column vector with the same number of elements as z!')
      end
   end
end

[ny,nu]=size(nn);
na=nn.na;nb=nn.nb;nk=nn.nk;
 
nma=max(max(na)');nbkm=max(max(nb+nk)')-1;nkm=min(min(nk)');
nd=sum(sum(na)')+sum(sum(nb)');
n=nma*ny+(nbkm-nkm+1)*nu;

% *** Set up default values **
maxsdef=idmsize(max(Ncaps),nd);
if nargin<4, maxsize=maxsdef;end

if maxsize<0, maxsize=maxsdef; end
if nargin<5, Tsamp=1;end
if isempty(Tsamp),Tsamp=1;end,
if isempty(maxsize),maxsize=maxsdef;end
% *** construct regression matrix ***

nmax=max([nma nbkm]');
M=floor(maxsize/n);
R=zeros(n);F=zeros(n,ny);
for kexp = 1:Ne
   z = ze{kexp};
   x = xe{kexp};
   Ncap = Ncaps(kexp);
   for k=nmax:M:Ncap-1
      if min(Ncap,k+M)<k+1,ntz=0;
      else 
         ntz=1;
      end
      if ntz,
         jj=(k+1:min(Ncap,k+M));phi=zeros(length(jj),n);phix=phi;
      end
      
      for kl=1:nma,
         if ntz,
            phi(:,(kl-1)*ny+1:kl*ny)=z(jj-kl,1:ny);
            phix(:,(kl-1)*ny+1:kl*ny)=x(jj-kl,1:ny);
         end
      end
      ss=nma*ny;
      
      for kl=nkm:nbkm,
         if ntz,
            phi(:,ss+(kl-nkm)*nu+1:ss+(kl-nkm+1)*nu)=z(jj-kl,ny+1:nz);
            phix(:,ss+(kl-nkm)*nu+1:ss+(kl-nkm+1)*nu)=z(jj-kl,ny+1:nz); 
         end
      end
      if ntz,
         R=R+phix'*phi; F=F+phix'*z(jj,1:ny);
      end
      
   end
end
%
% *** compute loss functions ***
%
par=[];parb=[];p11=[];p12=[];p22=[];lamm=[];
for outp=1:ny
   rowind=[];
   for kk=1:ny
      rowind=[rowind kk:ny:ny*na(outp,kk)];
   end
   for kk=1:nu
      baslev=nma*ny+(nk(outp,kk)-nkm)*nu;
      rowind=[rowind baslev+kk:nu:baslev+nu*nb(outp,kk)];
   end
   rowind=sort(rowind);
   th=R(rowind,rowind)\F(rowind,outp);
   k00=sum((nk(outp,:)==0) & (nb(outp,:)>0));
   naux=sum(na(outp,:));lth(outp)=length(th);
   ind1=1:naux;ind2=naux+k00+1:length(th);ind3=naux+1:naux+k00;
   par=[par th(ind1)' th(ind2)'];parb=[parb th(ind3)'];
end
m=nn;
m=parset(m,[par parb].');
e=pe(ze,m);
lamm=e'*e/(length(e)-nmax);
idm=m.idmodel;
idm=pvset(idm,'NoiseVariance',lamm);
m.idmodel=idm;
if p&~strcmp(pvget(nn,'CovarianceMatrix'),'None')
   for outp=1:ny
      rowind=[];
      for kk=1:ny
         rowind=[rowind kk:ny:ny*na(outp,kk)];
      end
      for kk=1:nu
         baslev=nma*ny+(nk(outp,kk)-nkm)*nu;
         rowind=[rowind baslev+kk:nu:baslev+nu*nb(outp,kk)];
      end
      rowind=sort(rowind);
      
      pth=inv(R(rowind,rowind));
      LAM=lamm(outp,outp);
      pth=LAM*pth;
      naux=sum(na(outp,:));
      k00=sum((nk(outp,:)==0) & (nb(outp,:)>0));
      
      ind1=1:naux;ind2=naux+k00+1:lth(outp);ind3=naux+1:naux+k00;
      
      [sp11,ssp11]=size(p11);lni=length(ind1)+length(ind2);
      p11=[[p11,zeros(sp11,lni)];[zeros(lni,sp11),[[pth(ind1,ind1),pth(ind1,ind2)];...
                  [pth(ind2,ind1),pth(ind2,ind2)]]]];
      [sp12,ssp12]=size(p12);
      p12=[[p12,zeros(sp11,length(ind3))];[zeros(lni,ssp12),[pth(ind1,ind3);pth(ind2,ind3)]]];
      [sp22,ssp22]=size(p22);
      p22=[[p22,zeros(sp22,length(ind3))];[zeros(length(ind3),ssp22),pth(ind3,ind3)]];
   end
   pvar=[[p11,p12];[p12',p22]];
   pvar = (pvar+pvar.')/2;
   try
      norm(pvar);
   catch
      disp('Covariance Matrix Ill-conditioned. Not stored.')
      pvar = [];
   end
   if any(eig(pvar))<0|any(diag(pvar)<0)
      disp('Covariance Matrix Ill-conditioned. Not stored.')
      pvar = [];
   end
else
   if strcmp(pvget(nn,'CovarianceMatrix'),'None')
      pvar = 'None';
   else
      pvar = [];
   end 
end

if p==1,
   if strcmp(pvget(nn,'CovarianceMatrix'),'None')
      pvar = 'None';
   end
   idm=pvset(idm, 'CovarianceMatrix',pvar);
   m.idmodel=idm;
   
   idm = m.idmodel;
   it_inf = pvget(idm,'EstimationInfo');
   it_inf.Method = 'IVX';
   it_inf.DataLength=sum(Ncaps);
   it_inf.DataTs=Tsamp;
   it_inf.DataInterSample=pvget(data,'InterSample'); 
   it_inf.Status='Estimated model (IVX)';
   it_inf.DataName=Name;
   V = det(lamm);
   it_inf.LossFcn = V;
   it_inf.FPE = V*(1+length(th)/sum(Ncaps))/(1-length(th)/sum(Ncaps));
   idm = pvset(idm,'ParameterVector',pvget(m,'ParameterVector'),'MaxSize',maxsize,'CovarianceMatrix',pvar,...
      'EstimationInfo',it_inf,'Ts',Tsamp,'NoiseVariance',lamm); 
   idm = idmname(idm,data);
   m.idmodel = idm; 
   m = timemark(m);
   
   
elseif p==2
   m1.model=m;
   m1.cov = pvar;
   m1.lam = lamm;
   
   m=m1;
end
