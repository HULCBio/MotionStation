function F = qfilt(varargin)
%QFILT Construct quantized filter objects.
%   QFILT is obsolete.  QFILT still works but may be removed in the future.
%   Use DFILT instead.
%
%   See also DFILT, FILTERDESIGN.

%   Thomas A. Bryan, 31 August 1999
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.27.4.2 $  $Date: 2004/04/12 23:26:04 $

msgid = generatemsgid('ObsoleteQfilt');

warning(msgid,'QFILT is obsolete. Use DFILT instead.');

report = qreportinit(1);
F = struct(...
    'coefficientformat', quantizer('fixed','saturate','round',[16 15]), ...
    'filterstructure', 'df2t', ...
    'inputformat', quantizer('fixed','saturate','floor',[16 15]), ...
    'numberofsections', 1, ...
    'multiplicandformat', quantizer('fixed','saturate','floor',[16 15]), ...
    'outputformat', quantizer('fixed','saturate','floor',[16 15]), ...
    'overflowmessage', '', ...
    'productformat', quantizer('fixed','saturate','floor',[32 30]), ...
    'quantizedcoefficients', {{1,1}}, ...
    'referencecoefficients', {{1,1}}, ...
    'report', report, ...
    'scalevalues', [], ...  % Empty scalevalues means skip the scaling.
    'statespersection', 0, ...
    'sumformat', quantizer('fixed','saturate','floor',[32 30]), ...
    'version', qfiltversion);

F = class(F, 'qfilt');

if nargin > 0
  F = set(F, varargin{:});
else
  wrn = warning('off');
  F = privquantizedesign(F);
  warning(wrn);
end