%ISGLOBAL グローバル変数の検出
% ISGLOBAL(A) は、ISGLOBAL がコールされるコンテキストで、A がグローバル
% 変数として宣言されていれば、TRUE であり、そうでない場合、FALSE です。
%
% ISGLOBAL は廃止されており、MATLAB の将来のバージョンでは使用されなくなり
% ます。
%
% ISGLOBAL は、条件グローバル宣言とともに通常使用されます。 
% 代わりのアプローチは、ローカルおよびグローバルに宣言された変数の組
% を使用することです。
%
%
%     if condition
%       global x
%     end
%
%     x = some_value
%
%     if isglobal(x)
%       do_something
%     end
%
%
% 上記を使用する代わりに、以下を使用することができます。
%
%
%     global gx
%     if condition
%       gx = some_value
%     else
%       x = some_value
%     end
%
%     if condition
%       do_something
%     end
%
%
% 他の回避策がない場合、"isglobal(variable)" の代わりにつぎのようにします。
%
%     ~isempty(whos('global','variable'))
%
%
% 参考 GLOBAL, CLEAR, WHO.

%   Copyright 1984-2003 The MathWorks, Inc. 
