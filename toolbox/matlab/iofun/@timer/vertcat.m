function out = vertcat(varargin)
%VERTCAT Vertical concatenation of timer objects.
%
%    [A;B] is the vertical concatenation of timer objects A and B.  A and B 
%    must have the same number of columns. Any number of timer objects can be
%    concatenated within one pair of brackets.  Only timer objects can be
%    concatenated together.
%
%    C = VERTCAT(A,B) is called for the syntax '[A; B]' 
% 
%    See also TIMER/HORZCAT.
%

%    RDD 1/08/2002
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1 $  $Date: 2002/02/19 19:56:23 $

out = [];
% Loop through each object and concatenate.
for i = 1:nargin
    if ~isempty(varargin{i}) % skip empty elements
        if ~isa(varargin{i},'timer') % trap for concatenation of non-timer objects
            error('MATLAB:timer:creatematrix',timererror('MATLAB:timer:creatematrix'));
        end
        [rows cols] = size(varargin{i});
        if cols > 1 % don't allow non-vectors to be created.
            error('MATLAB:timer:creatematrix',timererror('MATLAB:timer:creatematrix'));
        end                    
        if isempty(out) % if first element, set out to the element
            out=varargin{i};
        else
            % if not first element, add java object to out's jobject field
            out.jobject = [out.jobject; varargin{i}.jobject];
        end
    end
end
