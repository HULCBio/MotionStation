% AUGSTATE   状態空間モデルの出力に状態を付加
%
% ASYS = AUGSTATE(SYS) は、状態空間モデル SYS の出力に状態を付加します。
% 結果のモデルは、つぎのように表せます。
%      .                           .
%      x  = A x + B u   (または、E x = A x + B u ：デスクリプタSS用)
%
%     |y| = [C] x + [D] u
%     |x|   [I]     [0]
%
% このコマンドは、全状態フィードバックゲイン  u = Kx を使って、ループを
% 閉じるときに有効です。プラントを関数 AUGSTATE と共に準備して、FEEDBACK
% コマンドを使って、閉ループモデルを導出します。
%
% 参考 : FEEDBACK, SS, LTIMODELS.


%       Author(s): A. Potvin, 12-1-95
%       Copyright 1986-2002 The MathWorks, Inc. 
