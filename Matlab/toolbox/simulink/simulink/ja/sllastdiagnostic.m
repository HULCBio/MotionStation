% SLLASTDIAGNOSTIC   Simulink 最新の診断メッセージ
%
% SLLASTDIAGNOSTIC 自身では、Simulink により生成された最新の診断を含む
% Simulink 診断構造体配列を出力します。診断構造体は、つぎのフィールドをもって
% います。
%
%  Type        'error'、または、'warning'  MessageID   診断に対するメッセージ
% ID (たとえば、 'SL_InvSimulinkObjectName')  Message     診断メッセージ
% Handle      診断に関連している Simulink オブジェクトハンドル
%
% SLLASTDIAGNOSTIC([]) は、Simulink の最新の診断をリセットし、つぎの
% Simulink 診断に出会うまで、空の配列を出力します。
%
% SLLASTDIAGNOSTIC(DIAGSTRUCT) は、Simulink の最新の診断を、DIAGSTRUCTで指定
% された部分に設定します。
%
% 参考 : SLLASTERROR, SLLASTWARNING.


% Copyright 1990-2002 The MathWorks, Inc.
