function [intrlved, state]  = convintrlv(data,nrows,slope,varargin)
% CONVINTRLV Permute symbols using a set of shift registers.
%  INTRLVED = CONVINTRLV(DATA, NROWS, SLOPE) permutes the elements in DATA
%  by using internal shift registers. The delay value of the kth shift
%  register is (k-1)*SLOPE, where SLOPE is the register length step.  NROWS
%  is the number of shift registers. The resulting interleaved data is
%  stored in INTRLVED. If DATA is a matrix, each column is treated as 
%  a separate channel and is processed independently.
%
%  [INTRLVED STATE] = CONVINTRLV(DATA, NROWS, SLOPE) returns a structure
%  that holds the final state of the shift registers. STATE.VALUE stores
%  any unshifted symbols. STATE.INDEX is the index of the next register to
%  be shifted.
%
%  [INTRLVED STATE] = CONVINTRLV(DATA, NROWS, SLOPE, INIT_STATE)
%  initializes  the shift registers with the symbols contained in
%  INIT_STATE.VALUE, starting from the shift register referenced by
%  INIT_STATE.INDEX. INIT_STATE is typically the STATE output from a
%  previous call to this function.
% 
%  See also CONVDEINTRLV.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:00:34 $

% --- Error Checking
if nargin > 4
    error('comm:convintrlv:TooManyInp','Too many input arguments.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:convintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if any([~isscalar(nrows) ~(nrows > 0) ~isnumeric(nrows)])
    error('comm:convintrlv:NrowsIsNotAPosScalar','NROWS must be a positive scalar.');
elseif ~isequal(nrows,floor(nrows))
    error('comm:convintrlv:NrowsIsNotAPosInt','NROWS must be a positive integer.');
end

if any([~isscalar(slope) ~(slope > 0) ~isnumeric(slope)])
    error('comm:convintrlv:SlopeIsNotAPosScalar','SLOPE must be a positive scalar.');
elseif ~isequal(slope,floor(slope))
    error('comm:convintrlv:SlopeIsNotAPosInt','SLOPE must be a positive integer.');
end

% --- Initialize variables
delay = 0:slope:slope*(nrows-1);
delay = delay(:);

% --- No States
if nargin == 3
    [intrlved, state] = muxintrlv(data,delay);
end

% --- State is passed as an argument
if nargin == 4
    init_state = varargin{1};
    [intrlved, state] = muxintrlv(data,delay,init_state);
end
% [EOF] convintrlv.m
