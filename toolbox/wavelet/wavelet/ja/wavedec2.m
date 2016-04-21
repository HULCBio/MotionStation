% WAVEDEC2 　多重レベルの2次元ウェーブレット分解
%
% [C,L] = WAVEDEC2(X,N,'wname') は、文字列 'wname'(WFILTERS を参照)で
% 設定されたウェーブレットを使って、レベル N で行列 X のウェーブレット
% 分解を出力します。出力は、ウェーブレット分解ベクトル C とその長さを
% 要素とする行列 S です。N は厳密な意味での正の整数でなくてはなりません
% (WMAXLEV を参照)。
%
% ウェーブレット名の代わりに、フィルタを設定することもできます。
% [C,S] = WAVEDEC2(X,N,Lo_D,Hi_D) に対して、
%   Lo_D は、分解ローパスフィルタで、
%   Hi_D は、分解ハイパスフィルタです。
%
% 2次元ウェーブレット分解構造 [C,S] は、ウェーブレット分解ベクトル C 
% とその大きさを要素とする行列 S から構成されます。ベクトル C は、
% つぎのように組み合わされます。
%
% C = [ A(N)   | H(N)   | V(N)   | D(N) | ... 
% H(N-1) | V(N-1) | D(N-1) | ...  | H(1) | V(1) | D(1) ].
% 
% ここで、A、H、V、D は、つぎのような行ベクトルです。 
%   A = Approximation 係数
%   H = 水平Detail 係数
%   V = 垂直Detail 係数
%   D = 対角Detail 係数
% 
% それぞれのベクトルは、行列で列単位ストレージベクトルです。行列 S は、
% つぎの内容を含んでいます。
%     S(1,:) = Approximation 係数(N)の大きさ
%     S(i,:) = Detail 係数(N-i+2)の大きさ、ここで、i = 2,...,N+1 と 
%     S(N+2,:) = size(X) です。
% 
% 参考： DWT2, WAVEINFO, WAVEREC2, WFILTERS, WMAXLEV.



%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
