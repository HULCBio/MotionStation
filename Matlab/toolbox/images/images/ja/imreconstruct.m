% IMRECONSTRUCT 　形態学的再構成を行います。
% IM = IMRECONSTRUCT(MARKER,MASK) は、イメージ MASK の下で、イメージ 
% MARKER の形態学的な再構成を行います。MARKER と MASK は、同じ大きさ
% をもつ、2つの強度イメージか、または、バイナリイメージです。IM は、
% 入力に対応して、強度イメージか、バイナリイメージになります。MARKER 
% は、MASK と同じ大きさで、その要素は、MASK の対応する要素より小さな
% 値の要素になります。
%
% デフォルトでは、IMRECONSTRUCT は、2次元イメージで、8連結近傍、3次元
% イメージで、26連結近傍を使います。高次元の場合は、CONNDEF(NDIMS(I),
% 'maximal') を使います。
%
% IM = IMRECONSTRUCT(MARKER,MASK,CONN) は、指定した連結をもつ形態学的
% 再構成を行います。CONN は、つぎのスカラ値を使います。
%
%       4     2次元4連結近傍
%       8     2次元8連結近傍
%       6     3次元6連結近傍
%       18    3次元18連結近傍
%       26    3次元26連結近傍
%
% 連結度は、CONN に対して、0と1を要素とする3 x 3 x 3 x ... x 3 の行列
% を使って、任意の次元に対して、より一般的に定義できます。値1は、CONN 
% の中心要素に関連して近傍の位置を設定します。CONN は、中心要素に対し
% て、対称である必要があります。
%
% 形態学的再構成は、いくつかの他の Image Processing Toolbox 関数、IM-
% CLEARBORDER, IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, IMHMIN, 
% IMIMPOSEMIN に対するアルゴリズムの基になっています。
%
% クラスサポート
% -------------
% MARKER と MASK は、同じクラスで任意の次元をもつ非スパースの数値、
% または logical でなければなりません。IM は、MARKER と MASK と同じ
% クラスです。
%
% 参考： IMCLEARBORDER, IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, 
%        IMHMIN, IMIMPOSEMIN.



%   Copyright 1993-2002 The MathWorks, Inc.
