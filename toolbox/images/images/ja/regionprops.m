% REGIONPROPS 　イメージ領域のプロパテいの測定
% STATS = REGIONPROPS(L,PROPERTIES) は、ラベル行列 L の中の各ラベル付き
% 領域に対するプロパティの集合を測定します。L の正の整数要素は、異なる領
% 域を意味します。たとえば、L の要素集合が、1を示すものは、領域1に対応し
% 2 のものは、領域2に、等々、対応します。STATS は、長さ max(L(:)) の構造
% 体配列です。構造体配列のフィールドは、PROPERTIES で設定されるように、各
% 領域に対する異なるプロパティを定義します。
%
% PROPERTIES は、カンマを区切り子とする文字列、文字列を含むセル配列、文字
% 列'all'、または、文字列'basic' のいずれでも構いません。測定に関する正し
% い文字列の集合は、つぎのものを含んでいます。
%
%     'Area'              'ConvexHull'    'EulerNumber'
%     'Centroid'          'ConvexImage'   'Extrema'       
%     'BoundingBox'       'ConvexArea'    'EquivDiameter' 
%     'SubarrayIdx'       'Image'         'Solidity'      
%     'MajorAxisLength'   'PixelList'     'Extent'        
%     'MinorAxisLength'   'PixelIdxList'  'FilledImage'  
%     'Orientation'                       'FilledArea'                   
%     'Eccentricity'                       
%                                                         
% プロパティ文字列は、大文字、小文字に関係なく、省略もできます。
%
% PROPERTIES が、文字列'all' の場合、上述した測定はすべて計算されます。
% PROPERTIES が、設定されていない、または、文字列'basic'が設定されている
% 場合は、つぎの測定'Area', 'Centroid', 'BoundingBox' が計算されます。
%
% クラスサポート
% -------------
% 入力のラベル行列 L は、任意の数値クラスです。
%
% 参考： BWLABEL, BWLABELN, ISMEMBER, WATERSHED.



%   Copyright 1993-2002 The MathWorks, Inc.  
