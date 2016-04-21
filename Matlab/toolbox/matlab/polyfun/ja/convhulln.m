%CONVHULLN N-次元の凸包
% K = CONVHULLN(X) は、X の凸包の面を構成する X の中の点のインデックス 
% K を出力します。X は、n-次元の空間に位置する m 点を表わすm 行 n 列の
% 配列です。凸包がp 面をもつ場合は、K は p 行 n 列になります。
%
% CONVHULLN は、Qhull を使用します。
%
% K = CONVHULLN(X,OPTIONS) は、Qhull のオプションとして使用されるように、
% 文字列 OPTIONS のセル配列を指定します。デフォルトのオプションは、
% つぎのものです。
%     2D, 3D および 4D 入力に対して、{'Qt'}  
%     5D および より高次の入力に対して、{'Qt','Qx'} 
% OPTIONS が [] の場合、デフォルトのオプションが使用されます。
% OPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
% Qhull とそのオプションについての詳細は、http://www.qhull.org. を
% 参照してください。
%
% [K,V] = CONVHULLN(...) は、V に凸包の体積を出力します。
%
% 例題:
%     X = [0 0; 0 1e-10; 0 0; 1 1];
%     K = convhulln(X)
%   は、追加オプション 'Pp' によりワーニングを非表示にします。
%     K = convhulln(X,{'Qt','Pp'})
%
% 参考 CONVHULL, QHULL, DELAUNAYN, VORONOIN, TSEARCHN, DSEARCHN.

%   Copyright 1984-2003 The MathWorks, Inc. 
