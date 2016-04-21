function [intrlved, state]  = helintrlv(data,col,ngrp,stp,varargin)
% HELINTRLV Permute symbols using a helical array.
%  INTRLVED = HELINTRLV(DATA, COL, NGRP, STP) permutes DATA using a helical
%  array with COL columns and unlimited rows. HELINTRLV processes DATA in
%  groups of size NGRP and assigns an index to each group. The kth group of
%  NGRP symbols is entered sequentially down column k mod COL of the
%  helical array and beginning in row 1+(k-1)*STP. The helical interleaver
%  output is then read row-by-row from the helical array. STP must be a
%  nonnegative integer. If DATA is a matrix, each column is treated 
%  as a separate channel and is processed independently.
%
%  [INTRLVED STATE] = HELINTRLV(DATA, COL, NGRP, STP) returns a structure
%  that holds the final state of the helical array. STATE.VALUE stores the
%  next group of symbols to be shifted. 
%
%  [INTRLVED STATE] = HELINTRLV(DATA, COL, NGRP, STP, INIT_STATE) uses an
%  initial state structure, INIT_STATE, to initialize the helical array.
%  INIT_STATE must be a structure with two fields. INIT_STATE is typically
%  the STATE output from a previous call to this function.
% 
%  See also HELDEINTRLV.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $ $Date: 2004/04/12 23:00:41 $

% --- Error Checking
if nargin > 5
    error('comm:helintrlv:TooManyInp','Too many input arguments.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:helintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if any([~isscalar(col) ~(col > 0) ~isnumeric(col)])
    error('comm:helintrlv:ColIsNotAPosScalar','COL must be a positive scalar integer.')
elseif ~isequal(col,floor(col))
    error('comm:helintrlv:ColIsNotAPosInt','COL must be a positive integer.')
end

if any([~isscalar(ngrp) ~(ngrp > 0) ~isnumeric(ngrp)])
    error('comm:helintrlv:NgrpIsNotAPosScalar','NGRP must be a positive scalar integer.')
elseif ~isequal(ngrp,floor(ngrp))
    error('comm:helintrlv:NgrpIsNotAPosInt','NGRP must be a positive integer.')
end

needTranspose = 0;
if (size(data,1)==1)
    data = transpose(data);
    needTranspose = 1;
    if ~isequal(length(data(:,1)),(col*ngrp))
        error('comm:helintrlv:RowByNgrpIsInvalid','DATA must contain COL*NGRP elements.');
    end
elseif ~isequal(length(data(:,1)),(col*ngrp))
    error('comm:helintrlv:ColByNgrpIsInvalid','Each column in DATA must contain COL*NGRP elements.');
end

if any([~isscalar(stp) ~(stp > 0) ~isnumeric(stp)])
    error('comm:helintrlv:StpIsNotAPosScalar','STP must be a positive scalar integer.')
elseif ~isequal(stp,floor(stp))
    error('comm:helintrlv:StpIsNotAPosInt','STP must be a positive integer.')
end

% --- Initialize variables
output = matintrlv(data,col,ngrp);
delay = 0:stp:(col-1)*stp;

% --- No States
if nargin == 4
    [intrlved, outstate] = muxintrlv(output,delay);
end

% --- State is passed as an argument
if nargin == 5
    instate = varargin{1};
    instate.index = 1;
    [intrlved, outstate] = muxintrlv(output,delay,instate);
end
state.value = outstate.value;

if(needTranspose)
    intrlved = transpose(intrlved);
end
% [EOF] helintrlv.m
