function out=execute(c)
%EXECUTE returns a string during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:00 $

%<BookInfo>
%    <Title>
%    </Title>
%    <Subtitle>
%    </Subtitle>
%    <Author>
%      <Honorific>
%      <FirstName>
%      <Surname>
%    </Author>
%    <Date>
%    </Date>
%    <Copyright>
%      <Holder>
%      </Holder>
%      <Year>
%      </Year>
%    </Copyright>
%    <Abstract>
%      <Para>
%      </Para>
%    </Abstract>
%  <LegalNotice>
%    <Para>
%    </Para>
%  </LegalNotice>
%</BookInfo>

if strcmpi(c.rptcomponent.DocBookDoctype,'Sect1')
   out='';
   status(c,[sprintf('Warning - Title Page can only be used with document type "Book".  '),...
         sprintf('Setup file must contain a Chapter/Subsection component.')],2);
   return
end


Title=set(sgmltag, ...
    'tag','Title', ...
    'data',parsevartext(c.rptcomponent,c.att.Title));

Subtitle=set(sgmltag, ...
    'tag','Subtitle', ...
    'data',parsevartext(c.rptcomponent,c.att.Subtitle));

FirstName=set(sgmltag, ...
    'tag','FirstName', ...
    'data',parsevartext(c.rptcomponent,c.att.Author));

Author=set(sgmltag,'tag','Author','data',FirstName);

tpData={Title Subtitle Author};

if ~isempty(c.att.Image)
	imgComponent=c.rptcomponent.comps.cfrimage;
   
   imgComponent.att.FileName=c.att.Image;
   imgComponent.att.isTitle='none';
   imgComponent.att.isInline=logical(0);
   
   tpData{end+1} = runcomponent(imgComponent,5);
end


if c.att.Include_Date,
   tpData{end+1}=set(sgmltag,'tag','Date','data',datestr(now,c.att.DateFormat));
end

if c.att.Include_Copyright
   yrString=parsevartext(c.rptcomponent,c.att.Copyright_Date);
   if isempty(yrString)
       dateNum=clock;
       yrString=sprintf('%i',dateNum(1));
   end
   Year=set(sgmltag, ...
      'tag','Year', ...
      'data',yrString);
   
   if ~isempty(c.att.Copyright_Holder)
      Holder=set(sgmltag, ...
         'tag','Holder', ...
         'data',parsevartext(c.rptcomponent,c.att.Copyright_Holder));
      copyrightData={Year Holder};
   else
      copyrightData=Year;
   end
   
   tpData{end+1}=set(sgmltag,'tag','Copyright','data',copyrightData);
end

if ~isempty(c.att.Abstract)
   AbstractPara=set(sgmltag, ...
      'tag','Para', ...
      'data',parsevartext(c.rptcomponent,c.att.Abstract));
   tpData{end+1}=set(sgmltag, ...
      'tag','Abstract', ...
      'data',AbstractPara);
end
 
 if ~isempty(c.att.Legal_Notice)
    LegalNoticePara=set(sgmltag, ...
       'tag','Para', ...
       'data',parsevartext(c.rptcomponent,c.att.Legal_Notice));
    tpData{end+1}=set(sgmltag, ...
       'tag','LegalNotice', ...
       'data',LegalNoticePara);
 end
    
%BookInfo
out=set(sgmltag,'tag','BookInfo','data',tpData);