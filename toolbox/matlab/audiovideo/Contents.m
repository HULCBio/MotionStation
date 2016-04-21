% Audio and Video support.
%
% Audio input/output objects.
%   audioplayer   - Audio player object.
%   audiorecorder - Audio recorder object.
%
% Audio hardware drivers.
%   sound         - Play vector as sound.
%   soundsc       - Autoscale and play vector as sound.
%   wavplay       - Play sound using Windows audio output device.
%   wavrecord     - Record sound using Windows audio input device.
%
% Audio file import and export.
%   aufinfo       - Return information about AU file.
%   auread        - Read NeXT/SUN (".au") sound file.
%   auwrite       - Write NeXT/SUN (".au") sound file.
%   wavfinfo      - Return information about WAV file.
%   wavread       - Read Microsoft WAVE (".wav") sound file.
%   wavwrite      - Write Microsoft WAVE (".wav") sound file.
%
% Video file import/export.
%   aviread       - Read movie (AVI) file.
%   aviinfo       - Return information about AVI file.
%   avifile       - Create a new AVI file.
%   movie2avi     - Create AVI movie from MATLAB movie.
%
% Utilities.
%   lin2mu        - Convert linear signal to mu-law encoding.
%   mu2lin        - Convert mu-law encoding to linear signal.
%
% Example audio data (MAT files).
%   chirp         - Frequency sweeps          (1.6 sec, 8192 Hz)
%   gong          - Gong                      (5.1 sec, 8192 Hz)
%   handel        - Hallelujah chorus         (8.9 sec, 8192 Hz)
%   laughter      - Laughter from a crowd     (6.4 sec, 8192 Hz)
%   splat         - Chirp followed by a splat (1.2 sec, 8192 Hz)
%   train         - Train whistle             (1.5 sec, 8192 Hz)
%
% See also IMAGESCI, IOFUN.

% Obsolete functions.
%   saxis         - Sound axis scaling.
% 
% Utilities.
%   playsnd       - Implementation for SOUND.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:03:36 $
