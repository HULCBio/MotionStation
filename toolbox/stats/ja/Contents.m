% Statistics Toolbox
% Version 5.0 (R14) 05-May-2004 
%
% 分布
% パラメータ推定
%   betafit     - ベータ分布パラメータ推定
%   binofit     - 二項分布パラメータ推定
%   evfit       - 極値分布パラメータ推定
%   expfit      - 指数分布パラメータ推定
%   gamfit      - ガンマ分布パラメータ推定
%   lognfit     - 対数正規分布パラメータ推定
%   mle         - 最尤推定(MLE)法
%   nbinfit     - 負の二項分布パラメータ推定
%   normfit     - 正規分布パラメータ推定
%   poissfit    - Poisson分布パラメータ推定
%   raylfit     - Rayleighパラメータ推定
%   unifit      - 一様分布パラメータ推定
%   wblfit      - Weibull分布パラメータ推定
%
% 確率密度関数(pdf)
%   betapdf     - ベータ密度
%   binopdf     - 二項密度
%   chi2pdf     - カイ二乗密度
%   evpdf       - 極値密度
%   exppdf      - 指数密度
%   fpdf        - F 密度
%   gampdf      - ガンマ密度
%   geopdf      - 幾何密度
%   hygepdf     - 超幾何密度
%   lognpdf     - 対数正規密度
%   mvnpdf      - 多変量正規分布密度関数
%   nbinpdf     - 負二項密度
%   ncfpdf      - 非心F密度
%   nctpdf      - 非心t密度
%   ncx2pdf     - 非心カイ二乗密度
%   normpdf     - 正規(ガウス)密度
%   pdf         - 指定した分布に対する確率密度関数
%   poisspdf    - Poisson密度
%   raylpdf     - Rayleigh密度
%   tpdf        - T密度
%   unidpdf     - 離散一様密度
%   unifpdf     - 一様密度
%   wblpdf      - Weibull密度
% 
% 累積分布関数(cdf)
%   betacdf     - ベータ分布の累積分布関数
%   binocdf     - 二項分布の累積分布関数
%   cdf         - 指定した分布の累積分布関数
%   chi2cdf     - カイ二乗分布の累積分布関数
%   ecdf        - 経験累積分布関数 (Kaplan-Meier推定)
%   evcdf       - 極値分布の累積分布関数
%   expcdf      - 指数分布の累積分布関数
%   fcdf        - F分布の累積分布関数
%   gamcdf      - ガンマ分布の累積分布関数
%   geocdf      - 幾何分布の累積分布関数
%   hygecdf     - 超幾何分布の累積分布関数
%   logncdf     - 対数正規分布の累積分布関数
%   nbincdf     - 負二項分布の累積分布関数
%   ncfcdf      - 非心F分布の累積分布関数
%   nctcdf      - 非心t分布の累積分布関数
%   ncx2cdf     - 非心カイ二乗分布の累積分布関数
%   normcdf     - 正規(ガウス)分布の累積分布関数
%   poisscdf    - Poisson分布の累積分布関数
%   raylcdf     - Rayleigh分布の累積分布関数
%   tcdf        - T分布の累積分布関数
%   unidcdf     - 離散一様分布の累積分布関数
%   unifcdf     - 一様分布の累積分布関数
%   wblcdf      - Weibull分布の累積分布関数
% 
% 分布関数の臨界値
%   betainv     - ベータ分布の逆累積分布関数
%   binoinv     - 二項分布の逆累積分布関数
%   chi2inv     - カイ二乗分布の逆累積分布関数
%   evinv       - 極値分布の逆累積分布関数
%   expinv      - 指数分布の逆累積分布関数
%   finv        - F分布の逆累積分布関数
%   gaminv      - ガンマ分布の逆累積分布関数
%   geoinv      - 幾何分布の逆累積分布関数
%   hygeinv     - 超幾何分布の逆累積分布関数
%   icdf        - 指定した分布の逆累積分布関数
%   logninv     - 対数正規分布の逆累積分布関数
%   nbininv     - 負二項分布の逆累積分布関数
%   ncfinv      - 非心F分布の逆累積分布関数
%   nctinv      - 非心t分布の逆累積分布関数
%   ncx2inv     - 非心カイ二乗分布の逆累積分布関数
%   norminv     - 正規(ガウス)分布の逆累積分布関数
%   poissinv    - Poisson分布の逆累積分布関数
%   raylinv     - Rayleigh分布の逆累積分布関数
%   tinv        - T分布の逆累積分布関数
%   unidinv     - 離散一様分布の逆累積分布関数
%   unifinv     - 一様分布の逆累積分布関数
%   wblinv      - Weibull分布の逆累積分布関数
%
% 乱数の発生
%   betarnd     - ベータ分布する乱数
%   binornd     - 二項分布する乱数
%   chi2rnd     - カイ二乗分布する乱数
%   evrnd       - 極値分布する乱数
%   exprnd      - 指数分布する乱数
%   frnd        - F分布する乱数
%   gamrnd      - ガンマ分布する乱数
%   geornd      - 幾何分布する乱数
%   hygernd     - 超幾何分布する乱数
%   iwishrnd    - Wishart乱数逆行列
%   lognrnd     - 対数正規分布する乱数
%   mvnrnd      - 多変量による正規分布する乱数
%   mvtrnd      - 多変量t分布する乱数
%   nbinrnd     - 負二項分布する乱数
%   ncfrnd      - 非心F分布する乱数
%   nctrnd      - 非心t分布する乱数
%   ncx2rnd     - 非心カイ二乗分布する乱数
%   normrnd     - 正規(ガウス)分布する乱数
%   poissrnd    - Poisson分布する乱数
%   random      - 指定した分布をする乱数
%   raylrnd     - Rayleigh分布する乱数
%   trnd        - T分布する乱数
%   unidrnd     - 離散一様分布する乱数
%   unifrnd     - 一様分布する乱数
%   wblrnd      - Weibull分布する乱数
%   wishrnd     - Wishart乱数行列
% 
% 統計量
%   betastat    - ベータ分布の平均値と分散
%   binostat    - 二項分布の平均値と分散
%   chi2stat    - カイ二乗分布の平均値と分散
%   evstat      - 極値分布の平均値と分散
%   expstat     - 指数分布の平均値と分散
%   fstat       - F分布の平均値と分散
%   gamstat     - ガンマ分布の平均値と分散
%   geostat     - 幾何分布の平均値と分散
%   hygestat    - 超幾何分布の平均値と分散
%   lognstat    - 対数正規分布の平均値と分散
%   nbinstat    - 負の二項分布の平均値と分散
%   ncfstat     - 非心F分布の平均値と分散
%   nctstat     - 非心t分布の平均値と分散
%   ncx2stat    - 非心カイ二乗分布の平均値と分散
%   normstat    - 正規(ガウス)分布の平均値と分散
%   poisstat    - Poisson分布の平均値と分散
%   raylstat    - Rayleigh分布の平均値と分散
%   tstat       - T分布の平均値と分散
%   unidstat    - 離散一様分布の平均値と分散
%   unifstat    - 一様分布の平均値と分散
%   wblstat     - Weibull分布の平均値と分散
%
%  尤度関数
%   betalike    - ベータ対数尤度関数の負の値
%   evlike      - 極値対数尤度関数の負の値
%   explike     - 指数対数尤度関数の負の値
%   gamlike     - ガンマ対数尤度関数の負の値
%   lognlike    - 対数正規対数尤度関数の負の値
%   nbinlike    - 負の二項対数尤度関数の負の値
%   normlike    - 正規対数尤度関数の負の値
%   wbllike     - Weibull対数尤度関数の負の値
%
% 記述的統計量
%   bootstrp    - 任意関数に対するブートストラップ統計量
%   corrcoef    - 相関係数
%   cov         - 共分散
%   crosstab    - 2つのベクトルのクロス表
%   geomean     - 幾何平均
%   grpstats    - グループ毎の統計量
%   harmmean    - 調和平均
%   iqr         - 標本の四分位レンジ
%   kurtosis    - 標本尖度
%   mad         - データ標本の平均絶対偏差
%   mean        - サンプル平均(matlab toolboxで使用)
%   median      - ベクトルや行列の中央値
%   moment      - あるサンプルのモーメント
%   nanmax      - NaNs を無視した最大値
%   nanmean     - NaNs を無視した平均値
%   nanmedian   - NaNs を無視した中央値
%   nanmin      - NaNs を無視した最小値
%   nanstd      - NaNs を無視した標準偏差
%   nansum      - NaNs を無視した和
%   prctile     - 標本の百分位数
%   range       - レンジ
%   skewness    - 標本歪度
%   std         - 標準偏差(matlab toolbox)
%   tabulate    - 頻度表
%   trimmean    - 異常値を除去したデータ標本の平均
%   var         - 分散(matlab toolbox)
% 
% 線形モデル
%   addedvarplot - ステップワイズ回帰のための追加された変数プロットの作成
%   anova1      - 一因子分散分析
%   anova2      - 二因子分散分析
%   anovan      - n-因子分散分析
%   aoctool     - 共分散の解析のための対話形式のツール
%   dummyvar    - 0と1のダミー変数行列
%   friedman    - Friedman検定(ノンパラメトリック二因子分散分析anova)
%   glmfit      - 一般化線形モデルのフィッティング
%   glmval      - 一般化線形モデルの予測値の計算
%   kruskalwallis - Kruskal-Wallis検定(ノンパラメトリック一因子分散分析anova)
%   leverage    - 回帰診断
%   lscov       - 既知の分散行列を使った最小二乗推定
%   manova1     - 一因子分散多変量解析
%   manovacluster - manova1に対するグループ平均のクラスタの図示
%   multcompare - 平均値、他の推定値の多重比較検定
%   polyconf    - 多項式計算と信頼区間の算出
%   polyfit     - 最小二乗法を使った多項式近似
%   polyval     - 多項式関数を使った予測値
%   rcoplot     - ケース毎の残差表示
%   regress     - 多変量線形回帰
%   regstats    - 回帰診断を示すグラフィカルユーザインタフェース
%   ridge       - リッジ回帰のパラメータ推定
%   robustfit   - ロバスト回帰モデルフィッテング
%   rstool      - 多次元応答曲面の応答の可視化ツール(RSM)
%   stepwise    - ステップワイズ回帰の対話型ツール
%   stepwisefit - 対話型ではないステップワイズ回帰
%   x2fx        - 設定された行列を計画行列の要因に変換
%
% 非線形モデル
%   lsqnonneg   - 非負の最小二乗
%   nlinfit     - Newton法を使った非線形最小二乗法によるデータフィッティング
%   nlintool    - 非線形モデルの予測に対する会話型グラフィックスツール
%   nlpredci    - 予測に対する信頼区間
%   nlparci     - パラメータに対する信頼区間
%
% 実験計画法(DOE)
%   bbdesign    - Box-Behnken計画
%   candexch    - D-最適計画(候補集合に対する行交換アルゴリズム)。
%   candgen     - D-最適化計画作成のための候補集合
%   ccdesign    - 中心複合計画
%   cordexch    - D-最適計画法(座標交換アルゴリイズム)
%   daugment    - 拡大 D-最適計画法
%   dcovary     - 共分散を固定した D-最適計画法
%   ff2n        - 2レベルの完全実施計画
%   fracfact    - 2レベル一部実施計画
%   fullfact    - 混合レベルの完全実施計画
%   hadamard    - Hadmard行列(直交配列)
%   lhsdesign   - ラテン超方格(latin hypercube)の標本を作成
%   lhsnorm     - 多変量正規分布をもつラテン超方格(latin hypercube)標本
%   rowexch     - D-最適計画法(行交換アルゴリズム)
%
% 統計的工程管理(SPC)
%   capable     - 工程能力指数
%   capaplot    - 工程能力プロット
%   ewmaplot    - 指数的重み付けをした移動平均プロット
%   histfit     - ヒストグラムと正規密度曲線
%   normspec    - 設定した範囲間での正規分布密度のプロット
%   schart      - 統計的工程管理のための標準偏差の管理図
%   xbarplot    - 平均値をモニタするXbar図
%
% 多変量統計量
% クラスタ分析
%   cophenet    - Cophenetic相関係数を算出
%   cluster     - LINKAGE出力からのクラスタの作成
%   clusterdata - データからクラスタの作成
%   dendrogram  - 樹状図の作成
%   inconsistent- クラスタツリーの整合性のない値
%   kmeans      - K平均クラスタリング
%   linkage     - 階層的なクラスタの情報の取得
%   pdist       - 観測間の距離の算出
%   silhouette  - クラスタデータの輪郭をプロット
%   squareform  - 正方行列書式で距離を表現
%
% 次元削減手法
%   factoran    - 因子分析
%   pcacov      - 共分散行列による主成分分析
%   pcares      - 主成分分析からの残差
%   princomp    - 実データ行列による主成分分析
%
% 他の多変量手法
%   barttest    - 次元に関するBartlett検定
%   canoncorr   - 正準相関分析
%   cmdscale    - 古典的多次元尺度構成法
%   classify    - 線形判別分析
%   mahal       - Mahalanobisの距離
%   manova1     - 一因子分散多変量解析
%   procrustes  - Procrustes解析
%
% 決定木手法
%   treedisp    - 決定木の表示
%   treefit     - 分類または回帰ツリーを用いたデータの近似
%   treeprune   - 決定木の枝刈りおよび最適な枝刈りされた列の作成
%   treetest    - 決定木に対する推定誤差
%   treeval     - 決定木を用いた近似値の計算
%
% 仮説検定
%   ranksum     - ウィルコクソン(Wilcoxon)の順位和検定(独立な標本)
%   signrank    - ウィルコクソン(Wilcoxon)符号つき順位和検定(対標本)
%   signtest    - 符号つき検定(対標本)
%   ztest       - Z検定
%   ttest       - 1標本t検定
%   ttest2      - 2標本t検定
%
% 分布テスト
%   jbtest      - 正規性のJarque-Bera検定
%   kstest      - 1標本に対するKolmogorov-Smirnov検定
%   kstest2     - 2標本に対するKolmogorov-Smirnov検定
%   lillietest  - 正規性のLilliefors検定
%
% ノンパラメトリック関数
%   friedman    - Friedman検定(ノンパラメトリックニ因子分散分析)
%   kruskalwallis - Kruskal-Wallis検定(ノンパラメトリック一因子分散分析)
%   ksdensity   - Kernel 平滑化密度の推定
%   ranksum     - ウィルコクソン(Wilcoxon)の順位和検定(独立な標本)
%   signrank    - ウィルコクソン(Wilcoxon)符号つき順位和検定(対標本)
%   signtest    - 符号つき検定(対標本)
%
% 隠れマルコフモデル(Hidden Markov Model)
%   hmmdecode   - HMMの後方の状態確率を計算
%   hmmestimate - 状態情報を与えられたHMMパラメータ推定
%   hmmgenerate - HMMに対するランダムな系列の生成
%   hmmtrain    - HMMパラメータに対する最尤推定値の計算
%   hmmviterbi  - HMMの系列に対して最も起こりうる状態パスを計算
%
% 統計特有のプロット関数
%   boxplot     - データ行列のボックスプロット(列単位)
%   cdfplot     - 経験的な累積分布関数のプロット
%   ecdfhist    - 経験的累積分布関数から計算されたヒストグラム
%   fsurfht     - ある関数の会話型によるコンタープロット
%   gline       - 図の中に対話形式で直線を描写
%   gname       - 会話型で点のラベル表示
%   gplotmatrix - 共通変数を使ってグループ化された散布図プロットの行列
%   gscatter    - グループ化された変数の散布図を作成
%   lsline      - 散布図に最小二乗近似直線を重ね表示
%   normplot    - 正規確率分布のプロット
%   qqplot      - 四分位プロット
%   refcurve    - 基準多項式のプロット
%   refline     - 基準ライン
%   surfht      - データグリッドの会話型コンタープロット
%   wblplot     - Weibull確率のプロット
% 
% 提供されているデモンストレーションファイル
%   aoctool     - 共分散の解析に対する対話形式のツール
%   disttool    - 確率分布関数を調べるGUIツール
%   glmdemo     - 一般化線形モデルのスライドショー
%   polytool    - 近似多項式の予測に関する会話型のグラフィックスツール
%   randtool    - 乱数発生用のGUIツール
%   rsmdemo     - 実験計画と曲線近似のデモンストレーション
%   robustdemo  - ロバスト回帰と最小二乗フィッティングを比較する対話形式の
%                 ツール
%
% ファイルの I/O 関連
%   tblread     - ファイルシステムから表にしたデータを取り込む
%   tblwrite    - ファイルシステムに表にしたデータを書き込む
%   tdfread     - タブで区切られたファイルから数値およびテキストの読み込み
%   caseread    - ファイルからケース名を読み込む
%   casewrite   - ファイルにケース名を書き込む
%
% ユーティリティ関数
%   combnk      - n オブジェクトの k 個を同時に取り出すすべての組み合わせ
%   grp2idx     - グループ化変数をインデックスと名前の配列に変換
%   hougen      - Hougenモデル(非線形の例題)に対する予測関数
%   tiedrank    - 同順位に対して調整された標本のランクを計算
%   zscore      - 各列が平均値0、分散1の列となる標準化行列


% Copyright 1993-2004 The MathWorks, Inc. 
% Generated from Contents.m_template revision 1.7  $Date: 2003/02/12 17:07:05 $
