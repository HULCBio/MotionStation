% ASGNCHK   SUBSASGN に対する確認とインデックス化
%
% IND = ASGNCHK(IND,SIZES,DELFLAG,L) は、以下の役割を果たします。
% * 削除する部分(RHS = [], DELFLAG = 1)を設定するため、SUBSASGN のイン
%   デックス IND と LHS の次元 SIZES との互換性を確認します。
% * LHS の LTI の親 L の I/O チャンネルとグループ名を利用して、整数値の
%   添字を付けることによって、IND(1:2) に示すすべての名称の参照の置き
%   換えを行います。
%
% 参考 : SUBSASGN.


%   Author(s):  P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
