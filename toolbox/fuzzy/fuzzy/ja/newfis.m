% NEWFIS   新しいFISの作成
% 
% FIS = NEWFIS(FISNAME) は、新しい Mamdani スタイルのFIS構造体を作成しま
% す。
%
% FIS = NEWFIS(FISNAME,FISTYPE) は、FISNAME と名付けた Mamdani、または
% 菅野スタイルのシステム用の FIS 構造体を作成します。
% 
% FIS=NEWFIS(FISNAME, FISTYPE, andMethod, orMethod, impMethod, ...
%              aggMethod, defuzzMethod)
% はAND、OR、包含集合体、非ファジィ化法のメソッドを直接指定します。
%
% 参考    readfis, writefis


%   Kelly Liu 4-5-96 
%   Copyright 1994-2002 The MathWorks, Inc. 
