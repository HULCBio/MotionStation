function y = testfun_octave(x)
%TESTFUN  Do something stupid that takes some time to compute.
%   Y = TESTFUN(X) does some computations and returns Y=X.^2 as output.
%
%		Markus Buehren
%		Last modified 13.11.2007

for k=1:2000
	a = cond   (rand(20)); %#ok
%	a = condest(rand(20)); %#not available on Octave
%	a = rcond  (rand(20)); %#not available on Octave
	a = cond   (rand(20)); %#ok
	a = cond   (rand(20)); %#ok
end
y = x.a*x.b;
