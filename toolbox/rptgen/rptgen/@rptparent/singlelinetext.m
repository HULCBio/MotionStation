function out=singlelinetext(p,in,delim)
%SINGLELINETEXT forces a variable to be a 1xN string
%   OUT=SINGLELINETEXT(RPTPARENT,IN)
%   OUT=SINGLELINETEXT(RPTPARENT,IN,DELIMITER)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:26 $

if isempty(in)
   out='';
else
   if nargin<3
      delim=' ';
   end
   
   
   switch class(in)
   case 'cell' %assume a cell array of 1xN strings for simplicity
      in=in(:);
      [sp{1:size(in,1),1}]=deal(delim);
      sp{end}='';
      in=[in sp]';
      out=[in{:}];
   case 'char'
      if size(in,1)>1
         out=singlelinetext(p,cellstr(in),delim);
      else
         out=in;
      end
   case 'double'
      out=singlelinetext(p,num2str(in),delim);
   otherwise
      out='';
   end
   
   out=strrep(out,sprintf('\n'),delim);
end
