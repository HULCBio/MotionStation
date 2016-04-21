function varargout=validatecolumns(c,cWidIn)
%VALIDATECOLUMNS verify that columns are correct
%  [CWIDOUT]=VALIDATECOLUMNS(C)
%  [CWIDOUT]=VALIDATECOLUMNS(C,CWIDIN)
%  [CWIDOUT,C]=VALIDATECOLUMNS(C)
%  [CWIDOUT,C]=VALIDATECOLUMNS(c,CWIDIN)


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:08 $

if nargin<2
   cWidIn=c.att.ColWidths;
end
numColIn=length(cWidIn);

numContentColumns=size(c.att.TableContent,2);

if c.att.SingleValueMode
   numRenderColumns=2*numContentColumns;
   numSavedColumns=2*numContentColumns;
else
   numRenderColumns=numContentColumns;
   numSavedColumns=numContentColumns*2;
end

if nargout>0
   
   %determine RenderColumn ratios
   %RenderColumns show column widths in whatever mode
   %the user happens to be
   varargout{1}=ProcessColumns(cWidIn,numRenderColumns,c.att.ColWidths);
   
   %determine SavedColumn ratios
   %SavedColumns store column widths in SingleValueMode (double cell)
   %format.  Nargout{2} is a revised version of the component with
   %SavedColumn stored in c.att.ColWidths;
   
   if nargout>1
      c.att.ColWidths=ProcessColumns(cWidIn,numSavedColumns,c.att.ColWidths);
      varargout{2}=c;
   end %if nargout>1
end %if nargout>0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outColWid=ProcessColumns(inColWid,numDesiredColumns,prevColumns);

numInCol=length(inColWid);

if numInCol==numDesiredColumns
   outColWid=inColWid;
elseif numInCol==numDesiredColumns*2
      outColWid=inColWid(1:2:end-1)+inColWid(2:2:end);
elseif numInCol==numDesiredColumns/2
   if length(prevColumns)==numDesiredColumns
      for i=numInCol:-1:1
         currIndex=[i*2-1,i*2];
         outColWid(currIndex)=inColWid(i)*...
            prevColumns(currIndex)/sum(prevColumns(currIndex));
      end
   else
      outColWid(1:2:numDesiredColumns-1)=inColWid*.3;
      outColWid(2:2:numDesiredColumns)=inColWid*.7;
   end
elseif numInCol<numDesiredColumns
   missingColumns=numDesiredColumns-numInCol;
   outColWid=[inColWid mean(inColWid)*ones(1,missingColumns)];
else
   %numInCol>numDesiredColumns
   outColWid=inColWid(1:numDesiredColumns);
end