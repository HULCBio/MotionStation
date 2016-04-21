% FLOW   3変数からなる単純な関数
% 
% 3変数の関数FLOWは、無限タンク内の水中での噴出速度プロファイルです。
% FLOWは、SLICEとINTERP3のデモに役立ちます。
% 
% つぎのような呼び出し方法があります。
% 
%     V = FLOWは、50*25*25の配列を作成します。
%     V = FLOW(N)は、2N*N*Nの配列を作成します。
%     V = FLOW(X,Y,Z)は、点(X,Y,Z)での速度プロファイルを評価します。
%     [X,Y,Z,V] = FLOW(...)は、座標も出力します。


%   Reference: Fluid Mechanics, L. D. Landau and E. M. Lifshitz.
%   Copyright 1984-2002 The MathWorks, Inc. 
