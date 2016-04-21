function obj = subsasgn(obj, Struct, Value)
%SUBSASGN Subscripted assignment into timer objects.
%
%    SUBSASGN Subscripted assignment into timer objects. 
%
%    OBJ(I) = B assigns the values of B into the elements of OBJ specifed by
%    the subscript vector I. B must have the same number of elements as I
%    or be a scalar.
% 
%    OBJ(I).PROPERTY = B assigns the value B to the property, PROPERTY, of
%    timer object OBJ.
%
%    Supported syntax for timer objects:
%
%    Dot Notation:                  Equivalent Set Notation:
%    =============                  ========================
%    obj.Tag='sydney';              set(obj, 'Tag', 'sydney');
%    obj(1).Tag='sydney';           set(obj(1), 'Tag', 'sydney');
%    obj(1:4).Tag='sydney';         set(obj(1:4), 'Tag', 'sydney');
%    obj(1)=obj(2);               
%    obj(2)=[];
%
%    See also TIMER/SET.
%

%    RDD 12-7-2001
%    Copyright 2001-2003 The MathWorks, Inc. 
%    $Revision: 1.2.4.2 $  $Date: 2003/08/29 04:50:30 $

StructL = length(Struct);

if isempty(obj)
    % Ex. t(1) = timer; 
    %   where t does not yet exist
    
    % trap for unsupported syntax, e.g., t.prop = value;
    if (StructL > 1) || (strcmp(Struct(1).type,'()')==0)
        error('MATLAB:timer:unhandledsyntax',timererror('MATLAB:timer:unhandledsyntax'));
    end
    try % make new java object, j, with given subscripting 
        % Value has to be a timer object to get here, BTW
        checkSubs(Struct.subs, obj);
        j(Struct.subs{:}) = Value.jobject;
        obj = timer(j); % convert the new java object(s) to a MATLAB timer object
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
                error('MATLAB:timer:inconsistentsubscript',timererror('matlab:timer:inconsistentsubscript'));
            end
            if isa(val{lcv},'timer') % if timer object, work on jobject.
                val{lcv+1} = val{lcv};
                val{lcv+1}.jobject = val{lcv+1}.jobject(Struct(lcv).subs{:});
            else
                error('MATLAB:timer:inconsistentsubscript',timererror('matlab:timer:inconsistentsubscript'));
            end
        elseif strcmp(Struct(lcv).type,'{}')
            if dotrefFound % language currently doesn't support {} beyond a dot ref.
                error('MATLAB:timer:badcellref',timererror('matlab:timer:badcellref'));
            end
            val{lcv+1} = val{lcv}{Struct(lcv).subs{:}};
        elseif strcmp(Struct(lcv).type,'.')
            if dotrefFound % language currently doesn't support . beyond a property dot ref.
                error('MATLAB:timer:inconsistentdotref',timererror('matlab:timer:inconsistentdotref'));
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
            if isa(val{lcv},'timer') % if timers, work with jobject
                checkSubs(Struct(lcv).subs, val{lcv});
                if isempty(val{lcv+1}) % e.g., t(2) = [];
                    val{lcv}.jobject(Struct(lcv).subs{:}) = [];
                elseif ~isa(val{lcv+1},'timer')
                    error('MATLAB:timer:assigntonontimerobject',timererror('MATLAB:timer:assigntonontimerobject'));
                % This is an ugly conditional.  The first OR is for the
                % case where "x(y) = t".  The second is for "x(y) = [t t
                % t]" where y goes past the end of the array.  The third is
                % for all other syntaxes.
                elseif length(val{lcv+1}.jobject) == 1 || length(Struct(lcv).subs{:}) == length(val{lcv+1}.jobject) ...
                        || length(val{lcv}.jobject(Struct(lcv).subs{:})) == length(val{lcv+1}.jobject)
                    
                    val{lcv}.jobject(Struct(lcv).subs{:}) = val{lcv+1}.jobject(:);
                else
                    error('MATLAB:timer:assignelementsizemismatch',timererror('MATLAB:timer:assignelementsizemismatch'));
                end                    
            else
                error('MATLAB:timer:inconsistentsubscript',timererror('matlab:timer:inconsistentsubscript'));
            end
        elseif strcmp(Struct(lcv).type,'{}')
            error('MATLAB:timer:badcellref',timererror('matlab:timer:badcellref'));
        elseif strcmp(Struct(lcv).type,'.')
            if isobject(val{lcv})
                set(val{lcv},Struct(lcv).subs,val{lcv+1});
            else
                error('MATLAB:timer:inconsistentdotref',timererror('matlab:timer:inconsistentdotref'));
            end
        else
            error('MATLAB:timer:unhandledsyntax',timererror('MATLAB:timer:unhandledsyntax'));
        end
    catch
        lerr = fixlasterr;
        error(lerr{:});
    end
end    

if (length(val{1}) == 0)
    % currently, not allowing empty timer arrays
    error('MATLAB:timer:emptytimerarray',timererror('MATLAB:timer:emptytimerarray'));
else
    obj = val{1}; % return the object
end

% all pau

function checkSubs(subs, obj)
% this function checks to see if one gave an invalid subscript reference for a timer object.

subsL = length(subs);

% Error if index is a non-number.
for i=1:subsL
    if ~(islogical(subs{i}) || isnumeric(subs{i}) || ischar(subs{i}))
        error('MATLAB:timer:subsasgn:badsubscript',timererror('matlab:timer:subsasgn:badsubscript', class(subs{i})));
    end
end

if subsL == 1 % single dim. reference, e.g., t(1)
    if (~islogical(subs{1}) && (min(subs{1}) < 1)) % e.g., t(0)
        error('MATLAB:timer:nonpositiveindex',timererror('MATLAB:timer:nonpositiveindex'));
    end
    if isnumeric(subs{1}) && max(subs{1}) > length(obj)+1 % e.g., t(5), where length(t) = 2
        % This is valid if the indexes supplied are consecutive from
        % length(t) + 1.
        if ~(all(diff(subs{1}) == 1) && (subs{1}(1) == (length(obj) + 1)))
            error('MATLAB:timer:gapsnotallowed',timererror('matlab:timer:gapsnotallowed'));
        end
    end
else % e.g., t(1,2)   
    sz = zeros(subsL,1);
    newDim = zeros(subsL,1);
    for lcv=1:subsL % for each subscript dimension...
        if (~islogical(subs{lcv}) && (min(subs{lcv}) < 1)) % no dimensions can be < 1., e.g., t(0,3)
            error('MATLAB:timer:nonpositiveindex',timererror('MATLAB:timer:nonpositiveindex'));
        end
        sz(lcv) = size(obj,lcv);
        
        % Check for the case where the index is specified by ':'.  In this
        % case it will have a value of 58 which will likely be greater than
        % any of the indexes in the array causing newDim to be updated
        % incorrectly.
        if strcmp(subs{lcv}, ':')            
            newDim(lcv) = sz(lcv); % resulting dimensions
        else
            newDim(lcv) = max(max(subs{lcv}),sz(lcv)); % resulting dimensions
        end
    end
    
    if sum(gt(newDim,1)) > 1 % only one dimensions > 1 allowed for vectors, e.g., t(2,1) where t is 1x5
        error('MATLAB:timer:creatematrix',timererror('MATLAB:timer:creatematrix'));
    elseif sum(gt(newDim-sz,1)) > 0 % no dimension can grow more than one (no gaps allowed).
        error('MATLAB:timer:gapsnotallowed',timererror('matlab:timer:gapsnotallowed'));
    end
end

