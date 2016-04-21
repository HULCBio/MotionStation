% TEXTWRAP   与えられたUIコントロールに対して適切に改行された文字列行列
%を出力
%
% OUTSTRING = TEXTWRAP(UIHANDLE,INSTRING) は、文字列のセル配列
% (OUTSTRING)を出力します。これは、与えられたuicontrolの内部で、適切に
% 改行されています。 
%
% OUTSTRING は、セル配列書式の適切に改行された文字列行列です。
%
% UIHANDLE は、文字列が配置されるオブジェクトのハンドル番号です。
%
% INSTRING は、セル配列です。段落の改行は、各々のセルに対して実現されて
% います。配列の各セルは、各々の段落と考えられ、文字列ベクトルのみを
% 含まなければなりません。段落がキャリッジリターンで区切られている場合は、
% TEXTWRAP はキャリッジリターンで段落の行を改行します。
%
% OUTSTRING = TEXTWRAP(INSTRING、COLS) は、段落がキャリッジリターン
% で区切られていなければ、行が COLS の位置で改行されている、文字列のセル
% 配列を出力します。段落に、キャラクタ COLS がない場合は、段落内のテキスト
% は改行さません。 
% 
% この関数は、つぎのように呼び出すこともできます。
% 
%    [OUTSTRING,POSITION] = TEXTWRAP(UIHANDLE,INSTRING)
% 
% ここで、POSITIONは、uicontrolの推奨される位置で、uicontrolの単位で
% 表わされます。
% [OUTSTRING,POSITION] = TEXTWRAP(UIHANDLE,INSTRING,COLS)も機能します。
% この場合、OUTSTRING は COLS で改行され、推奨される位置が出力されます。


%  Loren Dean 
%   Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.9.4.1 $
