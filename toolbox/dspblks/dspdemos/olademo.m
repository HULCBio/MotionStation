% Initialization script for Speech Enhancement for the Hearing Impaired
% SIMULINK Signal Processing Blockset Demonstration
%

%	9/8/94
%	Copyright 1995-2003 The MathWorks, Inc.
%	$Revision: 1.9.4.2 $  $Date: 2004/04/12 23:05:38 $

    N = 256;    % fft and block size
    
    Fs = 8192;   % sampling frequency in Hz

% thresholds in dB SPL (Sound Pressure Level)
    %f =  [ 50 100 200 400 800 1600 3000 3300];
    %lt = [  0   0  10  10  20   20   20    0];   % lower threshold
    %ut = [100 100 100 100 100  100  100  100];   % upper threshold

    f =  [ 100  4000];
    lt = [   0   30 ];   % lower threshold
    ut = [ 100  100 ];   % upper threshold

%  extrapolate first point down to zero frequency:
    f = [0 f];
    lt = [lt(1) lt];
    ut = [ut(1) ut];
    
% reflect above Fs/2
    lt = [lt fliplr(lt)];
    ut = [ut fliplr(ut)];
    f  = [f  Fs-fliplr(f)];

% create linearly spaced (FFT) grid
    fgrid = (0:N-1)/N*Fs;
    ymin = interp1(f,lt,fgrid,'linear');
    ymax = interp1(f,ut,fgrid,'linear');

   % plot(fgrid,[ymin(:) ymax(:)])
   % hold on
   % plot(f,[lt(:) ut(:)],'o')    

% NOTE about Overlap-Add spectral modification:
% for a window w of length 256 and overlap of 192, the
% constant of modification is roughly
%   mean(sum(reshape(w( (1:64)'*[1 1 1 1] + ones(64,1)*[0 1 2 3]*64 ),64,4)'))
