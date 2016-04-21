function bList=loopfixpt(z,sortBy,blockScope,searchTerms,LoggedOnly)
%LOOPFIXPT
%   BLKLIST= LOOPFIXPT(RPTFPMETHODS,SORTBY,CONTEXT,SEARCHTERMS,LOGOPT)
%            Returns a sorted list of blocks appropriate
%            to the current context.
%   INFO   = LOOPBLOCK(ZSLMETHODS) 
%            Returns a list of SORTBY and CONTEXT values
%            with descriptions of each
%            INFO.sortCode = valid SORTBY values
%            INFO.sortName
%            INFO.contextCode = valid CONTEXT values
%            INFO.contextName
%            INFO.logCode = valid LOGOPT values
%            INFO.logName
%
%
%    See also CSL_BLK_LOOP, CSL_MDL_LOOP

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/10 16:56:31 $

if nargin==1
   bList=loopblock(zslmethods);
   bList.sortName=strrep(bList.sortName,'block','Fixed-Point block');
   bList.contextName={
      'Fixed-Point blocks in current system'
      'Fixed-Point blocks in current model'
      'Fixed-Point blocks connected to current signal'
      'Current block if it is a Fixed-Point block'
      'Fixed-Point blocks in all models'
   };
   bList.logCode={
      '$logged'
      '$unlogged'
      '$all'
   };
   bList.logName={
      'Logged Fixed-Point blocks only'
      'Unlogged Fixed-Point blocks only'
      'All Fixed-Point blocks (logged or unlogged)'
   };
else
   if nargin<5
      LoggedOnly='$all';
      if nargin<4
         searchTerms={};
         if nargin<3
            blockScope='';
         end
      end
   end
   
   zS=zslmethods;
   
   
   vNum=version;
   %vNum='5.3 (R11)';
   if str2num(vNum(1))<6
      %allow this to be used with pre-r12 code
      isPostFilter=1;
   else
      %restrict search to only look for Fixed-Point blocks, but
      %not the Fixed-Point GUI block (since it contains no useful
      %information)
      %searchTerms=[searchTerms,{'MaskType',...
      %         '^Fixed-Point .[^G].[^U].[^I]'}];
      searchTerms=[searchTerms,{'MaskType',...
               '^Fixed-Point '}];
      isPostFilter=0;
   end
   
   bList=loopblock(zS,sortBy,blockScope,searchTerms);
   
   if isPostFilter
      mType=getparam(zS,bList,'MaskType');
      okIndices=strmatch('Fixed-Point ',mType);
      bList=bList(okIndices);
   end
   
   %restrict search to only look for logged blocks
   switch LoggedOnly
   case '$logged'
      mType=getparam(zS,bList,'dolog');
      okIndices=strmatch('on',mType);
      bList=bList(okIndices);
   case '$unlogged'
      mType=getparam(zS,bList,'dolog');
      okIndices=strmatch('off',mType);
      bList=bList(okIndices);
   end

end
