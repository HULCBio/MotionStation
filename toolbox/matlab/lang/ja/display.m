% DISPLAY   配列の表示
% 
% DISPLAY(X) は、ステートメントの末尾にセミコロンが使用されていないときに
% オブジェクト X に対して呼び出されます。
%
% たとえば、
% 
%   X = inline('sin(x)')
% 
% は、DISPLAY(X) を呼び出し、一方
% 
%   X = inline('sin(x)');
% 
% は、呼び出しません。
%
% DISPLAY の典型的な実現では、その作業のほとんどは DISP を呼び出すこと
% で、つぎのようになります。DISP は、空配列を表示しないことに注意して
% ください。
%
%      function display(X)
%      if isequal(get(0,'FormatSpacing'),'compact')
%         disp([inputname(1) ' =']);
%         disp(X)
%      else
%         disp(' ')
%         disp([inputname(1) ' =']);
%         disp(' ');
%         disp(X)
%      end
%   
% 参考：INPUTNAME, DISP.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:50 $
%   Built-in function.
