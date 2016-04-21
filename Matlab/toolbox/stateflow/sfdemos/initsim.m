function initsim;

% Copyright 2003 The MathWorks, Inc.

p.symbolPeriod = 1e-6;
p.Nbits = 500; % bits per frame
p.Nbtrain = 100;  % training bits per frame
p.bitsPerSymbol = 2;
p.M = 2.^p.bitsPerSymbol;
p.Nsymbols = p.Nbits / p.bitsPerSymbol;
p.Ntrain = p.Nbtrain / p.bitsPerSymbol;
p.Nsource = p.Nsymbols - p.Ntrain;
p.sourcePeriod = p.symbolPeriod * p.Nsymbols/p.Nsource;
rand('state', 0);
p.trainSeq = randint(p.Ntrain, 1, p.M);
assignin('base', 'params', p);

