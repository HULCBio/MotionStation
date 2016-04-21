% CHGUNITS   FRD モデルの周波数単位の変換
%
%
% SYS = CHGUNITS(SYS,UNITS) は、FRDモデル SYS の周波数点の単位を、UNITSに
% 変換します。 ここで、UNITS は、'Hz' または 'rad/s' のどちらか一方です。
% 周波数値には 2*pi のスケーリングファクタが適用され、プロパティ 'Units'が
% 更新されます。
% 'Units' フィールドに、既に設定された UINITS と同じものが設定されている
% 場合、何もしません。
%
% 参考 : FRD, SET, GET.


% Copyright 1986-2002 The MathWorks, Inc.
