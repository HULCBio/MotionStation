function playblocking(obj, varargin)
%PLAYBLOCKING Synchronous playback of audio samples in audioplayer object.
%
%    PLAYBLOCKING(OBJ) plays from beginning; does not return until 
%                      playback completes.
%
%    PLAYBLOCKING(OBJ, START) plays from START sample; does not return until
%                      playback completes.
%
%    PLAYBLOCKING(OBJ, [START STOP]) plays from START sample until STOP sample;
%                      does not return until playback completes.
%
%    Use the PLAY method for asynchronous playback.
%
%    See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET, 
%             AUDIOPLAYER/SET, AUDIOPLAYER/PLAY.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:18 $

% Error checking.
if ~isa(obj, 'audioplayer')
     error('MATLAB:audioplayer:noAudioplayerObj', ...
           audioplayererror('MATLAB:audioplayer:noAudioplayerObj'));
end

error(nargchk(1, 2, nargin), 'struct');

playblocking(obj.internalObj, varargin{:});
