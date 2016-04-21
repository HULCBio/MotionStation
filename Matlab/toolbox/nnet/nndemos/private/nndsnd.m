function ss = nndsnd(i)
%NNDSND Neural Network Design utility function.

%  NNDSND(i)
%    i - index between 1 and 9.
%  Plays sound number i.
%
%  S = NNDSND(i)
%    i - index between 1 and 9.
%  Returns sound vector i, to be played at 8192Hz.
%
%  EXAMPLE: nndsnd(1)
%          s = nndsnd(8);
%          sound(s,8192)

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================

Fs = 8192;

% NO SOUND FOR STUDENT EDITION
if nnstuded
  s = [];

% BUZZ SOUND
elseif (i==1)
  time = [0:(1/Fs):0.01];
  w = time*2*pi;
  s = [sin(w *500).^2 .* sin(w* 800) .^ 1];
  s = [s,0,s,0,s,0,s,0,s,0,s,0,s];
  s = [s s s s*0 s s s s*0 s s s s];

% MACHINE SOUND
elseif (i==2)
  time = [0:(1/Fs):1];
  w = time*2*pi;
  s = [sin(w * 700).^2 .* sin(w* 600) .^ 3 + rand(1,length(w))];

% WIND SOUND
elseif (i==3)
  time = [0:(1/Fs):1];
  w = time*2*pi;

  steps = length(time);
  end_steps = fix(steps/8);
  mid_steps = steps-2*end_steps;
  end_gain = [0:(1/(end_steps-1)):1];
  gain = [end_gain, ones(1,mid_steps), fliplr(end_gain)];

  s = gain.*rand(1,length(w)).^0.1;

% WHIR SOUND
elseif (i==4)
  time = [0:(1/Fs):0.4];
  w = time*2*pi;
  s1 = 0;
  for i=1:1:10,
    s1 = s1 + sin(w * (700 + i*83));
  end
  time = [0:(1/Fs):0.2];
  w = time*2*pi;
  s2 = 0;
  for i=1:2:10,
    s2 = s2 + sin(w * (1200 + i*83));
  end
  time = [0:(1/Fs):0.2];
  w = time*2*pi;
  s3 = 0;
  for i=1:2:10,
    s3 = s3 + sin(w * (500 + i*83));
  end
  time = [0:(1/Fs):0.7];
  w = time*2*pi;
  s4 = 0;
  for i=1:1:6,
    s4 = s4 + sin(w * (600 + i*83));
  end
  s = [s1 s2 s3 s2 s4];

% KNOCK SOUND
elseif (i==5)
  time = [0:(1/Fs):0.004];
  w = time*2*pi;
  s = [sin(w * 550) sin(w * 400) sin(w * 200) sin(w * 100)]*0.5;

% BLIP SOUND
elseif (i==6)
  time = [0:(1/Fs):(0.004)];
  w = time*2*pi;
  s = [sin(w * 700)];

% BLOOP SOUND
elseif (i==7)
  time = [0:(1/Fs):0.004];
  w = time*2*pi;
  s = [sin(w * 500)];

% EXTENDED CLICK SOUND
elseif (i==8)
  time = [0:(1/Fs):0.004];
  w = time*2*pi;
  s = [sin(w * 700)];
  s = [s zeros(1,length(s)*10)];
  s = [s s s s s s s s];

% BLP
elseif (i==9)
  time = [0:(1/Fs):0.015];
  w = time*2*pi;

  steps = length(time);
  end_steps = fix(steps/2);
  mid_steps = steps-2*end_steps;
  end_gain = [0:(1/(end_steps-1)):1];
  gain = [end_gain, ones(1,mid_steps), fliplr(end_gain)];

  s = [sin(w * 200) .* sqrt(gain)];

% BEEP SOUND
elseif (i==10)
  time = [0:(1/Fs):0.2];
  w = time*2*pi;
  s = [sin(w * 400) + rand(1,length(w))*0.1];

end  

% PAD EDGES TO AVOID "CLICKS"
if ~nnstuded
  s = [zeros(1,40) s zeros(1,40)];
end

% RETURN SOUND
if nargout
  ss = s;
else
  nnsound(s,Fs)
end


