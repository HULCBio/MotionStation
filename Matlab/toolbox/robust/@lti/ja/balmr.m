% BALMR 平方根による平衡化打ち切り (不安定プラント)
%
% [SS_M,TOTBND,HSV] = BALMR(SS_,MRTYPE,NO) または、
% [AM,BM,CM,DM,TOTBND,HSV] = BALMR(A,B,C,D,MRTYPE,NO) は、つぎの関係を満
% 足するグラミアンの積PQの平方根に基づいて、G(s):=(a,b,c,d)の平衡化打ち
% 切りによるモデルの低次元化を実現します。
%
% 誤差(Ghed(s) - G(s))の無限大ノルム <= 
%                      2(n-k)最小ハンケル特異値(SVH)の和
%
% 不安定なG(s)に対して、アルゴリズムは、まず安定部と不安定部にG(s)を分割
% します。
%
% "MRTYPE"の選択により、つぎのオプションがあります。
%
% 1). MRTYPE = 1  --- "NO"で定義した次数の低次元モデルを算出。
% 2). MRTYPE = 2  --- トータルの誤差が"NO"より小さくなるk次のモデルを算
%                     出。
% 3). MRTYPE = 3  --- 全てのハンケル特異値を表示し、次数"k"の入力を促し
%                     ます。
%
% TOTBND = 誤差範囲 , HSV = ハンケル特異値



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
