function [intrlved, state]  = muxintrlv(data,delay,varargin)
% MUXINTRLV Permute symbols using a set of shift registers with specified delays.
%  INTRLVED = MUXINTRLV(DATA, DELAY) permutes the elements in DATA by using
%  internal shift registers, each with its own delay value. DELAY is a
%  vector whose entries indicate how many symbols each shift register can
%  hold. The length of this vector is the number of shift registers. The
%  resulting interleaved data is stored in INTRLVED. If DATA is a matrix,
%  each column is treated as a separate channel and is processed independently.
%  
%  [INTRLVED STATE] = MUXINTRLV(DATA, DELAY) returns a structure that holds
%  the final state of the shift registers. STATE.VALUE stores any unshifted
%  symbols. STATE.INDEX is the index of the next register to be shifted.
%
%  [INTRLVED STATE] = MUXINTRLV(DATA, DELAY, INIT_STATE) initializes  the
%  shift registers with the symbols contained in INIT_STATE.VALUE, starting
%  from the shift register referenced by INIT_STATE.INDEX. INIT_STATE must
%  be a structure with two fields. INIT_STATE is typically the STATE output
%  from a previous call to this function.
% 
%  See also MUXDEINTRLV.

%  Copyright 1996-2004 The MathWorks, Inc. 
%  $Revision: 1.1.6.4 $ $Date: 2004/04/08 20:48:12 $

% --- Initialization of variables
isDataRowVector = 0;
if (size(data,1)==1)
    data = transpose(data);
    isDataRowVector = 1;
end
input_data = data;
orig_data = data;
final_reg = cell(length(delay),1)';
output =[];
prev_output = [];
reg_idx = 1;  
[del_row del_col] = size(delay);

% --- Error Checking
if nargin > 3
    error('comm:muxintrlv:TooManyInp','Too many input arguments.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:muxintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if isa(data,'gf')
    gf_data = data.x;        % Obtain data values from Galois array
    gf_order = data.m;
    gf_primpoly = data.prim_poly;
    data = double(gf_data);  % Convert gf_data from uint16 to double
    input_data = data;
end

if isempty(delay)
    error('comm:muxintrlv:DelayIsEmpty','DELAY must be a nonempty array of positive integers.');
elseif ~isnumeric(delay)
    error('comm:muxintrlv:DelayIsNotAPosInt','DELAY must be a vector of positive integers.');
end

if (del_row > 1 && del_col > 1)
    error('comm:muxintrlv:DelayIsMatrix','DELAY must be a vector.');
end

if any([(delay < 0) (delay ~= floor(delay))])
    error('comm:muxintrlv:DelayIsNotAPosInt','DELAY must be an vector of positive integers.');
end

% --- If INIT_STATE is passed as an argument
if nargin == 3      
    % --- Check if STATE is a structure with two fields
    if ~isstruct(varargin{1})
        error('comm:muxintrlv:Init_stateIsNotAStruct','INIT_STATE must be a structure.')
    end
    
    if (length(fieldnames(varargin{1})) < 1 || length(fieldnames(varargin{1})) > 2)
        error('comm:muxintrlv:Init_stateTooManyFields','INIT_STATE must be a structure with two fields.');
    end
    
    % --- Check if STATE is valid
    if ~iscell(varargin{1}.value)
        error('comm:muxintrlv:Init_stateIsNotACell','INIT_STATE.VALUE must be a cell array.');
    end
    
    % Make sure that the STATE is in correct format.
    if all([~isempty(varargin{1}.value{1,1}) (size(varargin{1}.value{1,1},2)~=1)])
            error('comm:muxintrlv:Init_stateIncorrectFormat', 'INIT_STATE.VALUE must be a cell array of vectors having lengths equal to the corresponding delay values.');
    end
    for idx = 2:size(varargin{1}.value,1)
        if (size(varargin{1}.value{idx,1},2)~=delay(idx))
            error('comm:muxintrlv:Init_stateIncorrectFormat', 'INIT_STATE.VALUE must be a cell array of vectors having lengths equal to the corresponding delay values.');
        end
    end
    
    for i = 1:size(varargin{1}.value,2)   
        if (~isnumeric(varargin{1}.value{i}) && ~isa(varargin{1}.value{i},'gf'))
            error('comm:muxintrlv:Init_stateIsNotNumeric','INIT_STATE.VALUE must be a cell array of numeric values.');
        end
        
        if ~isnumeric(orig_data)
            if ~(isa(orig_data,'gf') && isa(varargin{1}.value{i},'gf'))
                error('comm:muxintrlv:InvalidDataAndInit_state','Both DATA and INIT_STATE.VALUE must be numeric or Galois field array.');                  
            elseif isa(varargin{1}.value{i},'gf')
                gf_state.value{i} = varargin{1}.value{i}.x;         % Obtain data values from each cell
                varargin{1}.value{i} = double(gf_state.value{i});   % Convert INIT_STATE from uint16 to double
            end
        end
    end      
    
    if (size(varargin{1}.value,2) > length(delay(:)))
        error('comm:muxintrlv:Init_stateTooManyRegs','The number of shift registers must be equal to the length of DELAY.');
    end
    
    if any([(varargin{1}.index < 1) (length(varargin{1}.index) > 1) ~isnumeric(varargin{1}.index)])
        error('comm:muxintrlv:IndexIsNotAPosInt','INIT_STATE index must be a positive scalar integer greater than zero.');
    end
    
    init_state = varargin{1};     % obtain INIT_STATE if no errors
end

% --- Obtain output and shift data in each register
for col_idx = 1:size(data,2)
    if nargin == 3
        shift_reg = {init_state.value{:,col_idx}};
        reg_idx = init_state.index;
    else
        shift_reg = init_register(delay);     % Call subfunction init_register to re-initialize shift registers  
        reg_idx = 1;
    end
    data = input_data(:,col_idx);
    for data_idx = 1:length(data)
        if (isempty(shift_reg{reg_idx}))         % If delay for register is zero               
            output = [output data(data_idx)];    % Put sample into output
        else
            output = [output shift_reg{reg_idx}(1)];    % Otherwise put sample into output
            
            % --- Shift oldest symbol in register out
            shift_reg{reg_idx} = circshift(shift_reg{reg_idx},[0 -1]);
            shift_reg{reg_idx}(end) = data(data_idx);
        end
        % update indexes
        reg_idx = mod(reg_idx,length(delay))+1;     
    end
    
    final_output = vertcat(prev_output,output);
    final_reg = vertcat(final_reg,shift_reg);
    prev_output = final_output;
    output = [];
    if isequal(col_idx,1)
        final_reg = shift_reg;
    end
end

% Returns interleaved data and state values
if (~isDataRowVector)
    intrlved = transpose(final_output); 
else
    intrlved = final_output;
end
state.value = transpose(final_reg);   % Stores all unshifted symbols
state.index = reg_idx;      % Stores the index of the next register to be shifted 

% --- Returns output as a Galois field (GF) array if data is a GF array
if isa(orig_data,'gf')     % Convert outputs back to Galois object
    intrlved = gf(intrlved,gf_order,gf_primpoly);
    for i = 1:length(state.value)
        state.value{i} = gf(state.value{i},gf_order,gf_primpoly);
    end
end

% --- Subfunction to initialize registers to zero
function shift_reg = init_register(delay)
for i = 1:length(delay)
    if isequal(delay(i),0)  % check if delay is zero
        shift_reg{i} = [];  
    else
        shift_reg{i} = zeros(1,delay(i));
    end
end 
% [EOF] muxintrlv.m