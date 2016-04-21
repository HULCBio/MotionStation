% EVALMCW   エディタブルテキストuicontrolの関数のリストの評価
% 
% EVALMCWは、"Evaluate MATLAB command window"(MATLABコマンドウィンドウの
% 評価)を略したものです。
% EVALMCW(editHandle)は、ハンドルeditHandleで参照されるエディタブルテキ
% ストuicontrolオブジェクト内のMATLABコードを評価します。コード内で
% エラーが検出されると、editフィールドにエラーを表示し、そして、最後に
% 実行された正しいステートメントに、テキストをリセットします。


%   Ned Gulley, 6-21-93
%   Copyright 1984-2002 The MathWorks, Inc.
