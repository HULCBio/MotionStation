% GET   timer オブジェクトプロパティの取得
%
% GET(OBJ) は、timer オブジェクト OBJ に対して、すべてのプロパティ名と
% カレントの値を表示します。
%
% V = GET(OBJ) は、構造体 V を出力します。ここで、各フィールド名は、
% OBJ のプロパティ名で、各フィールドはプロパティの値を含みます。
%
% V = GET(OBJ,'PropertyName') は、timer オブジェクト OBJ に対する
% 指定されたプロパティ PropertyName の値 V を出力します。
%
% PropertyName が1行N列、またはN行1列のプロパティ名を含んだ文字列の
% セル配列である場合、GET は、値の1行N列のセル配列を出力します。OBJ が、
% timer オブジェクトのベクトルの場合、V はM行N列のプロパティ値のセル配列
% です。ここで、M は OBJ の長さと等しく、N は指定されたプロパティの数に
% 等しくなります。
%
% 例題:
%       t = timer
%       get(t, {'StartDelay','Period'})
%       out = get(t, 'UserData')
%       get(t)
%
% 参考 : TIMER, TIMER/SET.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:40 $
