% CMDISPATCH Call は、ソースコントロール関数です。
% 
% CMDISPATCH(COMMAND, FILE) は、FILE にCOMMAND を適用します。FILE が
% 数字の場合、Stateflowマシンの id になるので、変換してください。
% 他の場合、正しい型でのファイル仕様を与えてください。
% 
% CMDISPATCH(COMMAND, FILE, DIRTY) は、DIRTY フラグを使って、FILE に
% COMMAND を適用します。
% 
% CMDISPATCH は、SimulinkとStateflowのみに機能します。
%
% 大部分のエラーは、ここで取り扱われますが、それ以外はここでは拒否されます。
% 
% 参考 ： CHECKIN, CHECKOUT, UNDOCHECKOUT.


% Copyright 1998-2002 The MathWorks, Inc.
