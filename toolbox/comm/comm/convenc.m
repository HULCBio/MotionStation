function varargout = convenc(msg,trellis,varargin)
%CONVENC Convolutionally encode binary data.
%   CODE = CONVENC(MSG,TRELLIS) encodes the binary vector MSG using the
%   convolutional encoder defined by the MATLAB structure TRELLIS.  See
%   POLY2TRELLIS and ISTRELLIS for a valid TRELLIS structure.  The encoder
%   starts at the all-zeros state.  Each symbol in MSG consists of
%   log2(TRELLIS.numInputSymbols) bits.  MSG may contain one or more symbols.
%   CODE is a vector in the same orientation as MSG, and each of its symbols
%   consists of log2(TRELLIS.numOutputSymbols) bits.
%
%   CODE = CONVENC(MSG,TRELLIS,INIT_STATE) is the same as the syntax above,
%   except that the encoder registers start at a state specified by INIT_STATE.
%   INIT_STATE is an integer between 0 and TRELLIS.numStates - 1.  To use the
%   default value for INIT_STATE, specify it as 0 or [].
%
%   [CODE FINAL_STATE] = CONVENC(...) returns the final state FINAL_STATE of
%   the encoder after processing the input message.
%
%   Example:
%      t = poly2trellis([3 3],[4 5 7;7 4 2]);
%      msg = [1 1 0 1 0 0 1 1];
%      [code1 state1]=convenc([msg(1:end/2)],t);
%      [code2 state2]=convenc([msg(end/2+1:end)],t,state1);
%      [codeA stateA]=convenc(msg,t);
%
%      The same result will be returned in [code1 code2] and codeA.
%      The final states state2 and stateA are also equal.
%
%   See also VITDEC, POLY2TRELLIS, ISTRELLIS.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.11.4.2 $  $Date: 2004/04/12 23:00:33 $
% Calls convcore.c

% Typical error checking.
error(nargchk(2,3,nargin));

nvarargin = nargin - 2;

% Set default
initialstate = 0;

switch (nvarargin)
case {1}
    if ~isempty(varargin{1})
       initialstate = varargin{1};
    end
end

if nargout > 2
    error('Too many output arguments.');
end

% check trellis
if ~istrellis(trellis),
    error('Trellis is not valid.');
end

% Get info out of trellis structure
k = log2(trellis.numInputSymbols);
n = log2(trellis.numOutputSymbols);
outputs = oct2dec(trellis.outputs);

% Check msg
if ~isempty(msg)
    msg_dim = size(msg);
    if ~isnumeric(msg) | msg_dim >2 | min(msg_dim)>1
        error('The input message must be a vector');
    end
    if max(max(msg < 0)) | max(max(~isfinite(msg))) | (~isreal(msg)) | (max(max(floor(msg) ~= msg))) | max(max(msg)) > 1
        error('The input message must contain only binary numbers.');
    end
    if mod(length(msg), k) ~=0
        error('Length of the input message must be a multiple of the number of bits in an input symbol.');
    end

    % Get message orientation
    if msg_dim(1)>1
        msg_flip = 1;
        msg=msg';
    else
        msg_flip = 0;
    end
end

% Check initial state
if  ~isnumeric(initialstate) | ~isscalar(initialstate) | max(max(initialstate < 0)) ...
        | max(max(~isfinite(initialstate))) ...
        | (~isreal(initialstate)) | (max(max(floor(initialstate) ~= initialstate))) ...
        | max(max(initialstate)) > trellis.numStates-1
    error(['The initial state must be an integer scalar between 0 and (TRELLIS.numStates-1).  '...
            'See POLY2TRELLIS.']);
end

% Return if input message is empty
if isempty(msg)
    varargout{1} = [];
    varargout{2} = initialstate;
    return;
end

% Actual call to core function 'convcore.c'
[varargout{1} varargout{2}] = convcore(msg,k,n,trellis.numStates,outputs,trellis.nextStates,initialstate);

% Change code back to same orientation as input MSG
if msg_flip
    varargout{1}=(varargout{1})';
end

% [EOF]
