% IMFEATURE   イメージ領域に対する形状測定についての計算
%   STATS = IMFEATURE(L,MEASUREMENTS) は、ラベル行列 L 内のラベル付け
%   された、それぞれの領域に対して、測定の集合を計算します。L の正の整
%   数要素は異なる領域に対応します。たとえば、1に等しいLの要素の集合
%   は、領域1に対応します。2に等しいLの要素の集合は、領域2に対応しま
%   す。そして、以下同様になります。STATS は、長さ max(L(:)) の構造体
%   配列です。構造体配列のフィールドは、MEASUREMENTS により設定されて
%   いるように、各領域に対する異なる測定を示します。
%
%   MEASUREMENTS は、コンマで区切られた文字列のリスト、文字列を含むセ
%   ル配列、文字列 'all'、または、文字列 'basic' を使用することができ
%   ます。使用可能な測定の文字列の集合は、以下のとおりです。
%
%     'Area'              'ConvexHull'    'EulerNumber'
%     'Centroid'          'ConvexImage'   'Extrema'
%     'BoundingBox'       'ConvexArea'    'EquivDiameter'
%     'MajorAxisLength'   'Image'         'Solidity'
%     'MinorAxisLength'   'FilledImage'   'Extent'
%     'Orientation'       'FilledArea'    'PixelList'
%     'Eccentricity'
%
%   測定の文字列は、大文字、小文字の区別を行いません。そして、省略形を
%   使うこともできます。
%
%   MEASUREMENTS が文字列 'all' である場合、上述のすべての測定について
%   計算します。MEASUREMENTS を設定しない場合や、文字列 'basic' である
%   場合には 'Area','Centroid','BoundingBox' の測定について計算しま
%   す。
%
%   STATS = IMFEATURE(L,MEASUREMENTS,N) は、測定量 'FilledImage',
%   'FilledArea','EulerNumber' を計算する際に使う連結タイプを設定しま
%   す。N には、4、または、8のいずれかの値を使用することができます。こ
%   のとき、4は4連結オブジェクト、8は8連結オブジェクトを設定します。こ
%   の引数を省略すると、デフォルトの8を設定します。
%
% クラスサポート
% -------------
% 入力ラベル行列 L は、double 、または、任意の整数のクラスをサポート
% しています。
%
% 参考 : BWLABEL, ISMEMBER



%   Copyright 1993-2002 The MathWorks, Inc.
