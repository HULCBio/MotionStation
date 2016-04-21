% STRUCT2CELL   構造体配列をセル配列に変換
%
% C = STRUCT2CELL(S) は、(P個のフィールドをもつ)M行N列の構造体 S を、
% P×M×Nのセル配列 C に変換します。
%
% SがN次元の場合、Cのサイズは [P SIZE(S)] になります。
%
% 例題:
%     clear s, s.category = 'tree'; s.height = 37.4; s.name = 'birch';
%     c = struct2cell(s); f = fieldnames(s);
%
% 参考：CELL2STRUCT, FIELDNAMES.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:52 $
%   Built-in function.
