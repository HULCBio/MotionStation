%PPVAL  区分多項式の計算
% V = PPVAL(PP,XX) は、XX の要素で、PCHIP, SPLINE, または、スプライン
% ユーティリティ MKPP で構成されるように、PP に得られる区分多項式 f の
% 値を出力します。
%
% V は、XX の各要素をf の値で置き換えることにより得られます。
% f がスカラー値の場合、V は、XX と同じサイズです。 
% f が [D1,..,Dr]-値で、XX がサイズ [N1,...,Ns] をもつ場合、V は、XX(J1,...,Js) 
% での f の値、V(:,...,:, J1,...,Js) であり、サイズ[D1,...,Dr, N1,...,Ns]  
% をもちます。 -- つぎの場合は、除きます。 
%   (1)  1 および s が 2 の場合、N1 は無視されます。すなわち、XX が行ベクトル
%        であり、
%   (2) PPVAL は、XX の後に続く次元を無視します。
%
% V = PPVAL(XX,PP) は、FMINBND, FZERO, QUAD や他の関数を引数とする関数と
% 合わせて使用することも可能です。
%
% 例題:
% 関数 cos を使ったものと、spline 補間を使ったものの結果を比較します。
%
%     a = 0; b = 10;
%     int1 = quad(@cos,a,b,[],[]);
%     x = a:b; y = cos(x); pp = spline(x,y); 
%     int2 = quad(@ppval,a,b,[],[],pp);
%
% int1は区間 [a,b] で関数 cos を計算し、一方、int2 は計算した x,y の値を
% 内挿することで、同じ区間で関数 cos を近似して、区分多項式 pp を計算
% したものです。
%
% 入力 pp, xx のサポートクラス
%      float: double, single
%
% 参考 SPLINE, PCHIP, MKPP, UNMKPP, SPLINES (The Spline Toolbox).

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.
