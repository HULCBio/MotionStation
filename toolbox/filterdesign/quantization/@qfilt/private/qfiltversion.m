function v = qfiltversion
%QFILTVERSION  Qfilt object version number
%   V = QFILTVERSION  returns the qfilt object's version number.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:28:01 $

% Version history.
% 1 = R11.1
% 2 = R12
%
% Default R12 structure:
%  struct(qfilt)
%          coefficientformat: [1x1 quantizer]
%            filterstructure: 'df2t'
%                inputformat: [1x1 quantizer]
%           numberofsections: 1
%         multiplicandformat: [1x1 quantizer]
%               outputformat: [1x1 quantizer]
%            overflowmessage: '2 overflows in coefficients.'
%              productformat: [1x1 quantizer]
%      quantizedcoefficients: {[1.0000]  [1.0000]}
%      referencecoefficients: {[1]  [1]}
%                     report: [1x1 struct]
%                scalevalues: 1
%           statespersection: 0
%                  sumformat: [1x1 quantizer]
%                    version: 2
%
%
% 3 = R12.1
% In version 3, we changed the quantizers to UDD with parent class
% quantum.quantizer that lives in C++, and a child class
% quantum.mquantizer that lives in M.  The constructor is still the
% same, with a gateway from QUANTIZER.M.
%
% Default R12.1 structure:
%   struct(qfilt)
%  
%          coefficientformat: [1x1 quantum.mquantizer]
%            filterstructure: 'df2t'
%                inputformat: [1x1 quantum.mquantizer]
%           numberofsections: 1
%         multiplicandformat: [1x1 quantum.mquantizer]
%               outputformat: [1x1 quantum.mquantizer]
%            overflowmessage: '2 overflows in coefficients.'
%              productformat: [1x1 quantum.mquantizer]
%      quantizedcoefficients: {[1.0000]  [1.0000]}
%      referencecoefficients: {[1]  [1]}
%                     report: [1x1 struct]
%                scalevalues: 1
%           statespersection: 0
%                  sumformat: [1x1 quantum.mquantizer]
%                    version: 3

v = 3;