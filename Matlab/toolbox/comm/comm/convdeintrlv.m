function [deintrlved, state]  = convdeintrlv(data,nrows,slope,varargin)
% CONVDEINTRLV Restore ordering of symbols permuted using shift registers.
%  DEINTRLVED = CONVDEINTRLV(DATA, NROWS, SLOPE) rearranges the elements in
%  DATA by using internal shift registers. The delay value of the kth shift
%  register is (NROWS-k)*SLOPE, where SLOPE is the register length step and
%  NROWS is the number of shift registers. The resulting deinterleaved data
%  is stored in DEINTRLVED. If DATA is a matrix, each column is treated 
%  as a separate channel and is processed independently.
%
%  [DEINTRLVED STATE] = CONVDEINTRLV(DATA, NROWS, SLOPE) returns a
%  structure that holds the final state of the shift registers. STATE.VALUE
%  stores any unshifted symbols. STATE.INDEX is the index of the next
%  register to be shifted.
%
%  [DEINTRLVED STATE] = CONVDEINTRLV(DATA, NROWS, SLOPE, INIT_STATE)
%  initializes  the shift registers with the symbols contained in
%  INIT_STATE.VALUE, starting from the shift register referenced by
%  INIT_STATE.INDEX. INIT_STATE is typically the STATE output from a
%  previous call to this function.
% 
%  See also CONVINTRLV.

%  Copyright 1996-2004 The MathWorks, Inc. 
%  $Revision: 1.1.6.4 $ $Date: 2004/04/08 20:48:06 $


% --- Error Checking
if nargin > 4
    error('comm:convdeintrlv:TooManyInp','Too many input arguments.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:convdeintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if any([~isscalar(nrows) ~(nrows > 0) ~isnumeric(nrows)])
    error('comm:convdeintrlv:NrowsIsNotAPosScalar','NROWS must be a positive scalar.');
elseif ~isequal(nrows,floor(nrows))
    error('comm:convdeintrlv:NrowsIsNotAPosInt','NROWS must be a positive integer.');
end

if any([~isscalar(slope) ~(slope > 0) ~isnumeric(slope)])
    error('comm:convdeintrlv:SlopeIsNotAPosScalar','SLOPE must be a positive scalar.');
elseif ~isequal(slope,floor(slope))
    error('comm:convdeintrlv:SlopeIsNotAPosInt','SLOPE must be a positive integer.');
end

% --- Initialize variables
delay = 0:slope:slope*(nrows-1);
delay = delay(:);

% --- No States
if nargin == 3
    [deintrlved, state] = muxdeintrlv(data,delay);
end

% --- State is passed as an argument
if nargin == 4
    init_state = varargin{1};
    [deintrlved, state] = muxdeintrlv(data,delay,init_state);
end
% [EOF] convdeintrlv.m