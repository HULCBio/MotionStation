% PDEX5  PDEPE 用の例題5
%
% この例題は、腫瘍に関連した腫れ物の初期の段階の数学的なモデルです。PDEs 
% はつぎのようになります。
%  
%      Dn/Dt = D(d*Dn/Dx - a*n*Dc/Dx)/Dx + s*r*n*(N - n)
%      Dc/Dt = D(Dc/Dx)/Dx + s*(n/(n+1) - c)
%
% PDEPE で期待される型で、方程式はつぎのようになります。
%
%    |1|         |n|      | d*D(n)/Dx - a*n*D(c)/Dx |    |  s*r*n*(N - n) |
%    | | .*  D_  | | = D_ |                         | +  |                |
%    |1|     Dt  |c|   Dx |        D(c)/Dx          |    | s*(n/(n+1) - c |
%
% 参考文献[1]の図 3と4 は、パラメータ値 d = 1e-3, a = 3.8, s = 3, r = 
% 0.88, N = 1 に対応したものです。 
%
% 初期条件は、0 <= x <= 1に対して、定数定常状態 n = 1, c = 0.5 の擾乱で
% す。線形安定解析は、空間的に不均質の解へのシステムの展開を予想します。
% ステップ関数は、この展開をシミュレーションするために、pde ファイル 
% PDEX5IC に初期値として設定されます。 
%
% [0,1] の両側で、2つの解のコンポーネントは流量ゼロで、そのため、左側、
% および、右側の境界はつぎのようになります。
%
%      |0|       |1|     | d*D(n)/Dx - a*n*D(c)/Dx |   |0|
%      | |   +   | | .*  |                         | = | |
%      |0|       |1|     |        D(c)/Dx          |   |0|
%
% 問題の定式化については、サブ関数 PDEX5PDE, PDEX5IC, PDEX5BC を参照して
% ください。
%
% 極限での分布を見るには、長い時間のシミュレーションが必要です。また、c
% (x,t) の極限での分布は、区間[0,1]で、たった0.1% しか変化しません。その
% ために、比較的密なメッシュで構いません。
% 
% 参考文献：
% [1] M.E. Orme and M.A.J. Chaplain, A mathematical model of the first 
%     steps of tumour-related angiogenesis: capillary sprout formation 
%     and secondary branching, IMA J. of Mathematics Applied in Medicine
%     & Biology, 13 (1996) pp. 73-98.
%
% 参考：PDEPE, @.


%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:49:14 $
