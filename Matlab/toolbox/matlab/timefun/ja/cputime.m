% CPUTIME   CPU経過時間(秒単位)
% 
% CPUTIME は、MATLABを起動してから、MATLABプロセスが使用した総CPU時間
% を秒単位で出力します。
%
% たとえば、
%
%     t = cputime; your_operation; cputime-t
%
% は、your_operation の実行に使われたCPU時間を出力します。
% 
% 出力値は、内部表現をオーバフローすると、巻き戻される場合があります。
%
% 参考：ETIME, TIC, TOC, CLOCK


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:07:23 $
%   Built-in function.
