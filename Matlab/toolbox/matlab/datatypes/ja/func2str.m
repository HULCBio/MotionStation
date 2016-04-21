% FUNC2STR は、function_handle から関数名文字列を作成します。
% 
% S = FUNC2STR(FUNHANDLE) は、function_handle FUNHANDLE で指定される関数
% 名を文字列 S に出力します。
%
% 文字列演算を実行することが必要な場合、たとえば、関数ハンドルに関した比
% 較、または、表示などのような場合、FUNC2STR を使って、関数名を表わす文字
% 列を作成できます。
%
% 例題：
%
% 関数ハンドルから関数文字列を作成するには、@hamps を使います。
%
%        funname = func2str(@humps)
%        funname =
%        humps
%
% 参考： FUNCTION_HANDLE, STR2FUNC, METHODS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $ $Date: 2004/04/28 01:47:17 $
