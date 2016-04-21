% BODEMAG   LTIモデルに対する ボードゲインをプロット
%
%
% BODEMAG(SYS) は、LTIモデル SYS の周波数応答の大きさをプロットします(位相に
% 関するプロットはありません)。周波数の範囲と応答を計算する点数は、自動的に選
% 択されます。
%
% BODEMAG(SYS,{WMIN,WMAX}) は、WMIN と WMAX(共に、rad/sec 単位) 間の周波数に
% 対する大きさの応答をプロットします。
%
% BODEMAG(SYS,W) は、W に設定した周波数に対する応答を計算します。 周波数の単
% 位は、rad/sec です。
%
% BODEMAG(SYS1,SYS2,...,W) は、複数のLTIモデル SYS1,SYS2,... の周波数応答の
% 大きさを一つのプロット図上に表示します。周波数ベクトル W はオプションです。
% 各モデルに対して、カラー、ラインスタイル、マーカを設定することもできます。 
% たとえば、
%   bodemag(sys1,'r',sys2,'y--',sys3,'gx') のようにします。
%
% 参考 : BODE, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
