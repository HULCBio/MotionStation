% WAVEDEC 　多重レベルの1次元ウェーブレット分解
%
% WAVEDEC は、指定された特定のウェーブレット(WFILTERS参照)または特定の
% ウェーブレット分解フィルタのいずれかを使って、多重レベルの1次元ウェー
% ブレット解析を行います。
%
% [C,L] = WAVEDEC(X,N,'wname') は、'wname'を使って、レベル N で信号 X の
% ウェーブレット分解を出力します。
%
% N は、厳密な意味での正の整数でなくてはなりません(WMAXLEV を参照)。出力
% 分解構造は、ウェーブレット分解ベクトル C とその大きさを要素とするベク
% トル L です。
%
% [C,L] = WAVEDEC(X,N,Lo_D,Hi_D) に対して、
%   Lo_D は、分解ローパスフィルタで、
%   Hi_D は、分解ハイパスフィルタです。
%
% この構造は、つぎのように組織化されます。
%   C      = [Approximation 係数(N)| Detail 係数(N)|... |Detail 係数(1)]
%   L(1)   = Approximation 係数の長さ (N)
%   L(i)   = Detail 係数の長さ (N-i+2) ここで、i = 2,...,N+1 です。
%   L(N+2) = length(X).
%
% 参考： DWT, WAVEINFO, WAVEREC, WFILTERS, WMAXLEV.



%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
