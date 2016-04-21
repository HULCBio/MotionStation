%% the Laplace equation on the unit square is discretized
%% with nx and ny interiour grid points
nx=20;
ny=21;

% for nx!=ny convergence will be slow, due to eigenvalues being very close
% if nx=ny convergence is much faster, but tha gap estimate for the 
% errors fails miserably 

neigen=6;  % number of eigenvalues to be computed
tol=1e-5; 

%%%%%%%%%%%%%%%%%%%%
hx=1/(nx+1);
hy=1/(ny+1);


N=nx*ny;

Ab=zeros(N,nx+1);
Ab(:,1)+=2.0*(1/(hx*hx)+1/(hy*hy));
Ab(:,2)-=1/(hx*hx);
Ab(:,nx+1)-=1/(hy*hy);
for j=1:ny
    Ab(j*nx,2)=0.0;
endfor
for i=N-nx+1:N
    Ab(i,nx+1)=0.0;
endfor

Ab=Ab/pi**2;

if(nx*ny<400)
   A=BandToFull(Ab);
   tic
   eigenOct=sort(eig(A));
   octaveTime=toc
   eigenOct=eigenOct(1:neigen);
endif

V=rand(N,neigen); %% random initial eigen vectors
tic
[eigen,Vec,eBand]=SBEig(Ab,V,tol);
BandTime=toc

eigen=sort(eigen(1:neigen));

exact=zeros(neigen*neigen,1);
for i=1:neigen
  for j=1:neigen
      exact((i-1)*neigen+j)=((2/(hx*hx)*(1-cos((i*pi)/(nx+1)))+...
	2/(hy*hy)*(1-cos((j*pi)/(ny+1))))/(pi*pi));
  end
end

exact=sort(exact)(1:neigen);
relerrorsBand=(exact-eigen)./eigen;
%[exact,eigen,relerrorsBand]
% relerrorsOct=(exact-eigenOCT)./eigen

% use a posteriori estimate for error, should be reliable
R=SBProd(Ab,Vec)-Vec*diag(eigen);
apostRelError=eBand./eigen;

gaperror=gapTest(eigen,eBand);
disp("Shown below are: exact value, absolute error, estBand, espGap")
[exact,eigen,exact-eigen,eBand,gaperror]


