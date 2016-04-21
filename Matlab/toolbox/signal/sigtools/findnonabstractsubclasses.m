function subclassnames = findnonabstractsubclasses(c0, p)
%FINDNONABSTRACTSUBCLASSES Find all the non-abstract subclasses of class c0
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(CO, P) find all the non-abstract
%   subclasses of class C0 in the package P and returns a cell array of the 
%   class names in SUBCLASSNAMES.
%
%   See also FINDALLWINCLASSES.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:53:19 $

p = findpackage(p);
c = findclass(p);

% Find class c0
i = 1;
index = [];
while isempty(index) & i<=length(c),
    if strcmpi(c0,c(i).Name),
        index = i;
    else
        i = i+1;
    end
end
c0 = c(index);
c(index) = [];

% Find the subclasses of c0
nsubclasses=[];
for i=1:length(c),
    if c(i).isDerivedFrom(c0),
        nsubclasses = [nsubclasses; i];
    end
end

% Remove the abstract classes
removedindex = [];
for j=1:length(nsubclasses),
    if strcmpi(c(nsubclasses(j)).Description, 'abstract'),
        removedindex=[removedindex; j];
    end
end
nsubclasses(removedindex) = [];

% Get the class names
subclassnames={};
for k=1:length(nsubclasses),
    subclassnames=[subclassnames;{c(nsubclasses(k)).Name}];
end

% Re-order
subclassnames = subclassnames(end:-1:1);


% [EOF]
