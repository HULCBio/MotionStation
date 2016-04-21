function output = timerfindall(varargin)
%TIMERFINDALL Find all timer objects with specified property values.
%
%   OUT = TIMERFINDALL returns all timer objects that exist in memory
%   regardless of the object's ObjectVisibility property value. The timer
%   objects are returned as an array to OUT.
%
%   OUT = TIMERFINDALL('P1', V1, 'P2', V2,...) returns an array, OUT, of
%   timer objects whose property names and property values match those
%   passed as param-value pairs, P1, V1, P2, V2,... The param-value pairs
%   can be specified as a cell array.
%
%   OUT = TIMERFINDALL(S) returns an array, OUT, of timer objects whose
%   property values match those defined in structure S whose field names 
%   are timer object property names and the field values are the requested
%   property values.
%   
%   OUT = TIMERFINDALL(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%   matching param-value pairs to the timer objects listed in OBJ.  OBJ can
%   be an array of timer objects.
%
%   Note that it is permissible to use param-value string pairs, structures,
%   and param-value cell array pairs in the same call to TIMERFINDALL.
%
%   When a property value is specified, it must use the same format as
%   GET returns. For example, if GET returns the Name as 'MyObject',
%   TIMERFINDALL will not find an object with a Name property value of
%   'myobject'. However, properties which have an enumerated list data type
%   will not be case sensitive when searching for property values. For
%   example, TIMERFINDALL will find an object with a Parity property value
%   of 'FixedRate' or 'fixedrate'. 
%
%    Example:
%      t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%      t2 = timer('Tag', 'displayProgress');
%      out1 = timerfindall('Tag', 'displayProgress')
%      out2 = timerfindall({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
%    See also TIMERFIND, TIMER/GET.
%

%    RDD 11-20-2001
%    Copyright 2001-2003 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:07:32 $

if isa(varargin{1}, 'timer')
    % Check to see if the given object is all invalid
    if all(~isvalid(varargin{1}))
        error('MATLAB:timer:invalid',timererror('MATLAB:timer:invalid'));
    end
    jobjs = varargin{1}.jobject;
    % set the remaining 
    findparam = {varargin{2:end}};
else
    p = findpackage('mltimer');
    if isempty(p)
        % no package dictionary exists
        output = [];
        return;
    end
    % Final all the timer objects in the database
    jobjs = find(p.DefaultDatabase);
    if length(jobjs)<2 % first found jobjs is the database, so length of 1 means no timers found 
        % e.g., no timer object found
        output = [];
        return;
    end 
    % first found jobjs is the database, so remove it now.
    jobjs = jobjs(2:end); 
    findparam = varargin;
end

% call find on the java objects
try
    allObjs = find(jobjs,findparam);
catch
    rethrow(lasterror);
end

% is nothing found, return empty set, otherwise return the timer object.
if (isempty(allObjs))
    output = [];
else
    output = timer(allObjs);
end
