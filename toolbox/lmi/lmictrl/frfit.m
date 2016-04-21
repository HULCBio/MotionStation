%  [num,den]=frfit(omega,fresp,r,weight)
%  sys = frfit(omega,fresp,r,weight)
%
%  Called by MAGSHAPE/MRFIT
%
%  Fits frequency response data points by a stable transfer
%  function
%                G(s) = NUM(s)/DEN(s)
%  of order R.
%
%  The interpolation uses Chebychev polynomials.  OMEGA is
%  a vector of frequencies and FRESP contains the frequency
%  response at these frequencies.   Frequency-weighted
%  interpolation is performed by specifying a vector WEIGHT of
%  frequency weights.
%
%  See also  MAGSHAPE, MRFIT.

% Authors: P. Gahinet and P. Apkarian 6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [num,den]=frfit(omega,fresp,r,weight)


% handle static gains
nf=max(abs(fresp));
aver=sum(fresp)/length(fresp);
if max(abs(fresp-aver)) < .1*nf,
   num=real(aver); den=1; return
end


r1=r+1;
npts=length(omega);
wmed=1; % sqrt(max(omega)*min(omega));omega=omega/wmed;
j=sqrt(-1);
if nargin < 4, weight=ones(npts,1); end


% construct upper triangular M to return to canonical rep.
M0=zeros(r+1,1); M1=M0;
M0(1)=1; M1(2)=1; M=[M0 M1];
for i=1:r-1,
   Mt=2*[0;M1(1:r)]-M0;
   M=[M Mt];
   M0=M1; M1=Mt;
end


% get slopes at origin and infinity
sl0=round((log10(abs(fresp(2)))-log10(abs(fresp(1))))...
          /(log10(omega(2))-log10(omega(1))));

slinf=round((log10(abs(fresp(npts)))-log10(abs(fresp(npts-1))))...
          /(log10(omega(npts))-log10(omega(npts-1))));

if slinf>0,   % add flat asymptote
  omega=[omega;[10;15]*omega(npts)];
  fresp=[fresp;[1;1]*10^slinf*abs(fresp(npts))];
  weight=[weight;1;1];
  npts=npts+2;
  slinf=0;
end


% check consistency slopes/order
mindeg=max(abs(sl0),-slinf+(sl0>0)*abs(sl0)); text=' ';

if mindeg > r,
  text=sprintf(...
      'The filter order should be at least %d for accurate fitting\n',mindeg);
  % reset slopes
  sl0=sign(sl0)*min(r,sl0);
  slinf=-(r-(sl0>0)*abs(sl0));
end

hh=findobj(gcf,'tag','MAGstatus');
if ~isempty(hh), set(hh,'str',text); end



% form the matrix  Mij = T_j (omega_i)  for i=1:npts,j=1:r+1
%-----------------------------------------------------------
jw=j*omega;
mag=abs(fresp);
t0=ones(npts,1); t1=jw;
A=[ones(npts,1) , jw];

for i=1:r-1,
   t=2*jw.*t1-t0;
   A=[A,t];
   t0=t1; t1=t;
end

Aom=A;
A=[A -diag(fresp)*A];

%%% TMP
AA=A; om0=omega;
%%%%


% Form system of hard constraints (end points + slopes)
%     NB: must be written in terms of canonical basis!
%--------------------------

Acons=[]; ycons=[];

% slope at zero
if sl0<=0,         % -> b1=...=bp=0,  a1/bp+1/w0^p=mag (p=-sl0)
  Acons=[Acons; zeros(-sl0,r1) M(1:-sl0,:);...
                M(1,:) -(mag(1)*omega(1)^(-sl0))*M(1-sl0,:)];
  ycons=[ycons; zeros(-sl0+1,1)];
elseif sl0>0,      % -> a1=...=ap=0,  ap+1.w0^p/b1=mag (p=sl0)
  Acons=[Acons; M(1:sl0,:) zeros(sl0,r1);...
                M(1+sl0,:)*omega(1)^sl0 -mag(1)*M(1,:)];
  ycons=[ycons; zeros(sl0+1,1)];
end

% normalization  br+1=1
Acons=[Acons; zeros(1,r1) M(r1,:)];
ycons=[ycons; 1];

% slope at infty
if slinf<=0,        % ar-p+2=...=ar+1=0   ar-p+1=mag*wn^(-slinf)
  Acons=[Acons; M(r1+slinf:r1,:) zeros(-slinf+1,r1)];
  ycons=[ycons; mag(npts)*omega(npts)^(-slinf); zeros(-slinf,1)];
end



%%%%%%%%% SOLVE THE FITTING PB  VIA CHEBYSHEV INTERPOLATION

[nc,nv]=size(Acons);

if nc >= nv,  % no remaining degrees of freedomn

  x=Acons\ycons;

else          % solve least-squares fitting pb

  % QR-based elimination of part of [a;b] to enforce constraints
  indin=1:nv; indout=[];

  for i=1:nc,
     % sort by norm the columns of subblock to be reduced
     if i<nc,
        [m,ix]=max(max(abs(Acons(i:nc,i:nv))));
     else
        [m,ix]=max(abs(Acons(i:nc,i:nv)));
     end
     Acons(:,i:nv)=[Acons(:,i+ix-1) Acons(:,[i:i+ix-2,i+ix:nv])];
     indout=[indout,indin(ix)];   indin=indin([1:ix-1,ix+1:nv-i+1]);

     x=Acons(i:nc,i); Atmp=Acons(i:nc,i+1:nv); ytmp=ycons(i:nc);
     if x(1)>=0, sgn=1; else sgn=-1; end
     aux=sgn*sqrt(x'*x);   x(1)=x(1)+aux;    nx2=.5*x'*x;
     Atmp=[[-aux;zeros(nc-i,1)] Atmp-x*((x'*Atmp)/nx2)];
     ytmp=ytmp-x*((x'*ytmp)/nx2);
     Acons(i:nc,i:nv)=Atmp;     ycons(i:nc)=ytmp;
  end

  perm=[indout indin];   % total column permutation
  Ac1=Acons(:,1:nc); Ac2=Acons(:,nc+1:nv);


  % form reduced least-squares fitting pb
  A=A(1:npts,:);
  A=[real(A);imag(A)];
  A=A(:,perm);        % reflect permutation used in QR
  A1=A(:,1:nc); A2=A(:,nc+1:nv);
  A=A2-A1*(Ac1\Ac2);
  y=-A1*(Ac1\ycons);


  % frequency-adjusted weighting
  fweight=ones(npts,1);
  ind=find(omega > 10);
%  fweight(ind)=1./(sqrt(mag(ind)).*omega(ind).^r);
  fweight(ind)=1./(omega(ind).^r);
  ind=find(omega < .01);
%  fweight(ind)=1./(mag(ind).*omega(ind).^min(0,sl0));
  fweight(ind)=1./(omega(ind).^min(0,sl0));
  fweight=weight.*fweight;
  Wt=diag([fweight;fweight]);


%condA=max(svd(Wt*A))/min(svd(Wt*A))

  x=pinv(Wt*A)*(Wt*y);
  x=[Ac1\(ycons-Ac2*x);x];  % solution to original problem
  [s,perm]=sort(perm);
  x=x(perm);                % undo column permutation used in QR


  % second pass: evaluate rel. error, update Wt, and refine fit
  % -----------------------------------------------------------
  nresp=Aom*x(1:r1); dresp=Aom*x(r1+1:2*r1);  %num/den response
  relerr=min(abs(abs(nresp./dresp)./mag-1)',1)';
  ind=find(mag < .01); relerr(ind)=relerr(ind)*.3;
  ind=find(relerr>.5); fweight(ind)=(10.^relerr(ind)).*fweight(ind);
  Wt=diag([fweight;fweight]);
  x=pinv(Wt*A)*(Wt*y); x=[Ac1\(ycons-Ac2*x);x];   x=x(perm);

end


a=x(1:r1); b=x(r1+1:2*r1);
num=fliplr((M*a)');
den=fliplr((M*b)');


%%%%%%%% disp error
err=AA*x;
err=abs(err);
%om_fw_er_fwer=[om0*wmed fweight err fweight.*err]
%%%%%%%%%%%%%%


% enforce stab + min phase

num=num(-slinf+1:r1);
rn=roots(num); rn=-abs(real(rn))+j*imag(rn);
if ~isempty(rn),
   ind=find(abs(real(rn)) < 1e-3*max(1,abs(rn)));
   rn(ind)=-1e-3*max(1,abs(rn(ind)))+j*imag(rn(ind));
end
dn=roots(den); dn=-abs(real(dn))+j*imag(dn);
if ~isempty(dn),
   ind=find(abs(real(dn)) < 1e-3*max(1,abs(dn)));
   dn(ind)=-1e-3*max(1,abs(dn(ind)))+j*imag(dn(ind));
end
num=real(num(1)*poly(rn));
den=real(den(1)*poly(dn));



if nargin==1,
   num=sbalanc(ltisys('tf',num,den));
end
