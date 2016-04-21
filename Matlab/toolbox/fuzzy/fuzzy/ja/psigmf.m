% PSIGMF 2つのシグモイドメンバシップ関数の積
% PSIGMF(X,PARAMs) は、X で計算される2つのシグモイド関数の積である行列 
% Y を出力します。PARAMS は、このメンバシップ関数の型と位置を決定する4要
% 素ベクトルです。特に、つぎのように X と PARAMS を SIGMF へ渡します。
%
%    PSIGMF(X,PARAMS) = SIGMF(X,PARAMS(1:2)).*SIGMF(X,PARAMS(3:4));
%
% 例題
%    x = (0:0.2:10)';
%    params1 = [2 3];
%    y1 = sigmf(x,params1);
%    params2 = [-5 8];
%    y2 = sigmf(x,params2);
%    y3 = psigmf(x,[params1 params2]);
%    subplot(211);
%    plot(x,y1,x,y2); title('sigmf');
%    subplot(212);
%    plot(x,y3,'g-',x,y3,'o'); title('psigmf');
%    set(gcf,'name','psigmf','numbertitle','off');
% 
% 参考   DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%        SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
