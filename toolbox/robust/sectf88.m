function [Ap,Bp,Cp,Dp] = sectf(varargin)
%SECTF88 Sector transformation (1988 version).
%
% [SS_P] = SECTF(SS_,d11,a,b,sectype) or
% [Ap,Bp,Cp,Dp] = SECTF(A,B,C,D,d11,a,b,sectype) performs multivariable
%   sector bilinear transformation on input-output channel 1 of a plant
%   P(s) such that the original input-output pairs (U1,Y1) in sector[a,b]
%   is mapped to another sector[x,y], or vice versa.
%
%                           |A  B1  B2 |
%           P(s) := |A B| = |C1 D11 D12|
%                   |C D|   |C2 D21 D22|
%
%           d11 = any matrix of same size as D11
%
%   Four options are provided: (must have 0 < b <= inf, a < b)
%
%       sectype = 1, sector(a,b) -----> sector(0,inf) = positive real problem
%       sectype = 2, sector(a,b) -----> sector(-1,1)  = small gain problem
%       sectype = 3, sector(0,inf) ---> sector(a,b) (inverse map of sectype 1)
%       sectype = 4, sector(-1,1) ----> sector(a,b) (inverse map of sectype 2)
%

% R. Y. Chiang & M. G. Safonov 2/1/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% --------------------------------------------------------------------------

nag1=nargin;
[emsg,nag1,xsflag,Ts,A,B,C,D,d11,aa,bb,sectype]=mkargs5x('ss',varargin); error(emsg);

[rd11,cd11] = size(d11);
[ra,ca] = size(A);
[rb,cb] = size(B);
[rc,cc] = size(C);
m = rd11; cb2 = cb-m; rc2 = rc-m;
%
if rd11 ~= cd11
   disp('    D11 NONSQUARE !! NO SECTOR TRANSFORMATION EXISTS !!')
   return
end
% ---------------------------------------------
if sectype == 1
   q = aa; r = 1/bb;
end
%
if sectype== 2
   q1 = aa; r1 = 1/bb;
   q2 = 1; r2 = -1;
end
%
if sectype== 3
   q = -aa; r = -1/bb;
end
%
if sectype== 4
   q1 = -1; r1 = 1;
   q2 = -aa; r2 = -1/bb;
end
% ---------------------------------------------
B = [B zeros(rb,2)];
C = [C;zeros(2,cc)];
M = zeros(m+cb2+m+m,m+cb2);
N = zeros(m+rc2,m+rc2+m+m);
F = zeros(m+cb2+m+m,m+rc2+m+m);
F(1:m,m+rc2+m+1:m+rc2+m+m) = eye(m);
F(m+cb2+m+1:m+cb2+m+m) = eye(m);
% ---------------------------------------------
if cb2 ~= 0 & rc2 ~= 0
   M(m+1:m+cb2,m+1:m+cb2) = eye(cb2);
   M(m+cb2+1:m+cb2+m,1:m) = eye(m);
   N(1:m,m+rc2+1:m+rc2+m) = eye(m);
   N(m+1:m+rc2,m+1:m+rc2) = eye(rc2);
else
   M(m+cb2+1:m+cb2+m,1:m) = eye(m);
   N(1:m,m+rc2+1:m+rc2+m) = eye(m);
end
% ----------------------------------------------
if sectype == 1 | sectype == 3
   K = [-q 1-q*r;1 r];
   D = [D zeros(rc,2);zeros(2,cb) K];
   [Ap,Bp,Cp,Dp] = interc(A,B,C,D,M,N,F);
end
%
if sectype == 2 | sectype == 4
   K1 = [-q1 1-q1*r1;1 r1];
   D = [D zeros(rc,2);zeros(2,cb) K1];
   [A,B,C,D] = interc(A,B,C,D,M,N,F);
   K2 = [-q2 1-q2*r2;1 r2];
   D = [D zeros(rc,2);zeros(2,cb) K2];
   [Ap,Bp,Cp,Dp] = interc(A,B,C,D,M,N,F);
end
%
if xsflag
   ss_p = mksys(Ap,Bp,Cp,Dp,Ts);
   Ap = ss_p;
end
%

% ---------- End of SECTF88.M --- RYC/MGS 1988 (Rev. 03/06/92)