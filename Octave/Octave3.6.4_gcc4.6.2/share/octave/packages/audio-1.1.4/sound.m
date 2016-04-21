## Copyright (C) 1999-2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## usage: sound(x [, fs, bs])
##
## Play the signal through the speakers.  Data is a matrix with
## one column per channel.  Rate fs defaults to 8000 Hz.  The signal
## is clipped to [-1, 1].  Buffer size bs controls how many audio samples 
## are clipped and buffered before sending them to the audio player.  bs 
## defaults to fs, which is equivalent to 1 second of audio.  
##
## Note that if $DISPLAY != $HOSTNAME:n then a remote shell is opened
## to the host specified in $HOSTNAME to play the audio.  See manual
## pages for ssh, ssh-keygen, ssh-agent and ssh-add to learn how to 
## set it up.
##
## This function writes the audio data through a pipe to the program
## "play" from the sox distribution.  sox runs pretty much anywhere,
## but it only has audio drivers for OSS (primarily linux and freebsd)
## and SunOS.  In case your local machine is not one of these, write
## a shell script such as ~/bin/octaveplay, substituting AUDIO_UTILITY
## with whatever audio utility you happen to have on your system:
##   #!/bin/sh
##   cat > ~/.octave_play.au
##   SYSTEM_AUDIO_UTILITY ~/.octave_play.au
##   rm -f ~/.octave_play.au
## and set the global variable (e.g., in .octaverc)
##   global sound_play_utility="~/bin/octaveplay";
##
## If your audio utility can accept an AU file via a pipe, then you
## can use it directly:
##   global sound_play_utility="SYSTEM_AUDIO_UTILITY flags"
## where flags are whatever you need to tell it that it is receiving
## an AU file.
##
## With clever use of the command dd, you can chop out the header and
## dump the data directly to the audio device in big-endian format:
##   global sound_play_utility="dd of=/dev/audio ibs=2 skip=12"
## or little-endian format:
##   global sound_play_utility="dd of=/dev/dsp ibs=2 skip=12 conv=swab"
## but you lose the sampling rate in the process.  
##
## Finally, you could modify sound.m to produce data in a format that 
## you can dump directly to your audio device and use "cat >/dev/audio" 
## as your sound_play_utility.  Things you may want to do are resample
## so that the rate is appropriate for your machine and convert the data
## to mulaw and output as bytes.
## 
## If you experience buffer underruns while playing audio data, the bs
## buffer size parameter can be increased to tradeoff interactivity
## for smoother playback.  If bs=Inf, then all the data is clipped and 
## buffered before sending it to the audio player pipe.  By default, 1 
## sec of audio is buffered.

function sound(data, rate, buffer_size)

  if nargin<1 || nargin>3
    usage("sound(x [, fs, bs])");
  endif
  if nargin<2 || isempty(rate), rate = 8000; endif
  if nargin<3 || isempty(buffer_size), buffer_size = rate; endif
  if rows(data) != length(data), data=data'; endif
  [samples, channels] = size(data);

  ## Check if the octave engine is running locally by seeing if the
  ## DISPLAY environment variable is empty or if it is the same as the 
  ## host name of the machine running octave.  The host name is
  ## taken from the HOSTNAME environment variable if it is available,
  ## otherwise it is taken from the "uname -n" command.
  display=getenv("DISPLAY");
  colon = rindex(display,":");
  if isempty(display) || colon==1
    islocal = 1;
  else
    if colon, display = display(1:colon-1); endif
    host=getenv("HOSTNAME");
    if isempty(host), 
      [status, host] = system("uname -n");
      ## trim newline from end of hostname
      if !isempty(host), host = host(1:length(host)-1); endif
    endif
    islocal = strcmp(tolower(host),tolower(display));
  endif

  ## What do we use for playing?
  global sound_play_utility;
  if ~isempty(sound_play_utility),
    ## User specified command
  elseif  (file_in_path(EXEC_PATH, "ofsndplay"))
    ## Mac
    sound_play_utility = "ofsndplay -"
  elseif (file_in_path(EXEC_PATH, "play"))
    ## Linux (sox)
    sound_play_utility = "play -t AU -";
  else
    error("sound.m: No command line utility found for sound playing");
  endif

  ## If not running locally, then must use ssh to execute play command
  if islocal
    fid=popen(sound_play_utility, "w");
  else
    fid=popen(["ssh ", host, " ", sound_play_utility], "w");
  end
  if fid < 0,
    warning("sound could not open play process");
  else
    ## write sun .au format header to the pipe
    fwrite(fid, toascii(".snd"), 'char');
    fwrite(fid, 24, 'int32', 0, 'ieee-be');
    fwrite(fid, -1, 'int32', 0, 'ieee-be');
    fwrite(fid, 3, 'int32', 0, 'ieee-be');
    fwrite(fid, rate, 'int32', 0, 'ieee-be');
    fwrite(fid, channels, 'int32', 0, 'ieee-be');

    if isinf(buffer_size),
      fwrite(fid, 32767*clip(data,[-1, 1])', 'int16', 0, 'ieee-be');
    else
      ## write data in blocks rather than all at once
      nblocks = ceil(samples/buffer_size);
      block_start = 1;
      for i=1:nblocks,
        block_end = min(size(data,1), block_start+buffer_size-1);
        fwrite(fid, 32767*clip(data(block_start:block_end,:),[-1, 1])', 'int16', 0, 'ieee-be');
        block_start = block_end + 1;
      end
    endif
    pclose(fid);
  endif
end

###### auplay based version: not needed if using sox
##  ## If not running locally, then must use ssh to execute play command
##  global sound_play_utility="~/bin/auplay"
##  if islocal
##    fid=popen(sound_play_utility, "w");
##  else
##    fid=popen(["ssh ", host, " ", sound_play_utility], "w");
##  end
##  fwrite(fid, rate, 'int32');
##  fwrite(fid, channels, 'int32');
##  fwrite(fid, 32767*clip(data,[-1, 1])', 'int16');
##  pclose(fid);

%!demo
%! [x, fs] = auload(file_in_loadpath("sample.wav"));
%! sound(x,fs);
