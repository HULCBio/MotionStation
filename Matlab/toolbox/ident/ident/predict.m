function [yhat,xi,thpred]=predict(data,theta,m,init,inhib)
%PREDICT Computes the k-step ahead prediction.
%   YP = PREDICT(MODEL,DATA,K)
%   
%   DATA: The output - input data as an IDDATA object, for which the
%   prediction is computed. 
%      
%   MODEL: The model as any IDMODEL object, IDPOLY, IDSS, IDARX or IDGREY.
%
%   K: The prediction horizon. Old outputs up to time t-K are used to
%       predict the output at time t. All relevant inputs are used.
%       K = inf gives a pure simulation of the system.(Default K=1).
%   YP: The resulting predicted output as an IDDATA object. If DATA
%       contains multiple experiments, so will YP.
%
%   YP = PREDICT(MODEL,DATA,K,INIT) allows the choice of initial vector:
%   INIT: The initialization strategy: one of
%      'e': Estimate initial state so that the norm of the
%           prediction errors is minimized.
%           This state is returned as X0, see below. For multiexperiment 
%           DATA, X0 is a matrix whose columns contain the initial states
%           for each experiment.
%      'z': Take the initial state as zero
%      'm': Use the model's internal initial state.
%       'd': Same as 'e', but if Model.InputDelay is non-zero, these delays
%            are first converted to explicit model delays, so that the are
%            contained in X0.
%       X0: a column vector of appropriate length to be used as initial value.
%           For multiexperiment DATA X0 may be a matrix whose columns give
%           different initial states for each experiment.
%   If INIT is not specified, Model.InitialState is used, so that
%      'Estimate', 'Backcast' and 'Auto' gives an estimated initial state,
%      while 'Zero' gives 'z' and 'Fixed' gives 'm'.
%
%   With [YP,X0,MPRED] = PREDICT(MODEL,DATA,M) the initial conditions and the 
%   predictor MPRED are returned. MPRED is a cell array of IDPOLY objects,
%   such that MPRED{ky} is the predictor for the ky:th output. The matching
%   the channels of MPRED with data follows from its InputNames.
%   See also COMPARE and IDMODEL/SIM.

%   L. Ljung 10-1-89,9-9-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.24.4.1 $  $Date: 2004/04/10 23:19:13 $

if nargin<2
   disp('Usage: YP = PREDICT(MODEL,DATA)')
   disp('       YP = PREDICT(MODEL,DATA,M)')
   return
end
thpred = [];
if isa(data,'idmodel') % Forgive order
   data1 = theta;
   theta = data;
   data = data1;
end
    [nym,num] = size(theta);
 if isa(data,'frd')|isa(data,'idfrd')
    error('PREDICT is not meaningful for Frequency Domain Data.')
       return
end 
if isa(data,'iddata');
    if strcmp(pvget(data,'Domain'),'Frequency')
        error('PREDICT is not meaningful for Frequency Domain Data.')
        return
    end
    [Ncap,ny,nu] = size(data);
    if ny~=nym|nu~=num
        error('Mismatch in input/output numbers for model and data.')
    end
else
    if ~isa(data,'double')
        error('Data must be an iddata object or a matrix of signals.')
    end
    [Ncap,nz] = size(data);
    if nz~=nym+num
        error(['The data must contain ',int2str(nym+num),' columns.'])
    end
end
if nargin<3, m=1;end
if nargin<4,init=[];end 
if nargin<5,inhib=0;end % inihib = 1 is basically a GUI call
if isempty(m), m=1;end
if ~isinf(m),
    if m<1|m~=floor(m)
        error('The prediction horizon M must by a positive integer.')
    end,
end
if isempty(init)
    if isa(theta,'idarx')
        init='z';
    else
        init=pvget(theta,'InitialState');
    end
    init=lower(init(1));
    if init=='d'
        inpd= pvget(theta,'InputDelay');
        if norm(inpd)==0
            init = 'e';
        end
    end
    if init=='a'|init=='b',
        init='e';
    elseif init=='f'
      init = 'm';   
   end
elseif ischar(init)
   init=lower(init(1));
   if ~any(strcmp(init,{'m','z','e','d'}))
      error('Init must be one of ''E(stimate)'', ''Z(ero)'', ''M(odel)'', ''D(elayconvert)'', or a vector.')
   end
end
%% Now init is either a vector or the values 'e', 'm', 'z' 'd'
if isa(data,'iddata')&size(data,'Ne')>1&pvget(theta,'Ts')==0
   tds = pvget(data,'Ts'); tds = unique(cat(1,tds{:}));
   if length(tds)>1&norm(pvget(theta,'InputDelay'))>0
      % This special case requires special attention since
      % the different experiments need to be shifted differently
      noxi = 0;
      if nargout == 3
         warning('Predictor models are not returned in this case.')
      end
      for kexp = 1:size(data,'Ne')
          init1 = init;
          if isa(init,'double') % numeric IC
              [nr,nc] = size(init);
              if nc>1
                  init1 = init(:,kexp);
              end
          end
         [yhat{kexp},x1] = predict(theta,getexp(data,kexp),m,init1);
         if nargout>1&~noxi
            try
               xi(:,kexp)=x1;
            catch
               noxi = 1; xi =[];
               warning('Different sizes of returned initial states. Will be set to [],')
            end
         end
      end
      yhat = merge(yhat{:});
      return
   end
end
if isinf(m)
   if ischar(init)&init=='e'
      [dum,X0] = pe(data,theta,'e');
      init = X0;  % Note the difference with COMPARE, which fits
      % X0 with K = 0;
   end
   if ~isa(data,'iddata')
       data = data(:,nym+1:end);
   end
   yhat = sim(theta,data,init);
   thpred = theta;
   if nargout>1
       xi = init;
   end
   return
end
Inpd = pvget(theta,'InputDelay');
tsm = pvget(theta,'Ts');
nu = size(theta,'nu');
if tsm == 0
   if ~isa(data,'iddata')
      error('Time continuous models require the data to be an IDDATA object.')
   end
end

T=pvget(theta,'Ts'); 
Tdflag = 0;
if isa(data,'iddata')
   Ts = pvget(data,'Ts');
   Ts = cat(1,Ts{:});
else
   Ts = [];
end

if T>0
   if ~isempty(Ts)
      if any(abs(Ts-T)>1e4*eps)
         warning([' The data and model sampling intervals are different.'])
      end
   end
else %T==0
   if ~isa(data,'iddata')
      ttes = pvget(theta,'Utility'); % This is really to honor old syntax
      try
         Td = ttes.Tsdata; method = 'z';
      catch
         error(sprintf(['  For a continuous time model the prediction data must be ',...
               'given as an IDDATA object.\n  Use DATA = iddata(y,u,Ts).']))
      end
   else  
      Tdc = pvget(data,'Ts'); Td = Tdc{1};
      methodc = pvget(data,'InterSample');
     
      try % To cover the no-input case
         method = methodc{1,1};
      catch
         method = 'zoh';
      end
      Tdflag = 1; thetac = theta;
   end
   theta=c2d(theta,Td,method,'cov','none');
end

Inpd = pvget(theta,'InputDelay');
if init=='d' & norm(Inpd)>0
    theta = inpd2nk(theta);
    Inpd = zeros(size(Inpd));
    init='e';
end
if isa(data,'iddata')
   data = nkshift(data,Inpd,'append'); 
   theta = pvset(theta,'InputDelay',zeros(nu,1));
   [ze,Ne,ny,nu,Ts,Name,Ncaps,errflag] = idprep(data,0,'dummy');
   iddatflag = 1;
else
    if norm(Inpd)>eps
        if ~inhib
            warning(['The model''s InputDelay can be handled only if',...
                    ' the data is an IDDATA object.']);
        else % we do the shift anyway
            [Ncap,nudum] = size(data);
            nk1 = Inpd;
            ny = nudum - length(nk1);
            
            Ncc = min([Ncap,Ncap+min(nk1)]);
            for ku = 1:length(nk1)
                u1 = data(max([nk1,0])-nk1(ku)+1:Ncc-nk1(ku),ny+ku);
                newsamp = Ncap-length(u1);
                if nk1(ku)>0
                    u1= [zeros(newsamp,1);u1];
                else
                    u1 = [u1;zeros(newsamp,1)];
                end
                data(:,ny+ku) = u1;
            end
        end
        
    end 
    iddatflag= 0;
    nz = size(data,2);
    ze = {data};
    Ncaps(1) = size(data,1);
    Ts =[];
    Ne = 1;
end
if m>=min(Ncaps)
    error('The prediction horizon must be less than the number of data.')
end
[A,B,C,D,K,X0]=ssdata(theta); 
[nyt,nx]=size(C);nut=size(B,2);
if iddatflag
    if ny~=nyt|nu~=nut 
        disp(['The number of outputs and inputs in the data vector is not']) 
        disp(['consistent with model. Should be ',int2str(ny),'+',int2str(nu)])
        error(' ')
    end
else
    if nz~=nyt+nut
        error('Data matrix size inconsistent with number of model input/output.')
    end
    ny = nyt; nu = nut;
end
if strcmp(init,'e')
    [dum,X0] = pe(ze,theta,'e');
elseif strcmp(init,'z')
    X0 = zeros(size(X0));
end
if ~ischar(init)
    X0 = init;
end
if nargout>1
        xi = X0;
 end
 [xnr,xnc]= size(X0);
 if xnc~=1&xnc~=Ne
     error(sprintf(['If the initial state has been specified, the number'...
             '\nof columns must either equal 1 or the number of experiments.']))
 end
 if xnr~=nx
     error(['The initial state must have ',int2str(nx),' rows.'])
 end
 if xnc==1 & Ne>1
     X0= X0*ones(1,Ne);
 end
for kexp = 1:Ne
   if Tdflag % To handle possible different sampling intervals for different exp.
      Tfnew = Tdc{kexp};
      if Tfnew ~=Td
         Td = Tfnew;
         theta = c2d(thetac,Td,methodc{kexp},'cov','none');  
      end
   end
   z = ze{kexp};
   u = z(:,1+ny:end);
   Ncap = Ncaps(kexp);
 
   if m==inf, 
      yhat=sim(theta,u,X0(:,kexp),inhib);
   else
      
      x=ltitr(A-K*C,[K B-K*D],[z],X0(:,kexp));
      if m==1, 
         yhat=(C*x.').'; 
         if ~isempty(D),yhat=yhat + (D*u.').';end
      else
         
         F=D;Mm=eye(length(A));
         for km=1:m-1
            F=[F C*Mm*B];
            Mm=A*Mm;
         end
         yhat=zeros(Ncap,ny);%corr 911111
         for ky=1:ny
            for ku=1:nu
               yhat(:,ky)=yhat(:,ky)+filter(F(ky,ku:nu:m*nu),1,u(:,ku));
            end
         end
         if isempty(yhat),yhat=zeros(Ncap,ny);end
         yhat(m:Ncap,:)=yhat(m:Ncap,:)+(C*Mm*x(1:Ncap-m+1,:).').';
         if nu>0
            x=ltitr(A,B,u(1:m,:),X0(:,kexp));
            yhat(1:m,:)=(C*x.').';
         end
         if ~isempty(D),yhat(1:m,:)=yhat(1:m,:) + (D*u(1:m,:).').';end
      end
   end
   yhatc{kexp} = yhat;
end
if iddatflag
   yhat = data;
   yhat = pvset(yhat,'OutputData',yhatc,'InputData',[]);
end
if nargout >2
   thpred = polypred(theta,m);
end
%%%%%
function thpred = polypred(theta,m);
% Note that cross couplings between output
% channels are ignored in these calculations.
[ny,nu]= size(theta);
yna = pvget(theta,'OutputName');
una = pvget(theta,'InputName');
yu = pvget(theta,'OutputUnit');
uu = pvget(theta,'InputUnit');
for ky = 1:ny
   [a,b,c,d,f]=polydata(theta(ky,:));
   if nu>0
      ff=1;
      for ku=1:nu, 
         bt=b(ku,:);
         for kku=1:nu,if kku~=ku,bt=conv(bt,f(kku,:));end,end
         bb(ku,:)=bt;
         ff=conv(ff,f(ku,:));
      end
      a=conv(conv(a,ff),d);c=conv(c,ff);
   else 
      a=conv(a,d);
   end
   
   
   na=length(a);nc=length(c);nn=max(na,nc);
   a=[a,zeros(1,nn-na)];c=[c,zeros(1,nn-nc)];
   [f,g]=deconv(conv([1 zeros(1,m-1)],c),a);
   ng=length(g);
   
   if nu>0,
      df=conv(d,f);
      
      for ku=1:nu
         bf(ku,:)=conv(bb(ku,:),df);
      end
      nbf=length(bf(1,:));nn=max(ng,nbf);
      gg=[[g,zeros(1,nn-ng)];[bf,zeros(nu,nn-nbf)]];
   else 
      gg=g;
   end
   th1 = idpoly(c,gg);
   
   th1 = pvset(th1,'InputName',[yna(ky);una],'OutputName',[yna{ky},'p'],...
      'InputUnit',[yu(ky);uu],'OutputUnit',yu(ky),'Ts',pvget(theta,'Ts'),...
      'TimeUnit',pvget(theta,'TimeUnit'),'EstimationInfo',pvget(theta,'EstimationInfo'));
   thpred{ky} =th1;
   
end


