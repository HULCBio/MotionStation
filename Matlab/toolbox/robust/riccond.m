function [tot] = riccond(a,b,qrn,p1,p2);
%RICCOND Continuous Riccati equation condition numbers.
%
% [TOT] = RICCOND(A,B,QRN,P1,P2) produces a Riccati condition
%    analysis using the concept of Arnold and Laub (1984).
%
%    INPUTS:
%
%      System: (A,B) matrices, and weighting QRN = [Q N;N' R];
%      Riccati Solution: P1,P2 (P = P2/P1)
%
%    OUTPUT:
%
%         TOT = [norAc norQc norRc conr conP1 conArn conBey res]
%     where                                         -1            -1
%        norAc, norQc, norRc ----- F-Norm of Ac=(A-BR N'), Qc=(Q-NR N'),
%                                  and Rc = B/R*B'.
%        conr ----- condition number of R
%        conP1 ---- condition number of P1
%        conArn --- Arnold and Laub's Riccati condition number
%        conBey --- Byers's Riccati condition number
%        res ------ residual of Riccati equation
%

% R. Y. Chiang & M. G. Safonov 9/18/1988
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% -----------------------------------------------------------------
[ns,ns] = size(a);
[q,n,nt,r] = sys2ss(qrn,ns);
%
ac = a - b/r*nt;
rc = b/r*b';
qc = q - n/r*nt;
%
ham = [ac -rc;-qc -ac'];
perr = [p2' -p1']*ham*[p1;p2];
p = p2/p1;
%
clc
format short e
disp(' -----------------------------------');
disp('    Riccati Condition Analysis ');
disp(' -----------------------------------');
disp(' ')
disp(' 1). F-Norm of Ac, Qc and B/R*B`:');
norAc = norm(ac,'fro');
norQc = norm(qc,'fro');
norRc = norm(rc,'fro');
norAQR = [norAc norQc norRc],
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
disp(' 4). Arnold and Laub Riccati Condition no.:');
acl = ac - rc*p;
sepArn = min(svd(kron(eye(ns),acl')+kron(acl',eye(ns))));
conArn = norm(qc,'fro')/norm(p,'fro')/sepArn,
disp('                        hit <ret> to continue');
pause
%
disp(' 5). Byers Riccati Condition no.:');
sepBye = sepArn;
conBye = (norm(qc,'fro')/norm(p,'fro')+2*norm(ac,'fro')...
         +norm(rc,'fro')*norm(p,'fro'))/sepBye,
disp('                        hit <ret> to continue');
pause
%
disp(' 6). Residual = norm(perr,1)/norm(p,1)');
res = norm(perr,1)/norm(p,1),
%
tot = [norAc norQc norRc conr conP1 conArn conBye res]';
%
% ------ End of RICCOND.M % RYC/MGS %
