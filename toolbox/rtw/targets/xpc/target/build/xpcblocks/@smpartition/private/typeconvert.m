function [y,nb] = typeconvert(S,x)
% TYPECONVERT - type conversion routine
%  INX=TYPECONVERT(STR) returns an index for the specified string which 
%  describes the data type.  The returned index is used to refer to this
%  type for the s-function.  If the type string is illegal, this function
%  returns [].  
%    
%  STR=TYPECONVERT(INX) returns a string label that corresponds to INX,
%  which is an internal index used by the s-function.  An illegal INX will
%  cause STR to be an empty string: ''.
%
%  [STR,NB]=TYPECONVERT(INX)
%  [INX,NB]=TYPECONVERT(STR) same as above, but also returns the size in
%  bytes of the specified type
%
%    Type      Size     TypeID
%             (Bytes)
%   'double'     8       0
%   'single'     4       1
%   'int8'       1       2
%   'uint8'      1       3
%   'int16'      2       4
%   'uint16'     2       5
%   'int32'      4       6
%   'uint32'     4       7
%   'boolean'    1       8
%
%  (etc)
%

% Copyright 2004 The MathWorks, Inc.

alltypes =  {'double','single','int8','uint8','int16','uint16','int32','uint32','boolean'};
bytestypes = [      8,       4,    1,       1,      2,      2,       4,       4         1];
if ischar(x),
    y = strmatch(x,alltypes);
    if nargout >= 2,
        if isempty(y),    
           nb = [];
        else
           nb = bytestypes(y);
        end
    end
    y = y-1;    
elseif isnumeric(x)
    try
       y = alltypes{x+1};
    catch
        y = [];
    end
    if nargout >= 2,
        if isempty(y),    
           nb = [];
        else
           nb = bytestypes(x+1);
        end
    end
else
    error('TYPECONVERT only accepts strings or integers');
end


