function [result] = getlog(xpcObj, logName, start, numPoints, interleave)
% GETLOG Get (part of) any of the various logs returned by the simulation
%
%   GETLOG(XPCOBJ, LOGNAME, START, NUMPOINTS, INTERLEAVE) uploads one of the
%   logs TimeLog, StateLog, OutputLog or TETLog, which are properties of the
%   xPC object XPCOBJ. Unlike the result obtained with the GET command, part
%   of a log can also be uploaded, which saves time if a slow link is
%   present. LOGNAME can be one of 'TimeLog', 'StateLog', 'OutputLog', or
%   'TETLog' (same as the fields of XPCOBJ). Partial but unambiguous names are
%   acceptable. START, NUMPOINTS and INTERLEAVE specify the starting point,
%   number of points and the interleave (or decimation) of the points. If none
%   of these are specified, the whole log is returned. XPCOBJ and LOGNAME are
%   mandatory.
%
%   GETLOG(XPCOBJ, LOGNAME, START) returns only sample number START.
%   GETLOG(XPCOBJ, LOGNAME, START, NUMPOINTS) returns NUMPOINTS samples
%   starting at START, with an interleave of 1.
%
%   The first point is numbered 1 (not 0).
%   
%   GETLOG can only be used for a scalar XPCOBJ.
%
%   See also GET.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/03/25 04:17:06 $

if (nargin < 2),        error('GETLOG expects at least two arguments'); end
if ~isa(xpcObj, 'xpc'), error('First argument MUST be a xPC object');   end

if (length(xpcObj) > 1)
  error('Vectors of xPC objects cannot be used in GETLOAD');
end

try, xpcObj = sync(xpcObj); catch, error(xpcgate('xpcerrorhandler')); end

if strcmpi(xpcObj.Application, 'loader'), error('No application loaded'); end
if strcmpi(xpcObj.Status, 'running'), error('Stop the simulation first'); end

propname = xpcObj.prop.propname;
logNames = propname(19 : 22); % TimeLog, StateLog, OutputLog, TETLog
logFuncs = {'gettime', 'getstate', 'getoutp', 'gettet'};

index    = strmatch(lower(logName), lower(logNames));
% is index uniquely defined?
if isempty(index),      error([logName, ': Invalid log name.']);   end
if (length(index) > 1), error([logName, ': Ambiguous log name.']); end

funcName = logFuncs{index}; 

try
  switch nargin
   case 2, result = xpcgate(funcName);	
   % Private funcs use zero-based indexing: hence (start - 1)
   case 3, result = xpcgate(funcName, start - 1);
   case 4, result = xpcgate(funcName, start - 1, numPoints);
   case 5, result = xpcgate(funcName, start - 1, numPoints, interleave);
  end % switch nargin
catch
  error(xpcgate('xpcerrorhandler'));
end % try

%% EOF getload.m

