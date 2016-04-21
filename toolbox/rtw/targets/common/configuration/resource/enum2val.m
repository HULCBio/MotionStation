function idx = enum2val(type,enum)
%ENUM2VAL  Converts an enumerated string to it's numerical equivalent.
% 
% idx = enum2val(type, enum)
%
% -- Arguments ---
%
%   type    -   A string indicating the enumeration class to look up
%   enum    -   A string representing the enumeration value to lookup
%
% -- Returns   ---
%
%   An integer representing the numerical equivalent of the enumeration
%   string.
%
% -- Example ---
%
%   v = enum2val('color','red');
%
    
%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $
%   $Date: 2004/04/19 01:21:27 $

    typeClass = findtype(type);
    if isempty(typeClass)
        error([ type ' is not a valid udd type ' ]);
    end

    idx = strmatch(enum, typeClass.Strings, 'exact' );

    if isempty(idx)
        error([enum ' is not one of the enumeration strings in type ' type ]);
    end
    
   idx = int32(typeClass.Values(idx)); 


