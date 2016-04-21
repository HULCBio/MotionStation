% ZSCORE   標準化された z スコア
%
% Z = ZSCORE(D) は、標準偏差で正規化された平均からの D の各列の偏差を出力
% します。これは、D の Z スコアとして知られているものです。列ベクトル V に
% 対して、Z スコアは、Z = (V-mean(V))./std(V) で表せます。
%
% ZSCORE は、クラスタ分析で距離を計算する前にデータの前処理として使います。
%
% 参考 : PDIST, CLUSTER, CLUSTERDATA.


%   ZP. You, July 22, 1998
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ 
