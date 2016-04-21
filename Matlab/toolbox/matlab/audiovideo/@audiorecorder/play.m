function player = play(obj, varargin)
%PLAY Plays recorded audio samples in audiorecorder object.
%
%    P = PLAY(OBJ) plays the recorded audio samples at the beginning and
%    returns an audioplayer object.
%
%    P = PLAY(OBJ, START) plays the audio samples from the START sample and
%    returns an audioplayer object.
%
%    P = PLAY(OBJ, [START STOP]) plays the audio samples from the START
%    sample until the STOP sample and returns an audioplayer object.
%
%    See also AUDIORECORDER, AUDIODEVINFO, METHODS, AUDIORECORDER/GET, 
%             AUDIORECORDER/SET, AUDIORECORDER/RECORD.

%    JCS
%    Copyright 2003-2004 The MathWorks, Inc. 
%    $Revision $  $Date: 2004/04/16 22:04:37 $

% Error checking.
if ~isa(obj, 'audiorecorder')
     error('MATLAB:audiorecorder:noAudiorecorderObj', ...
           audiorecordererror('MATLAB:audiorecorder:noAudiorecorderObj'));
end

error(nargchk(1, 2, nargin), 'struct');

player = play(obj.internalObj, varargin{:});
