function [segm,V,thm,r2e]=segment(z,nn,r2,q,r1,M,th0,p0,lifelength,mu)
%SEGMENT  Segments data and tracks abruptly changing systems.
%   [segm,V] = SEGMENT(z,nn,r2,q)
%
%   z : An IDDATA object or the output-input data matrix z = [y u].
%       The routine is for single output data only.
%   nn: ARX or ARMAX model orders nn = [na nb nk] or nn = [na nb nc nk].
%       See also ARX or ARMAX. The algorithm handles multi-input systems.
%
%   r2: The equation error variance(Default:estimated, but better to guess)
%   q : The probability that the system jumps at each sample.(Default 0.01)
%   segm: The parameters of the segmented data. Row k is for sample # k
%         The parameters are given in "alphabetical order".
%   V: The loss function corresponding to segm
%   The time-varying estimates th, and the estimated values of r2 are given
%   by   [segm,V,th,r2] = SEGMENT(z,nn)
%
%   Additional design variables are reached by
%   [segm,V,th,r2]=SEGMENT(z,nn,r2,q,R1,M,th0,P0,ll,mu)
%   R1: covariance matrix of the parameter jumps. (Default Identity matrix)
%   M: Number of parallel models to be used (Default 5)
%   th0:Initial parameter estimates (row vector)
%   P0:Initial covariance matrix (Def 10*I). ll:Guaranteed lifelength of
%   each model(Def 1). mu: Forgetting factor in r2-estimation (Def 0.97).
%   Reference: P. Andersson Int J Control, Nov 1985.

%   L. Ljung 10-1-89
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:22:29 $
if nargin < 2
   disp('Usage: SEGM = SEGMENT(DATA,ORDERS)')
   disp(['       [SEGM,LOSS] = SEGMENT(DATA,ORDERS,NOISE_VAR,JUMP_PROB,',...
         'JUMP_SIZE,No_OF_MODELS,TH0,P0,LL,MU)'])
   return
end
if isa(z,'iddata')
   y = pvget(z,'OutputData');
   u = pvget(z,'InputData');
   z = [y{1},u{1}];
end

[Ncap,nz]=size(z);
if Ncap<nz,disp('Warning: Have you entered the data as column vectors?'),end
nu=nz-1; nl=length(nn);
if nu==0,na=nn(1);nb=0;nc=0;nk=1;if nl>1,nc=nn(2);end
   if nl>2,error('For a time series, nn = na or nn = [na nc]!'),end
else
   na=nn(1);nb=nn(2:nu+1);
   if nl==2*nu+1,nk=nn(nu+2:2*nu+1);nc=0;
   else if nl==2*nu+2,nc=nn(nu+2);nk=nn(nu+3:2*nu+2);
      else error('Incorrect number of orders specified: nn=[na nb nk] or nn=[na nb nc nk]'),end,end
end
d=na+sum(nb)+nc; % Number of parameters
if nargin<10, mu=[];end
if nargin<9, lifelength=[];end
if nargin<8 p0=[];end
if nargin<7,th0=[];end
if nargin<6 M=[];end
if nargin<5 r1=[];end
if nargin<4 q=[];end
if nargin<3 r2=[];end
if isempty(q),q=0.01;end
if isempty(r1),r1=eye(d);end
if isempty(M),M=5;end
if isempty(th0),th0=zeros(1,d);end
if isempty(p0),p0=10*eye(d);end
if isempty(lifelength),lifelength=1;end
if isempty(mu),mu=0.97;end
if isempty(r2),r2dum=1;R2v=ones(1,M);r2=r2dum;estr2=1;else estr2=0; end;
alfa=1/M*ones(1,M);%[1,zeros(1,M-1)];

thm=zeros(Ncap,d);
Phicap=zeros(Ncap,d);
th=th0'*ones(1,M);age=zeros(1,M);hist=zeros(Ncap,M);r2e=zeros(Ncap,1);
P=[]; for i=1:M,P=[P p0/r2];end;

if nc>0,nu=nu+1;nk(nu)=1;nb(nu)=nc;z(1:nc,nu+1)=zeros(nc,1);end
for i=max([na+1,max(nb+nk),nc+1]):Ncap
   phi=[-z(i-1:-1:i-na,1)];
   for ku=1:nu,
      phi=[phi;z(i-nk(ku):-1:i-nk(ku)-nb(ku)+1,1+ku)];
   end
   y=z(i,1);
   for j=1:M,
      Pj=P(:,d*(j-1)+1:d*(j-1)+d);
      den(j)=(r2+phi'*Pj*phi);
      
      epsi(j)=y-th(:,j)'*phi;
      
      alfabar(j)=alfa(j)/sqrt(den(j))*exp(-epsi(j)^2/(2*den(j)));
      th(:,j)=th(:,j)+1/den(j)*P(:,d*(j-1)+1:d*(j-1)+d)*phi*epsi(j);
      P(:,d*(j-1)+1:d*(j-1)+d)=Pj-(Pj*phi*phi'*Pj)/den(j);
   end;
   
   aind=find((age(1:M)>lifelength));if length(aind)>0,
      [dummy,jmin]=min(alfabar(aind));jmin=aind(jmin);
      [dummy,jmax]=max(alfabar);
      
      P(:,d*(jmin-1)+1:d*(jmin-1)+d)=P(:,d*(jmax-1)+1:d*(jmax-1)+d)+r1;
      th(:,jmin)=th(:,jmax);
      alfabar(jmin)=q*alfabar(jmax);age(jmin)=0;
      hist(:,jmin)=hist(:,jmax);hist(i,jmin)=1;
   else jmax=1;end
   age=age+ones(1,M);
   alfa=1/sum(alfabar)*alfabar;
   
   theta=th*alfa';
   epsilon=y-theta'*phi;if nc>0,z(i,nu+1)=epsilon;end
   %
   %       estimate R2
   %
   if estr2
      r2dum=r2dum+(1-mu)*(epsilon^2-r2dum);
      agedum=max(age,2)-1;
      R2v= R2v +max(ones(1,M)./agedum,(1-mu)).*(epsi.^2./den-R2v);
      Rr=R2v(find(age>d));
      if length(Rr)>0,r2=min(Rr);else r2=r2dum;end
      
   end
   thm(i,:)=theta';r2e(i)=r2;Phicap(i,:)=phi';
end
hh=hist(:,jmax);
kk=find(hh==1);
kk=[1 kk' Ncap];
nn=length(kk);
for k=2:nn
   segm(kk(k-1):kk(k),:)=ones(kk(k)-kk(k-1)+1,1)*thm(kk(k),:);
end
e=z(:,1)-sum(segm'.*Phicap')';
V=e'*e/Ncap;
