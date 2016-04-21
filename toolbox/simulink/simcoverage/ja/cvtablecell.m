% CVTABLECELL - coverageの詳細のテーブルを表示するためのダイアログ
%
% CVTABLECELL(TABLEID,EXECCNT,INDEX,MINVAL,MAXVAL) は、内挿か飽和か、
% また、MINVAL(i) - MAXVAL(i) の区間に基づく範囲、実行回数 EXECCNT、
% テーブルのインデックス INDEX を示すダイアログボックスを生成します。
% 飽和は、NaN を使って MINVAL または MAXVAL の要素を置き換えることに
% よって示されます。MAXVAL が空で、MINVAL がスカラの場合、情報は非ゼロの
% INDEX の要素と MINVAL の値によって定義されたブレークポイントに対して
% 表示されます。


%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
