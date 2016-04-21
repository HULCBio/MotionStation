% IDARX は、IDARX モデル構造を作成します。
%       
%   M = IDARX(A,B,Ts)
%   M = IDARX(A,B,Ts,'Property',Value,..)
%
% ny出力、nu入力をもつ多変数 ARX モデルは、つぎのように表します。
%
%   A0*y(t)+A1*y(t-T)+ ... + An*y(t-nT) =
%	      '                 B0*u(t)+B1*u(t-T)+Bm*u(t-mT) + e(t) 
%	      
% A は、ny-ny-n のサイズの配列で、A(:,:,k+1) = Ak を表します。A0 = eye(ny)
% になるような正規化が必要です。B は、同様な ny-nu-m のサイズの配列です。
%   
% Ts は、サンプリング間隔です。
%
% IDARX プロパティの詳細情報は、SET(IDARX)、または、IDPROPS IDARX と入力
% して得られます。
%



%   Copyright 1986-2001 The MathWorks, Inc.
