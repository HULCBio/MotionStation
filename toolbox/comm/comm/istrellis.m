function [isOk, status]  = istrellis(S)
%ISTRELLIS True for a valid trellis structure.
%   [ISOK, STATUS] = ISTRELLIS(S) checks if the input S is a valid trellis
%   structure.  If the input is a valid trellis structure, ISOK is 1, and
%   STATUS is an empty string. Otherwise ISOK is 0, and STATUS is a string
%   which indicates why S is not a valid trellis.
%
%   A trellis structure has the following fields:
%
%     numInputSymbols,  (number of input symbols)
%     numOutputSymbols, (number of output symbols)
%     numStates,        (number of states)
%     nextStates,       (next state matrix)
%     outputs,          (output matrix)
%
%   If the input is represented by k bits and output represented by n bits,
%   numInputSymbols = 2^k and numOutputSymbols = 2^n. The numStates field
%   stores the number of states. The 'nextStates' and 'outputs' fields are
%   matrices with 'numStates' rows and 'numInputSymbols' columns.
%
%   Each element in the 'nextStates' matrix is an integer value between 0 and
%   (numStates-1). The (s,u) element of the 'nextStates' matrix, i.e., the
%   element in the s-th row and u-th column, denotes the next state when
%   the starting state is (s-1) and the input bits have decimal
%   representation (u-1).  To convert to decimal value, use the first input
%   bit as the most significant bit (MSB).  For example, the second column
%   of the 'nextStates' matrix stores the next states when the last input is
%   1 and the other inputs are 0.
%
%   The (s,u) element of the 'outputs' matrix denotes the output when the
%   starting state is (s-1) and the input bits have decimal representation
%   (u-1). To convert to decimal value, use the first output bit as the MSB.
%
%   See also POLY2TRELLIS, STRUCT, CONVENC, VITDEC.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2003/10/09 17:48:24 $

status = '';

% Typical error checking.
msg = nargchk(1,2,nargin);
if ~isempty(msg),
  isOk = logical(0);
  status = msg;
  return;
end

% The input must be structure
isOk = isstruct(S);
if ~isOk,
  status = 'The input argument must be a structure.';
  return;
end;

% The input must have valid field names
actNames  = fieldnames(S);
numfields = size(actNames, 1);

expNames = {'numInputSymbols';  ...
	    'numOutputSymbols'; ...
	    'numStates';        ...
	    'nextStates';       ...
	    'outputs'};

isOk = (numfields == 5) & isequal(sort(actNames),sort(expNames));
if ~isOk,
  status = ['The input argument must be a structure with the following ' ...
	    'fields: numInputSymbols, numOutputSymbols, numStates, ' ...
	    'nextStates and outputs.'];
  return;
end;

%%% Check numInputSymbols.
numInputSymbols = S.numInputSymbols;
isOk = isequal(length(numInputSymbols), 1);
if ~isOk,
  status = 'The numInputSymbols field must be a scalar value.';
  return;
end;

tmp  = log2(numInputSymbols);
isOk = isequal(tmp, double(int32(tmp)));
if ~isOk,
  status = 'The numInputSymbols field must be a power of 2.';
  return;
end;

%%% Check numOutputSymbols.
numOutputSymbols = S.numOutputSymbols;
isOk = isequal(length(numOutputSymbols), 1);
if ~isOk,
  status = 'The numOutputSymbols field must be a scalar value.';
  return;
end;

tmp  = log2(numOutputSymbols);
isOk = isequal(tmp, double(int32(tmp)));

if ~isOk,
  status = 'The numOutputSymbols field must be a power of 2.';
  return;
end;

%%%% Check numStates
isOk = isequal(length(S.numStates), 1) & ...
       isequal(S.numStates, double(int32(S.numStates)));
if isOk
  isOk =  S.numStates > 0;
end

if ~isOk,
  status = 'The numStates field must be a scalar, positive integer value.';
  return;
end;

%%%% Check nextStates
nextStates = S.nextStates;
numStates  = S.numStates;

% nextStates field must be a 2d octal matrix with correct size.
tmp = size(nextStates);
isOk =  (length(tmp) == 2)          & ...
        (tmp(1) == numStates)       & ...
	(tmp(2) == numInputSymbols) & ...
	isequal(double(uint32(nextStates)), nextStates);
if ~isOk,
  status = ['The ''nextStates'' field must be an unsigned integer ' ...
	    'matrix with numStates rows and numInputSymbols columns.'];
  return;
end;

% nextStates must be between zero and (numStates - 1)
isOk = isempty(find(nextStates >= numStates));
if ~isOk,
  status = ['Each element of the ''nextStates'' matrix must be between ' ...
	    '0 and numStates-1.'];
  return;
end;

%%%  Check outputs
outputs  = S.outputs;

% Outputs field must be a 2d octal matrix with correct size.
tmp  = size(outputs);
isOk =  (length(tmp) == 2)         & ...
	(tmp(1) == numStates)      & ...
	(tmp(2)== numInputSymbols) & ...
	isoctal(outputs);
if ~isOk,
  status =  ['The ''outputs'' field must be an octal matrix with ' ...
	     'numStates rows and numInputSymbols columns.'];
  return;
end;


% Decimal output values must be between zero and (numOutputSym - 1)
decOutputs = oct2dec(outputs);
isOk = isempty(find(decOutputs >= numOutputSymbols));
if ~isOk,
  status = ['Each element of the ''outputs'' matrix (in decimal format) ' ...
	    'must be between 0 and numOutputSymbols-1.'];
  return;
end;
