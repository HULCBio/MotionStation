% MAKEBARS   バーグラフのためのデータの作成
% 
% [MSG,X,Y,XX,YY,LINETYPE,PLOTTYPE,BARWIDTH,EQUAL] = MAKEBARS(X,Y) は、
% オリジナルのデータ値 X と Y、BARxx m-ファイル(BAR、BARH、BAR3、BAR3H)
% のうちの1つを使って、プロットされる書式付きデータ値 XX と YY を出力
% します。
% 
% LINETYPE は、プロットに対して希望するカラーを出力します。
% PLOTTYPE は、プロットがグループ化されるか(PLOTTYPE = 0)、スタックされ
% るか(PLOTTYPE = 1)、分離されるか(PLOTTYPE = 2-3次元プロットのみ)を
% 指定します。BARWIDTH は、(1に正規化された)バーの幅です。
%
% [MSG,X,Y,XX,YY,LINETYPE,PLOTTYPE,BARWIDTH,ZZ] = MAKEBARS(X,Y) は、
% 上記と同様ですが、最後のパラメータ ZZ は、3次元プロット BAR3 と
% BAR3H で使用されるz軸のデータです。
%
% [...] = MAKEBARS(X,Y,WIDTH) または MAKEBARS(Y,WIDTH) は、WIDTH で
% 与えられる幅を出力します。デフォルトは0.8です。
% [...] = MAKEBARS(...,'grouped') は、情報がグループ化されてプロット
% されるような書式で、データを出力します。
% [...] = MAKEBARS(...,'detached') {3次元のみ}は、情報が別々にプロット
% されるように、データを出力します。
% [...] = MAKEBARS(...,'stacked') は、情報がスタックされる書式でプロット
% されるように、データを出力します。
% [...] = MAKEBARS(...,'hist') は、可変の幅のbinを出力します。
% [...] = MAKEBARS(...,'histc') は、エッジに触れるバーを作成します。
% 
% データの間隔が等しければ、EQUAL は真です。そうでなければ偽です。
% plottype が 'hist' と 'histc' 以外のとき、EQUAL は常に真です。
%
% 参考：HIST, PLOT, BAR, BARH, BAR3, BAR3H.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:22 $
