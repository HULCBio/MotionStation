% function weight = fow(dcval,bw,ginf)
%
% つぎのプロパティをもつ安定な1次システムWEIGHTを作成します。
%
% WEIGHT(0) = dcval
% WEIGHT(inf) = ginf
% |WEIGHT(j*abs(bw))| = 1
%
% つぎのうちのいずれかでなければなりません。
%
% |dcval| < 1 < |ginf|
%  または
% |dcval| > 1 > |ginf|

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:30:30 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
