% INCONSISTENT   クラスタツリーの Inconsistent 値
%
% T = INCONSISTENT(Z) は、Z で与えられるクラスタツリーの Inconsiistent 値
% を計算します。Z は、関数 LINKAGE から作成される(M-1)行3列の行列です。
% 
% T = INCONSISTENT(Z, DEPTH) は、DEPTH と等価な深さをもつツリーの 
% Inconsistent 値を計算します。
% 
% 出力 Y は、(M-1) 行4列の行列です。S は、ノード i からスタートし、
% DEPTH の深さまでの簡略化されたサブツリーと仮定すると、つぎのように
% なります。
% 
%       Y(i,1) = S の中のノード間の平均距離
%       Y(i,2) = S の中のノード間の距離の標準偏差
%       Y(i,3) = S の中のノードの数
%       Y(i,4) = (ノード i の距離 - Y(i,1))/Y(i,2)
% 
% DEPTH が設定されていない場合、デフォルト値は2です。
% 
% 参考 : PDIST, LINKAGE, COPHENET, DENDROGRAM, CLUSTER, CLUSTERDATA


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $
