% GRAM   可制御性グラミアンと可観測性グラミアン
%
%
% Wc = GRAM(SYS,'c') は、状態空間モデル SYS の可制御性グラミアンを求めます。
%
% Wo = GRAM(SYS,'o') は、可観測性グラミアンを求めます。
%
% 両方のケースで、状態空間モデル SYS は安定でなければいけません。
% グラミアンは、つぎのLyaponov方程式を解いて計算されます
%
%  *   連続時間システム dx/dt = A x + B u  ,   y = C x + D u  では、
%      A*Wc + Wc*A' + BB' = 0  と  A'*Wo + Wo*A + C'C = 0 です。
%
%  *  離散時間システム x[n+1] = A x[n] + B u[n] ,  y[n] = C x[n] + D u[n] では、
%     A*Wc*A' - Wc + BB' = 0  と  A'*Wo*A - Wo + C'C = 0 です。
%
% LTIモデル SYS の ND 配列に対して、Wc と Wo は、つぎのような N+2 の次元を
% もつ配列です。
%    Wc(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'c') .
%    Wo(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'o') .
%
% Rc = GRAM(SYS,'cf') と Ro = GRAM(SYS,'of') は、グラミアンの
% Cholesky factors を出力します(Wc = Rc'*Rc と Wo = Ro'*Ro)。
%
% 参考 : SS, BALREAL, CTRB, OBSV.


% Copyright 1986-2002 The MathWorks, Inc.
