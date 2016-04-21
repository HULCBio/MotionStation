function f = iirlp2hp(h,Wc,Wd)
%IIRLP2HP  IIR lowpass to highpass transformation.
%   F = IIRLP2HP(H,Wc,Wd) performs a lowpass to highpass
%   transformation on the filter object H resulting in the
%   transformed filter object F.
%
%   Wc is the frequency value of the point to be transformed (between 0
%   and 1) and Wd is the desired frequency location of the transformed
%   point (also between 0 and 1).
%
%   Always verify the result with FREQZ since in some cases numerical
%   problems may arise.
%
%   EXAMPLE: Move the response at .0175 to .4 and convert lowpass
%            filter to a highpass filter.
%      [b,a]=iirlpnorm(10,6,[0 .0175 .02 .0215 .025 1],...
%            [0 .0175 .02 .0215 .025 1],[1 1 0 0 0 0],[1 1 1 1 10 10]);
%      Hq = qfilt('df2t',{b,a},'format','double');
%      Hq2 = iirlp2hp(Hq,.0175,.4);
%      fvtool(Hq,Hq2);
%
%   See also QFILT/IIRLP2LP, QFILT/IIRLP2BP, QFILT/IIRLP2BS, QFILT/FIRLP2LP,
%            QFILT/FIRLP2HP.

%   References: 
%     [1]  S. K. Mitra, Digital Signal Processing, A Computer
%          Based Approach, McGraw-Hill, N.Y., 1998, Chapter 7.


%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:31:39 $ 

error(nargchk(3,3,nargin));

f = iirxform(h,Wc,Wd,@iirlp2hp);

