% RETURN   呼び出し関数に戻ります
% 
% RETURN は、呼び出し関数またはキーボードに状態を戻します。また、
% KEYBOARDモードを終了します。
%
% 通常、関数の最後に到達したときに呼び出し関数に戻ります。RETURNステー
% トメントを使って、途中で強制的に呼び出し関数に戻ることができます。
%
% 例題
%      function d = det(A)
%      if isempty(A)
%         d = 1;
%         return
%      else
%        ...
%      end
%
% 参考：FUNCTION, KEYBOARD, BREAK, CONTINUE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:28 $
%   Built-in function.
