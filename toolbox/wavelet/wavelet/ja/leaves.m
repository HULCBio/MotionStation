% LEAVES　 不連続ノード
%
% N = LEAVES(T) は、ツリー T の終端ノードのインデックスを含む列ベクトル
% N を出力します。
%
% ノードは、ツリー T において左から右へと順番付けられています。
%
% [N,K] = LEAVES(T,'s')、または、[N,K] = LEAVES(T,'sort') は、順番付け
% されたインデックスを出力します。M = N(K) は、ツリー T において、
% 左から右へと再び順番付けられたインデックスになります。
%
% N = LEAVES(T,'dp') は、不連続ノードの深さと位置から得られる行列 N を
% 出力します。
% N(i,1) は、不連続ノードの i 番目の深さです。
% N(i,2) は、不連続ノードの i 番目の位置です。
%
% [N,K] = LEAVES(T,'sdp')、または、[N,K] = LEAVES(T,'pds')、
% [N,K] = LEAVES(T,'sortdp')、[N,K] = LEAVES(T,'pdsort') は、順序付け
% されたノードを出力します。
%
% 参考： TNODES, NOLEAVES.


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Oct-96.
%   Copyright 1995-2002 The MathWorks, Inc.
