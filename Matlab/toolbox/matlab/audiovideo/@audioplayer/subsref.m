function result=subsref(obj,Struct)
%SUBSREF Subscripted reference into audioplayer objects.
%
%    OBJ(I) is an array formed from the elements of OBJ specified by the
%    subscript vector I.  
% 
%    OBJ.PROPERTY returns the property value of PROPERTY for audioplayer
%    object OBJ.
% 
%    Supported syntax for audioplayer objects:
% 
%    Dot Notation:                  Equivalent Get Notation:
%    =============                  ========================
%    obj.Tag                        get(obj,'Tag')
%    obj(1).Tag                     get(obj(1),'Tag')
%    obj(1)                         
% 
%    See also AUDIOPLAYER/GET.
 
%    JCS 
%    Copyright 2003 The MathWorks, Inc.
%    $Revision $  $Date: 2003/12/04 19:00:51 $

StructL = length(Struct);
result = obj;

try
    dotrefFound = false; % no referencing beyond the dot will be allowed.
    for lcv=1:StructL
        switch Struct(lcv).type
        case '.'
            % indexing into properties not currently supported by language.
            if (dotrefFound) 
                error('MATLAB:audioplayer:inconsistentdotref', ...
                audioplayererror('matlab:audioplayer:inconsistentdotref'));
            end
                result = get(result,Struct(lcv).subs);
                dotrefFound = true;
        case '()'
            % indexing into properties not currently supported by language.
            if (dotrefFound) 
                error('MATLAB:audioplayer:inconsistentsubscript',...
                audioplayererror('matlab:audioplayer:inconsistentsubscript'));
            end
            % Error if index is a non-number.
            for i=1:length(Struct(lcv).subs)
                ind = Struct(lcv).subs{i};
                if ~islogical(ind) && ~isnumeric(ind) && ~ischar(ind)
                    error('MATLAB:audioplayer:subsref:badsubscript',...
                    audioplayererror('matlab:audioplayer:subsref:badsubscript', class(ind)));
                end
                % Make sure that the indeces are a vector.  This will be
                % true if the length of ind is equal to the number of
                % elements in ind.
                if (length(ind) ~= numel(ind))
                    error('MATLAB:audioplayer:creatematrix', ...
                    audioplayererror('MATLAB:audioplayer:creatematrix'));
                end
            end
            result.internalObj = result.internalObj(Struct(lcv).subs{:});
        case '{}' 
        % all the cell referencing needed should have already been handled
        % by MATLAB
            error('MATLAB:audioplayer:badcellref', ...
                  audioplayererror('matlab:audioplayer:badcellref'));
        otherwise
            error('MATLAB:audioplayer:badref', ...
            audioplayererror('MATLAB:audioplayer:badref',Struct(1).type));
        end
    end
    
catch
    err = fixlasterr;
    error(err{:});
end    

