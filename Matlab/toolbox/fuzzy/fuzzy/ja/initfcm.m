% INITFCM は、ファジィ c-means クラスタリング用の初期ファジィ分割部を作
% 成します。
% 
% U = INITFCM(CLUSTER_N, DATA_N) は、ファジィ分割行列 U をランダムに作成
% します。U の大きさは、CLUSTER_N 行 DATA_N 列です。ここで、CLUSTER_N は
% クラスタの数、DATA_N はデータ点数です。作成した U の各列の和は1になり
% これは、ファジィ c-means クラスタリングで必要とされていることです。
%
% 参考      DISTFCM, FCMDEMO, IRISFCM, STEPFCM, FCM.

