function write(ff,inputvar,val)
% WRITE Writes data into an input parameter.
% 	WRITE(FF,INPUT,VAL) writes the value VAL directly to the storage unit, 
%   i.e., register or memory, which the input argument INPUT is assigned
%   to. INPUT can be the input parameter's name or numeric order in the
%   function declaration.
%
% 	WRITE(FF,INPUT,VAL) is similar to:
%       input_obj = getinput(ff,input);
%       write(input_obj,val);
%
%   See also GOTO, EXECUTE, RUN, GETINPUT.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.13.2.3 $  $Date: 2003/11/30 23:09:12 $

error(nargchk(3,3,nargin));

if ~ishandle(ff)
    error(generateccsmsgid('InvalidHandle'),'First parameter must be a FUNCTION handle.');
end

% Check if inputvar is an input to ff
[inputvar, input_index,isallocated] = CheckInputvarIfValid(ff,inputvar);

% Update output and allocated variables addresses
p_updateI0values(ff); 

% Before changing the state of proc, do housekeeping -- REMOVED

% Rename input object
inObj = getinput(ff,inputvar);
try
    if isallocated 
        derefObj = deref(inObj);  %dereference pointer 
        % adjust size of new object with the user input for size 
        inputobj = reshape(derefObj,ff.stackallocation.vars.(ff.stackallocation.varnames{input_index}).size); 
        write(inputobj,val); 
    else 
        write(inObj,val); % do not copy size-property, it is assumed correct
    end
catch
    error(generateccsmsgid('ErrorDuringWrite'),...
        sprintf(['You supplied an invalid value for input parameter ''' inputvar ''':\n',lasterr]));
end

%-----------------------------------------
function [inputvar, input_index, isallocated] = CheckInputvarIfValid(ff,inputvar) 
isallocated = 0;
if isnumeric(inputvar)
    if length(inputvar)~=1 || inputvar<1 || mod(inputvar,1)~=0 || inputvar>length(ff.inputnames),
        error(generateccsmsgid('InvalidInput'),'You supplied an invalid input order value. ');
    end
    input_index = inputvar;
    inputvar = ff.inputnames{input_index};
elseif ischar(inputvar)
    if findstr('*', inputvar) 
        inputvar = p_deblank(strrep(inputvar,'*','')); 
        input_index =  strmatch(inputvar,ff.stackallocation.varnames,'exact'); 
        if isempty(input_index) 
            error(generateccsmsgid('InvalidInputName'),['''' inputvar ''' is not an allocated input argument to ''' ff.name '''.']); 
        end 
        isallocated = 1; 
    else 
        input_index = strmatch(inputvar,ff.inputnames,'exact');
        if isempty(input_index)
            errid = generateccsmsgid('InvalidInputName');
            error(errid,['''' inputvar ''' is not an input argument to ''' ff.name '''.']);
        end
    end
else
    error(generateccsmsgid('InvalidSecondParam'), ...
        sprintf(['Second parameter must be the input argument''s name (string).']));
end

% [EOF] write.m