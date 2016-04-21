% WGETHIST 　ヒストグラムのプロットに用いる値を出力
% P = WGETHIST(X,N) は、2 行 N 列の行列を出力します。ここで、X はベクトルまたは
% 行列であり、N はバイナリ(bins)の数です。
%   P(1,:) は、ヒストグラムを構成する点のx座標
%   P(2,:) は、ヒストグラムを構成する点のy座標
%
% P = WGETHIST(X) は、 P = WGETHIST(X,10) と等価です。
%
% P = WGETHIST(X,N,MODE) (MODE = 'center' または 'left')、X が定数の場合、ヒスト
% グラムを構成するメイン集合は、中心に収束するか否かのいずれかになります(収束す
% るか否かは、MODE の値に依存します)。
%
% 参考： WIMGHIST.



%   Copyright 1995-2002 The MathWorks, Inc.
