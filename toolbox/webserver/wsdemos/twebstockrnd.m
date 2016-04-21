function str = twebstockrnd(spot, r, sigma, numsim, symbol)
%TWEBSTOCKRND stand-alone test driver for WEBSTOCKRND.
%   WEBSTOCKRND is the web demo stock price path simulation.
%
%   STR = WEBSTOCKRND(SPOT, R, SIGMA, SUMSIM, SYMBOL) creates 
%   stock price path graphic and HTML file.  Returns HTML output
%   in STR.
% 
%   Inputs 
%      SPOT   : Current Stock Price                     e.g. 60
%      R      : Annualized Expected Return (percent)    e.g. 10
%      SIGMA  : Annualized Volatility (percent)         e.g. 30
%      NUMSIM : Number of Simulated Paths               e.g. 4
%      SYMBOL : Ticker Symbol                           e.g. IBM

%   Author(s): J. Akao, M. Greenstein, 04-01-98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.5 $   $Date: 2001/04/25 18:49:28 $

% Establish defaults.
InputSet.spot   = num2str(100);
InputSet.r      = num2str(10);
InputSet.sigma  = num2str(30);
InputSet.numsim = num2str(4);
InputSet.symbol = 'IBM';

% Check for input in arguments.
if (0 < nargin), InputSet.spot = num2str(spot); end
if (1 < nargin), InputSet.r = num2str(r); end
if (2 < nargin), InputSet.sigma = num2str(sigma); end
if (3 < nargin), InputSet.numsim = num2str(numsim); end
if (4 < nargin), InputSet.symbol = symbol; end

% Create substitute matweb-supplied arguments.
InputSet.mldir = '.';
InputSet.mlid  = 'ml00001';

% Call the demo as it would be called from matweb.  Supply an
% output file.
str = webstockrnd(InputSet, 'twebstockrnd.html');

