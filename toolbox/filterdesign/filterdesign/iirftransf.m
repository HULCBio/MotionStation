function   [outnum, outden] = iirftransf(orignum, origden, ftfnum, ftfden)
%IIRFTRANSF IIR frequency transformation of the digital filter.
%   [OutNum,OutDen] = IIRFTRANSF(OrigNum,OrigDen,FTFNum,FTFDen) returns
%   numerator and denominator vectors, OUTNUM and OUTDEN of the target filter,
%   which is the result of transforming the prototype filter specified by the
%   numerator, ORIGNUM, and denominator, ORIGDEN, with the mapping filter given
%   by the numberator, FTFNUM, and the denominator, FTFDEN.
%
%   Inputs:
%     OrigNum - Numerator of the prototype lowpass filter
%     OrigDen - Denominator of the prototype lowpass filter
%     FTFNum  - Numerator of the mapping filter
%     FTFDen  - Denominator of the mapping filter
%   Outputs:
%     OutNum  - Numerator of the target filter
%     OutDen  - Denominator of the target filter
%
%   Example:
%        [b, a]           = ellip(3, 0.1, 30, 0.409);      % IIR halfband filter
%        [alpnum, alpden] = allpasslp2lp(0.5, 0.25);
%        [num, den]       = iirftransf(b, a, alpnum, alpden);
%        fvtool(b,a,num,den);
%
%   See also ZPKFTRANSF.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:44:50 $

% --------------------------------------------------------------------
% Check the input arguments

error(nargchk(2, 4, nargin));

error(ftransfargchk(orignum, 'Numerator of the original filter',     'vector'));
error(ftransfargchk(origden, 'Denominator of the original filter',   'vector'));

switch nargin,

   case 4,
      error(ftransfargchk(ftfnum,'Numerator of the mapping filter',  'vector'));
      error(ftransfargchk(ftfden,'Denominator of the mapping filter','vector'));

   % FIR case -> denominator defaults to unity
   case 3;
      ftfden = 1;
      error(ftransfargchk(ftfnum,'Numerator of the mapping filter',  'vector'));

   % Transformation filter defaults to constant equal one
   case 2,
      ftfnum = 1;
      ftfden = 1;

end;


% --------------------------------------------------------------------
% Calculate the mapping filter

if (ftfnum ~=1) | (ftfden ~= 1),

   % Make all input vectors rows
   orignum = orignum(:).';
   origden = origden(:).';
   ftfnum  = ftfnum (:).';
   ftfden  = ftfden (:).';

   % Make numerators of original and mapping filters equal to their denominators
   [orignum, origden] = eqtflength(orignum, origden);
   [ftfnum,  ftfden]  = eqtflength(ftfnum,  ftfden );

   % Cancel overlapping poles and zeros in the original filter
   [z,p,k] = pzcancel(roots(orignum), roots(origden), orignum(1)/origden(1), 1e-4);

   % Stabilise the target filter in case it is not after the transformation
   [z,p,k] = pzstable(z, p, k);

   orignum = poly(z) * k;
   origden = poly(p);

   outnum = [];
   outden = [];
   order  = length(orignum);

   % Deal with target filter numerator
   for i=1:order,
      temp   = orignum(i) * conv(nconv(ftfnum,order-i), nconv(ftfden,i-1));
      outnum = [outnum, zeros(1,max(0,length(temp)-length(outnum)))] + temp;
   end;

   % Deal with target filter denominator
   for i=1:order,
      temp   = origden(i) * conv(nconv(ftfnum,order-i), nconv(ftfden,i-1));
      outden = [outden, zeros(1,max(0,length(temp)-length(outden)))] + temp;
   end;

   % Normalise the first element of the denominator to one
   fnd    = find(outden~=0);
   if ~isempty(fnd),
      MagDiv = outden(fnd(1));
      outnum = outnum / MagDiv;
      outden = outden / MagDiv;
   end;

else

   [outnum, outden] = eqtflength(orignum, origden);

end;
