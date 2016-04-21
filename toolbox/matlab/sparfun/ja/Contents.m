% スパース行列
%
% 基本的なスパース行列
% speye       - スパース単位行列
% sprand      - スパース一様分布乱数行列
% sprandn     - スパース正規分布乱数行列
% sprandsym   - スパース乱数対称行列
% spdiags     - 対角行列から作成されるスパース行列
% 
% フル行列からスパース行列への変換
% sparse      - スパース行列の作成
% full        - スパース行列をフル行列に変換
% find        - 非ゼロ要素のインデックスを求める
% spconvert   - スパース行列の外部書式から行列を取り込む
%
% スパース行列の操作
% nnz         - 行列の非ゼロ要素の数
% nonzeros    - 行列の非ゼロ要素
% nzmax       - 行列の非ゼロ要素に対して割り当てられるストレージ量
% spones      - スパース行列の非ゼロ要素を1で置き換える
% spalloc     - スパース行列に対するメモリの割り当て
% issparse    - スパース行列の検出
% spfun       - 行列の非ゼロ要素に関数を適用
% spy         - スパースパターンの構造表示
%
% 並べ替えのアルゴリズム
% colamd      - 列近似最小度合い置換
% symamd      - 対称近似最小度合い置換
% colmmd      - スパース列の最小度合いでの置換
% symmmd      - スパース対称最小度合いでの並べ替え
% symrcm      - 対称逆Cuthill-McKee置換
% colperm     - 非ゼロ要素数によるスパース列の置換
% randperm    - ランダム置換
% dmperm      - Dulmage-Mendelsohn置換
%
% 線形代数
% eigs        - ARPACKを使った固有値の計算
% svds        - eigsを使った特異値の計算
% luinc       - 不完全LU分解
% cholinc     - 不完全Cholesky分解
% normest     - 行列の2-ノルム
% condest     - 1-ノルム行列条件数の推定
% sprank      - 構造的ランク
%
% 線形方程式(繰り返し手法)
% pcg         - 前提条件付き共役傾斜法
% bicg        - 双共役傾斜法
% bicgstab    - 双共役傾斜安定化法
% cgs         - 共役傾斜二乗法
% gmres       - 一般化最小残差法
% lsqr        - 正規方程式での共役傾斜法
% minres      - 最小残差法
% qmr         - 準最小残差法
% symmlq      - 対称LQ法
%
% グラフの操作(ツリー)
% treelayout  - ツリーまたはフォレストのレイアウト
% treeplot    - ツリーのプロット
% etree       - ツリーの消去
% etreeplot   - ツリーのプロット
% gplot       - グラフ理論で描かれるグラフのプロット
%
% その他
% symbfact    - シンボリックな分解の解析
% spparms     - スパース行列のルーチンに対するパラメータの設定
% spaugment   - 最小二乗拡大システムの作成


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:25 $
