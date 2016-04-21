% MAKETREE 　ツリーの作成
% [T,NB] = MAKETREE(ORD,D) は、深さ D をもつ次数 ORD のツリー構造を作成します。
% 出力引数 NB = ORD^D は、不連続ノードの番号です。出力ベクトル T は、[T(1) ... 
% T(NB+1)]のように作られます。ここで、T(i)、i は 1 から NB で、NB は不連続ノード
% のインデックスで、T(NB+1) = -ORDです。
%
% ノードは、左から右、上から下へと番号付けされています。ルートとなるインデックス
% は0です。
%
% 3つの入力引数を使うとき、[T,NB] = MAKETREE(ORD,D,NBI) は、上のように T(1,:) を
% (1+NBI) 行 (NB+1) 列の行列として T を計算します。また、T(2:NBI+1,:) には、ユー
% ザは自身のものを自由に付加できます。
%
% なお、MAKETREE(ORD) は、MAKETREE(ORD,0,0) と等価です。MAKETREE(ORD,D) は、MA-
% KETREE(ORD,D,0) と等価です。
%
% 参考： PLOTTREE, WTREEMGR.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
