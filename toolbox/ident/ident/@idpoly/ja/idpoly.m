% IDPOLY は、IDPOLY モデル構造体を作成します。
%       
%  M = IDPOLY(A,B,C,D,F,NoiseVariance,Ts)
%  M = IDPOLY(A,B,C,D,F,NoiseVariance,Ts,'Property',Value,..)
%
%  M: つぎのモデルを記述するモデル構造体オブジェクトとして出力
%
%     A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%
% 白色ノイズ源の分散は、NoiseVariance です。Ts はサンプル間隔で、Ts = 0 
% は連続時間モデルを意味します。
% 
% A,B,C,D, F は、多項式として入力されます。
%
% 離散時間モデルでは、A, C, D, F は1から始まり、一方、B には、遅れを示す
% ゼロが付加されます。多入力システムの場合、B と F は、入力数と等しい行
% 数をもつ行列です。時系列の場合、B と F は、[] として設定します。
%
% 例題：
% A = [1 -1.5 0.7], B = [0 0.5 0 0.3; 0 0 1 0], Ts = 1 は、つぎのモデル
% を定義します。
% 
%   y(t) - 1.5y(t-1) + 0.7y(t-2) = 0.5u1(t-1) + 0.3u1(t-3) + u2(t-2)
%
% 連続時間モデルに対して、多項式が、s の降ベキの順に入力されています。
% 
% 例題： 
% A = 1; B = [1 2;0 3]; C = 1; D = 1; F = [1 0;0 1]; Ts = 0 は、つぎの連
% 続時間システムに定義します。
% 
%    Y = (s+2)/s U1 + 3 U2.
%
% C, D, F, NoiseVariance, Ts 以降を省略すると、1とみなします(B = [] の場
% 合、F = []です)。
%
% M = IDPOLY は、空のオブジェクトを作成します。
%
% M = IDPOLY(SYS) は、任意の単出力 IMODEL、または、LTI オブジェクト SYS 
% 用の IDPOLY モデルを作成します。LTI モデルがInputGroup 'Noise' を含む
% 場合、白色ノイズとして取り扱うことで M のノイズモデルを計算します。
%
% IDPOLY プロパティの詳細な情報は、SET(IDPOLY) とタイプしてください。
% 
% 参考：POLYDATA 
%



%   Copyright 1986-2001 The MathWorks, Inc.
