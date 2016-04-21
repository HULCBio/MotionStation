% SIMPRINTLOG   Simulinkプリントログ
%
% PrintLog = SIMPRINTLOG(Systems,Resolved,Unresolved,Stateflow) は、
% Simulink プリントダイアログで用いるプリントログを作成します。
%
% Systems    - 印刷するシステムのリスト
% Resolved   - 一意的な解決済ライブラリリンクのリスト  Unresolved - 一意的
%              な未解決ライブラリリンクのリスト
%
% リストは、文字列またはハンドルの列のセル配列でなければなりません。
% たとえば、
%
%  Systems = {'simulink';'simulink/Sources'}
%
% PrintLog   - 文字列行列
%
% 参考 : SIMPRINTDLG.


% Copyright 1990-2002 The MathWorks, Inc.
