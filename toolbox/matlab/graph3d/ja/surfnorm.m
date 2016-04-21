% SURFNORM   サーフェスの法線
% 
% [Nx,Ny,Nz] = SURFNORM(X,Y,Z) は、成分 (X,Y,Z) をもつサーフェスに対して、
% 3次元の法線の成分を出力します。法線は、長さ1に正規化されています。
%
% [Nx,Ny,Nz] = SURFNORM(Z) は、サーフェス Z に対するサーフェスの法線の
% 成分を出力します。
%
% 左側の引数がない SURFNORM(X,Y,Z) または SURFNORM(Z) は、サーフェス
% とそこから生じる法線をプロットします。
%
% SURFNORM(AX,...) は、GCA ではなく AX にプロットします。
%
% SURFNORM(...,'PropertyName',PropertyValue,...) は、指定したサーフェス
% プロパティの値を設定するために使います。複数のプロパティを1つのステート
% メントで設定することができます。
%
% 出力されるサーフェスの法線は、データのbicubic近似を基にしています。
% 法線の方向を反対にするためには、SURFNORM(X',Y',Z') を使ってください。


% Clay M. Thompson  1-15-91
% Revised 8-5-91, 9-17-91 by cmt.
% Copyright 1984-2002 The MathWorks, Inc. 
