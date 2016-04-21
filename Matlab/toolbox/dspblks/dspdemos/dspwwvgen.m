function [y,Ts] = dspwwvgen(x)
% GEN_WWV_VEC Generate test vector for WWV simulator.
%   [y,Ts]=gen_wwv_vec(x) generates IRIG-H audio or symbol data.
%
% Symbols mode:
% -------------
% Fills test vector with decoder symbols:
%   PMISS   (0)
%   P0      (1)
%   P1      (2)
%   PMARK   (3)
%
% Audio mode:
% -----------
% Fills test vector with samples of 100Hz sinusoid, sampled
% at 8 kHz and amplitude modulated by IRIG-H symbol widths.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin<1,
	% Define test data:
   % -----------------
  x.mode    = 'symbols';
  %x.mode    = 'audio';
	x.utc     = 15.45;   % hh.mm
	x.ut1     = -0.1;    % seconds in range [-0.7, +0.7]
	x.day     = 173;     % day of year
	x.yr      = 1997;    % year
	x.dst     = 0;       % Daylight Savings Time indicator
	x.dst2    = 0;       % DST onset indicator
  x.leap    = 1;       % Leap second
end

% Generate symbol vector:
y  = gen_irig(x);
Ts = 1;

% Add a couple of symbols to the frame of data, so that
% the decoder has time to synchronize:
y = [ones(5,1) ; y];

% Generate audio signal if desired:
if strcmp(lower(x.mode),'audio'),
   Ts = 1/8000;
   y = gen_audio(y,Ts);
end

return


% =======================

function s = gen_audio(x,Ts)
% Construct audio signal:

% Define symbols and amplitude modulations:
nPER  = ceil(1.00/Ts);
nMISS = ceil(0.00/Ts);
n0    = ceil(0.17/Ts);
n1    = ceil(0.47/Ts);
nMARK = ceil(0.77/Ts);

PMISS=0; amiss = zeros(1,nPER);
P0   =1; a0    = [ones(1,n0)    zeros(1,nPER-n0)   ];
P1   =2; a1    = [ones(1,n1)    zeros(1,nPER-n1)   ];
PMARK=3; amark = [ones(1,nMARK) zeros(1,nPER-nMARK)];

% Create (1/Ts) Hz sampled 100Hz PWM audio signal:
t = 0:Ts:length(x);
s = cos(2*pi*100*t);
for i = 1:length(x),
   switch x(i)
   case PMISS,  a = amiss;
   case P0,     a = a0;
   case P1,     a = a1;
   case PMARK,  a = amark;
   end
   
   i1 = (i-1)*nPER + 1;
   i2 = i1 + (nPER-1);
   s(i1:i2)= a .* s(i1:i2);
end

% Modulate signal envelope and add noise:
%s = s .* (sin(2*pi*0.04.*t)*0.1+0.8) + randn(size(s))*0.25;
%s = s/2;

% Signal drop out:
% s1=15*8000; s2=18*8000; s(s1:s2)=0;

return


% =======================

function y = gen_irig(x)

PMISS = 0;
P0    = 1;
P1    = 2;
PMARK = 3;

% Preload with all P0's:
% ----------------------
y = P0*ones(60,1);

% 10-sec markers:
% ---------------
y(1:10:end) = PMARK;

% Start-of-frame marker:
% ----------------------
y(2) = PMISS;

% Data:
% -----
y(4)  = bit(x.dst2); % DST #2
y(57) = bit(x.dst);  % DST #1

y(5) = bit(x.leap);

ybcd = bcd(x.yr-1900,2);
y(6:9) = ybcd(1:4);
y(53:56) = ybcd(5:8);


hh = floor(x.utc);
mm = round((x.utc-hh)*100);
ybcd = bcd(mm,2);
y(12:15) = ybcd(1:4);
y(17:20) = ybcd(5:8);
ybcd = bcd(hh,2);
y(22:25) = ybcd(1:4);
y(27:30) = ybcd(5:8);

ybcd = bcd(x.day,3);
y(32:35) = ybcd(1:4);
y(37:40) = ybcd(5:8);
y(42:45) = ybcd(9:12);

y(52) = bit(sign(x.ut1)==-1);

ybcd = bcd(abs(x.ut1*10),1);
y(58:60) = ybcd(1:3);
return

% =======================

function y=bcd(d,n)
P0 = 1;
P1 = 2;
s=dec2bcd(d,n);
y=P0*ones(1,length(s)); % Set P0's
y(find(s=='1'))=P1;    % Set P1's
y=fliplr(y);
return

% =======================

function y=bit(x)
P0    = 1;
P1    = 2;
if x, y=P1; else y=P0; end
return

% =======================

function y=dec2bcd(d,n)
%DEC2BCD Convert decimal integer to a binary-coded-decimal (BCD) string.
%   DEC2BCD(D) returns the BCD representation of D as a string.
%   D must be a non-negative integer.
%
%   DEC2BCD(D,N) produces a BCD representation with at least
%   N decimal digits encoded.
%
%   Example
%      dec2bcd(23) returns '00100011'
%      dec2bcd(23,3) returns '000000100011'
%
%   See also DEC2BIN, BIN2DEC, DEC2HEX, DEC2BASE.

error(nargchk(1,2,nargin));

d = abs(d(:)); % Make sure d is a column vector.

if d<2, numdigits=1;
else    numdigits=ceil(log10(d));
end

if nargin>1,
	if prod(size(n))~=1 | numdigits<0,
	   error('N must be a positive scalar.');
    end
	n = round(n); % Make sure n is an integer.
else
  n = numdigits;
end

digits = zeros(1,numdigits);
for i=numdigits-1:-1:0
  dig = floor(d*10^(-i));
  d = d - dig*(10^i);
  digits(numdigits-i)=dig;
end

if n==0; digits=[];
elseif n>numdigits, digits=[zeros(1,n-numdigits) digits];
else digits=digits(end+1-n:end);
end

y=[];
for i=1:length(digits),
  y=[y dec2bin(digits(i),4)];
end

% =======================

