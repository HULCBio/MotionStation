function errmsg=freqchk(wp,ws,opt)
%FREQCHK Parameter checking for BUTTORD, CHEB1ORD, CHEB2ORD, ELLIPORD.
%
%   MSG=FREQCHK(WP,WS,OPT) checks for the correct passband (WP) and 
%   stopband (WS) frequency specifications and returns a diagnostic 
%   message (MSG). If the parameters are specified correctly MSG is
%   empty. OPT is a string indicating digital or analog filter design.
%
%   The frequency parameters are checked to be of the same length.
%   For bandpass and bandstop filters, the frequency bands are checked
%   for increasing values and no overlaps.
% 
%   For digital filters, WP and WS are checked to be in (0,1). 
%   For analog filters, WP and WS are checked to be non-negative values.
   
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 01:08:57 $

errmsg='';

% Check for correct lengths
if length(wp)~=length(ws),
   errmsg = 'The frequency vectors must both be the same length.';
   return
end

% Check for allowed interval values 
if strcmp(opt,'z'),
   if any(wp<=0) | any(wp>=1) | any(ws<=0) | any(ws>=1),
      errmsg = 'The cutoff frequencies must be within the interval of (0,1).';
      return    
   end
else % Analog filter design
   if any(wp<=0) | any(ws<=0),
      errmsg = 'The cutoff frequencies must be non-negative for analog filters.';
      return    
   end
end

% For Band specifications
if length(wp)==2,
   % Check for frequencies to be in increasing order
   if (wp(1)>=wp(2)) | (ws(1)>=ws(2)),
      errmsg = 'The cutoff frequencies should be in increasing order.';
      return
   end    
   % Check for passband and stopband frequency overlaps  
   if ~( ((wp(1)<ws(1)) & (wp(2)>ws(2))) | ((wp(1)>ws(1)) & (wp(2)<ws(2))) ),
      errmsg = 'The passband and stopband cutoff frequencies should not overlap.'; 
      return
   end
end

% [EOF] freqchk.m
