% SLLASTERROR   Simulinkの最新のエラーメッセージ
%
% SLLASTERROR 自身では、Simulink により生成された最新のエラーを含む
% Simulink 診断構造体を出力します。診断構造体は、つぎのフィールドをもっていま
% す。
%
%  Type        'error' MessageID   エラーに対するメッセージ ID (たとえば、 '
% SL_InvSimulinkObjectName')       Message     エラーメッセージ
% Handle      エラーに関連した Simulink オブジェクトハンドル
%
% SLLASTERROR([]) は、Simulink の最新のエラーをリセットし、つぎのSimulink エラー
% に出会うまで、空の配列を出力します。
%
% SLLASTERROR(DIAGSTRUCT) は、Simulink の最新のエラーを、DIAGSTRUCT で指定され
% た部分に設定します。
%
% 参考 : SLLASTDIAGNOSTIC, SLLASTWARNING.


% Copyright 1990-2002 The MathWorks, Inc.
