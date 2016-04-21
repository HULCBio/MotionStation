function obj = subsasgn(obj, Struct, Value)
%SUBSASGN Subscripted assignment into audioplayer objects.
%
%    OBJ(I) = B assigns the values of B into the elements of OBJ specifed by
%    the subscript vector I. B must have the same number of elements as I
%    or be a scalar.
% 
%    OBJ(I).PROPERTY = B assigns the value B to the property, PROPERTY, of
%    audioplayer object OBJ.
%
%    Supported syntax for audioplayer objects:
%
%    Dot Notation:                  Equivalent Set Notation:
%    =============                  ========================
%    obj.Tag='sydney';              set(obj, 'Tag', 'sydney');
%    obj(1).Tag='sydney';           set(obj(1), 'Tag', 'sydney');
%
%    See also AUDIOPLAYER/SET.
%

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:50 $

StructL = length(Struct);

if isempty(obj)
    % Ex. p(1) = audioplayer; 
    %   where p does not yet exist
    
    % trap for unsupported syntax, e.g., p.prop(3) = value;
    if (StructL > 1) || (strcmp(Struct(1).type,'()')==0)
        error('MATLAB:audioplayer:unhandledsyntax',audioplayererror('MATLAB:audioplayer:unhandledsyntax'));
    end
    try % make new UDD/Java object, j, with given subscripting 
        % Value has to be a audioplayer object to get here, BTW
        checkSubs(Struct.subs, obj);
        j(Struct.subs{:}) = Value.internalObj;
        obj = audioplayer(j); % convert to a MATLAB audioplayer object
    catch
        lerr = fixlasterr;
        error(lerr{:});
    end
    return;
end

%  The expression is evaluated from left to right using the following algorithm.
%
%  Consider the example obj.userdata{x}(y) = Value;
%    A.  The expression can be broken down into its individual elements
%            val{1} = obj 
%            val{2} = val{1}.userdata % i.e., get(val{1},'userdata')
%            val{3} = val{2}{x}
%           
%    B.  Given the values in A, the evaluated can cascade back right-to-left
%            val{3}(y) = Value;
%            val{2}{x} = val{3};
%            val{1}.userdata = val{2}; % i.e., set(val{1},'userdata',val{2});

val{1} = obj;
rightmostobj = 1; % I know the val{1} is an object.
dotrefFound = false;
for lcv=1:StructL-1 % go left to right, evaluating each reference and storing them off for later
    try 
        if strcmp(Struct(lcv).type,'()')
            if dotrefFound % language currently doesn't support () beyond a dot ref.
                error('MATLAB:audioplayer:inconsistentsubscript',audioplayererror('matlab:audioplayer:inconsistentsubscript'));
            end
            if isa(val{lcv},'audioplayer') % if audioplayer object, work on internalObj.
                val{lcv+1} = val{lcv};
                val{lcv+1}.internalObj = val{lcv+1}.internalObj(Struct(lcv).subs{:});
            else
                error('MATLAB:audioplayer:inconsistentsubscript',audioplayererror('matlab:audioplayer:inconsistentsubscript'));
            end
        elseif strcmp(Struct(lcv).type,'{}')
            if dotrefFound % language currently doesn't support {} beyond a dot ref.
                error('MATLAB:audioplayer:badcellref',audioplayererror('matlab:audioplayer:badcellref'));
            end
            val{lcv+1} = val{lcv}{Struct(lcv).subs{:}};
        elseif strcmp(Struct(lcv).type,'.')
            if dotrefFound % language currently doesn't support . beyond a property dot ref.
                error('MATLAB:audioplayer:inconsistentdotref',audioplayererror('matlab:audioplayer:inconsistentdotref'));
            end
            if isobject(val{lcv}) % if object, use get
                val{lcv+1} = get(val{lcv},Struct(lcv).subs);
                dotrefFound = true;
            else
                val{lcv+1} = val{lcv}.(Struct(lcv).subs); % for structures
            end
        end
    catch
        lerr = fixlasterr;
        error(lerr{:});
    end
end    
val{StructL+1}=Value;

% now cascade the evaluation values right-to-left, stopping when you hit an object (since it is 
% by reference, there is no need to go further left)
for lcv=StructL:-1:rightmostobj 
    try
        if strcmp(Struct(lcv).type,'()')
            if isa(val{lcv},'audioplayer') % if audioplayers, work with internalObj
                checkSubs(Struct(lcv).subs, val{lcv});
                if isempty(val{lcv+1}) % e.g., t(2) = [];
                    val{lcv}.internalObj(Struct(lcv).subs{:}) = [];
                elseif ~isa(val{lcv+1},'audioplayer')
                    error('MATLAB:audioplayer:assigntononaudioplayerobject',audioplayererror('MATLAB:audioplayer:assigntononaudioplayerobject'));
                elseif length(val{lcv+1}.internalObj) == 1 || length(val{lcv}.internalObj(Struct(lcv).subs{:})) == length(val{lcv+1}.internalObj)
                    val{lcv}.internalObj(Struct(lcv).subs{:}) = val{lcv+1}.internalObj;
                else
                    error('MATLAB:audioplayer:assignelementsizemismatch',audioplayererror('MATLAB:audioplayer:assignelementsizemismatch'));
                end                    
            else
                error('MATLAB:audioplayer:inconsistentsubscript',audioplayererror('matlab:audioplayer:inconsistentsubscript'));
            end
        elseif strcmp(Struct(lcv).type,'{}')
            error('MATLAB:audioplayer:badcellref',audioplayererror('matlab:audioplayer:badcellref'));
        elseif strcmp(Struct(lcv).type,'.')
            if isobject(val{lcv})
                set(val{lcv},Struct(lcv).subs,val{lcv+1});
            else
                error('MATLAB:audioplayer:inconsistentdotref',audioplayererror('matlab:audioplayer:inconsistentdotref'));
            end
        else
            error('MATLAB:audioplayer:unhandledsyntax',audioplayererror('MATLAB:audioplayer:unhandledsyntax'));
        end
    catch
        lerr = fixlasterr;
        error(lerr{:});
    end
end    

if length(val{1}) == 0 
    % currently, not allowing empty audioplayer arrays
    error('MATLAB:audioplayer:emptyaudioplayerarray',audioplayererror('MATLAB:audioplayer:emptyaudioplayerarray'));
else
    obj = val{1}; % return the object
end

% all pau

function checkSubs(subs, obj)
% this function checks to see if one gave an invalid subscript reference for a audioplayer object.

subsL = length(subs);

% Error if index is a non-number.
for i=1:subsL
    if ~isnumeric(subs{i}) && (~ischar(subs{i}) || ~strcmp(subs{i}, ':')),
        error('MATLAB:audioplayer:subsasgn:badsubscript',audioplayererror('matlab:audioplayer:subsasgn:badsubscript', class(subs{i})));
    end
end

if subsL == 1 % single dim. reference, e.g., t(1)
    if min(subs{1}) < 1 % e.g., t(0)
        error('MATLAB:audioplayer:nonpositiveindex',audioplayererror('MATLAB:audioplayer:nonpositiveindex'));
    end
    if isnumeric(subs{1}) && max(subs{1}) > length(obj)+1 % e.g., t(5), where length(t) = 2
        error('MATLAB:audioplayer:gapsnotallowed',audioplayererror('matlab:audioplayer:gapsnotallowed'));
    end
else % e.g., t(1,2)   
    sz = zeros(subsL,1);
    newDim = zeros(subsL,1);
    for lcv=1:subsL % for each subscript dimension...
        if min(subs{lcv}) < 1 % no dimensions can be < 1., e.g., t(0,3)
            error('MATLAB:audioplayer:nonpositiveindex',audioplayererror('MATLAB:audioplayer:nonpositiveindex'));
        end
        sz(lcv) = size(obj,lcv);
        newDim(lcv) = max(max(subs{lcv}),sz(lcv)); % resulting dimensions
    end
    
    if sum(gt(newDim,1)) > 1 % only one dimensions > 1 allowed for vectors, e.g., t(2,1) where t is 1x5
        error('MATLAB:audioplayer:creatematrix',audioplayererror('MATLAB:audioplayer:creatematrix'));
    elseif sum(gt(newDim-sz,1)) > 0 % no dimension can grow more than one (no gaps allowed).
        error('MATLAB:audioplayer:gapsnotallowed',audioplayererror('matlab:audioplayer:gapsnotallowed'));
    end
end

