% CLUSTERDATA   データからクラスタを作成
%
% T = CLUSTERDATA(X, CUTOFF) は、データX から、クラスタを作成します。
% X は、大きさM×N の行列であり、N 個の変数に対して、M 個の観測値として
% 取り扱われます。CUTOFF は、LINKAGEにより生成される階層的なツリーを
% クラスタへカットするしきい値です。
% 0 < CUTOFF < 2 の場合、クラスタは、inconsistent値が 、CUTOFF より
% 大きい場合に作成されます (INCONSISTENT参照)。
% CUTOFF が、整数で、CUTOFF >= 2である場合、CUTOFF は、LINKAGEにより
% 作成される階層的なツリー中に保たれるクラスタの最大の数と考えられます。
% 出力 T は、各観測に対するクラスタ数を含む大きさ M のベクトルです。
%
% T = CLUSTERDATA(X,CUTOFF) は、つぎのステートメントと等価です。
%     Y = pdist(X, 'euclid');
%     Z = linkage(Y, 'single');
%     T = cluster(Z, 'cutoff', CUTOFF);
%
% T = CLUSTERDATA(X,'PARAM1',VAL1,'PARAM2',VAL2,...) は、パラメータ/値
% の組による設定法を使って、クラスタ操作に対して、よりコントロール可能
% になります。使用可能なパラメータは、つぎのようになります。:
%
%     パラメータ   値
%     'distance'   PDISTで、許可された distance metric 名のいずれか。
%                   (オプション'minkowski'には、指数 P の値を続けることが
%                    できます)。
%     'linkage'    LINKAGEで許可されるlinkage法。
%     'cutoff'     inconsistentあるいはdistance measureに対するカットオフ。
%     'maxclust'   作成するクラスタの最大の数。
%     'criterion'  'inconsistent'、あるいは、'distance' のいずれか。
%     'depth'      inconsistent値の計算のための深さ。
%   
% 参考 : PDIST, LINKAGE, INCONSISTENT, CLUSTER, KMEANS.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $
