% AUDIOUNIQUENAME  ワークスペースに一意的な変数名を割り当て
%
% この関数は、is a helper for toolbox/matlab/audio/prefspanel.m およびその他
% のワークスペースブラウザメニュー機能に対する補助関数です。この関数は
% 未サポートで、この関数の呼び出しは将来のリリースではエラーが発生する場合が
% あります。
%
% AUDIOUNIQUENAME(VAR, NAME, WS) は、変数 VAR 名前 NAME をワークスペース 
% WS に与えます。WS はデフォルトで 'caller' です。名前 NAME をもつ変数が
% ワークスペース WS に既に存在する場合は、希望する変数名に番号が付け加えられ
% ます。

%   Author: B. Wherry
%   Copyright 1984-2002 The MathWorks, Inc.
