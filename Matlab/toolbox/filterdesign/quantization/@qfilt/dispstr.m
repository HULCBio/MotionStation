function str = dispstr(Hq)
%DISPSTR Quantized filter string for display.
%   STR = DISPSTR(Hq) returns the character array STR that is the default
%   display for quantized filter object Hq.
%
%   Example:
%     Hq = qfilt;
%     str = dispstr(Hq)
%
%   See also QFILT, QFILT/DISP.

%   Thomas A. Bryan, 15 November 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:30:49 $

c = longdescription(Hq);
c = {c,coeffstr(Hq),'',...
  ['   FilterStructure = ',filterstructure(Hq)],...
  ['       ScaleValues = [',deblank(sprintf('%g  ',scalevalues(Hq))),']'],...
  ['  NumberOfSections = ',num2str(get(Hq,'numberofsections'))],...
  ['  StatesPerSection = [',num2str(get(Hq,'statespersection')),']'],...
  [' CoefficientFormat = ',tostring(quantizer(Hq,'coefficient'))],...
  ['       InputFormat = ',tostring(quantizer(Hq,'input'))],...
  ['      OutputFormat = ',tostring(quantizer(Hq,'output'))],...
  ['MultiplicandFormat = ',tostring(quantizer(Hq,'multiplicand'))],...
  ['     ProductFormat = ',tostring(quantizer(Hq,'product'))],...
  ['         SumFormat = ',tostring(quantizer(Hq,'sum'))]};
warnmsg = Hq.overflowmessage;
if ~isempty(warnmsg)
  c = {c{:},['Warning: ',warnmsg]};
end

str = char(c);

%-----------------------------------------------------------------------
function str = longdescription(Hq)
%LONGDESCRIPTION Long filter structure description.
%
%   STR = LONGDESCRIPTION(Hq) returns a string containing a long description
%   of the filter structure.

s = filterstructure(Hq,'full');
str = sprintf(['Quantized ',s,' filter']);
