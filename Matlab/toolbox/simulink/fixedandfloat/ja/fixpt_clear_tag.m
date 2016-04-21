% FIXPT_CLEAR_TAG(SystemName)
%
% (サブ)システム内のすべてのブロックに対して、Fixed Point Blockset ライ
% ブラリにリンクしているものを検索します。これらのブロックに対して、Tag 
% と AttributesFormatString で名付けられたパラメータは、空の文字列に設定
% されます。
% 
% Fixed Point Blockset 2.0 は、モデルが更新される度に、これらのパラメータ
% 内にカレント情報を設定します。スピードを向上するため、Fixed Point 
% Blockset の最新リリースは、これらのパラメータを設定しません。バージョン
% 2.0 を使って作成したモデルに対して、Tag と AttributesFormatString の
% 情報は、古いもので、多分、正しいものではありません。このスクリプトは
% 古い情報を削除するものです。
% 1つ以上のブロックが修正された場合、結果の値は真で、それ以外の出力値は
% 偽になります。


% Copyright 1994-2002 The MathWorks, Inc.
