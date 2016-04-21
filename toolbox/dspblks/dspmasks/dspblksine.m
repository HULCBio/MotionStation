function varargout = dspblksine(action)
% DSPBLKSINE Signal Processing Blockset Sine Wave block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.19.4.4 $ $Date: 2004/04/12 23:07:16 $

%Parameters:
[AMPLITUDE, FREQUENCY, PHASE] = deal(1,2,3);
[COMPMETHOD, TABLESIZE, SAMPLETIME, SAMPLESPERFRAME] = deal(6,7,8,9);
RESETSTATE = 17;

blk = gcbh;
obj = get_param(blk,'object');
if nargin==0, action = 'dynamic'; end

Mode = obj.SampleMode;
isDiscrete = strncmp(Mode,'Discrete',8);
maxVal = abs(dspGetEditBoxParamValue(blk,'Amplitude'));

switch action
 case 'init'
  dtInfo = dspGetFixptSourceDTInfo(obj,0,maxVal);
  dtID = dspCalcSLBuiltinDataTypeID(blk,dtInfo);
  varargout = {dtInfo,dtID};
  
 case 'dynamic'
  vis = obj.MaskVisibilities;
  lastVis = vis;
  % Update enable-status of:
  %   computation method, complex computation method,
  %   sample time, samples per frame, data-type and re-enable:
  if isDiscrete,    
    vis(COMPMETHOD) = {'on'};
    vis(SAMPLETIME) = {'on'};
    vis(SAMPLESPERFRAME) = {'on'};
    obj.MaskVisibilities = vis;
    lastVis = vis;
    Method = obj.CompMethod;
    isTable = strcmp(Method,'Table lookup');
    if isTable,
      vis(TABLESIZE)={'on'};
    else
      vis(TABLESIZE)={'off'};
    end
  else
    isTable = 0;
    vis(COMPMETHOD : SAMPLESPERFRAME) = {'off'};
  end
  % Set the tunability of the Amp, Freq, and Phase.
  % These need to be "off" in Table Lookup Mode
  %   
  tune = obj.MaskTunableValues;
  orig_tune = tune;
  if isTable,
    tune(AMPLITUDE : PHASE) = {'off'};
  else
    tune(AMPLITUDE : PHASE) = {'on'};
  end 
  % We can only change masktunablevalues when the simulation is stopped:
  SimStatus = get_param(bdroot(gcs),'SimulationStatus');
  if strcmp(SimStatus,'stopped') && ~isequal(tune,orig_tune),
    obj.MaskTunableValues = tune;
  end
  
  % process the standard fixed-point parameters
  [vis,lastVis] = dspProcessFixptSourceParams(obj,12,0,vis,lastVis);

  if ~isequal(vis,lastVis)
    obj.MaskVisibilities = vis;
  end
  
 case 'icon'
  if isDiscrete,
    dx=pi/5;
    x=(0:dx:2*pi)';
    y=sin(x);
    [x,y]=stairs(x,y);   
  else
    dx=pi/22;
    x=(0:dx:2*pi)';
    y=sin(x);
  end
  % Axes:
  x=[x;NaN;0; 0;NaN;0;2*pi];
  y=[y;NaN;1;-1;NaN;0;0];
  varargout(1:2) = {x,y};
end
