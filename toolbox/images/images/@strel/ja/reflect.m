% REFLECT 点対称な構造化要素
% SE2 = REFLECT(SE) は、中心を通り、対称な構造化要素を作成します。この影
% 響は、構造化要素の領域を、その中心の回りに180度回転したかのように見え
% ます(2次元の場合)。
% SE が、構造化要素オブジェクトの配列の場合、REFLECT(SE) は、SE の各要素
% は点対称になり、SE2 は、SEと同じ大きさになります。
%
% 例題
% -------
%    se = strel([0 0 1; 0 0 0; 0 0 0])
%    se2 = reflect(se)
%
% 参考：STREL.



% $Revision: 1.1 $
%   Copyright 1993-2002 The MathWorks, Inc.
