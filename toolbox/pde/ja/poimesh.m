% POIMESH   長方形の形状上に等間隔のメッシュを描画します。
% [P,E,T] = POIMESH(G,NX,NY) は、G によって設定された長方形の形状上で、
% "xエッジ"を NX 片に分割し、"yエッジ"を NY 片に分割して、(NX+1)*(NY+1) 
% の交点をもつ長方形のメッシュを構成します。
%
% "x エッジ"は、x 軸で作る角度が最も小さいものです。
%
% [P,E,T] = POIMESH(G,N) は、NX = NY = N を使い、[P,E,T] = POIMESH(G) は、
% NX = NY = 1 を使います。
%
% POISOLV の高速実行のために、NX と NY の大きい方は、2のベキ乗であるべき
% です。
%
% Gが長方形の形状データでなければ、Pはゼロを表示します。
%
% 参考   INITMESH, POISOLV



%       Copyright 1994-2001 The MathWorks, Inc.
