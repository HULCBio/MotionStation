% FUNCTIONS   関数ハンドルに関する情報を出力
%
% F = FUNCTIONS(FUNHANDLE) は、FUNHANDLE に関する関数名、タイプ、他の
% 情報を MATLAB 構造体に出力します。
% 
% 関数 FUNCTIONS は、内部的な目的で使われて、目的を引用したり、デバッグ
% 用に使われます。その挙動は、それに続くリリースの中で変更され、プログ
% ラミング法に依存しません。
%
% 例題：
%
% 関数 DEBLANK 用の関数ハンドルの情報を得ましょう。:
%
%        f = functions(@deblank)
%        f = 
%            function: 'deblank'
%                type: 'overloaded'
%                file: 'matlabroot\toolbox\matlab\strfun\deblank.m'
%             methods: [1x1 struct]
%
% メソッドフィールドは、関数を多重定義する各組み込みのクラスに対し、
% 1つのフィールド名を含むサブ構造体です。これは、多重定義関数について
% のみ存在します。各フィールドの値は、メソッドを定義するファイルのパス
% と名前になります。
%
%            
% 参考：FUNCTION_HANDLE, FUNC2STR, STR2FUNC.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2004/04/28 01:47:19 $
%   Built-in functions.