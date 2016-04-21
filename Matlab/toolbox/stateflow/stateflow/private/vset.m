function s = vset(s1, op, s2 )
%VSET  Provides set operations on vectors of doubles or chars
%      A set is an unordered list of unique elements.
%      All set operations return their resulting set vector sorted in
%      ascending order.
%
%   SET    = VSET( S )  returns the minimum set.
%   SET    = VSET( S1, '+', S2 )  returns the union of sets.
%   SET    = VSET( S1, '*', S2 )  returns the intersection of sets.
%   SET    = VSET( S1, '-', S2 )  returns the differenece between the sets.
%   IS_EQUAL  = VSET( S1, '==', S2 ) returns true if sets are the same.
%   IS_SUBSET = VSET( S1, '<=', S2 ) returns true if S1 is a subset of S2.
%   IS_PROPER = VSET( S1, '<', S2 )  returns true if S1 is a proper subset of S2.
%   IS_SUBSET = VSET( S1, '>=', S2 ) returns true if S2 is a subset of S1.
%   IS_PROPER = VSET( S1, '>', S2 )  returns true if S2 is a proper subset of S1.

%
%	E. Mehran Mestchian
%	Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11.2.1 $  $Date: 2004/04/15 01:01:31 $

if nargin==1
%   SET    = VSET( S )  returns the minimum set.
	if isempty(s1),
		if isstr(s1),
			s='';
		else,
			s = [];
		end
		return
	end
	if min(size(s1))==1,
		s= sort(s1);
	else
		s= sort(s1(:));
	end

	N=length(s);
	if N>1
		% d indicates the location of matching entries
		d = find(s(1:N-1)==s(2:N));
		s(d) = [];
	end
	if isstr(s1), s=setstr(s); end
else
	error(nargchk(3,3,nargin));
	rowvec = (size(s1,1)==1) | (size(s2,1)==1);
	switch op
	case '+' % S = VSET( S1, '+', S2 )  returns the union of sets.
		s= vset([s1(:);s2(:)]);
		if rowvec, s = s.'; end
	case '*' %  S = VSET( S1, '*', S2 )  returns the intersection of sets.
		if isempty(s1) | isempty(s2), if isstr(s1),s=''; else,s = [];end,return, end
		% Make sure s1 and s2 contain unique elements.
		s1 = vset(s1(:));
		s2 = vset(s2(:));
		% Find matching entries
		s = sort([s1;s2]);
		N = length(s);
		if N>1
			d = find(s(1:N-1)==s(2:N));
			s = s(d);
		end
		if rowvec, s = s.'; end
		if isstr(s1), s=setstr(s); end
	case '-' % S = VSET( S1, '-', S2 )  returns the differenece between the sets.
		if isempty(s2), s= vset(s1); return, end
		if isempty(s1),if isstr(s1),s=''; else,s = [];end,return,end
		% Make sure s1 and s2 contain unique elements.
		s1 = vset(s1(:));
		s2 = vset(s2(:));
		% Find matching entries
		[s,ndx] = sort([s1;s2]);
		N = length(s);
		if N>1
			d = find(s(1:N-1)==s(2:N)); % d indicates the location of matching entries
			ndx([d;d+1]) = []; % Remove all matching entries
		end
		d = ndx <= length(s1); % Values in a that don't match.
		s = s1(ndx(d));
		if rowvec, s = s.'; end
		if isstr(s1), s=setstr(s); end
	case '==' %  IS_EQUAL  = VSET( S1, '==', S2 ) returns true if sets are the same.
		% Make sure s1 and s2 contain unique elements.
		s1 = vset(s1(:));
		s2 = vset(s2(:));
		s = isequal(s1,s2);
	case '<=' %  IS_SUBSET = VSET( S1, '<=', S2 ) returns true if S1 is a subset of S2.
		if isempty(s2), s=isempty(s1); return, end
		if isempty(s1), s=1; return,end
		% Make sure s1 and s2 contain unique elements.
		s1 = vset(s1(:));
		s2 = vset(s2(:));
		% Find matching entries
		[s,ndx] = sort([s1;s2]);
		N = length(s);
		if N>1
			N = length(find(s(1:N-1)==s(2:N))); % d indicates the location of matching entries
		end
		s = N==length(s1);
	case '<' %   IS_PROPER = VSET( S1, '<', S2 )  returns true if S1 is a proper subset of S2.
		if isempty(s2), s=0; return, end
		if isempty(s1), s=~isempty(s2); return,end
		% Make sure s1 and s2 contain unique elements.
		s1 = vset(s1(:));
		s2 = vset(s2(:));
		% Find matching entries
		[s,ndx] = sort([s1;s2]);
		N = length(s);
		if N>1
			N = length(find(s(1:N-1)==s(2:N))); % d indicates the location of matching entries
		end
		s = N==length(s1) & N<length(s2);
	case '>=' %  IS_SUBSET = VSET( S1, '>=', S2 ) returns true if S2 is a subset of S1.
		if isempty(s1), s=isempty(s2); return, end
		if isempty(s2), s=1; return,end
		% Make sure s1 and s2 contain unique elements.
		s1 = vset(s1(:));
		s2 = vset(s2(:));
		% Find matching entries
		[s,ndx] = sort([s1;s2]);
		N = length(s);
		if N>1
			N = length(find(s(1:N-1)==s(2:N))); % d indicates the location of matching entries
		end
		s = N==length(s2);
	case '>' %   IS_PROPER = VSET( S1, '<', S2 )  returns true if S2 is a proper subset of S1.
		if isempty(s1), s=0; return, end
		if isempty(s2), s=~isempty(s1); return,end
		% Make sure s1 and s2 contain unique elements.
		s1 = vset(s1(:));
		s2 = vset(s2(:));
		% Find matching entries
		[s,ndx] = sort([s1;s2]);
		N = length(s);
		if N>1
			N= length(find(s(1:N-1)==s(2:N))); % d indicates the location of matching entries
		end
		s = N==length(s2) & N<length(s1);
	otherwise
		error('Bad SET operation.');
	end
end
