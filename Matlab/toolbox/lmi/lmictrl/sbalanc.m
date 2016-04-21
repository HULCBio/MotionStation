% [a,b,c] = sbalanc(a,b,c,cond)
%     sys = sbalanc(sys,cond)
%
% Balances and scales the state-space realization (A,B,C) using a
% diagonal similarities. This realization can be specified as a
% system matrix (see LTISYS)
%
% The optional argument COND is an upper bound on the condition
% number of this similarity  (default = 1.0e8).
%
%
% See also  LTISYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [a,b,c]=sbalanc(a,b,c,cond)

if nargin > 4 ,
   display('usage: [a,b,c]=sbalanc(a,b,c,cond) or sys=sbalanc(sys,cond) ');
elseif nargin==3 | nargin == 1,
   cond=27;   % power of 2
elseif nargin==2,
   cond=log(b)/log(2);
end
d=0;

if nargin <= 2,
   [a,b,c,d]=ltiss(a);
   if ~isreal(a), e=eye(size(a))+imag(a); a=e\real(a); b=e\b; end
end

if isempty(a) | isempty(d),
   if nargin <= 2, a=ltisys(a,b,c,d); b=[]; c=[]; end
   return,
end


% rhoA mesures the size of A in terms of its eigenvalues (poles)

rhoA=max(1,max(abs(eig(a))));
diaga=diag(xdiag(a)); a=a-diaga;
na=size(a,1);

Dsim=zeros(na,1);


% prescale |B|=|C|

nB=norm(b,1);     nC=norm(c,1);
if nB == 0 | nC== 0, gap=nextpow2(nB)-nextpow2(nC);
else                 gap=round(nextpow2(nB/nC)/2);  end
if gap~=0, b=pow2(b,-gap); c=pow2(c,gap); end


%  using diagonal scalings, reduce ||A|| to approach 2^(rhoA+10)

target=min(10*rhoA,max(max(abs(a))));
niter=0; vary=1;

while vary & niter<5,

vary=0; niter=niter+1;

for i=1:na,

  % balance i-th row/column

  nrow=max(max(abs(a(i,:))),max(abs(b(i,:))));
  ncol=max(max(abs(a(:,i))),max(abs(c(:,i))));

  if nrow > target,

     sqroot=pow2(ceil(nextpow2(nrow*ncol)/2));
     averg=max(target,sqroot);     % objective for max(row,col)
     gap=min(nextpow2(nrow/averg),cond+Dsim(i)-max(Dsim));
     if abs(gap) > 3,
       a(i,:)=pow2(a(i,:),-gap);    b(i,:)=pow2(b(i,:),-gap);
       a(:,i)=pow2(a(:,i),gap);     c(:,i)=pow2(c(:,i),gap);
       Dsim(i)=Dsim(i)-gap;
       vary=1;
     end

  elseif ncol > target,

     sqroot=pow2(ceil(nextpow2(nrow*ncol)/2));
     averg=max(target,sqroot);     % objective for max(row,col)
     gap=min(nextpow2(ncol/averg),cond-Dsim(i)+min(Dsim));
     if abs(gap) > 3,
       a(i,:)=pow2(a(i,:),gap);    b(i,:)=pow2(b(i,:),gap);
       a(:,i)=pow2(a(:,i),-gap);   c(:,i)=pow2(c(:,i),-gap);
       Dsim(i)=Dsim(i)+gap;
       vary=1;
     end

  end


  % scale |B|=|C|

  nB=norm(b,1);     nC=norm(c,1);
  if nB == 0 | nC== 0, gap=nextpow2(nB)-nextpow2(nC);
  else                 gap=ceil(nextpow2(nB/nC)/2);  end
  if gap~=0, b=pow2(b,-gap); c=pow2(c,gap); end


end  %for

end  % while


a=a+diaga;


%%%%% TMP %%%%%%
%reduc=max([norm(AA),norm(BB),norm(CC)])/max([norm(a),norm(b),norm(c)]);
%disp(sprintf('norm reduction of A , B , C :  %4.2e  %4.2e  %4.2e',...
%      norm(AA)/norm(a), norm(BB)/norm(b),norm(CC)/norm(c)));
%%%%%%%%%%%%%%%%

if nargin <=2 ,
  a=ltisys(a,b,c,d);  b=[]; c=[];
end


% originator: p. gahinet (10/93)
