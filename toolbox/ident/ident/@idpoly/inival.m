function M = inival(z, M)
%INIVAL   Computes initial values for the prediction error method.
%	
%	TH = inival(Data, Model, MAXSIZE,T)
%
%	The routine is intended primarily as a subroutine to PEM.
%	See PEM for an explanation of the arguments.

%	L. Ljung 10-1-86
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.10.4.1 $  $Date: 2004/04/10 23:16:34 $

% *** Set up the relevant orders ***

 

if ~iscell(z)
   z = {z};
end
Ne = length(z);
for kexp= 1:Ne
   Ncaps(kexp)=size(z{kexp},1);
end
nu = size(z{1},2)-1;
 
na=M.na;
nb=M.nb;
nc=M.nc;
nd=M.nd;
nf=M.nf;
nk=M.nk; 
maxsize = pvget(M.idmodel,'MaxSize'); %% Clean up
if isstr(maxsize)
   maxsize = idmsize(max(Ncaps),sum([na,nb,nc,nd,nf]));
end

Tsamp=1;  
init = M.InitialState;
init = lower(init(1:4));
%if strcmp(init,'auto')
%   init='esti';
%end

 
%if strcmp(init,'esti')
   nmax=max([na nb+nk-ones(1,nu) nc nd nf]);
%else
%   nmax=0;
%end
if nu>0
Ndcap = sum([na,nb,nc,nd]);
n     = Ndcap+sum(nf);
else
   n = na+nc;
end

tb = []; tf = []; t1 = []; tc = []; td = [];
if nu>0
   % *** step 1: compute the LS-estimate of A and B
   naf = na+max(nf);
   t   = arx(z,[naf nb nk],maxsize,Tsamp,0);
   
   % ** Stabilize the a-estimate **
   a     = fstab([1 t(1:naf).']); 
   b     = zeros(nu,max(nb+nk));
   NBcap = cumsum([naf nb]);
   for k = 1:nu
      if nb(k)>0
         b(k,nk(k)+1:nk(k)+nb(k)) = t(NBcap(k)+1:NBcap(k+1)).';
      end
   end
   
   % *** step 2: compute IV-estimates
   %tb = []; tf = []; t1 = []; tc = []; td = [];
   
   if naf>0
      %     if na>0 we compute the IV-estimate of A and B in a
      %     straightforward fashion and initialize F (if any) as F=1.
      if na>0
         t1=iv(z,[na nb nk],a,b,maxsize,Tsamp,0);
         if nc+nd>0
            for kexp = 1:Ne
               z1 = z{kexp};
               v{kexp}=filter([1 t1(1:na).'],1,z1(:,1));
               for ku=1:nu
                  v{kexp}=v{kexp}-filter([zeros(1,nk(ku)),...
                        t1(NBcap(ku)+1-max(nf):NBcap(ku+1)-max(nf)).'],1,z1(:,ku+1));
               end
            end
         end
         
      end
      
      %    if na=0 we initialize each of the F as the denominator
      %    dynamics of each of the corresponding single input systems
      %    estimated by the IV-method. The estimate is first made stable
      
      if na==0
         s1=1; s=1;
         for kexp = 1:Ne
            z1=z{kexp};
            v{kexp} = z1(:,1);
         end
         
         for k=1:nu
            if nb(k)>0
               for kexp = 1:Ne
                  z1 = z{kexp};
                  dati{kexp}=[z1(:,1),z1(:,k+1)];
                  end
               t=iv(dati,[nf(k) nb(k) nk(k)],a,b(k,:),...
                  maxsize,Tsamp,0);
               if any(isinf(t))
                  m = [];
                  return;
               end
               if nf(k)>0
                  f  = fstab([1 t(1:nf(k)).']);
                  tf = [tf;f(2:end).'];
              else
                  f = 1;
              end
               tb=[tb;t(nf(k)+1:nf(k)+nb(k))];
               
               if nc+nd>0
                  for kexp = 1:Ne
                     z1 = z{kexp};
                     v{kexp}=v{kexp}-...
                        filter([zeros(1,nk(k)),t(nf(k)+1:nf(k)+nb(k)).'],f,z1(:,k+1));
                  end
               end
               
            end
         end
         
      end
   else % if naf ==0
      tb = t;
      for kexp = 1:Ne
         z1 = z{kexp};
         v{kexp} = z1(:,1);
         for ku=1:nu
            v{kexp}=v{kexp}...
               -filter(b(ku,:),1,z1(:,ku+1));
         end
      end
      
   end
else % ie nu ==0
   v=z;
   nd=na;
end %if nu>0 
%  *** step 3: calculate the residuals associated with the
%              current model


if nc+nd>0
   for kexp = 1:Ne
      v1 = v{kexp};
      v{kexp} = v1(nmax+1:Ncaps(kexp));
   end
   
   %   *** step 4: build an ARMA(nd,nc) model of these residuals.
   
   if nc==0
      td = arx(v,nd,maxsize,Tsamp,0);
   end
   
   if nc>0
      if isempty(nb),nb1=0;else nb1=nb;end
      ord=floor(min([na+nb1+4*nc,sum(Ncaps)/3]));
      n=max([n,ord]);

      art = arx(v,ord,maxsize,Tsamp,0);
      for kexp = 1:Ne
           ep  = filter([1 art.'],1,v{kexp});

         dati{kexp} = [v{kexp} ep];
         end
      t   = arx(dati,[nd nc 1],maxsize,Tsamp,0);
      %     ** check stability of C-polynomial **
      c  = fstab([1 t(nd+1:nd+nc).']);
      tc = c(2:length(c)).';
      if nd>0
         td=t(1:nd);%td = [1,t(1:nd).'];
      end
   end
end

% *** Build up the final object ***
%e = pex(z, M, 'e'); %e=e(nmax+1:Ncap);% LL%%LL 'e' or 'z'??
%M.idmodel.NoiseVariance=e'*e/length(e); 
M.nc = nc;
if nu>0
   M.nd = nd;
else
   M.na=nd;
end

if nu >0
   if isempty(tf)
      tf = zeros(sum(nf),1);
   end
   
   pars=[t1;tb;tc;td;tf];
else
   pars=[td;tc];
end

M.idmodel=pvset(M.idmodel,'ParameterVector',pars);  % The estimate of lambda

