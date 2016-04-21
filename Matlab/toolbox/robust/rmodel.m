function [a,b,c,d]=rmodel(n,p,m)
%RMODEL Generates random stable continuous nth order test models.
%
%	[NUM,DEN]=RMODEL(N) generates an Nth order SISO transfer function
%		 model.
%	[NUM,DEN]=RMODEL(N,P) generates an Nth order single input, P
%		output transfer function model.
%	[A,B,C,D]=RMODEL(N) generates an Nth order SISO state space model.
%	[A,B,C,D]=RMODEL(N,P,M) generates an Nth order, P output, M input,
%		state space model.
%
%  See also DRMODEL.

%	Clay M. Thompson 1-22-91
%  Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $

nag1 = nargin;
nag2 = nargout;



if nag1==0,
  n=max([1,round(abs(10*randn(1,1)))]);
  if nag2==4,
    p=max([1,round(4*randn(1,1))]);
    m=max([1,round(4*randn(1,1))]);
  else
    m=1;
    p=1;
  end
end
if nag1<2, p=1; end
if nag1<3, m=1; end

%rand('uniform')
% Prob of an integrator is 0.10 for the first and 0.01 for all others
 nint = (rand(1,1)<0.10)+sum(rand(n-1,1)<0.01);
% Prob of repeated roots is 0.05
 nrepeated = floor(sum(rand(n-nint,1)<0.05)/2);
% Prob of complex roots is 0.5
 ncomplex = floor(sum(rand(n-nint-2*nrepeated,1)<0.5)/2);
 nreal = n-nint-2*nrepeated-2*ncomplex;

if nag2==2, nzeros = sum(rand(n,p)<0.7); end

% Determine random poles
rep = -exp(randn(nrepeated,1));
re = -exp(randn(ncomplex,1));
% Make imaginary part bigger for more oscillatory (and interesting) models
im = 3 * exp(randn(ncomplex,1));
jay = sqrt(-1);
complex = -exp(randn(ncomplex,1))+sqrt(-1)*exp(randn(ncomplex,1));

if nag2==2, % Random transfer function
  poles = [re+jay*im;re-jay*im;zeros(nint,1);rep;rep;-exp(randn(nreal,1))];

  % Determine random zeros
  zer = inf*ones(n,p);
  jay = sqrt(-1);
  for i=1:p
    %rand('uniform')
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
    a(ndx,ndx) = diag([zeros(nint,1);rep;rep;-exp(randn(nreal,1))]);
  end
  T = orth(randn(n,n));
  a = T\a*T;
  b = randn(n,m);
  c = randn(p,n);
  d = randn(p,m);
  %rand('uniform')
  b = b .* (rand(n,m)<0.75);
  c = c .* (rand(p,n)<0.75);
  d = d .* (rand(p,m)<0.5);
end