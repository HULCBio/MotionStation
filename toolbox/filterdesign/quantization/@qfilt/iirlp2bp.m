function f = iirlp2bp(h,Wc,Wd)
%IIRLP2BP  IIR lowpass to bandpass transformation.
%   F = IIRLP2BP(H,Wc,Wd) performs a lowpass to bandpass
%   transformation on the filter object H resulting in the
%   transformed filter object F.
%
%   Wc is the frequency value of the point to be transformed (between 0
%   and 1) and Wd is a two element vector with the desired frequency
%   locations of the transformed  points (both between 0 and 1).
%
%   Always verify the result with FREQZ since in some cases numerical
%   problems may arise.
%
%   EXAMPLE: Move the response at .0175 to .4 and .5 in order to
%            generate a bandpass filter from a lowpass filter.
%      [b,a]=iirlpnorm(10,6,[0 .0175 .02 .0215 .025 1],...
%            [0 .0175 .02 .0215 .025 1],[1 1 0 0 0 0],[1 1 1 1 10 10]);
%      Hq = qfilt('df2t',{b,a},'format','double');
%      Hq2 = iirlp2bp(Hq,.0175,[.4,.5]);
%      fvtool(Hq,Hq2);
%
%   See also QFILT/IIRLP2LP, QFILT/IIRLP2HP, QFILT/IIRLP2BS, QFILT/FIRLP2LP,
%            QFILT/FIRLP2HP.

%   References: 
%     [1]  S. K. Mitra, Digital Signal Processing, A Computer
%          Based Approach, McGraw-Hill, N.Y., 1998, Chapter 7.


%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:31:42 $ 

error(nargchk(3,3,nargin));

f = iirxform(h,Wc,Wd,@iirlp2bp);

