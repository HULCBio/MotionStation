% solve A*x=lambda*B*x
n=100;   % size if the matrix A
b=10;    % width of the band
neig=10; % number of eigenvalues
bb=5;    % semibandwidth of B



general=1;
nMax=400;  % up to this size full matrices are computed too

Aband=rand(n,b);
Aband(:,1)+=1;
Aband(:,1)+=1*(1:n)';
for c=1:b
 Aband(n-c+1,c+1:b)=zeros(1,b-c);
endfor
Bband=0.1*rand(n,bb);
Bband(:,1)+=1.0;
for c=1:bb
 Bband(n-c+1,c+1:bb)=zeros(1,bb-c);
endfor

if n<=nMax
  Afull=BandToFull(Aband);
  Bfull=BandToFull(Bband);
  tic;
  %ef=eig(Afull);
  %R=chol(Bfull);
  %ef=sort(eig(inv(R')*Afull*inv(R)));
  if general ef=sort(qz(Afull,Bfull))(1:neig);
  else ef=sort(qz(Afull,eye(n)))(1:neig);
  endif
fulltime=toc

endif

precision=1e-3;

V=rand(n,neig);
tic
%eb=SBEig(Aband,V,precision);
if general [eb,evec,err]=SBEig(Aband,Bband,V,precision);
else [eb,evec,err]=SBEig(Aband,V,precision);
endif
bandtime=toc

if n<=nMax
  gaperror=gapTest(eb,err);
  disp("Shown below are: SBEig values, Octave values, absolute error, estBand, espGap")
  [eb(1:neig),ef(1:neig),ef(1:neig)-eb(1:neig),err,gaperror]
else
  [eb(1:neig),err]
endif


test=0;
if test
 [AA, BB, Q, Z, V, W, lambda] = qz (Afull, Bfull);
 [nl,i]=sort(lambda);
 nV=V(:,i(1:neig));
 for i=1:neig 
   abs(nV(:,i)'*evec(:,i)/(norm(nV(:,i))*norm(evec(:,i))))-1
 endfor
endif


