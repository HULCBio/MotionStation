function varargout = tf(Hq)
%TF Convert quantized filter to transfer function.
%   [Bq,Aq,Br,Ar] = TF(Hq) converts the quantized filter coefficients from the
%   quantized filter Hq into transfer-function form with numerator Bq and
%   denominator Aq, and the reference coefficients into transfer-function form
%   with numerator Br and denominator Ar.  If the quantized filter Hq has more
%   than one section, then all the numerator polynomials are are convolved into
%   the numerator polynomial of a single transfer function.  Similarly, the
%   denominator polynomials are convolved into a denominator polynomial of a
%   single transfer function.
%
%   [Cq,Cr] = TF(Hq,'sections') returns one cell per section, 
%   where Cq is the transfer-function form of the quantized coefficients and
%   Cr is the transfer-function form of the reference coefficients.
%     Cq = {{Bq1,Aq1},{Bq2,Aq2},...}
%     Cr = {{Br1,Ar1},{Br2,Ar2},...}
%
%   Example:
%     [A,B,C,D]=butter(3,.2);
%     Hq=qfilt('statespace',{A,B,C,D},'mode','double');
%     [b,a]=tf(Hq)
%
%   See also QFILT.

%   Author(s): J. Schickler
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:29:28 $

output = nargout;
if output == 0
    output = 1;
end

[varargout{1:output}] = qfilt2tf(Hq);

% [EOF]
