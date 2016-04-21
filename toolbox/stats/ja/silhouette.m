% SILHOUETTE   クラスタデータの輪郭をプロット
%
% SILHOUETTE(X, CLUST) CLUST で定義されたクラスタごとに、N×P データ
% 行列 X に対するクラスタの輪郭をプロットします。X の行は点に対応し、
% 列は、座標に対応します。CLUST は、各点に対するクラスタのインデックスを
% 含む数値配列か、各点に対するクラスタ名を含む文字列のセル配列か文字行列
% です。SILHOUETTE は、欠損値に対しては CLUST 内に NaN か空文字列を用い、
% X の対応する行は無視されます。デフォルトでは、SILHOUETTE は、X の点間
% の Euclidean 距離の二乗を使用します。
%
% S = SILHOUETTE(X, CLUST) は、クラスタの輪郭を表示しませんが、N×1 の
% ベクトル S に輪郭値を出力します。
%
% [S,H] = SILHOUETTE(X, CLUST) は、輪郭をプロットし、輪郭値を N×1 の
% ベクトル S として、figureのハンドルを H として出力します。
%
% [...] = SILHOUETTE(X, CLUST, DISTANCE) は、DISTANCE で指定された点間
% の距離の基準を使って輪郭をプロットします。DISTANCE は以下のものから
% 選択します。:
%
%     'Euclidean'    - Euclidean 距離
%    {'sqEuclidean'} - Euclidean 距離の二乗
%     'cityblock'    - 絶対距離(別名 L1)の和
%     'cosine'       - 1から(ベクトルとして扱われた)点の間の角度の
%                      コサインを引いた値
%     'correlation'  - 1から(値の系列として扱われた)点の間の標本相関を
%                      引いた値
%     'Hamming'      - 異なる座標のパーセンテージ
%     'Jaccard'      - 異なる非ゼロの座標のパーセンテージ
%     vector         - PDIST で作成されたベクトル形式での数値的な距離
%                      行列 (X は、この場合使用されず、安全に [] を設定
%                      することが可能です)
%     function       - @DISTFUN のように、@ を用いて指定した距離関数
%
% 距離関数は以下の形式でなければなりません。
%
%       function D = DISTFUN(X0, X, P1, P2, ...),
%
% 引数として1つの 1×P 行列の点 X0 と、点 X の N×P 行列に、ゼロ以上の
% 付加的な問題固有の引数 P1,P2, ..., をとり、そして、X の各点(列)と
% X0 の間の距離の N×1 ベクトル D を出力します。
%
% [...] = SILHOUETTE(X, CLUST, DISTFUN, P1, P2, ...) は、関数 DISTFUN
% に、直接引数 P1, P2, ... を渡します。
%
% 各点に対する輪郭値は、その点が他のクラスタ内の点に比べて、自身のクラ
% スタ内の点とどれだけ相似しているかという基準で、-1から1までの値を
% とります。これは以下のように定義されます。
%
%    S(i) = (min(AVGD_BETWEEN(i,k)) - AVGD_WITHIN(i))
%                            / max(AVGD_WITHIN(i), min(AVGD_BETWEEN(i,k)))
%
% ここで、AVGD_WITHIN(i) は、i番目の点から自身のクラスタ内の他の点への
% 平均距離で、AVGD_BETWEEN(i,k) は、i番目の点から他のクラスタ k の点への
% 平均距離です。
%
% 例題:
%
%    X = [randn(10,2)+ones(10,2); randn(10,2)-ones(10,2)];
%    cidx = kmeans(X, 2, 'distance', 'sqeuclid');
%    s = silhouette(X, cidx, 'sqeuclid');
%
% 参考 : KMEANS, LINKAGE, DENDROGRAM, PDIST.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $ $Date: 2002/05/08 18:43:59 $

