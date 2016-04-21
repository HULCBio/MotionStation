function nn = construct_rpointer(nn,args)
%CONSTRUCT_RPOINTER (Private) Constructor for an Rpointer object.
%  MM = CONSTRUCT_RPOINTER(OBJ,'PropertyName',PropertyValue,...)

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $ $Date: 2003/11/30 23:11:54 $

% Process constructors input arguments if any
if nargin <= 1
    return;      % Use defaults
end
nargs = length(args);

if(mod(nargs,2)~=0)
    error(generateccsmsgid('PropValuePairsRequired'),['RPOINTER constructor requires property and value ', ...
            'arguments to be specified in pairs.']);
end

% Get property / value pairs from argument list
for i = 1:2:nargs
    prop = lower(args{i});
    val  = args{i+1};
    
    % Argument checking
    if isempty(prop)  % ignore nulls
        continue;
    elseif ~ischar(prop),
        error(generateccsmsgid('InvalidInput'),'Property Name must be a string entry');        
    end
    if ~isempty( strmatch(prop,{'reftype','referent','isrecursive'},'exact'))
        nn.(prop) = val;
        args{i} = [];
        args{i+1} = [];
    end
end

% Call base-class constructor
construct_rnumeric(nn,args);  

% Convert data into correct numeric format
if strcmp(nn.procsubfamily,'C55x')
    ConvertC55xPointer(nn);
elseif strcmp(nn.procsubfamily,'C28x')
    ConvertC28xPointer(nn);
else
    convert_rnumeric(nn,'unsigned int');
end

% Set property 'typestring'='reftype'
set(nn,'typestring',nn.reftype);

%-----------------------------------
% C2800 has 2 types of pointers:
%  1. 16-bit pointer
%  2. 22-bit pointer (Large Memory Model)
function ConvertC28xPointer(nn)
if (~isempty(nn.regname) && ~isempty(strfind(nn.regname{1},'X'))) || ...
   (isfield(nn.ObjectData,'bitsize') && nn.ObjectData.bitsize==22),
    % 1. In large memory mode, 22 bits, usually the XARn registers are assigned
    cast_C28x(nn,'pointer_ml');
    % nn.postpad = 10; % Geck: This is not currently applicable because of an
    % imposed limitation on postpad (uncomment to see effect)
else 
    % 2. Small memory mode, 16 bits
    convert_rnumeric(nn,'unsigned int');
end
%-----------------------------------
% C2800 has 2 types of pointers:
%  1. 16-bit pointer
%  2. 22-bit pointer (Large Memory Model)
function ConvertC28xPointer_build(nn)
% Note: Checking the build option is not anymore necessary because we
% can check it from the register assignment.
try
    buildOpt = getbuildopt(nn.link);
    % b.1. Large memory mode, 22 bits
    if strfind(buildOpt(3).optstring,' -ml') 
        cast_C28x(nn,'pointer_ml');
   % b.2. Small memory mode, 16 bits
    else
        convert_rnumeric(nn,'unsigned int');
    end
catch
    if strcmp(lasterr,'??? GetBuildOpt: No project loaded, first open a project')
        % b.2. Small memory mode, 16 bits
        convert_rnumeric(nn,'unsigned int');
        warnid = generateccsmsgid('C55xDefault_SmallMemoryModel');
        warning(warnid,sprintf(['Project is not open. Small memory model is assumed, and pointer size is 16 bits.\n'...
                'For large memory models, open the project.']));
    else
        rethrow(lasterror);
    end
end

%-----------------------------------
% C5500 has 3 types of pointers:
%  a. function pointer (24 bits)
%  b.1. 23-bit data pointer
%  b.2. 16-bit data pointer
function ConvertC55xPointer(nn)

% a. Function pointer, 24 bits
if nn.ObjectData.bitsize==32
    cast_C55x(nn,'unsigned long',1); % use 'cast' instead of "convert_rnumeric(nn,'unsigned long');"
                                     % to bypass check on final data type 
    nn.postpad = 8;
    
% b. Data pointer, 16 or 23 bits depending on memory mode
elseif nn.ObjectData.bitsize==23  
    % b.1. Large memory mode, 23 bits
    cast_C55x(nn,'pointer_ml',1); % use 'cast' instead of "convert_rnumeric(nn,'unsigned long');"
                                  % to bypass check on final data type 
elseif nn.ObjectData.bitsize==16  
    % b.2. Small memory mode, 16 bits
    cast_C55x(nn,'unsigned int',1); % use 'cast' instead of "convert_rnumeric(nn,'unsigned int');"
                                    % to bypass check on final data type
end

%-----------------------------------
% C5500 has 3 types of pointers:
%  a. function pointer (24 bits)
%  b.1. 23-bit data pointer
%  b.2. 16-bit data pointer
function ConvertC55xPointer_build(nn)

% Check referent's uclass
ref = getprop(nn,'referent');
if ~isfield(ref,'uclass') && strcmp(ref.type,'function'),
    ref.uclass = 'function'; setprop(nn,'referent',ref);
elseif ~isfield(ref,'uclass') && strcmp(ref.type,'void'),
    ref.uclass = 'void'; setprop(nn,'referent',ref);
end

% a. Function pointer, 24 bits
if strcmp(ref.uclass,'function')
    cast_C55x(nn,'unsigned long',1); % use 'cast' instead of "convert_rnumeric(nn,'unsigned long');"
                                     % to bypass check on final data type 
    nn.postpad = 8;

% b. Data pointer, 16 or 23 bits depending on memory mode
else
    try
        buildOpt = getbuildopt(nn.link);
        % b.1. Large memory mode, 23 bits
        if strfind(buildOpt(3).optstring,' -ml') 
            cast_C55x(nn,'pointer_ml',1); % use 'cast' instead of "convert_rnumeric(nn,'unsigned long');"
                                             % to bypass check on final data type 
        % b.2. Small memory mode, 16 bits
        else
            cast_C55x(nn,'unsigned int',1); % use 'cast' instead of "convert_rnumeric(nn,'unsigned int');"
                                            % to bypass check on final data type
        end
    catch
        if strcmp(lasterr,'??? GetBuildOpt: No project loaded, first open a project')
            % b.2. Small memory mode, 16 bits
            cast_C55x(nn,'unsigned int',1); % use 'cast' instead of "convert_rnumeric(nn,'unsigned int');"
                                            % to bypass check on final data type
            warnid = generateccsmsgid('C55xDefault_SmallMemoryModel');
            warning(warnid,sprintf(['Project is not open. Small memory model is assumed, and pointer size is 16 bits.\n'...
                    'For large memory models, open the project.']));
        else
            rethrow(lasterror);
        end
    end
end

% [EOF] construct_rpointer.m