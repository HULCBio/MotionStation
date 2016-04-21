function [R, height, width, hasFlag] ...
                        = parsePixMapInputs(function_name, flagstr, varargin)
                    
% Input-parsing for MAPBBOX, MAPOUTLINE, and PIXCENTERS.
%
%   Handle the following argument lists:
%
%      INFO
%      INFO, FLAG
%      R, SIZEA
%      R, SIZEA, FLAG
%      R, HEIGHT, WIDTH
%      R, HEIGHT, WIDTH, FLAG
%
%   FLAGSTR is the acceptable value of FLAG.
%   Set FLAGSTR = [] if FLAG is not to be used.

%   Copyright 1996-2003 The MathWorks, Inc.  
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:40 $

if isempty(flagstr)
    maxArgCount = 3;
else
    maxArgCount = 4;
end

checknargin(1, maxArgCount, numel(varargin), function_name);

if isstruct(varargin{1})
    [R, height, width, hasFlag] = parseInfo(function_name, flagstr, varargin{:});
else
    [R, height, width, hasFlag] = parseOther(function_name, flagstr, varargin{:});
end

%----------------------------------------------------------------------
function [R, height, width, hasFlag] = parseInfo(function_name, flagstr, varargin)

info = varargin{1};
if ~isfield(info,'RefMatrix') || ~isfield(info,'Height') || ~isfield(info,'Width')
    eid=sprintf('%s:%s:missingInfoFields', getcomp, function_name);
    msg=sprintf('Function %s expected its first argument, INFO, %s\n',...
                function_name, 'to contain RefMatrix, Height, and Width fields.');
    error(eid,msg)
else
    R = info.RefMatrix;
    try
        checkrefmat(R, function_name, 'R', 1);
    catch
        % Throw an error that make sense in this context.
        eid=sprintf('%s:%s:infoHasInvalidR', getcomp, function_name);
        msg=sprintf('Function %s expected its first argument, INFO, %s\n',...
                    function_name, 'to contain a valid RefMatrix value.');
        error(eid,msg)
    end
    try
        [height, width] = checkHeightAndWidth(info.Height, info.Width, function_name);
    catch
        % Throw an error that make sense in this context.
        eid=sprintf('%s:%s:infoHasInvalidHorW', getcomp, function_name);
        msg=sprintf('Function %s expected its first argument, INFO, %s\n',...
                    function_name, 'to contain valid Height and Width values.');
        error(eid,msg)
    end
end

if numel(varargin) >= 2 && ~isempty(flagstr) && ischar(flagstr)
    % Inputs: INFO, FLAG
    checkFlag(function_name, flagstr, varargin{2}, 2);
    hasFlag = true;
else
    % Inputs: INFO
    hasFlag = false;
end

%-------------------------------------------------------------------------
function [R, height, width, hasFlag] = parseOther(function_name, flagstr, varargin)

R = varargin{1};
checkrefmat(R, function_name, 'R', 1);

switch(numel(varargin))
    case 2
        % Inputs: R, SIZEA
        [height, width] = checkSizeA(varargin{2},function_name);
        hasFlag = false;
        
    case 3
        if ~isempty(flagstr) && ischar(flagstr) && ischar(varargin{3})
            % Inputs: R, SIZEA, FLAG
            [height, width] = checkSizeA(varargin{2},function_name);
            checkFlag(function_name, flagstr, varargin{3}, 3);
            hasFlag = true;
        else
            % Inputs: R, HEIGHT, WIDTH
            [height, width]...
                = checkHeightAndWidth(varargin{2},varargin{3},function_name);
            hasFlag = false;
        end
        
    case 4
        % Inputs: R, HEIGHT, WIDTH, FLAG
        [height, width]...
            = checkHeightAndWidth(varargin{2},varargin{3},function_name);
        checkFlag(function_name, flagstr, varargin{4}, 4);
        hasFlag = true;
end

%----------------------------------------------------------------------
function [height, width] = checkSizeA(sizeA, function_name)

sizeAAttributes = {'real','positive','integer'};
checkinput(sizeA,{'double'},sizeAAttributes,function_name,'SIZEA',2);

if numel(sizeA) < 2 || ndims(sizeA) ~= 2 || size(sizeA,1) ~= 1
    eid = sprintf('%s:%s:invalidSIZEA',getcomp,function_name);
    err = sprintf(...
              'Function %s expected its %s argument, SIZEA, to be 1-by-N.',...
              function_name, num2ordinal(2));
    error(eid,err)
end

height = sizeA(1);
width  = sizeA(2);

%----------------------------------------------------------------------
function [height, width] = checkHeightAndWidth(height, width, function_name)

hwAttributes = {'real','scalar','positive','integer'};
checkinput(height,{'double'},hwAttributes,function_name,'HEIGHT',2);
checkinput(width, {'double'},hwAttributes,function_name,'WIDTH', 3);

%----------------------------------------------------------------------
function checkFlag(function_name, flagstr, flag, pos)

checkinput(flag,{'char'},{'nonempty'},function_name,flagstr,pos);

% FLAGSTR is the only permissible value of FLAG.
t = strmatch(lower(flag),flagstr);
if (isempty(t) || t(1) ~= 1)
    eid = sprintf('%s:%s:expectedFlag',getcomp,function_name);
    err = sprintf(...
        'Function %s expected its %s argument to be the string ''%s''.',...
        function_name, num2ordinal(pos), flagstr);
    error(eid,err)
end
