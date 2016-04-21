% FLATTOPWIN   Flat Top ウィンドウ
%
% FLATTOPWIN(N) は、N 点の対称な Flat Top ウィンドウを列ベクトルで返します。
% FLATTOPWIN(N,SFLAG) は、SFLAG のウィンドウサンプリングを用いてN 点の 
% Flat Top ウィンドウを生成します。SFLAG は、'symmetric' または 'periodic'
% です。デフォルトは、対称なウィンドウとして出力されます。
%
% 例題:
%    w = flattopwin(64); 
%    wvtool(w);
%
% 参考 :  BLACKMAN, HANN, HAMMING.

%   $Revision: 1.1 $  $Date: 2003/04/18 17:41:59 $

