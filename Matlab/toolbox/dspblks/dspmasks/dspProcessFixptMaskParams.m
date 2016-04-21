function [curVis,lastVis] = dspProcessFixptMaskParams(blk,visState,lastVisState,addlParams)
%[curVis,lastVis] = dspProcessFixptMaskParams(blk,visState,addlParams)
%   blk          : handle of fixed-point enabled block.  Default value is the 
%                  output of 'gcbh'
%   visState     : the visibility settings at the time of this function call, 
%                  to allow the state to be updated.  If not supplied, the
%                  visibility state will be initialized by a call to
%                  get_param(blk,'maskvisibilities')
%   lastVisState : the last applied visibility settings. If not supplied, the
%                  state will be initialized to be equal to visState
%   addlParams   : array of additional mask parameters (by parameter index)
%                  that should be turned on or off by the 'Show additional
%                  parameters' checkbox
%
%   This function handles the dynamic switching of parameter visibilities
%   for fixed-point enabled blocks that meet the requirements below.
%
%   This function returns two values:
%  
%   curVis  : The current set of visibility settings
%   lastVis : The last applied set of visibility settings
%
%   NOTE: This is a Signal Processing Blockset mask utility function.  It is 
%   not intended to be used as a general-purpose function.
  
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $  $Date: 2004/04/12 23:05:51 $

% There are nine (9) different 'sections' that may exist in the mask. It is
% assumed that if the section exists, then all of the parameters for that
% section (listed below) exist with the specified names:
%
% (1) first coefficient    : firstCoeffMode, firstCoeffWordLength,
%     params                 firstCoeffFracLength
%
% (2) second coefficient   : secondCoeffMode, secondCoeffWordLength,
%     params                 secondCoeffFracLength
%
% (3) third coefficient    : thirdCoeffMode, thirdCoeffWordLength,
%     params                 thirdCoeffFracLength
%
% (4) intermediate product : interProdMode, interProdWordLength, 
%     params                 interProdFracLength
%
% (5) product output       : prodOutputMode, prodOutputWordLength, 
%     params                 prodOutputFracLength
%
% (6) accumulator params   : accumMode, accumWordLength, 
%                            accumFracLength
%
% (7) memory params        : memoryMode, memoryWordLength, 
%                            memoryFracLength
%
% (8) output params        : outputMode, outputWordLength, 
%                            outputFracLength
%
% (9) misc                 : roundingMode, overflowMode
  
if (nargin < 1) || isempty(blk)
  blk = gcbh;
  obj = get_param(gcbh,'object');
else
  obj = get_param(blk,'object');
end
if (nargin < 2)
  curVis  = obj.MaskVisibilities; % get_param
else
  curVis  = visState;
end
if (nargin < 3)
  lastVis = curVis;
else
  lastVis = lastVisState;
end

if (nargin < 4) 
  addlParams = [];
end

% Let's find out what we have...
names      = obj.MaskNames; % get_param
ROUND_MODE = find(strcmp(names,'roundingMode'));
ALLOW_OVER = find(strcmp(names,'allowOverrides'));

if ~isempty(find(strcmp(names,'additionalParams')))
  % has Show additional params checkbox
  noAddlParams = strcmp(obj.additionalParams,'off');
else
  noAddlParams = 0;
end

if ~isempty(ALLOW_OVER) 
  % has Allow overrides checkbox
  % Allow overrides is now always off...
  curVis(ALLOW_OVER)  = {'off'};
end

[curVis,lastVis] = update(obj, names, 'firstCoeffMode', noAddlParams, curVis, lastVis);
[curVis,lastVis] = update(obj, names, 'secondCoeffMode',noAddlParams, curVis, lastVis);
[curVis,lastVis] = update(obj, names, 'thirdCoeffMode', noAddlParams, curVis, lastVis);
[curVis,lastVis] = update(obj, names, 'interProdMode',  noAddlParams, curVis, lastVis);
[curVis,lastVis] = update(obj, names, 'prodOutputMode', noAddlParams, curVis, lastVis);
[curVis,lastVis] = update(obj, names, 'accumMode',      noAddlParams, curVis, lastVis);
[curVis,lastVis] = update(obj, names, 'memoryMode',     noAddlParams, curVis, lastVis);
[curVis,lastVis] = update(obj, names, 'outputMode',     noAddlParams, curVis, lastVis);

if ~isempty(ROUND_MODE); % has Misc params - round and overflow
  if noAddlParams
    curVis(ROUND_MODE)   = {'off'};
    curVis(ROUND_MODE+1) = {'off'};
  else
    curVis(ROUND_MODE)   = {'on'};
    curVis(ROUND_MODE+1) = {'on'};
  end
end

if ~isempty(addlParams)
  if noAddlParams
    curVis(addlParams) = {'off'};
  else    
    curVis(addlParams) = {'on'};
  end
end

%----------------------------------------  
function [curVis,lastVis] = update(obj,names,modeStr,noAddlParams,curVis,lastVis)

modeIndex = find(strcmp(names,modeStr));
hasParams = ~isempty(modeIndex);

if hasParams
  if noAddlParams
    curVis(modeIndex:modeIndex+2) = {'off'};
    return;
  else
    curVis(modeIndex) = {'on'};
    obj.MaskVisibilities = curVis; % set_param
    lastVis = curVis;
    mode = obj.(modeStr); % get_param
    if strcmp(mode,'User-defined')
      curVis(modeIndex+1) = {'on'};
      curVis(modeIndex+2) = {'on'};
    else
      curVis(modeIndex+1) = {'off'};
      curVis(modeIndex+2) = {'off'};
    end  
  end
end  

