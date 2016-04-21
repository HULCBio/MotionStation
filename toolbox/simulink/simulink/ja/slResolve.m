% SLRESOLVE   ブロックのコンテキストに与えられた変数名の分解
%
% SLRESOLVE('variable_name',BLOCK) は、BLOCK のコンテキスト内の
% 'variable_name' を分解します。BLOCK は、有効な gcb、またはブロックの
% パスでなければなりません。
%
% 例)    slresolve('k','myModel/Subsystem/Gain');
%        slresolve('k',gcb);


%   Copyright 1984-2002 The MathWorks, Inc.
