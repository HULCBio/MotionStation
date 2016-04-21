function [par,struc,it_inf,cov,lambda] = minloop(z,par,struc,algorithm,it_inf)
%MINLOOP  ** The minimization loop **

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.26.4.1 $  $Date: 2004/04/10 23:18:40 $

Xsum = findobj(get(0,'children'),'tag','sitb16');
if ~isempty(Xsum)
   XID = get(Xsum,'UserData');
   try
      XIDiter = XID.iter;
   catch
   end
end
oeflag = 0;
switch struc.type
case 'poly'
   if struc.na+struc.nc+struc.nd==0
      oeflag = 1;
   end
case 'ssnans'
   if ~any(any(isnan(struc.filearg.ks))')
      if norm(struc.filearg.ks)==0
         oeflag = 1;
      end
   end
case 'ssgen'
   m0 =struc.model;
   lnp = length(pvget(m0,'ParameterVector'));
   m0 = parset(m0,randn(lnp,1));
   if norm(pvget(m0,'K'))==0
      oeflag = 1;
   end
   
end
algorithm.FixedParameter = pnam2num(algorithm.FixedParameter,struc.pname);
if (length(algorithm.FixedParameter) == length(par))&length(par)>0
   error('All parameters are fixed. Nothing to estimate.')
end
if any(algorithm.FixedParameter>length(par))
  warning(['Some FixedParameter indices larger than parameter' ...
	   ' length.'])
  end

gui=0;
stopp=0;flag=[];
idp = 0;
try
    idp = strcmp(pvget(struc.model,'MfileName'),'procmod');
end
try
    if idp, tagg = 'sitb37';else tagg = 'sitb20';end
flag=findobj(get(0,'children'),'flat','tag',tagg);%37 is idproc
end
if ~isempty(flag),
   if strcmp(get(flag,'vis'),'on'),
       if ~idp
           stopb = XIDiter(7);
           nrb = XIDiter(4);
           fitb = XIDiter(5);
           impb = XIDiter(6);
           chkb = XIDiter(2);
       else
           stopb = XIDiter(11);
           nrb = XIDiter(13);
           fitb = XIDiter(15);
           impb = XIDiter(17);
           chkb = XIDiter(18);
       end
        gui=1;%set(stopb,'userdata',0); %stop button
   end,
end 
npar = length(par); 
N = 0;
if iscell(z)
for kexp = 1:length(z)
N = N + size(z{kexp},1);
end
else
    N = size(z,1);
end
if npar > N
    error('Too few data for this size of model.')
end
tol = algorithm.Tolerance;
maxiter = abs(algorithm.MaxIter);
impr=[];
ind1 = algorithm.FixedParameter;
ind2 = [1:npar]';
if isempty(ind1)
   ind3=ind2;
else
   indt = ind2*ones(1,length(ind1))~=ones(npar,1)*ind1(:)';
   if size(indt,2)>1, indt=all(indt');end
   ind3 = ind2(find(indt));%all((ind2*ones(1,length(ind1))~=ones(npar,1)*ind1)')))
end
%%LL FIXA LIM
algorithm.estindex=ind3;
lambda=struc.lambda;
if ~any(lambda(:))|norm(lambda)<eps %% This is to protect from strange initial model
   lambda=eye(size(lambda));
end

ny=1;                  
testnorm = tol+1;
stop = 0;stopp=0;
l = 0;
if strcmp(lower(algorithm.Trace),'on')
   dispmode = 1;
elseif strcmp(lower(algorithm.Trace),'full')
   dispmode = 2;
else
   dispmode = 0;
end

while [testnorm>tol l<maxiter stop~=1 norm(lambda)>eps] 
   l=l+1;
   
   if gui,
      drawnow,
      display=get(chkb,'value'); %full
      if display,dispmode = 2;else dispmode = 0; end
  end
   % Compute the Gauss-Newton direction *
   struc.sqrlam=inv(sqrtm(lambda));
   
   if strcmp(struc.type,'ssfree')
      if ~isempty(par)
         struc=ssfrupd(par,struc);
      end
      par=[];
      dkx=struc.dkx;m=struc.nu;p=struc.ny;n=struc.nx;nk=struc.nk;
      if dkx(2), bk = [struc.b struc.k];, else, bk = struc.b; end
      Qperp = fipert_qr(struc.a,bk,struc.c);
      if isempty(nk)
         nextra = dkx(3)*n;
      else
         nextra = dkx(1)*sum(nk==0)*p+dkx(3)*n;
      end
      if nextra>0,
         Qperp = [Qperp zeros(size(Qperp,1),nextra); zeros(nextra, ...
               size(Qperp,2)) eye(nextra)];
      end
      struc.Qperp=Qperp;
      
   end
  
   [lambda,tlam,psi,e,Nobs]=gnnew(z,par,struc,algorithm);
    V=abs(real(det(lambda))); %%LL;    
   if isempty(psi)
      error('Predictor has become unstable')
   end
   if algorithm.MaxIter<0
      parnew=par;
      lambda = tlam;
      break
   end
   
   if l==1
      delta = algorithm.Advanced.Search.LmStartValue*norm(psi);
   end
   testnorm=abs((e'*psi)*pinv(psi'*psi)*(psi'*e)*100/Nobs);  
   % No normalization wrt V for ss, since that   
   % is implicit in the lam-normalization 
   if strcmp(struc.type,'poly')
      testnorm=testnorm/lambda;
   end
   if dispmode
      disp(['Iteration ',int2str(l),':'])
   end
   
   [Vn,parnew,stop,delta,lambda,tlam]=msearch(V,z,par,struc,psi,e,delta,algorithm,...
      lambda,tlam,dispmode); 
   %  * Display the current values along with the previous ones *
    g=pinv(psi)*e;
   
   if dispmode      
      disp(['   Current loss: ' num2str(Vn) '   Previous loss: ' num2str(V)])
      if ~strcmp(struc.type,'ssfree')&dispmode>1
         t=zeros(npar,3); t(:,1)=parnew;t(:,2)=par;
         t(algorithm.estindex,3)=pinv(psi)*e;
         disp(['   New par   prev. par   gn-dir '])
         disp(t)
      end
      disp(['   Norm of gn-vector: ' num2str(norm(g))])
      disp(['   Expected improvement: ',num2str(testnorm),' %'])
      disp(['   Achieved improvement: ',num2str((V-Vn)*100/V),' %'])
      if stop==1
         disp('   No improvement of the criterion possible along the search direction.')
         disp('   Iterations therefore terminated.')
      end
   end %if display
   if gui
      set(nrb,'string',['Iteration ',int2str(l)]);
      set(fitb,'string',['Fit: ',num2str(Vn,3)]);
      set(impb,'string',['Improvement ',num2str((V-Vn)/V*100,3),' %']);
      %set(XIDiter(6),'string',num2str(testnorm));
      drawnow
      stopp=get(stopb,'userdata');
   end
   testnorm = max(testnorm,(V-Vn)*100/V); 
   par = parnew;impr = -(Vn-V)*100/V;V=Vn;
   V = abs(real(det(tlam))); 
   lambda = tlam;% For the noise Cov estimation we do not use robustification
   if strcmp(struc.type,'ssfree')
      struc=ssfrupd(par,struc);
      par=[];
   end
   if isnumeric(stopp)&stopp,break,end
end
if l==maxiter
   it_inf.WhyStop='Maxiter reached';
elseif stop
   it_inf.WhyStop='No improvement along search direction.';
else
   it_inf.WhyStop='Near (local) minimum, (norm(g)<tol).';
end
if strcmp(struc.type,'ssfree')
   npar = length(psi);
end

it_inf.UpdateNorm=testnorm;
it_inf.LastImprovement=[num2str(impr),'%']; 
it_inf.Iterations=l;
Vl = V*(1-npar/Nobs); % V has been compensated for # of pars
it_inf.LossFcn=Vl;
nparfpe = npar - length(algorithm.FixedParameter);
it_inf.FPE = Vl*(1+nparfpe/Nobs)/(1-nparfpe/Nobs);
it_inf.InitialState = struc.init;
if strcmp(struc.type,'ssfree')
   cov=[];
elseif ~struc.cov
   cov = 'None';
else
   cov = zeros(npar,npar);
   R = psi'*psi;
  
   if rcond(R)<5*eps
       it_inf.Warning = 'Covariance matrix estimate unreliable.';
   end
   sw = warning;
   warning('off')
   pin=inv(psi'*psi); 
   warning(sw)
   if oeflag    
      [lambda,tlam,psi,e,Nobs]=gnnew(z,par,struc,algorithm,1);
      pin = pin*(psi'*psi)*pin;
      lambda = tlam; % For the noise Cov estimation we do not use robustification
   end
   cov(ind3,ind3) = pin;
   if strcmp(struc.type,'poly')&~oeflag % the psi is not normalized by lamdba
      cov = V*cov;                
   end
   cov = (cov+cov')/2;
   covpflag = 0;
   try
      norm(cov);
   catch
       covpflag = 1;
   end
   if (~covpflag)&any(eig(cov)<0)
       covpflag = 1;
   end
   if covpflag
      warning('Covariance Matrix Ill-conditioned. Not stored.')
      cov = [];
   end
end

if isfield(struc,'realflag')
    realflag = struc.realflag;
else
    realflag = 1;
end
if realflag
    lambda = real(lambda);
end

