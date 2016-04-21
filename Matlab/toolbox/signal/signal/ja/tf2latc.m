% TF2LATC 伝達関数をラティスフィルタに変換
% K = TF2LATC(NUM)は、NUM(1)で正規化されたFIR(MA)ラティスフィルタ
% に対するラティスパラメータKを求めます。FIRフィルタのゼロが単位円上に
% ある場合には、誤差が生じる場合があります。
%
% K = TF2LATC(NUM,'max')で、NUMは最大位相FIRフィルタに対応し、
% FIRラティスに変換する前にNUMを反転させ、共役化します。
% これは、abs(K) <= 1となり、LATCFILTの第二出力として最大位相フィルタを
% 実現するために用いられます。
%
% K = TF2LATC(NUM,'min')で、NUMは最小位相FIRフィルタに対応し、
% これは、abs(K) <= 1となり、LATCFILTの第一出力として最小位相フィルタを
% 実現するために用いられます。
%
% K = TF2LATC(NUM,DEN,...)で、DENは、K = TF2LATC(NUM/DEN,...)と
% 等価なスカラです。
%
% [K,V] = TF2LATC(NUM,DEN)は、DEN(1)によって正規化されたIIR (ARMA) 
% lattice-ladder フィルタに対するラティスパラメータKとladderパラメータVを
% 求めます。伝達関数の極が単位円上にある場合には、誤差が生じる場合が
% あります。
%
% K = TF2LATC(1,DEN)は、IIR all-pole (AR)ラティスフィルタに対するラティス
% パラメータKを求めます。[K,V] = TF2LATC(B0,DEN) で、B0はスカラで、
% ladder係数Vのベクトルを出力します。この場合は、Vの最初の要素のみが
% 非ゼロです。
%
%   例題:
%      % Convert an all-pole IIR filter to lattice coefficients:
%      DEN = [1 13/24 5/8 1/3];
%      K = tf2latc(1,DEN);  % K will be [1/4 1/2 1/3]'
%
% 参考：LATC2TF, LATCFILT, POLY2RC, RC2POLY.



%   Copyright 1988-2002 The MathWorks, Inc.
