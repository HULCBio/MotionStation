% ISVALID   timer オブジェクトが有効かどうかを判定
%
% OUT = ISVALID(OBJ) は、OBJ の要素が無効な timer オブジェクトであれば0を
% OBJ の要素が有効な timer オブジェクトであれば1を含む、論理配列 OUT を
% 出力します。
%
% 無効な timer オブジェクトは、削除されたオブジェクトで、再利用できません。
% ワークスペースから無効な timer オブジェクトを消去するには、CLEAR コマンド
% を使用してください。
%
% 例題:
%      % 有効な timer オブジェクトを作成します。
%      t = timer;
%      out1 = isvalid(t)
%
%      % timer オブジェクトを削除すると、無効になります。
%      delete(t)
%      out2 = isvalid(t)
%
% 参考 : TIMER/DELETE.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:42 $

