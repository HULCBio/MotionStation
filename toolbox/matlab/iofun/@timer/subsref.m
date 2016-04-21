function result = subsref(obj, Struct)
%SUBSREF Subscripted reference into timer objects.
%
%   SUBSREF Subscripted reference into timer objects.
%
%   OBJ(I) is an array formed from the elements of OBJ specified by the
%   subscript vector I.  
%
%   OBJ.PROPERTY returns the property value of PROPERTY for timer
%   object OBJ.
%
%   Supported syntax for timer objects:
%
%   Dot Notation:                  Equivalent Get Notation:
%   =============                  ========================
%   obj.Tag                        get(obj,'Tag')
%   obj(1).Tag                     get(obj(1),'Tag')
%   obj(1:4).Tag                   get(obj(1:4), 'Tag')
%   obj(1)                         
%
%   See also TIMER/GET.

%    RDD 12-07-2001
%    Copyright 2001-2003 The MathWorks, Inc. 
%    $Revision: 1.2.4.2 $  $Date: 2003/08/29 04:50:31 $

StructL = length(Struct);
result = obj;

try
    dotrefFound = false; % no referencing beyond the dot will be allowed.
    for lcv=1:StructL
        switch Struct(lcv).type
        case '.'
            if (dotrefFound) % indexing into properties not currently supported by language.
                error('MATLAB:timer:inconsistentdotref',timererror('matlab:timer:inconsistentdotref'));
            end
                result = get(result,Struct(lcv).subs);
                dotrefFound = true;
        case '()'
            if (dotrefFound) % indexing into properties not currently supported by language.
                error('MATLAB:timer:inconsistentsubscript',timererror('matlab:timer:inconsistentsubscript'));
            end
            % Error if index is a non-number.
            for i=1:length(Struct(lcv).subs)
                ind = Struct(lcv).subs{i};
                if ~islogical(ind) && ~isnumeric(ind) && ~ischar(ind)
                    error('MATLAB:timer:subsref:badsubscript',timererror('matlab:timer:subsref:badsubscript', class(ind)));
                end
                % Make sure that the indeces are a vector.  This will be
                % true if the length of ind is equal to the number of
                % elements in ind.
                if (length(ind) ~= numel(ind))
                    error('MATLAB:timer:creatematrix',timererror('MATLAB:timer:creatematrix'));
                end
            end
            result.jobject = result.jobject(Struct(lcv).subs{:});
        case '{}' % all the cell referencing needed should have already been handled by MATLAB
            error('MATLAB:timer:badcellref',timererror('matlab:timer:badcellref'));
        otherwise
            error('MATLAB:timer:badref',timererror('MATLAB:timer:badref',Struct(1).type));
        end
    end
    
catch
    err = fixlasterr;
    error(err{:});
end    

