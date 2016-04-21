% function [X,resid] = clyap(A,C))
%
%   Solves the Lyapunov equation  A'*X + X*A + C'C = 0
%   CLYAP calls the subroutine SJH6 to solve the Lyapunov
%   equation using Cholesky factors. RESID is the norm
%   of residual error: norm(A'*X + X*A + C'C).
%
%   See also: RIC_EIG, RIC_SCHR, SJH6, and SYLV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function  [X,resid]= clyap(A,C)
   if nargin == 0
     disp(['usage: [X,resid] = clyap(A,C)']);
     return
   end %if nargin<1

   if nargin ~= 2
     error('CLYAP requires two matrices')
   end

[mattype1,rowd1,cold1,num1] = minfo(A);
[mattype2,rowd2,cold2,num2] = minfo(C);

   if (mattype1 ~= 'cons' | mattype2 ~= 'cons')
     error('CLYAP requires the input of two CONSTANT matrices')
   elseif (rowd1 ~= cold1)
     error('The CONSTANT matrix A must be square')
   elseif (rowd1 ~= cold2)
     error('A and C have inconsistent dimensions')
   end

   [T,AS]=schur(A);
%%% SJH6 assumes that C = C'*C hence its pos def.
   CS = C*T;
 % Solve the Lyapunov equation with the Cholesky factor U, where
 %  U is upper triangular and X = U'*U
   U = sjh6(AS,CS);
   X = T*U'*U*T';
   resid = norm(A'*X + X*A + C'*C);

%