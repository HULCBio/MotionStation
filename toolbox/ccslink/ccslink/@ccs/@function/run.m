function resp = run(ff,varargin)
% RUN Runs the embedded function.
%   O = RUN(FF) Prepares the function FF for execution by configuring the
%   registers and the stack, and runs the function until a breakpoint is 
%   reached. If the execution of the function is completed, 
%   i.e, the first breakpoint encountered matches the function's return
%   address, the return value O is read and returned. Note: the return 
%   value can also be extracted through the function object's property 
%   OUTPUTVAR.
%     
%   O = RUN(FF,InputName1,InputValue1,...,InputNameN,InputValuen) Same as
%   above, except it first writes values to the specified input arguments.
%   Note: The input_name-input_value pairs need not be in order.
%
%   O = RUN(FF,InputOrder1,InputValue1,...,InputOrderN,InputValuen) Same as
%   above, except the input argument's numerical order can be used to refer 
%   to a specific function input. Note: The input_order-input_value pairs
%   need not be in the correct order.
%   
%   Example:
%    cc = ccsdsp
%    ff = createobj(cc,'foo')
%    write(ff.input2,value2) % perform a separate write to 'input2'
%    o = run(ff,input3,value3,input1,value1) % correct order of inputs not required
% 
%     See also GOTO, EXECUTE, WRITE.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/06 01:04:58 $

if ~ishandle(ff),
    errId = generateccsmsgid('InvalidHandle');
    error(errId,'First parameter must be a valid FUNCTION handle.');
end

% Assign/Write values to specified inputs
p_writeinputs(ff,varargin);

% Go to start of function - prepare function for execution
goto(ff);

% Run function
resp = execute(ff);

% [EOF] run.m