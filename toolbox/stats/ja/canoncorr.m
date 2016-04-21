% CANONCORR   正準相関分析
%
% [A,B] = CANONCORR(X,Y) は、N×P1 と N×P2 のデータ行列 X と Y に対する
% 標本正準係数を計算します。X と Y は、異なる変数(列)の数をもつことが
% できますが、観測(行)数は同じでなければなりません。A と B は、P1×D と 
% P2×D 行列で、D = min(rank(X),rank(Y)) です。A と B のj番目の列は、
% それぞれ正準係数(すなわち X と Y に対するj番目の正準変数を構築する
% 変数の線形結合)を含みます。A と B の列は、COV(U) および COV(V)(以下
% を参照)が単位行列になるようスケーリングされています。X または Y が
% フルランク以下の場合、CANONCORR は警告を与え、X または Y の独立でない
% 列に対応する A または B の行に零を返します。
%
% [A,B,R] = CANONCORR(X,Y) は、標本正準相関係数を含む 1×D のベクトル 
% R を返します。R のj番目の要素は、U と V (以下を参照)のj番目の列の間
% の相関です。
%
% [A,B,R,U,V] = CANONCORR(X,Y) は、N×D の行列 U と V に、スコアとして
% も知られる正準変数を返します。U と V は以下のように計算されます。
%
%      U = (X - repmat(mean(X),N,1))*A および
%      V = (Y - repmat(mean(Y),N,1))*B.
%
% [A,B,R,U,V,STATS] = CANONCORR(X,Y) は、K = 0:(D-1) に対して、(K+1)
% 番目から D番目の相関係数はすべて零であるとする D個の帰無仮説 H0_K に
% 関する情報を含んだ構造体を出力します。STATS は、K の値に対応する要素
% をもつそれぞれ 1×D のベクトルとなる以下の8つのフィールドを含みます。:
%
%      Wilks:    ウイルクス(Wilks)のlambda (尤度比) 統計量
%      chisq:    Lawleyの修正版を使ったH0_K に対するBartlettの近似の
%                カイ二乗統計量
%      pChisq:   CHISQ に対するright-tail有意水準
%      F:        H0_K に対するRaoの近似のF統計量
%      pF:       Fに対するright-tail有意水準
%      df1:      F統計量に対する自由度の分子と同様のカイ二乗統計量に
%                対する自由度
%      df2:      F統計量に対する自由度の分母
%
% 例題:
%
%      load carbig;
%      X = [Displacement Horsepower Weight Acceleration MPG];
%      nans = sum(isnan(X),2) > 0;
%      [A B r U V] = canoncorr(X(~nans,1:3), X(~nans,4:5));
%
%      plot(U(:,1),V(:,1),'.');
%      xlabel('0.0025*Disp + 0.020*HP - 0.000025*Wgt');
%      ylabel('-0.17*Accel + -0.092*MPG')
%
% 参考: PRINCOMP, MANOVA1.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/12/18 20:05:06 $

