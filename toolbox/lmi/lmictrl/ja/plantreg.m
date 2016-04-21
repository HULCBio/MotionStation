% [Preg,gbest,x1,x2,y1,y2]=plantreg(P,r,gama,x1,x2,y1,y2,sing12,sing21)
%
% 関数HINFRICで利用。ユーザはこの関数を直接利用しません。
%
% D12かD21がランク落ちするプラントP(s)の正規化を行います。
%
% eps正規化が数値的安定性とコントローラパラメータの大きさとの間で最適化
% されます。
% GAMAは、数値的信頼性のために必要とされるとき、GBESTに増加されます。
%
% 入力:
%   P             パックされた形式でのプラントの状態空間表現
%   R             D22のサイズ   (R = [ 出力数 , 制御入力数 ])
%   GAMA          要求されるHinf性能
%   X1,X2,Y1,Y2   関数GOPTRICの出力
%   SING12        D12がランク落ちするとき、SING12 > 0
%   SING21        D21がランク落ちするとき、SING21 > 0
%
% 出力:
%   PREG          正規化されたプラント (パックされた形式)
%   GBEST         正規化後の[GAMA, +Inf]間での達成可能な最適性能
%   X1,X2,Y1,Y2   gamma = GBESTに対する2つのHinfRiccati方程式の安定化解
%　　　　　　　　 X = X2/X1とY = Y2/Y1。
%
% 参考：    HINFRIC.

% Copyright 1995-2001 The MathWorks, Inc. 
