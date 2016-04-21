function stemplot(x,varname)
%STEMPLOT  Plots the signal specified using the STEM function.

% Copyright 1999-2004 The MathWorks, Inc.

figure;
stem(x);
grid;
title(['Signal ',varname]);
ylabel('Amplitude');
xlabel('Samples (n)');

% Zoom-in to samples of interest.
ylim = get(gca,'ylim'); 
idx = find(abs(x)>=0.001);
if ~isempty(idx),
    axis([idx(1) idx(end) ylim]);
end

% [EOF]
