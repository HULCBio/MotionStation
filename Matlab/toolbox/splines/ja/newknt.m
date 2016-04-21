% NEWKNT   新しいブレークポイントの分布
%
% [NEWKNOTS,DISTFN] = NEWKNT(F,NEWL) は、(F と同じ次数のスプラインに
% 対して)節点列 NEWKNOTS を出力します。この列は、F の高次微分に関連した
% 特定の線形単調関数(そのpp-型は DISTFN に出力されます)が等しく分布する
% ようにして、F の基本区間をNEWL個の要素に切断します。
%
% この目的は、関数 g の F におけるラフな近似が、g に関する十分な情報を
% 含むと仮定し、適切な近似に適した節点列を選ぶことです。
% 
% たとえば、
%
%      sp = spap2(augknt(linspace(X(1),X(end),M+1),K),K,X,Y);
%
% によって得られたM-1個の等間隔の内部の節点をもつK次のスプラインによって、
% 与えられたデータ X,Y の最小二乗近似を得た後で、
%
%      sp = spap2(newknt(sp),K,X,Y);
%
% によって(同じ要素の数をもつ)より適切な近似を得ることができます。
%
% 参考 : OPTKNT, APTKNT, AVEKNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
