function output = get(obj,varargin)
%GET Get audioplayer object properties.
%
%    GET(OBJ) displays all property names and their current values for
%    audioplayer object OBJ.
%
%    V = GET(OBJ) returns a structure, V, where each field name is the
%    name of a property of OBJ and each field contains the value of that 
%    property.
%
%    V = GET(OBJ,'PropertyName') returns the value, V, of the specified 
%    property, PropertyName, for audioplayer object OBJ. 
%
%    If PropertyName is a 1-by-N or N-by-1 cell array of strings 
%    containing property names, GET returns a 1-by-N cell array
%    of values.
%
%    Example:
%       load handel;
%       p = audioplayer(y,Fs);
%       get(p)
%       get(p,'Tag')
%       v = get(p,{'tag','deviceID'})
%
%    See also AUDIOPLAYER, AUDIOPLAYER/SET.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:11 $

if ~isa(obj,'audioplayer')
    builtin('get',obj,varargin{:})
    return;
end

% Properties added in alphabetical order.
properties = {'BitsPerSample', ...
              'CurrentSample', ...
              'DeviceID', ...
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
