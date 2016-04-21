function output = get(obj,varargin)
%GET Get audiorecorder object properties.
%
%    GET(OBJ) displays all property names and their current values for
%    audiorecorder object OBJ.
%
%    V = GET(OBJ) returns a structure, V, where each field name is the
%    name of a property of OBJ and each field contains the value of that 
%    property.
%
%    V = GET(OBJ,'PropertyName') returns the value, V, of the specified 
%    property, PropertyName, for audiorecorder object OBJ. 
%
%    If PropertyName is a 1-by-N or N-by-1 cell array of strings 
%    containing property names, GET returns a 1-by-N cell array
%    of values.
%
%    Example:
%       r = audiorecorder(22050, 16, 1);
%       get(r)
%       record(r);
%       v = get(p,{'tag','TotalSamples'})
%       stop(r);
%
%    See also AUDIORECORDER, AUDIORECORDER/SET.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:00:29 $

if ~isa(obj,'audiorecorder')
    builtin('get',obj,varargin{:})
    return;
end

% Properties added in alphabetical order.
properties = {'BitsPerSample', ...
              'BufferLength', ...
              'CurrentSample', ...
              'DeviceID', ...
              'NumberOfBuffers', ...
              'NumberOfChannels', ...
              'Running', ...
              'SampleRate', ...
              'StartFcn', ...
              'StopFcn', ...
              'Tag', ...
              'TimerFcn', ...
              'TimerPeriod', ...
              'TotalSamples', ...
              'Type', ...
              'UserData'};

if ((nargout == 0) && (nargin == 1)) % e.g., "get(OBJ)"
    try
        % Set each field 
        for i = 1:length(properties)
            out.(properties{i}) = get(obj.internalObj, properties{i});
        end
        disp(out);
    catch % rethrow error from builtin get function
        lerr = fixlasterr;
        error(lerr{:});
    end
else % "r=get(t)" or "get(t,'PN',...)"
    try % calling builtin get
        output = get(obj.internalObj, varargin{:});
    catch
        lerr = fixlasterr;
        error(lerr{:});
    end
end
