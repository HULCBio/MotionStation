% SETFIELD   構造体フィールドの内容を設定
%
% S = SETFIELD(S,'field',V) は、値 V を指定したフィールドの内容として
% 設定します。これは、S.field = V の構文と等価です。S は、1×1 の構造体
% でなければなりません。変更された構造体が出力されます。
%
% S = SETFIELD(S,{i,j},'field',{k},V) は、
%       S(i,j).field(k) = V;
% の構文と等価です。
%
% 言い換えると、S = SETFIELD(S,sub1,sub2,...,V) は、構造体 S の内容を、
% サブスクリプトか、またはsub1,sub2,... で指定されるフィールドの参照を
% 使って V に設定します。括弧内のサブスクリプトの各設定は、セル配列で
% 囲まれ、また別々の入力として SETFIELD に渡されなければなりません。
% フィールドの参照は、文字列として渡されます。
%
% 参考: GETFIELD, RMFIELD, ISFIELD, FIELDNAMES.


%   Copyright 1984-2003 The MathWorks, Inc. 
