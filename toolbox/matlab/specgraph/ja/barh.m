% BARH   水平バープロット
% 
% BARH(X,Y) は、M 行 N 列の行列 Y の列を、N 個の水平バーからなるM個の
% グループとして描画します。ベクトル X は、単調増加または単調減少で
% なければなりません。
%
% BARH(Y) は、デフォルト値 X = 1:M を使用します｡入力がベクトルの場合は、
% BARH(X,Y) または BARH(Y) は、LENGTH(Y) のバーを描画します。カラーは、
% カラーマップにより設定されます。
%
% BARH(X,Y,WIDTH)またはBARH(Y,WIDTH) は、バーの幅を指定します。WIDTH が
% 1よりも大きければ、バーは重ね書きされます。デフォルト値は、WIDTH = 0.8 
% です。
%
% BARH(...,'grouped') は、デフォルトのグループ化した垂直バープロットを
% 作成します。
% BARH(...,'stacked') は、1つのバーに各要素を積み重ねて、バープロットを
% 作成します。
% BARH(...,LINESPEC) は、指定したラインカラー('rgbymckw' のいずれか)を
% 使用します。
% 
% BARH(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = BARH(...) は、barシリーズオブジェクトのハンドル番号からなるベクトル
% を出力します。
%
% 下位互換性
% BARH('v6',...)は、MATLAB 6.5およびそれ以前のバージョンとの互換性のため
% barシリーズオブジェクトの代わりにpatchオブジェクトを作成します。
%
% バーのエッジを表示するには、SHADING FACETED を使用してください。
% エッジを消すには、SHADING FLAT を使用してください。
%
% 例題: 
%            subplot(3,1,1)、barh(rand(10,5),'stacked')、colormap(cool)
%            subplot(3,1,2), barh(0:.25:1,rand(5),1)
%            subplot(3,1,3), barh(rand(2,3),.75,'grouped')
%
% 参考： PLOT, BAR, BAR3, BAR3H.


%    Copyright 1984-2002 The MathWorks, Inc. 
