% BAR   バープロット
% 
% BAR(X,Y) は、M 行 N 列の行列 Y の列を、N 個の垂直バーからなる M 個の
% グループとして描画します。ベクトル X は、単調増加または単調減少でなけ
% ればなりません。
%
% BAR(Y) は、デフォルト値 X = 1:M を使用します。入力がベクトルの場合は、
% BAR(X,Y) または BAR(Y) は、LENGTH(Y) のバーを描画します。カラーは、
% カラーマップにより設定されます。
%
% BAR(X,Y,WIDTH) または BAR(Y,WIDTH) は、バーの幅を設定します。WIDTH が
% 1よりも大きければ、バーは重ね書きされます。デフォルト値は、WIDTH = 0.8 
% です。
%
% BAR(...,'grouped') は、デフォルトのグループ化した垂直バープロットを
% 作成します。
% BAR(...,'stacked') は、1つのバーに各要素を積み重ねて、バープロットを
% 作成します。
% BAR(...,LINESPEC) は、指定したラインカラー('rgbymckw' のいずれか)を
% 使用します。
%
% BAR(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = BAR(...) は、barシリーズオブジェクトのハンドル番号からなるベクトル
% を出力します。
%
% バーのエッジを表示するには、SHADING FACETED を使用してください。
% エッジを消すには、SHADING FLAT を使用してください。
%
% 例題:  
% 　　　　　　subplot(3,1,1), bar(rand(10,5),'stacked'), colormap(cool)
%             subplot(3,1,2), bar(0:.25:1,rand(5),1)
%             subplot(3,1,3), bar(rand(2,3),.75,'grouped')
%
% 参考： HIST, PLOT, BARH, BAR3, BAR3H.


%    C.B Moler 2-06-86
%    Modified 24-Dec-88, 2-Jan-92 LS.
%    Modified 8-5-91, 9-22-94 by cmt; 8-9-95 WSun.
%    Copyright 1984-2002 The MathWorks, Inc. 
