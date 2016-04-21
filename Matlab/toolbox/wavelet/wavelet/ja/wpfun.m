% WPFUN 　ウェーブレットパケット関数
% [WPWS,X] = WPFUN('wname',NUM,PREC) は、'wname' (WFILTERS 参照)に対するウェーブ
% レットパケットを長さ 1/2^PREC の2進間隔で計算します。PREC は正の整数です。
% 出力行列 WPWS は、0から NUM までのインデックスの W 関数で、[W0; W1;...; Wnum] 
% のように行様式でストアしたものです。出力ベクトル X は、対応する共通の X グリッ
% ドベクトルです。
%
% [WPWS,X] = WPFUN('wname',NUM) は、[WPWS,X] = WPFUN('wname',NUM,7) と等価です。
% 
% 参考： WAVEFUN, WAVEINFO.



%   Copyright 1995-2002 The MathWorks, Inc.
