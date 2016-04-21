% GLMFIT   一般化線形モデルのあてはめ
%
% B=GLMFIT(X,Y,DISTR) は、予測変数行列X、応答Y、分布DISTRに一般化線形
% モデルをあてはめます。出力Bは、係数推定値のベクトルです。指定可能な
% 分布は、'normal'、'binomial'、'poisson'、'gamma'、'inverse gaussian'
% です。
% 分布パラメータは、正準リンクを使ってXの列の関数としてあてはめます。
%
% B=GLMFIT(X,Y,DISTR,LINK,'ESTDISP',OFFSET,PWTS,'CONST')は、最適化に
% ついてさらにきめ細かくコントロールします。LINKは、正準リンクの代わりに
% 使われるリンク関数です。'ESTDISP'は、標準誤差の計算で二項分布または
% ポワソン分布の分散パラメータを推定するとき'on'にし、理論的な分散パラ
% メータ値を使うときは'off'にします(推定された分散は、常に他の分布に
% 使われます）。OFFSET は、1.0と固定された係数値である付加的な予測子と
% して使われるベクトルです。PWTSは、XとYの各測定値の振動となるような、
% あらかじめ与えられた重みのベクトルです。'CONST'は、定数項を推定する
% 場合、'on' (デフォルト)にし、省略する場合、'off'にしてください。定数
% 項の係数は、Bの最初の要素です。(Xの行列内に直接1つの列を入力しないで
% 下さい)
%
% LINK は、分布パラメータmuと予測子 xb の線形結合の間で f(mu) = xb と
% して定義される関数fを定義します。LINKで定義されるfは以下のいずれかと
% なります。
%    - つぎの文字列 'identity'、'log'、'logit'、'probit'、
%      'comploglog'、'reciprocal'、'logloglink'
%    - 数字P。mu = xb^P として定義されます
%    - {@FL @FD @FI}の形式のセル配列。3つの関数はリンク(FL)、リンクの
%      導関数(FD)、リンクの逆関数(FI)を定義します。
%    - リンク、導関数、逆関数リンクを定義するための3つのinline関数のセル配列
%
% [B,DEV,STATS]=GLMFIT(...) は、追加の結果を出力します。DEVは、解像度
% ベクトルの偏分です。STATSは、以下のフィールドが含まれる構造体です。
% dfe(誤差の自由度)、s(理論値または推定値の分散パラメータ)、
% sfit(推定値の分散パラメータ)、se(係数推定値bの標準誤差のベクトル)、 
% coeffcorr(bの相関行列)、t(bのｔ統計量)、p(bのp-値)、
% resid(残差のベクトル)、residp(Pearson残差のベクトル)、
% residd(偏分残差のベクトル)、resida(Anscombe残差のベクトル)
%
% 例題:
%	    b = glmfit(x, [y N], 'binomial', 'probit')
%      この例題はxのyに対するprobit回帰にあてはめます。各々のy(i)は、
%      N(i)の試行での成功数です。
%
% 参考 : GLMVAL, REGRESS.


%   Author:  Tom Lane, 2-8-2000
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:12:10 $
