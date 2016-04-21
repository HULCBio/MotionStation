function tf=isempty(myTag)
%ISEMPTY returns whether an SGMLTAG object is empty
%   ISEMPTY(SGMLTAG) returns true if char(SGMLTAG) 
%   is empty.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:35 $

%to be empty, the myTag.tag must be empty AND
%all the cells of myTag must be empty.

tf=(isempty(myTag.tag) & locIsEmpty(myTag.data));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=locIsEmpty(sectContent)

if isempty(sectContent)
    tf=logical(1);
elseif iscell(sectContent)
    %we can't use cellfun('isempty') here because
    %it is important to call overloaded isempty on sgmltags
    tf=logical(1);
    cLen=length(sectContent);
    i=1;
    while i<=cLen & tf
        tf=locIsEmpty(sectContent{i});
        i=i+1;
    end
else
    tf=logical(0);
end