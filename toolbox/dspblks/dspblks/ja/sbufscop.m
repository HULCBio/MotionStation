% sbufscop   SimulinkのベクトルスコープS-Function
%
% sbufscop は、Handle Graphics Figure ウインドウ内の入力ベクトルをプロット
% する SIMULINK S-Function です。Figureは、Scope ブロックのフル名を使って、
% 名付けられ、タグが付けられます。
%
% 入力ベクトルは、サンプルデータのベクトル、または、周波数のベクトルとして
% 解釈されます。つぎの構文で使います。
% 
%    sbufscop(T,X,U,FLAG,SCALING,DOMAIN,FIGPOS,YLABELSTR,RADS)
% 
% 最初の4つの入力引数 T, X, U, FLAGは、Simulinkで必要な4つの入力引数です。
% 他の引数の説明を、つぎに示します。:
%	    SCALING は、X-軸の範囲の設定
%	    DOMAIN は、入力が時間領域か、周波数領域かの設定
%	    FIGPOS は、Scope Figureウインドウの位置を設定するピクセル単
%                      位で表わした位置を表わす長方形です。
%	    YLABELSTR は、Y-軸を設定する追加オプションの引数です。  
%                     デフォルトは、'Magnitude'です。
%	    RADS は、X-軸の単位を設定する追加オプションの引数です。 
%	              1 の場合、X-軸の単位はラジアンで、
%	              0(デフォルト) の場合、Hertz(Hz)になります。


%   7/22/94
%   Revised: T. Krauss 20-Sep-94, D. Orofino 1-Feb-97, S. Zlotkin 20-Feb-97
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.6.1 $  $Date: 2003/07/22 21:03:54 $
