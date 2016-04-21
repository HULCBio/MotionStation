function th = ivar(data,na,nc,maxsize,T)
%IVAR   Computes IV-estimates for the AR-part of a scalar time series.
%   MODEL = IVAR(Y,NA)
%
%   MODEL: returned as the IV-estimate of the AR-part of a time series
%   model
%   A(q) y(t) =  v(t)
%   along with relevant structure information. (For the exact structure
%   of MODEL see HELP IDPOLY.
%
%   Y : the time series as a singel output IDDATA object. See HELP IDDATA
%
%   NA: the order of the AR-part (the A(q)-polynomial)
%
%   In the above model v(t) is an arbitrary process, assumed to be a
%   (possibly time-varying) moving average process of order NC. The
%   default value of NC is NA. Other values of NC are obtained by
%   MODEL = IVAR(Y,NA,NC)
%
%   With
%   TH = IVAR(Y,NA,NC,maxsize)
%   no matrix with more elements than maxsize is formed by the algorithm.
%   See also AR.

%   L. Ljung 4-21-87
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2001/04/06 14:22:27 $

if nargin < 2
   disp('Usage: TH = IVAR(Y,ORDER)')
   disp('       TH = IVAR(Y,ORDER,MA_ORDER,MAXSIZE,T)')
   return
end
if nargin < 5
   T =[];
end
if isempty(T), T=1;end
if ~isa(data,'iddata')
   data = iddata(data,[],T);
end
[yor,Ne,ny,nu,T,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
error(errflag)
y = yor; % Keep the original y for later computatation of e
if ny>1
   error('Only scalar time series can be handled. Use ARX for multivariate signals.')
end
if nu>0
   error('This routine is for scalar time series only. Use ARX for the case with input.')
end
% *** Some initial tests on the input arguments ***
%
maxsdef=idmsize(max(Ncaps));

 if nargin<4, maxsize=maxsdef;end
if nargin<3, nc=na;end
 if maxsize<0,maxsize=maxsdef;,end,if nc<0,nc=na;end
 if isempty(maxsize),maxsize=maxsdef;end,
if isempty(nc),nc=na;end
 if length(na)>1,error(' NA should be a single number!'),return,end

% *** Estimate a C-polynomial by first building a high order AR-model and
%     then using the corresponding residuals as inputs in an ARX-model ***

ar=arx(y,na+nc,maxsize,T,0);
for kexp = 1:Ne
   e=filter([1 ar.'],1,y{kexp});
   yyy{kexp}=[y{kexp},e];
end

ac=arx(yyy,[na nc 1],maxsize,T,0);
c=fstab([1 ac(na+1:na+nc).']);

% *** construct instruments ***

for kexp = 1:Ne
   Ncap = Ncaps(kexp);
     xx=[zeros(nc,1);y{kexp}(1:Ncap-nc)];
     cc=conv(c,c);
     x{kexp}=filter(1,cc,xx);
     end
     par= ivx(y,na,x,maxsize,T,0);
     th = idpoly([1,par.'],[]);
     e=pe(y,th);
     V=e'*e/(length(e)-na-nc);
     R = zeros(0,na+nc);
     R1 = zeros(na+nc,na+nc);
     for kexp = 1:Ne
        Ncap =Ncaps(kexp);
        yf=filter(1,c,y{kexp});
        e = pe(y{kexp},th);
     ef=filter(1,c,e);
     M=floor(maxsize/(na+nc));
     
     for k1=max(na,nc):M:Ncap-1
        jj=(k1+1:min(Ncap,k1+M));
        psi=zeros(length(jj),na+nc);
        for k=1:na, psi(:,k)=yf(jj-k);end
        for k=1:nc, psi(:,na+k)=ef(jj-k);end
        R= triu(qr([R;psi]));[nRr,nRc]=size(R);
        R = R(1:min(nRr,nRc),:);

        R1=R1+psi'*psi;
     end
  end
  
 es = pvget(th,'EstimationInfo');
es.FPE = V*(1+na/Ncap)/(1-na/Ncap);
es.Status = 'Estimated Model (IVAR)';
es.Method = 'IVAR';
es.DataLength = length(y);
es.LossFcn = V;
es.DataTs = T;
es.DataInterSample = 'Not Applicable';
idm=pvget(th,'idmodel');%modsg(th,'g');
P=V*pinv(R'*R);
idm=pvset(idm,'Ts',T,'CovarianceMatrix',P(1:na,1:na),'NoiseVariance',V,...
   'EstimationInfo',es,...
   'OutputName',pvget(data,'OutputName'),'OutputUnit',...
   pvget(data,'OutputUnit'));
th = pvset(th,'idmodel',idm);%.idmodel=idm;
th = timemark(th);


     
