function sound(y,fs,bits)
%SOUND Play vector as sound.
%   SOUND(Y,FS) sends the signal in vector Y (with sample frequency
%   FS) out to the speaker on platforms that support sound. Values in
%   Y are assumed to be in the range -1.0 <= y <= 1.0. Values outside
%   that range are clipped.  Stereo sounds are played, on platforms
%   that support it, when Y is an N-by-2 matrix.
%
%   SOUND(Y) plays the sound at the default sample rate of 8192 Hz.
%
%   SOUND(Y,FS,BITS) plays the sound using BITS bits/sample if
%   possible.  Most platforms support BITS=8 or 16.
%
%   Example:
%     load handel
%     sound(y,Fs)
%   You should hear a snippet of Handel's Hallelujah Chorus.
%
%   See also SOUNDSC, WAVPLAY.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:47 $

if nargin<1, error('Not enough input arguments.'); end
if nargin<2, fs = 8192; end
if nargin<3, bits = 16; end

% Make sure y is in the range +/- 1
y = max(-1,min(y,1));

% Make sure that there's one column
% per channel.
if ndims(y)>2, error('Requires 2-D values only.'); end
if size(y,1)==1, y = y.'; end

playsnd(y,fs,bits);
