function [lib, b, params] = blockparams(this, mapstates)
%BLOCKPARAMS   Return the block parameters for the Digital Filter block.

%   Author(s): J. Schickler
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/01/25 22:44:47 $

if nargin < 2, mapstates = 'off'; end

% Get the defaults from the DFILT
[lib, b, params] = blockparams(qfilt2dfilt(this), mapstates);

fs = lower(get(this, 'FilterStructure'));
switch fs,
 case {'df1', 'df1t', 'df2', 'df2t', 'fir', 'firt'}

  params.firstCoeffMode       = 'User-Defined';
  params.firstCoeffWordLength = get(get(this, 'Coefficientformat'), 'format');
  params.firstCoeffFracLength = sprintf('%d', params.firstCoeffWordLength(2));
  params.firstCoeffWordLength = sprintf('%d', params.firstCoeffWordLength(1));
  if ~issos(this) && (any(strcmpi(fs, {'df1','df1t','df2','df2t'})))
    params.secondCoeffMode       = 'User-Defined';
    params.secondCoeffWordLength = get(get(this, 'Coefficientformat'), 'format');
    params.secondCoeffFracLength = sprintf('%d', params.secondCoeffWordLength(2));
    params.secondCoeffWordLength = sprintf('%d', params.secondCoeffWordLength(1));
  end

  params.outputMode       = 'User-Defined';
  params.outputWordLength = get(get(this, 'OutputFormat'), 'format');
  params.outputFracLength = sprintf('%d', params.outputWordLength(2));
  params.outputWordLength = sprintf('%d', params.outputWordLength(1));

  params.accumMode       = 'User-Defined';
  params.accumWordLength = get(get(this, 'SumFormat'), 'format');
  params.accumFracLength = sprintf('%d', params.accumWordLength(2));
  params.accumWordLength = sprintf('%d', params.accumWordLength(1));

  params.prodOutputMode       = 'User-Defined';
  params.prodOutputWordLength = get(get(this, 'ProductFormat'), 'format');
  params.prodOutputFracLength = sprintf('%d', params.prodOutputWordLength(2));
  params.prodOutputWordLength = sprintf('%d', params.prodOutputWordLength(1));

  switch get(get(this, 'SumFormat'), 'RoundMode')
   case 'floor'
    rmode = 'floor';
   otherwise
    rmode = 'nearest';
  end

  if strcmpi(get(get(this, 'SumFormat'), 'OverFlow'), 'saturate')
    omode = 'on';
  else
    omode = 'off';
  end

  params.roundingMode = rmode;
  params.overflowMode = omode;
 otherwise
  error(generatemsgid('unsupportedStructure'), ...
        'The Signal Processing Blockset does not support the ''%s'' structure.', fs);
end

% [EOF]
