function result=subsref(obj,Struct)
%SUBSREF Subscripted reference into audiorecorder objects.
%
%    OBJ(I) is an array formed from the elements of OBJ specified by the
%    subscript vector I.  
% 
%    OBJ.PROPERTY returns the property value of PROPERTY for audiorecorder
%    object OBJ.
% 
%    Supported syntax for audiorecorder objects:
% 
%    Dot Notation:                  Equivalent Get Notation:
%    =============                  ========================
%    obj.Tag                        get(obj,'Tag')
%    obj(1).Tag                     get(obj(1),'Tag')
%    obj(1)                         
% 
%    See also AUDIORECORDER/GET.
 
%    JCS 
%    Copyright 2003 The MathWorks, Inc.
%    $Revision $  $Date: 2003/12/04 19:01:05 $

StructL = length(Struct);
result = obj;

try
    dotrefFound = false; % no referencing beyond the dot will be allowed.
    for lcv=1:StructL
        switch Struct(lcv).type
        case '.'
            % indexing into properties not currently supported by language.
            if (dotrefFound) 
                error('MATLAB:audiorecorder:inconsistentdotref', ...
                audiorecordererror('matlab:audiorecorder:inconsistentdotref'));
            end
                result = get(result,Struct(lcv).subs);
                dotrefFound = true;
        case '()'
            % indexing into properties not currently supported by language.
            if (dotrefFound) 
                error('MATLAB:audiorecorder:inconsistentsubscript',...
                audiorecordererror('matlab:audiorecorder:inconsistentsubscript'));
            end
            % Error if index is a non-number.
            for i=1:length(Struct(lcv).subs)
                ind = Struct(lcv).subs{i};
                if ~islogical(ind) && ~isnumeric(ind) && ~ischar(ind)
                    error('MATLAB:audiorecorder:subsref:badsubscript',...
                    audiorecordererror('matlab:audiorecorder:subsref:badsubscript', class(ind)));
                end
                % Make sure that the indeces are a vector.  This will be
                % true if the length of ind is equal to the number of
                % elements in ind.
                if (length(ind) ~= numel(ind))
                    error('MATLAB:audiorecorder:creatematrix', ...
                    audiorecordererror('MATLAB:audiorecorder:creatematrix'));
                end
            end
            result.internalObj = result.internalObj(Struct(lcv).subs{:});
        case '{}' 
        % all the cell referencing needed should have already been handled
        % by MATLAB
            error('MATLAB:audiorecorder:badcellref', ...
                  audiorecordererror('matlab:audiorecorder:badcellref'));
        otherwise
            error('MATLAB:audiorecorder:badref', ...
            audiorecordererror('MATLAB:audiorecorder:badref',Struct(1).type));
        end
    end
    
catch
    err = fixlasterr;
    error(err{:});
end    

