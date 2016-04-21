function b = hdsNewArray(a,Size)
%HDSNEWARRAY  Creates new array of specified size and type.
%
%   New array entries are initialized with a filler specific
%   to the data type.  The data type is determine by the first 
%   argument.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:56 $
if isa(a,'double')
   % Filler = NaN
   b = zeros(Size);
   b(:) = NaN;
elseif isa(a,'char')
   % Filler = ' ';
   b = char(zeros(Size));
elseif iscellstr(a)
   % Filler = ''
   b = cell(Size);
   b(:) = {''};
elseif isa(a,'cell')
   b = cell(Size);
elseif isa(a,'struct')
   c = fieldnames(a)';
   c = [c ; cell(size(c))];
   c{2,1} = cell(Size);
   b = struct(c{:});
elseif isa(a,'handle')
   % REVISIT
   b = zeros(Size);
   b(:) = NaN;
   b = handle(b);
else
   % Default recipe
   b = feval(class(a),zeros(Size));
end