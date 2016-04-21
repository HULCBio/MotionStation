% WPJOIN     ウェーブレットパケットの組み替え
% WPJOIN は、1つのノードを組み替えた後、ツリー構造 T とデータ構造 D をアップデー
% トします。
%
% [T,D] = WPJOIN(T,D,N) は、ノード N の組み替えに対応して、ツリー構造 T とデータ
% 構造 D (MAKETREE参照)をアップデートしたものを出力します。[T,D,X] = WPJOIN(...
% T,D,N) は、ノードの係数も出力できます。
%
% [T,D] = WPJOIN(T,D) は、[T,D] = WPJOIN(T,D,0) と等価です。
% 
% [T,D,X] = WPJOIN(T,D) は、[T,D,X] = WPJOIN(T,D,0) と等価です。
%
% 参考： MAKETREE, WPDEC, WPDEC2, WPSPLT.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
