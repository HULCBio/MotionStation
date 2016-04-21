% RGB2GRAY   RGB イメージ、または、カラーマップをグレースケールに変換
%   RGB2GRAY は、RGB イメージを輝度はそのままにして色調と彩度を削除し
%   て、グレースケールに変換します。
%
%   I = RGB2GRAY(RGB) は、トゥルーカラーイメージ RGB をグレースケール
%   強度イメージIに変します。
%
%   NEWMAP = RGB2GRAY(MAP) は、MAP と等価なグレースケールカラーマップ
%   を出力します。
%
%   クラスサポート
% -------------
%   入力が RGB イメージの場合、uint8、uint16、または、double のいずれ
%   のクラスもサポートしています。出力イメージ I は、入力イメージと同
%   じクラスになります。入力がカラーマップの場合、入力と出力のカラー
%   マップは共にクラス double です。
%
%   参考：IND2GRAY, NTSC2RGB, RGB2IND, RGB2NTSC



%   Copyright 1993-2002 The MathWorks, Inc.  
