function [w,msg] = gencoswin(varargin)
%GENCOSWIN   Returns one of the generalized cosine windows.
%   GENCOSWIN returns the generalized cosine window specified by the 
%   first string argument. Its inputs can be
%     Window name    - a string, any of 'hamming', 'hann', 'blackman'.
%     N              - length of the window desired.
%     Sampling flag  - optional string, one of 'symmetric', 'periodic'. 

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:09:14 $ 

% Parse the inputs
window = varargin{1};
n = varargin{2};
msg = '';

% Check for trivial orders
[n,w,trivialwin] = check_order(n);
if trivialwin, return, end;

% Select the sampling option
if nargin == 2, % no sampling flag specified, use default. 
    sflag = 'symmetric';
else
    sflag = lower(varargin{3});
end

% Allow partial strings for sampling options
allsflags = {'symmetric','periodic'};
sflagindex = strmatch(sflag, allsflags);
if length(sflagindex)~=1         % catch 0 or 2 matches
    msg = 'Sampling flag must be either ''symmetric'' or ''periodic''.';
    return;
else	
    sflag = allsflags{sflagindex};
end

% Evaluate the window
switch sflag
case 'periodic'
    w = sym_window(n+1,window);
    w(end) = [];
case 'symmetric'
    w = sym_window(n,window);
end

%---------------------------------------------------------------------
function w = sym_window(n,window)
%SYM_WINDOW   Symmetric generalized cosine window.
%   SYM_WINDOW Returns an exactly symmetric N point generalized cosine 
%   window by evaluating the first half and then flipping the same samples
%   over the other half.

if ~rem(n,2)
    % Even length window
    half = n/2;
    w = calc_window(half,n,window);
    w = [w; w(end:-1:1)];
else
    % Odd length window
    half = (n+1)/2;
    w = calc_window(half,n,window);
    w = [w; w(end-1:-1:1)];
end

%---------------------------------------------------------------------
function w = calc_window(m,n,window)
%CALC_WINDOW   Calculate the generalized cosine window samples.
%   CALC_WINDOW Calculates and returns the first M points of an N point
%   generalized cosine window determined by the 'window' string.

% For the hamming and blackman windows we force rounding in order to achieve
% better numerical properties.  For example, the end points of the hamming 
% window should be exactly 0.08.

switch window
case 'hann'
    % Hann window
    %    w = 0.5 * (1 - cos(2*pi*(0:m-1)'/(n-1))); 
    a0 = 0.5;
    a1 = 0.5;
    a2 = 0;
    a3 = 0;
    a4 = 0;
case 'hamming'
    % Hamming window
    %    w = (54 - 46*cos(2*pi*(0:m-1)'/(n-1)))/100;
    a0 = 0.54;
    a1 = 0.46;
    a2 = 0;
    a3 = 0;
    a4 = 0;
case 'blackman'
    % Blackman window
    %    w = (42 - 50*cos(2*pi*(0:m-1)/(n-1)) + 8*cos(4*pi*(0:m-1)/(n-1)))'/100;
    a0 = 0.42;
    a1 = 0.5;
    a2 = 0.08;
    a3 = 0;
    a4 = 0;
case 'flattopwin'
    % Flattop window
    % Original coefficients as defined in the reference (see flattopwin.m);
    % a0 = 1;
    % a1 = 1.93;
    % a2 = 1.29;
    % a3 = 0.388;
    % a4 = 0.032;
    %
    % Scaled by (a0+a1+a2+a3+a4)
    a0 = 0.2156;
    a1 = 0.4160;
    a2 = 0.2781;
    a3 = 0.0836;
    a4 = 0.0069;
end

x = (0:m-1)'/(n-1);
w = a0 - a1*cos(2*pi*x) + a2*cos(4*pi*x) - a3*cos(6*pi*x) + a4*cos(8*pi*x);

% [EOF] gencoswin.m
