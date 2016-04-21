function varargout=align(Action,varargin)
%ALIGN Align uicontrols and axes.
%   ALIGN(HandleList,HorizontalAlignment,VerticalAlignment) will
%   align the objects in the handle list. Adding a left hand argument
%   will cause the updated positions of the objects to be returned while
%   the position of the objects on the figure does not change.
%   Calling the alignment tool with
%   Positions=ALIGN(CurPositions,HorizontalAlignment,VerticalAlignment)
%   will return the updated position matrix from the initial position
%   matrix.
%
%   Possible values for HorizontalAlignment are:
%     None, Left, Center, Right, Distribute, Fixed
%
%   Possible values for VerticalAlignment are:
%     None, Top, Middle, Bottom, Distribute, Fixed
%
%   All alignment options will align the objects within the
%   bounding box that encloses the objects.  Distribute and Fixed
%   will align objects to the bottom left of the bounding box. Distribute
%   evenly distributes the objects while Fixed distributes the objects
%   with a fixed distance (in points) between them.
%
%   If Fixed is used for HorizontalAlignment or VerticalAlignment, then
%   the distance must be passed in as an extra argument:
%   
%   ALIGN(HandleList,'Fixed',Distance,VerticalAlignment)
%   ALIGN(HandleList,HorizontalAlignment,'Fixed',Distance)
%   ALIGN(HandleList,'Fixed',HorizontalDistance,'Fixed',VerticalDistance)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.22 $ $Date: 2002/04/15 03:24:06 $

switch nargin,

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Alignment Tool does not open %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 3,
    HorizontalAlignment=varargin(1);  
    VerticalAlignment=varargin(2);  
    if strcmp(lower(HorizontalAlignment{:}),'fixed'),
      HorizontalAlignment={'Fixed',0};
    end      
    if strcmp(lower(VerticalAlignment{:}),'fixed'),
      VerticalAlignment={'Fixed',0};
    end      
    HandleList=Action;
    Position=LocalAlign(HandleList,HorizontalAlignment, ...
                        VerticalAlignment,~nargout);
    
    if nargout,varargout(1)={Position};end
    

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Alignment Tool does not open %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    if isstr(varargin{2}),    
      HorizontalAlignment=varargin(1);  
      VerticalAlignment=varargin(2:3);
    else,
      HorizontalAlignment=varargin(1:2);  
      VerticalAlignment=varargin(3);
    end
            
    HandleList=Action;
    Position=LocalAlign(HandleList,HorizontalAlignment, ...
                        VerticalAlignment,~nargout);
    
    if nargout,varargout(1)={Position};end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Alignment Tool does not open %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 5,
    HorizontalAlignment=varargin(1:2);  
    VerticalAlignment=varargin(3:4);  
    HandleList=Action;
    Position=LocalAlign(HandleList,HorizontalAlignment, ...
                        VerticalAlignment,~nargout);
    
    if nargout,varargout(1)={Position};end
    

  %%%%%%%%%%%%%
  %%% Error %%%
  %%%%%%%%%%%%%
  otherwise,
    error('Wrong number of input arguments for ALIGN');

end % switch nargin



%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalAlign %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function varargout= LocalAlign(HandleList,HorizontalAlignment, ...
                                VerticalAlignment,SetFlag);
% Calculate alignment

%%% set all units to points
if all(ishandle(HandleList))&~isempty(HandleList), % Handles passed in
  AllHandles=HandleList;
  HandleList=LocalGetValidHandles(AllHandles);
  NumObjs=size(HandleList,1);
  HandleFlag=1;
  Units=get(HandleList,{'Units'});
  set(HandleList,'Units','points');
  Pos=get(HandleList,{'Position'});
  Position=cat(1,Pos{:});

else,
  NumObjs=size(HandleList,1);
  HandleFlag=0;
  Position=HandleList;

end % if all

if ~isempty(Position),
  HPos=LocalGetHorizontalPosition(Position,HorizontalAlignment);   
  VPos=LocalGetVerticalPosition(Position,VerticalAlignment);   
  Position=[HPos(:,1) VPos(:,2) HPos(:,3) VPos(:,4)];
end % if ~isempty

if HandleFlag,
  if ~SetFlag,
    OldPos=get(HandleList,{'Position'});
  end % if ~SetFlag
  
  %% convert from matrix to cell array
  TempPos=num2cell(Position,2);
  set(HandleList,{'Position'},TempPos);
  
  %%% set all units back to previous value and get new position matrix
  set(HandleList,{'Units'},Units);

  Pos=get(HandleList,{'Position'});Position=cat(1,Pos{:});

  if ~SetFlag,
    clear Position
    Pos=get(HandleList,{'Position'});Position=cat(1,Pos{:});
    %%% This line sets units to points, replaces the original positions
    %%% and then sets the units back to the original value.
    set(HandleList,'Units','points',{'Position'},OldPos,{'Units'},Units);
  end % if ~SetFlag
  
end % if HandleFlag

if nargout, 
  varargout(1)={Position};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetValidHandles %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewHandles=LocalGetValidHandles(HandleList);          
% Make sure all handles are valid

NewHandles=HandleList(ishandle(HandleList));
if ~isempty(NewHandles),  
  TypeList=get(NewHandles,{'Type'});
  Loc=[strmatch('axes',TypeList);strmatch('uicontrol',TypeList)];
  NewHandles=NewHandles(Loc);  
end  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetHorizontalPosition %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Position=LocalGetHorizontalPosition(Position,Alignment)
% Determine new horizontal positions
Align=Alignment{1};

switch lower(Align),
  case 'left',
    Position(:,1)=min(Position(:,1));
    
  case 'center',
    MinVal=min(Position(:,1));
    MaxVal=max(sum(Position(:,[1 3])'));
    CtrVal=(MinVal+MaxVal)/2;
    Position(:,1)=CtrVal-Position(:,3)/2;
    
  case 'right',
    MaxVal=max(sum(Position(:,[1 3])'));
    Position(:,1)=MaxVal-Position(:,3);
    
  case 'distribute',
    Gap=LocalCalcGap(Position,1);
    Position=LocalCalcPos(Position,Gap,1);
      
  case 'fixed',
    Gap=Alignment{2};
    Position=LocalCalcPos(Position,Gap,1);
            
end % switch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetVerticalPosition %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Position=LocalGetVerticalPosition(Position,Alignment)
% Determine new vertical positions

Align=Alignment{1};

switch lower(Align),
  case 'top',
    MaxVal=max(sum(Position(:,[2 4])'));
    Position(:,2)=MaxVal-Position(:,4);
    
  case 'middle',
    MinVal=min(Position(:,2));
    MaxVal=max(sum(Position(:,[2 4])'));
    CtrVal=(MinVal+MaxVal)/2;
    Position(:,2)=CtrVal-Position(:,4)/2;
    
  case 'bottom',
    Position(:,2)=min(Position(:,2));
    
  case 'distribute',
    Gap=LocalCalcGap(Position,2);
    Position=LocalCalcPos(Position,Gap,2);
      
  case 'fixed',
    Gap=Alignment{2};
    Position=LocalCalcPos(Position,Gap,2);
      
end % switch


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCalcPos %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function NewPosition=LocalCalcPos(Position,Gap,HV);
% Calculate compress gaps positions

[TempPos,Index]=sortrows(Position,HV);
NumObjs=size(TempPos,1);
%% V5 LPD This could be sped up
for ObjLp=2:NumObjs,
  TempPos(ObjLp,HV)=sum(TempPos(ObjLp-1,[HV HV+2])')+Gap;
end
[junk,UnsortIndex]=sort(Index);
NewPosition=TempPos(UnsortIndex,:);


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCalcGap %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Gap=LocalCalcGap(Position,HV)
% Calculate distribute gaps positions

MinVal=min(Position(:,HV));
MaxVal=max(sum(Position(:,[HV HV+2])'));
NumObjs=size(Position,1);
Width=sum(Position(:,HV+2));
Gap=(MaxVal-MinVal-Width)/(NumObjs-1);

