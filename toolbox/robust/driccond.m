function [tot] = driccond(a,b,q,r,p1,p2);
%DRICCOND Discrete Riccati condition numbers.
%
% [TOT] = DRICCOND(A,B,Q,R,P1,P2) produces a Riccati condition
%    analysis using the concept of Arnold and Laub (1984).
%
%    INPUTS:
%
%      System: (A,B) matrices, and weighting matrices Q, R
%      Riccati Solution: P1,P2 (P = P2/P1)
%
%    OUTPUT:
%
%         TOT = [norA norQ norR conr conP1 conArn conBey res]
%     where                                           -1
%        norA, norQ, norR ----- F-Norm of A, Q, and  BR B'
%        conr ----- condition number of R
%        conP1 ---- condition number of P1
%        conArn --- Arnold and Laub's Riccati condition number
%        conBey --- Byers's Riccati condition number
%        res ------ residual of Riccati equation
%

% R. Y. Chiang & M. G. Safonov 9/18/1988
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% -----------------------------------------------------------------
[ns,ns] = size(a);
%
rc = b/r*b';
p = p2/p1;
perr = a'*p/(eye(ns)+rc*p)*a+q-p;
%
clc
format short e
disp(' -----------------------------------');
disp('    Riccati Condition Analysis ');
disp(' -----------------------------------');
disp('                         -1')
disp(' 1). F-Norm of A, Q and BR B`:');
norA = norm(a,'fro');
norQ = norm(q,'fro');
norRc = norm(rc,'fro');
norAQR = [norA norQ norRc],
disp('                        hit <ret> to continue');
pause
%
disp(' 2). Condition no. of R:');
conr = cond(r),
disp('                        hit <ret> to continue');
pause
%
disp(' 3). Condition no. of P1:');
conP1 = cond(p1),
disp('                        hit <ret> to continue');
pause
%
%disp(' 4). Arnold and Laub Riccati Condition no.:');
%acl = inv(eye(ns)+r*p)*ac;
%sepArn = min(svd(kron(eye(acl'),acl')+kron(acl',eye(acl'))));
%conArn = norm(qc,'fro')/norm(p,'fro')/sepArn,
%disp('                        hit <ret> to continue');
%pause
%
disp(' 4). Byers Riccati Condition no.:');
acl = (eye(ns)+rc*p)\a;
kacl = kron(acl',acl');
sepBye = min(svd(kacl-eye(size(kacl)*[1;0])));
conBye = (norm(q,'fro')/norm(p,'fro')+2*norm(a,'fro')^2 ...
         +norm(a,'fro')^2*norm(rc,'fro')*norm(p,'fro'))/sepBye,
disp('                        hit <ret> to continue');
pause
%
disp(' 5). Residual = norm(perr,1)/norm(p,1)');
res = norm(perr,1)/norm(p,1),
%
tot = [norA norQ norRc conr conP1 conBye res]';
%
% ------ End of DRICCOND.M % RYC/MGS %