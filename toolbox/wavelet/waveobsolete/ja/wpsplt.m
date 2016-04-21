% WPSPLT   ウェーブレットパケットの分割(分解)
% WPSPLT は、あるノードの分解の後のツリー構造とデータ構造をアップデートします。
%
% [T,D] = WPSPLT(T,D,N) は、ノード N の分解に対応したツリー構造 T とデータ構造 D
% をアップデートしたものを出力します(MAKETREE を参照)。
%
% 1次元の分解については、
% [T,D,CA,CD] = WPSPLT(T,D,N) で、ノード N での CA は Approximation で、 CD は 
% Detail となります。
%
% 2次元の分解については、 
% [T,D,CA,CH,CV,CD] = WPSPLT(T,D,N) で、ノード N での CA は Approximation で、CH、
% CV、CD は、水平、垂直、対角方向の Detail です。
%
% 参考： MAKETREE, WAVEDEC, WAVEDEC2, WPDEC, WPDEC2, WPJOIN.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
