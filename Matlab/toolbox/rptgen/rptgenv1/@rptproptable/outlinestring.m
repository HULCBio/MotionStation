function strout=outlinestring(r,c,preString)
%OUTLINESTRING returns a short description of the component
%   OUTSTR=OUTLINESTRING(RPTPROPTABLE,C,PRESTRING) returns OUTSTR, 
%   a string for the component outline.  Format is
%   '<PRESTRING> PropTable - <Table Title>'

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:28 $

strout=sprintf( '%s Prop Table - %s',preString, ...
      singlelinetext(c,c.att.TableTitle));
