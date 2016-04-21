function T = wavetype(wname,TYPE)
%WAVETYPE Wavelet type information.
%   T = WAVETYPE(W) returns the type T of the wavelet is W.
%   The valid values for T are:
%       - 'lazy' : for the "lazy" wavelet.
%       - 'orth' : for orthogonal wavelets.
%       - 'bior' : for biorthogonal wavelets.
%       - 'unknow' : for unknown names.
%
%   R = WAVETYPE(W,T) returns 1 if the wavelet W is of 
%   type T and 0 otherwise.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Jun-2003.
%   Last Revision 08-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/13 00:40:09 $ 

waveCell = wavenames('lazy');
if any(strcmpi(wname,waveCell))
    T = 'lazy';
else
    waveCell = wavenames('orth');
    if any(strcmpi(wname,waveCell))
        T = 'orth';
    else
        waveCell = wavenames('bior');
        if any(strcmpi(wname,waveCell))
            T = 'bior';
        else
            T = 'unknown';
        end
    end
end
if nargin>1
    T  = (lower(TYPE(1)) == T(1));
end