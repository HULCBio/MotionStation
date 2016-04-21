function [a,b,c,d]=drmodel(n,p,m)
%DRMODEL Generates random stable discrete nth order test models.
%   [NUM,DEN]=DRMODEL(N) generates an Nth order SISO transfer
%       function model.
%   [NUM,DEN]=DRMODEL(N,P) generates an Nth order single input, P 
%       output transfer function model.
%   [A,B,C,D]=DRMODEL(N) generates an Nth order SISO state space model
%   [A,B,C,D]=DRMODEL(N,P,M) generates an Nth order, P output, M 
%       input, state space model.
%       
%   See also: RMODEL.

%   Clay M. Thompson  12-27-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:23:35 $

error(nargchk(0,3,nargin));

if nargin==0,
  n = max([1,round(abs(10*randn(1,1)))]);
  if nargout==4,
    p = max([1,round(4*randn(1,1))]);
    m = max([1,round(4*randn(1,1))]);
  else
    m = 1;
    p = 1;
  end
end
if nargin<2, 
   p = 1; 
end
if nargin<3, 
   m = 1; 
end

% Prob of an integrator is 0.10 for the first and 0.01 for all others
nint = (rand(1,1)<0.10)+sum(rand(n-1,1)<0.01);

% Prob of repeated roots is 0.05
nrepeated = floor(sum(rand(n-nint,1)<0.05)/2);

% Prob of complex roots is 0.5
ncomplex = floor(sum(rand(n-nint-2*nrepeated,1)<0.5)/2);
nreal = n-nint-2*nrepeated-2*ncomplex;

% Determine random poles
rep = 2*rand(nrepeated,1)-1;
mag = rand(ncomplex,1);
ang = pi*rand(ncomplex,1);
jay = sqrt(-1);
complex = mag.*exp(jay*ang);
re = real(complex); im = imag(complex);

if nargout==2, % Random transfer function
   poles = [re+jay*im;re-jay*im;ones(nint,1);rep;rep;2*rand(nreal,1)-1];
  
   % Determine random zeros
   zer = inf*ones(n,p);
   jay = sqrt(-1);
   for i=1:p
      % Prob of complex zeros is 0.35
      ncomplex = floor(sum(rand(n,1)<0.35)/2);
      % Prob of real zero is 0.35
      nreal = sum(rand(n-2*ncomplex,1)<0.35);
      nzeros = 2*ncomplex+nreal;
      if nzeros>0,
         re = randn(ncomplex,1); im = randn(ncomplex,1);
         zer(1:nzeros,i) = [re+jay*im;re-jay*im;randn(nreal,1)];
      end
   end
   [a,b] = zp2tf(zer,poles,randn(p,1));

else % Random state space model
   a = zeros(n,n);
   for i=1:ncomplex,
      ndx = [2*i-1,2*i];
      a(ndx,ndx) = [re(i),im(i);-im(i),re(i)];
   end
   ndx = [2*ncomplex+1:n];
   if ~isempty(ndx),
      a(ndx,ndx) = diag([ones(nint,1);rep;rep;2*rand(nreal,1)-1]);
   end
   T = orth(rand(n,n));
   a = T\a*T;
   b = rand(n,m);
   c = rand(p,n);
   d = rand(p,m);
   b = b .* (rand(n,m)<0.75);
   c = c .* (rand(p,n)<0.75);
   d = d .* (rand(p,m)<0.5);
end

% end drmodel
