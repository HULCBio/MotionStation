function b = fi_fir_coefficients
%FI_FIR_COEFFICIENTS   FIR filter coefficients for FI demos.
%   B = FI_FIR_COEFFICIENTS returns FIR filter coefficients used in FI demos.
% 
%   The coefficients were computed with these functions from the Signal
%   Processing Toolbox.
%
%   FIRPMORD  Parks-McClellan optimal equiripple FIR order estimator.
%   FIRPM Parks-McClellan optimal equiripple FIR filter design.
%
%   [L,fo,mo,w] = firpmord([1500 2000],[1 0], [0.01 01.], 8000 );
%   b = firpm(L,fo,mo,w);

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/20 23:17:31 $

b = [-0.0204578867332901
     0.00866039546135874
     0.106866761907635
     -0.218770646053448
     0.0730546552429824
     0.315303787611475
     0.4649509557016
     0.315303787611475
     0.0730546552429824
     -0.218770646053448
     0.106866761907635
     0.00866039546135874
     -0.0204578867332901]';

