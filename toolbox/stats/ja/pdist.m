% PDIST   観測間の距離
%
% Y = PDIST(X) は、M行N列の行列 X 内の各観測の組み合わせ間の Euclidean
% 距離を含むベクトル Y を出力します。X の行は、観測に対応し、列は変数に
% 対応します。Y は、M*(M-1)/2行1列のベクトルで、X内の観測の M*(M-1)/2組
% に対応します。
%
% Y = PDIST(X, DISTANCE) は、DISTANCE を用いて Y を計算します。以下から
% 選択可能です。:
% 
%       'euclidean'   - Euclidean距離
%       'seuclidean'  - 各座標の二乗和が座標の標本分散による重み付けの逆
%                       となる標準化Euclidean距離
%       'cityblock'   - City Block距離
%       'mahalanobis' - マハラノビス(Mahalanobis)距離
%       'minkowski'   - 指数2とするミンコフスキー(Minkowski)距離
%       'cosine'      - 1から(ベクトルとして扱われる)観測間の角度を含んだ
%                       コサインを引いた値
%       'correlation' - 1から(値の系列として扱われる)観測間の標本相関を
%                       引いた値
%       'hamming'     - 異なる座標のパーセンテージとなるHamming距離
%       'jaccard'     - 1から異なる非ゼロの座標のパーセンテージとなる
%                       Jaccard係数を引いた値
%       function      - @ を用いて指定された距離関数、例えば @DISTFUN
% 
% 距離関数は、以下の形式でなければなりません。
%
%         function D = DISTFUN(XI, XJ, P1, P2, ...),
%
% 引数として、2つのL行N列の行列 XI とXJ と、ゼロ、または付加的な問題固有の
% 引数 P1, P2, ... を取り、K番目の要素が観測 XI(K,:) と XJ(K,:) 間の距離
% となるL行1列の距離のベクトル D を出力します。
%
% Y = PDIST(X, DISTFUN, P1, P2, ...) は、関数 DISTFUN に直接引数 P1, P2, ...
% を渡します。
%
% Y = PDIST(X, 'minkowski', P) は、正のスカラの指数 P を用いてミンコフスキー
% (Minkowski)距離を計算します。
%
% 出力 Y は、例えば、フルのM行M列の距離行列の右上三角のように、
% ((1,2),(1,3),..., (1,M),(2,3),...(2,M),.....(M-1,M)) の順に配置されます。
% 観測 (I < J) のI番目とJ番目の間の距離を取得するには、Y((I-1)*(M-I/2)+J-I)
% の公式を使うか、または、(I,J) の入力が観測 I と観測 J 間の距離と等しく
% なるM行M列の正方対称行列を出力する補助関数 Z = SQUAREFORM(Y) を使うかの
% どちらかです。
%
% 例題:
%
%      X = randn(100, 5);                 % いくつかのランダム点
%      Y = pdist(X, 'euclidean');         % 重み付けされない距離
%      Wgts = [.1 .3 .3 .2 .1];           % 座標の重み付け
%      Ywgt = pdist(X, @weucldist, Wgts); % 重み付けされた距離
%
%      function d = weucldist(XI, XJ, W) % 重み付けされたeuclidean距離
%      d = sqrt((XI-XJ).^2 * W');
%
% 参考 : SQUAREFORM, LINKAGE, SILHOUETTE.


%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.6 $
