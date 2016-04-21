% CMGAMMA   ガンマ補正カラーマップ
% CMGAMMA(MAP,GTABLE) は、行列 GTABLE のガンマ補正をカラーマップ MAP に
% 適用し、それをカレントのカラーマップとしてインストールします。GTABLE 
% を m 行2列、または、m 行4列の行列にすることができます。GTABLE が m 行2
% 列である場合、CMGAMMA は、カラーマップの3つの成分すべてに対して同じ補
% 正を適用します。GTABLE が m 行4列である場合、CMGAMMA は、GTABLE の列の
% 補正をカラーマップの各成分に別々に適用します。
% 
% CMGAMMA(MAP) は、関数 CMGAMDEF(COMPUTER) を呼び出して、ガンマ補正テー
% ブルを定義します。このツールボックスの前にユーザのパス上に、CMGAMDEFM 
% ファイルを設定することにより、ユーザのデフォルトテーブルをインストール
% することができます。
% 
% CMGAMMA、または、CMGAMMA(GTABLE) は、カレントのカラーマップにデフォル
% トのガンマ補正テーブル、または、GTABLE を適用します。
% 
% NEWMAP = CMGAMMA(...) は、補正したカラーマップを出力しますが、その適用
% は行いません。
%
% 参考：CMGAMDEF, INTERP1.



%   Copyright 1993-2002 The MathWorks, Inc.  
