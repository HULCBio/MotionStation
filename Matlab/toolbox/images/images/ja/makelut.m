% MAKELUT   関数 APPLYLUT で使用するルックアップテーブルを作成
%   LUT = MAKELUT(FUN,N) は、関数 APPLYLUT で使用するルックアップテー
%   ブルを出力します。FUN は、入力として1と0から構成される2行2列、また
%   は、3行3列の行列を受け入れ、スカラを出力する関数です。N は、2、ま
%   たは、3のどちらかです。MAKELUT は、2行2列、または、3行3列の近傍を 
%   FUN に渡して、LUT を作成し、一度に16要素（2行2列の近傍）または、
%   512要素（3行3列の近傍）ベクトルを作成します。ベクトルは、各可能な
%   近傍に対し、FUN からの出力を使います。
%
%   LUT = MAKELUT(FUN,N,P1,P2,...) は、付加的なパラメータ P1,P2,... を
%   FUN に転送します。
%
%   FUN は、@ を使って作成される FUNCTION_HANDLE か、または、INLINE オ
%   ブジェクトです。
%
%   クラスサポート
% -------------
%   LUT は、クラス double のベクトルとして出力されます。
%
%   例題
%   ----
%       f = inline('sum(x(:)) >= 2');
%       lut = makelut(f,2);
%
%   参考：APPLYLUT, FUNCTION_HANDLE, INLINE



%   Copyright 1993-2002 The MathWorks, Inc.  
