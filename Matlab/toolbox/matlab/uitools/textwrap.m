function [OutString,varargout]=textwrap(varargin)
%TEXTWRAP Return wrapped string matrix for given UI Control.
%  OUTSTRING=TEXTWRAP(UIHANDLE,INSTRING) returns a wrapped
%  string cell array (OUTSTRING) that fits inside the given uicontrol. 
%
%  OUTSTRING is the wrapped string matrix in cell array format.
%  
%  UIHANDLE is the handle of the object the string is placed in.
%  
%  INSTRING is a cell array. Paragraph breaks are implemented for 
%  each cell.  Each cell of the array is considered to be a separate
%  paragraph and must only contain a string vector.  If the 
%  paragraph is carriage return delimited, TEXTWRAP will wrap the 
%  paragraph lines at the carriage returns.
%
%  OUTSTRING=TEXTWRAP(INSTRING, COLS) returns a wrapped string cell 
%  array whose lines are wrapped at COLS if the paragraph is not 
%  carriage return delimited. If a paragraph does not have COLS 
%  characters, the text in the paragraph will not be wrapped. 
%  
%  May also be called as:
%  [OUTSTRING,POSITION]=TEXTWRAP(UIHANDLE,INSTRING) where POSITION is 
%  the recommended position of the uicontrol in the units of the 
%  uicontrol.  [OUTSTRING,POSITION]=TEXTWRAP(UIHANDLE,INSTRING,COLS) will
%  also work.  For this case, OUTSTRING will be wrapped at COLS and the
%  recommended position will be returned.

%  Loren Dean 
%   Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.24 $

if nargout<1|nargout>2,
  error('TEXTWRAP requires 1 or 2 output arguments.');
end
error(nargchk(2,3,nargin));
if nargin==3,
  UIHandle=varargin{1};
  if iscell(varargin{2}),     
    InString=varargin{2};
  else,
    error('Second input argument must be a cell array when using 3 inputs');
  end % if iscell
    
  Columns=varargin{3};
  
else,
  if isnumeric(varargin{1}),
    UIHandle=varargin{1};
    InString=varargin{2};
    Columns=[];    
  elseif iscell(varargin{1}),
    UIHandle=[];
    InString=varargin{1};
    Columns=varargin{2};
  else,
    error('First input argument must be a handle or cell array.');
    
  end % if isnumeric
end

if ~isempty(UIHandle),
  if ~ishandle(UIHandle),error('Invalid handle passed to TEXTWRAP.');end    
  UIPosition=get(UIHandle,'Position');
  UIWidth=UIPosition(3);
  UIHeight=UIPosition(4);

  TempObj=copyobj(UIHandle,get(UIHandle,'Parent'));
  set(TempObj,'Visible','off','Max',100);
end % if ~isempty

NumPara=prod(size(InString));
OutString={};
ReturnChar=sprintf('\n');

for lp=1:NumPara,
  Para=InString{lp};  

  if isempty(Para),
    NumNewLines=0;
    OutString=[OutString;{' '}];
    
  else,
    Loc=find(Para==ReturnChar);
    TempPara={};
    if ~isempty(Loc),
      Loc=[0 Loc length(Para)+1];
      for lp=length(Loc)-1:-1:1,
        TempPara{lp,1}=Para(Loc(lp)+1:Loc(lp+1)-1);
      end        
    else,
      TempPara=Para; 
    end  
    Para=cellstr(TempPara);
    
    NumNewLines=size(Para,1);
        
  end % if isempty

  for LnLp=1:NumNewLines,  
    if ~isempty(Columns),
      WrappedCell=LocalWrapAtColumn(Para{LnLp,1},Columns);
    else,
      WrappedCell=LocalWrapAtWidth(Para{LnLp,1},TempObj,UIWidth);   
    end % if        
    OutString=[OutString;WrappedCell];
  end % for LnLp
end % for NumPara

if ~isempty(UIHandle),
  set(TempObj,'String',OutString);
  Extent=get(TempObj,'Extent');
  Position=[UIPosition(1:2) Extent(3:4)];
  delete(TempObj);

else,
  Position=[0 0 0 0];  
end % if ~isempty

if nargout==2,varargout{1}=Position;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetWrapLoc %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WrapLoc=LocalGetWrapLoc(Para,Columns)

Width=size(Para,2);
if isequal(Width,0)|isempty(Columns),
  WrapLoc=[];
else,  
  Para=[Para ' '];  
  Locs=find(Para==' ');  
  WrapLoc=Locs(find(Locs<=Columns));
  % Need to take care of the case where the word is wider than the width
  if isempty(WrapLoc),
    WrapLoc=Columns;
  end
end % if  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalWrapAtColumn %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WrappedCell=LocalWrapAtColumn(Para,Columns)

WrappedCell={''};
LineNo=1;
WrapLoc=LocalGetWrapLoc(Para,Columns);
while ~isempty(WrapLoc),  
  LocHigh=WrapLoc(end);  
  if LocHigh>length(Para),
    LocHigh=length(Para);
  end    
  WrappedCell{LineNo,1}=Para(1:LocHigh);
  Para(1:LocHigh)=[];
  Para=fliplr(deblank(fliplr(Para)));  
  WrapLoc=LocalGetWrapLoc(Para,Columns);
  LineNo=LineNo+1;
end % while  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalWrapAtWidth %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WrappedCell=LocalWrapAtWidth(Para,TempObjHandle,UIWidth)

Width=size(Para,2);
Para=[Para ' '];
SpaceLocs=[find(Para==' ')];
WrappedCell={};

if ~isempty(SpaceLocs),
  EndOfPara=logical(0);  
  NeedToWrapLine=logical(0);
  LocLowIndex=0;    LocHighIndex=1;  
  LocLow=1;         LocHigh=SpaceLocs(LocHighIndex)-1;  
  while ~EndOfPara,  
    while ~NeedToWrapLine,
      TrialString=Para(LocLow:LocHigh);
      set(TempObjHandle,'String',TrialString);
      TempExtent=get(TempObjHandle,'Extent');
      NeedToWrapLine=TempExtent(3)>=UIWidth;
      if ~NeedToWrapLine,
        if LocHighIndex==length(SpaceLocs),
          NeedToWrapLine=logical(1);
        else,
          LocHighIndex=LocHighIndex+1;
          LocHigh=SpaceLocs(LocHighIndex)-1;
        end % if LocHighIndex 
      else,
        % Check that the number of words is >1       
        if (LocHighIndex-LocLowIndex)>1,
          LocHighIndex=LocHighIndex-1;
          LocHigh=SpaceLocs(LocHighIndex)-1;        
        end % if
      end % if ~NeedToWrapLine      
    end % while ~NeedToWrapLine 
    WrappedCell=[WrappedCell;{Para(LocLow:LocHigh)}];

    LocLowIndex=LocHighIndex;
    LocHighIndex=LocHighIndex+1;

    LocLow=SpaceLocs(LocLowIndex)+1;
    if LocHighIndex<=length(SpaceLocs),
      LocHigh=SpaceLocs(LocHighIndex)-1;
      NeedToWrapLine=logical(0);
    else,
      EndOfPara=logical(1);
    end % if
  end % while ~EndOfPara  
% There are no spaces in the text so it can't be wrapped.  
else,  
  WrappedCell={Para};
  
end % if ~isempty



