% NLINFIT   Gauss-Newton 法を使って、非線形の最小二乗データ近似
% 
% NLINFIT(X,Y,FUN,BETA0) は、最小二乗を用いた非線形関数の係数を推定します。
% Y は、応答値(従属変数)のベクトルです。通常は、X は、Y の各値に対する
% 1つの行を使った予測子(独立変数)の計画行列です。しかしながら、X は、
% FUN に受け入れられるために準備された任意の配列です。FUN は、係数ベクトル
% と配列 X の2つの引数を受け入れて、近似された Y の値のベクトルを出力する
% 関数です。BETA0 は、係数に対する初期値を含むベクトルです。
%
% [BETA,R,J] = NLINFIT(X,Y,FUN,BETA0) は、適合係数 BETA、残差 R、ヤコビ
% アン J を出力します。ユーザは、予測の誤差推定を行うための NLPREDCI と、
% 推定された係数の誤差推定を行うための NLPARCI でこれらの出力を使用する
% ことができます。
% 
% 例題
% ----
%   FUN は、@を使って指定することができます。:
%      nlintool(x, y, @myfun, b0)
%   ここで、MYFUN は、以下のようなMATLAB関数です。:
%      function yhat = myfun(beta, x)
%      b1 = beta(1);
%      b2 = beta(2);
%      yhat = 1 ./ (1 + exp(b1 + b2*x));
%
%   FUN は、インラインオブジェクトでも構いません。:
%      fun = inline('1 ./ (1 + exp(b(1) + b(2)*x))', 'b', 'x')
%      nlintool(x, y, fun, b0)
%
% 参考 : NLPARCI, NLPREDCI, NLINTOOL.


%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:14:05 $
