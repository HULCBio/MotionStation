function slupdate(sys,prompt)
%SLUPDATE Replace blocks from a previous release with newer ones.
%   SLUPDATE(SYS) replaces older, obsolete versions of blocks within
%   the model SYS with newer Simulink 5 versions.  Note that the
%   model must be open prior to calling SLUPDATE.  Blocks that are
%   updated include:
%
%       Pulse Generator             - a new implementation
%       Hit Crossing                - now built-in
%       S-function Memory           - Memory block is now built-in
%       S-function Quantizer        - now built-in
%       Graph scope                 - built-in Scope is much improved over this
%       S-function 2-D Table Lookup - now built-in
%       Elementary Math             - replaced by either the Trigonometry,
%                                     Rounding, or Math block  
%       To Workspace                - three element version of Maximum rows
%                                     parameter is separated out into 
%                                     individual fields
%       Outport                     - replace Initial output of width []
%
%   SLUPDATE(SYS, PROMPT) will prompt the user for each instance of 
%   a replaceable block if the value of PROMPT is 1. This is the
%   default. A value of 0 will not prompt the user. 
%
%   When prompted, the user has three options.
%   - "y" : Replace the block  (default)
%   - "n" : Do not replace the block
%   - "a" : Replace all blocks without further prompting
%
%   In addition to above changes, SLUPDATE calls ADDTERMS to terminate
%   any unconnected input and output ports by attaching Ground and
%   Terminator blocks respectively.  SLUPDATE also converts blocks
%   to links in the appropriate block libraries.
%
%   SLUPDATE will look for all masked built-in blocks that are not
%   subsystems or s-functions, place the block in a subsystem and
%   copy the mask and block callbacks to the new subsystem.
%
%   See also FIND_SYSTEM, GET_PARAM, ADD_BLOCK, ADDTERMS, MOVEMASK.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.81.4.8 $

%
% Force the user to open the model first.  This limitation is due to the
% mechansim that we use to update the version number of the model - we
% insert a call to simver in to the MATLAB execution queue which instead
% of being executed gets eaten by the input call in AskToReplace.  The
% side effect, and it's a serious one, is that the input call will gag,
% and the version of the model will not be set to 2.0.
%

if nargin==0
  error('You must specify a model name to update.')
end

if isempty(find_system('SearchDepth',0,'Name',sys)),
  if exist(sys) == 4,
    w = warning;
    warning('off');
    open_system(sys);
    warning(w);
  else
    error(sprintf('The model ''%s'' cannot be found, you must open the model first before using slupdate.',sys));
  end
end

if nargin==1,
   prompt  = 1;
   replace = 0;
end
if prompt==0,
  replace=1;
end

%
% Libraries need to be unlocked before changes can be made to them.
%
isLibrary = strcmp(get_param(sys,'BlockDiagramType'),'library');
if isLibrary,
  set_param(sys,'Lock','off');
end

%
% Some of the replace functions require that the Simulink block library
% be opened, and if it isn't open then they open it.  Determine if the
% library is open so that we can close it at the end if it is currently
% not open.
%
closeSimulink=isempty(find_system(0,'SearchDepth',1,'Name','simulink'));

if closeSimulink
  load_system('simulink')
end

%
% replaceInfo is a data structure that contains the information about
% which blocks to replace and which function to call to replace it.
% The first field is the BlockDesc which contains the arguments to
% find_system that will identify the block to replace.  The second
% field is the name of the local function that will replace the block.
% The third field is a 1 to automatically prompt the user for block
% replacement.  0 to have the block's replace function handle the
% query.
%
dot_linked_lib = sprintf('%s\n%s', 'simulink_need_slupdate/Dot','Product');

replaceInfo = { ...
 { 'MaskType','Dot Product','referenceBlock',dot_linked_lib},'ReplaceDotProduct',1;...
 { 'MaskType','Pulse Generator', ...
   'MaskPromptString',['Pulse period (secs):|Pulse width:|Pulse height:|'...
                        'Pulse start time:'] }, 'ReplacePulseGen',1;...
 { 'MaskType', 'Pulse Generator', ...
   'LinkStatus', 'none', ...
   'MaskPromptString','Period (secs):|Duty cycle (% of period):|Amplitude:|Start time:'}, ...
 'ReplacePulseGen2',1;...
 { 'MaskType','Crossing' }, 'ReplaceHitCross',1;...
 { 'BlockType','S-Function','FunctionName','sfunmem' }, 'ReplaceSFunMem',1;...
 { 'BlockType','S-Function','FunctionName','quantize','Mask','on'}, 'ReplaceQuantizer',1;...
 { 'MaskType','Graph scope.', ...
   'MaskPromptString',['Time range:|y-min:|y-max:|', ...
   'Line type (rgbw-:*). Seperate each plot by ''/'':'] },'ReplaceGraphScope',1;...
 { 'MaskType','2-D Table Lookup' }, 'Replace2DTableLookup',1;...
 { 'MaskType','Lookup Table (2-D)' }, 'Replace2DTableLookup',1;...
 { 'MaskType','Limited integrator.' }, 'ReplaceLimitedIntegrator',1;...
 { 'MaskType','Limited Integrator.' }, 'ReplaceLimitedIntegrator',1;...
 { 'BlockType','ResetIntegrator' }, 'ReplaceResetIntegrator',1;...
 { 'BlockType','ToWorkspace'}, 'UpdateToWorkspace',0;...
 { 'BlockType','ElementaryMath'}, 'ReplaceElMath',1;...
 { 'BlockType', 'Outport', 'OutputWhenDisabled', 'held' }, 'FixOutportIC',0;...
 { 'MaskType', 'FIS', 'LinkStatus','none' }, 'ReplaceFIS',1;...
 { 'BlockType', 'Reference', 'SourceBlock','rtwinlib/Adapter' }, 'delete_block',1;...
 { 'BlockType', 'Reference', 'SourceBlock','rtwinlib/RT In' }, 'ReplaceRTWinInOut',0;...
 { 'BlockType', 'Reference', 'SourceBlock','rtwinlib/RT Out' }, 'ReplaceRTWinInOut',0;...
 { 'MaskType', 'Direction Cosine Matrix' }, 'ReplaceDCM',0;... 
 { 'MaskType', '3 DOF equations of motion'}, 'Replace3DOF',0;...
 { 'BlockType', 'From', 'CloseFcn', 'tagdialog Close'}, ...
    'ReplaceCloseFcnWithEmptyStr', 0;...
 { 'BlockType', 'DiscretePulseGenerator'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'Inport'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'ComplexToMagnitudeAngle'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'ComplexToRealImag'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'DiscreteIntegrator'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'FromWorkspace'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'MagnitudeAngleToComplex'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'RealImagToComplex'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'Sin'}, 'ReplaceEnumStr', 0;...
 { 'BlockType', 'SubSystem'}, 'ReplaceEnumStr', 0;...
 { 'MaskType', 'Matrix Gain','LinkStatus','none'}, 'ReplaceMatrixGain',1;...
 { 'MaskType', 'Coulombic and Viscous Friction','LinkStatus','none'}, 'ReplaceCoulombic',1;...
 { 'MaskType', 'XY scope.','LinkStatus','none'}, 'ReplaceXYScope',1;...
 { 'MaskType', 'chirp','LinkStatus','none'}, 'ReplaceChirp',1;...
 { 'MaskType', ' Ramp','LinkStatus','none'}, 'ReplaceRamp',1;...
 { 'MaskType', 'Repeating table','LinkStatus','none'}, 'ReplaceRepeatingSequence',1;...
 { 'MaskType','PID Controller','LinkStatus','none'}, 'ReplacePID',1;...
 { 'MaskType','PID(2) Controller','LinkStatus','none'}, 'ReplacePID2',1;...
 { 'MaskType','Latch','LinkStatus','none'}, 'ReplaceFlipFlop',1;...
 { 'MaskType','SR flip-flop','LinkStatus','none'}, 'ReplaceFlipFlop',1;...
 { 'MaskType','JK flip-flop','LinkStatus','none'}, 'ReplaceFlipFlop',1;...
 { 'MaskType','D flip-flop','LinkStatus','none'},'ReplaceFlipFlop',1;...    
 { 'BlockType', 'SubSystem','ports',[2 2 0 0 0 0 0 0],'Mask','off','LinkStatus','none'}, 'ReplaceLatchWithRef',0;...
 { 'BlockType', 'SubSystem','ports',[3 2 0 0 0 0 0 0],'Mask','off','LinkStatus','none'}, 'ReplaceLatchWithRef',0;...
 { 'MaskType', 'First Order Hold','LinkStatus','none','MaskPromptString','Sample time:'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Discrete Transfer Function with Initial Outputs','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Discrete Transfer Function with Initial States','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Discrete Zero-Pole with Initial Outputs','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Discrete Zero-Pole with Initial States','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','State-Space with Initial Outputs','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Transfer Function with Initial Outputs','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Transfer Function with Initial States','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Zero-Pole with Initial Outputs','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Zero-Pole with Initial States','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Auto Correlator','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Spectrum Analyzer','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Cross Correlator','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Digital clock','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Derivative for linearization','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Delay for linearization.','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Cart2Polar','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Cart2Sph','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','CelsiusToFahrenheit','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','DegreesToRadians','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','FahrenheitToCelsius','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Polar2Cart','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','RadiansToDegrees','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Sph2Cart','LinkStatus','none'}, 'ReplaceBlockWithLink',1;...
 { 'MaskType','Sign','LinkStatus','none'},'ReplaceBlockWithLink',1;...
};

replaceInfo = cell2struct(replaceInfo, { 'BlockDesc', 'ReplaceFcn', 'AutoPrompt' }, 2);

updatedBlocks = {};

% create a junk model
% replacement block will be set up here first
% then moved to final destination model.
% This is done because going directly to the destination often breaks lines
% if the default number of ports in the library doesn't agree with 
% the number of ports in the current instance
tempSys = 'temp_junk_slupdate_scratch_pad';
if exist(tempSys) ~= 4
    new_system(tempSys);
else
  blks = find_system(tempSys,'SearchDepth',1);
  if length(blks) > 2
    error(['The model ',tempSys,' is being used.  This conflicts with slupdate.  Please rename this model.'])
  end
end
load_system(fixptlibname);

%
% scan the model for instances of the blocks that need replacing
%
for i=1:size(replaceInfo,1),

  % call find_system to locate any blocks that need replacing
  args=replaceInfo(i).BlockDesc;
  blocks=find_system(sys,'LookUnderMasks','all', args{:});

  % if any are found, call the ReplaceFcn
  for j=1:length(blocks),

    % strip out the carriage returns
    name=CleanBlockName(blocks{j});
    
    %
    % For the "normal" case, the AutoPrompt field is 1.  This means that we 
    % handle the prompt out here and call the ReplaceFcn with 1 arg, the block
    % and expect no return.  For the case that the ReplaceFcn needs to handle the
    % prompt on its own (AutoPrompt == 0), the ReplaceFcn is called with the block,
    % and the current prompt status.  The new prompt status is returned.
    %
    replace = 1;
    if replaceInfo(i).AutoPrompt,
      if prompt
        [replace,prompt]=AskToReplace(name);
      end
    
      if replace
        fprintf('Updating: ''%s''\n', name);
        feval(replaceInfo(i).ReplaceFcn, blocks{j});
      else
        fprintf('Skipping: ''%s''\n', name);
      end
    else
      [replace, prompt] = feval(replaceInfo(i).ReplaceFcn, blocks{j}, replace, prompt);
    end %if replaceInfo(i).AutoPrompt
  
    if (replace),
      updatedBlocks{end+1} = name;
    end
  end %j
end %i

% Restore broken links to simulink library and fixed-point blockset
%
[prompt,updatedBlocks] = restore_broken_links(sys,prompt,updatedBlocks);


%
% terminate any unconnected ports in block diagrams, not libraries
%
if ~isLibrary,
  addterms(sys);
end

%
% Move the mask off of built-in blocks that are not subsystems
movemask(sys);

%
% update Real-Time Windows Target target settings
%
switch(lower(get_param(sys, 'RTWSystemTargetFile')))   % is this a RTWin model?
  case {'win_tgt.tlc', 'rtwin.tlc'}
    set_param(sys, 'RTWSystemTargetFile','rtwin.tlc');
    set_param(sys, 'RTWTemplateMakefile','rtwintmf');
end;

%
% close the Simulink block library if it wasn't open when we started
%
close_system(tempSys,0);

if closeSimulink,
  close_system('simulink',0);
end

%
% generate a report of what has been updated and suggested libraries that
% might need updating
%
indent = '  ';
cr     = sprintf('\n');
fprintf('\n');
if length(updatedBlocks) == 0,
  fprintf('No blocks in ''%s'' were updated.\n', sys);
else
  fprintf('The following blocks in ''%s'' were updated:\n', sys);
  for i=1:length(updatedBlocks),
    fprintf('%s%s\n', indent, updatedBlocks{i})
  end
  fprintf('\n');
end

libs = FindLibsInModel(sys);
if ~isempty(libs),
  fprintf('The model ''%s'' is referencing the block libraries:\n', sys);
  for i=1:length(libs),
    fprintf('%s%s\n', indent, libs{i});
  end
  fprintf('\n');
  fprintf(['You should consider running slupdate on them if they are ' ...
           'not vendor-supplied block libraries.\n']);
end

% end slupdate

%
%===============================================================================
% ReplacePulseGen
% Replaces an older 1.x version of the pulse generator with a newer 4.? version.
%===============================================================================
%
function ReplacePulseGen(block)
disp('ReplacePulseGen')
% need the Simulink block library for this

% the MaskEntries need to be translated from:
%   'Period', 'Pulse Width', 'Pulse Height', and 'Pulse start time'
% to:
%   'Period', 'Duty cycle', 'Amplitude', and 'Start time'
% note that 'Duty Cycle' is now called PulseWidth for consistency
% with discrete pulse generator but it is still percentage of period

oldEntries = GetMaskEntries(block);
if length(oldEntries)~=4, error('Not enough mask entries.'); end

Period       = oldEntries{1};
PulseWidth   = oldEntries{2};
PulseHeight  = oldEntries{3};
StartTime    = oldEntries{4};

% define the new entries
DutyCycle  =['100 * (' PulseWidth ')/(' Period ')'];

% now replace the block with the built-in Pulse Generator in the 
% Simulink block library
ReplaceBlock(block,'built-in/DiscretePulseGenerator',...
         'PulseType','Time-based',...
	     'Amplitude',PulseHeight,...
	     'Period',Period,...
	     'PulseWidth',DutyCycle,...
	     'PhaseDelay',StartTime,...
	     'VectorParams1D','on');

% end ReplacePulseGen


%===============================================================================
% ReplacePulseGen2
% Replaces an older masked subsystem version of the pulse generator 
% with a newer built-in version.
%===============================================================================
%
function ReplacePulseGen2(block)
disp('ReplacePulseGen2')

oldEntries = GetMaskEntries(block);
if length(oldEntries)<4, error('Not enough mask entries.'); end

% New parameters have same values as old, but are presented  in a 
% different order and are no longer part of a mask
Period     = oldEntries{1};
DutyCycle  = oldEntries{2};
Amplitude  = oldEntries{3};
StartTime  = oldEntries{4};
if length(oldEntries)>4
  Vect1D = oldEntries{5};  
else
  Vect1D = 'on';
end

% now replace the block with the built-in Pulse Generator in 
% the Simulink block library
ReplaceBlock(block,'built-in/DiscretePulseGenerator',...
         'PulseType','Time-based',...
	     'Amplitude',Amplitude,...
	     'Period',Period,...
	     'PulseWidth',DutyCycle,...
	     'PhaseDelay',StartTime,...
	     'VectorParams1D',Vect1D);

% end ReplacePulseGen2

%
%===============================================================================
% ReplaceHitCross
% Replaces an older 1.x version of the Hit Crossing block with a new built-in
% version.
%===============================================================================
%
function ReplaceHitCross(block)

% the MaskEntries need to be translated from:
%  'Crossing Value', and 'Tol'
% to:
%  'HitCrossingOffset'

oldEntries = GetMaskEntries(block);
if length(oldEntries)~=2, error('Not enough mask entries.'); end

CrossingVal=oldEntries{1};

% define the new parameters
HitCrossingOffset=CrossingVal;

% now replace the block with the bult-in HitCrossing block
ReplaceBlock(block,'built-in/HitCross',...
             'HitCrossingOffset', HitCrossingOffset,...
             'HitCrossingDirection','falling',...
             'ShowOutputPort','off');

% end ReplaceHitCross

%
%===============================================================================
% ReplaceGraphScope
% Replaces an older 1.x version of the Graph Scope with the built-in
% scope block.  Ignores all scope parameters.
%===============================================================================
%
function ReplaceGraphScope(block)

oldEntries = GetMaskEntries(block);

if length(oldEntries)~=4, error('Wrong number of mask entries.'); end

TimeRange = oldEntries{1};
Ymin = oldEntries{2};
Ymax = oldEntries{3};

% now replace the block with the bult-in Scope block
ReplaceBlock(block,'built-in/Scope',...
             'TimeRange',TimeRange,...
	     'YMin',Ymin,'YMax',Ymax);

% end ReplaceScope

%
%==============================================================================
% ReplaceRepeatingSequence
% Replaces an older 1.x version of the Repeating Sequence block with a new 
% version.
%==============================================================================
%
function ReplaceRepeatingSequence(block)

maskVar=get_param(block, 'MaskVariables');
if isempty(maskVar),
  %this is old style mask
  set_param(block, ...
      'MaskVariables'     ,'rep_seq_t=@1;rep_seq_y=@2;', ...
      'MaskInitialization', 'period=max(rep_seq_t);' ...
      );
end
ReplaceBlockWithLink(block);
% end ReplaceRepeatingSequence

%
%===============================================================================
% ReplaceSFunMem
% Replaces a S-function Memory block with the built-in version
%===============================================================================
%
function ReplaceSFunMem(block)

% replace the block with a built-in Memory block
ReplaceBlock(block,'built-in/Memory',...
             'X0', '0.0');

% end ReplaceSFunMem

%
%===============================================================================
% ReplaceQuantizer
% Replaces a S-function Quantizer block with the built-in version
%===============================================================================
%
function ReplaceQuantizer(block)

% get the quantization interval from the mask
entries      =GetMaskEntries(block);
QuantInterval=entries{1};

% replace the block with a built-in Quantizer block
ReplaceBlock(block,'built-in/Quantizer',...
             'QuantizationInterval', QuantInterval);

% end ReplaceQuantizer

%
%===============================================================================
% Replace2DTableLookup
% Replaces a S-function 2-D Table Lookup block with the built-in version
%===============================================================================
%
function Replace2DTableLookup(block)

% get the RowIndices, ColumnIndex, and OutputValues from the mask
entries     =GetMaskEntries(block);
RowIndex    =entries{1};
ColumnIndex =entries{2};
OutputValues=entries{3};

libBlock = sprintf('built-in/Lookup2D');

% the decorations must be preserved
decorations=GetDecorationParams(block);

% the old block's name and parent are needed for the new block
name  =strrep(get_param(block,'Name'),'/','//');
parent=get_param(block,'Parent');

%
% first delete the old block, then add the new block with the appropriate
% parameters (as passed in as a varargs) and with the old decorations
%
newBlockName = [parent '/' name];
delete_block(block);
add_block(libBlock, newBlockName,'x',RowIndex, 'y',ColumnIndex, 't', OutputValues,decorations{:});

% end Replace2DTableLookup

%
%===============================================================================
% ReplaceLimitedIntegrator
% Replaces an older 1.x Limited Integrator block, a masked subsystem, with a
% built-in/Integrator block with saturation limits.
%===============================================================================
%
function ReplaceLimitedIntegrator(block)

% get the LowerLimit, UpperLimit, and Initial Condition
entries   =GetMaskEntries(block);
LowerLimit=entries{1};
UpperLimit=entries{2};
X0        =entries{3};

% replace the block with a built-in 2-D Lookup Table block
ReplaceBlock(block,'built-in/Integrator',...
             'LimitOutput','on',...
             'LowerSaturationLimit',LowerLimit,...
             'UpperSaturationLimit',UpperLimit,...
             'InitialCondition',X0);

% end ReplaceLimitedIntegrator

%
%===============================================================================
% ReplaceResetIntegrator
% Replaces an older 1.x Limited Integrator block, a masked subsystem, with a
% built-in/Integrator block with saturation limits.
%===============================================================================
%
function ReplaceResetIntegrator(block)

% replace the block with an integrator block of equivalent options
ReplaceBlock(block,'built-in/Integrator',...
	     'InitialConditionSource','external',...
	     'ExternalReset','level');

% end ReplaceResetIntegrator

%
%=============================================================================
% ReplaceElMath
% Replaces an Elementary Math with either a Trigonometry, Math or
% Rounding block
%=============================================================================
%
function ReplaceElMath(block)

% get the operator of the elmath block
Op = get_param(block, 'Operator');

switch (Op)
  case {'sin','cos','tan','asin','acos','atan','atan2','sinh','cosh','tanh'}
    % replace the block with a built-in Trigonometry block
    ReplaceBlock(block,'built-in/Trigonometry','Operator', Op);

  case {'exp','log','log10','sqrt','reciprocal','pow','hypot'}
    % replace the block with a built-in Math block
    ReplaceBlock(block,'built-in/Math', 'Operator', Op);

  case {'floor','ceil'}
    % replace the block with a built-in Rounding block
    ReplaceBlock(block,'built-in/Rounding', 'Operator', Op);
    
end
% end ReplaceElMath

%==============================================================================
% UpdateToWorkspace
% Updates an empty MaxDataPoints parameter and sets it to "Inf"
% Updates the three element form of the 'Maximum number of rows' property
%==============================================================================
%
function [replace, prompt] = UpdateToWorkspace(block, replace, prompt)

prompted = 0;

% Set the MaxDataPoints parameter to Inf
if isempty(get_param(block, 'MaxDataPoints')),
  name = CleanBlockName(block);
  if prompt,
    [replace,prompt]=AskToReplace(name);
  end
  prompted = 1;

  if replace,
    fprintf('Updating: ''%s''\n', name);
    set_param(block, 'MaxDataPoints', 'Inf');
  else,
    fprintf('Skipping: ''%s''\n', name);
    return;
  end
end

word1 = [];
word2 = [];
word3 = [];

maxDataPoints = get_param(block, 'MaxDataPoints');
origMaxDataPoints = maxDataPoints;


%
% Remove space at ends
%
maxDataPoints = fliplr(deblank(fliplr(deblank(maxDataPoints))));

%
% Replace , and ; with spaces 
%
maxDataPoints = strrep(maxDataPoints, ',', ' ');
maxDataPoints = strrep(maxDataPoints, ';', ' ');

%
% Remove space inbetween brackets & text: [ var ] -> [var]

bracket = findstr('[', maxDataPoints);
if isempty(bracket),
  return;  % nothing to update
end

if ~prompted,
  name = CleanBlockName(block);
  if prompt,
    [replace,prompt]=AskToReplace(name);
  end
  prompted = 1;

  if replace,
    fprintf('Updating: ''%s''\n', name);
  else,
    fprintf('Skipping: ''%s''\n', name);
    return;
  end
end

warnstring = ...
  ['Unrecognized syntax in the to workspace block: ' block ...
   'Please separate the appropriate elements of the ''Maximum number of rows''' ...
   'parameter into the appropriate dialog entries: [rows, decimation, ts]'];

%
% If any of the following characters are in the string, I don't
% know what to do: (,:
%
parens = find(maxDataPoints == '(');  % ones(3,1)
colons = find(maxDataPoints == ':');  % 1:3

if ~isempty(parens) | ~isempty(colons),
    fprintf('\n');
    warning(warnstring);
    fprintf('\n');
    return;
end


while isspace(maxDataPoints(bracket+1)),
  maxDataPoints(bracket+1) = [];
end

maxDataPoints = fliplr(maxDataPoints);
bracket = findstr(']', maxDataPoints);
while isspace(maxDataPoints(bracket+1)),
  maxDataPoints(bracket+1) = [];
end
maxDataPoints = fliplr(maxDataPoints);

% pull off the []
maxDataPoints(1)  = [];
maxDataPoints(end)= [];


%
% We now have something of the form:
%   'buf   dec  ts'
%

[word1, r] = strtok(maxDataPoints);
[word2, r] = strtok(r);
[word3, r] = strtok(r);

if ~isempty(r),
  warning(warnstring);
  return;
end

pvPair = {};
if ~isempty(word1),
  pvPair{1} = 'MaxDataPoints';
  pvPair{2} = word1;
end

if ~isempty(word2),
  pvPair{3} = 'Decimation';
  pvPair{4} = word2;
end

if ~isempty(word3),
  pvPair{5} = 'SampleTime';
  pvPair{6} = word3;
end

tryVal = ['set_param(block, pvPair{:})'];
dec = get_param(block, 'Decimation');
ts  = get_param(block, 'SampleTime');

error = 0;
eval(tryVal, 'error = 1;');
if (error == 1),
  warning(warnstring);

  warn = warning; 
  warning('off');
  set_param(block, 'MaxDataPoints', origMaxDataPoints, ...
		   'Decimation', dec, 'SampleTime', ts);
  warning(warn);
end

% end UpdateToWorkspace

%==============================================================================
% Fix2DLookupMask
% Fixes a bug in the 2D Lookup Table block mask.
%==============================================================================
%
function Fix2DLookupMask(block)

% the mask in the block was broken, copy the mask from the one in the
% Simulink block library
lu2d=find_system('simulink/Look-Up\nTables', ...
    'LookUnderMasks', 'all', 'BlockType','Lookup2D');
lu2d=lu2d{1};

set_param(block,'MaskType',get_param(lu2d,'MaskType'),...
                'MaskInitialization',get_param(lu2d,'MaskInitialization'));

libBlock = sprintf('simulink/Look-Up\nTables/Look-Up\nTable (2-D)');
block2link(block, libBlock);

% end Fix2DLookupMask

%
%===============================================================================
% FindLibsInModel
% Returns a cell arry of libraries that the model references
%===============================================================================
%
function libs=FindLibsInModel(sys)

libLinks = find_system(sys,'FollowLinks','on','LookUnderMasks','all',...
                           'LinkStatus','resolved');

srcBlocks = get_param(libLinks,'ReferenceBlock');
libs = cell(size(srcBlocks));
for i=1:length(srcBlocks),
  srcBlock = srcBlocks{i};
  slashIdx = findstr(srcBlock, '/');    
  libs{i}  = srcBlock(1:(slashIdx(1)-1));
end

libs = unique(libs);
slIdx = [find(strncmp(libs,'simulink',8)); find(strcmp(libs,sys))];
libs(slIdx) = [];

% end FindLibsInModel

%
%===============================================================================
% AskToReplace
% Prompts the user for confirmation to replace a specific block.
%===============================================================================
%
function [replace,prompt]=AskToReplace(block)

%
% initialize prompt, it is only changed if the input is 'a'
%
prompt=1;

replace=input(['Replace ''' block '''? ([y]/n/a) '],'s');
if isempty(replace),
  replace=1;
else
  switch replace(1)
    case 'y'
      replace=1;

    case 'n'
      replace=0;
	
    case 'a'
      replace=1;
      prompt=0;

    otherwise,
      warning(sprintf('Invalid input ''%s'', assuming ''n''.\n',replace));
      replace = 0;
  end
end

% end AskToReplace

%
%=============================================================================
% CleanBlockName
% Returns a cleansed version of the block name (cr's --> spaces)
%=============================================================================
%
function cleanName = CleanBlockName(blockName)

cleanName = strrep(blockName, sprintf('\n'), ' ');

% end CleanBlockName

%
%=============================================================================
% safe_set_param
% Same as set_param, however, the call to set_param is protected by try/catch
% so that errors can be treated as a warning.
%=============================================================================
%
function safe_set_param(block, varargin)

try
  set_param(block, varargin{:})
catch
  errmsg = lasterr;
  msg = sprintf(['An error occured when setting a parameter for ''%s''.  ' ...
                 'The error message reported by MATLAB was:\n%s\n'],...
                 CleanBlockName(block), errmsg);
  warning(msg);
end
                                                                 
%end safe_set_param

%
%=============================================================================
% GetMaskEntries
% Return mask entries as a cell array of strings.
%=============================================================================
%
function entries = GetMaskEntries(block)

oldEntries=get_param(block,'MaskValueString');
if ~isempty(oldEntries),
  k = find(oldEntries == '|');
else
  k = [];
end

k = [0 k length(oldEntries)+1];

for i=length(k)-1:-1:1
  entries{i} = oldEntries(k(i)+1:k(i+1)-1);
end

% end GetMaskEntries

%
%=============================================================================
% GetDecorationParams
% Return a cell array containing the parameter/value pairs for a block's
% decorations (i.e. FontSize, FontWeight, Orientation, etc.)
%=============================================================================
%
function decorations = GetDecorationParams(block)

decorations = {
  'Position',        [];
  'Orientation',     [];
  'ForegroundColor', [];
  'BackgroundColor', [];
  'DropShadow',      [];
  'NamePlacement',   [];
  'FontName',        [];
  'FontSize',        [];
  'FontWeight',      [];
  'FontAngle',       [];
  'ShowName',        []
};

for i=1:size(decorations,1),
  decorations{i,2}=get_param(block,decorations{i,1});
end

decorations=reshape(decorations',1,length(decorations(:)));

% end GetDecorationParams

%
%=============================================================================
% GetMaskParams
% Return a cell array containing the parameter/value pairs for a block's
% Mask.
%=============================================================================
%
function maskParams = GetMaskParams(block)

maskParams = {
  'MaskType',           [];
  'MaskDescription',    [];
  'MaskHelp',           [];
  'MaskPromptString',   [];
  'MaskValueString',    [];
  'MaskInitialization', [];
  'MaskDisplay',        []
};

for i=1:size(maskParams,1),
  maskParams{i,2}=get_param(block,maskParams{i,1});
end

maskParams=reshape(maskParams',1,length(maskParams(:)));

% end GetMaskParams

%
%=============================================================================
% ReplaceBlock
% Replaces a single block with a new block with specified parameters.
%=============================================================================
%
function ReplaceBlock(oldBlock,newBlock,varargin)

% the decorations must be preserved
decorations=GetDecorationParams(oldBlock);

%
% the mask must be preserved, if the old block is not a SubSystem
% or an S-function.  The reasoning here is that SubSystem and S-function
% blocks (masked or otherwise) will be replaced with either a built-in
% or another SubSystem or S-function (possibly masked) and that the old
% mask is not important.  However, if the block is not one of the above,
% and it does have a mask then the mask may offer an alternative
% interface to the block that should be preserved.
%
switch get_param(oldBlock,'BlockType'),
  case {'SubSystem','S-Function'},
    mask={};

  otherwise
    mask=GetMaskParams(oldBlock);
end

% the old block's name and parent are needed for the new block
name  =strrep(get_param(oldBlock,'Name'),'/','//');
parent=get_param(oldBlock,'Parent');

%
% first delete the old block, then add the new block with the appropriate
% parameters (as passed in as a varargs) and with the old decorations
%
delete_block(oldBlock);
add_block(newBlock, [parent '/' name],varargin{:},decorations{:},mask{:});

% end ReplaceBlock


%
%=============================================================================
% determineBrokenLinkReplacement
%=============================================================================
%
function replacementInfo = determineBrokenLinkReplacement(block)
  
persistent mapOldMaskToCurrent oldMaskTypeCell

if isempty(mapOldMaskToCurrent)
  %
  % This is the mapping data for blocks that lived on
  % main libraries for Simulink and Fixed-Point Blockset from R11 to present
  % 
  mapOldMaskToCurrent = getMappingOldMaskToCurrent();
  oldMaskTypeCell = {mapOldMaskToCurrent(:).oldMaskType};
end
  
oldMaskType = get_param(block, 'MaskType');


%oldMasksCanNotHandle = {'','Pulse Generator','Fixed-Point-Private Quandrant Processing Sine'};  
oldMasksCanNotHandle = {'','Fixed-Point-Private Quandrant Processing Sine'};  

if any(strcmp(oldMaskType,oldMasksCanNotHandle))
  
  replacementInfo.oldMaskType  = oldMaskType;
  replacementInfo.newMaskType  = '';
  replacementInfo.newBlockType = '';
  replacementInfo.newRefBlock  = '';
  return
end

ii = min(find(strcmp(oldMaskTypeCell,oldMaskType)));

if ~isempty(ii)
    
  replacementInfo = mapOldMaskToCurrent(ii);
else
  %
  % This is the mapping data for blocks not in the main R11-onward list above.
  % 
  switch (oldMaskType)
   case 'First Order Hold',
    libBlock = sprintf('simulink/Discrete/First-Order\nHold');
   case 'Coulombic and Viscous Friction',
    libBlock = sprintf('simulink/Discontinuities/Coulomb &\nViscous Friction');
   case 'XY scope.',
    libBlock = 'simulink/Sinks/XY Graph';
   case 'chirp',
    libBlock = 'simulink/Sources/Chirp Signal';
   case 'Repeating table',
    libBlock = sprintf('simulink/Sources/Repeating\nSequence');
   case 'Discrete Transfer Function with Initial Outputs',
    libBlock = sprintf('simulink_extras/Additional\nDiscrete/Discrete\nTransfer Fcn\n(with initial outputs)');
   case 'Discrete Transfer Function with Initial States',
    libBlock = sprintf('simulink_extras/Additional\nDiscrete/Discrete\nTransfer Fcn\n(with initial states)');
   case 'Discrete Zero-Pole with Initial Outputs',
    libBlock = sprintf('simulink_extras/Additional\nDiscrete/Discrete\nZero-Pole\n(with initial outputs)');
   case 'Discrete Zero-Pole with Initial States',
    libBlock = sprintf('simulink_extras/Additional\nDiscrete/Discrete\nZero-Pole\n(with initial states)');
   case 'PID Controller',
    libBlock = sprintf('simulink_extras/Additional\nLinear/PID Controller');
   case 'PID(2) Controller',
    libBlock = sprintf('simulink_extras/Additional\nLinear/PID Controller\n(with Approximate\nDerivative)');
   case 'State-Space with Initial Outputs',
    libBlock = sprintf('simulink_extras/Additional\nLinear/State-Space\n(with initial outputs)');
   case 'Transfer Function with Initial Outputs',
    libBlock = sprintf('simulink_extras/Additional\nLinear/Transfer Fcn\n(with initial outputs)');
   case 'Transfer Function with Initial States',
    libBlock = sprintf('simulink_extras/Additional\nLinear/Transfer Fcn\n(with initial states)');
   case 'Zero-Pole with Initial Outputs',
    libBlock = sprintf('simulink_extras/Additional\nLinear/Zero-Pole\n(with initial outputs)');
   case 'Zero-Pole with Initial States',
    libBlock = sprintf('simulink_extras/Additional\nLinear/Zero-Pole\n(with initial states)');
   case 'Auto Correlator',
    libBlock = sprintf('simulink_extras/Additional\nSinks/Auto\nCorrelator');
   case 'Spectrum Analyzer',
    sfunBlock  = find_system(block,'LookUnderMasks','all','BlockType','S-Function');
    sfunName   = get_param(sfunBlock, 'FunctionName');
    sfunParams = get_param(sfunBlock, 'Parameters');
    if strcmp(sfunName, 'sfunpsd') & (sfunParams{1}(end) == '0'),
      libBlock = sprintf('simulink_extras/Additional\nSinks/Power Spectral\nDensity');
    elseif strcmp(sfunName, 'sfunpsd') & (sfunParams{1}(end) == '1'),
      libBlock = sprintf('simulink_extras/Additional\nSinks/Averaging\nPower Spectral\nDensity');
    elseif strcmp(sfunName, 'sfuntf') & (sfunParams{1}(end) == '0'),
      libBlock = sprintf('simulink_extras/Additional\nSinks/Spectrum\nAnalyzer');
    elseif strcmp(sfunName, 'sfuntf') & (sfunParams{1}(end) == '1'),
      libBlock = sprintf('simulink_extras/Additional\nSinks/Averaging\nSpectrum\nAnalyzer');
    else
      error('Unrecognized block type');
    end
   case 'Cross Correlator',
    libBlock = sprintf('simulink_extras/Additional\nSinks/Cross\nCorrelator');
   case 'Digital clock',
    libBlock = 'simulink_extras/Flip Flops/Clock';
   case 'Derivative for linearization',
    libBlock = sprintf('simulink_extras/Linearization/Switched\nderivative for\nlinearization');
   case 'Delay for linearization.',
    libBlock = sprintf('simulink_extras/Linearization/Switched\ntransport delay\nfor linearization');
   case 'Cart2Polar',
    libBlock = sprintf('simulink_extras/Transformations/Cartesian to\nPolar');
   case 'Cart2Sph',
    libBlock = sprintf('simulink_extras/Transformations/Cartesian to\nSpherical');
   case 'CelsiusToFahrenheit',
    libBlock = sprintf('simulink_extras/Transformations/Celsius to\nFahrenheit'); 
   case 'DegreesToRadians',
    libBlock = sprintf('simulink_extras/Transformations/Degrees to\nRadians');
   case 'FahrenheitToCelsius',
    libBlock = sprintf('simulink_extras/Transformations/Fahrenheit\nto Celsius');
   case 'Polar2Cart',
    libBlock = sprintf('simulink_extras/Transformations/Polar to\nCartesian');
   case 'RadiansToDegrees',
    libBlock = sprintf('simulink_extras/Transformations/Radians\nto Degrees');
   case 'Sph2Cart',
    libBlock = sprintf('simulink_extras/Transformations/Spherical to\nCartesian');
   case 'Pulse Generator',
    libBlock = sprintf('simulink/Sources/Pulse\nGenerator');
   case 'Sign',
    libBlock = 'simulink/Math Operations/Sign';    
   case 'FIS'
    if isFISwithoutRuleViewer(block)
      libBlock = sprintf('fuzblock/Fuzzy Logic \nController');
    else
      libBlock = '';
    end
   otherwise,
    libBlock = '';
  end
  
  replacementInfo.oldMaskType  = oldMaskType;
  replacementInfo.newMaskType  = '';
  replacementInfo.newBlockType = '';
  replacementInfo.newRefBlock  = libBlock;
end
%
%=============================================================================
% END determineBrokenLinkReplacement
%=============================================================================
%


%
%=============================================================================
% ReplaceBlockWithLink
%=============================================================================
%
function ReplaceBlockWithLink(block),

replacementInfo = determineBrokenLinkReplacement(block);

if isempty(replacementInfo.newRefBlock)
  return;
end

block2link(block, replacementInfo.newRefBlock);

% end ReplaceBlockWithLink

%
%=============================================================================
% ReplaceFlipFlop: Replace Simulink 1.3 flip-flop with new version.
%=============================================================================
%
function ReplaceFlipFlop(block),

% Save the original setting for the initial condition
init_condition = get_param(block,'MaskValues');

try 
  init_val = eval(init_condition{1});
catch
  init_val = 0;
end

if (init_val ~= 0) & (init_val ~= 1)
  init_condition = {'0'};
  msg = sprintf(['Initial condition of block ''%s'' is not 0 ', ...
	'or 1. Setting initial condition of updated block to 0.'], ...
        block);
  warning(msg);
end

old_mask_type  = get_param(block, 'MaskType');
switch(old_mask_type),
  case 'Latch',
    libBlock = sprintf('simulink_extras/Flip Flops/S-R\nFlip-Flop');
  case 'SR flip-flop',
    libBlock = sprintf('slupdate_flipflops/Positive-Edge\nTriggered\nS-R Flip-Flop');
  case 'JK flip-flop',
    libBlock = sprintf('slupdate_flipflops/Positive-Edge\nTriggered\nJ-K Flip-Flop');
  case 'D flip-flop',
    libBlock = sprintf('slupdate_flipflops/Positive-Edge\nTriggered\nD Flip-Flop');
  otherwise,
    error('Unrecognized block type');
end

% Replace with appropriate new block and set initial condition 
% based on old setting.
block2link(block, libBlock);
safe_set_param(block,'MaskValues',init_condition);

% Only the latch has an equivalent in the new simulink_extras library.
% For all others, we use a private library called slupdate_flipflops.
% Once we have completed the update, break the link to this private library.
if ~strcmp(old_mask_type, 'Latch')
  safe_set_param(block,'LinkStatus','none');
end

% end ReplaceFlipFlop

%
%=============================================================================
% block2link
% Replace a block with a link to a block
%=============================================================================
%
function block2link(curBadBlock, refstring),

% These parameters are always copied from the block with the bad link
% to the replacement.  All the mask parameters are also copied.
% No other parameters are copied.
% 
baseParamsToCopy = { ...
                  'Tag' ...
                  'Description' ...
                  'RequirementInfo' ...
                  'Position' ...
                  'Orientation' ...
                  'ForegroundColor' ...
                  'BackgroundColor' ...
                  'DropShadow' ...
                  'NamePlacement' ...
                  'ShowName' ...
                  'Priority' ...
                  'AttributesFormatString' ...
                  'RTWdata' ...
                  'FontName' ...
                  'FontSize' ...
                  'FontWeight' ...
                  'FontAngle' ...
                  'IOType' ...
                  'UserDataPersistent' ...
                  'UserData' ...
                  'Diagnostics' ...
                  'StatePerturbationForJacobian' ...
                  'IOSignalStrings' ...
                  'ExtModeUploadOption' ...
                  'ExtModeLoggingTrig' ...
                  };

safelyIgnoredParameters = {'DblOver';'dolog';'EnableZeroCross'};

tempSys = 'temp_junk_slupdate_scratch_pad';
tempBlk = [tempSys,'/junkblock'];

curNewRefBlock = sprintf(refstring);

curRefLibName = strtok(refstring,'/');

load_system(curRefLibName);

add_block(curNewRefBlock,tempBlk);
            
curModelName = strtok(curBadBlock,'/');
    
try
  % create a list of parameter that will be taken from the
  % bad link and applied to its "good" replacement.
  %
  curParamNames = get_param(curBadBlock,'MaskNames');
  
  curParamNames = { baseParamsToCopy{:} curParamNames{:} };
  
  curParamValues = {};
                      
  try
    % Preferred approach is to set all parameters simultaneously
    % Create a string for the set param, because all the params
    % should be set at once.  This is done to avoid errors due
    % to invalid combinations that could arise from setting
    % them one at a time.
    %
    strToEval = 'set_param(tempBlk';
    
    for k=1:length(curParamNames);
      
      curNameOfParam = curParamNames{k};
      
      if any(strcmp(safelyIgnoredParameters,curNameOfParam))
        continue
      end
      
      curValueOfMaskParam = get_param(curBadBlock,curNameOfParam);
      
      curParamValues{k} = curValueOfMaskParam;
      
      kStr = num2str(k);
      
      strToEval = [ strToEval, ',curParamNames{',kStr,'},curParamValues{',kStr,'}'];
      
    end
    
    strToEval = [ strToEval, ');' ];
    
    eval(strToEval);
    
  catch
    %
    % Could not set all the parameters simultaneously
    % so do as much as possible one parameter at a time.
    %
    for k=1:length(curParamNames);
      
      strToEval = 'set_param(tempBlk';
      
      curNameOfParam = curParamNames{k};
      
      curValueOfMaskParam = get_param(curBadBlock,curNameOfParam);
      
      curParamValues{k} = curValueOfMaskParam;
      
      kStr = num2str(k);
      
      strToEval = [ strToEval, ',curParamNames{',kStr,'},curParamValues{',kStr,'}'];
      
      strToEval = [ strToEval, ');' ];
      
      try
        eval(strToEval);
      catch
      end
      
    end
    
  end
  
  delete_block(curBadBlock);
  
  % reminder: the replacement is being taken from a "junk"
  % model rather than directly from the source library.
  % Again, this is done to get the port count correct, and
  % hence avoid broken lines issues.
  %
  add_block(tempBlk,curBadBlock);
  
catch
end
                
delete_block(tempBlk);

% end block2link


%
%=============================================================================
% ReplaceLatchWithRef
%=============================================================================
%
function [replace, prompt] = ReplaceLatchWithRef(block, replace, prompt),

ports        = get_param(block, 'ports');
outportNames = get_param(find_system(block, 'SearchDepth',1,'BlockType','Outport'),'name');
libBlock     = '';

if ~strcmp(outportNames{1},'Q') | ~strcmp(outportNames{2},'!Q'),
  libBlock = '';
  return; % not an old latch or flip-flop
end

inportNames = get_param(find_system(block, 'SearchDepth',1,'BlockType','Inport'),'name');

if (ports(1) == 2),
  if strcmp(inportNames{1},'D') & strcmp(inportNames{2},'C'),
    %D-Latch 
    libBlock = 'simulink_extras/Flip Flops/D Latch';
  elseif strcmp(inportNames{1},'S') & strcmp(inportNames{2},'R'),
    %SR flip flop
    libBlock = sprintf('simulink_extras/Flip Flops/S-R\nFlip-Flop');
  end
elseif (ports(1) == 3),
  if strcmp(inportNames{1},'D') & strcmp(inportNames{2},'CLK') & strcmp(inportNames{3},'!CLR'),
    %D flip-flop
    libBlock = 'simulink_extras/Flip Flops/D Flip-Flop';
  elseif strcmp(inportNames{1},'J') & strcmp(inportNames{2},'CLK') & strcmp(inportNames{3},'K'),
    %j-k flip-flop
    libBlock = sprintf('simulink_extras/Flip Flops/J-K\nFlip-Flop');
  end
end

%
% At this point, we know the libBlock.  If it is not empty, then we may have to do
% the replacement.
%
if ~isempty(libBlock),
  name = CleanBlockName(block);
  if prompt,
    [replace,prompt]=AskToReplace(name);
  end
    
  if replace
    fprintf('Updating: ''%s''\n', name);
    block2link(block, libBlock);
  else
    fprintf('Skipping: ''%s''\n', name);
  end
end


%
%=============================================================================
% ReplaceXYScope
%=============================================================================
%
function ReplaceXYScope(block),

maskVar=get_param(block, 'MaskVariables');
if isempty(maskVar) | ...
      strcmp(maskVar,'ax(1)=@1;ax(2)=@2;ax(3)=@3;ax(4)=@4;st=@5;'),
  %this is old style mask

  %42c
  valFlag=logical(0);
  if strcmp(get_param(block,'MaskInitialization'), ...
            'ax = [@1, @2, @3, @4];st=-1;'),
    valFlag=logical(1);
  end
  
  safe_set_param(block, ...
      'MaskVariables'     ,'xmin=@1;xmax=@2;ymin=@3;ymax=@4;st=@5;', ...
      'MaskInitialization', '' ...
      );

  if valFlag,
    vals=get_param(block,'MaskValues');
    vals{5}='-1';
    safe_set_param(block,'MaskValues',vals);
  end

end

ReplaceBlockWithLink(block);


%
%=============================================================================
% FixOutportIC
%=============================================================================
%
function [replace, prompt] = FixOutportIC(block, replace, prompt)

parentBlock  = get_param(get_param(block, 'Parent'), 'Handle');

% If the parent is the model itself, it does not make sense to 
% perform the additional tests below.
if strcmp(get_param(parentBlock, 'Type'), 'block')
  % Determine if the block is inside a Stateflow chart block.
  % If it is, then do not update IC to [].
  if strcmp(get_param(parentBlock,'MaskType'), 'Stateflow');
    replace = 0;
    return;
  end
  
  % Determine if the block is inside a triggered or enabled
  % subsystem. If it is, then do not update IC to [].
  triggerPorts = find_system(parentBlock, 'LookUnderMasks', 'all', ...
			     'SearchDepth', 1, 'BlockType', 'TriggerPort');
  enablePorts  = find_system(parentBlock, 'LookUnderMasks', 'all', ...
			     'SearchDepth', 1, 'BlockType', 'EnablePort');

  if ~isempty([triggerPorts; enablePorts])
    replace = 0;
    return;
  end
end

strVal = get_param(block,'InitialOutput');

replace = 0; % Assume block is not replaced
try
  val = eval(strVal);
  if isequal(val, 0.0),
    name = CleanBlockName(block);
    if prompt,
      [replace,prompt]=AskToReplace(name);
    end
    
    if replace,
      fprintf('Updating: ''%s''\n', name);
      safe_set_param(block,'InitialOutput','[]');
    else
      fprintf('Skipping: ''%s''\n', name);
    end
  end
end

% end FixOutportIC


%==============================================================================
% ReplacePID
% Replaces older 2.x version of the PID block with a newer 3.0 version.
%==============================================================================
%
function ReplacePID(block)

maskVar=get_param(block, 'MaskVariables');
if isempty(maskVar),
  %this is old style mask
  safe_set_param(block, ...
      'MaskVariables'     ,'P=@1;I=@2;D=@3;', ...
      'MaskInitialization', '' ...
      );
end

ReplaceBlockWithLink(block);
% end ReplacePID

%==============================================================================
% ReplacePID2
% Replaces older 2.x version of the PID2 block with a newer 3.0 version.
%==============================================================================
%
function ReplacePID2(block)

maskVar=get_param(block, 'MaskVariables');
if isempty(maskVar),
  %this is old style mask from 1.3.  The 2.0 mask is fine
  safe_set_param(block, ...
      'MaskVariables'     ,'P=@1;I=@2;D=@3;N=@4;', ...
      'MaskInitialization', '' ...
      );
end

ReplaceBlockWithLink(block);
% end ReplacePID

%
%==============================================================================
% ReplaceRamp
% Replaces older 1.x version of the ramp generator with a newer 2.0 version.
%==============================================================================
%
function ReplaceRamp(block)

maskVar=get_param(block, 'MaskVariables');
if isempty(maskVar),
  %this is old style mask
  safe_set_param(block, ...
      'MaskVariables'     ,'slope=@1;start=@2;X0=@3;', ...
      'MaskInitialization', '' ...
      );
end

ReplaceBlockWithLink(block);

% end ReplaceRamp

%
%===============================================================================
% ReplaceChirp
% Replaces an older 1.x version of the chirp generator with a newer 2.0 version.
%===============================================================================
%
function ReplaceChirp(block)
maskVar=get_param(block, 'MaskVariables');
if isempty(maskVar),
  %this is old style mask
  safe_set_param(block, ...
      'MaskVariables'     ,'f1=@1;T=@2;f2=@3;', ...
      'MaskInitialization', 't=[0:.1:5];' ...
      );
end

ReplaceBlockWithLink(block);

% end ReplaceChirp

%
%===============================================================================
% ReplaceDotProduct
% Replaces an Dot Product block linked to the
% simulink_need_slupdate library to
% the Dot Product in the main simulink library 
%===============================================================================
%
function ReplaceDotProduct(block)
%maskVar=get_param(block, 'MaskVariables');

set_param(block, 'linkStatus', 'none')
ReplaceBlockWithLink(block);

%
%===============================================================================
% ReplaceMatrixGain
% Replaces an 1.x version of the Matrix Gain block with a newer 2.0 version.
%===============================================================================
%
function ReplaceMatrixGain(block)
maskVar=get_param(block, 'MaskVariables');
if isempty(maskVar),
  %this is old style mask
  safe_set_param(block, ...
      'MaskVariables'     ,'K=@1;', ...
      'MaskInitialization', '' ...
      );
end

gainVal = get_param(block, 'K');
ReplaceBlockWithLink(block);
safe_set_param(block,'Gain',gainVal);

% end ReplaceMatrixGain

%
%===============================================================================
% ReplaceCoulombic
% Replaces a 1.x version of the Coulombic Friction block with a 2.0 version.
%===============================================================================
%
function ReplaceCoulombic(block)
maskVar=get_param(block, 'MaskVariables');
if isempty(maskVar),
  %this is old style mask
  safe_set_param(block, ...
      'MaskVariables'     ,'offset=@1;gain=@2;', ...
      'MaskInitialization', 'x=max(offset(1),gain(1)+offset(1));' ...
      );
end

ReplaceBlockWithLink(block);

% end ReplaceCoulombic


%
%===============================================================================
% ReplaceFIS
% Replaces pre-R12 Fuzzy Logic Controller block with broken links with R12 library blocks
%===============================================================================
%

% There are two Fuzzy Logic Blocks with MaskType 'FIS'
%   one with rule viewer, one without
% Slupdate only handles the one without a rule viewer
%
function res = isFISwithoutRuleViewer(block)
props = get_param(block,'objectparameters');
res = isfield(props,'MaskParam1');

function ReplaceFIS(block)
if isFISwithoutRuleViewer(block)
    % pre-R12 Fuzzy Logic Controller block
    % Get FIS name
    FISname = get_param(block,'MaskParam1');
    % Update block
    ReplaceBlockWithLink(block);
    % Set name
    set_param(block,'fis',FISname)
end

% end ReplaceFIS



%
%===============================================================================
% ReplaceRTWinInOut
% Replace Real-Time Windows Target RT In and RT Out blocks
%===============================================================================
%
function [replace, prompt] = ReplaceRTWinInOut(block, replace, prompt)

% detect if we are dealing with 'RT In' or 'RT Out'

sourceblock = get_param(block,'SourceBlock');
inout = sourceblock(find(sourceblock==' ')+1:end);

% prompt the user for the type of the block

promptstr = [sprintf('\nFound a block ''%s'' of type ''RT %s''.\n', block, inout), ...
             'The block can be upgraded to one of the following blocks:\n', ...
             sprintf('\t [1] Analog %sput\n', inout), ...
             sprintf('\t [2] Digital %sput\n', inout), ...
             sprintf('\t [3] Other %sput\n', inout), ...
             sprintf('\t [0] Don''t upgrade\n'), ...
             'Enter your choice: ', ...
            ];
choice = input(promptstr);
while choice<0 | choice >3
  choice = input('Invalid choice, please re-enter: ',choice);
end;

% return if no action is to be taken

replace = choice~=0;
if ~replace
  return;
end;

% 

% add a temporary RT In/Out block to the RTWINLIB library so we can read the parameters

close_system('rtwinlib', 0);
lib = load_system('rtwinlib');
set_param(lib,'Lock','off');
add_block('built-in/SubSystem',sourceblock, 'MaskVariables','Ts=@1;adapter=@2;channels=@3;');

% read the original parameters

Ts = get_param(block, 'Ts');
ch = get_param(block, 'channels');

% reload RTWINLIB, discarding the temporary changes

close_system('rtwinlib', 0);
load_system('rtwinlib');

% replace the block according to the choice

blkorient = get_param(block, 'orientation');
blkpos = get_param(block, 'position');
delete_block(block);
blktypes = {'Analog', 'Digital', 'Other'};
add_block(['rtwinlib/' blktypes{choice} ' ' inout 'put'], block, ...
          'Orientation',blkorient, 'Position',blkpos);

% set block parameters, ignoring errors ("No data acquisition board has been set.")

try
  set_param(block, 'SampleTime', Ts, 'Channels', ch);
catch
end

% wait for the user to fill the rest of parameters

fprintf('\nPlease review and complete the settings of the upgraded block in the block dialog.\n');

oldshow = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'on');
open_system(block);
figh = gcf;
set(0, 'ShowHiddenHandles', oldshow);
set(figh, 'WindowStyle','modal');
uiwait(figh);


% end ReplaceRTWinInOut


%
%===============================================================================
% ReplaceDCM
% Replace Direction Cosine Matrices
%===============================================================================
%
function [replace, prompt] = ReplaceDCM( block, replace, prompt )

% make sure that block does not get replaced twice - mask type was not changed 
% from R12 to R12.1

if ((get_param(bdroot(block),'VersionLoaded')== 4) & ...
      ((strcmp(get_param(get_param(block,'Parent'),'Type'),'block') & ...
     (~strcmp(get_param(get_param(block,'Parent'),'MaskType'),'Direction Cosine Matrix (R12)') | ...
      ~strcmp(get_param(get_param(block,'Parent'),'MaskType'),'6DoF Equations of Motion')))...
      | strcmp(get_param(get_param(block,'Parent'),'Type'),'block_diagram')))

   libref_quat = sprintf('aerospace/Axes\nTransformations/Direction Cosine Matrix\nfrom quaternions');
   libref_euler = sprintf('aerospace/Axes\nTransformations/Direction Cosine Matrix\nfrom Euler Angles');

   if strcmp(get_param(block,'ReferenceBlock'),libref_quat)
       libBlock = sprintf('slupdate_aerospace/DCM from Quaternions');
   else 
       if strcmp(get_param(block,'ReferenceBlock'),libref_euler)
           libBlock = sprintf('slupdate_aerospace/DCM from Euler Angles');
       else
           replace = 0;
           msg=sprintf('Skipping ''%s''.  This block may have been customized\nfrom the Aerospace library and may need to be updated.\n',block);
           disp(msg)
	   return;
       end
   end

  % prompt the user to replace block or not
        
    if prompt
      
      [replace,prompt] = AskToReplace(block);
        
      if ~replace
          return;
      end
    end
    
    safe_set_param(block,'LinkStatus','none');
        
    % Replace with appropriate new block
    % and break the link to this private library.
    block2link(block, libBlock);
    safe_set_param(block,'LinkStatus','none');
end

% end ReplaceDCM


%
%===============================================================================
% ReplaceEnumStr
% Replace Enum string for some builtin Simulink blocks
%===============================================================================
%
function [replace, prompt] = ReplaceEnumStr( block, replace, prompt )

  switch get_param(block, 'BlockType')
    case 'DiscretePulseGenerator'
     if strcmp(get_param(block, 'PulseType'), 'Time-based')
       safe_set_param(block,'PulseType','Time based');
     elseif strcmp(get_param(block, 'PulseType'), 'Sample-based')
       safe_set_param(block,'PulseType','Sample based');
     end
     
   case 'Inport'
    if strcmp(get_param(block, 'SamplingMode'), 'sample-based')
      safe_set_param(block,'SamplingMode','Sample based');
    elseif strcmp(get_param(block, 'SamplingMode'), 'frame-based')
      safe_set_param(block,'SamplingMode','Frame based');
    end
    
   case 'ComplexToMagnitudeAngle'
    if strcmp(get_param(block, 'Output'), 'MagnitudeAndAngle')
      safe_set_param(block,'Output','Magnitude and angle');
    end
    
   case 'ComplexToRealImag'
    if strcmp(get_param(block, 'Output'), 'RealAndImag')
      safe_set_param(block,'Output','Real and imag');
    end

   case 'DiscreteIntegrator'
    if strcmp(get_param(block, 'IntegratorMethod'), 'ForwardEuler')
      safe_set_param(block,'IntegratorMethod','Forward Euler');
    elseif strcmp(get_param(block, 'IntegratorMethod'), 'BackwardEuler')
      safe_set_param(block,'IntegratorMethod','Backward Euler');
    end
     
   case 'FromWorkspace'
    if strcmp(get_param(block, 'OutputAfterFinalValue'), 'SettingToZero')
      safe_set_param(block,'OutputAfterFinalValue','Setting to zero');
    elseif strcmp(get_param(block, 'OutputAfterFinalValue'), 'HoldingFinalValue')
      safe_set_param(block,'OutputAfterFinalValue','Holding final value');
    elseif strcmp(get_param(block, 'OutputAfterFinalValue'), 'CyclicRepetition')
      safe_set_param(block,'OutputAfterFinalValue','Cyclic repetition');
    end
    
   case 'MagnitudeAngleToComplex'
    if strcmp(get_param(block, 'Input'), 'MagnitudeAndAngle')
      safe_set_param(block,'Input','Magnitude and angle');
    end
    
   case 'RealImagToComplex'
    if strcmp(get_param(block, 'Input'), 'RealAndImag')
      safe_set_param(block,'Input','Real and imag');
    end
    
   case 'Sin'
    if strcmp(get_param(block, 'SineType'), 'Time-based')
      safe_set_param(block,'SineType','Time based');
    elseif strcmp(get_param(block, 'SineType'), 'Sample-based')
      safe_set_param(block,'SineType','Sample based');
    end
    
   case 'SubSystem'
    if strcmp(get_param(block, 'RTWFcnNameOpts'), 'UseSubsystemName')
      safe_set_param(block,'RTWFcnNameOpts','Use subsystem name');
    elseif strcmp(get_param(block, 'RTWFcnNameOpts'), 'UserSpecified')
      safe_set_param(block,'RTWFcnNameOpts','User specified');
    elseif strcmp(get_param(block, 'RTWFileNameOpts'), 'UseSubsystemName')
      safe_set_param(block,'RTWFileNameOpts','Use subsystem name');
    elseif strcmp(get_param(block, 'RTWFileNameOpts'), 'UseFunctionName')
      safe_set_param(block,'RTWFileNameOpts','Use function name');
    elseif strcmp(get_param(block, 'RTWFileNameOpts'), 'UserSpecified')
      safe_set_param(block,'RTWFileNameOpts','User specified');
    end
    
  end
  
% end ReplaceEnumStr



%
%===============================================================================
% Replace3DOF
% Replace 3DOF equation of motion and re-route outputs
%===============================================================================
%
function [replace, prompt] = Replace3DOF( block, replace, prompt )

% make sure that block does not get replaced twice - mask type was not changed 
% from R12 to R12.1
if ((get_param(bdroot(block),'VersionLoaded')== 4) & ...
   ((strcmp(get_param(get_param(block,'Parent'),'Type'),'block') & ...
	 ~strcmp(get_param(get_param(block,'Parent'),'MaskType'), ...
			 '3 DOF equations of motion (R12)'))...
	| strcmp(get_param(get_param(block,'Parent'),'Type'),'block_diagram')))
 
    % prompt the user to replace block or not
    if prompt

       [replace,prompt] = AskToReplace(block);

       if ~replace
          return;
       end
    end

    % Save the original settings for the initial conditions
    entries = get_param(block,'MaskValues');
    safe_set_param(block,'LinkStatus','none');

    libBlock = sprintf('slupdate_aerospace/EoM (Body Axes)');

    % Replace with appropriate new block, set initial conditions
    % based on old setting, and break the link to this private library.
    block2link(block, libBlock);
    safe_set_param(block,'LinkStatus','none');
    block_child = find_system(block,'MaskType','3 DOF equations of motion');
    safe_set_param(block_child{:},'MaskValues',entries);

end

%
%===============================================================================
% ReplaceCloseFcnWithEmptyStr
% Replace an old CloseFcn of FROM block with empty string. This is a special 
% case for avoiding the warning message of missing function.
%===============================================================================
% 
function [replace, prompt] = ReplaceCloseFcnWithEmptyStr(block, replace, prompt)
  
  safe_set_param(block, 'CloseFcn', '');

% end 


function  [prompt,updatedBlocks] = restore_broken_links(sys,prompt_old,updatedBlocks_old)
%  Restore links to blocks from Simulink Library. 
%
% Description: Breaking or disabling library links to blocks from the 
%   Simulink Library is usually an unintended error.  Breaking or disabling
%   the link will generally not cause errors until an attempt is made to
%   use the model with a newer version of Simulink.  Often, the model
%   will not work with a newer version of Simulink because the library
%   links are not intact.  This script attempts to restore
%   the broken links to blocks from Simulink Library.  
%
%   Blocks that were formerly found in Fixed-Point Blockset have been unified 
%   with Simulink blocks and are now all found in the Simulink Library.  
%   This script will also attempt to restore links to blocks that originally 
%   came from Fixed-Point Blockset.
%  
%   Breaking links to blocks from Simulink Library is a problem for the
%   following reasons.   When the library link is intact,
%   a block instance depends on the library link interface.  Each new version 
%   of Simulink is designed to maintain compatibility with the library link
%   interface from prior Simulink versions.   When the library link is broken,
%   a block instance becomes dependent on internal details are not designed
%   to be compatible between releases.  As an example of one of many possible
%   problems, the internal implementation of a block may depend on an private 
%   SFunction.  In a newer release, that private SFunction might have a
%   different signature or may not even exist anymore.  Because of the broken 
%   link, the block will try to use old internal details that are no longer
%   functional.  The old model will not be usable in the new Simulink version.  
%  
%   This script is designed to attempt to restore broken links from as far
%   back as Simulink Version 3.0 and Fixed-Point Blockset Version 2.0 from 
%   1998.  The script can not handle every possible situation.  When a library
%   link is broken, information that directly identifies the original Reference
%   Block is destroyed.  The original reference block must be inferred from
%   the information that remains.  False inferences are possible.  The output
%   argument of this function will identify with which blocks had their links 
%   restored.
%  

prompt = prompt_old;
updatedBlocks = updatedBlocks_old;
  
%   lost link 
%     fixpt_lib_4/LookUp/Cosine/Handle Quarter Symetery Cosine
%

brokenLinks = find_system(sys,'LookUnderMasks','all','BlockType','S-Function','LinkStatus','none');
temp1       = find_system(sys,'LookUnderMasks','all','BlockType','S-Function','LinkStatus','inactive');
temp2       = find_system(sys,'LookUnderMasks','all','BlockType','SubSystem', 'LinkStatus','none');
temp3       = find_system(sys,'LookUnderMasks','all','BlockType','SubSystem', 'LinkStatus','inactive');

brokenLinks = [ brokenLinks; temp1; temp2; temp3 ];

numBrokenLinks = length(brokenLinks);

for iBrokenLink=1:numBrokenLinks
                
    curBadBlock = brokenLinks{iBrokenLink};
    
    replacementInfo = determineBrokenLinkReplacement(curBadBlock);

    if isempty(replacementInfo.newRefBlock)
      continue
    end

    % Restoring the link of a parent can make the child disappear
    %   so make sure block is still around.
    stillExists = find_system(curBadBlock,'LookUnderMasks','all');
    
    if isempty(stillExists)
      continue
    end
    
    name=CleanBlockName(curBadBlock);
    
    if prompt
      [replace,prompt]=AskToReplace(name);
    else  
      replace = 1;
    end
    
    if ~replace
      continue
    else
      block2link(curBadBlock, replacementInfo.newRefBlock);

      updatedBlocks{end+1} = name;
    end
end
  
