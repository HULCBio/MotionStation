% DSSDATA   ディスクリプタ状態空間データへのクイックアクセス
%
%
% [A,B,C,D,E] = DSSDATA(SYS) は、ディスクリプタ状態空間モデル SYS(DSS参照)
% に対して、行列 A, B, C, D, E の値を出力します。通常の状態空間モデルに対して、
% DSSDATA は、(すなわち、E = I のとき) SSDATA と等価になります。
%
% [A,B,C,D,E,TS] = DSSDATA(SYS) は、サンプル時間 TS も出力します。
% SYS のその他のプロパティは、GET を用いて抽出するか、直接的に構造体ライクな
% 書式で参照できます(たとえば、SYS.Ts)。
%
% 可変次数の SS モデルの配列に対して、可変サイズのA,B,C,D,E行列のセル配列に
% 出力するために、つぎの書式を利用してください。 
%   [A,B,C,D,E] = DSSDATA(SYS,'cell')
%
% 参考 : GET, SSDATA, DSS, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.
