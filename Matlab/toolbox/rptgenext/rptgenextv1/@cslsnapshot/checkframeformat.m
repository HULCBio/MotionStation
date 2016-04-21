function [warnStr,c]=checkframeformat(c,imgInfo)
%CHECKFRAMEFORMAT returns true if the image format works with printframes
%   WARNSTR=CHECKFRAMEFORMAT(C)
%   [WARNSTR,C]=CHECKFRAMEFORMAT(C) sets c.att.isPrintFrame
%     to "0" if the current format is bad.
%
%   can also call with CHECKFRAMEFORMAT(C,IMGINFO)
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:51 $

warnStr='';
if c.att.isPrintFrame
   if nargin<2
      imgInfo=getimgformat(c.rptcomponent,c.att.format);
   end
   
   badList={
      'dwin'
      'dmeta'
      'dhpgl'
      'dill'
      'dmfile'
      'dbitmap'
  };
   
   badFormatName='';
   i=1;
   badListLength=length(badList);
   isBad=logical(0);
   while ~isBad & i<=badListLength
      if length(findstr(imgInfo.driver,badList{i}))>0
         badFormatName=badList{i};
         isBad=logical(1);
      else
         i=i+1;
      end
   end
   
   if isBad
      warnStr=sprintf('Warning - format "%s" can not be used with printframes.',...
	   imgInfo.name);
      if nargout>1
         c.att.isPrintFrame=logical(0);
      end
   end
end

   
