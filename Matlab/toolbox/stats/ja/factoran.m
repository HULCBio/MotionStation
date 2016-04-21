% FACTORAN   最尤度を利用した因子分析
%
% LAMBDA = FACTORAN(X, M) は、M 個の共通因子が存在する仮説のもとで、
% 因子荷重行列の推定を出力します。入力行列 X は、D 個の変数 (列) に
% ついての N個の観測 (行)から構成されます。最尤度推定が成功するため
% には、X の変数は、線形独立、即ち、COV(X) がフルランクである必要が
% あります。D×M 出力行列 LAMBDA の(i,j)番目の要素は、i番目の変数の
% j番目の因子の係数、あるいは、荷重です。デフォルトでは、推定され
% た因子荷重を、varimax 基準(下記参照)を使用して回転します。
%
% [LAMBDA, PSI] = FACTORAN(X, M) は、D行1列のベクトル PSI に指定した
% 分散の最尤度推定を出力します。
%
% [LAMBDA, PSI, T] = FACTORAN(X, M) は、LAMBDA を回転するために使われる
% M行M列の回転行列 T を出力します。
%
% [LAMBDA, PSI, T, STATS] = FACTORAN(X, M) は、共通因子の数が M である
% という帰無仮説に関連する情報を含む構造体を出力します。STATS は、つぎの
% フィールドから構成されます。
%
%      loglike - 対数尤度を最大にする値
%          dfe - 自由度の誤差度合 == ((D-M)^2 - (D+M))/2
%        chisq - 帰無仮説に対するカイ二乗統計近似
%            p - 帰無仮説に対するright-tail有意水準
%
% FACTORAN は、STATS.dfe が正で、PSI に指定する分散の推定がすべて正で
% ない場合、STATS.chisq と STATS.p を出力しません。
% FACTORAN は、X が共分散行列で、ユーザが最適な 'Nobs' パラメータ(以下
% 参照)を使用しない場合、STATS.chisq と STATS.p を出力しません。
%
% [LAMBDA, PSI, T, STATS, F] = FACTORAN(X, M) は、更に因子スコアとしても
% 知られるN行M列の行列 F の共通因子の予測を出力します。F の行は予測に
% 対応し、列は因子に対応します。FACTORAN は、X が共分散行列だと F を
% 計算することができません。FACTORAN は、LAMBDA に関しては同じ基準を
% 用いて F を回転します。
%
% [ ... ] = FACTORAN(..., 'PARAM1',val1, 'PARAM2',val2, ...) は、入力を
% 定義するために、オプションパラメータ名/組の組み合わせを指定し、モデル
% に当てはめるのに使われた数値的な最適化をコントロールし、出力の詳細を
% 指定することができます。使用可能なパラメータは、つぎのようになります。:
%
%      'Xtype'     - X の入力タイプ [ {'data'} | 'covariance' ]
%      'Start'     - 最適化において PSI に対する出発点の選択手法。以下
%                    から選択できます:
%                            'random' - 離散一様分布(0,1) 値を選択します。
%                        {'Rsquared'} - スケール因子とDIAG(INV(CORRCOEF(X)))
%                                       の積として、出発点のベクトルを選択
%                                       します。
%                    positive integer - 'random' を使用してそれぞれの
%                                       初期化を実行するための最適化の数
%                              matrix - 明白な開始点であるD行R列の行列。
%                                       各列は1つの開始ベクトルで、FACTORAN
%                                       は、R の最適化を実行します。
%      'Delta'     - 最尤最適化の間、指定した分散PSIに対する下界
%                    [ 0 <= 正のスカラ < 1 | {0.005} ]
%      'OptimOpts' - STATSET により生成される最尤最適化のためのオプション。
%                    パラメータ名とデフォルト値については、
%                    STATSET('factoran') を参照してください。
%      'Nobs'      - X が共分散行列のとき、X の推定に使用された観測数
%                    [ positive integer ]
%      'Scores'    - F を予測するのに使用される手法
%                    [ {'wls'} | 'Bartlett' | 'regression' | 'Thomson' ]
%      'Rotate'    - 因子荷重とスコアを回転するために使用される手法
%                    [ 'none' | {'varimax'} | 'orthomax' | 'procrustes'
%                    | 'promax' | function ]
%
% 回転関数は、例えば、@ROTATEFUN のように、@ を使用して指定することが
% でき、以下のような形式でなければなりません。
%
%         function [B, T] = ROTATEFUN(A, P1, P2, ...),
%
% ここでは、回転しない因子荷重のD行M列の行列 A を引数として取り、ゼロ、
% あるいは更に付加的な問題に依存する引数 P1, P2, ..., を加え、回転因子
% 荷重のD行M列の行列 B と対応するD行D列の回転行列Tを出力します。
%
% [ ... ] = FACTORAN(..., 'Rotate', ROTATEFUN, 'UserArgs', P1, P2, ...)
% は、関数 ROTATEFUN に直接引数 P1, P2, ... を渡します。
%
% 'Rotate' が 'varimax', 'orthomax' の場合、付加的なパラメータは以下の
% ようになります。:
%   
%      'Normalize'   - 回転の間に荷重行列の列を正規化するかどうかを
%                      示すフラグ  [ {'on'} | 'off' ]
%      'RelTol'      - 相対的な収束の許容度
%                      [ 正のスカラ | {sqrt(eps)} ]
%      'Maxit'       - 繰り返し制限 [ 正の整数 | {250} ]
%      'CoeffOM'     - varimax に対して無視されますが、特定の orthomax 基準
%                      を定義する係数 [ 0 <= スカラ <= 1 | {1} ]
%
% Rotate' が 'promax' の場合、ユーザは promax によって内部で使用される
% orthomax 回転をコントロールするために上記4つのパラメータを使用する
% ことができます。'promax' に対する付加的なパラメータは、以下の通りです。
%
%      'PowerPM'     - 作成された promax ターゲット行列に対する指数
%                      [ スカラ >= 1 | {4} ]
%
% 'Rotate' が 'procrustes' の場合、付加的なパラメータは以下の通りです。:
%
%      'TargetProcr' - ターゲット因子荷重(必須) [ D-by-M 行列 ]
%      'TypeProcr'   - 回転のタイプ [ {'oblique'} | 'orthogonal' ]
%
% 例題:
%
%      load carbig;
%      X = [Acceleration Displacement Horsepower MPG Weight]; 
%      X = X(all(~isnan(X),2),:);
%      [Lambda, Psi, T, stats, F] = factoran(X, 2, 'scores', 'regr')
%
%      % 推定された共分散から計算されますが、同じ推定です。
%      [Lambda, Psi, T] = factoran(cov(X), 2, 'Xtype', 'cov')
%
%      % promax 回転を使用します。
%      [Lambda, Psi, T] = factoran(X, 2, 'rotate','promax', 'power',2)
%
%      % 回転関数を引数として渡します。
%      [Lambda Psi T] = ...
%           factoran(X, 2, 'rotate', @myrotation, 'userargs', 1, 'two')
%
% 参考 : OPTIMSET, PROCRUSTES, PRINCOMP, PCACOV.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2003/04/21 19:42:37 $
