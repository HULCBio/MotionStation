% ISVALID   デバイスに接続可能な serial port オブジェクトかどうかを判定
%
% OUT = ISVALID(OBJ) は、論理配列 OUT を出力します。これは、OBJ の要素が、
% 削除された serial port オブジェクトなら0、有効な serial port オブジェクト
% の要素なら1になります。
%
% 有効でない serial port オブジェクト (オブジェクトが削除されている) 
% は、デバイスに接続できません。有効でないserial port オブジェクトは、
% CLEAR を使ってワークスペースから消去してください。
%
% 例題:
%      % 有効な serial port オブジェクトを作成します。
%      s = serial('COM1');
%      out1 = isvalid(s)
%
%      % serial port を削除し、無効にします。
%      delete(s)
%      out2 = isvalid(s)
%
% 参考 : SERIAL/DELETE.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
