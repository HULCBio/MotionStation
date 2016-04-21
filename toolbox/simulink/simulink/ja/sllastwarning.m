% SLLASTWARNING   Simulink の最新のワーニングメッセージ
%
% SLLASTWARNING 自身では、Simulink により生成された最新のワーニングを含む
% Simulink 診断構造体を出力します。診断構造体は、つぎのフィールドをもっていま
% す。
%
%  Type        'warning' MessageID   ワーニングに対するメッセージ ID (たとえ
% ば、 'SL_InvSimulinkObjectName')     Message     ワーニングメッセージ
% Handle      ワーニングに関連した Simulink オブジェクトハンドル
%
% SLLASTWARNING([]) は、つぎの Simulink エラーに出会うまで、空行列を出力するた
% めに最新のワーニングをリセットします。
%
% SLLASTWARNING(DIAGSTRUCT) は、Simulink の最新のワーニングを、DIAGSTRUCT で指
% 定された部分に設定します。
%
% 参考 : SLLASTDIAGNOSTIC, SLLASTERROR.


% Copyright 1990-2002 The MathWorks, Inc.
