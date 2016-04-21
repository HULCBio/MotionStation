% MANOVACLUSTER    manova1の出力で用いられるグループ平均のクラスタ
%
% MANOVACLUSTER(STATS)は、MANOVA1からのSTATS構造体の出力とsingle linkage 
% アルゴリズムの適用により計算されたグループ平均のクラスタリングを表示
% するための樹形図を作成します。この関数からのグラフィカルな出力に関する
% 詳細は、DENDROGRAM を参照してください。
%
% MANOVACLUSTER(STATS,METHOD)は、ingle linkageの代わりに METHOD アルゴ
% リズムを使います。可能な手法は以下のとおりです。
%
%      'single'   --- 最も近い距離
%      'complete' --- 最も遠い距離
%      'average'  --- 平均距離
%      'centroid' --- 重心までの距離
%      'ward'     --- 距離の二乗和
%
% H = MANOVACLUSTER(...)は、ラインハンドルのベクトルを返します。
%
% 参考 : MANOVA1, DENDROGRAM, LINKAGE, PDIST, CLUSTER,
%        CLUSTERDATA, INCONSISTENT.


%   Tom Lane, 12-17-99
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $
