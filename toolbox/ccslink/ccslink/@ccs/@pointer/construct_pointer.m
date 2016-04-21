function nn = construct_pointer(nn,args)
%CONSTRUCT_POINTER (Private) Constructor for a pointer object.
%  MM = CONSTRUCT_POINTER(OBJ,'PropertyName',PropertyValue,...)

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $ $Date: 2003/11/30 23:10:18 $


% Process constructors input arguments if any
if nargin <= 1
    return; % Use defaults
end
nargs = length(args);

if(mod(nargs,2)~=0)
    error(['POINTER constructor requires property and value ', ...
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
        error('Property Name must be a string entry');        
    end
    if ~isempty( strmatch(prop,{'typestring','reftype','referent','isrecursive'},'exact'))
        nn.(prop) = val;
        args{i} = [];
        args{i+1} = [];
    end
end

% Call base-class constructor
construct_numeric(nn,args);  

% Convert data into correct numeric format
if strcmp(nn.procsubfamily,'C55x')
    if isfield(nn.objectdata,'bitsize')
        ConvertC55xPointer(nn);
    else
        ConvertC55xPointer_build(nn);
    end
elseif strcmp(nn.procsubfamily,'C28x')
    if isfield(nn.objectdata,'bitsize')
        ConvertC28xPointer(nn);
    else
        ConvertC28xPointer_build(nn);
    end
else
    convert_numeric(nn,'unsigned int');
end

% Set property 'typestring'='reftype'
set(nn,'typestring',nn.reftype);

%-----------------------------------
% C2800 has 2 types of pointers:
%  1. 16-bit pointer
%  2. 22-bit pointer (Large Memory Model)
function ConvertC28xPointer(nn)
if nn.ObjectData.bitsize==22
	% 1. Large memory mode, 22 bits
    convert_numeric(nn,'unsigned long');
    % nn.postpad = 10; % Geck: This not currently applicable because of an
    % imposed limitation on postpad (uncomment to see effect)
else 
	% 2. Small memory mode, 16 bits
    convert_numeric(nn,'unsigned int');
end
%-----------------------------------
% C2800 has 2 types of pointers:
%  1. 16-bit pointer
%  2. 22-bit pointer (Large Memory Model)
function ConvertC28xPointer_build(nn)
try
    buildOpt = getbuildopt(nn.link);
    % 1. Large memory mode, 22 bits
    if strfind(buildOpt(3).optstring,' -ml')
        convert_numeric(nn,'unsigned long');
        % nn.postpad = 10; % Geck: This not currently applicable because of an
        % imposed limitation on postpad (uncomment to see effect)
    % 2. Small memory mode, 16 bits
    else 
        convert_numeric(nn,'unsigned int');
    end
catch
    if strcmp(lasterr,'??? GetBuildOpt: No project loaded, first open a project'),
        % 2. Small memory mode, 16 bits
        convert_numeric(nn,'unsigned int');
        warnid = generateccsmsgid('C28xDefault_SmallMemoryModel');
        warning(warnid,sprintf(['Compiler option ''-ml'' could not be checked because project is not open.\n'...
                'Small memory model is assumed, and pointer size is 16 bits.']));
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
    convert_numeric(nn,'unsigned long');
    nn.postpad = 8;
    
% b. Data pointer, 16 or 23 bits depending on memory mode
elseif nn.ObjectData.bitsize==23  % b.1. Large memory mode, 23 bits
    convert_numeric(nn,'unsigned long');
    nn.postpad = 8; % geck: postpad is limited to increments of 8 for now
    
elseif nn.ObjectData.bitsize==16  % b.2. Small memory mode, 16 bits
    convert_numeric(nn,'unsigned int');
    
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
    convert_numeric(nn,'unsigned long');
    nn.postpad = 8;

% b. Data pointer, 16 or 23 bits depending on memory mode
else
    try
        buildOpt = getbuildopt(nn.link);
        % b.1. Large memory mode, 23 bits
        if strfind(buildOpt(3).optstring,' -ml')
            convert_numeric(nn,'unsigned long');
            nn.postpad = 8; % geck: postpad is limited to increments of 8 for now
        % b.2. Small memory mode, 16 bits
        else 
            convert_numeric(nn,'unsigned int');
        end
    catch
        if strcmp(lasterr,'??? GetBuildOpt: No project loaded, first open a project'),
            % b.2. Small memory mode, 16 bits
            convert_numeric(nn,'unsigned int');
            warnid = generateccsmsgid('C55xDefault_SmallMemoryModel');
            warning(warnid,sprintf(['Compiler option ''-ml'' could not be checked because project is not open.\n'...
                    'Small memory model is assumed, and pointer size is 16 bits.']));
        else
            rethrow(lasterror);
        end
    end
end

% [EOF] construct_pointer.m