function [msg]=qaskdeco(x,y,m,minmax)
%QASKDECO
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use QAMDEMOD instead.

%    MSG = QASKDECO(X, Y, M) decodes the message signal MSG from the
%    in-phase component X and quadrature component Y with the M-ary
%    number M. M must be an integer power of 2. The signal constellation
%    is assumed to be scaled such that the minimum distance between 
%    adjacent signal points is 2.
%
%    MSG = QASKDECO(X, Y, M, MINMAX) decodes the information where
%    the maximum and minimum values of X and Y are given in MINMAX
%    by the form:
%                 | X_min    X_max |
%        MINMAX = |                |
%                 | Y_min    Y_max |
%
%    See also QASKENCO.

%    Copyright 1996-2003 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $

error(nargchk(3,4,nargin));

[x_m, x_n] = size(x);
[y_m, y_n] = size(y);
if min(x_m, x_n) * min(y_m, y_n) ~= 1
	error('Input in-phase and quadrature components must be vectors.');
end;

if isstr(m)
  error('M must be a number, not a string.');
end

K = log2(m);
if floor(K) ~= K
	error('M must equal an integer power of 2.');
end;

% Make copies for use in case we need them later
xorig = x;
yorig = y;

xx = constlay(K, 1);
[leny, lenx] = size(xx);

if (nargin == 4)
    [i,j]=size(minmax);
    if (i ~= 2) | (j ~= 2)
        error('The fourth input argument for QASKDECO is incorrect.')
    end;
    if ((minmax(1,2) <= minmax(1,1)) | (minmax(2,2) <= minmax(2,1))) & (m > 2)
        disp('Cannot process QASKDECO')
        disp('The fourth variable should have the format:')
        disp('     | X_min    X_max |')
        disp('     | Y_min    Y_max |')
    end;
    % scale such that x = [0, 1], and y = [0, 1].
    if m > 2
        x = (x - minmax(1,1))/(minmax(1,2) - minmax(1,1));
    end
    if m > 0
        y = (y - minmax(2,1))/(minmax(2,2) - minmax(2,1));
    end;
    x = x * 2 * lenx - lenx ;
    y = y * 2 * leny - leny ;
end;

xx = flipud((xx));

smallNum = eps^(2/3);
% Clamp the values that are outside the constellation regions.
idx = find(x >= lenx);
x(idx) = min(x(idx), lenx-smallNum);

idx = find(x < -lenx);
x(idx) = max(x(idx), -lenx);

idy = find(y >= leny);
y(idy) = min(y(idy), leny-smallNum);

idy = find(y < -leny);
y(idy) = max(y(idy), -leny);

% Make the decisions
x = round((x + lenx + 1) / 2);
y = round((y + leny + 1) / 2);

% Get the message
for i = 1 : min(length(x), length(y));
	msg(i) = xx(y(i), x(i));
end;

% Redo the decoding using the minimum distance criterion for any NaN
% decisions that we may have made due to constlay. 
if any(isnan(msg))
	% Get the nearest neighbours for the NaN decisions	
	[idx, idy]  = find(isnan(xx));
	for i = 1:length(idx)
		if idy(i) < length(xx)/2
			if idx(i) < length(xx)/2  % II Quadrant
				vals(3*(i-1)+1) = xx(idx(i)+1, idy(i));
				vals(3*(i-1)+2) = xx(idx(i),   idy(i)+1);
				vals(3*(i-1)+3) = xx(idx(i)+1, idy(i)+1);
			else	% III Quadrant
				vals(3*(i-1)+1) = xx(idx(i)-1, idy(i));
				vals(3*(i-1)+2) = xx(idx(i),   idy(i)+1);
				vals(3*(i-1)+3) = xx(idx(i)-1, idy(i)+1);
			end
		else	
			if idx(i) < length(xx)/2  % I Quadrant 
				vals(3*(i-1)+1) = xx(idx(i),   idy(i)-1);
				vals(3*(i-1)+2) = xx(idx(i)+1, idy(i)-1);
				vals(3*(i-1)+3) = xx(idx(i)+1, idy(i));
			else	% IV Quadrant
				vals(3*(i-1)+1) = xx(idx(i)-1, idy(i)-1);
				vals(3*(i-1)+2) = xx(idx(i)-1, idy(i));
				vals(3*(i-1)+3) = xx(idx(i),   idy(i)-1);
			end
		end	
	end
	% keep only the unique ones
	vals(find(isnan(vals))) = [];
	vals = unique(vals);
	
	% Find the actual location in terms of I, Q components
	[nanI, nanQ] = qaskenco(vals,m);
	nanI = nanI';
	nanQ = nanQ';
	
	% Get the original data 
	cid = find(isnan(msg));
	x = xorig(cid);
	y = yorig(cid);

	% Apply the Minimum distance criteria
	[temp, xxind] = min(...
	((x(:, ones(1, length(vals))) - nanI(ones(1, length(cid)), :)).^2 + ...
	(y(:, ones(1, length(vals))) - nanQ(ones(1, length(cid)), :)).^2)');

	msg(cid) = vals(xxind);
end

if x_m > x_n
	msg = msg';
end;

% [EOF]
