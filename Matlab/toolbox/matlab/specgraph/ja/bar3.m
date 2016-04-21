% BAR3   3次元バープロット
% 
% BAR3(Y,Z) は、M 行 N 列の行列 Z の列を、垂直3次元バープロットとして
% 描画します。ベクトル Y は、単調増加または単調減少でなければなりません。 
%
% BAR3(Z) は、デフォルト値 Y = 1:M を使用します。入力がベクトルの場合は、
% BAR3(Y,Z) または BAR3(Z) は、LENGTH(Z) のバーを描画します。カラーは、
% カラーマップにより設定されます。
%
% BAR3(Y,Z,WIDTH) または BAR3(Z,WIDTH) は、バーの幅を指定します。
% WIDTH が1よりも大きければ、バーは重ね書きされます。デフォルト値は、
% WIDTH = 0.8 です。
%
% BAR3(...,'detached') は、デフォルトの分離したバープロットを作成します。
% BAR3(...,'grouped') は、グループ化したバープロットを作成します。
% BAR3(...,'stacked') は、1つのバーに各要素を積み重ねて、バープロットを
% 作成します。
% BAR3(...,LINESPEC) は、指定したラインカラー('rgbymckw' のいずれか)を
% 使用します。
%
% BAR3(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = BAR3(...) は、surfaceオブジェクトのハンドル番号からなるベクトルを
% 出力します。
%
% 例題:
%       subplot(1,2,1), bar3(peaks(5))
%       subplot(1,2,2), bar3(rand(5),'stacked')
%
% 参考：BAR, BARH, BAR3H.


%   Mark W. Reichelt 8-24-93
%   Revised by CMT 10-19-94, WSun 8-9-95
%   Copyright 1984-2002 The MathWorks, Inc.
