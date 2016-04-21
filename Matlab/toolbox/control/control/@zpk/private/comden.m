function [a,b,c,d] = comden(Gain,Zero,Pole)
%COMDEN  Realization of SIMO or MISO ZPK model with common denominator.
%
%   [A,B,C,D] = COMDEN(GAIN,ZERO,POLE)  returns a state-space
%   realization for the SIMO or MISO model with data ZERO, POLE,
%   GAIN.  The last argument POLE is the vector of common poles.

%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/10 06:13:47 $

% Get number of outputs/inputs 
[p,m] = size(Gain);

% Handle various cases
if ~any(Gain) | isempty(Pole),
   a = [];   
   b = zeros(0,m);  
   c = zeros(p,0);  
   d = Gain;
   
elseif p==1 & m==1,
   % SISO case: use specialized algorithm that realizes the ZPK 
   % transfer function as a series of first or second orders
   Zero = Zero{1};
   nz = length(Zero);
   np = length(Pole);
   
   if isconjugate(Zero) & isconjugate(Pole)
       % Real case (complex zeros and poles are conjugate). Put complex pairs first
       cp = Pole(imag(Pole)>0);  ncp = length(cp);
       cz = Zero(imag(Zero)>0);  ncz = length(cz);
       p = zeros(np,1);   
       p([1:2:2*ncp 2:2:2*ncp 2*ncp+1:np]) = [cp ; conj(cp) ; Pole(~imag(Pole))];
       z = zeros(nz,1);   
       z([1:2:2*ncz 2:2:2*ncz 2*ncz+1:nz]) = [cz ; conj(cz) ; Zero(~imag(Zero))];
       
       % Append the second- and first-order sections
       nsec2 = max(ncp,ncz);
       nsec = np - nsec2;
   else
       % Complex case: use only first-order sections
       p = Pole;
       z = Zero;
       nsec2 = 0;
       nsec = np;
   end
   
   % Realize each fos/sos and append them
   a = zeros(np);
   b = zeros(np,nsec);
   c = zeros(nsec,np);
   d = zeros(nsec,1);
   % Balanced realizations of second-order sections
   for j=1:nsec2,
      xr = [2*j-1,2*j];
      [a(xr,xr),b(xr,j),c(j,xr),d(j)] = sos(z(xr(1):min(xr(2),nz),:),p(xr));
   end
   % Balanced realizations of first-order sections
   for j=1:nsec-nsec2,
      xr = 2*nsec2+j;
      jsec = nsec2+j;
      [a(xr,xr),b(xr,jsec),c(jsec,xr),d(jsec)] = fos(z(xr:min(xr,nz),:),p(xr));
   end
   
   % Eliminate inner signals to get state-space realization
   %    dx = Ax + Bw,   z = Cx + Dw,   w = Mz + N*u,  y = P*z
   % with N = [0;...;0;1] and P = [1,0,...,0]
   idmc = (eye(nsec) - diag(d(1:nsec-1,:),1))\c;   % (I-DM)\C
   imd = eye(nsec) - diag(d(2:nsec,:),1);          % I-MD
   a = a + b(:,1:nsec-1) * idmc(2:nsec,:);
   b = b * (imd\[zeros(nsec-1,1);1]);
   c = idmc(1,:);
   d = all(d);
      
   % Add gain (Note: gain is nonzero here)
   d = d * Gain;
   ks = sqrt(abs(Gain));
   b = b * ks; 
   c = c * (Gain/ks);
   
else
   % SIMO case: convert to TF and use COMPREAL.  First form the 
   % numerator array NUM (PxR matrix)
   mp = max(m,p);
   r = length(Pole)+1;       % common denominator length
   num = zeros(mp,r);
   for i=1:mp,
      % i-th row is numerator of i-th output channel
      ni = Gain(i) * poly(Zero{i});
      num(i,r-length(ni)+1:r) = ni;
   end
   
   % Call compreal
   [a,b,c,d] = compreal(num,poly(Pole));
   
   % Transpose/permute A,B,C,D in MISO case to make A upper Hessenberg
   if p<m,
      b0 = b;
      a = a.';  b = c.';  c = b0.';  d = d.';
      perm = size(a,1):-1:1;
      a = a(perm,perm);
      b = b(perm,:);
      c = c(:,perm);
   end
   
end


%%%%%%%%%%%%%

function [a,b,c,d] = sos(z,p)
%SOS  Realization of second-order section (d*s^2+e*s+f)/(s-p(1))/(s-p(2))

% Numerator coefficients
switch length(z)
case 0
   d = 0;
   e = 0;
case 1
   d = 0;
   e = 1;
case 2
   d = 1;
   e = -real(sum(z));
end

% Pole characteristics
rp = real(p);
ip = imag(p(1));
if abs(ip)>=1
   a12 = ip;
   a21 = -ip;
else
   a12 = 1;
   a21 = -ip^2;
end

% Auxiliary variables
x = d*sum(rp)+e; 
y = (real(prod(rp(2)-z))-d*ip^2)/a12;   % d*(rp(2)^2-ip^2)+e*rp(2)+f
lambda = (x^2+y^2)^0.25;

% State-space realization
a = [rp(1) , a12 ; a21 , rp(2)];
if lambda
   b = [x ; y]/lambda;
else
   b = [0;0];
end
c = [lambda , 0];


%------------------------

function [a,b,c,d] = fos(z,p)
%FOS  Realization of first-order section 1/(s-p) or (s-z)/(s-p) (d*s+e)/(s-p)

nump = prod(p-z);         % num(p)=1 or num(p)=p-z
lambda = sqrt(abs(nump));  % |num(p)|^.5

a = p;
b = lambda;
c = sign(nump)*lambda;
d = (length(z)~=0);

      
      
      

