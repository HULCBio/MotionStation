% GET   serial port オブジェクトプロパティの取得
%
% V = GET(OBJ,'Property') は、serial port オブジェクト OBJ に対して、
% 指定されたプロパティ Property の値 V を出力します。
%
% プロパティが、1 行 N 列、または N 行 1 列のプロパティ名を含むセル配列
% の場合、GET は値を要素とする1 行 
% N 列のセル配列を出力します。OBJ が、serial port オブジェクトのベクトル
% の場合、Vがプロパティ値の M 行 N 列のセル配列になります。ここで、M は、
% OBJ の長さと等しく、N は、指定されるプロパティの数に等しくなります。
%
% GET(OBJ) は、serial port オブジェクト OBJ に対して、すべてのプロパティ
% 名とカレント値を表示します。
%
% V = GET(OBJ) は、構造体 V を出力します。ここで、構造体のフィールド名は、
% OBJ のプロパティ名で、各フィールドには、そのプロパティの値が設定されて
% います。
%
% 例題:
%       s = serial('COM1');
%       get(s, {'BaudRate','DataBits'})
%       out = get(s, 'Parity')
%       get(s)
%
% 参考 : SERIAL/SET.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
