%DSEARCHN N-次元最近傍点のサーチ
% K = DSEARCHN(X,T,XI) は、XI の中の各点に対する X の最近傍点のインデックス
% K を出力します。X は、n次元空間で p 点を表わす p 行 n 列の行列です。
% XI もp 行 n 列の行列で、n次元空間 のp 点を表わします。T は、numt行 n+1列
% の行列で、DELAUAYN で作成されるデータ X の分割です。出力 K は、長さ p 
% の列ベクトルです。
%
% K = DSEARCHN(X,T,XI,OUTVAL) は、点が凸包の中に存在する限り、XI の中
% の各点に対して、X に最近傍点のインデックス K を戻します。XI(J,:) が
% 凸包の外に位置する場合は、K(J) は、スカラのdouble 値である OUTVAL を
% 割り当てます。Inf が、OUTVAL に使われる場合が多いです。OUTVAL が[]の
% 場合は、K は、K = DSEARCHN(X,T,XI) と同じです。
%
% K = DSEARCHN(X,T,XI,OUTVAL,COPTIONS) は、CONVHULLN により Qhull の
% オプションとして使用されるように、文字列のセル配列 COPTIONS を
% 指定します。
% OPTIONS が [] の場合、デフォルトの CONVHULLN オプションが使用されます。  
% COPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
% 
% K = DSEARCHN(X,T,XI,OUTVAL,COPTIONS,DOPTIONS) は、DELAUNAYN により 
% Qhull のオプションとして使用されるように、文字列 DOPTIONS のセル配列
% を指定します。
% DOPTIONS が [] の場合、デフォルトの DELAUNAYN オプションが使用されます。
% DOPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
%  
% K = DSEARCHN(X,XI) は、分割を使わないで、サーチを行います。
% 大きな X と小さな XI を使う場合に、このアプローチは速くなり、メモリの
% 使用が少なくなります。
%
% [K,D] = DSEARCHN(X,...) は、最近傍点までの距離 D に出力します。D は、
% 長さ p の列ベクトルです。
%
% 参考 TSEARCH, DSEARCH, TSEARCHN, QHULL, GRIDDATAN, DELAUNAYN,
%      CONVHULLN.

%   Relies on the MEX file tsrchnmx to do most of the work.

%   Copyright 1984-2003 The MathWorks, Inc.
