function fmt = productformat(F)
%PRODUCTFORMAT  Product format of a quantized FFT object.
%   Q = PRODUCTFORMAT(F) returns the value of the PRODUCTFORMAT property of
%   quantized FFT object F.  Quantized FFTs use the PRODUCTFORMAT to quantize
%   their products.  The value is either a QUANTIZER object or a UNITQUANTIZER
%   object.  For more information on this property, see the help for QUANTIZER
%   and UNITQUANTIZER.
%
%   The default is 
%     q = quantizer('fixed', 'floor', 'saturate', [32 30])
%
%   Example:
%     F = qfft
%     q = productformat(F)
%
%   See also QFFT, QFFT/GET, QFFT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:26:31 $

fmt = F.productformat;
