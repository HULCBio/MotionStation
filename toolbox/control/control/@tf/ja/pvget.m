% PVGET   パブリックなLTIプロパティの値を取得
%
% VALUES = PVGET(SYS) は、セル配列 VALUES の中のすべてのパブリックな値を
% 出力します。
%
% [VALUES,VALSTR] = PVGET(SYS) は、GET(SYS) で表示される書式化されたプロ
% パティ値情報を含む文字列 VALSTR のセル配列を出力します。書式化は、
% PVFORMAT を使って実行できます。
%
% VALUE = PVGET(SYS,PROPERTY) は、PROPERTY を指定することにより、単一
% プロパティ値を出力します。文字列プロパティは、(大文字、小文字の違いも
% 含めて)正確なプロパティ名で指定しなければいけません。
%
% 参考 : GET.


%   Author(s): P. Gahinet, 7-8-97
%   Copyright 1986-2002 The MathWorks, Inc. 
