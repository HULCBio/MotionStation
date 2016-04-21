function play(obj, varargin)
%PLAY Plays audio samples in audioplayer object.
%
%    PLAY(OBJ) plays the audio samples from the beginning.
%
%    PLAY(OBJ, START) plays the audio samples from the START sample.
%
%    PLAY(OBJ, [START STOP]) plays the audio samples from the START sample
%    until the STOP sample.
%
%    Use the PLAYBLOCKING method for synchronous playback.
%
%    Example:  Load snippet of Handel's Hallelujah Chorus and play back 
%              only the first three seconds.
%
%       load handel;
%       p = audioplayer(y, Fs); 
%       play(p, [1 (get(p, 'SampleRate') * 3)]);
%
%    See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET, 
%             AUDIOPLAYER/SET, AUDIOPLAYER/PLAYBLOCKING.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:17 $

% Error checking.
if ~isa(obj, 'audioplayer')
     error('MATLAB:audioplayer:noAudioplayerObj', ...
           audioplayererror('MATLAB:audioplayer:noAudioplayerObj'));
end

error(nargchk(1, 2, nargin), 'struct');

play(obj.internalObj, varargin{:});
