function varargout = vitdec(code,trellis,tblen,opmode,dectype,varargin)
%VITDEC Convolutionally decode binary data using the Viterbi algorithm.
%   DECODED = VITDEC(CODE,TRELLIS,TBLEN,OPMODE,DECTYPE) decodes the vector CODE
%   using the Viterbi algorithm.  CODE is assumed to be the output of a 
%   convolutional encoder specified by the MATLAB structure TRELLIS.  See
%   POLY2TRELLIS for a valid TRELLIS structure.  Each symbol in CODE consists 
%   of log2(TRELLIS.numOutputSymbols) bits, and CODE may contain one or more 
%   symbols.  DECODED is a vector in the same orientation as CODE, and each of 
%   its symbols consists of log2(TRELLIS.numInputSymbols) bits.  TBLEN is a 
%   positive integer scalar that specifies the traceback depth.
%    
%      OPMODE denotes the operation mode of the decoder. Choices are:
%      'trunc' : The encoder is assumed to have started at the all-zeros state.  
%                The decoder traces back from the state with the best metric.
%      'term'  : The encoder is assumed to have both started and ended at the 
%                all-zeros state.  The decoder traces back from the all-zeros
%                state.
%      'cont'  : The encoder is assumed to have started at the all-zeros state.
%                The decoder traces back from the state with the best metric.  A
%                delay equal to TBLEN symbols is incurred.
%    
%      DECTYPE denotes how the bits are represented in CODE.  Choices are:
%      'unquant' : The decoder expects signed real input values.  +1 represents
%                  a logical zero and -1 represents a logical one.
%      'hard'    : The decoder expects binary input values.
%      'soft'    : See the syntax below.
%
%   DECODED = VITDEC(CODE,TRELLIS,TBLEN,OPMODE,'soft',NSDEC) decodes the input
%   vector CODE consisting of integers between 0 and 2^NSDEC-1, where
%   0 represents the most confident 0 and 2^NSDEC-1 represents the most 
%   confident 1.
%   Note that NSDEC is a required argument if and only if the decision type is
%   'soft'.
%    
%   DECODED = VITDEC(..., 'cont', ..., INIT_METRIC,INIT_STATES,INIT_INPUTS)
%   provides the decoder with initial state metrics, initial traceback states
%   and initial traceback inputs.  Each real number in INIT_METRIC represents
%   the starting state metric of the corresponding state.  INIT_STATES and 
%   INIT_INPUTS jointly specify the initial traceback memory of the decoder.
%   They are both TRELLIS.numStates-by-TBLEN matrices.  INIT_STATES consists of
%   integers between 0 and TRELLIS.numStates-1.  INIT_INPUTS consists of 
%   integers between 0 and TRELLIS.numInputSymbols-1.  To use default values for
%   all of the last three arguments, specify them as [],[],[].
%   
%   [DECODED FINAL_METRIC FINAL_STATES FINAL_INPUTS] = VITDEC(..., 'cont', ...)
%   returns the state metrics, traceback states and traceback inputs at the end
%   of the decoding process.  FINAL_METRIC is a vector with TRELLIS.numStates 
%   elements which correspond to the final state metrics.  FINAL_STATES and 
%   FINAL_INPUTS are TRELLIS.numStates-by-TBLEN matrices.
%   
%   Example:
%      t = poly2trellis([3 3],[4 5 7;7 4 2]);  k = log2(t.numInputSymbols);
%      msg = [1 1 0 1 1 1 1 0 1 0 1 1 0 1 1 1];
%      code = convenc(msg,t);    tblen = 3;
%      [d1 m1 p1 in1]=vitdec(code(1:end/2),t,tblen,'cont','hard');
%      [d2 m2 p2 in2]=vitdec(code(end/2+1:end),t,tblen,'cont','hard',m1,p1,in1);
%      [d m p in] = vitdec(code,t,tblen,'cont','hard');
%    
%      The same decoded message is returned in d and [d1 d2].  The pairs m and 
%      m2, p and p2, in and in2 are equal.  Note that d is a delayed version of 
%      msg, so d(tblen*k+1:end) is the same as msg(1:end-tblen*k).
%    
%   See also CONVENC, POLY2TRELLIS, ISTRELLIS.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.15.4.2 $  $Date: 2004/04/12 23:01:27 $
% Author : Katherine Kwong
% Calls vit.c

% Check number of input arguments
error(nargchk(5,9,nargin));

nvarargin = nargin - 5;

% Check number of output arguments
if nargout>4
    error('Too many output arguments.');
end

% Define macros

% Opmode
CONT  = 1;
TRUNC = 2;
TERM  = 3;

% Dectype
UNQUANT = 1;
HARD    = 2;
SOFT    = 3;

% Value set indicators (used for setting optional inputs)
initTableSet  = 0;

% Set default values for optional inputs
nsdec         = 1;
initmetric    = [];
initstate     = [];
initinput     = [];

% --- Placeholders for the numeric and string index values
numArg = [];
strArg = [];

% Check trellis
if ~istrellis(trellis),
    error('Trellis is not valid.');
end

k = log2(trellis.numInputSymbols);
n = log2(trellis.numOutputSymbols);
outputs = oct2dec(trellis.outputs);

if ~ischar(opmode)
    error('Operation mode must be specified by a character string.');
end
if ~ischar(dectype)
    error('Decision type must be specified by a character string.');
end

% Set opmode
switch lower(opmode)
case {'cont'}
   opmodeNum = CONT;
case {'trunc'}
   opmodeNum = TRUNC;
case {'term'}
   opmodeNum = TERM;
otherwise
   error('Unknown operation mode passed in.');
end;

% Check : only 1 output is allowed for 'term and 'trunc' modes
if ( opmodeNum~=CONT & nargout>1 )
    error(sprintf(['The decoded message is the only output allowed '...
           'for the Truncated and Terminated\n'...
           'operation modes.']))
end

% Set dectype
switch lower(dectype)
case {'unquant'}
   dectypeNum = UNQUANT;
case {'hard'}
   dectypeNum = HARD;
case {'soft'}
   dectypeNum = SOFT;
otherwise
   error('Unknown decision type passed in.');
end;

% --- Identify string and numeric arguments
for nn=1:nvarargin
   if(isnumeric(varargin{nn}))
      numArg(size(numArg,2)+1) = nn;
   else
      error('Only numeric arguments are allowed for the optional inputs.');
   end;
end;

% --- Build the numeric argument set
switch(length(numArg))

   case 0 
      % --- only allowed in 'trunc' or 'term' opmode w/ 'unquant' or hard' dectype
      
      if (dectypeNum == SOFT)
          error(['Number of soft decision bits must be provided ' ,...
                 'for the ''soft'' decision type.']);
      end
      
   case 1
      % --- only nsdec is provided : i.e. soft

      if (dectypeNum == SOFT)
            nsdec    = varargin{numArg(1)};
            
      elseif (opmodeNum == CONT)
         if isscalar(varargin{numArg(1)})
            error(sprintf(['One optional input argument has been provided.  ' ,...
                  'This can only represent the\n' ,...
                  'number of soft decision bits, but the specified operation mode is not ''soft''.\n']))
            
         elseif isempty(varargin{numArg(1)})
            error(sprintf(['In order to use the default values for ' ,...
                  'INIT_METRIC, INIT_STATES and INIT_INPUTS,\n' ,...
                  'all three of them must be specified as [].']))
            
         else
            error(sprintf(['To specify initial metrics, states and input, all three of them ' ,...
                  'must be provided\n' ,...
                  'at the same time.']))
         end;
         
      else
         error(sprintf(['One optional input argument has been provided.  ' ,...
               'This can only be the number of\n' ,...
               'soft decision bits, but the operation mode is not ''soft''.']))
      end
         
   case 2
      % --- not allowed
      
      if (opmodeNum == CONT)
         if isempty(varargin{numArg(1)}) | isempty(varargin{numArg(2)})
            error(sprintf(['Two optional input arguments have been provided.  ' ,...
                  'To use the default values for\n' ,...
                  'INIT_METRIC, INIT_STATES and ' ,...
                  'INIT_INPUTS, all three of them are required to be\n' ,...
                  'the empty matrix [].']))
            
         else
            error(sprintf(['Invalid syntax.  To specify initial metrics, states and inputs, ' ,...
                  'all three of\n' ,...
                  'them must be provided at the same time.']))
         end
         
      else
          error('Seven input arguments have been provided.  Invalid syntax.')
      end
      
   case 3
      % --- initmetric is first (element 1), initstate (element 2), initinput (element 3)

      if (opmodeNum == CONT)
         if dectypeNum~=SOFT
            initmetric    = varargin{numArg(1)};
            initstate     = varargin{numArg(2)};
            initinput     = varargin{numArg(3)};
            
            if ~(isempty(initmetric) & isempty(initstate) & isempty(initinput))
               initTableSet  = 1;      % Indicates that traceback memory is given
            end
            
         elseif isscalar(varargin{numArg(1)})
            error(sprintf(['Invalid syntax.  To specify initial metrics, states and inputs,' ,...
                  'all three of them\n' ,...
                  'must be provided at the same time.']))
         else
            error(sprintf(['To use the ''soft'' decision type, the number of soft ' ,...
                  'decision bits must be\n' ,...
                  'specified.']))
         end
         
      else
         error(sprintf(['Eight input arguments have been provided.  ' ,...
                'This is only allowed for the ''cont''\n' ,...
                'mode used with the ''unquant'' or ''hard'' decision type.']))
      end;
      
   case 4
      % --- nsdec, initmetric, initstate, initinput provided : 
      %       (only allowed in 'cont' mode w/ 'soft' dectype)

      if (opmodeNum == CONT & dectypeNum == SOFT)
         nsdec         = varargin{numArg(1)};
         initmetric    = varargin{numArg(2)};
         initstate     = varargin{numArg(3)};
         initinput     = varargin{numArg(4)};
          
         if ~(isempty(initmetric) & isempty(initstate) & isempty(initinput))
            initTableSet  = 1;      % Indicates that traceback memory is given
         end
         
      else
         error(sprintf(['Nine input arguments have been provided.  ' ,...
                'This is only allowed for the ''cont''\n' ,...
                'mode used with the ''soft'' decision type.']))
      end;

   otherwise
      error('Invalid syntax.  Too many input arguments.')
end;


% Check code
if ~isempty(code)

    code_dim = size(code);
    if ~isnumeric(code) | code_dim >2 | ~( isvector(code) && ~isscalar(code) ) ...
            | max(max(~isfinite(code))) | (~isreal(code))
        error('CODE must be a vector of real numbers.')
    end
    
    if max(max(code < 0)) | (max(max(floor(code) ~= code)))
        if dectypeNum == HARD & max(max(code)) > 1
            error('For hard decision type, CODE must contain only binary numbers.');
        elseif dectypeNum == SOFT & max(max(code)) > 2^nsdec-1
            error(['For soft decision type, CODE must contain only integers ', ...
                    'between 0 and 2^NSDEC-1.']);
        end
    end
    
    if mod(length(code), n) ~=0
        error(sprintf(['Length of the input code vector must be a multiple of the ', ...
                'number of bits in an\n' ,...
                'output symbol.']))
    end
    
    % Get code orientation
    if code_dim(1)>1
        code_flip = 1;
        code=code';
    else
        code_flip = 0;
    end
    
end

% Check tblen
if ~isscalar(tblen) | ~isnumeric(tblen) | ~isreal(tblen) ...
 | ~isfinite(tblen) | tblen<=0 | floor(tblen)~=tblen  
    error('Traceback depth must be a positive integer scalar.');

elseif ~isempty(code) & (opmodeNum ~= CONT & tblen>length(code)/n )
    error(sprintf(['For the ''cont'' mode, traceback depth must be ', ...
           'a positive integer scalar not\n', ...
           'larger than the number of input symbols in CODE.']))
end

% Check nsdec if dectype=='soft'
if (dectypeNum == SOFT)
    if ~isscalar(nsdec) | ~isnumeric(nsdec) | ~isreal(nsdec) ...
      | nsdec<0 | floor(nsdec)~=nsdec 
        error(['Number of soft decision bits must be a positive ', ...
        'scalar integer.']);
    end
end

% Check initmetric, initstate, initinput
if (initTableSet == 1)
    if ~isnumeric(initmetric) | ~( isvector(initmetric) && ...
        ~isempty(initmetric) && ~isscalar(initmetric) ) ...
            | length(initmetric)~=trellis.numStates | max(max(~isfinite(initmetric))) ...
            | (~isreal(initmetric))
         
       if isempty(initmetric)
          error(sprintf(['When using [] as the default for INIT_METRIC, ' ,...
                'INIT_STATES and INIT_INPUTS must\n' ,...
                'also be [].']))
       else
          error(sprintf(['The inital state metrics must be a real vector with length ' ,...
                'equal to the number\n' ,...
                'of states in the specified trellis.']))
       end
       
    end
    
    dimState = size(initstate);
    if ~isnumeric(initstate) | ~isequal([dimState], [trellis.numStates tblen])  ...
            | max(max(~isfinite(initstate))) | (~isreal(initstate))...
            | max(max(floor(initstate)~=initstate)) | min(initstate(:))<0 ...
            | max(initstate(:)>trellis.numStates-1)
         
       if isempty(initstate)
          error(sprintf(['When using [] as the default for INIT_STATES, ' ,...
                'INIT_METRIC and INIT_INPUTS must\n' ,...
                'also be [].']))
       else
          error(sprintf(['The initial traceback states must be integers ' ,...
                'between 0 and\n' ,...
                '(number of states - 1), arranged in a matrix.  ' ,...
                'Its number of rows must equal the\n' ,...
                'number of states in the specified trellis, ' ,...
                'and its number of columns must equal\n' ,...
                'the traceback depth.']))
       end
            
    end
    
    dimInput = size(initinput);
    if ~isnumeric(initinput) | ~isequal([dimInput], [trellis.numStates tblen]) ...
            | max(max(~isfinite(initinput))) | (~isreal(initinput))...
            | max(max(floor(initstate)~=initstate)) | min(initstate(:))<0 ...
            | max(initstate(:)>trellis.numStates-1)
         
       if isempty(initinput)
          error(sprintf(['When using [] as the default for INIT_INPUTS, ' ,...
                'INIT_METRIC and INIT_STATES must\n' ,...
                'also be [].']))
       else
          error(sprintf(['The initial traceback inputs must be integers ' ,...
                'between 0 and\n' ,...
                '(number of states - 1), arranged in a matrix.  ' ,...
                'Its number of rows must equal the\n' ,...
                'number of states in the specified trellis, ' ,...
                'and its number of columns must equal\n' ,...
                'the traceback depth.']))
       end
         
    end
end

% Return if input code is empty
if isempty(code)   
    varargout{1} = [];
    varargout{2} = initmetric;
    varargout{3} = initstate;
    varargout{4} = initinput;
    return;
end

% Call to vit.c
[varargout{1} varargout{2} varargout{3} varargout{4}] ...
    = vit(code,k,n,trellis.numStates,outputs,trellis.nextStates,tblen,opmodeNum, ...
      dectypeNum,nsdec,initTableSet,initmetric,initstate,initinput);

% Change message back to same orientation as the input code if needed
if code_flip
    varargout{1}=(varargout{1})';
end

% [EOF]
