function [y,ysd]=idsim(data,th,init,inhib)
%IDSIM  Simulates a given dynamic system.
%   Y = IDSIM(UE,MODEL)
%
%   MODEL: contains the parameters of the model in  any of the IDMODEL
%   formats, IDSS, IDPOLY, IDARX, or IDGREY.
%
%   UE: the input-noise data UE = [U E]. Here U is the input data, that
%   could be given as an IDDATA object (with the signal defined as input)
%   or as a matrix U = [U1 U2 ..Un] with the column vector Uk as the k:th
%   input. Similarly, E is either an IDDATA object or a matrix of noise
%   inputs (as many columns as there are output channels). If E is omitted
%   a noise-free simulation is obtained.
%   The noise contribution is scaled by the variance information con-
%   tained in MODEL.
%
%   Y: The simulated output. If U is an IDDATA object, Y is also 
%   delivered as an IDDATA object, otherwise as a matrix, whose k:th
%   column is the k:th output channel.
%
%   If UE is a multiple experiment IDDATA object, so will Y be.
%
%   If MODEL is continuous time, it is first sampled according to the 
%   information in the input U which then must be an IDDATA object,
%   ('Ts' and 'InterSample' properties).
%
%   With  [Y,YSD] = IDSIM(UE,MODEL)  the estimated standard deviation of the
%   simulated output, YSD, is also computed. YSD is of the same formar as Y.
%
%   Y = IDSIM(UE,MODEL,INIT) gives acces to the initial state:
%       INIT = 'm' (default) uses the model's initial state.
%       INIT = 'z' gives zero initial conditions.
%       INIT = X0 (column vector). Uses X0 as the initial state.
%
%   See IDINPUT, IDMODEL for simulation and model creation.
%   See COMPARE and PREDICT for model evaluation.

%   L. Ljung 10-1-86, 9-9-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2001/04/06 14:22:26 $


y=[];ysd=[];
if nargin < 4, inhib = 0;end
if nargin<3,init=[];end
if nargin<2
   disp('Usage: Y = IDSIM(UE,TH)')
   disp('       [Y,YSD] = IDSIM(UE,TH,INIT)')
   return
end
if isa(data,'idmodel') % Forgive order
   data1 = th;
   th = data;
   data = data1;
end

if isempty(init), init = 'm'; end
Tdflag = 0;
T=pvget(th,'Ts');
if T==0
   if ~isa(data,'iddata')
      ttes = pvget(th,'Utility'); % This is really to honor old syntax
      try
         Td = ttes.Tsdata; method = 'z';
      catch
         error(sprintf(['  For a continuous time model the input data must be ',...
               'given as an IDDATA object.\n  Use U = iddata([],u,Ts).']))
      end
   else
      Tdc = pvget(data,'Ts');Td = Tdc{1}; 
      Tdflag = 1; thc = th;
      methodc = pvget(data,'InterSample');  
      try % To cover the no-input case
         method = methodc{1,1};
      catch
         method = 'zoh';
         end
;
   end
   th=c2d(th,Td,method);
elseif isa(data,'iddata')
   Td = pvget(data,'Ts'); Td = Td{1};
   if abs(Td-T)>10*eps
      warning([' The data and model sampling intervals are different.'])
   end
end

[a,b,c,d,k,x0]=ssdata(th);
LAM=pvget(th,'NoiseVariance');

if max(abs(eig(a)))>1, 
   warning(' System unstable.'),
end
Inpd = pvget(th,'InputDelay'); %%LL%% Check how c2d handle inputdelay
if isa(data,'iddata')
   data = nkshift(data,Inpd);
   zee = pvget(data,'InputData');
   %ze =ze{1};
   iddatflag = 1;
else
   iddatflag= 0;
   zee = {data};
   if norm(Inpd)>eps&~inhib
      warning(['The model''s InputDelay can be handled only if',...
            ' the data is an IDDATA object.']);
   end
 end
Ne = length(zee);

[ny,n]=size(c);
[n,nu]=size(b);
for kexp=1:Ne
   if Tdflag % To handle possible different sampling intervals for different exp.
      Tfnew = Tdc{kexp};
      if Tfnew ~=Td
         Td = Tfnew;
         th = c2d(thc,Td,methodc{kexp}); %%LL%% Possible Covariance
      end
   end
   ze = zee{kexp};
   [Ncap,nze]=size(ze); 
   if nze>Ncap, 
      error(' The data should be organized in columns.'),
      return,
   end
   if ~any(nze==[nu nu+ny])
      error('An incorrect number of inputs/noises have been specified!')
   end
   if ~strcmp(lower(init(1)),'m')%isempty(init),
      if strcmp(lower(init(1)),'z')
         x0 = zeros(n,1);
      else
         [nxr,nxc] = size(init); %if nxr<nxc,init=init.';nxr=nxc;end
         if nxr~=n,
            error(['The number of rows of the initial state must be ',int2str(n)])
         end
         x0 = init(:,kexp);
      end
      
   end
   if nze==ny+nu,
      sqrlam=sqrtm(LAM);
      e=ze(:,nu+1:nu+ny)*sqrlam; %%LL%% loop
      x=ltitr(a,[b k],[ze(:,1:nu) e],x0);
      y=(c*x.' +[d,eye(ny)]*[ze(:,1:nu) e].').';
   end
   if nze==nu
      x=ltitr(a,b,ze,x0);
      y=(c*x.'+d*ze.').';
   end
   yc{kexp} = y;
   if nargout>1
      nue = size(ze,2);
      mbb = idpolget(th);
      if ~isempty(mbb)
         if ~isempty(pvget(mbb{1},'CovarianceMatrix'))
            for kk = 1:length(mbb)
               mb = mbb{kk}(:,1:nue);  
               ysd(:,kk) = idsimcov(mb,ze,y(:,kk));%,nu); 
            end
         end
         ysdc{kexp} = ysd;
      end
   end
end % kexp
if iddatflag
   una = pvget(data,'InputName');
   unam = pvget(th,'InputName');
   war = 0;
   for ku = 1:length(unam);
      if ~strcmp(una{ku},unam{ku})
         war = 1;
      end
   end
   if war
      warning('The InputNames of the data and the model do not coincide.')
   end
   
   y = data;
   y = pvset(y,'OutputData',yc,'InputData',[],'OutputName',pvget(th,'OutputName'),...
      'OutputUnit',pvget(th,'OutputUnit'));
   if nargout>1
     if isempty(ysdc{1})
       ysd = [];
       else
      ysd = data;
      ysd= pvset(ysd,'OutputData',ysdc,'InputData',[],'OutputName',pvget(th,'OutputName'),...
      'OutputUnit',pvget(th,'OutputUnit'));
      end
   end
   
end



