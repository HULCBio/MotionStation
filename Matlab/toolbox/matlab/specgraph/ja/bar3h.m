% BAR3H   水平3次元バープロット
% 
% BAR3H(Y,Z) は、M 行 N 列の行列 Z の列を、水平3次元バーとして描画します。
% ベクトル Y は、単調増加または単調減少でなければなりません。
%
% BAR3H(Z) は、デフォルト値 Y = 1:M を使用します。入力がベクトルの場合、
% BAR3H(Y,Z) または BAR3H(Z)は、LENGTH(Z) のバーを描画します。カラーは
% カラーマップにより設定されます。
%
% BAR3H(Y,Z,WIDTH) または BAR3(Z,WIDTH) は、バーの幅を設定します。
% WIDTH が1よりも大きければ、バーは重ね書きされます。デフォルト値は、
% WIDTH = 0.8 です。
%
% BAR3H(...,'detached') は、デフォルトの分離したバープロットを作成します。
% BAR3H(...,'grouped') は、グループ化したバープロットを作成します。
% BAR3H(...,'stacked') は、1つのバーに各要素を積み重ねて、バープロットを
% 作成します。
% BAR3H(...,LINESPEC) は、指定したラインカラー('rgbymckw' のいずれか)を
% 使用します。
%
% BAR3H(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = BAR3H(...) は、surfaceオブジェクトのハンドル番号からなるベクトルを
% 出力します。
% 
% 例題:
%       subplot(1,2,1), bar3h(peaks(5))
%       subplot(1,2,2), bar3h(rand(5),'stacked')
%
% 参考：BAR, BARH, BAR3.


%   Mark W. Reichelt 8-24-93
%   Revised by CMT 10-19-94, WSun 8-9-95
%   Copyright 1984-2002 The MathWorks, Inc. 
