% POLYVAL   多項式の計算
% 
% Y = POLYVAL(P,X)は、Pが長さN+1のベクトルで、多項式の係数を要素にもつ
% とき、X で計算された多項式の値です。
%
%     Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)
%
% X が行列またはベクトルの場合は、多項式は、X のすべての点で計算されます。
% 行列についての計算は、POLYVALM を参照してください。
%
% Y = POLYVAL(P,X,[],MU) は、X の代わりに、XHAT = (X-MU(1))/MU(2) を使い
% ます。中心とスケーリングに関するパラメータ MU は、POLYFIT で計算される
% オプションの出力です。
%
% [Y,DELTA] = POLYVAL(P,X,S) または [Y,DELTA] = POLYVAL(P,X,S,MU) は、
% エラー推定 Y +/- delta を作成するために、POLYFIT で与えられるオプション
% 出力構造体 S を使います。POLYFIT へのデータ入力でのエラーが定数の
% 分散と独立な正規分布する場合は、Y +/- DELTA は、少なくとも予測の50%を
% 含みます。
%
% 入力 P,X,S,MU のサポートクラス
%      float: double, single
%
% 参考 POLYFIT, POLYVALM.

%   Copyright 1984-2004 The MathWorks, Inc.
