% [gain,peakf]=norminf(sys,tol)
%
% Computes the peak gain of the frequency response of
%                                   -1
%             G (s) = D + C (sE - A)  B
%
% The norm is finite if and only if (A,E) has no eigenvalue
% on the imaginary axis.
%
% Input:
%   SYS        system matrix description of G(s)  (see LTISYS)
%   TOL        relative accuracy required  (default = 0.01)
%
% Output:
%   GAIN       peak gain  (RMS gain if G is stable)
%   PEAKF      frequency at which this norm is attained.
%              That is, such that
%
%                     || G ( j * PEAKF ) ||  =  GAIN
%
%
% See also  DNORMINF, QUADPERF, MUPERF.

% Authors: P. Gahinet and A.J. Laub  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.8.2.3 $

function [gain,peakf]=norminf(sys,tol)


if nargin > 2,
  error('usage:  [gain,peakf]=norminf(sys,tol)');
elseif ~islsys(sys),
  error('SYS must be a system matrix');
elseif nargin < 2,
  tol=1.0e-2;
end

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


% test the spectrum of A wrt the imag. axis
na=size(a,1);
if desc, eiga=eig(a,e); else eiga=eig(a); end
reala=abs(real(eiga));
imaga=imag(eiga);
if min(reala) < macheps*max([noa,abs(eiga)']),
  error('A has eigenvalues on the jw-axis: the norm is infinite');
end
ind=find(imaga > 1e-3);
selfrq=imaga(ind);

% select the eval closest to the imag. axis
[aux,ind]=min(reala(ind));
selfrq=selfrq(ind);

% add frequency 0 and infinity (-> always even # pts below!)
selfrq=[selfrq;0];
gmin=norm(d);
peakf=Inf;


% hessenberg of A
if desc,
  [aa,ee,q,z]=qz(a,e,'complex');
  bb=q*b;   cc=c*z;
else
  [u,aa]=hess(a); ee=e;
  bb=u'*b;  cc=c*u;
end

% compute a lower estimate
j=sqrt(-1);
for w=selfrq',
   tmp=norm(d+(cc/(j*w*ee-aa))*bb);
   if tmp > gmin,
      gmin=tmp;
      peakf=w;
   end
end


% pencil set-up

h11=mdiag(a,-a');
h12=[zeros(na,rd) b;c' zeros(na,cd)];
h21=mdiag(c,-b');
j11=mdiag(e,e');

%%%%%%%% BRUISMA-STEINBUCH-BOYD-BALAKRISHNAN'S ALGORITHM  %%%%%%%%%%%


if gmin==0,  gmin=1e-6; end
OK=1;



while OK,

   g=(1+tol)*gmin;
   [q,r]=qr([h12;nob*[eye(rd),d/g;d'/g,eye(cd)]]);
   q=q(:,rd+cd+(1:2*na));
   if desc, aux=q'*[j11;zeros(size(h21))]; else aux=q(1:2*na,:)'; end
   geval=eig(q'*[h11;nob*h21/g],aux);
   realgev=abs(real(geval));

   cev=find(realgev < tolsep*(1+max(abs(geval))));

   if isempty(cev),   % no eval on the imag. axis -> DONE
     if gmin <= 1e-6,
       disp('Norm between 0 and 1.0e-6');  gain=0;
     else
       gain=gmin;
     end
     return
   else
     ws=imag(geval(cev))';
     ws=sort(ws(find(ws > 0)));
     lws=length(ws);

     % form the vector of mid-points

     if lws==1,
        gain=gmin; return;
     else
        ws=sqrt(ws(1:lws-1).*ws(2:lws));
     end

     gmin0=gmin;
     for w=ws,
       tmp=norm(d+cc/(j*w*ee-aa)*bb);
       if tmp > gmin,
          gmin=tmp;  peakf=w;
       end
     end

     if gmin<=gmin0, gain=gmin; return, end

   end


end %while
