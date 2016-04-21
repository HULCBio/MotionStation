% GRAM   可制御性グラミアンと可観測性グラミアン
%
% Wc = GRAM(SYS,'c') は、状態空間モデル SYS の可制御性グラミアンを求めます。
%
% Wo = GRAM(SYS,'o') は、可観測性グラミアンを求めます。
%
% 両方のケースで、状態空間モデル SYS は安定でなければいけません。グラミアン
% は、つぎの Lyaponov 方程式を解いて計算されます
%
%  *   連続時間システム
%        dx/dt = A x + B u  ,   y = C x + D u  では、
%        A*Wc + Wc*A' + BB' = 0  と  A'*Wo + Wo*A + C'C = 0 
%    
%  *  離散時間システム   
%        x[n+1] = A x[n] + B u[n] ,  y[n] = C x[n] + D u[n]  では、
%        A*Wc*A' - Wc + BB' = 0  と  A'*Wo*A - Wo + C'C = 0 
% 
% LTI モデル SYS の ND 配列に対して、Wc と Wo は、つぎのような N+2 の
% 次元をもつ配列です。 
% 
%   Wc(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'c') .  
%   Wo(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'o') .  
%
% 参考 : SS, BALREAL, CTRB, OBSV.


%   J.N. Little 3-6-86
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:04 $
