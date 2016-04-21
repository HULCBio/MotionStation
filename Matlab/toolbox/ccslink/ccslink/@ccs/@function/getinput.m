function obj = getinput(ff,inputarg)
% GETINPUT. Return a function's input object.
%  INPUTOBJ = GETINPUT(FF,INPUTNAME) Returns the input object INPUTOBJ associated with the 
%  function's input parameter INPUTNAME, where INPUTNAME is a string.
%
%  Example,
%
%  CCS:  
%   int foo(int _a, int b);
%
%  MATLAB:
%   % Create a link to function 'foo'
%   ff = createobj(cc,'foo')
%   % Get foo's input _a
%   inputobj = getinput(cc,'_a')
%  
%  See also GETOUTPUT, GET.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.7.6.3 $  $Date: 2003/11/30 23:08:24 $

error(nargchk(2,2,nargin));

if ~ishandle(ff),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a valid FUNCTION handle. ');
end

% If void input, return NULL
if isempty(ff.inputnames)
    obj = []; return;
end

% Check if inputarg is a valid input order or input name
[inputarg,inputorder,isallocated] = CheckInputArgIfValid(ff,inputarg);

% Update output and allocated variables addresses
p_updateI0values(ff);

% Mangle input names that are not allowed by ML
m_inputarg = ff.mangledinputnames{inputorder};

% Input object must exist first before attempting to return it
if ~p_is_input_created(ff,inputorder) % not created
    error(generateccsmsgid('InputObjNotCreated'),['Cannot return the input object ''' inputarg ''', it is not yet created. ']);
end

% Return the input requested
obj = ff.inputvars.(m_inputarg);

% Return a numeric obj if requesting for allocated var
if isallocated 
   derefObj = deref(obj);  % dereference pointer 
   % adjust size of new object with the user input for size 
   obj = reshape(derefObj,ff.stackallocation.vars.(ff.inputnames{inputorder}).size); 
end 

% % Prepare function (stack,...) in case user starts writing to input
% if ~(ff.is_stack_allocated) && length(fieldnames(ff.inputvars))==length(ff.inputnames) && nargin>2,
%     p_preparation(ff); % assign fp, save register values, set input stack addresses, is_stack_allocated=1
% end

%---------------------------------------------
function [inputarg,inputorder,isallocated] = CheckInputArgIfValid(ff,inputarg)
isallocated = 0;
errid = generateccsmsgid('InvalidInput');
if ~ischar(inputarg) && ~isnumeric(inputarg)
    error(errid,'Second Parameter must be a string or a numeric. ');
end
if isnumeric(inputarg) 
    warning(generateccsmsgid('ObsoleteSyntax'),'Passing the input''s numerical order will soon be deprecated, pass the input''s name instead.');
    inputorder = inputarg;
    if inputarg<1 || inputarg>length(ff.inputnames)
        error(errid,['The input order you supplied, ''' num2str(inputarg) ''', is invalid. ']);
    else
        inputarg = ff.inputnames{inputarg};
    end
elseif ischar(inputarg) 
    if findstr('*', inputarg) 
        inputarg = p_deblank(strrep(inputarg,'*','')); 
        inputorder = strmatch(inputarg,ff.inputnames,'exact');
        if isempty(inputorder) 
            error(errid,['''' inputarg ''' is not an allocated input argument to ''' ff.name '''.']); 
        end
        isallocated = 1; 
    else 
        inputorder = strmatch(inputarg,ff.inputnames,'exact'); 
        if isempty(inputorder)
            error(errid,['The input name you supplied, ''' inputarg ''', is not an input argument to ''' ff.name '''.']);
        end
    end
end

% [EOF] getinput.m