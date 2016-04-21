% COMPASS   コンパスプロット
% 
% COMPASS(U,V) は、ベクトルの成分 (U,V) を、原点からの放射状の矢印として
% 表示するグラフを描画します。
%
% COMPASS(Z) は、COMPASS(REAL(Z),IMAG(Z)) と等価です。
%
% COMPASS(U,V,LINESPEC) と COMPASS(Z,LINESPEC) は、ラインの仕様
% LINESPECを使います(可能な値については、PLOT を参照)。
%
% COMPASS(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = COMPASS(...) は、lineオブジェクトのハンドル番号を出力します。
%
% 参考：ROSE, FEATHER, QUIVER.


%   Charles R. Denham, MathWorks 3-20-89
%   Modified, 1-2-92, LS.
%   Modified, 12-12-94, cmt.
%   Copyright 1984-2002 The MathWorks, Inc. 
