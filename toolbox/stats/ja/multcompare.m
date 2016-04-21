% MULTCOMPARE   平均値あるいは他の推定量に関する多重比較検定の実行
%
% MULTCOMPAREは、(傾き、切片、平均のような)推定が有意な差をもつよう定義
% された一因子分散分析(ANOVA)またはANOCOVAの結果を用いた多重比較検定を
% 行います。
%
% COMPARISON = MULTCOMPARE(STATS) は、以下の関数のどれかから出力として
% 得られる構造体 STATS の情報を使用して多重比較検定を実行します。:
% anova1、anova2、anovan、aoctool、kruskalwallis、friedman
% 出力値 COMPARISON は、比較に対して1つの行と5つの列をもつ行列です。
% 1-2列目は、比較されている2つのサンプルのインデックスです。3-5列目は、
% 推定の下界とこれらの差に対する上界です。
%
% COMPARISON = MULTCOMPARE(STATS, 'PARAM1',val1, 'PARAM2',val2,...) は、
% 以下の名前/値の組み合わせの1つあるいはそれ以上を指定します。:
%   
%     'alpha'       100*(1-ALPHA)%の区間の信頼水準を指定します。
%                   (デフォルト 0.05).
%     'displayopt'  前後の区間を比較する推定のグラフを表示するには 'on'
%                   (デフォルト)で、グラフを省略するには 'off' のいずれかを
%                   指定します。
%     'ctype'       限界値を使用するためのタイプ。選択できるのは、
%                   'tukey-kramer'(デフォルト)、'dunn-sidak'、'bonferroni'、
%                   'scheffe' です。これらの限界値の最小を使用するために、
%                   これらの選択から2つか、それ以上をスペースで分離して
%                   入力してください。
%     'dimension'   1つの次元、または母集団周辺平均が計算される全体の
%                   次元を指定するベクトルです。STATS が anovan から生成
%                   されるときのみ使用されます。デフォルトは、1番目の
%                   次元全体を計算するため1です。例えば [1 3] の場合、
%                   最初と3番目の予測子の各結合に対する母集団周辺平均を
%                   計算します。
%     'estimate'    比較のための推定です。選択可能な値は、stats 構造体の
%                   ソースに依存します。:
%         anova1:   無視されます。グループ平均を比較します。
%         anova2:   'column' (デフォルト) または 'row' 平均
%         anovan:   無視されます。母集団周辺平均を比較します。
%         aoctool:  'slope'、'intercept'、'pmm' (separate-slopesモデルに
%                   対してデフォルトは'slope'、それ以外は'intercept'です)
%         kruskalwallis:  無視されます。列のランクの平均を比較します。
%         friedman:  無視されます。列のランクの平均を比較します。
%
%
% [COMPARISON,MEANS,H] = MULTCOMPARE(...)は、推定された量とそれらの標準
% 誤差が等価となる列をもつ行列 MEANS と、またグラフを含むfigureのハンドル 
% H も出力します。
%
% グラフ内に示される反復は、もしそれらの反復が重なる場合、有意差ではなく、
% それらの反復が交わらない場合、計算された2つの推定値は、有意差のある
% 非常に近い近似として計算されます。(これは、すべての平均が同じ標本サイズ
% に基づく場合、anova1 からの平均の多重比較検定に対して正確です)
% どの平均が有意差であるかをみるために、任意の推定値をクリックすることが
% できます。
%
% 2つの付加的な CTYPE の選択が可能です。'hsd' オプションは、"honestly 
% significant differences" を表し、'tukey-kramer' オプションと同じです。
% 'lsd' オプションは、"最小有意差(least significant difference)" を表し、
% t-検定で使用します。; これは、F検定のように、事前に全体的な検定がされて
% いない限り、多重比較問題に対して保護されません。
%
% 参考 : ANOVA1, ANOVA2, ANOVAN, AOCTOOL, FRIEDMAN, KRUSKALWALLIS.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:13:13 $
