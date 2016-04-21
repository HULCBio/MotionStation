function f = iirlp2bs(h,Wc,Wd)
%IIRLP2BS  IIR lowpass to bandtop transformation.
%   F = IIRLP2BS(H,Wc,Wd) performs a lowpass to bandstop
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
%   EXAMPLE: Move the response at .4 to .5 and .7 in order to
%            generate a bandstop filter from a lowpass filter.
%      [b,a]=ellip(10,1,60,.4);
%      Hq = qfilt('df2t',{b,a},'format','double');
%      Hq2 = iirlp2bs(Hq,.4,[.5,.7]);
%      fvtool(Hq,Hq2);
%
%   See also QFILT/IIRLP2LP, QFILT/IIRLP2HP, QFILT/IIRLP2BP, QFILT/FIRLP2LP,
%            QFILT/FIRLP2HP.

%   References: 
%     [1]  S. K. Mitra, Digital Signal Processing, A Computer
%          Based Approach, McGraw-Hill, N.Y., 1998, Chapter 7.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:31:45 $ 

error(nargchk(3,3,nargin));

f = iirxform(h,Wc,Wd,@iirlp2bs);

