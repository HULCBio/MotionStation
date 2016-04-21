% STRUCT   構造体配列の作成または変換
%
% S = STRUCT('field1',VALUES1,'field2',VALUES2,...) 指定したフィールド
% と値をもつ構造体配列を作成します。値の配列VALUES1、VALUES2...は、同じ
% サイズのセル配列か、スカラのセルまたは単一の値でなければなりません。
% 値の配列の対応する要素は、対応する構造体配列の要素に設定されます。
% 結果の構造体のサイズは、値のセル配列と同じか、値がセルでなければ、
% 1行1列になります。
%
% STRUCT(OBJ) は、オブジェクトOBJを等価な構造体に変換します。クラスの
% 情報は失われます。
%
% STRUCT([]) は、空の構造体を作成します。
%
% セル配列を含むフィールドを作成するには、セル配列VALUEの中にセル配列を
% 置いてください。たとえば
%
%     s = struct('strings',{{'hello','yes'}},'lengths',[5 3])
%
% は、 つぎのような1x1の構造体を作成します。
%
%      s = 
%         strings: {'hello'  'yes'}
%         lengths: [5 3]
%
% 例題
%      s = struct('type',{'big','little'},'color','red','x',{3 4})
%
% 参考: ISFIELD, GETFIELD, SETFIELD, RMFIELD, FIELDNAMES, DEAL, 
%       SUBSTRUCT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:47:51 $
%   Built-in function.

