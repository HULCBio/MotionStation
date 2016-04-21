% ELLIPKE   完全楕円積分
%
% [K,E] = ELLIPKE(M) は、M の各要素に対して実行される第1種と第2種の完全
% 楕円積分の値を出力します。現在、実現されているバージョンでは、M は 
% 0 < =  M < =  1に制限されています。
% 
% [K,E] = ELLIPKE(M,TOL) は、デフォルトの TOL = EPS の代わりに、精度 
% TOL で完全楕円積分を計算します。
%
% ヤコビアン楕円関数の定義によっては、パラメータ m の代わりに母数 k を
% 使うことがあります。これらは、m = k^2 という関係です。
%
% 参考：ELLIPJ.


%   L. Shure 1-9-88
%   Modified to include the second kind by Bjorn Bonnevier
%   from the Alfven Laboratory, KTH, Stockholm, Sweden
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:06 $
