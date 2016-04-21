function [HH,W,Pnn,Nf,units] = nlm(Hq,N,L,whole,Fs)
%NLM   Noise Loading Method estimate of frequency response.
%   [H,W,Pnn,Nf] = NLM(Hq,N,L) returns an estimate of the complex frequency
%   response H, the frequency vector W in radians/sample, the noise power
%   spectrum Pnn, and the noise figure Nf for the quantized filter Hq at N
%   equally spaced points around the upper half of the unit circle using the
%   Noise Loading Method.  The method averages over L Monte Carlo trials.  If N
%   or L are missing or empty, the defaults are N=512, L=10.
%
%   [H,W,Pnn,Nf] = NLM(Hq,N,L,'whole') uses N points around the whole unit
%   circle.
%
%   [H,F,...] = NLM(Hq,N,L,Fs) and [H,F,...] = NLM(Hq,N,L,'whole',Fs) return
%   frequency vector F (in Hz), where Fs is the sampling frequency (in Hz).
% 
%   NLM(Hq,...) with no output arguments plots the magnitude and unwrapped phase
%   of H with comparisons to the analytical frequency response from FREQZ in the
%   current figure window.
%
%   Example:
%     [b,a] = butter(6,.5);
%     Hq = qfilt('df2t',{b,a});
%     nlm(Hq,1024,20)
%
%   See also QFILT, QFILT/FILTER, QFILT/FREQZ.

%   Reference: 
%   James H. McClellan, C. Sidney Burrus, Alan V. Oppenheim, Thomas W. Parks,
%   Ronald W. Schafer, and Hans W. Schuessler, Computer-Based Exercises for
%   Signal Processing Using MATLAB 5, Prentice-Hall, Upper Saddle River, New
%   Jersey, 1998.

%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/14 15:30:13 $

error(nargchk(1,5,nargin));
if nargin<5, Fs=[]; end
if nargin<4, whole=''; Fs=[]; end
if nargin<3, L=[]; end
if nargin<2, N=[]; end
if nargin==4
  % nlm(Hq,N,L,'whole') or nlm(Hq,N,L,Fs)
  if ischar(whole)
    [whole,errmsg]=qpropertymatch(whole,{'whole'});
    error(errmsg);
  elseif isnumeric(whole)
    Fs=whole;
    whole='';
  else
    error('Third argument must be ''whole'' or Fs.')
  end
end
if isempty(N), N=512; end
if isempty(L), L=10; end

if isempty(whole)
  M = 2*N;
else
  M = N;
end

if nargout==0, 
  wbar = waitbar(0,sprintf(['Noise Loading Method calculating.\n',...
      'Close this window to terminate early.']));
  drawnow
end

wrn = warning('off');
sumH = zeros(M,1); % H(k) accumulation
sumY2 = sumH;      % |Y(k)|^2 accumulation
for k = 1:L;
  phi = 2*pi*rand(M/2-1,1);           % Generation of the periodic
  phi = [0; phi; 0; -phi(end:-1:1)];  % input signal.
  Vp = exp(i*phi);
  vp = real(ifft(Vp));
  v = [vp; vp];
  y = filter(Hq,v);      % Applying v to the system under test
  y = y(M+1:2*M);        % Selecting and transforming the last period
  Yp = fft(y);
  sumH = sumH + Yp./Vp;    % Accumulation
  sumY2 = sumY2 + real(Yp.*conj(Yp));
  if nargout==0 
    if ~ishandle(wbar)
      % Closing the wait bar is a way of terminating early
      break
    end
    waitbar(k/L,wbar);
  end
end
H = sumH/L; % Postprocessing
Pnn = ((sumY2/(L-1)) - real(H.*conj(H))*L/(L-1))/M;
Pnn = abs(Pnn);
Q = eps(get(Hq,'outputformat'));
% The noise variance for roundmode fix is eps^2/3.  For all other roundmodes,
% the noise variance is eps^2/12.
if strcmpi(Hq.sumformat.roundmode,'fix')
  d = 3;
else
  d = 12;
end
Nf = mean(Pnn)/(Q*Q/d);
H = H(1:N);
Pnn = Pnn(1:N);

if isempty(Fs)
  if isempty(whole)
    [Hquantfreqz,W,units,Hreffreqz] = freqz(Hq,N);
  else
    [Hquantfreqz,W,units,Hreffreqz] = freqz(Hq,N,'whole');
  end
else
  if isempty(whole)
    [Hquantfreqz,W,units,Hreffreqz] = freqz(Hq,N,Fs);
  else
    [Hquantfreqz,W,units,Hreffreqz] = freqz(Hq,N,'whole',Fs);
  end
end
if nargout == 0
  if ishandle(wbar), close(wbar); end
  freqzplot([H(2:N) Hquantfreqz(2:end) Hreffreqz(2:end) sqrt(Pnn(2:N))],...
      W(2:end),units); 
  hax1 = subplot(211);
  legend(hax1,'Quantized NLM','Quantized FREQZ','Reference FREQZ',...
      'Noise Power Spectrum',0);
  set(get(hax1,'title'),'string',...
      ['Noise Loading Method.  Noise figure = ',...
        num2str(10*log10(Nf)),' dB']);
  hax2 = subplot(212);
  pmzoom([hax1;hax2])
  zoom off
else
  HH = H;
end
warning(wrn)

