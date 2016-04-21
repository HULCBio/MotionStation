% SCATTERPLOT   スキャタプロットの生成
%
% SCATTERPLOT(X) は、X のスキャタプロットを生成します。X は実数か複素数
% のベクトル、または2列の行列（1列目が実数信号、2列目が虚数信号）をとる
% ことができます。
%
% SCATTERPLOT(X, N) は、間引きファクタ N を使って X のスキャタプロットを
% 生成します。X の各 N 番目の点は、1番目の値でスタートし、プロットされます。
% N のデフォルトは 1 です。
%
% SCATTERPLOT(X, N, OFFSET) は、オフセットつきで X のスキャタプロットを
% 生成します。OFFSET は、プロット前に X の開始点をスキップするサンプル数
% です。OFFSET のデフォルト値はゼロです。
%
% SCATTERPLOT(X, N, OFFSET, PLOTSTRING) は、PLOTSTRING によって記述され
% たラインタイプ、プロットシンボル、色で、X のスキャタプロットを生成します。
% PLOTSTRING は PLOT 関数で使われる文字列を指定できます。PLOTSTRING の
% デフォルトは、'b.' です。
%
% H = SCATTERPLOT(...) は、スキャタプロットを生成し、生成したスキャタ
% プロットが使用するフィギュアのハンドルを返します。
%
% H = SCATTERPLOT(X, N, OFFSET, PLOTSTRING, H) と
% SCATTERPLOT(X, N, OFFSET, PLOTSTRING, H) は、ハンドル H によって示された
% フィギュアを使って、スキャタプロットを生成します。H は前に SCATTERPLOT 
% によって生成されたフィギュアを示す、有効なハンドルでなければなりません。
% H のデフォルトは [] で、SCATTERPLOT は新しいフィギュアを作成します。
%
% 参考:   EYEDIAGRAM, PLOT, SCATTEREYEDEMO, SCATTER.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2003/06/23 04:35:17 $
