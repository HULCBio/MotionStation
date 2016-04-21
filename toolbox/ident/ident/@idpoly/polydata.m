function [a,b,c,d,f,da,db,dc,dd,df]=polydata(m)
%POLYDATA computes the polynomials associated with a given model.
%   [A,B,C,D,F]=POLYDATA(MODEL)
%
%   MODEL is the model  as an  IDMODEL object
%
%   A,B,C,D, and F are returned as the corresponding polynomials
%   in the general input-output model. A, C and D are then row
%   vectors, while B and F have as many rows as there are inputs.
%
%   [A,B,C,D,F,dA,dB,dC,dD,dF]=POLYDATA(MODEL)
%   also returns the standard deviations of the estimated polynomials.
%
%   See also IDPOLY

%   L. Ljung 10-1-86, 8-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/06 14:22:20 $

if nargin < 1
   disp('Usage: [A,B,C,D,F] = POLYDATA(SYS)')
   disp('       [A,B,C,D,F,DA,DB,DC,DD,DF] = POLYDATA(SYS)')
   return
end

na = m.na; nb = m.nb; nc = m.nc; nd = m.nd; nf = m.nf; nk = m.nk;

par = pvget(m.idmodel,'ParameterVector').';
T   = pvget(m.idmodel,'Ts');
if nargout>5
   dpar = pvget(m.idmodel,'CovarianceMatrix');
   if ischar(dpar), dpar =[];end
   if ~isempty(dpar)
      dpar = sqrt(diag(dpar)).';
   end
end

nu=length(nb);
if isempty(par)
   a=1; b=zeros(nu,0);c=1;d=1;f=ones(nu,1);
   %a=[];b=[];c=[];d=[];f=[];
   %da=[];db=[];dc=[];dd=[];df=[];
   da = 0; db = b; dc=0;dd=0;df=b;
   return
end

Nacum=na;
Nbcum=Nacum+sum(nb);
Nccum=Nbcum+nc;
Ndcum=Nccum+nd;
Nfcum=Ndcum+sum(nf);

a = [1 par(1:Nacum)];
c = [1 par(Nbcum+1:Nccum)];
d = [1 par(Nccum+1:Ndcum)];

% AR, ARMA
%if nu==0,
%  b=0; f=1;
%end

b   = zeros(nu,max(nb+nk));
nf1 = max(nf)+1;
f   = zeros(nu,nf1);
s   = 1;
s1  = 1;

for k=1:nu
   if nb(k) > 0
      b(k,nk(k)+1:nk(k)+nb(k)) = par(na+s:na+s+nb(k)-1);
   end
   if T>0
      if nf(k)>0
         f(k,1:nf(k)+1) = [1 par(Ndcum+s1:Ndcum+nf(k)+s1-1)];
      else
         f(k,1)=1;
      end
   else
      if nf(k)>0
         f(k,nf1-nf(k):nf1) = [1 par(Ndcum+s1:Ndcum+nf(k)+s1-1)];
      else
         f(k,nf1)=1;
      end
   end
   s  = s  + nb(k);
   s1 = s1 + nf(k);
end
if nargout>5
   if isempty(dpar)
      da=[];db=zeros(nu,0);dc=[];dd=[];df=zeros(nu,0);
   else
      
      
      da = [0 dpar(1:Nacum)];
      dc = [0 dpar(Nbcum+1:Nccum)];
      dd = [0 dpar(Nccum+1:Ndcum)];
      
      db   = zeros(nu,max(nb+nk));
      nf1 = max(nf)+1;
      df   = zeros(nu,nf1);
      s   = 1;
      s1  = 1;
      
      for k=1:nu
         if nb(k) > 0
            db(k,nk(k)+1:nk(k)+nb(k)) = dpar(na+s:na+s+nb(k)-1);
         end
         if T>0
            if nf(k)>0
               df(k,1:nf(k)+1) = [0 dpar(Ndcum+s1:Ndcum+nf(k)+s1-1)];
            else
               df(k,1)=0;
            end
         else
            if nf(k)>0
               df(k,nf1-nf(k):nf1) = [0 dpar(Ndcum+s1:Ndcum+nf(k)+s1-1)];
            else
               df(k,nf1)=0;
            end
         end
         s  = s  + nb(k);
         s1 = s1 + nf(k);
      end
   end
end
