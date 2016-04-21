% CSGDEL   最小領域間のボーダーセグメント(境界条件をもたない境界線)を削
% 除します。
%
% [DL1,BT1] = CSGDEL(DL,BT,BL) は、リスト BL のボーダセグメント(境界条件
% をもたない境界線)を削除します。リスト BL 内の要素によって、Decomposed 
% Geometry 行列の整合性が保存されないの場合、関連するボーダセグメントも
% 削除されます。
%
% DL と DL1 は、Decomposed Geometry 行列です。詳細は、DECSG を参照してく
% ださい。
% 
% BT と BT1 は、ブーリアンテーブルです。詳細は、DECSG を参照してください。
%
% [DL1,BT1] = CSGDEL(DL,BT) は、全てのボーダセグメントを削除します。
%
% 参考   DECSG



%       Copyright 1994-2001 The MathWorks, Inc.
