% DSIGMF 2つのシグモイドメンバシップ関数間の差を使ったメンバシップ関数
% 
% 表示
%    y = dsigmf(x,[a1 c1 a2 c2])
% 
% 詳細
% ここで扱うシグモイドメンバシップ関数は、2つのパラメータ a と c に依存
% し、f(X,a,c) = 1/(1+exp(-a(x-c))) で与えられます。
% 
% メンバシップ関数 dsigmf は、4つのパラメータ a1、c1、a2 および c2 に依
% 存し、つぎのような2つのシグモイド関数の差です。
% 
%    f1(x; a1,c1) - f2(x; a2,c2)
% 
% パラメータの設定順は、[a1 c1 a2 c2] です。
% 
% 例題
%    x = 0:0.1:10;
%    y = dsigmf(x,[5 2 5 7]);
%    plot(x,y)
%    xlabel('dsigmf、P = [5 2 5 7]')
% 
% 参考    EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
