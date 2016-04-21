% TLC   TLCHANDLE をもつ代わりのシンタックスの要求
%
% TLC(ACTION,H,ARGUMENTS) は、H がTLCHANDLEオブジェクトの場合、
% tlcコンテキストとして機能するための代わりのシンタックスです。
% 有効なシンタックスは以下のとおりです。
%
%   TLC('read',h,FILENAME)
%   TLC('execfile',H,FILENAME)
%   TLC('execstring',H,STRING)
%   TLC('execcmdline',H,STRINGS)
%   TLC('query',H,EXPRESSION)
%   TLC('get',h,NAME)
%   TLC('set',h,NAME,VALUE)
%   TLC('close',h)
%   TLC('startprofiler',h)
%   TLC('stopprofiler',h)
%   TLC('resumeprofiler',h)
%   TLC('clearprofiler',h)
%   TLC('histprofiler',h,BOOLEAN)
%   PROFILERHANDLE=TLC('getprofiler',h)
%
% 参考 : TLC SERVER, TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
