function str = xdocToString( obj,indent,stream )
%   Converts to String
%
%   This is the same as the DISPLAY method, but instead
%   of writing to a stream I construct a MATLAB string.
% 
%   I could have passed DISPLAY a Java stream as the 3rd input,
%   but didn't b/c Java streams don't have an fprintf method, and 
%   I can avoid calling Java for this alltogether.
%   
%   It would be nice to overload FPRINTF to handle Java streams.

% $Revision: 1.1.6.1 $  $Date: 2003/08/05 19:22:41 $
% Copyright 1984-2003 The MathWorks, Inc.

% LF = char(13); CR = char(10);
LF = []; CR = [];

if(nargin < 3)
    stream = 1;
    if(nargin < 2)
        indent = '';
    end
end

if nargin==1
    bufferStr([]);
end

% open the tag
bufferStr(stream,'%s<%s',indent,obj.tag);

% print attributes
for i = 1:length(obj.attributes)
    k = obj.attributes{i};
    bufferStr(stream,' %s="%s"',k{1},k{2});
end

if(isempty(obj.children) && isempty(obj.contents))
    %close the tag
    bufferStr(stream,['/>' LF CR],obj.tag);
else
    bufferStr(stream,['>' LF CR],obj.tag);
    
    for i = 1:length(obj.contents)
        content = obj.contents{i};
        bufferStr(stream,['%s%s' LF CR],[indent, ''],content);
    end
    
    %or display the children
    for i = 1:length(obj.children)
        child = obj.children{i};
        %display(child,[indent, '     '],stream);
        xdocToString(child,[indent, ''],stream);
    end
    %and close the tag
    bufferStr(stream,['%s</%s>' LF CR],indent,obj.tag);
end

%   Return the string, with trailing blanks removed.
str = deblank(bufferStr);

%===============================================================================
function str = bufferStr(varargin)

persistent completeString;
if isempty(completeString); completeString = ''; end

if nargin==0
    str = completeString(:).';
    return
elseif nargin==1 && isempty(varargin{1})
    completeString = '';
    return
else
    %   Call sprintf
    newString = sprintf(varargin{2:end});
    %   Grow the current string
    completeString = [completeString;newString(:)];
end
