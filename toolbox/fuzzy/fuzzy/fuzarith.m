function out = fuzarith(x, A, B, operator)
%FUZARITH Fuzzy arithmetic.
%	C = FUZARITH(X, A, B, OPERATOR) returns a fuzzy set C as the result
%	of applying OPERATOR on fuzzy sets A and B of universe X. A, B, and X
%	should be vectors of the same dimension. OPERATOR should be one of the
%	following strings: 'sum', 'sub', 'prod', and 'div'. The returned fuzzy
%	set C is a column vector with the same length as A and B. Note that
%	This function uses interval arithmetics and it assumes
%	1. A and B are convex fuzzy sets;
%	2. Membership grades of A and B outside of X are zero.
%
%	Fuzzy addition could generates "divide by zero" message, but it will
%	not affect the correctness of this function. (However, this may cause
%	problems on machines without IEEE arithmetic, such as VAX and Cray.)
%
%	For example:
%
%	point_n = 101;			% this determines MF's resolution
%	min_x = -20; max_x = 20;	% universe is [min_x, max_x]
%	x = linspace(min_x, max_x, point_n)';
%	A = trapmf(x, [-10 -2 1 3]);	% trapezoidal fuzzy set A
%	B = gaussmf(x, [2 5]);		% Gaussian fuzzy set B
%	C1 = fuzarith(x, A, B, 'sum');
%	subplot(2,2,1);
%	plot(x, A, 'y--', x, B, 'm:', x, C1, 'c');
%	title('fuzzy addition A+B');
%	C2 = fuzarith(x, A, B, 'sub');
%	subplot(2,2,2);
%	plot(x, A, 'y--', x, B, 'm:', x, C2, 'c');
%	title('fuzzy subtraction A-B');
%	C3 = fuzarith(x, A, B, 'prod');
%	subplot(2,2,3);
%	plot(x, A, 'y--', x, B, 'm:', x, C3, 'c');
%	title('fuzzy multiplication A*B');
%	C4 = fuzarith(x, A, B, 'div');
%	subplot(2,2,4);
%	plot(x, A, 'y--', x, B, 'm:', x, C4, 'c');
%	title('fuzzy division A/B');

%	Roger Jang, 6-23-95
%	Copyright 1994-2002 The MathWorks, Inc. 
% $Revision: 1.10 $

x = x(:); A = A(:); B = B(:);
orig_x = x;
% augment x, A, and B for easy interpolation
A = [0; A; 0];
B = [0; B; 0];
x = [min(x)-(max(x)-min(x))/100; x; max(x)+(max(x)-min(x))/100];

tmp = find(diff(A)>0);
index1A = min(tmp):max(tmp)+1;	% index for left shoulder
tmp = find(diff(A)<0);
index2A = min(tmp):max(tmp)+1;	% index for right shoulder

tmp = find(diff(B)>0);
index1B = min(tmp):max(tmp)+1;	% index for left shoulder
tmp = find(diff(B)<0);
index2B = min(tmp):max(tmp)+1;	% index for right shoulder

height = linspace(0, 1, 101)';
index1 = find(height > max(A(index1A)));
index2 = find(height > max(A(index2A)));
index3 = find(height > max(B(index1B)));
index4 = find(height > max(B(index2B)));
height([index1; index2; index3; index4]) = [];

leftA = interp1(A(index1A), x(index1A), height, 'linear'); 
rightA = interp1(A(index2A), x(index2A), height, 'linear'); 
leftB = interp1(B(index1B), x(index1B), height, 'linear'); 
rightB = interp1(B(index2B), x(index2B), height, 'linear'); 

intervalA = [leftA rightA];
intervalB = [leftB rightB];

if strcmp(operator, 'sum'),
	% interval mathematics for summation A+B 
	intervalC = [leftA+leftB rightA+rightB];
	x1 = [intervalC(:, 1); flipud(intervalC(:, 2))];
	C = [height; flipud(height)];
elseif strcmp(operator, 'sub'),
	% interval mathematics for subtraction A-B 
	intervalC = [leftA-rightB rightA-leftB];
	x1 = [intervalC(:, 1); flipud(intervalC(:, 2))];
	C = [height; flipud(height)];
elseif strcmp(operator, 'prod'),
	% interval mathematics for product A*B 
	tmp = [leftA.*leftB leftA.*rightB rightA.*leftB rightA.*rightB];
	intervalC = [min(tmp')' max(tmp')'];
	x1 = [intervalC(:, 1); flipud(intervalC(:, 2))];
	C = [height; flipud(height)];
elseif strcmp(operator, 'div'),
	% interval mathematics for division A/B 
	index = (prod(intervalB')>0)';	% contains 0 or not
	tmp1 = leftB.*index;
	tmp = [leftA./leftB leftA./tmp1 leftA./rightB ...
		rightA./leftB rightA./tmp1 rightA./rightB];
	intervalC = [min(tmp')' max(tmp')'];
	x1 = [intervalC(:, 1); flipud(intervalC(:, 2))];
	C = [height; flipud(height)];
	% get rid of inf or -inf due to division
	index = find(~finite(x1));
	x1(index) = [];
	C(index) = [];
else
	error('Unknown fuzzy arithmetic operator!');
end

% Make sure that x1 is monotonically increasing
index = find(diff(x1) == 0);
x1(index) = [];
C(index) = [];

% Take care of "out-of-bound interpolation"
index1 = find(orig_x < min(x1));
index2 = find(orig_x > max(x1));
% tmp_x is legal input for interp1
tmp_x = orig_x;
tmp_x([index1; index2]) = [];
% Do interpolation 
out = interp1(x1, C, tmp_x, 'linear');
% Final output
out = [zeros(size(index1)); out; zeros(size(index2))];
