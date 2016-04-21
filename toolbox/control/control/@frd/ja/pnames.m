% PNAMES   すべてのプロパティと設定可能な値
%
% [PROPS,ASGNVALS] = PNAMES(SYS) は、FRDオブジェクト SYS の公開プロパティ
% のリスト PROPS とこれらのプロパティに対して設定可能な値 ASGNVALS を
% 出力します。PROPSと ASGNVALS は、共に文字列のセルベクトルです。PROPS 
% は親プロパティも含めて、実際に、大文字、小文字を区別したプロパティ名の
% リストです。
%
% [PROPS,ASGNVALS] = PNAMES(SYS,'specific') は、SYS のFRD指定公開プロ
% パティのみを出力します。
% 
% 参考 : GET, SET.


%       Author(s): S. Almy, 3-1-98, P. Gahinet, 7-8-97
%       Copyright 1986-2002 The MathWorks, Inc. 
