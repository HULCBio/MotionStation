% EYEDIAGRAM アイパターンの生成
% 
% EYEDIAGRAM(X, N) は、各トレースにつき N サンプルで、X のアイパターンを
% 生成します。N は1より大きい整数でなければなりません。X には、実数または
% 複素数のベクトルか、あるいは2列の行列（1列目が実数信号、2列目が虚数
% 信号）をとることができます。X が実数ベクトルの場合は、EYEDIAGRAM は
% 一つのアイパターンを生成します。X が2行の行列か複素数ベクトルの場合は、
% EYEDIAGRAM は2つのアイパターンを生成します。1つは実数（同相）信号で、
% もう1つは虚数（直交）信号についてのアイパターンです。EYEDIAGRAM は、
% 1番目の点とそれ以降の毎 N 番目の点を、横軸の中心に置くようにプロット
% します。
% 
% EYEDIAGRAM(X, N, PERIOD) は、指定したトレース周期で X のアイパターンを
% 生成します。PERIOD は横軸の範囲を決定するために使われます。PERIOD は
% 正の数でなければなりません。横軸の範囲は -PERIOD/2 から +PERIOD/2 と
% なります。PERIOD のデフォルト値は1です。
%
% EYEDIAGRAM(X, N, PERIOD, OFFSET) は、オフセットをつけて X のアイパターン
% を生成します。OFFSETは、横軸の中心点を、開始点とそれ以降の毎 N番目の点が
% (OFFSET+1) 番目となるように決定づけます。OFFSETは 0 <= OFFSET < N の
% 範囲の、非負の整数でなければなりません。OFFSET のデフォルト値は 0 です。
% 
% EYEDIAGRAM(X, N, PERIOD, OFFSET, PLOTSTRING) は、PLOTSTRING で記述された
% ラインタイプ、プロットシンボル、色で X のアイパターンを生成します。
% PLOTSTRING は PLOT 関数で使われる文字列を指定することができます。
% PLOTSTRING のデフォルト値は 'b-' です。
%
% H = EYEDIAGRAM(...) は、アイパターンを生成し、アイパターンをプロット
% するために使用したフィギュアのハンドルを返します。
%
% H = EYEDIAGRAM(X, N, PERIOD, OFFSET, PLOTSTRING, H) と
% EYEDIAGRAM(X, N, PERIOD, OFFSET, PLOTSTRING, H) は、フィギュアハンドル
% を使ってアイパターンを生成します。H は、EYEDIAGRAM によって前に生成さ
% れたフィギュアの、有効なハンドルでなければなりません。H のデフォルト値
% は [] で、この場合 EYEDIAGRAM は新規のフィギュアを作成します。HOLD 関
% 数は EYEDIAGRAM フィギュアに対しては機能しません。
%
% 参考： SCATTERPLOT, PLOT, SCATTEREYEDEMO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2003/06/23 04:34:28 $

