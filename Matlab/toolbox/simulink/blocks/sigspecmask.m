function S = sigspecmask(block, D, Ts, DataType, SignalType, varargin)
% SIGSPECMASK Mask dialog function for the signal specification block.
  
%   Author: Mojdeh Shakeri
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/15 00:32:29 $
  
% Initialize output structure  
S            = [];
S.status     = '';
S.dispStr    = '';

dispStr = '';
lenv = length(varargin);
if lenv == 0
  SamplingMode = 'auto';
  bname = getfullname(block);
  warning(['Mask of Signal Specification block ', bname, ' is obsolete.'...
           ' Please run ''slupdate'' on this model.']);
elseif lenv == 1
  SamplingMode = varargin{1};
else
  error('Too many input arguments.');
end


%%%  Fill dimension string
dstr = '';
DIsInherit = (length(D) == 1 ) & (D(1) == -1);
if (~DIsInherit)
  % It must be a matrix (n-D array n=2)
  isOk = (ndims(D) == 2);
  if (isOk)
    m = size(D, 1);
    n = size(D, 2);
    % A row or column vector with 1 or 2 elements
    isOk = (m == 1 | n == 1) & (m*n == 1 | m*n == 2); 
  end
  
  if(isOk) % dimensions must be positive, integer valued
    isOk = isequal(double(int32(D)), D) & isempty(find(D <= 0));
  end
  
  if(~isOk)
    S.status = ['Dimensions must be -1 (inherited) or it must be ' ...
		'a positive, non-zero, integer valued vector with ' ...
		'1 or 2 elements.'];
	      
    dStr    = sprintf('D:?');
  else
    if (m == 1 & n == 1) % Scalar
      dStr = sprintf('D:[%d]',D);
    else % row or column vector
      dStr = sprintf('D:[%d, %d]',D(1), D(2));
    end;
  end
  dispStr = dStr;
end;

%%%  Fill sample time info
tsStr = '';
TsIsInherit = (length(Ts) == 1 ) & (Ts(1) == -1);
if (~TsIsInherit)
  isOk = (ndims(Ts) == 2);
  if (isOk)
    m = size(Ts, 1);
    n = size(Ts, 2);
    % A row or column vector with 1 or 2 elements
    isOk = (m == 1 | n == 1) & (m*n == 1 | m*n == 2); 
  end
    
  if(~isOk)
    S.status = ['Sample time must be a vector with 1 or 2 elements.'];
    tsStr    = sprintf('Ts:?');
  else
    if (m == 1 & n == 1) % Scalar
      tsStr = sprintf('Ts:[%f]',Ts);
    else % row or column vector
      tsStr = sprintf('Ts:[%f %f]',Ts(1), Ts(2));
    end;
  end

  if (strcmp(dispStr, ''))
    dispStr = tsStr;
  else
    dispStr = sprintf('%s, %s',dispStr, tsStr);
  end
end


%%%  Fill complex signal info
sigTypeStr = '';
if (~isequal(SignalType,'auto'))
  sigTypeStr = SignalType;
  if (strcmpi(SignalType,'complex'))
    sigTypeStr = 'C:1';
  else
    sigTypeStr = 'C:0';
  end

  if (strcmp(dispStr, ''))
    dispStr = sigTypeStr;
  else
    dispStr = sprintf('%s, %s',dispStr, sigTypeStr);
  end
end

%%%  Fill data type info
dtypeStr = '';
if (~isequal(DataType,'auto'))
  dtypeStr = DataType;
  if (strcmp(dispStr, ''))
    dispStr = dtypeStr;
  else
    dispStr = sprintf('%s, T:%s',dispStr, dtypeStr);
  end
end

%%% Fill sampling mode info
samplingmodeStr = '';
if (~isequal(SamplingMode, 'auto'))
  samplingmodeStr = SamplingMode;
  if (strcmpi(SamplingMode, 'Sample based'))
    samplingmodeStr = 'NF';
  else
    samplingmodeStr = 'F';
  end
  
  if (strcmp(dispStr, ''))
    dispStr = samplingmodeStr;
  else
    dispStr = sprintf('%s, S:%s',dispStr, samplingmodeStr);
  end
  
end


% Fill output structure
if (strcmp(dispStr, ''))
  S.dispStr = 'Inherit';
else
  S.dispStr = dispStr;
end

if (strcmp(S.status,'') == 1)
  try,
    % If Ts is invalid, the following set_param results in an error.
    % Using try-catch, the error reported during block diagram compilation
    % by the inport block, and will be displayed in the error dialog.
	set_param([block '/In'],...
 			  'DataType',     DataType,...
			  'SignalType',   SignalType,...
			  'SamplingMode', SamplingMode);
  catch,
    % Do nothing
  end
end


