% BESTTREE　最良のツリー(ウェーブレットパケット)
% BESTTREEは、エントロピータイプ規範を参照しながら、初期ツリーの最適サブツリーを
% 計算します。計算の結果求まるツリーが、初期ツリーよりもかなり小さくなることもあ
% ります。
%
% [T,D] = BESTTREE(T,D) は、最適エントロピー値に対応するように修正されたツリー構
% 造 T とデータ構造 D を計算します。
%
% [T,D,E] = BESTTREE(T,D) は、最良ツリー T 、データ構造 D 、最良エントロピー E 
% を出力します。
%
% [T,D,E,N] = BESTTREE(T,D)は、最良ツリー T 、データ構造 D 、最良エントロピー E 
% に加えて、マージされたノードのインデックスを含んだベクトル N も出力します。
% 
% 参考： BESTLEVT, MAKETREE, WENTROPY, WPDEC, WPDEC2.
% 



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
