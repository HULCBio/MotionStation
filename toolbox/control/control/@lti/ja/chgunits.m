% CHGUNITS   FRDモデルの周波数単位の変換
%
%
% SYS = CHGUNITS(SYS,UNITS) は、FRDモデル SYS の周波数点の単位を、UNITSに変換
% します。 ここで、UNITS は、'Hz' または 'rad/s' のどちらか一方です。周波数値に
% は2*pi のスケーリングファクタが適用され、プロパティ 'Units'が更新されます。
% 'Units' フィールドに、既に設定された UINITS と同じものが設定されている場合、
% 何もしません。
%
% 参考 : FRD, SET, GET.


% Copyright 1986-2002 The MathWorks, Inc.
