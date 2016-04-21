function varargout = mlseeq(x,chcffs,const,tblen,opmode,varargin)
%MLSEEQ Equalize a linearly modulated signal using the Viterbi algorithm.
%   Y = MLSEEQ(X,CHCFFS,CONST,TBLEN,OPMODE) equalizes the baseband signal
%   vector X using the Viterbi algorithm. CHCFFS is a vector that 
%   represents the channel coefficients. CONST is a vector that defines 
%   the ideal signal constellation. TBLEN is a positive integer that 
%   specifies the traceback depth. The equalizer traces back from the 
%   state with the best metric.
%    
%   OPMODE denotes the operation mode of the equalizer.  There are two 
%   available operation modes:
%      'rst'  : No delay is associated with this mode.  
%      'cont' : An output delay equal to TBLEN symbols is incurred.
%    
%   Y = MLSEEQ(X,CHCFFS,CONST,TBLEN,OPMODE,NSAMP) specifies the number 
%   of samples per input symbol, that is, the oversampling factor. When 
%   NSAMP > 1, CHCFFS represents the oversampled channel coefficients.
%    
%   OPMODE set to 'rst'
%   ----------------------------
%   Y = MLSEEQ(...,'rst',NSAMP,PREAMBLE,POSTAMBLE) provides the
%   equalizer with PREAMBLE and POSTAMBLE that are prepended and appended
%   to the data, respectively. PREAMBLE and POSTAMBLE are vectors that consist
%   of elements between 0 and M-1, where M is the order of the modulation. 
%   To omit a PREAMBLE or POSTAMBLE, specify them as [].
%
%   OPMODE set to 'cont'
%   ----------------------------
%   Y = MLSEEQ(...,'cont',NSAMP,INIT_METRIC,INIT_STATES,INIT_INPUTS)
%   provides the equalizer with initial state metrics, initial traceback states
%   and initial traceback inputs.  Each real number in INIT_METRIC represents
%   the starting state metric of the corresponding state.  INIT_STATES and 
%   INIT_INPUTS jointly specify the initial traceback memory of the equalizer.
%   The following table shows the valid dimensions and values of the
%   above input arguments:
%
%    Argument      Description        Size                Range
%    ======================================================================
%    INIT_METRIC   State metrics      1 x numStates       Real numbers
%    INIT_STATES   Traceback states   numStates x tblen   0 to numStates-1  
%    INIT_INPUTS   Traceback inputs   numStates x tblen   0 to M-1
%   
%   where numStates = M^(L-1), M is defined above and L is the length of
%   the channel impulse response, in symbols (without any oversampling).
%   
%   [Y FINAL_METRIC FINAL_STATES FINAL_INPUTS] = MLSEEQ(...,'cont',...)
%   returns the normalized state metrics, traceback states and traceback inputs 
%   at the end of the traceback decoding process. FINAL_METRIC is a vector with 
%   numStates elements which correspond to the final state metrics. FINAL_STATES
%   and FINAL_INPUTS are numStates-by-TBLEN matrices.
%   
%   Example:
% 
%      % Continuous operation mode
%      modmsg = qammod([2 2 1 3 1 1 3 3 2 2 1 3 1 0 1],4);
%      const = qammod(0:3,4);
%      tblen = 10; chcffs = [1 ; 0.25];
%      filtmsg = filter(chcffs,1,modmsg);   
%      [rx1 m1 p1 in1] = mlseeq(filtmsg,chcffs,const,tblen,'cont');
%      % Check if received data is identical to the original message 
%      % accounting for the traceback decoding delay
%      rxequaltx = isequal(rx1(tblen+1:end),modmsg(1:end-tblen));
%
%     % Reset operation mode
%     preamble = [1 2]; data = [2 2 1 3 1 1 3 3 2 2 1 3 1 0 1];
%     msg = [preamble data];
%     modmsg = qammod(msg,4); const = qammod(0:3,4);
%     tblen = 10; chcffs = [1 ; 0.25];
%     filtmsg = filter(chcffs,1,modmsg);   
%     rx = mlseeq(filtmsg,chcffs,const,tblen,'rst',1,preamble,[]);
%     % Check if received data is identical to the original message
%     rxequaltx = isequal(rx,modmsg);
%
%     See also EQUALIZE.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/07/30 02:47:38 $

% Calls mlse_eq.c

% Check number of input arguments
msg = nargchk(5,9,nargin);
if ~isempty(msg)
    error('comm:mlseeq:numInArg',msg);
end

% Number of variable input arguments
nvarargin = nargin - 5;

% Check number of output arguments
msg = nargoutchk(1,4,nargout);
if ~isempty(msg)
    error('comm:mlseeq:numOutArg',msg);
end

% Define macros
% Opmode
CONT = 1;
RST  = 2;

% Value set indicators (used for setting optional inputs)
initTableSet  = 0;

% Set default values for optional inputs
preamble   = -1;
postamble  = -1;
initmetric = [];
initstate  = [];
initinput  = [];

% --- Placeholders for the numeric index values
numArg = [];

if ~ischar(opmode)
    error('comm:mlseeq:strOpmode','Operation mode must be specified by a character string.');
end

% Set opmode
switch lower(opmode)
case {'cont'}
   opmodeNum = CONT;
case {'rst'}
   opmodeNum = RST;
otherwise
   error('comm:mlseeq:Opmode','Unknown operation mode.');
end;

% Check : only 1 output is allowed for 'rst' mode
if ( opmodeNum==RST && nargout>1 )
    error('comm:mlseeq:numOutArgRst',['The equalized message is the only output allowed '...
           'for Reset operation mode.']);
end

% --- Identify string and numeric arguments
for nn=1:nvarargin
   if(isnumeric(varargin{nn}))
      numArg(size(numArg,2)+1) = nn;
   else
      error('comm:mlseeq:optNumArg','Only numeric arguments are allowed for the optional inputs.');
   end;
end;

% --- Build the numeric argument set
switch(length(numArg))

    case 0
        % Five input argument - allowed for both operation modes
        % Set default value for the oversampling ratio.
        nsamp = 1;
    
    case 1
        % Six input arguments - allowed for both operation modes
        nsamp = varargin{numArg(1)};
        
    case 2
        % Seven input arguments - not allowed
        nsamp = varargin{numArg(1)};        
        if (opmodeNum == RST)
            error('comm:mlseeq:numArgRst',['Seven input arguments have been provided. This is not ',...
                    'allowed. Specify both preamble and postamble. If one of them ',...
                    'does not exist, use empty matrix.']);
        else
            error('comm:mlseeq:numArgCont',['Seven input arguments have been provided. This is not ',...
                'allowed in the Continuous operation mode.']);
        end
        
    case 3
      % Eight input arguments - allowed for 'rst' mode only
      nsamp = varargin{numArg(1)};
      if (opmodeNum == RST)
          
          % Check for preamble
          inputPreamble = varargin{numArg(2)};
          if isempty(inputPreamble)            
              % Default value
              preamble = -1;              
          elseif ismatrix(inputPreamble) || ~isnumeric(inputPreamble) || ~isreal(inputPreamble) || ...
                  min(inputPreamble)<0 || max(inputPreamble)>=numel(const)
              error('comm:mlseeq:preamble',['Preamble must be a vector of integers between 0 ' ...
                      'and the order of the constellation minus 1.']);
          else
              preamble = inputPreamble;
          end
          
          % Check for postamble
          inputPostamble = varargin{numArg(3)};
          if isempty(inputPostamble)
              % Default value
              postamble = -1;
          elseif ismatrix(inputPostamble) || ~isnumeric(inputPostamble) || ~isreal(inputPostamble) || ...
                  min(inputPostamble)<0 || (max(inputPostamble)>=numel(const))
              error('comm:mlseeq:postamble',['Postamble must be a vector of integers between 0 ' ...
                      'and the order of the constellation minus 1.']);
          else
              postamble = inputPostamble;         
          end
          
      else
          error('comm:mlseeq:numArgRst',['Eight input arguments have been provided. This is only allowed ',...
                         'for the Reset\n',...
                         'operation mode.']);
      end
      
   case 4
       % 9 input arguments - allowed for 'cont' mode only
       nsamp = varargin{numArg(1)};
       % --- initmetric is second (element 2), initstate (element 3), initinput (element 4)
      if (opmodeNum == CONT)
         
            initmetric    = varargin{numArg(2)};
            initstate     = varargin{numArg(3)};
            initinput     = varargin{numArg(4)};
            
            if ~(isempty(initmetric) && isempty(initstate) && isempty(initinput))
               initTableSet  = 1;      % Indicates that traceback memory is given
           end         
         
      else
         error('comm:mlseeq:numArgCont',['Nine input arguments have been provided.  ' ,...
                        'This is only allowed for the Continuous\n' ,...
                        'operation mode.'])
      end;
      
   otherwise
      error('comm:mlseeq:numInArg','Invalid syntax.  Too many input arguments.')
end;

% Check nsamp
if ~isscalar(nsamp) || ~isnumeric(nsamp) || ~isreal(nsamp) ...
 || ~isfinite(nsamp) || nsamp<=0 || floor(nsamp)~=nsamp  
    error('comm:mlseeq:nsamp','Samples per input symbol must be a positive integer scalar.');
end

% Check input signal x
if ~isempty(x)

    if ~isnumeric(x) || ismatrix(x) || any(~isfinite(x))
        error('comm:mlseeq:X','Input signal X must be a vector of complex numbers.');
    elseif ( mod(length(x), nsamp) ~= 0)
        error('comm:mlseeq:X',['Length of the input signal vector X must be a multiple of the ', ...
                'number of samples per input symbol output symbol.']);
    else
        x_cplx = complex(real(x),imag(x));
    end    
    
    % Get input signal orientation
    x_dim = size(x);
    if x_dim(1)>1
        x_flip = 1;
        x_cplx = x_cplx.';
    else
        x_flip = 0;
    end
    
else
    error('comm:mlseeq:X','Input signal X must be a vector of complex numbers.');    
end

% Check channel coefficients
cplxchanest = complex(real(chcffs),imag(chcffs));
if (isempty(cplxchanest) || ismatrix(cplxchanest) || ...
        ~isnumeric(cplxchanest) || ...
         mod(length(cplxchanest),nsamp)) 
    error('comm:mlseeq:chcffs',['Channel coefficients must be a vector whose ',...
            'length is a multiple of the Samples per symbol ', ...
            'parameter.']);
end


% Check constellation points
cplxconstpts = complex(real(const),imag(const));
if isempty(cplxconstpts) || ismatrix(cplxconstpts) || length(cplxconstpts)<2 ...
    || ~isnumeric(const) || (length(unique(cplxconstpts)) ~= length(cplxconstpts))
    error('comm:mlseeq:const',['Complex constellation points must be a vector of at least ' ...
            'two elements.']);
end

% Check traceback depth
if ~isscalar(tblen) || ~isnumeric(tblen) || ~isreal(tblen) ...
 || ~isfinite(tblen) || tblen<=0 || floor(tblen)~=tblen  
    error('comm:mlseeq:tblen','Traceback depth must be a positive integer scalar.');

elseif (opmodeNum == RST && tblen > length(x_cplx)/nsamp )
    error('comm:mlseeq:tblen',['For the Reset mode, traceback depth must be ', ...
           'a positive integer scalar not\n', ...
           'larger than the number of input symbols.']);
end

% Check initmetric, initstate, initinput
M = numel(const);
L = numel(chcffs)/nsamp;
numStates = M^(L-1);
if (initTableSet == 1)
        
    if isempty(initmetric)
        error('comm:mlseeq:initmetric',['When using [] as the default for INIT_METRIC, ' ,...
                'INIT_STATES and INIT_INPUTS must\n' ,...
                'also be [].']);
    elseif ~isnumeric(initmetric) || (~isreal(initmetric))  || ...
            any(any(~isfinite(initmetric))) || length(initmetric)~=numStates
        error('comm:mlseeq:initmetric',['The inital state metrics must be a real vector with length ' ,...
              'equal to the number\n' ,...
              'of states, where numStates = M^(L-1), where '...
              'M is the order of modulation and L is\n'...
              'the length of the channel''s impulse response in symbols.']);
    end
       
    dimState = size(initstate);
    if isempty(initstate)
        error('comm:mlseeq:initstate',['When using [] as the default for INIT_STATES, ' ,...
                'INIT_METRIC and INIT_INPUTS must\n' ,...
                'also be [].'])
    elseif ~isnumeric(initstate) || (~isreal(initstate)) || ...
            any(any(~isfinite(initstate))) || min(initstate(:))<0 || ...
            max(initstate(:)>numStates-1) || max(max(floor(initstate)~=initstate)) || ...
            ~isequal(dimState, [numStates tblen])
        error('comm:mlseeq:initstate',[ ...
              'The initial traceback state must be a matrix of integers between 0 \n' ,...
              'and (numStates-1), where numStates = M^(L-1), M = order of modulation,\n'...
              'and L = length of channel''s impulse response in symbols.\n' ,...
              'The matrix must have numStates rows and '...
              'TBLEN columns.']);
    end
         
    dimInput = size(initinput);   
    if isempty(initinput)
        error('comm:mlseeq:initinput',['When using [] as the default for INIT_INPUTS, ' ,...
                'INIT_METRIC and INIT_STATES must\n' ,...
                'also be [].']);
    elseif ~isnumeric(initinput) || (~isreal(initinput)) || ...
            any(any(~isfinite(initinput))) || min(initstate(:))<0 || ...
            max(initstate(:)>numStates-1) || max(max(floor(initstate)~=initstate)) || ...
            ~isequal(dimInput, [numStates tblen])
        error('comm:mlseeq:initinput',[ ...
              'The initial traceback input must be a matrix of integers between 0 \n' ,...
              'and (numStates-1), where numStates = M^(L-1), M = order of modulation,\n'...
              'and L = length of channel''s impulse response in symbols.\n' ,...
              'The matrix must have numStates rows and '...
              'TBLEN columns.']);

    end        
    
end

% Call to mlse_eq.c
[varargout{1} varargout{2} varargout{3} varargout{4}] ...
    = mlse_eq(x_cplx,cplxchanest,cplxconstpts,tblen,opmodeNum, ...
      nsamp,preamble,postamble,initTableSet,initmetric,initstate,initinput);

% Change message back to same orientation as the input signal if needed
if x_flip
    varargout{1}=(varargout{1}).';
end

% [EOF]