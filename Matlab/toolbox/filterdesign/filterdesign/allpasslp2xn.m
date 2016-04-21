function [allpassnum, allpassden] = allpasslp2xn(wo, wt, pass)
%ALLPASSLP2XN Allpass for lowpass to N-point frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSLP2XN(Wo,Wt,Pass) returns numerator,
%   ALLPASSNUM, and the denominator, ALLPASSDEN, of the allpass mapping filter.
%
%   Inputs:
%     Wo         - Frequency values to be transformed from the prototype filter
%     Wt         - Desired frequency locations in the transformed target filter
%     Pass       - 'pass'/'stop' for DC/Nyquist mobility
%                  The default value is 'pass'.
%   Outputs:
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Frequencies must be normalized to be between 0 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        % Allpass mapper moving three independent features Wo of the original real
%        % lowpass filter to arbitrary positive frequencies Wt of the target filter
%        Wo = [0.2, 0.3, 0.5];
%        Wt = [0.3, 0.5, 0.8];
%        [AllpassNum, AllpassDen] = allpasslp2xn(Wo,Wt);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, angle(h)/pi, Wt, Wo, 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRLP2XN and ZPKLP2XN.

%   References:
%     [1]  Gerry D. Cain, Artur Krukowski, Izzet Kale, "High Order
%          Transformations for Flexible IIR Filter Design", VII European
%          Signal Processing Conference (EUSIPCO'94), Vol. 3, pp. 1582-1585,
%          Edinburgh, United Kingdom, 13-16 September 1994.
%     [2]  Artur Krukowski, Gerald D. Cain, Izzet Kale, "Custom designed
%          high-order frequency transformations for IIR filters", 38th Midwest
%          Symposium on Circuits and Systems (MWSCAS'95), Rio de Janeiro,
%          Brazil, 13-16 August 1995.

%   Author(s): Dr. Artur Krukowski (consultants: Prof. I. Kale and Prof. G.D. Cain) University of Westminster.
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2004/04/12 23:25:18 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,3,nargin));

error(ftransfargchk(wo,                'Frequency value from the prototype filter', ...
                                       'vector', 'real', 'full normalized'));
error(ftransfargchk(wt,                'Desired frequency location in the target filter', ...
                                       'vector', 'real', 'full normalized'));
error(ftransfargchk([wo(:).';wt(:).'], 'Prototype and target frequencies', 'overlap'));

if nargin == 3,
   error(ftransfargchk(pass,           'Parameter Pass', 'string', 'pass/stop'));
   switch(lower(pass)),
      case 'stop', passval = 1;
      case 'pass', passval = -1;
   end;
else
    passval = -1;
end;

% ---------------------------------------------------------------------
% Calculate the mapping filter
Forder     = length(wo);

% Create matix of equations and a vector of equation results
zo    = exp( i * pi * wo);
zn    = exp(-i * pi * wt);

   for k=1:Forder
      a(k,:) = zo(k) * (zn(k).^(Forder-1:-1:0)) - passval*(zn(k).^(1:Forder));
   end;

   % Calculate output variables
   b          = passval - zo.' .* (zn.' .^ Forder);
   allpassnum = real([1; a\b]);

   % Detecting the case of several points mapped to their own vicinity
   InfTaps = find(isnan(allpassnum));
   if ~isempty(InfTaps),
       % Using least square solution when a is singular
       opts.RECT = true;                                                           
       allpassnum = real([1; linsolve(a,b,opts)]);
   end;

   allpassden = fliplr(allpassnum(:).');
   allpassnum = passval*allpassnum(:).';
   
   % Detect zeros outside (poles inside) the unit circle - compromising the target filter stability
   if signalpolyutils('isstable',allpassden),
      % Make the filter unstable
      allpassnum = fliplr(allpassnum);
      allpassden = fliplr(allpassden);
   end

   % Cancel overlapping pole-zero pairs
   [z, p, k] = pzcancel(roots(allpassnum), roots(allpassden), freqz(allpassnum,allpassden,1), 1e-10);

   % Detect the case when all poles and zeros were cancelled
   if isempty(z), z=0; end;

   % Re-create the transfer function if anything was cancelled
   if length(z)~=Forder,
      allpassnum =         poly(z);
      allpassden = k    .* poly(p);
      s          = sign(allpassden(end));
      allpassnum = allpassnum ./ s;
      allpassden = allpassden ./ allpassden(end);

      % Take care of the roots in infinity
      [allpassnum,allpassden] = eqtflength(fliplr(allpassnum), fliplr(allpassden));
      allpassnum = fliplr(allpassnum);
      allpassden = fliplr(allpassden);
   end;
