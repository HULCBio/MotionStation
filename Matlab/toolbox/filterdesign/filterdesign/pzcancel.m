function [z2, p2, k2] = pzcancel(z, p, k, tol)
%PZCANCEL Performs cancellation of the overlapping pole-zero pairs.
%   [Z2,P2,K2] = PZCANCEL(Z,P,K) gets rid of the poles and zeros that are at
%   the same location using the pole-zero-gain dscription.
%
%   The function requires full filter description to be given, e.i. numerator
%   and denominator for the transfer function, or poles, zeros and gain for
%   Pole-Zero form.
%
%   The parameter TOL can be used to specify the distance between the pole and
%   the zero that qualifies the pair for cancellation.
%
%   Example:
%        [b, a]     = ellip(3,0.1,30,0.409); % IIR halfband filter
%        [z, p, k]  = pzcancel(roots(b),roots(a),b(1))

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:17 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(3,4,nargin));
error(ftransfargchk(z, 'Zeros of the filter', 'vector'));
error(ftransfargchk(p, 'Poles of the filter', 'vector'));
error(ftransfargchk(k, 'Gain of the filter',  'scalar'));

if nargin == 4,
   error(ftransfargchk(tol, 'Tollerance factor', 'real', 'positive', 'scalar'));
else
   tol = 1e-5;
end;


% --------------------------------------------------------------------
% Perform the actual cancellation

z2= [];
pidx = zeros(1,length(p)); % indexes specifying which poles need cancelling
for j=1:length(z),
   fnd1 = find(abs(z(j)-p)<tol);
   fnd2 = find(pidx(fnd1)<eps);
   fnd  = fnd1(fnd2);
   if isempty(fnd),
      z2 = [z2, z(j)];      % zero copied to the output
   else
      pidx(fnd(1)) = 1;    % skip zero and mark the pole for cancelling
   end;
end;

% --------------------------------------------------------------------
% Assign output arguments. Convert to transfer function form if required.

p2 = p(find(pidx==0));
p2 = p2(:).';
k2 = k;
