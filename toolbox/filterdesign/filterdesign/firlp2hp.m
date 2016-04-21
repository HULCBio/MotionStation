function b = firlp2hp(b,flag)
%FIRLP2HP  FIR lowpass to highpass transformation.
%   G = FIRLP2HP(B) transforms a lowpass FIR filter B with zero-phase
%   response Hr(w) into a highpass FIR filter G with zero-phase response
%   Hr(pi-w).
%
%   The passband and stopband ripples of G will be equal to the
%   passband and stopband ripples of B respectively.
%
%   G = FIRLP2HP(B,'wide') transforms the type I lowpass FIR filter
%   B with zero-phase response Hr(w) into a type I highpass FIR
%   filter G with zero-phase response 1 - Hr(w).
%
%   For this case, the passband and stopband ripples of G will be
%   equal to the stopband and passband ripples of B respectively.
%
%   EXAMPLE:
%      % Overlay the original narrowband lowpass and the
%      % resulting narrowband highpass and wideband highpass
%      b = firgr(36,[0 .2 .25 1],[1 1 0 0],[1 3]);
%      s = warning('off','signal:zerophase:syntaxChanged');
%      [Hzlp,w] = zerophase(b); 
%      h = firlp2hp(b);
%      Hzhp = zerophase(h);
%      g = firlp2hp(b,'wide');
%      Hzwhp = zerophase(g);
%      plot(w/pi,[Hzlp,Hzhp,Hzwhp]);
%      xlabel('Normalized frequency (\times \pi rad/sample)')
%      ylabel('Amplitude')
%      legend('Prototype lowpass','Narrowband highpass',...
%      'Wideband highpass',0)
%      warning(s);
%
%   See also FIRLP2LP, ZEROPHASE, IIRLP2LP, IIRLP2HP, IIRLP2BP, IIRLP2BS.

%   References: 
%     [1] T. Saramaki, Finite impulse response filter design, in 
%          Handbook for Digital Signal Processing. S.K. Mitra and
%          J.F. Kaiser Eds. Wiley-Interscience, N.Y., 1993, Chapter 4.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2004/04/12 23:25:28 $

error(nargchk(1,2,nargin));

if nargin < 2, flag = 'narrow'; end

[N,flag,msg] = checkinputNgetord(b,flag);
error(msg);

switch lower(flag),
case 'narrow',
	% Compute B(-z), 
	b(2:2:end)=-b(2:2:end);
	
    if rem(length(b),2)
        % Multiply by (-1)^(N/2)
        coeffSign = (-1)^(N./2);
        b = coeffSign.*b;
    end	
case 'wide',
	% Implement as a parallel of two FIR filters, -B(z) and z^(-N/2)
    dly = zeros(1,N/2+1);
	dly(N/2+1) = 1; % z^(-N/2)
    
    [dly,b] = eqtflength(dly,b);
    b = dly - b;
	b = removetrailzeros(b);
	
otherwise
	error('Unrecognized string specified.');
end
%---------------------------------------------------------------
function [N,flag,msg] = checkinputNgetord(b,flag)

% Initialize
msg = ''; 
N = length(b) - 1;

% Validate input flag
flagOpts= {'narrow','wide'};
indx = find(strcmpi(flag,flagOpts));
if isempty(indx),
	msg = 'Unrecognized string specified.';
	return
end
flag = flagOpts{indx};

errmsg = 'Filter must be a type I linear phase FIR.';


symstr = signalpolyutils('symmetrytest',b,1);
if strcmp(flag,'wide') && (~strcmpi(symstr,'symmetric') || rem(N,2)),
   msg = errmsg;
   return
end

% [EOF]
