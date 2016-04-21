% GETNEIGHBORS 構造化要素の近傍位置、高さの取得
% [OFFSETS,HEIGHTS] = GETNEIGHBORS(SE) は、構造化要素オブジェクト SE の
% 中で、相対的な高さと、各々の近傍に対して、対応する高さを出力します。
% OFFSETS は、P 行 N 列の配列で、P は、構造化要素の中の近傍の数で、N は、
% 構造化要素の広がりです。OFFSETS の各行は、構造化要素の中心を基準にした
% 対応する近傍の位置を含みます。HEIGHT は、個々の構造化要素の近傍の高さを
% 含む P 要素の列ベクトルです。
%
% 例題
% -------
%    se = strel([1 0 1],[5 0 -5])
%    [offsets,heights] = getneighbors(se)
%
% 参考：STREL, STREL/GETNHOOD, STREL/GETHEIGHT.



% $Revision: 1.1 $
%   Copyright 1993-2002 The MathWorks, Inc.
