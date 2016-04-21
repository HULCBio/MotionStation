% CHGUNITS は、IDFRD モデルの周波数の単位の変更を行ないます。
%
% SYS = CHGUNITS(SYS,UNITS) は、IDFRD モデルの SYS で格納されている
% 周波数点の単位をUNITS に変更します。ここで、UNITS は、'Hz' または 
% 'rad/s'のいずれかを設定します。2*pi のスケーリングファクタが周波数値
% に適用され、'Units' プロパティが更新されます。'Units' フィールドが
% 既にUNITS と一致している場合、変化は生じません。
%
% 参考： FRD, SET, GET.


%       Author(s): S. Almy
%       Copyright 1986-2001 The MathWorks, Inc.
