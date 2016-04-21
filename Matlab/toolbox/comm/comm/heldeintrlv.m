function [deintrlved, state]  = heldeintrlv(data,col,ngrp,stp,varargin)
% HELDEINTRLV Restore ordering of symbols permuted using a set of shift registers.
%   [DEINTRLVED,STATE] = HELDEINTRLV(DATA,COL,NGRP,STP) restores the
%   ordering of symbols in DATA by placing them in an array row by row and
%   then selecting groups in a helical fashion to place in the output,
%   DEINTRLVED. DATA must have COL*NGRP elements. If DATA is a matrix with
%   multiple columns, then it must have COL*NGRP rows, and the function
%   processes the columns independently. STATE is a structure that holds
%   the final state of the array. STATE.VALUE stores input symbols that
%   remain in the COL columns of the array and do not appear in the output.
%   If DATA is a matrix, each column is treated as a separate channel 
%   and is processed independently.
%
%   [DEINTRLVED,STATE] = HELDEINTRLV(DATA,COL,NGRP,STP,INIT_STATE)
%   initializes the array with the symbols contained in INIT_STATE.VALUE
%   instead of zeros. The structure INIT_STATE is typically the state
%   output from a previous call to this same function, and is unrelated to
%   the corresponding interleaver. In this syntax, some output symbols are
%   default values of 0, some are input symbols from DATA, and some are
%   initialization values from INIT_STATE.VALUE.
%
%   DEINTRLVED = HELDEINTRLV(DATA,COL,NGRP,STP,INIT_STATE) is the same as
%   the syntax above, except that it does not record the deinterleaver's
%   final state. This syntax is appropriate for the last in a series of
%   calls to this function. However, if you plan to call this function
%   again to continue the deinterleaving process, then the syntax above is
%   more appropriate.
% 
%  See also HELINTRLV.

%  Copyright 1996-2004 The MathWorks, Inc. 
%  $Revision: 1.1.6.5 $ $Date: 2004/04/08 20:48:09 $


% --- Initialization of variables
orig_data = data;

% --- Error Checking
if nargin > 5
    error('comm:heldeintrlv:TooManyInp','Too many input arguments.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:heldeintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if isa(data,'gf')
    gf_data = data.x;        % Obtain data values from Galois array
    gf_order = data.m;
    gf_primpoly = data.prim_poly;
    data = double(gf_data);  % Convert gf_data from uint16 to double
end

if any([~isscalar(col) ~(col > 0) ~isnumeric(col)])
    error('comm:heldeintrlv:ColIsNotAPosScalar','COL must be a positive scalar integer.')
elseif ~isequal(col,floor(col))
    error('comm:heldeintrlv:ColIsNotAPosInt','COL must be a positive integer.')
end

if any([~isscalar(ngrp) ~(ngrp > 0) ~isnumeric(ngrp)])
    error('comm:heldeintrlv:NgrpIsNotAPosScalar','NGRP must be a positive scalar integer.')
elseif ~isequal(ngrp,floor(ngrp))
    error('comm:heldeintrlv:NgrpIsNotAPosInt','NGRP must be a positive integer.')
end

needTranspose = 0;
if (size(data,1)==1)
    data = transpose(data);
    needTranspose = 1;
    if ~isequal(length(data(:,1)),(col*ngrp))
        error('comm:heldeintrlv:RowByNgrpIsInvalid','DATA must contain COL*NGRP elements.');
    end
elseif ~isequal(length(data(:,1)),(col*ngrp))
    error('comm:heldeintrlv:ColByNgrpIsInvalid','Each column in DATA must contain COL*NGRP elements.');
end

if any([~isscalar(stp) ~(stp > 0) ~isnumeric(stp)])
    error('comm:heldeintrlv:StpIsNotAPosScalar','STP must be a positive scalar integer.')
elseif ~isequal(stp,floor(stp))
    error('comm:heldeintrlv:StpIsNotAPosInt','STP must be a positive integer.')
end

% --- Initialize variables
delay = 0:stp:(col-1)*stp;
delayLen = mod(col*ngrp-stp*col*(col-1),col*ngrp);
[nrows,ncols] = size(data);

if nargin == 4 % --- No States
    [output outstate] = muxdeintrlv(data,delay);
    state.value = outstate.value;
    if delayLen>0
        state.delay = output(end-delayLen+1:end,:);
        output = [zeros(delayLen,ncols);output(1:end-delayLen,:)];
    else
        state.delay = [];
    end
elseif nargin == 5 % --- State is passed as an argument
    init_state = varargin{1};
    mux_state.value = init_state.value;
    mux_state.index = 1;
    [output outstate] = muxdeintrlv(data,delay,mux_state);
    state.value = outstate.value;
    if delayLen>0
        state.delay = output(end-delayLen+1:end,:);
        output = [init_state.delay;output(1:end-delayLen,:)];
    else
        state.delay = [];
    end
end

deintrlved = matdeintrlv(output,col,ngrp);

% --- Returns output as a Galois field array
if isa(orig_data,'gf')     % Convert outputs back to Galois object
    deintrlved = gf(deintrlved,gf_order,gf_primpoly);
    for i = 1:length(state.value)
        state.value{i} = gf(state.value{i},gf_order,gf_primpoly);
    end
    state.delay = gf(state.delay,gf_order,gf_primpoly);
end

if(needTranspose)
    deintrlved = transpose(deintrlved);
end
% [EOF] heldeintrlv.m