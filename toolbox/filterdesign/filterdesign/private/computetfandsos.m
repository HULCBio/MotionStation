function varargout = computetfandsos(numOrd,denOrd,bs,as,h0)
%COMPUTETFANDSOS  Compute SOS matrix and transfer function.
%
%   Private function used by:
%     - IIRLPNORM    
%     - IIRLPNORMC   
%     - IIRGRPDELAY (makes a special call with only one input argument
%                   in order to get the handle to the toSos function.

%   Author(s): D. Shpak
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/17 03:27:53 $

if nargin == 1,
    % Get handle to toSos function so that IIRGRPDELAY can use it
    if strcmpi(numOrd,'gettososhndl'),
        toSoshndl = @toSos;
        
        varargout = {toSoshndl};
        return
    else
        error('Invalid string specified.');
    end
end
    
sections = fix((max(numOrd,denOrd) + 1) / 2);
% Convert numerator and denominator into second-order sections format
b = toSos(bs, numOrd, sections);
a = toSos(as, denOrd, sections);
sos = [b a];

[num,den] = sos2tf(sos,h0);

% Remove trailing zeros
num = num(1:max(find(num~=0)));
den = den(1:max(find(den~=0)));

varargout = {num,den,sos};

%-----------------------------------------------------------------------
function q=toSos(qs, ord, nSections)
% The B and A sections from the mex function don't have
% the leading 1's required for MATLAB's second-order sections
% format so they are added here.

nTwo = ord / 2;
nOne = rem(ord, 2);
q = [];
k = 1;
for i=1:nTwo
   q = [q; 1 qs(k) qs(k+1)];
   k = k + 2;
end
if (nOne > 0)
   q = [q; 1 qs(k) 0];
   k = k + 2;
end
section = (k-1) / 2;
if (section < nSections)
   q = [q; repmat([1 0 0], nSections - section, 1)];
end

