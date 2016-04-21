% DSSDATA   ディスクリプタ状態空間データへのクイックアクセス
%
% [A,B,C,D,E] = DSSDATA(SYS) は、ディスクリプタ状態空間モデル SYS(DSS 
% 参照)に対して、行列 A, B, C, D, E の値を出力します。通常の状態空間モデル
% に対して、DSSDATA は、(すなわち、E = I のとき)SSDATA と等価になります。
%
% [A,B,C,D,E,TS] = DSSDATA(SYS) は、サンプル時間 TS も出力します。SYS の
% その他のプロパティは、GET を使って参照するか、構造体ライクな形式(たと
% えば、SYS.Ts)で直接的に参照できます。
%
% 可変次数の SS モデルの配列に対して、可変サイズの A, B, C, D, E 行列の
% セル配列に出力するために、つぎの書式を利用してください。
% 
%   [A,B,C,D,E] = DSSDATA(SYS,'cell')
%
% 参考 : GET, SSDATA, DSS, LTIMODELS, LTIPROPS.


%    Author(s): P. Gahinet, 4-1-96
%    Copyright 1986-2002 The MathWorks, Inc. 
