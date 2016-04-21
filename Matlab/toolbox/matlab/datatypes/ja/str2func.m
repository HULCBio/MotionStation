% STR2FUNC   関数名の文字列から関数ハンドル(function_handle)を構築
%
% FUNHANDLE = STR2FUNC(S) は、文字列 S 内の関数名から関数ハンドル
% (function_handle) FUNHANDLE を構築します。
%
% @function 構文か、STR2FUNC コマンドのどちらかを用いて関数ハンドルを
% 作成することができます。文字列のセル配列でこの操作を実行することも
% 可能です。この場合、関数ハンドルの配列が出力されます。
%
% 例題:
%
% 関数名 'humps' から関数ハンドルを作成します。:
%
%        fhandle = str2func('humps')
%        fhandle = 
%            @humps
%
% 関数名のセル配列から関数ハンドルの配列を作成します:
%
%        fh_array = str2func({'sin' 'cos' 'tan'})
%        fh_array = 
%            @sin    @cos    @tan
%
% 参考: FUNCTION_HANDLE, FUNC2STR, FUNCTIONS.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $ $Date: 2004/04/28 01:47:50 $
