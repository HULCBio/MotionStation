% [gain,peakf]=dnorminf(sys,tol)
%
% Computes the peak gain of the discrete-time transfer
% function
%                                   -1
%             G (z) = D + C (zE - A)  B
%
% The norm is finite if and only if (A,E) has no eigenvalue
% on the unit circle
%
% Input:
%   SYS        system matrix description of G(z)  (see LTISYS)
%   TOL        relative accuracy required (default = 0.01)
%
% Output:
%   GAIN       peak gain  (RMS gain when G is stable)
%   PEAKF      "frequency" at which this norm is attained, i.e.:
%
%                               j*PEAKF
%                       || G ( e        ) ||  =  GAIN
%
%
% See also  NORMINF.

% Author: P. Gahinet and A.J. Laub 10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $

function [gain,peakf]=dnorminf(sys,tol)


if nargin > 2,
  error('usage:  [gain,peakf]=dnorminf(sys,tol)');
elseif ~islsys(sys),
  error('SYS must be a system matrix');
elseif nargin < 2,
  tol=1.0e-2;
end

%%% v5 code
ceval = [];

[a,b,c,d,e]=ltiss(sbalanc(sys));
if max(max(abs(e-eye(size(e)))))>0, desc=1; else desc=0; end


% control parameters
macheps=mach_eps;
tolsep=macheps^(2/3);      % Ham. eval. test
peakf=0;
outrange=1.0e8;



% scaling
noa=norm(a,1);    nob=norm(b,1);    noc=norm(c,1);
if nob==0 | noc==0, gain=norm(d); peakf=0; return, end
pbscale=max([noa,nob,noc]);

% set d
rd=size(c,1);   cd=size(b,2);
if isempty(d) | norm(d,1)==0,
  d=zeros(rd,cd);
end


% test the spectrum of A wrt the unit circle
na=size(a,1);
if desc, eiga=eig(a,e); else eiga=eig(a); end
abseiga=abs(eiga);
if min(abs(ones(na,1)-abseiga)) < macheps*max([noa,abseiga'])
   error('A has eigenvalues on the unit circle: the norm is infinite');
end
ang=angle(eiga);
ind=find(abseiga > 0 & ang > 1e-4 & ang < pi-1e-4);
seleig=eiga(ind);

% select the eval closest to the unit circle
[aux,ind]=min(abs(ones(size(seleig))-abseiga(ind)));
seleig=seleig(ind);
seleig=seleig./abs(seleig);

% add extreme frequencies 0 and pi (-> always even # pts below!)
seleig=[seleig;1;-1];


% hessenberg of A
if desc,
  [aa,ee,q,z]=qz(a,e,'complex');
  bb=q*b;   cc=c*z;
else
  [u,aa]=hess(a); ee=e;
  bb=u'*b;  cc=c*u;
end


% compute a lower estimate
gmin=0;
for z=seleig',
   tmp=norm(d+cc/(z*ee-aa)*bb);
   if tmp > gmin,
      gmin=tmp;
      ceval=z;
   end
end


% pencil set-up

m11=mdiag(a,e');             n11=mdiag(e,a');
m12=mdiag(b,c');
m21=[zeros(cd,na);c];        m21(rd+cd,2*na)=0;
n21=[zeros(cd,na),b'];       n21(rd+cd,2*na)=0;



%%%%%%%% BRUISMA-STEINBUCH-BOYD-BALAKRISHNAN'S ALGORITHM  %%%%%%%%%%%


if gmin==0,  gmin=1e-6; end
OK=1;

while OK,


   g=(1+tol)*gmin;
   [q,r]=qr([m12;nob*[eye(cd),d'/g;d/g,eye(rd)]]);
   q=q(:,rd+cd+(1:2*na));
   geval=eig(q'*[m11;nob*m21/g],q'*[n11;nob*n21/g]);
   absgev=abs(geval);

   cev=find(abs(ones(size(absgev))-absgev) < tolsep*pbscale);

   if isempty(cev),   % no eval on the unit circle -> DONE
     if gmin <= 1e-6,
       disp('Norm between 0 and 1.0e-6');  gain=0;
     else
       gain=gmin;
     end
     peakf=angle(ceval);
     return
   else
     ang=angle(geval(cev))';
     ang=sort(ang(find(ang > 0 & ang < pi)));
     lan=length(ang);

     % form the vector of mid-points

     if lan==1,
        gain=gmin; return;
     else
        ang=(ang(1:lan-1)+ang(2:lan))/2;
     end
     zfrq=exp(sqrt(-1)*ang);


     gmin0=gmin;
     for z=zfrq,
       tmp=norm(d+cc/(z*ee-aa)*bb);
       if tmp > gmin,
          gmin=tmp;  ceval=z;
       end
     end

     if gmin<=gmin0, gain=gmin; return, end

   end


end %while
