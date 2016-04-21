% SSDATA   状態空間データへのクイックアクセス
%
%
% [A,B,C,D] = SSDATA(SYS) は、状態空間モデルSYSに関する行列データ A,B,C,Dを抽
% 出します。SYS が状態空間モデルでない場合、あらかじめ状態空間表現に変換しま
% す。
%
% [A,B,C,D,TS] = SSDATA(SYS) は、サンプル時間 TS も出力します。
% SYS のその他のプロパティは、GET を用いて抽出するか、直接的に構造体ライクな
% 書式で参照できます(たとえば、SYS.Ts)。
%
% 同じ次数(状態の数)の SS モデルの配列の場合、SSDATA は、多次元配列 A,B,C,
% D を出力します。 ここで、 A(:,:,k), B(:,:,k), C(:,:,k), D(:,:,k) は、k番目の
% モデル SYS(:,:,k) の状態空間行列を与えます。
%
% 次数の異なるLTIモデルに対して、セル配列の中の可変サイズの行列 A,B,C,D次数
% を求めるためには、つぎの書式を利用してください。 [A,B,C,D] = SSDATA(SYS,'
% cell')
%
% 参考 : SS, GET, DSSDATA, TFDATA, ZPKDATA, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.
