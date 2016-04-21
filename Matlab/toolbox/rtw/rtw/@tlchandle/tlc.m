function varargout=tlc(action,h,varargin)
%TLC allows alternate syntax with TLCHANDLE
%   TLC(ACTION,H,ARGUMENTS) is an alternate syntax
%   for working with tlc contexts where H is a
%   TLCHANDLE object.  Valid syntax:
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
%   See also: TLC SERVER, TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/10 17:56:45 $

varargout=tlc(action,h.Handle,varargin{:});
