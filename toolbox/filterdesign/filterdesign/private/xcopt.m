function [y, allpassnum, allpassden, A, B] = xcopt(C, wt, wo, FSel)
%XCOPT Cost function for N-point complex frequency transformation.
%   [Y,ALLPASSNUM,ALLPASSDEN,A,B] = XCOPT(C,Wt,Wo,FSel) is a cost function
%   used for re-optimisation of the coefficients of the N-point exact
%   complex frequency transformation in order to get the band  edges in the
%   right place.
%
%   Inputs:
%     C          - The rotation factor in front of the allpass mapper
%     Wo         - Old frequwncy locations in radians
%     Wt         - New frequency locations in radians
%     FSel       - The selection of the objective function:
%                  1 - Checking absolute instability of the filter
%                  2 - Minimizing the mapping errors
%   Outputs:
%     y          - The value of the cost function
%     Allpassnum - Numerator of the mapping filter
%     Allpassden - Denominator of the mapping filter
%
%   See also ALLPASSLP2XC, IIRLP2XC and ZPKLP2XC.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:39:36 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(4,4,nargin));

OPT = 2;

if OPT == 1,

% ---------------------------------------------------------------------
% Calculate the mapping filter in tems of Z

   N            = length(wt)/2;    % Filter order
   A            = zeros(4*N, 2*N); % Equation matrix (4N x 2N) overdetermined
   B            = zeros(4*N, 1);   % Column vector   (4N)      overdetermined

   arg1         = pi*(wo(:)+wt(:)*N);
   B(1:2*N)     = cos(pi*C) - cos(arg1);
   B(2*N+1:4*N) = sin(pi*C) - sin(arg1);

   for k=1:N,
      arg1                =  pi*(wo(:)+(N-k)*wt(:));
      arg2                =  pi*(C+wt(:)*k);
      A(1:2*N,     2*k-1) =  cos(arg1) - cos(arg2);
      A(2*N+1:4*N, 2*k-1) =  sin(arg1) - sin(arg2);
      A(1:2*N,     2*k)   =  sin(arg1) + sin(arg2);
      A(2*N+1:4*N, 2*k)   = -cos(arg1) - cos(arg2);
   end;

   X = (A\B)';

   allpassnum = [X(1:2:end)+i.*X(2:2:end), 1];
   allpassden = fliplr(conj(allpassnum));
   Const      = allpassden(end);
   allpassnum = allpassnum * exp(i*pi*C) ./ Const;
   allpassden = allpassden ./ Const;

elseif OPT == 2,

   % ---------------------------------------------------------------------
   % Calculate the mapping filter in tems of Z^-1

   N            = length(wt)/2;    % Filter order
   A            = zeros(4*N, 2*N); % Equation matrix (4N x 2N) overdetermined
   B            = zeros(4*N, 1);   % Column vector   (4N)      overdetermined

   arg3         = -pi*(wo(:)+wt(:)*N);
   B(1:2*N)     = cos(-pi*C) - cos(arg3);
   B(2*N+1:4*N) = sin(-pi*C) - sin(arg3);

   for k=1:N,
      arg1                =  -pi*(wo(:)+(N-k)*wt(:));
      arg2                =  -pi*(C+wt(:)*k);
      A(1:2*N,     2*k-1) =  cos(arg1) - cos(arg2);
      A(2*N+1:4*N, 2*k-1) =  sin(arg1) - sin(arg2);
      A(1:2*N,     2*k)   =  sin(arg1) + sin(arg2);
      A(2*N+1:4*N, 2*k)   = -cos(arg1) - cos(arg2);
   end;

   X = (A\B)';

   allpassden = [1, X(1:2:end)+i*X(2:2:end)];
   allpassnum = conj(fliplr(allpassden));
   Const      = allpassden(end);
   allpassnum = allpassnum ./ Const .*exp(-i*pi*C);
   allpassden = allpassden ./ Const;

end;

% ---------------------------------------------------------------------
% Calculate the objective function

if     FSel == 1,
    P = abs(roots(allpassden));
    y = sum(P(find(P < 1)));
elseif FSel == 2,
    H = freqz(allpassnum, allpassden, wt, 2);
    y = norm(angle(H)/pi-wo, 2);
end;