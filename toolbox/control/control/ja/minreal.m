% MINREAL   最小実現と極零の除去
%
%
% MSYS = MINREAL(SYS) は、LTI モデル SYS に対して、すべてをキャンセルする
% 極/零点の組、または、非最小状態ダイナミクスのどちらかを除去したものと
% 等価なモデル MSYS を作成します。状態空間モデルに対して、MINREAL は、
% すべての不可制御モードまたは不可観測モードを削除することにより、SYS の
% 最小実現 MSYS を求めます。
%
% MSYS = MINREAL(SYS,TOL) は、極/零点を除去したり、状態ダイナミクスを削除
% するときに利用する許容値 TOL も設定します。デフォルト値は、TOL = SQRT(EPS) 
% で、この許容値を大きくすることにより、さらに多くの除去を実行します。
%
% 状態空間モデル SYS = SS(A,B,C,D) に対して、 
%   [MSYS,U] = MINREAL(SYS) 
% は、(U*A*U',U*B,C*U') が (A,B,C) の Kalman 分解となる直交行列 U も出力
% します。
%
% 参考 : SMINREAL, BALREAL, MODRED.


% Copyright 1986-2002 The MathWorks, Inc.
