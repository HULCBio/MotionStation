function [w,xw,yw,wtxt] = dspblkwinfcn2get(blk,N)
%DSPBLKWINFCN2GET Get new window for Signal Processing Blockset Window function.
%   [W,XW,YW,WTXT] = DSPBLKWINFCN2GET(BLK,N) gets a new window W, and
%   scaled x- and y- values XW, YW for the plot on the face of the
%   block, and a text message WTXT for the face of the block.  BLK is
%   the name of the block that calls this function (from GCBH), and N
%   is the width of the window.  The other window parameters are read
%   from the mask.
%
%   This is a block helper function for mask parameters for the DSP
%   Blockset Window Function. 

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.2.4.2 $ $Date: 2004/04/12 23:07:46 $

  OptionalParams = strcmp(get_param(blk,'OptParams'),'on');
  wintype = get_param(blk,'wintype');
  winsamp = get_param(blk,'winsamp');
  maskWS = get_param(blk,'maskwsvariables');   % get all mask variables (needed for 'eval' types)
  use_samp = ~isempty(strmatch(wintype,{'Blackman','Hamming','Hanning','Hann'}));
  sflag = lower(winsamp);

  switch wintype,
   case 'Bartlett',
    s={'bartlett',N};
   case 'Blackman',
    s={'blackman',N,sflag};
   case 'Boxcar',
    s={'boxcar',N};
   case 'Chebyshev',
    Rs = getMaskValue(maskWS,'Rs');
    s ={'chebwin',N,Rs};
   case 'Hamming',
    s={'hamming',N,sflag};
   case 'Hann',
    s={'hann',N,sflag};
   case 'Hanning',
    s={'hanning',N,sflag};
   case 'Kaiser',
    beta = getMaskValue(maskWS,'beta');
    s={'kaiser',N,beta};
   case 'Triang',
    s={'triang',N};
   case 'User defined'
    winName = get_param(blk,'UserWindow');   % can get window name directly (since it's literal)
    s={winName,N};
    if (OptionalParams)
      winOpts = getMaskValue(maskWS,'UserParams');
      if ~isempty(winOpts),
        if ~iscell(winOpts), winOpts={winOpts}; end
        s=[s winOpts];
      end
    end
  end


  if nargout==1
    % The S-function is requesting a new window.  Do not suppress any
    % warnings or errors.
    w=feval(s{:});
  else
    % For icon only.
    try
      % None of the window fcn arguments should be empty.
      % It's either a user mistake, or the mask variable
      % was undefined.  We wish to suppress all warnings
      % from the window design functions, and to produce
      % a default icon for the block:
      anyEmpty = 0;
      for i=2:length(s),
        if isempty(s{i}),
          anyEmpty=1;
          break;
        end
      end
      if anyEmpty,
        w=zeros(N,1);
      else
        w=feval(s{:});
      end
    catch
      % Any other errors:
      w=zeros(N,1);
    end
    % wtxt, xw, yw are only computed for the icon.
    wtxt=s{1}; xw=(0:N-1)/(N-1)*0.75+0.05; yw=w*.65;
  end
  
  return

% ----------------------------------------------------------
function y = getMaskValue(ws, param)

% find param name in the array of mask variables
  idx = strmatch(param,{ws.Name});
  if isempty(idx),
    error(['Could not find param name "' param '" in Window block mask workspace.']);
  end
  y = ws(idx).Value;

  
