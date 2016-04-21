% ORBITODE   ORBITDEMで使用される制約付き3体問題
% 
% これは、下記の文献の246ページで、ShampineとGordonにより記述された、ノ
% ンスティッフなソルバに対する標準のテスト問題です。最初の2つの解の成分
% は、無限小の質量の物体の座標なので、1つの解をもう1つの解に対してプロッ
% トすることは、他の2つの物体の周りの軌道を与えます。初期条件は、軌道を
% 周期的にするように選択されます。軌道の定量的な挙動の再生成のためには、
% 適度に厳しい許容範囲が必要です。RelTolの適正な値は1e-5で、AbsTolの適正
% な値は1e-4です。
% 
% ORBITODE 自身では、ゼロクロッシングの方向を設定する機能の限界の位置を
% 求めるデモを実行します。初期の点と最長距離を示す点に戻す2点は共に同じ
% イベント関数値をもち、クロシングの方向を使って、それらを区別します。
%
% 3番目の物体の軌道は、出力関数 ODEPHAS2 を使って、プロットできます。
%   
% L. F. Shampine and M. K. Gordon, Computer Solution of Ordinary
% Differential Equations, W.H. Freeman & Co., 1975.
%   
% 参考：ODE45, ODE23, ODE113, ODESET, ODEPHAS2, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-23-94, 4-19-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:49:09 $
