function varargout = dspblkfilter(action,varargin)
% DSPBLKFILTER Mask dynamic dialog function for Digital Filter block

% Copyright 1995-2004 The MathWorks, Inc.
% $Date: 2004/04/12 23:06:28 $ $Revision: 1.19.6.6 $

% Mapping of mask-values to mask parameters:
% mask_vals{1}  -> filter type popup
% mask_vals{2}  -> Filter struct popup (IIR)
% mask_vals{3}  -> Filter struct popup (IIR AllPole)
% mask_vals{4}  -> Filter struct popup (FIR)
% mask_vals{5}  -> Coefficient source popup
% mask_vals{11} -> Coeff update rate popup

  if nargin==0, action = 'init'; end

  currBlock = gcbh;
  switch action
   case 'icon'
    iconStruct = genFilterIconStruct(currBlock);
    varargout(1) = {iconStruct};
   case 'init'
    argsStruct   = genFilterArgsStruct(currBlock);
    dtInfo       = dspGetFixptDataTypeInfo(currBlock,63);
    varargout(1) = {argsStruct};
    varargout(2) = {dtInfo};
   case 'validateICs'
    ICs = varargin{1};
    errmsg = validateICs(ICs);
    varargout(1) = {errmsg};
   case 'validateNumCoeffs'
    NumCoeffs = varargin{1};
    errmsg = validateNumCoeffs(NumCoeffs);
    varargout(1) = {errmsg};
   case 'validateDenCoeffs'
    DenCoeffs = varargin{1};
    errmsg = validateDenCoeffs(DenCoeffs);
    varargout(1) = {errmsg};
   case 'validateRefCoeffs'
    RefCoeffs = varargin{1};
    errmsg = validateRefCoeffs(RefCoeffs);
    varargout(1) = {errmsg};
   case 'validateSOSCoeffs'
    SOSCoeffs   = varargin{1};
    ScaleValues = varargin{2};
    errmsg = validateSOSCoeffs(SOSCoeffs,ScaleValues);
    varargout(1) = {errmsg};
   otherwise
    error('Invalid mask helper function argument.');
  end

%-------------------------------------------------------------------------------
%      FUNCTIONS TO GENERATE FILTER ICONS
%-------------------------------------------------------------------------------
function iconStruct = genFilterIconStruct(currBlock)

  mask_vals = get_param(currBlock, 'MaskValues');
  coeffSrcStr = mask_vals{5};
  switch coeffSrcStr
   case 'Input port(s)'
    iconStruct.in = 'In'; iconStruct.out = 'Out';
    coeffFrmPort = 1;
   otherwise
    iconStruct.i1 = 1;  iconStruct.s1  = '';
    iconStruct.i2 = 1;  iconStruct.s2  = '';
    iconStruct.in = ''; iconStruct.out = '';
    coeffFrmPort = 0;
  end
  filtTypeStr = mask_vals{1};
  switch filtTypeStr
   case 'IIR (poles & zeros)'
    %% generate IIR icon
    filtStructStr = mask_vals{2};
    iconStruct = genIIRIconStruct(filtStructStr, coeffFrmPort, iconStruct);
    %%
   case 'IIR (all poles)'
    %% generate all-pole icon
    filtStructStr = mask_vals{3};
    iconStruct = genAllPoleIconStruct(filtStructStr, coeffFrmPort, iconStruct);
    %%
   case 'FIR (all zeros)'
    %% generate FIR icon
    filtStructStr = mask_vals{4};
    iconStruct = genFIRIconStruct(filtStructStr, coeffFrmPort, iconStruct);
    %%
  end

%-------------------------------------------------------------------------------
function iconStruct = genIIRIconStruct(filtStructStr, coeffFrmPort, iconStruct)
  switch filtStructStr
   case {'Biquad direct form I (SOS)', ...
         'Biquad direct form I transposed (SOS)', ...
         'Biquad direct form II (SOS)', ...
         'Biquad direct form II transposed (SOS)'}
    %% SOS structures:
    if (coeffFrmPort)
      %% Biquads currently do not support port-based coeffs
      %% Therefore, generate icon assuming mask-based coeffs
      iconStruct.i1 = 1;  iconStruct.s1  = '';
      iconStruct.i2 = 1;  iconStruct.s2  = '';
      iconStruct.in = ''; iconStruct.out = '';
      coeffFrmPort = 0;
    end
    iconStruct.x = [0.05 0.95 NaN .25 .25 .75 .75 NaN .5 .5 NaN .25 .75];
    iconStruct.y = [.75 .75 NaN .75 .15 .15 .75 NaN .75 .15 NaN .45 .45];
    switch filtStructStr
     case 'Biquad direct form I (SOS)'
      iconStruct.icon = 'SOS DF1';
     case 'Biquad direct form I transposed (SOS)'
      iconStruct.icon = 'SOS DF1T';
     case 'Biquad direct form II (SOS)'
      iconStruct.icon = 'SOS DF2';
     case 'Biquad direct form II transposed (SOS)'
      iconStruct.icon = 'SOS DF2T';
    end
    %%
   case {'Direct form I', ...
         'Direct form I transposed', ...
         'Direct form II', ...
         'Direct form II transposed'}
    %% General IIR structures:
    if (coeffFrmPort)
      iconStruct.i1 = 2;    iconStruct.s1  = 'Num';
      iconStruct.i2 = 3;    iconStruct.s2  = 'Den';
    end
    iconStruct.x = [.2 .8 .7 .7 .5 .5 .3 .3  .7  .3  .3 .7 .3 .3  .7  .3  .3 .7];
    iconStruct.y = [.7 .7 .7 .1 .1 .7 .7 .55 .55 .55 .4 .4 .4 .25 .25 .25 .1 .1];
    switch filtStructStr
     case 'Direct form I'
      iconStruct.icon = 'IIR DF1';
     case 'Direct form I transposed'
      iconStruct.icon = 'IIR DF1T';
     case 'Direct form II'
      iconStruct.icon = 'IIR DF2';
     case 'Direct form II transposed'
      iconStruct.icon = 'IIR DF2T';
    end
  end

%-------------------------------------------------------------------------------
function iconStruct = genAllPoleIconStruct(filtStructStr, coeffFrmPort, iconStruct)
  switch filtStructStr
   case 'Direct form transposed'
    %% generate Direct form transposed All-Pole icon
    iconStruct.icon = 'IIR All-Pole';
    if (coeffFrmPort)
      iconStruct.i1 = 2;    iconStruct.s1  = '';
      iconStruct.i2 = 2;    iconStruct.s2  = 'Den';
    end
    iconStruct.x = [.2 .8 .6 .6 .4 .4 .4  .6  .4  .4 .6 .4 .4  .6  .4  .4 .6];
    iconStruct.y = [.7 .7 .7 .1 .1 .7 .55 .55 .55 .4 .4 .4 .25 .25 .25 .1 .1];
    %%
   case 'Direct form'
    %% generate Direct form transposed All-Pole icon
    iconStruct.icon = 'IIR All-Pole';
    if (coeffFrmPort)
      iconStruct.i1 = 2;    iconStruct.s1  = '';
      iconStruct.i2 = 2;    iconStruct.s2  = 'Den';
    end
    iconStruct.x = [.2 .8 .6 .6 .4 .4 .4  .6  .4  .4 .6 .4 .4  .6  .4  .4 .6];
    iconStruct.y = [.7 .7 .7 .1 .1 .7 .55 .55 .55 .4 .4 .4 .25 .25 .25 .1 .1];
    %%
   case 'Lattice AR'
    %% generate Lattice AR icon
    iconStruct.icon = 'Lattice AR';
    if (coeffFrmPort)
      iconStruct.i1 = 2;    iconStruct.s1  = '';
      iconStruct.i2 = 2;    iconStruct.s2  = 'K';
    end
    iconStruct.x = [.2 .8 .725 .725 .575 .675 .575 .675 .425 .525 .425 .525 .375 .275];
    iconStruct.y = [.7 .7 .7   .3   .3   .7   .7   .3   .3   .7   .7   .3   .3   .7];
    %%
   otherwise
    error('Invalid filter structure specified for IIR all-pole filter type.');
  end

%-------------------------------------------------------------------------------
function iconStruct = genFIRIconStruct(filtStructStr, coeffFrmPort, iconStruct)
  if (strcmp(filtStructStr,'Lattice MA'))
    %% generate Lattice MA icon
    iconStruct.icon = 'Lattice MA';
    if (coeffFrmPort)
      iconStruct.i1 = 2;    iconStruct.s1  = '';
      iconStruct.i2 = 2;    iconStruct.s2  = 'K';
    end
    iconStruct.x = [.2 .8 .725 .725 .575 .675 .575 .675 .425 .525 .425 .525 .375 .275];
    iconStruct.y = [.7 .7 .7   .3   .3   .7   .7   .3   .3   .7   .7   .3   .3   .7];
    iconStruct.x = 1.0 - iconStruct.x;
    %%
  else
    if (coeffFrmPort)
      iconStruct.i1 = 2;    iconStruct.s1  = '';
      iconStruct.i2 = 2;    iconStruct.s2  = 'Num';
    end
    iconStruct.x = [.3 .8 .7 .5 .6 .5 .5 .4 .3 .5 .2];
    iconStruct.y = [.1 .1 .1 .7 .1 .1 .7 .1 .1 .7 .7];
    switch filtStructStr
     case 'Direct form transposed'
      iconStruct.icon = 'TDF FIR';
     case 'Direct form'
      iconStruct.icon = 'DF FIR';
     case 'Direct form symmetric'
      iconStruct.icon = 'DF SYM FIR';
     case 'Direct form antisymmetric'
      iconStruct.icon = 'DF ASYM FIR';
     otherwise
       error('Invalid filter structure specified for FIR filter type.');
    end
  end

%-------------------------------------------------------------------------------
%      FUNCTIONS TO GENERATE FILTER ARGUMENTS
%-------------------------------------------------------------------------------
function argsStruct = genFilterArgsStruct(currBlock)
  mask_vals  = get_param(currBlock, 'MaskValues');
  coeffSrc   = mask_vals{5};
  if (strcmp(coeffSrc, 'Specify via dialog'))
    argsStruct.CoeffsFromMask = 1;
  else
    argsStruct.CoeffsFromMask = 0;
  end
  if (strcmp(mask_vals{11}, 'One filter per sample'))
    argsStruct.FilterPerSample = 1;
  else
    argsStruct.FilterPerSample = 0;
  end
  argsStruct.a0CoeffIsUnity = double(dspGetEditBoxParamValue(gcbh,'denIgnore'));
  %% Init coefficient fields to [] to avoid errors when they
  %% are invoked in modes where they are unused
  argsStruct.Coeff1      = []; %% Unused in sos and lattice modes
  argsStruct.Coeff2      = []; %% Only used in general IIR mode
  argsStruct.sosCoeffs   = []; %% Only used in sos mode
  argsStruct.scaleValues = []; %% Only used in sos mode
  filtType = mask_vals{1};
  switch filtType
   case 'IIR (poles & zeros)'
    filtStruct = mask_vals{2};
    argsStruct = genIIRArgsStruct(filtStruct, argsStruct);
   case 'IIR (all poles)'
    argsStruct.IC = dspGetEditBoxParamValue(gcbh,'IC');
    filtStruct = mask_vals{3};
    argsStruct = genAllPoleArgsStruct(filtStruct, argsStruct);
   case 'FIR (all zeros)'
    argsStruct.IC = dspGetEditBoxParamValue(gcbh,'IC');
    filtStruct = mask_vals{4};
    argsStruct = genFIRArgsStruct(filtStruct, argsStruct);
   otherwise
    error(['Invalid filter type encountered ' ...
           'when determining filter block arguments.']);
  end
  %% If any IC is [], use a scalar zero instead:
  if ~iscell(argsStruct.IC)
    if isempty(argsStruct.IC)
      argsStruct.IC = 0;
    end
    errmsg = validateICs(argsStruct.IC);
    if ~isempty(errmsg); error(errmsg); end;
    %% IC passed all checks, send down to S-function as double-prec
    argsStruct.IC = double(argsStruct.IC);
  else
    %% IC is in a cell array, this means we're in IIR DF1/DF1T mode
    %% There are two ICs in the cell array, check each for []
    for i = 1:length(argsStruct.IC)
      if isempty(argsStruct.IC{i})
        argsStruct.IC{i} = 0;
      end
      errmsg = validateICs(argsStruct.IC{i});
      if ~isempty(errmsg); error(errmsg); end;
      %% IC passed all checks, send down to S-function as double-prec
      argsStruct.IC{i} = double(argsStruct.IC{i});
    end
  end

%-------------------------------------------------------------------------------
function argsStruct = genIIRArgsStruct(filtStruct, argsStruct)
  %% Handle ICs
  switch filtStruct
   case {'Direct form I', 'Direct form I transposed', ...
         'Biquad direct form I (SOS)', 'Biquad direct form I transposed (SOS)'}
    % IC in this case is a cell array of the two ICs states entered by user
    IC1 = dspGetEditBoxParamValue(gcbh,'ICnum');
    IC2 = dspGetEditBoxParamValue(gcbh,'ICden');
    argsStruct.IC = {IC1,IC2};
   otherwise
    % IC is a single parameter
    argsStruct.IC = dspGetEditBoxParamValue(gcbh,'IC');
  end

  %% Setup FilterStruct values according to enum in sdspfilter2.cpp
  switch filtStruct
   case {'Direct form I', 'Biquad direct form I (SOS)'}
    argsStruct.FilterStruct = 2;
   case {'Direct form I transposed', 'Biquad direct form I transposed (SOS)'}
    argsStruct.FilterStruct = 3;
   case {'Direct form II', 'Biquad direct form II (SOS)'}
    argsStruct.FilterStruct = 4;
   case {'Direct form II transposed', 'Biquad direct form II transposed (SOS)'}
    argsStruct.FilterStruct = 5;
  end

  %% Handle coeffs and other info
  switch filtStruct
   case {'Direct form I', 'Direct form I transposed', ...
         'Direct form II', 'Direct form II transposed'}
    %% FilterType value corresponds to enum in sdspfilter2.cpp
    argsStruct.FilterType = 0;
    if (argsStruct.CoeffsFromMask == 1)
      argsStruct.Coeff1 = dspGetEditBoxParamValue(gcbh,'NumCoeffs');
      errmsg = validateNumCoeffs(argsStruct.Coeff1);
      if ~isempty(errmsg); error(errmsg); end;
      % Coeff1 passed checks, pass to S-fcn as double
      argsStruct.Coeff1 = double(argsStruct.Coeff1);

      argsStruct.Coeff2 = dspGetEditBoxParamValue(gcbh,'DenCoeffs');
      errmsg = validateDenCoeffs(argsStruct.Coeff2);
      if ~isempty(errmsg); error(errmsg); end;
      % Coeff2 passed checks, pass to S-fcn as double
      argsStruct.Coeff2 = double(argsStruct.Coeff2);

      if (argsStruct.Coeff2(1) ~= 1)
        argsStruct.a0CoeffIsUnity = 0;
      else
        argsStruct.a0CoeffIsUnity = 1;
      end
    end
   case {'Biquad direct form I (SOS)', 'Biquad direct form I transposed (SOS)', ...
         'Biquad direct form II (SOS)', 'Biquad direct form II transposed (SOS)'}
    %% FilterType value corresponds to enum in sdspfilter2.cpp
    argsStruct.FilterType = 3;
    argsStruct.CoeffsFromMask = 1;
    argsStruct.a0CoeffIsUnity = 1;
    SOSMatrix = dspGetEditBoxParamValue(gcbh,'BiQuadCoeffs');
    scaleVals = dspGetEditBoxParamValue(gcbh,'ScaleValues');
    errmsg = validateSOSCoeffs(SOSMatrix,scaleVals);
    if ~isempty(errmsg); error(errmsg); end;

    % SOSMatrix and scaleVals passed all checks, pass them to S-fcn as doubles
    SOSMatrix = double(SOSMatrix);
    scaleVals = double(scaleVals);

    numSections = size(SOSMatrix,1); %% numSections = rows in Mx6 SOS Matrix
    h = SOSMatrix(:,[1:3 5 6]);
    for i=1:numSections
      h(i,:)=h(i,:)./SOSMatrix(i,4);  % Normalize by a0
    end
    argsStruct.sosCoeffs = h.'; %% S-function expects a 5xM matrix of coeffs
    if isscalar(scaleVals)
      %% Pad scale value with M ones (consistent with dfilt treatment)
      argsStruct.scaleValues = [scaleVals; ones(numSections,1)];
    else
      argsStruct.scaleValues = scaleVals;
    end
   otherwise
    error('Invalid filter structure specified for IIR filter type.');
  end

%-------------------------------------------------------------------------------
function argsStruct = genAllPoleArgsStruct(filtStruct, argsStruct)
  %% FilterType value corresponds to enum in sdspfilter2.cpp
  argsStruct.FilterType = 2;
  if strcmp(filtStruct,'Lattice AR')
    argsStruct.a0CoeffIsUnity = 1;
  end
  if (argsStruct.CoeffsFromMask == 1)
    if (strcmp(filtStruct,'Lattice AR'))
      argsStruct.Coeff1 = dspGetEditBoxParamValue(gcbh,'LatticeCoeffs');
      errmsg = validateRefCoeffs(argsStruct.Coeff1);
      if ~isempty(errmsg); error(errmsg); end;
      % Coeff1 passed checks, pass to S-fcn as double
      argsStruct.Coeff1 = double(argsStruct.Coeff1);
      if (max(abs(argsStruct.Coeff1)) > 1)
        warning('SPBlks:DigitalFilter:UnstableLatticeAR', ...
              ['Possible unstable filter specified for lattice AR - ' ...
             'some reflection coefficient magnitudes were greater than 1.']);
      end
    else
      argsStruct.Coeff1 = dspGetEditBoxParamValue(gcbh,'DenCoeffs');
      errmsg = validateDenCoeffs(argsStruct.Coeff1);
      if ~isempty(errmsg); error(errmsg); end;
      % Coeff1 passed checks, pass to S-fcn as double
      argsStruct.Coeff1 = double(argsStruct.Coeff1);
      if (argsStruct.Coeff1(1) ~= 1)
        argsStruct.a0CoeffIsUnity = 0;
      else
        argsStruct.a0CoeffIsUnity = 1;
      end
    end
  end
  switch filtStruct
   %% FilterStruct value corresponds to enum in sdspfilter2.cpp
   case 'Direct form'
    argsStruct.FilterStruct = 0;
   case 'Direct form transposed'
    argsStruct.FilterStruct = 1;
   case 'Lattice AR'
    argsStruct.FilterStruct = 6;
  end

%-------------------------------------------------------------------------------
function argsStruct = genFIRArgsStruct(filtStruct, argsStruct)
  %% FilterType value corresponds to enum in sdspfilter2.cpp
  argsStruct.FilterType = 1;
  argsStruct.a0CoeffIsUnity = 1;
  if (argsStruct.CoeffsFromMask == 1)
    if (strcmp(filtStruct,'Lattice MA'))
      argsStruct.Coeff1 = dspGetEditBoxParamValue(gcbh,'LatticeCoeffs');
      errmsg = validateRefCoeffs(argsStruct.Coeff1);
      if ~isempty(errmsg); error(errmsg); end;
    else
      argsStruct.Coeff1 = dspGetEditBoxParamValue(gcbh,'NumCoeffs');
      errmsg = validateNumCoeffs(argsStruct.Coeff1);
      if ~isempty(errmsg); error(errmsg); end;
    end
  end
  % Coeff1 passed checks, pass to S-fcn as double
  argsStruct.Coeff1 = double(argsStruct.Coeff1);
  switch filtStruct
   %% FilterStruct value corresponds to enum in sdspfilter2.cpp
   case 'Direct form'
    argsStruct.FilterStruct = 0;
   case 'Direct form symmetric'
    argsStruct.FilterStruct = 7;
   case 'Direct form antisymmetric'
    argsStruct.FilterStruct = 8;
   case 'Direct form transposed'
    argsStruct.FilterStruct = 1;
   case 'Lattice MA'
    argsStruct.FilterStruct = 6;
   otherwise
    error('Invalid filter structure specified for FIR filter type.');
  end

%-------------------------------------------------------------------------------
function errmsg = validateICs(ICs)
  errmsg = '';
  if ~isnumeric(ICs)
    errmsg = 'Initial conditions must be numeric';
  elseif (any(isinf(ICs(:))) || any(isnan(ICs(:))))
    errmsg = 'Initial conditions cannot be Inf or NaN.';
  end

%-------------------------------------------------------------------------------
function errmsg = validateNumCoeffs(NumCoeffs)
  errmsg = '';
  if ~isnumeric(NumCoeffs)
    errmsg = 'Numerator must be numeric';
  elseif isempty(NumCoeffs)
    errmsg = 'Numerator must be non-empty';
  elseif ~isvector(NumCoeffs)
    errmsg = 'Numerator must be a vector';
  elseif (any(isinf(NumCoeffs(:))) || any(isnan(NumCoeffs(:))))
    errmsg = 'Numerator cannot be Inf or NaN';
  end

%-------------------------------------------------------------------------------
function errmsg = validateDenCoeffs(DenCoeffs)
  errmsg = '';
  if ~isnumeric(DenCoeffs)
    errmsg = 'Denominator must be numeric';
  elseif isempty(DenCoeffs)
    errmsg = 'Denominator must be non-empty';
  elseif ~isvector(DenCoeffs)
    errmsg = 'Denominator must be a vector';
  elseif (DenCoeffs(1) == 0.0)
    errmsg = 'First denominator coefficient must be non-zero';
  elseif (any(isinf(DenCoeffs(:))) || any(isnan(DenCoeffs(:))))
    errmsg = 'Denominator cannot be Inf or NaN';
  end

%-------------------------------------------------------------------------------
function errmsg = validateRefCoeffs(RefCoeffs)
  errmsg = '';
  if ~isnumeric(RefCoeffs)
    errmsg = 'Reflection coefficients must be numeric';
  elseif isempty(RefCoeffs)
    errmsg = 'Reflection coefficients must be non-empty';
  elseif ~isvector(RefCoeffs)
    errmsg = 'Reflection coefficients must be in a vector';
  elseif (any(isinf(RefCoeffs(:))) || any(isnan(RefCoeffs(:))))
    errmsg = 'Reflection coefficients cannot be Inf or NaN';
  end

%-------------------------------------------------------------------------------
function errmsg = validateSOSCoeffs(SOSCoeffs,ScaleValues)
  errmsg = '';
  [numSections,numCoeffs] = size(SOSCoeffs);
  if ~isnumeric(SOSCoeffs)
    errmsg = 'SOS matrix must be numeric';
    return;
  elseif isempty(SOSCoeffs)
    errmsg = 'SOS matrix must be non-empty';
    return;
  elseif ((numSections < 1) || (numCoeffs ~= 6))
    errmsg = ['Biquad SOS matrix must be an Mx6 matrix.' ...
             sprintf('\n') 'See "zp2sos", "ss2sos", or "tf2sos" for details.'];
    return;
  elseif (any(isinf(SOSCoeffs(:))) || any(isnan(SOSCoeffs(:))))
    errmsg = 'SOS coefficients cannot be Inf or NaN';
    return;
  elseif any(SOSCoeffs(:,4) == 0.0)
    errmsg = 'Leading denominator coefficients (a0 entries, i.e. 4th column) in SOS matrix must be non-zero';
    return;
  end

  if ~isnumeric(ScaleValues)
    errmsg = 'Scale values must be numeric';
  elseif isempty(ScaleValues)
    errmsg = 'Scale values must be non-empty';
  elseif ~isvector(ScaleValues)
    errmsg = 'Scale values must be specified in a vector';
  elseif (~isscalar(ScaleValues) && (length(ScaleValues) ~= (numSections+1)))
    errmsg = ['Scale values must either be scalar or have length ' ...
              'one more than the number of sections'];
  elseif (any(isinf(ScaleValues(:))) || any(isnan(ScaleValues(:))))
    errmsg = 'Scale values cannot be Inf or NaN';
  end
