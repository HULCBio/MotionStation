function m = iv4(varargin)%data,nn,maxsize,T,p)
%IDARX/IV4 Computes approximately optimal IV-estimates for multivariate ARX-models
%
%   MODEL = IV4(DATA,Mi)
%
%   MODEL: returned as the estimate of the ARX model
%   A(q) y(t) = B(q) u(t-nk) + v(t)
%   along with estimated covariances and structure information.
%   For the exact format of MODEL see HELP IDARX.
%
%   DATA: the output-input data  and an IDDATA object. See HELP IDDATA. 
%
%   Mi: an IDARX object defining the orders. See help IDARX.
%
%   Some parameters associated with the algorithm are accessed by
%   MODEL = IV4(DATA,Mi'MaxSize',MAXSIZE)
%   where MAXSIZE controls the memory/speed trade-off. See the manual.
%   When property/value pairs are used, they may come in any order.
%   Omitted ones are given default values.
%   The MODEL properties 'FOCUS' and 'INPUTDELAY' may be set as a
%   Property/Value pair as in
%   M = IV4(DATA,Mi,'Focus','Simulation','InputDelay',[3 2]);
%   See IDPROPS ALGORITHM and IDPROPS IDMODEL.
%    
%   See also ARX, ARMAX, BJ, N4SID, OE, PEM.

%   L. Ljung 10-3-90
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2004/04/10 23:15:08 $


% *** Set up default values ***
[nn,data,p] = arxdecod(varargin{:});
na=nn.na;nb=nn.nb;nk=nn.nk; [ny,nu]=size(nb);
if p==1
   if  ~isa(data,'iddata')
      T=pvget(nn,'Ts');
      data = iddata(data(:,1:ny),data(:,ny+1:end),T);
   end
   if strcmp(pvget(data,'Domain'),'Frequency')
       error('IV4 currently does nor support Multi-ouput Frequency Domain Data.')
   end
   Inpd = pvget(nn,'InputDelay');
   foc = pvget(nn,'Focus');
   if ischar(foc)&strcmp(foc,'Stability')
      warning('Focus ''Stability'' currently not supported for multioutput ARX models.')
   end
   
   data = nkshift(data,Inpd);  
   [ze,Ne,nyd,nud,Ts,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
   error(errflag)
   nz =nyd+nud;
else % This is a call from  iv
   Ts = T;
   ze = data;
   if ~iscell(ze),ze={ze};end
   Ne = length(ze);
   Ncaps =[];
   nz = size(ze{1},2);
   nud = nz-ny;
   nyd = ny;
   foc = 'Prediction';
   for kexp = 1:Ne
      Ncaps = [Ncaps,size(ze{kexp},1)];
   end
end

if nu<=0,
   error('This routine is not intended for time series. Use ARX or AR instead.'),
end
if nud~=nu|nyd~=ny
   error(sprintf(['Mismatch between model orders and number of input/outputs.\n',...
         'For an AR model, nn = na should be a Ny-by-Ny matrix (Ny = # of outputs).\n',...
         'For an ARX model nn = [na nb nk], whera na is as above, and nb and nk\n',...
         'are Ny-by-Nu matrices (Nu = # of inputs).'])) 
end
nma=max(max(na)');nbkm=max(max(nb+nk)')-1;nkm=min(min(nk)');
nd=sum(sum(na)')+sum(sum(nb)');
n=nma*ny+(nbkm-nkm+1)*nu;

maxsize = pvget(nn,'MaxSize');
if strcmp(lower(maxsize),'auto')
   maxsize = idmsize(max(Ncaps),nd);
end

if (ischar(foc)&strcmp(foc,'Simulation'))|~ischar(foc) %% The focus
  foc0 = foc;
   nn = pvset(nn,'Focus','Prediction','InputDelay',zeros(nu,1));
   m0 = arx(data,nn);
   if isa(foc,'idmodel')|isa(foc,'lti') |iscell(foc)
       ts = pvget(data,'Ts');ts=ts{1};
       [num1,den1]=tfdata(m0);
       foc = foccheck(foc,ts,den1{1,1});
       
   else
      [num,den]=tfdata(m0);
      foc = {1,fstab(den{1,1})};
   end
   zf = idfilt(data,foc);
   m = iv4(zf,nn);
   m = pvset(m,'InputDelay',Inpd,'Focus',foc0);
   return
end
% *** Do some consistency tests ***


%
% *** First stage: compute an LS model ***
%

th=arx(ze,nn,maxsize,Ts,0);
a=ssdata(th);
maxa=max(abs(eig(a)));
if maxa>1, %Stabilize!
   [a,b]=arxdata(th);[nar]=size(a,3);
   for ka=2:nar
      a(:,:,ka) =((0.9/maxa)^ka)*a(:,:,ka);%ka*ny+1:(ka+1)*ny);
   end
   th=idarx(a,b);
end
%
% *** Second stage: Compute the IV-estimates using the LS
%     model a, b for generating the instruments ***
%
for kexp = 1:Ne
   z = ze{kexp};
   yh{kexp}=idsim(z(:,ny+1:nz),th,[],1);
   for outp=1:ny
      if norm(yh{kexp}(:,outp),inf)<eps,
         error(sprintf(['Output number %d is decoupled from all inputs',....
               '\n IV4 cannot be used.',outp]))
      end
   end
end
th=ivx(ze,nn,yh,maxsize,Ts,0);
a=ssdata(th);
maxa=max(abs(eig(a)));
while maxa>1, %Stabilize!
   [a,b]=arxdata(th);nar=size(a,3);
   for ka=2:nar
      a(:,:,ka) =((0.9/maxa)^ka)*a(:,:,ka);%ka*ny+1:(ka+1)*ny);
   end
   th1=idarx(a,b);
   a=ssdata(th1);
   maxa = max(abs(eig(a)));
   th=th1;
end

%
% *** Third stage: Compute the residuals, v, associated with the
%     current model, and determine an AR-model, A, for these ***
%
for kexp = 1:Ne
   v1=pe(ze{kexp},th);
   if ny>1, v1=sum(v1')';end
   v{kexp} = v1;
end
art=arx(v,(max(sum(na))+max(sum(nb))),maxsize,Ts,0);

%
% *** Fourth stage: Use the optimal instruments ***
%
for kexp= 1:Ne
   z = ze{kexp};
   for kz=1:nz
      zf1(:,kz)=filter([1 art.'],1,z(:,kz));
   end
   zf{kexp}=zf1;
   xf{kexp}=idsim(zf1(:,ny+1:nz),th,[],1);
end
th=ivx(zf,nn,xf,maxsize,Ts,2);
m=th.model;
lamm=th.lam;
pcov = th.cov;
try
   norm(pcov);
catch
   disp('Covariance Matrix Ill-conditioned. Not stored.')
   pvar = [];
end
idm = m.idmodel;
it_inf = pvget(idm,'EstimationInfo');
it_inf.Method = 'IV4';
it_inf.DataLength=sum(Ncaps);
it_inf.DataTs=Ts;
it_inf.DataInterSample=pvget(data,'InterSample'); 
it_inf.Status='Estimated model (ARX)';
it_inf.DataName=Name;
V =det(lamm);
it_inf.LossFcn = V;
it_inf.FPE = V*(1+length(th)/sum(Ncaps))/(1-length(th)/sum(Ncaps));
idm = pvset(idm,'MaxSize',maxsize,'CovarianceMatrix',pcov,...
   'EstimationInfo',it_inf,'Ts',Ts,'NoiseVariance',lamm);
idm = idmname(idm,data);
m.idmodel = idm; 
m = timemark(m);

