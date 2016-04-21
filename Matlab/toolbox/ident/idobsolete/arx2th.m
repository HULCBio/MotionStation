function eta=arx2th(A,B,ny,nu,lam,Tsamp)
%ARX2TH Constructs the THETA-format for an ARX model.
%   OBSOLTE function. Use IDARX instead.
%
%   TH=ARX2TH(A,B,ny,nu)
%
%   A,B: The given matrix polynomials for a (possibly) multivariable
%   ARX-model
%   y(t) + A1 y(t-1) + .. + An y(t-n) =
%   = B0 u(t) + ..+ B1 u(t-1) + .. Bm u(t-m)
%   A = [I A1 A2 .. An],  B=[B0 B1 .. Bm]
%   ny, nu : The number of outputs and inputs, respectively
%
%   TH is returned as a model structure (in the THETA-format)
%   where free parameters are consistent with the structure of A
%   and B, i.e. leading zeros in the rows of B are regarded as fixed
%   delays, and trailing zeros in the rows of A and B are regarded as a
%   definition of lower order polynomials. These zeros will thus be
%   regarded as fixed while all other parameters are free. The nominal
%   values of these free parameters are set equal to the values in A and B.
%   With th = ARX2TH(A,B,ny,nu,LAMBDA,Tsamp) also the innovations covarian-
%   ce matrix LAMBDA and the sampling interval Tsamp can be specified.
%
%   See also ARX, THETA and TH2ARX.

%   L. Ljung 10-2-90,11-2-91
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2001/08/03 14:23:40 $

if nargin < 4
   disp('Usage: TH = ARX2TH(A,B,NY,NU)')
   disp('       TH = ARX2TH(A,B,NY,NU,LAM,T)')
   return
end

if nargin<6, 
   Tsamp=[];end, 
if nargin<5, 
   lam=[];
end
if isempty(Tsamp),
   Tsamp=1;
end, 
if isempty(lam),
   lam=eye(ny);
end
[ra,ca]=size(A);
if isempty(B),
   rb=ra;nu=0;
else 
   [rb,cb]=size(B);
end
na=(ca-ny)/ny; 
if nu>0,
   nb=(cb-nu)/nu;
else 
   nb=0;
end
if ra~=ny | rb~=ny, 
   error('The A and the B polynomials must have the same number of rows as the number of outputs!'),
end
if floor(na)~=na | floor(nb)~=nb,
   error(sprintf(['The size of A or B is not consistent with an ARX-model!,'...
         '\nThe number of columns must be a multiple of the number of rows'])),
end

% IDPOLY
if (ra == 1) & (nu <= 1)
  eta = idpoly(A, B, 'Ts', Tsamp, 'NoiseVariance', lam);

% IDARX
else
  for ka=1:na+1
    A1(:,:,ka)=A(:,(ka-1)*ny+1:ka*ny);
  end
  for kb = 1:nb+1
    B1(:,:,kb) = B(:,(kb-1)*nu+1:kb*nu);
  end

  eta = idarx(A1,B1,'Ts',Tsamp,'NoiseVariance',lam);
end
 
 
