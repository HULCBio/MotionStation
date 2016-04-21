% GET_PARAM   Simulinkシステムとブロックのパラメータ値を取得
%
% GET_PARAM('OBJ','PARAMETER') は、'OBJ'がシステムまたはブロックのパス名であ
% るとき、指定したパラメータの値を出力します。パラメータ名については、大文字と小
% 文字の区別はありません。
%
% GET_PARAM(OBJ, 'ObjectParameters') は、OBJ パラメータを記述する構造体を出力
% します。出力される構造体の各フィールドは、特定のパラメータ名(たとえば、'
% Name' フィールドは、OBJ の名前パラメータに対応)に対応します。各パラメータフィー
% ルド自身は、つぎのフィールドをもつ構造体です。
%
% Type        パラメータタイプ('boolean', 'string', 'int', 'real', 'point'
% , 'rectangle', 'matrix','enum', 'ports', 'list')Enum        列挙された文
% 字値のセル配列('enum' パラメータタイプにのみ 適用)Attributes  パラメータの
% 属性を定義する文字列のセル配列('read-write', 'read-only','
% read-only-if-compiled', 'write-only', 'dont-eval', 'always-save', '
% never-save','nondirty', 'simulation')
%
% 'DialogParameters' ブロックプロパティは、ブロックパラメータダイアログの中に
% 表示されるパラメータのみを記述する同様な構造体を出力します。
%
% 参考 : SET_PARAM, FIND_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.
