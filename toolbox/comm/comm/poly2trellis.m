%POLY2TRELLIS Convert convolutional code polynomial to trellis description.
%   TRELLIS = POLY2TRELLIS(CONSTRAINTLENGTH, CODEGENERATOR) converts a
%   polynomial representation of a feedforward convolutional encoder to a
%   trellis structure. For a rate k/n code, the encoder input is a vector of
%   length k, and the encoder output is a vector of length n. Therefore,
%
%   - CONSTRAINTLENGTH is a 1-by-k vector specifying the delay for each of
%     the k input bit streams.
%
%   - CODEGENERATOR is a k-by-n matrix of octal numbers specifying the n
%     output connections for each of the k inputs.
%
%   TRELLIS = POLY2TRELLIS(CONSTRAINTLENGTH, CODEGENERATOR, FEEDBACKCONNECTION)
%   is the same as the first syntax, but for a feedback convolutional encoder.
%
%   - FEEDBACKCONNECTION is a 1-by-k vector of octal numbers specifying the
%     feedback connection for each of the k inputs.
%
%   A trellis is represented by a structure with the following fields:
%     numInputSymbols,  (number of input symbols)
%     numOutputSymbols, (number of output symbols)
%     numStates,        (number of states)
%     nextStates,       (next state matrix)
%     outputs,          (output matrix)
%
%   For more information about trellis structures, type 'help istrellis' in
%   MATLAB.
%
%   See also ISTRELLIS, CONVENC, VITDEC.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/12 23:00:56 $
