function out=getinfo(c)
%GETINFO component information

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:15 $

out=getprotocomp(c);

out.Name = xlate('Header');
out.Type = 'FR';
out.Desc = xlate('Inserts a header into the report.');
out.ValidChildren={logical(1)};

out.att.headertext='';
out.att.weight='';

%----------------------------

entry.Name='Header weight';
entry.Type='ENUM';
entry.enumValues={'' 'Sect1' 'Sect2' 'Sect3' 'Sect4' 'Sect5'};
entry.enumNames={'Auto' 'Largest' 'Larger' 'Large' ...
   'Normal' 'Small'};
entry.UIcontrol='popupmenu';
out.attx.weight=entry;


