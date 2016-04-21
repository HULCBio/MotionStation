function Fmax = commblkfskupcon(block, action)
% COMMBLKFSKUPCON Mask dynamic dialog function for FSK and CPM upconverter

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/01/26 18:45:38 $

%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************
maskM = [];

switch(action)
  
  %*********************************************************************
  % Function Name:     init
  % Description:       Main initialization code
  % Inputs:            current block
  % Return Values:     Fmax, the maximum frequency of the input signal --
  %                    Fmax is used to set interpolator filter cutoff frequencies
  %********************************************************************
case 'init'
  % --- Set Field index numbers and mask variable data
  setallfieldvalues(block);
  
  % --- Ensure that the mask is correct
  cbModType(block);
  
  % Error checking
  
  % Modulation type first
  if ~(maskModType == 'FSK' | ...
       maskModType == 'CPM')
    error('Unkown modulation type');
  end;
  
  if (maskModType == 'FSK')
    % M, the number of symbols in the symbol set
    if (isempty(maskM) | ...
        prod(size(maskM)) ~= 1 | ...
        maskM < 2 | ...
        round(maskM) ~= maskM | ...
        ischar(maskM))
      error('The M-ary number must be an integer scalar greater than 1');
    end;
  
    % freqSep, the separation frequency between FSK tones
    if (isempty(maskFreqSep) | ...
        prod(size(maskFreqSep)) ~= 1 | ...
        maskFreqSep <= 0 | ...
        ischar(maskFreqSep))
      error('The FSK frequency separation must be a real, positive scalar');
    end;
  end;  
  
  % td, the symbol period
  if (isempty(maskTd) | ...
      prod(size(maskTd)) ~= 1 | ...
      maskTd <= 0 | ...
      ischar(maskTd))
    error('The symbol period must be a real, positive scalar');
  end;
  
  % Fc, the carrier frequency
  if (isempty(maskFc) | ...
      prod(size(maskFc)) ~= 1 | ...
      maskFc <= 0 | ...
      ischar(maskFc))
    error('The carrier frequency must be a real, positive scalar');
  end;
  
  % Ph, the carrier initial phase
  if (isempty(maskPh) | ...
      prod(size(maskPh)) ~= 1 | ...
      ischar(maskPh))
    error('The carrier frequency must be a real scalar');
  end;
  
  % Tin, the input sample time
  if (isempty(maskTin) | ...
      prod(size(maskTin)) ~= 1 | ...
      maskTin <= 0 | ...
      ischar(maskTin))
    error('The input sample time must be a real, positive scalar');
  end;

  % Tout, the output sample time
  if (isempty(maskTout) | ...
      prod(size(maskTout)) ~= 1 | ...
      maskTout <= 0 | ...
      ischar(maskTout))
    error('The output sample time must be a real, positive scalar');
  end;

  % Check for validity of parameter relationships
  if (maskFc <= 1/maskTin)
    error('The carrier frequency must be greater than the reciprocal of the input sample time');
  end;
  numSamp = maskTd / maskTin;
  if (numSamp < round(numSamp) - 1.e-6 | ...
      numSamp > round(numSamp) + 1.e-6 | ...
      round(numSamp) < 1)
    error('The symbol period must be a positive integer multiple of the input sample time');
  end;
  FsampIn = 1/maskTin;
  FsampOut = 1/maskTout;
  intFactor = FsampOut / FsampIn;
  if (intFactor < round(intFactor) - 1.e-6 | ...
      intFactor > round(intFactor) + 1.e-6 | ...
      round(intFactor) < 1)
    error('The input sample time must be a positive integer multiple of the output sample time');
  end;
  intFactor = round(intFactor);
  
  % Determine the maximum frequency extent of the FSK or CPM signal.  For FSK, allow some
  % margin, and for CPM, ensure the the main lobe is captured.
  switch lower(maskModType)
  case 'fsk'
    Fmax = ((maskM-1)/2) * maskFreqSep;   % Highest tone frequency
    Fmax = Fmax + 1/maskTd;               % First lobe of underlying sinc function
    if (Fmax >= FsampIn/2)   
      error('The reciprocal of the input sample time must exceed twice the sum of the maximum FSK frequency and the reciprocal of the symbol period');
    end;
    if (Fmax >= maskFc)
      error('The carrier frequency must exceed the sum of the maximum FSK frequency and the reciprocal of the symbol period');
    end;  
  case 'cpm'
    Rsym = 1/maskTd;
    Fmax = 2 * Rsym;				% Main lobe for MSK
    if (FsampIn <= 2*Fmax)
      error('The input sample time should be less than 1/4 the symbol period')
    end;
  end;
  if (FsampOut <= 2*(maskFc + Fmax))
    error('The reciprocal of the output sample time must be greater than twice the sum of the carrier frequency and the maximum baseband signal frequency');
  end;

% ---- end of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbModType'
  cbModType(block);
  
end;    % end of switch(action) statement


% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbModType
% Description:      Deal with the different input modes
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Return Values:    Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbModType(block)

  % --- Set Field index numbers
  setfieldindexnumbers(block);

  Vals = get_param(block, 'MaskValues');
  
  switch lower(Vals{idxModType})
  case 'fsk'
    set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','on','on','on'});
  case 'cpm'
    set_param(gcb,'MaskVisibilities',{'on','off','off','on','on','on','on','on'});
  otherwise
    error('Unknown modulation type.');
  end;
return;

% [EOF] commblkfskupcon.m