function add2hist(h,HistoryLine)
%ADD2HIST  Adds entry to history record.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:27 $

h.History = [h.History ; {HistoryLine}];  
