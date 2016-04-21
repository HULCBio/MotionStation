function playsnd(y,fs,bits)
%PLAYSND Implementation for SOUND
%   PLAYSND(Y,FS,BITS)

%   IF a MEX file version exists, it is called; otherwise, this file is
%   used when a MEX file is not available for the platform.  Sound is
%   simply written to /dev/audio, either on the local machine, or on
%   the remote machine specified by the environment variable DISPLAY.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:58 $

% Is audio device local or remote?
if isunix,
  [s,hostname] = unix('hostname');
  if isempty(hostname), % Be extra robust
    hostname = unix('uname -n');
  end
  machinename = hostname(1:end-1);
else
  machinename = getenv('HOST');
end
dspname = getenv('DISPLAY');
if ~isempty(dspname), dspname  = dspname(1:find(dspname == ':')-1); end

if isempty(dspname) | isempty(machinename) | ...
  strcmp(dspname,machinename) | strcmp(lower(dspname),'unix');
  % Audio device is (probably) on this machine.
  fp = fopen('/dev/audio','wb');
  if fp == -1
    disp('Audio capabilities are not available on this machine.')
    return;
  end
  fwrite(fp,lin2mu(y),'uchar');
  fclose(fp);
else
  % Audio device is on a remote machine.
  % Write to a temporary file, then use a shell escape
  % to send the file to the remote /dev/audio.
  t = clock;
  tmpfile = ['/tmp/au' sprintf('%02.0f%02.0f%02.0f', t(4:6))];
  fp = fopen(tmpfile,'wb');
  if fp==-1,
    error(['Cannot open ' tmpfile ' with write privilege.'])
  end
  fwrite(fp,lin2mu(y),'uchar');
  fclose(fp);

  cp = computer;
  rsh = 'rsh ';
  if cp(1)=='H', rsh = 'remsh '; end
  eval(['!cat ' tmpfile ' | ' rsh dspname ' ''cat > /dev/audio'' ']);
  delete(tmpfile);
end
