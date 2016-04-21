% UNMKPP   区分多項式の分解
% 
% [BREAKS,COEFS,L,K,D] = UNMKPP(PP) は、区分多項式 PP から、節点、係数、
% 区分の数、その次数と次元を抽出します。PP は、SPLINE で作成されたものか、
% あるいはスプラインユーティリティ MKPP で作成されたものです。
%
% 参考：MKPP, SPLINE, PPVAL.


%   Carl de Boor 7-2-86
%   Copyright 1984-2003 The MathWorks, Inc.