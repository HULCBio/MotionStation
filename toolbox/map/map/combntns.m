function out=combntns(choicevec,choose);

%COMBNTNS  Computes all combinations of a given set of values
%
%  c = COMBNTNS(choicevec,choose) returns all combinations of the
%  values of the input choice vector.  The size of the combinations
%  are given by the second input.  For example, if choicevec
%  is [1 2 3 4 5], and choose is 2, the output is a matrix
%  containing all distinct pairs of the choicevec set.
%  The output matrix has "choose" columns and the combinatorial
%  "length(choicevec)-choose-'choose'" rows.  The function does not
%  account for repeated values, treating each entry as distinct.
%  As in all combinatorial counting, an entry is not paired with
%  itself, and changed order does not constitute a new pairing.
%  This function is recursive.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.11.4.1 $    $Date: 2003/08/01 18:15:39 $

if nargin ~= 2;  error('Incorrect number of arguments');  end

%  Input dimension tests

if min(size(choicevec)) ~= 1 | ndims(choicevec) > 2
    error('Input choices must be a vector')

elseif max(size(choose)) ~= 1
    error('Input choose must be a scalar')

else
    choicevec = choicevec(:);       %  Enforce a column vector
end

%  Ensure real inputs

if any([~isreal(choicevec) ~isreal(choose)])
    warning('Imaginary parts of complex arguments ignored')
	choicevec = real(choicevec);    choose = real(choose);
end

%  Cannot choose more than are available

choices=length(choicevec);
if choices<choose(1)
	error('Not enough choices to choose that many')
end


%  Choose(1) ensures that a scalar is used.  To test the
%  size of choices upon input results in systems errors on
%  the Macintosh.  Maybe somehow related to recursive nature of program.

%  If the number of choices and the number to choose
%  are the same, choicevec is the only output.

if choices==choose(1)
	out=choicevec';

%  If being chosen one at a time, return each element of
%  choicevec as its own row

elseif choose(1)==1
	out=choicevec;

%  Otherwise, recur down to the level at which one such
%  condition is met, and pack up the output as you come out of
%  recursion.

else
	out = [];
	for i=1:choices-choose(1)+1
		tempout=combntns(choicevec(i+1:choices),choose(1)-1);
		out=[out; choicevec(i)*ones(size(tempout,1),1)	tempout];
	end
end
