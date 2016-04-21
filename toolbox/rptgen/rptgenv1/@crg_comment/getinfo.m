function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CFRPARAGRAPH)
%
%   I.Name - component informal name
%   I.Type - component general category 2-letter code
%   I.Desc - short description of the component
%   I.ValidChildren - shows whether or not component can have children
%          ValidChildren={logical(0)} for no children
%          ValidChildren={logical(1)} if children are allowed
%   I.att - component attributes
%   I.attx - information about component attributes
%   I.ref - reference structure
%   I.x - temporary attribute page handle structure

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:52 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Comment');
out.Type = 'RG';
out.Desc = xlate('Inserts a comment into the report.');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out.att.CommentText={''};

out.att.isDisplayComment=logical(0);

out.att.CommentStatusLevel=3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.CommentText=struct('String','',...
   'UIcontrol','multiedit',...
   'isParsedText',logical(1));

out.attx.isDisplayComment.String=...
   'Show comment in Generation Status window';

out.attx.CommentStatusLevel.String=...
   'Status message priority level ';
out.attx.CommentStatusLevel.enumValues=...
   {1 2 3 4 5 6};
out.attx.CommentStatusLevel.enumNames={
   '1) Error messages only'
   '2) Warning messages'
   '3) Important messages '
   '4) Standard messages '
   '5) Low-level messages '
   '6) All messages'
};
