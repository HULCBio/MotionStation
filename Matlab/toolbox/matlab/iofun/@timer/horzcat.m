function out = horzcat(varargin)
%HORZCAT Horizontal concatenation of timer objects.
%
%    [A B] is the horizontal concatenation of timer objects A and B.  A and B
%    must have the same number of rows.  [A,B] is the same thing.  Any
%    number of timer objects can be concatenated within one pair of brackets.
%    Only timer objects can be concatenated together.

% 
%    C = HORZCAT(A,B) is called for the syntax '[A  B]'.
% 
%    See also TIMER/VERTCAT.
%

%    RDD 1/08/2002
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1 $  $Date: 2002/02/19 19:55:24 $

out = [];
% Loop through each object and concatenate.
for i = 1:nargin
    if ~isempty(varargin{i}) % skip empty elements
        if ~isa(varargin{i},'timer') % trap for concatenation of non-timer objects
            error('MATLAB:timer:creatematrix',timererror('MATLAB:timer:creatematrix'));
        end
        [rows cols] = size(varargin{i});
        if rows > 1 % don't allow non-vectors to be created.
            error('MATLAB:timer:creatematrix',timererror('MATLAB:timer:creatematrix'));
        end                    
        if isempty(out) % if first element, set out to the element
            out=varargin{i};
        else
            % if not first element, add java object to out's jobject field
            out.jobject = [out.jobject varargin{i}.jobject];
        end
    end
end

