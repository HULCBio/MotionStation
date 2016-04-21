function [m,bestchoice,nchoice,failflag] = n4sid(dat,order,varargin)
%N4SID  Estimates a state-space model using a sub-space method.
%   
%   MODEL = N4SID(DATA) or MODEL = N4SID(DATA,ORDER) 
%
%   MODEL: Returned as the estimated state-space model in the IDSS format.
%   DATA: The output input data as an IDDATA object. See HELP IDDATA.
%   ORDER: The order of the model (Dimension of state vector). If entered
%       as a vector (e.g. 3:10) information about all these orders will be
%       given in a plot. (Note that input delays (NK, see below) larger
%       than 1 will be appended as extra states, giving a resulting model 
%       of higher order.) If ORDER is entered as 'best', the default order among
%       1:10 is chosen. This is the default choice.
%   ORDER can also be an IDSS model object, in which case all model structure
%      and algorithm properties are taken from this object.
%
%   By MODEL = N4SID(DATA,ORDER,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See IDPROPS IDSS and IDPROPS ALGORITHM for a list of
%   Property/Value pairs.
%   Useful model structure properties are
%     'Focus' : ['Prediction'|'Simulation'|Filter,|'Stability'].
%               'Simu' and 'Stab' guarantee a stable model.
%     'nk': row vector of delays from the different inputs.
%     The initial state is always estimated, but delivered in MODEL only if
%     'InitialState' = 'Estimate'.
%     If 'DisturbanceModel' = 'None', the K-matrix is returned as 0,
%     and a stable model is guaranteed. Default is
%      'DisturbanceModel' = 'Estimate'.
%
%   Computing the covariance information takes most of the time. Setting 
%   'CovarianceMatrix' = 'None' suppresses these calculations.
%   
%   The algorithm is affected by the properties
%   'N4Weight': ['Auto'|'MOESP'|'CVA']  Determines the weightings
%                before the SVD. 'Auto' makes an automatic choice.
%   'N4Horizon': Determines the prediction horizons used by the algorithm.
%       N4Horizon =[r,sy,su], where
%       r: the maximum prediction horizon
%       sy: The number of past outputs used in the predictors
%       su: The number of past inputs used in the predictors
%       If N4Horizon has several rows, each row will be tried.
%       N4Horizon = 'Auto' (default) estimates reasonable horizons.
%       In case 'DisturbanceModel' = 'None', this default choice uses sy = 0.
%
%   'Trace':  ['On'|'Off']  'On' gives info to screen
%       about fit and choice of N4Horizon
%   'MaxSize': No matrix with more than maxsize elements is
%       formed. Loops are used instead when necessary.
%
%   See also  PEM and HELP IDPROPS.

%   M. Viberg, 8-13-1992, T. McKelvey, L. Ljung 9-26-1993.
%   Rewritten; L. Ljung 8-3-2000.
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.41.4.2 $  $Date: 2004/04/10 23:19:08 $

Xsum = findobj(get(0,'children'),'tag','sitb16');
XIDplotw =[];
if ~isempty(Xsum)
   XID = get(Xsum,'UserData');
   try
      XIDplotw = XID.plotw;
   catch
   end
end    
TH=[];bestchoice=[];nchoice=[];failflag=0;
arg='nogui';
if nargin<1
   disp('Usage: TH = N4SID(Z);')
   disp('       TH = N4SID(Z,ORDER,Prop_1,Value_1,...,Prop_n,Value_n);')
   return
end
if nargin == 1
   order = 'best';%[1:10];
end
if ischar(order)&length(order)>1&~strcmp(lower(order(1:2)),'be') %Omitted structure
   varargin=[{order},varargin];
   order = 'best';
end
if ischar(order)&length(order)>1&strcmp(lower(order(1:2)),'nx')%nx as in pem
   if nargin<=2
      error('Model order must be supplied after ''nx''.')
   end
   order = varargin{1};
   varargin = varargin(2:end);
end

ny = 1;
Ts = 1;
if nargin>2%&~isstr(varargin{1}) % Old syntax
   try
      if strcmp(varargin{end},'guichoice')
         arg = 'guichoice';
         varargin=varargin(1:end-1);
      elseif strcmp(varargin{end},'gui')
         arg = 'gui';
         varargin=varargin(1:end-1);
      end
   catch 
   end
end
if isa(dat,'frd')
    dat = idfrd(dat);
end
if isa(dat,'idfrd')
    dat = iddata(dat);
end
idfrdflag=0;
try
    ut = pvget(dat,'Utility');
    if ut.idfrd
        idfrdflag = 1;
    end
end
if idfrdflag
    ln = length(varargin);
    varargin{ln+1} ='InitialState';
    varargin{ln+2} = 'Zero';
end

if length(varargin)>0
   if ~ischar(varargin{1}) % old syntax
      if isa(dat,'iddata')
         nu = size(dat,'nu');
         ny = size(dat,'ny');
         if ny == 0
             error('The data set must contain an output signal.')
         end
         nz = nu+ny;%size(dat,'nu')+size(dat,'ny');
      else
         nz = size(dat,2);
      end
      [ny,Ts,varargin] = transf(varargin,nz);
   end
end
if isa(dat,'iddata')
    setid(dat);
    [varargin,datarg] = pnsortd(varargin);
    if ~isempty(datarg), dat = pvset(dat,datarg{:});end
    dom = pvget(dat,'Domain');
    if isempty(pvget(dat,'Name'))
    dat=pvset(dat,'Name',inputname(1));
end

else
    dom = 'Time';
end
if strcmp(dom(1),'F')
    m = n4sid_f(dat,order,varargin{:},arg,XIDplotw);
    return
end

if ~isa(dat,'iddata')
   if isa(order,'idss')|isa(order,'idpoly')
      ny=size(order,1);
   else
      %ny = 1; 
      if size(dat,2)>2 &ny==1  
          disp('Data interpreted as single-output.')
      end
  end
  dat=iddata(dat(:,1:ny),dat(:,ny+1:end),Ts);
end
[N,ny,nu]=size(dat);
if ny == 0
    error('The data set must contain an output signal.')
end
if nargin < 2, order=[];end
if isempty(order),order='best';end
imatch = strmatch('nk',lower(varargin(1:2:end))); % Lift out nk to avoid double work
nk=ones(1,nu);
if ~isempty(imatch)
   nk = varargin{2*imatch};
   nk=nk(:)';
   if length(nk)~=nu
      error('NK must be a row vector of length NU (# of inputs).')
   end
   varargin = varargin([1:2*imatch-2,2*imatch+1:end]);
   nkset = 1;
else
   nkset = 0;
end
if isa(order,'idss')
    [nmy,nmu] = size(order);
    if nmy~=ny|nmu~=nu
        error('The input/output size of the model does not agree with data size.')
    end
        
   mprel=order;order=size(mprel,'nx');
   if ~nkset
      nk = pvget(mprel,'nk'); 
   else
      mprel =pvset(mprel,'nk',nk);
   end
   if length(varargin)>1
      set(mprel,varargin{:});  
   end
   def_order = 0;
else
   if ischar(order)
        if min(N) <= (ceil(10/ny)+1)*(1+ny+nu) + (1+nu+ny)*ceil((10-ny+1)/(nu+ny))
      %if min(N)<19*ny+30*(nu+1)+1
         error('There are too few data points to support this order choice.')
      end
      def_order=1;order=1:10;
   else 
      def_order=0;
   end
   
   nxx = min(order);
   
   if nxx<=0|floor(nxx)~=nxx
      error('The order must be a positive integer.')
   end
   c = [eye(ny),zeros(ny,nxx)];
   c = c(:,1:nxx);
   mprel=idss(randn(nxx,nxx),ones(nxx,nu),c,zeros(ny,nu),zeros(nxx,ny),...
      zeros(nxx,1),'Ks',NaN*ones(nxx,ny));
   
   mprel = pvset(mprel,'SSParameterization','Free');%'Ks',NaN*ones(1,ny));
   if nargin>2&length(varargin)>0
      try
         set(mprel,varargin{:}) % should skip 'Canonical' here
         %Here is a question of InitialState = 'auto'.
      catch
         error(lasterr)
      end
   end
end
delayu=find(nk>1);
nks = max(nk-1,zeros(size(nk)));
idmod=pvget(mprel,'idmodel');

%&&&&& Testing for different sampling intervals:
Tsdata = pvget(dat,'Ts');
T = unique(cat(1,Tsdata{:}));
if length(T)>1
    if pvget(idmod,'Ts')~=0
        error(sprintf(['You cannot build a discrete time model from data with',...
                ' different sampling intervals.\nUse M= N4SID(data,order,...''ts'',0).']))
    else
        modk = 0;
        for ts = T'
            modk = modk + 1;
            nr = find(ts==cat(1,Tsdata{:}));
            mk{modk} = n4sid(getexp(dat,nr),mprel);
        end
        m = merge(mk{:});
        return
    end
end
%&&&&&
inpd = pvget(idmod,'InputDelay');

if pvget(idmod,'Ts') == 0 & inpd ~= 0
    Ts = pvget(dat,'Ts'); 
    for kexp = 1:length(Ts)
        Tse = Ts{kexp};
        inpd = inpd/Tse;
        if any(inpd ~= fix(inpd))
            error(sprintf(['The InputDelay for a time continuous model must ',...
                    'be a multiple of the data sampling interval.']))
        end
    end
end
if ~strcmp(pvget(idmod,'CovarianceMatrix'),'None')&...
      (2*ny+nu)*max(order)>200 % more than 100 canonical parameters
   disp(sprintf([' With these orders, calculating covariance information may take'...
         '\n a substantial time. For preliminary models, consider adding the',...
         '\n Property/Value pair ...,''Cov'',''None'',... to the input arguments.\n']))
end
dat1 = nkshift(dat,inpd'+nks);
[z,Ne,ny,nu,Ts,Name,Ncaps,errflag]=idprep(dat1,0,inputname(1));
error(errflag)
Ncap = max(Ncaps);
%if pvget(mprel,'Ts')==0
%   error('N4SID does not handle continuous time models')
%end

if ~isa(mprel,'idss')
   error(sprintf(['N4SID only handles IDSS model objects',...
         '\nor models defined by state space order.']))
end

if strcmp(pvget(mprel,'SSParameterization'),'Structured')
   error('N4SID does not handle the ''Structured'' SSParameterization')
end
focus = pvget(mprel,'Focus'); 
if nu == 0 & ~strcmp(focus,'Prediction')
   warning('For time-series, ''Focus'' does not apply.')
   mprel = pvset(mprel,'Focus','Prediction');
   focus = 'Prediction';
end

if isa(focus,'lti')|isa(focus,'idmodel')|iscell(focus)|isa(focus,'double')
   mprel = pvset(mprel,'nk',(nk>0)); 
   if length(order)>1
     txt=sprintf(['The order selection feature currently cannot  be' ...
		  '\nused together with the Focus=''Filter'' option.'...
		  '\n \nIf you would like to determine the order based' ...
		   ' on filtered data,\nfirst filter the data and' ...
		    ' then call N4SID/PEM. \nFor the chosen model' ...
		     ' order you can then call\nN4SID with the' ...
		      ' original data and the desired Focus option.']);
     error(txt)
     end
   % if ordchoice filtrera dat1 -->zf
   %  m = n4sid(zf,orders,'foc','sim')
   %  mprel.a etc = m.a
   %  m = n4sid(dat1,mprel)
   %  else ...
   try
   m = n4focus(dat1,mprel,focus,Ts);
   catch
     error(lasterr)
     end
   m = pvset(m,'nk',nk);
   return
end


if any(nk==0),dkx(1)=1;else dkx(1)=0;end 
if any(any(isnan(pvget(mprel,'Ks')))') 
   dkx(2)=1;
else
   dkx(2)=0;
end
if any(isnan(pvget(mprel,'X0s')))
   dkx(3)=1;
else
   dkx(3)=0;
end
if nu==0&dkx(2)==0
   error('For a time-series model, the K-matrix has to be estimated.')
end

maxsize=pvget(idmod,'MaxSize'); 
if ischar(maxsize)
   maxsize = idmsize(Ncap,max(order)*ny);
end

n4w = pvget(idmod,'N4Weight');
if strcmp(n4w,'Auto')
   if nu == 0
      n4w = 'CVA';
   else
      n4w = 'CVA';
   end
end
n4h = pvget(idmod,'N4Horizon');
n=ceil(max(order)); 
dispmode = 1;
if ischar(n4h)
try
    n4h = auxdef(z,dkx,n,ny,nu,focus,maxsize,Ncap);
catch
    error(lasterr)
end
   dispmode = 0;
end
[nraux,ncaux]=size(n4h);
%if ncaux<5,error('AUXORD should have 5 columns'),end
if nraux>1,tryaux=1;else tryaux=0;end, Vmin=inf;
if length(order)>1,
   ordchoice=1;
   if tryaux
      error(['The chosen ORDER cannot be a vector when N4Horizon has several' ...
            ' rows.'])
   end
else
   ordchoice=0; 
end

% if auxord has several rows, loop over them
if strcmp(arg,'gui')&tryaux
   figure(XIDplotw(11,1))
end
for naux=1:nraux
   try
   [auxact,maxsize,nrr]=...
      orders(n,n4h(naux,:),maxsize,Ncap,ny,nu,dkx,dispmode); 
catch
    error(lasterr)
end
   raa=auxact(1);s1aa=auxact(2);s2aa=auxact(3); 
   if strcmp(n4w,'CVA'),auxact(4)=1;else auxact(4)=0;end
   
   if strcmp(arg,'guichoice')
      hh=findobj(XIDplotw(10,1),'label',menulabel('&Help'));
      R1=get(hh,'userdata');info=R1{1};R=R1{2};nkold = R1{3};
      if nkold ~=nk
         errordlg(['The input delays for which the multi-order model was computed ',...
               '(',int2str(nkold),') do not agree with the current call (nk = ',...
               int2str(nk),').'])
         m = [];
         return 
      end
      ny=info(1);auxact=info(2:5);nu=info(6);Ncap=info(7); %%LL%% Think of Ncap here
      raa=auxact(1);s1aa=auxact(2);s2aa=auxact(3);
      if auxact(4)
         n4w = 'CVA';
      else
         n4w = 'MOESP';
      end
      
      n=order;
   else 
      [R,failflag2]=buildR(z,maxsize,nrr,raa,s1aa,s2aa,ny,Ncaps,nu);
   end
   [nrR,ncR]=size(R);
   ind3=nu*(raa+s2aa)+ny*s1aa+1:nu*(raa+s2aa)+ny*(raa+s1aa);
   ind2=nu*raa+1:nu*(s2aa+raa)+ny*s1aa;
   if strcmp(n4w,'CVA')%auxact(4)==1 %cva
      W1=R(ind3,[ind2 ind3]);[ull1,sll1,vll1]=svd(W1);
      sll1=sll1(1:raa*ny,1:raa*ny);
      W1i=ull1*sll1;W1=pinv(sll1)*ull1';
      W1i=ull1*(sll1+10^-6*max(abs(diag(sll1)))*eye(size(sll1)))*ull1';
      [Un,Sn,Vn]=svd(pinv(sll1)*ull1'*R(ind3,ind2));Un=ull1*sll1*Un;
   else
      [Un,Sn,Vn]=svd(R(ind3,ind2));
   end
   
   if ordchoice,
       if strcmp(n4w,'CVA')
           [Un1,Sn1,Vn1] = svd(R(ind3,ind2));
       else
           Sn1 = Sn;
       end
      n=ordch(Sn1,n,arg,def_order,ny,auxact,nu,Ncap,R,XIDplotw,nk); %%LL%% THink of Ncap here
      if isempty(n),
         m=[];
         return
      end
   end
   A=conj(Un(1:ny*(raa-1),1:n)\Un(ny+1:raa*ny,1:n));
   C=conj(Un(1:ny,1:n));
   if dkx(2)==0|...
         (isstr(focus)&any(strcmp(lower(focus),{'stability','simulation'})))...
         |nu==0
      A=stab(A);
   end
   R1=R(1:nu*raa,1:nu*raa);
   R2=R(s1aa*ny+(raa+s2aa)*nu+1:end,1:s1aa*ny+(raa+s2aa)*nu+ny);
   if dkx(2)
      K=estK(R1,R2,Un,n,ny,nu,raa,s1aa,s2aa,A,C);
      if max(abs(eig(A-K*C)))>1   % Safety check. Theoretically this cannot
         % happen
         try
             K= zeros(n,ny);
            %K=ssssaux('kric',A,C,K*K',eye(ny),K);
         end
      end
      
   else
      K=zeros(n,ny);
   end
   if any(strcmp(focus,{'Prediction','Stability'}))
      useK = 1;
   else
      useK = 0;
   end
   if useK|max(abs(eig(A)))>1 
      K1=K;
   else  
      K1=zeros(n,ny); 
   end
   if nu>0|dkx(3)
      try
         [B,D,x0]=linreg(z,A,K1,C,ny,nu,n,dkx,nk,maxsize);
      catch
         error(lasterr)
      end
      
   else
      B=zeros(n,0);D=zeros(ny,0);x0=zeros(n,1);
   end
   if max(abs(eig(A-K*C)))>1   % Safety check. Theoretically this cannot
      % happen
      try
         K=ssssaux('kric',A,C,K*K',eye(ny),K);
      end
   end
   at=A.';bt=B.';ct=C.';dt=[];kt=K.';
   par=[at(:);bt(:);ct(:)];
   As=NaN*ones(size(A));Bs=NaN*ones(size(B));Cs=NaN*ones(size(C));
   if nu==0
      Ds = zeros(ny,0);
   end
   
   for ku = 1:nu
      if nk(ku)==0
         Ds(:,ku)=NaN*ones(ny,1);
         dt =[dt,D(:,ku)];
      else
         Ds(:,ku)=zeros(ny,1);
      end
   end
   if ~isempty(dt)
      dt = dt.';
      par = [par;dt(:)];
   end
   if  dkx(2)
      par=[par,;kt(:)];
      Ks=NaN*ones(size(K));
   else
      Ks=zeros(size(K));
   end
   if dkx(3) %% should check auto here??
      par=[par;x0];
      X0s=NaN*ones(size(x0));
   else
      X0s=zeros(size(x0));
   end
   idmod=pvset(idmod,'ParameterVector',par,'Approach','Subspace');
   mprel1=llset(mprel,{'idmodel','As','Bs','Cs','Ds','Ks','X0s'},...
      {idmod,As,Bs,Cs,Ds,Ks,X0s});
   mprel1 = pvset(mprel1,'Ts',Ts);
   
   
   e=pe(z,mprel1,'m');
   nx = size(As,1);
   npar = nx*(ny+nu);
if dkx(1), npar = npar+nu*ny;end
if dkx(2), npar = npar + ny*nx;end
if dkx(3), npar = npar + nx;end

   lambdap=e'*e/(length(e)-npar/ny);Vloss=det(lambdap);
   if Vloss<Vmin,Vmin=Vloss;m=mprel1;lambda=lambdap;auxbest=auxact;end  
   %%LL%% % plot if gui och auxchoice
   if strcmp(arg,'gui')&tryaux
      [dum,dum,dum,xx,yy]=makebars(raa,Vloss);
      patch(xx,yy,'y');drawnow
   elseif tryaux&~strcmp(pvget(mprel1,'Trace'),'Off')
      disp(['N4Horizon = ',int2str(auxact(1:3)),' gives a loss: ',num2str(Vloss)])
   end %if 'gui'
   
end % over aux
if tryaux&strcmp(arg,'gui')
   [dum,dum,dum,xx,yy]=makebars(auxbest(1),Vmin);
   patch(xx,yy,'red')
elseif tryaux&~strcmp(pvget(mprel1,'Trace'),'Off')
   disp(['Best choice: N4Horizon = ',int2str(auxbest(1:3))])  
end
% Adjust if data sequence was shifte
if ~isempty(delayu)
   m = pvset(m,'nk',nk);
end
m = pvset(m,'NoiseVariance',lambda);
if pvget(mprel,'Ts')==0
   if any(inpd~=0)
      m = pvset(m,'InputDelay',inpd); % To set it right for discrete time
   end
   di = pvget(dat,'InterSample');
   m = d2c(m,di{1,1}); 
end

if ~strcmp(pvget(idmod,'CovarianceMatrix'),'None')
   try
   m2=m;
   m2 = pvset(m2,'SSParameterization','Canonical');
   idmod=pvget(m2,'idmodel'); 
   maxi = pvget(idmod,'MaxIter');
   tr = pvget(idmod,'Trace');
   idmod=pvset(idmod,'MaxIter',-1,'Trace','Off');
   m2=pvset(m2,'idmodel',idmod);%,'NoiseVariance',lambda);
   m2=pem(dat,m2);
   m2 = pvset(m2,'MaxIter',maxi,'Trace',tr);
   if strcmp(pvget(mprel,'SSParameterization'),'Canonical')
      m = m2;
   else
      idmod=pvget(m,'idmodel');
      uti = pvget(idmod,'Utility');
      uti.Pmodel=m2;
      idmod=pvset(idmod,'Utility',uti);
      m=pvset(m,'idmodel',idmod);
   end
catch
   
   warning(sprintf(['\n The calculation of covariance information failed.',...
         '\n ''CovarianceMatrix has been set to ''None''.']))
   m = pvset(m,'CovarianceMatrix','None');
   end
elseif strcmp(pvget(mprel,'SSParameterization'),'Canonical')
   m = pvset(m,'SSParameterization','Canonical');
   % test if transformation made predictor unstable.
end 

est=pvget(idmod,'EstimationInfo');
est.N4Horizon = auxbest(1:3);
est.N4Weight = n4w;
est.DataLength=sum(Ncaps);
est.DataTs=Ts;
est.LossFcn = det(lambda);
nx = size(As,1);
 est.FPE = det(lambda)*(1+npar/sum(Ncaps))/(1-npar/sum(Ncaps));
dn = pvget(dat,'Name');
if isempty(dn)
   dn = inputname(1);
end

est.DataName = dn;
est.DataInterSample=pvget(dat,'InterSample');%'Zero order hold';
est.Status='Estimated model (N4SID)';
est.Method = 'N4SID';
idmod=pvget(m,'idmodel');
idmod=pvset(idmod,'EstimationInfo',est);%'NoiseVariance',lambda);
idmod = idmname(idmod,dat);
m=pvset(m,'idmodel',idmod);
nchoice = nx;
bestchoice = auxbest(1:3);
 %if ~strcmp(pvget(m,'CovarianceMatrix'),'None')
 %	setcov(m)
 %end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function n = ordch(SS,n,arg,def_order,ny,auxord,nu,Ncap,R,XIDplotw,nk)

nmax = n;
dS=diag(SS);
testo=log(dS);
try
ndef=min(n,max(find(testo>(max(testo)+min(testo))/2)));
catch
    error('The order determination test failed. Try explicit orders.')
end
[a,b]=min(diff(testo)); 
if ~def_order
   [dum,dum,dum,xx,yy]=makebars(1:length(dS),log(dS)');
   mdS=floor(min(log(dS)));
   zer=find(yy==0);yy(zer)=mdS*ones(size(zer));
   if ~strcmp(arg,'gui')
      figure
      handax=gca;
   else
      handax=get(XIDplotw(10,1),'userdata');handax=handax(3);
      set(handax,'vis','off');axes(handax),cla
      [nR,nC]=size(R);
      hh=findobj(XIDplotw(10,1),'label',menulabel('&Help'));
      set(hh,'userdata',{[ny,auxord,nu,Ncap],R,nk});
   end
   axes(handax)
   line(xx,yy,'color','y');%%
   ylabel('Log of Singular values');xlabel('Model order')
   title('Model singular values vs order')
   text(0.97,0.95,'Red: Default Choice','units','norm','fontsize',10,...
      'HorizontalAlignment','right');
   
   patch(xx(1:ndef*5-3),yy(1:ndef*5-3),'y');%%
   patch(xx(5*ndef-3:5*ndef),yy(5*ndef-3:5*ndef),'r');%%%
   patch(xx(5*ndef:n*5+1),yy(5*ndef:n*5+1),'y');%%
   set(handax,'vis','on')
   
   if strcmp(arg,'gui')
      set(XIDplotw(10,3),'userdata',[[ndef,1:length(dS)];[dS(ndef),dS']]);
      n=[];
      return
   end
   title('Select model order in command window.')
   n=-1;
   while n<=0|n>nmax
   n=input('Select model order:(''Return'' gives default) ');
   n = floor(n);
   if isempty(n)
      n=ndef;
      disp(['Order chosen to ',int2str(n)]);
   end
   if n<=0,disp('Order must be a postitive integer'),end
   if n>nmax,disp(['Order must be less than ',int2str(nmax+1)]),end
end
else
   n=ndef;
end  % if def_order
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function K = estK(R1,R2,Un,n,ny,nu,ra,s1a,s2a,A,C);

hl1= R2(ny+1:ra*ny,1:nu*(s2a+ra)+ny*s1a+ny); 
hl2 = [R2(1:ra*ny,1:nu*(s2a+ra)+ny*s1a) zeros(ra*ny,ny)];
Gam = Un(:,1:n);
vl = [Un(1:(ra-1)*ny,1:n)\hl1;R2(1:ny,1:nu*(s2a+ra)+ny*s1a+ny)];
hl = [Un(:,1:n)\hl2  ;[R1 zeros(nu*ra,(nu*s2a+ny*s1a)+ny)]];

K = vl/hl;
W = (vl - K*hl)*(vl-K*hl)';
% Q,R,S matrices

Q = W(1:n,1:n);
S = W(1:n,n+1:n+ny);
R = W(n+1:n+ny,n+1:n+ny); 

try
   [K,flag] = ssssaux('kric',A,C,Q,R,S);
   if flag
      warning(sprintf(['The computation of K has met some problems.',...
            '\nThe reason may be that the model order is too high.']))
   end
catch
   K = zeros(n,ny);
   warning(sprintf(['The estimation of K failed. K has been set to 0.']))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [B,D,x0,psi1,evec1]=linreg(zme,A,K1,C,ny,nu,nx,dkx,nk,maxsize)
psi = [];
n=nu*nx+nx*length(zme); % zme is cell array
if dkx(1),
   n=n+ny*length(find(nk==0));
end
nz=ny+nu; 
rowmax=max(n*ny,nx+nz);
M=floor(maxsize/rowmax);
%R=zeros(n,n);Fcap=zeros(n,1);

sqrlam = eye(ny);
lame = zeros(ny,ny);
Nlep = 0;
for loop = 1:3 % the loop is for multioutput systems to allow 
   %             for weighting with lambda
   R1=[];
   if loop == 1|ny>1
      if loop == 3
         lambda = lame/Nlep;
          if any(any(isnan(lambda)')')|any(any(isinf(lambda))')
                     error(sprintf([' Estimation problem ill conditioned.',...
                           '\n The reason may be poorly exciting input or too high order.',...
                           '\n Try lower order and/or ''DisturbanceModel'' = ''None''.']))
                     end

         try
            sqrlam = inv(chol(lambda)); %% secure error in lambda if not pd
         catch
             sqrlam = eye(length(sqrlam)); % Skip weightings
            %[veig,eigv] = eig(lambda);
            %eigv = abs(eigv);
            %lambda = veig*eigv*veig';
            %sqrlam = inv(chol(lambda));
         end
      end
      for kexp = 1:length(zme)
         z = zme{kexp};
         Ncap = size(z,1);
         X0=zeros(nx,1);
         %if loop~=2|M<Ncap|length(zme)>0 %Do loop in second round only if psi
         %has changed. "spectest".
         if loop==2& M>Ncap & length(zme)==1 % Then no need to loop
            epsi = evec - psi*g;
            lep = size(epsi,1);
            Nlep = Nlep + lep/ny;
            epsi = reshape(epsi,lep/ny,ny);
            
            lame = lame + epsi'*epsi;
         else
            for kc=1:M:Ncap
               jj=(kc:min(Ncap,kc-1+M));
               if jj(length(jj))<Ncap,jjz=[jj,jj(length(jj))+1];else jjz=jj;end
               psitemp=zeros(length(jj),ny);
               psi=zeros(ny*length(jj),n);
               if norm(K1)==0
                  e = z(jj,1:ny);
               else
                  x=ltitr(A-K1*C,K1,z(jjz,1:ny),X0); 
                  [nxr,nxc]=size(x);X0=x(nxr,:).';
                  %We use the good K even for an OE model
                  yh=(C*x(1:length(jj),:).').'; 
                  e=(z(jj,1:ny)-yh);
                                 end
               e=e*sqrlam;
               evec=e(:);
               kl=1;
               for kx=1:nx,
                  for ku=1:nu
                     dB=zeros(nx,1);dB(kx,1)=1;
                     if kc==1,
                        dX=zeros(nx,1);
                     else 
                        dX=dXk(:,kl);
                     end
                     psix=ltitr(A-K1*C,dB,z(jjz,ny+ku),dX);[rp,cp]=size(psix);
                     dXk(:,kl)=psix(rp,:).';
                     psitemp=(C*psix(1:length(jj),:).').'*sqrlam;
                     psi(:,kl)=psitemp(:);kl=kl+1;   
                  end,
               end
               if dkx(1)
                  for ky=1:ny,
                     for ku=find(nk==0);
                        psitemp=...
                           [zeros(length(jjz),ky-1),z(jjz,ny+ku),zeros(length(jjz),ny-ky)]...
                           *sqrlam;psitemp=psitemp(1:length(jj),:);
                        psi(:,kl)=psitemp(:);kl=kl+1;
                     end,
                  end
               end
               %% x0
               kl = kl+(kexp-1)*nx;
               for kx=1:nx
                  if kc==1
                     x0dum=zeros(nx,1);x0dum(kx,1)=1;
                  else
                     x0dum=X00(:,kl);
                  end
                  psix=ltitr(A-K1*C,zeros(nx,1),zeros(length(jjz),1),x0dum);
                  [rp,cp]=size(psix);
                  X00(:,kl)=psix(rp,:).';
                  psitemp=(C*psix(1:length(jj),:).').'*sqrlam;
                  psi(:,kl)=psitemp(:);kl=kl+1;   
               end
               
               if loop == 2
                  epsi = evec - psi*g;
                  lep = size(epsi,1);
                  Nlep = Nlep + lep/ny;
                  epsi = reshape(epsi,lep/ny,ny);
                  
                  lame = lame + epsi'*epsi;
               else
                 
                  R1 = triu(qr([R1;[psi,evec] ]));[nrr,nrc] = size(R1);
                  R1 = R1(1:min(nrr,nrc),:);
               end
            end % spectest
         end
      end
      
      % *** Compute the estimate of B and D ***
      if loop ~= 2
         g=pinv(R1(1:n,1:n))*R1(1:n,n+1);
      end
   end
end %loop
B1=reshape(g(1:nx*nu),nu,nx).';
D1=zeros(ny,nu);
if dkx(1)%strcmp(dmat,'d'),
   nud=length(find(nk==0));
   Dtemp=reshape(g(nx*nu+1:n-nx*kexp),nud,ny).';
   D1(:,find(nk==0))=Dtemp;
   B1=B1+K1*D1;
end
if dkx(3),
   x0=g(n-nx+1:n); % Note, in multiexperiment case, only x0 for last
   % experiment is delivered (but all are used to get
   % better estimates of B and D).
else 
   x0=zeros(nx,1);
end
B=B1;D=D1; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [auxord,maxsize,nrr]=...
   orders(n,auxord,maxsize,Ncap,ny,nu,dkx,dispmode)
if nargin< 8
   dispmode = 1;
end

if Ncap <= (ceil(n/ny)+1)*(1+ny+nu) + (1+nu+ny)*ceil((n-ny+1)/(nu+ny))
   error('Too few data for this choice of order.')
end
test = Ncap -(ny+1)*auxord(1)-nu*auxord(1)-ny*auxord(2)-nu*auxord(3)...
   -max(auxord([2 3]));
if test <0 % then auxord needs to be reduced
   count = 1;
   maxc = sum(auxord);
auxordorig = auxord;
   while test <0&count<maxc
      auxord = auxord - 1;
      auxord(1) = max(auxord(1),ceil(n/ny)+1);
      auxord([2 3]) = max(auxord([2 3]),ceil((n-ny+1)/(nu+ny))*ones(1,2));
      auxord([2 3]) = max(auxord([2 3]),[0 0]);
      auxord([2 3]) = min(auxord([2 3]),auxordorig([2 3]));
      test = Ncap -(ny+1)*auxord(1)-nu*auxord(1)-ny*auxord(2)-nu*auxord(3)...
         -max(auxord([2 3]));
      count = count+1;
   end
   if dispmode
      disp(['N4Horizon has been changed to ',int2str(auxord)])
   end
end
if auxord(1)<ceil(n/ny)+1
   auxord(1)=ceil(n/ny)+1;
   if dispmode
      disp(['N4Horizon(1) (r) has been changed to ',int2str(auxord(1))])
   end
end
if nu*auxord(3)+ny*auxord(2)+ny<=n&dkx(2)
   
   newa=ceil((n-ny+1)/(nu+ny));auxord([2,3])=[newa,newa];
   if dispmode
      disp(['N4Horizon(2:3) (sy su) have been changed to ',int2str(newa)])
   end
end

nrr=sum(auxord([1 2]))*ny+sum(auxord([1 3]))*nu;%2*i*(l+m);
if nrr*1.2*nrr>maxsize,
   maxsize=nrr*1.2*nrr;
   disp(['MaxSize has been changed to ',int2str(maxsize)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function As=stab(A)
[V,D]=eig(A);
if cond(V)>10^8, [V,D]=schur(A);[V,D]=rsf2csf(V,D);end
if max(abs(diag(D)))<1,As=A;return,end
[n,n]=size(D);
for kk=1:n
   if abs(D(kk,kk))>1,D(kk,kk)=1/D(kk,kk);end
end
As=real(V*D*inv(V));
%******************************************************************
function [R,fail]=buildR(zme,maxsize,nrr,ra,s1a,s2a,l,Ncaps,m)
%%% Hankel matrices:
nele=floor(maxsize/(nrr));
if nele==0,error(['MAXSIZE must be larger than ',int2str(maxsize) '.']),end
msa=max(s1a,s2a); nohanrow=msa+ra;

R=[];H1=zeros(nrr,nrr+min(nele,max(Ncaps))-nohanrow+1);
for kexp = 1:length(zme);
   z = zme{kexp}; Ncap = Ncaps(kexp);
   nloop=floor((Ncap-nohanrow)/nele-eps)+1;
   
   for kk=1:nloop
      jj=[1+(kk-1)*nele:min(Ncap,kk*nele+nohanrow-1)];
      Y = ssssaux('idblockh',z(jj,1:l),nohanrow);
      if m>0
         U = ssssaux('idblockh',z(jj,l+1:end),nohanrow);
      else
         U=[];
      end
      UF=U(m*msa+1:m*(msa+ra),:);UP=U([1:m*s2a],:);  
      YF=Y(l*msa+1:l*(msa+ra),:);YP=Y([1:l*s1a],:);
      H=[UF;UP;YP;YF];
      if ~isempty(R)
         H1(:,1:min(ncR,nrr)+length(jj)-nohanrow+1) =...
            [H,R(1:min(nrR,nrr),1:min(ncR,nrr))];
      else
         H1(:,1:length(jj)-nohanrow+1)=H;ncR=0;
      end
      R=triu(qr(H1(:,1:min(ncR,nrr)+length(jj)-nohanrow+1)'))';[nrR,ncR]=size(R); 
   end  %for kk
end
if nrR>=ncR,fail=2;error('Too few data for this choice of orders'),end
fail=0;R=R(:,1:nrR);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function n4hor = auxdef(z,dkx,order,ny,nu,focus,maxsize,Ncap)
radef=max(order+1,ceil(1.5*order/ny));
maxo=min([6*max(order),(size(z{1},1)-size(z{1},2))/2,max(floor(Ncap/(ny+nu+1))-1+order/ny,1)]);
% if size(z{1},1)-6*max(order)-size(z{1},2)<=0
%     if length(z)>1
%         error('The number of data in the first experinent are too few for this choice of orders.')
%     else
%         error('Too few data for this choice of orders.')
%             end   
%         end
if dkx(2)
   auxord=aic(z{1},ceil(maxo),ny,maxsize);
   n4hor = [radef, auxord,auxord];
   
else
   auxord=aico(z{1},ceil(6*max(order)),ny,maxsize);
   n4hor = [radef, 0,auxord];
end
%fix(1.2*max(order))+3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function n = aic(z,nmax,p,maxsize)
% Computes the best order of an ARX model using AIC

[N,nz]=size(z);
M = max(floor(maxsize/nz/nmax),nmax+1);
R1 = zeros(0,nmax*nz);
for k=nmax:M:N-1
   jj=(k:min(N,k+M-1));
   phi=zeros(length(jj),nmax*nz);
   for kz=1:nmax
      phi(:,(kz-1)*nz+1:kz*nz)=z(jj-nmax+kz,:);
   end
   R1 = triu(qr([R1;phi]));[nr,nrc]=size(R1);
   R1 = R1(1:min(nr,nrc),:);
end
Neff = N-nmax+1;
for k=0:min(nmax-1,floor((Neff-p-1)/nz))
   V(k+1)=sum(log(diag(R1(k*nz+1:k*nz+p,k*nz+1:k*nz+p)/nr).^2))+2*nz*p*k/Neff;
end

[dum,n]=min(V);n=n-1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [n,V] = aico(z,nmax,p,maxsize)
[N,nz] = size(z);
nu = nz-p;
str =[];
for ku = 1:nmax
   str = [str;[0,ku*ones(1,nu),ones(1,nu)]];
end
w = 0;
for ky = 1:p
   zz = z(:,[ky,p+1:nz]);
   v = arxstruc(zz,zz,str,maxsize);
   w = w+v(1,1:end-1);
end
w = log(w)+ 2*[1:nmax]*nu/(N-nmax);
[dum,n] = min(w);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ny,Ts,argnew] = transf(argold,nz) 
ml=length(argold);

trace = 'off';
auxord = [];
ny = 1;
Kest = 'Estimate';
estX = 'Auto';
maxsize = 'Auto';
Ts = 1;
if isstr(argold{1})
   ny = 1; trace = 'on';
else
   ny = argold{1};
end
nu = nz-ny;
nk = ones(1,nu);

if ml >1
   if isstr(argold{2})
      trace = 'on';  
   else
      aux = argold{2};
      if isempty(aux)
         auxord ='Auto';
      else
         if size(aux,2)==1
            auxord = [ones(1,3)*aux];
         else
            auxord =[];
            for kk= 1:size(aux,2)
               auxord=[auxord;[ones(1,3)*aux(1,kk)]];
            end
         end 
      end
   end
end
if ml > 2
   if isstr(argold{3})
      trace = 'on';  
   else
      dkx = argold{3};
      if dkx(1)
         nk = zeros(1,nu);
      else
         nk = ones(1,nu);
      end
      if dkx(2)
         Kest = 'Estimate';
      else
         Kest = 'None';
      end
      if dkx(3)
         estX = 'Estimate';
      else
         estX = 'Zero';
      end
      if length(dkx)>3
         nk = dkx(4:end);
      end
   end
end
if ml>3
   if isstr(argold{4})
      trace = 'on';  
   else
      maxsize = argold{4};
   end
end
if ml > 4
   if isstr(argold{5})
      trace = 'on';  
   else
      Ts = argold{5};
   end
   
end
if ml > 5
   trace = 'on';
end

argnew={'N4Horizon',auxord,'nk',nk,'InitialState',estX,'DisturbanceModel',Kest,...
      'MaxSize',maxsize,'Ts',Ts,'Trace',trace};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = n4focus(data,m0,foc,Tsd)
if isa(foc,'idmodel')|isa(foc,'lti')|iscell(foc)
  ts = pvget(data,'Ts');ts = ts{1};
  foc = foccheck(foc,ts);
end
  zf = idfilt(data,foc);
ssp = pvget(m0,'SSParameterization');
dist = pvget(m0,'DisturbanceModel');
[a0,b0,c0,d0,k0] = ssdata(m0);
[ny,nu] = size(d0);
nk = pvget(m0,'nk');
if ~isempty(nk)
   nk=ones(1,nu);
end
nknew = nk>0;
m1 = pvset(m0,'Focus','Simulation','DisturbanceModel','None',...
   'InputDelay',zeros(nu,1),'nk',nknew,'SSParameterization','Free');

tr = pvget(m0,'Trace');

if ~strcmp(tr,'Off')
   disp(sprintf('\n   *** Finding the dynamics model ... ***\n'))
end

m=n4sid(zf,m1); 
if ~strcmp(dist,'None')
m2 = n4sid(data,m,'DisturbanceModel','Estimate','Cov','None');
K = pvget(m2,'K'); [A,B,C]=ssdata(m);
if max(abs(eig(A-K*C)))>1  % To secure a stable initial predictor
   try
      K = ssssaux('kric',A,C,K*K',eye(ny),K);
   end
end

m = pvset(m,'K',K,'Ks',NaN*K);
end
m = pvset(m,'InputDelay',pvget(m0,'InputDelay'));
m = pvset(m,'SSParameterization','Free');
m = pvset(m,'nk',nk);
m = pvset(m,'Focus',foc,'SSParameterization',ssp);
es = pvget(m,'EstimationInfo');
es.Status='Estimated model (PEM with focus)';
es.Method = 'PEM with focus';
es.DataName = pvget(data,'Name');
m=pvset(m,'EstimationInfo',es,'Focus',foc);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
