% Partial Differential Equation Toolbox
% Version 1.0.5 (R14) 05-May-2004
%
% PDEアルゴリズム
%   adaptmesh   - アダプティブメッシュを作成しPDE問題を解きます
%   assema      - 剛性マトリックスと質量マトリックスと右辺ベクトルを組み
%               立てます
%   assemb      - 境界条件から行列とベクトルを組み立てます
%   assempde    - 剛性マトリックスと PDE 問題の右辺を組み立てます
%   hyperbolic  - 双曲型問題を解きます
%   parabolic   - 放物型問題を解きます
%   pdeeig      - 固有値 PDE 問題を解きます
%   pdenonlin   - 非線形 PDE 問題を解きます
%   poisolv     - 長方形グリッド上でのポアソン方程式の高速解法
%
% ユーザインタフェースアルゴリズムとユーティリティ
%   pdecirc     - 円の描画
%   pdeellip    - 楕円の描画
%   pdemdlcv    - MATLAB 4.2c Model M-ファイルを MATLAB 5 で使うために変換
%   pdepoly     - 多角形の描画
%   pderect     - 長方形の描画
%   pdetool     - PDE Toolbox グラフィカルユーザインタフェース(GUI)
%
% Geometryアルゴリズム
%   csgchk      - Geometry Description 行列の妥当性のチェック
%   csgdel      - 最小領域間のボーダを削除
%   decsg       - Constructive Solid Geometry を最小領域に分解
%   initmesh    - 三角形メッシュを初期化
%   jigglemesh  - 三角形メッシュの内部点をずらし、メッシュの要素数を変えず
%               に要素形状を変えます
%   pdearcl     - パラメータ表現されたものと弧の長さを補間
%   poimesh     - 長方形の形状上に等間隔のメッシュを描画
%   refinemesh  - 三角形メッシュを細分化
%   wbound      - 境界条件を設定するデータファイルを書きます
%   wgeom       - 形状を設定するデータファイルを書きます
%
% プロット関数
%   pdecont     - コンタープロットを表示するためのコマンド
%   pdegplot    - PDE 形状をプロット
%   pdemesh     - PDE 三角形メッシュをプロット
%   pdeplot     - PDE Toolbox のプロット関数
%   pdesurf     - サーフェスプロットを表示するためのコマンド
%
% ユーティリティアルゴリズム
%   dst         - 離散サイン変換
%   idst        - 逆離散サイン変換
%   pdeadgsc    - 相対許容規範を使って三角形を選択
%   pdeadworst  - 精度の悪さに関係のある三角形要素を選択
%   pdecgrad    - PDE の解のフラックス(流率)の計算
%   pdeent      - 与えた三角形集合の近傍にある三角形のインデックス
%   pdegrad     - PDE の解の勾配を計算
%   pdeintrp    - 節点データから三角形の中点のデータに補間
%   pdejmps     - アダプティブソルバのために誤差を評価
%   pdeprtni    - 三角形の中点のデータから節点のデータに補間
%   pdesde      - サブドメイン集合における境界線分のインデックス
%   pdesdp      - サブドメイン集合における節点のインデックス
%   pdesdt      - サブドメイン集合における三角形要素のインデックス
%   pdesmech    - 構造力学のテンソル関数の計算
%   pdetrg      - 三角形要素の形状のデータ
%   pdetriq     - 三角形要素の性質測定値
%   poiasma     - ポアソン方程式の高速ソルバのために境界上の節点から剛性マ
%               トリックスを組み立てます
%   poicalc     - 長方形メッシュ上でのポアソン方程式のための高速ソルバ
%   poiindex    - 長方形グリッドの正準順序における点のインデックス
%   sptarn      - 一般化スパース固有値問題を解きます
%   tri2grid    - PDE の三角形メッシュから長方形メッシュに補間します
%
% ユーザ定義アルゴリズム
%   pdebound    - Boundary M-ファイル
%   pdegeom     - Geometry M-ファイル
%
% デモ
%   pdedemo1    - 単位円板上でのポアソン方程式の解
%   pdedemo2    - ヘルムホルツ方程式の解と反射波の研究
%   pdedemo3    - 極小曲面問題
%   pdedemo4    - サブドメイン分解を使った FEM 問題の解
%   pdedemo5    - 放物型のPDEの解(熱伝導)
%   pdedemo6    - 双曲型のPDEの解(波動方程式)
%   pdedemo7    - アダプティブメッシュ解法
%   pdedemo8    - 長方形グリッド上のポアソン方程式

%   Copyright 2004 The MathWorks, Inc. 
%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2003/08/29 04:52:48 $
