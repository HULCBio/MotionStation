function [x] = lyapkr(a,b,c)
%LYAPKR Lyapunov/Sylvester equation solver (Kronecker product approach).
%
% [X] = LYAPKR(A,B,C) produces the solution of a Lyapunov or Sylvester equation
%      The algorithm is simply the Kronecker product of a special
%      kind, i.e :
%
%        A1*X*B1 + A2*X*B2 + A3*X*B3 + ... = Ck
%
%        The solution is
%
%        [KRON(A1,B1') + KRON(A2,B2') + ... ] * S[X] = S(Ck)
%
%        For the Lyapunov or Sylvester equation :
%
%            A1 = A,  B1 = I,  A2 = I, B2 = B,  Ck = -C.
%
%       such that :  A * X + X * B + C = 0
%

% R. Y. Chiang & M. G. Safonov 2/14/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% -------------------------------------------------------------------
%

[ra,ca] = size(a);
[rb,cb] = size(b);
[rc,cc] = size(c);
%
if (ra ~= ca) | (rb ~= cb) | (rc ~= ra) | (cc ~= cb)
        disp(' Error : Inconsistent inputs to LYAP solver.');
end
%
if rc == cc
   krnkr = kron(a,eye(ra)') + kron(eye(rb),b');
   Cr = -c';
   sc = Cr(:);
   xx = inv(krnkr) * sc;
   x  = unstkr(xx,ra,ca);
end
%
if (rc < cc)
    a1 = zeros(cc);
    a1(1:rc,1:rc) = a;
    krnkr = kron(a1,eye(cc)') + kron(eye(cc),b');
    c  = [c;zeros((cc-rc),cc)];
    Cr = -c';
    sc = Cr(:);
    xx = inv(krnkr) * sc;
    x  = unstkr(xx,cc,cc);
    x = x(1:rc,:);
end
%
if (rc > cc)
    b2 = zeros(rc);
    b2(1:cc,1:cc) = b;
    krnkr = kron(a,eye(rc)') + kron(eye(rc),b2');
    c  = [c zeros(rc,(rc-cc))];
    Cr = -c';
    sc = Cr(:);
    xx = inv(krnkr) * sc;
    x  = unstkr(xx,rc,rc);
    x  = x(:,1:cc);
end
%
% ------ End of LYAPKR.M --- RYC/MGS
