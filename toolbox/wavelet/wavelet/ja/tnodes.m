% TNODES 　不連続なノードの検出 (削除される関数 - LEAVES を使用してください)
% N = TNODES(T) は、ツリー構造T(MAKETREE を参照)の不連続ノードのインデックスを出
% 力します。N は列ベクトルです。
%
% ノードは左から右、上から下へ番号付けされています。ルートインデックスは0です。
%
% N = TNODES(T,'deppos') は、不連続なノードの深さと位置を含む行列 N を出力します。
% N(i,1) は、i 番目の不連続ノードの深さで、N(i,2) は、i 番目の不連続ノードの位置
% を示します。
%
% [N,K] = TNODES(T)、または、[N,K] = TNODES(T,'deppos') に対して、 M = N(K) は、
% ツリー T で、左から右へと番号を付け直したインデックスです。
%
% 参考： LEAVES, NOLEAVES, WTREEMGR.



%   Copyright 1995-2002 The MathWorks, Inc.
