function v = qfftversion
%QFFTVERSION  QFFT object version number.
%   V = QFFTVERSION  returns the QFFT object's current version number.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:25:32 $

% Version history.
% 1 = R12
%
% In R12, the quantizers were Java-based.
% Default R12 structure:
%  struct(qfft)
%                  radix: 2
%                 length: 16
%      coefficientformat: [1x1 quantizer]
%            inputformat: [1x1 quantizer]
%           outputformat: [1x1 quantizer]
%     multiplicandformat: [1x1 quantizer]
%          productformat: [1x1 quantizer]
%              sumformat: [1x1 quantizer]
%            scalevalues: 1
%                version: 1
%
% 2 = R12.1
%
% In R12.1, the quantizers were UDD-based.
% Default R12.1 structure:
%  struct(qfft)
%                  radix: 2
%                 length: 16
%      coefficientformat: [1x1 quantizer]
%            inputformat: [1x1 quantizer]
%           outputformat: [1x1 quantizer]
%     multiplicandformat: [1x1 quantizer]
%          productformat: [1x1 quantizer]
%              sumformat: [1x1 quantizer]
%            scalevalues: 1
%                version: 1

v = 2;
