function varargout = target_code_flags(method,target,varargin)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/04/15 01:00:55 $
result = [];

switch(method)
case 'get'
    if(length(varargin)>=1)
        flagNames = varargin{1};
        result = get_target_code_flags(target,flagNames);
    else
        result = target_methods('codeflags',target);
    end
    varargout{1} = result;
case 'set'
    if(length(varargin)==2)
        flagNames = varargin{1};
        flagValues = varargin{2};
        set_target_code_flags(target,flagNames,flagValues);
    elseif(length(varargin)==1 & ...
            strcmp(class(varargin{1}),'struct') &...
            isfield(varargin{1},'name') &...
            isfield(varargin{1},'value'))
        % better be a struct array of flags
        set_target_code_flags_kernel(target,varargin{1});
    else
        error('target_code_flags(''set'') called with wrong arguments');
    end
case 'fill'
    result = fill_target_code_flag_values(target,varargin{1});
    varargout{1} = result;
case 'reset'
    reset_code_flags(target);
otherwise,
    error(sprintf('Unknown method %s passed to target_code_flags',method));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flagValues = get_target_code_flags(target,flagNames)

flagValues = [];
if(ischar(flagNames))
    flagNames = {flagNames};
end

flags = target_methods('codeflags',target);
if(~isempty(flags))
    existingFlagNames = {flags.name};
else
    existingFlagNames = {};
end

for i=1:length(flagNames)
    index = find(strcmp(existingFlagNames,flagNames{i}));
    if(~isempty(index))
        flagValues(i) = flags(index(1)).value;
    else
        flagValues(i) = 0;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flags = fill_target_code_flag_values(target,flags)

str = sf('get',target,'.codeFlags');
existingFlags = tokenize_code_flags(str);
if(~isempty(existingFlags))
    existingFlagNames = {existingFlags.name};
else
    existingFlagNames = [];
end
for i=1:length(flags)
    index = find(strcmp(existingFlagNames,flags(i).name));
    if(~isempty(index))
        flags(i).value = existingFlags(index(1)).value;
    else
        flags(i).value = flags(i).defaultValue;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_target_code_flags_kernel(target,flags)
str = sf('get',target,'.codeFlags');
newStr = kotenize_code_flags(flags);

if(~strcmp(str,newStr))
    % set it only if necessary
    sf('set',target,'.codeFlags',newStr);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_target_code_flags(target,flagNames,flagValues)

if(ischar(flagNames))
    flagNames = {flagNames};
end

flags = target_methods('codeflags',target);

if(~isempty(flags))
    existingFlagNames = {flags.name};
else
    existingFlagNames = {};
end
for i=1:length(flagNames)
    index = find(strcmp(existingFlagNames,flagNames{i}));
    if(~isempty(index))
        flags(index(1)).value = flagValues(i);
    else
        flags(end+1).name = flagNames{i};
        flags(end).value = flagValues(i);
    end
end

set_target_code_flags_kernel(target,flags);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reset_code_flags(target)

str = sf('get',target,'.codeFlags');

flags = tokenize_code_flags(str);

for i=1:length(flags)
    flags(i).value = 0;
end
newStr = kotenize_code_flags(flags);
if(~strcmp(str,newStr))
	% set it only if necessary
    sf('set',target,'.codeFlags',newStr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = kotenize_code_flags(flags)

str = '';
for i=1:length(flags)
    str = sprintf('%s %s=%d',str,flags(i).name,flags(i).value);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flags = tokenize_code_flags(str)

[first last tokens] = regexp(str,'(\w+)=(\d+)');

flags = [];
for i = 1:length(first)
    flags(i).name = str(tokens{i}(1,1):tokens{i}(1,2));
    flags(i).value = str2num(str(tokens{i}(2,1):tokens{i}(2,2)));
end
