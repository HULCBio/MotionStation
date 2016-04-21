function varargout = info(Hq)
%INFO Return information about the QFilt object
%   INFO(Hq) Return information about the QFilt object Hq.

%   Author: J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/09/23 13:26:19 $

if nargout,

    % Get the basic info from the DFilt
    Hd = qfilt2dfilt(Hq);
    str = info(Hd);
    
    title = str(1,:);
    title = sprintf('Quantized %s', deblank(title));
    str   = str(2:end,:);
    
    % Get the quantizer info
    head = sprintf('                      Mode    RoundMode   OverflowMode [WordLength FractionalLength]');
    q    = get(Hq, 'CoefficientFormat');
    cstr = sprintf('Coefficient Format  : %-7s %-11s %-12s [%d %d]', ...
        get(q, 'Mode'), get(q, 'RoundMode'), get(q, 'OverflowMode'), get(q, 'WordLength'), get(q, 'Fraction'));
    q    = get(Hq, 'InputFormat');
    istr = sprintf('Input Format        : %-7s %-11s %-12s [%d %d]', ...
        get(q, 'Mode'), get(q, 'RoundMode'), get(q, 'OverflowMode'), get(q, 'WordLength'), get(q, 'Fraction'));
    q    = get(Hq, 'OutputFormat');
    ostr = sprintf('Output Format       : %-7s %-11s %-12s [%d %d]', ...
        get(q, 'Mode'), get(q, 'RoundMode'), get(q, 'OverflowMode'), get(q, 'WordLength'), get(q, 'Fraction'));
    q    = get(Hq, 'MultiplicandFormat');
    mstr = sprintf('Multiplicand Format : %-7s %-11s %-12s [%d %d]', ...
        get(q, 'Mode'), get(q, 'RoundMode'), get(q, 'OverflowMode'), get(q, 'WordLength'), get(q, 'Fraction'));
    q    = get(Hq, 'ProductFormat');
    pstr = sprintf('Product Format      : %-7s %-11s %-12s [%d %d]', ...
        get(q, 'Mode'), get(q, 'RoundMode'), get(q, 'OverflowMode'), get(q, 'WordLength'), get(q, 'Fraction'));
    q    = get(Hq, 'SumFormat');
    sstr = sprintf('Sum Format          : %-7s %-11s %-12s [%d %d]', ...
        get(q, 'Mode'), get(q, 'RoundMode'), get(q, 'OverflowMode'), get(q, 'WordLength'), get(q, 'Fraction'));
    
    varargout = {strvcat(title, str, ' ', head, cstr, istr, ostr, mstr, pstr, sstr)};
else
    fvtool(Hq, 'info');
end

% [EOF]
