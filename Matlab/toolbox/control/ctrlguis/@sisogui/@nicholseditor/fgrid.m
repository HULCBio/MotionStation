function varargout = fgrid(Editor, Models)
%FGRID  Derives adequate frequency range and grid for Nichols plot.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/08/20 14:07:24 $

% Sample time
Ts = Editor.LoopData.getTs;

% Determine Preferred frequency range [Wmin, Wmax]
W = fgrid('nichols', [], [], [], [], Models{:});
for ct = 1:length(W)
  W{ct} = W{ct}{1}(:);
end
Wmin = W{1}(1);
Wmax = W{1}(end);

% Determine frequency grid W that allows for plot expansion
% when moving poles/zeros 
if Ts
  % Discrete time: Adjust upper limit based on Nyquist freq.
  NyqFreq = pi / abs(Ts); % Nyquist frequency
  if Wmax < 0.99*NyqFreq
    % Push upper limit beyond Nyquist freq
    nfdec = 10^floor(log10(NyqFreq));    % corresponding decade
    nftick = round(NyqFreq / nfdec);
    Wmax = max(nftick + 1, (nftick > 6) * 10) * nfdec;
  end
  for ct = 1:length(W)
    % Expand toward LF, fill in up to Nyquist freq, and clip at Nyquist freq.
    Wct = W{ct};
    W{ct} = [Wct(1)./[1e5;1e3;1e1] ; LocalFill(Wct, NyqFreq)];
  end
else
  % Continuous time: Expand freq. vector toward LF and HF
  for ct = 1:length(W)
    Wct = W{ct};
    W{ct} = [Wct(1)./[1e5;1e3;1e1] ; Wct ; Wct(end)*[1e1;1e3;1e5]];
  end
end

% Need a unique set of frequencies
for ct = 1:length(W)
  Wct = unique(W{ct});
  % REVISIT: Protect against 0 rad/sec frequency
  if (Wct(1) <= eps)
    Wct(1) = eps;
  end
  W{ct} = Wct;
end

% Return frequency vectors as separate outputs
varargout = W;

% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%
function w = LocalFill(w, nf)
wmax = w(end);
if wmax > nf,
  w = [w(w<0.999*nf,:) ; nf];
elseif wmax > nf/2,
  w2 = linspace(wmax, nf, ceil(10*log2(nf/wmax)));
  w = [w(1:end-1) ; w2(:)];
else
  w1 = logspace(log10(wmax), log10(nf/2), ceil(3*log10(nf/2/wmax)));
  w2 = linspace(nf/2, nf, 10);
  w = [w(1:end-1) ; w1(1:end-1)' ; w2(:)];
end
