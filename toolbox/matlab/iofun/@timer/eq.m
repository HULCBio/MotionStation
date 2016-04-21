function iseq=eq(arg1, arg2)
%EQ ==  Equal.
%
%    C = EQ(A,B) does element by element comparisons between timer objects
%    A and B and returns a logical indicating if they refer to the 
%    same timer objects. 
%
%    Note: EQ is automatically called for the syntax 'A == B'.
%
%    See also TIMER/NE, TIMER/ISEQUAL
%

%    RDD 11-20-2001
%    Copyright 2001-2003 The MathWorks, Inc.
%    $Revision: 1.2.4.2 $  $Date: 2004/03/30 13:07:21 $

% if arg1 is a timer, set obj1 to the java timer object so the jobjects are
% compared, otherwise just compare what is given.
if isa(arg1,'timer')
    obj1 = arg1.jobject;
    valids = isJavaTimer(obj1); % find out which ones are valid timers
else
    obj1 = arg1;
end

% if arg2 is a timer, set obj2 to the java timer object so the jobjects are
% compared, otherwise just compare what is given.
if isa(arg2,'timer')
    obj2 = arg2.jobject;
    valids = isJavaTimer(obj2);  % find out which ones are valid timers
else
    obj2 = arg2;
end

% Make sure that the objects are of the same size.
try
    if (~all(size(obj1) == size(obj2)) && ~( (numel(obj1) <= 1) || (numel(obj2) <= 1) ) )
        error('matlab:timer:sizemismatch', timererror('matlab:timer:sizemismatch'));
    end
catch
    lerr = fixlasterr;
    error(lerr{:});
end

% compare the two objs and mask with the valid matrix since it is defined
% that invalid objects are never equal to each other.
try 
    iseq = eq(obj1,obj2) & valids;
catch
    lerr = fixlasterr;
    error(lerr{:});
end
