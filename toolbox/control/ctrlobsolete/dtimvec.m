function npts=dtimvec(a,b,c,x0,st)
%DTIMVEC Returns time vector used by discrete time response functions.
%	NPTS=DTIMVEC(a,b,c,X0,ST,PRECISION) returns a suggestion  
%	for the number of samples, NPTS. that should be used 
%	with discrete state space systems (a,b,c) that have known 
%	initial conditions X0. NPTS can be used,
%	for instance, for step and impulse responses. 
%	
%	DTIMVEC attempts to produce a number of points that ensures the 
%	output responses have decayed to approx. ST % of their initial 
%	or peak values. 

%	A.C.W.Grace 9-21-89, AFP 10-1-94
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.9 $  $Date: 2002/04/10 06:33:38 $

[r,n]=size(c);
% Work out scale factors by looking at d.c. gain, 
% eigenvectors and eigenvalues of the system.
[m,r]=eig(a);
r=diag(r);

% Equate the responses to the sum of a set of 
% exponentials(r) multiplied by a vector of magnitude terms(vec).
[r1,n]=size(c);
if r1>1, 
   c1=max(abs(c)); 
else
   c1=c; 
end

% Cater for the case when m is singular
if rcond(m)<eps,
   vec = (c1*m).'.*(1e4*ones(n,1));
else
   vec=(c1*m).'.*(m\x0);
end

% Cater for the case when poles and zeros cancel each other out:
vec=vec+1e-20*(vec==0);

% d.c. gain (not including d matrix)
dcgain =c1*x0; % or dcgain=c\(eye(n)-a)*b;
ind=find(imag(r)>0);

% If the d.c gain is small then base the scaling
% factor on the estimated maximum peak in the response.
if abs(dcgain)<1e-8,
   % Estimation of the maximum peak in the response.
   peak=2*imag(vec(ind)).*exp(-abs(0.5*real(r(ind)).*pi./imag(r(ind))));
   pk=max([abs(dcgain);abs(peak);eps]);
else
   pk=dcgain;
end

% Work out the st% settling time for the responses.
% (or st% peak value settling time for low d.c. gain systems).
lt=(st*pk./abs(vec));
absr = abs(r);
n1=log(lt)./log(absr+(absr==1)+eps*(absr==0));
n=max(real(n1));

% Touch up n if necessary
if isnan(n),
   n = 10;
end
% For unstable problems n will be negative
n = max(n, 10);
n = min(n,1000);

% Round the maximum time to an appropriate value for plotting.
nn = chop(n,1,5);
if abs((n-nn)/n)>0.2, 
   nn = chop(n,1,1);
   if abs((n-nn)/n)>0.2,
      nn = chop(n,2,2);
   end
end
npts=nn+1;

% end dtimvec
