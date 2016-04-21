% BALSQ 平方根による平衡化打ち切り (安定プラント)
%
% [SS_Q,AUG,SVH,SLBIG,SRBIG] = BALSQ(SS_,MRTYPE,NO)、または、
% [AQ,BQ,CQ,DQ,AUG,SVH,SLBIG,SRBIG] = BALSQ(A,B,C,D,MRTYPE,NO) は、
% つぎの関係を満足するグラミアンの積PQの平方根に基づいて、
% G(s):=(a,b,c,d)の平衡化打ち切りによるモデルの低次元化を実現します。
%
% 誤差(Ghed(s) - G(s))の無限大ノルム <= 2(n-k)最小ハンケル特異値(SVH)の
% 和
%
%           (aq,bq,cq,dq) = (slbig'*a*srbig,slbig'*b,c*srbig,d)
%
% "MRTYPE"の選択により、つぎのオプションがあります。
%
% 1). MRTYPE = 1  --- "NO"で定義した次数の低次元モデルを算出。
% 2). MRTYPE = 2  --- トータルの誤差が"NO"より小さくなるk次のモデルを算
%                     出。
% 3). MRTYPE = 3  --- ハンケル特異値を表示し、次数"k"の入力を促します。
%
% AUG = [削除された状態の数 , 誤差範囲] , SVH = ハンケル特異値

% Copyright 1988-2002 The MathWorks, Inc. 
