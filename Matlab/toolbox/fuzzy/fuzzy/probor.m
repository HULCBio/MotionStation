function y=probor(x)
%PROBOR	Probabilistic OR.
%	Y = PROBOR(X) returns the probabilistic OR (also known
%	as the algebraic sum) of the columns of X. If X has two
%	rows such that X = [A; B], then Y = A + B - AB. If X has
%	only one row, then Y = X.
%
%	For example:
%	
%		x = (0:0.1:10);
%               figure('Name','Probabilistic OR','NumberTitle','off');
%               y1 = gaussmf(x, [0.5 4]);
%               y2 = gaussmf(x, [2 7]);
%		yy = probor([y1; y2]);
%		plot(x,[y1; y2; yy])

%	Ned Gulley, 9-19-94
%	Copyright 1994-2002 The MathWorks, Inc. 
%	$Revision: 1.14 $  $Date: 2002/04/14 22:21:46 $

if size(x,1)<=1,
    y=x;
    return
end

y=x;
for count=2:size(x,1),
    y(count,:)=y(count-1,:)+y(count,:)-prod(y(([-1 0]+count),:));
end

y=y(size(y,1),:);
