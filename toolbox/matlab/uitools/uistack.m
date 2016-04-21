function varargout=uistack(Handles,StackOpt,Step)
%UISTACK Restack objects.
%   UISTACK(H) visually raises the visual stacking order of the objects, H. 
%   UISTACK(H,STACKOPT) where STACKOPT is 'up','down','top','bottom'
%   UISTACK(H,STACKOPT,STEP) where STEP is the distance to move 'up' and 'down'
%   applies the stacking option to the handles specified by H. All
%   handles, H, must have the same parent.

%   Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2002/04/15 03:24:53 $ 

error(nargchk(0,1,nargout));
error(nargchk(1,3,nargin));
if ~all(ishandle(Handles)),
  error('Invalid Handles passed to UISTACK');
end
if nargin==1,
  StackOpt='up';
  Step=1;
end
if nargin==2,
  Step=1;
end
if Step<0
    Step = 0;
end

Parent=get(Handles,{'Parent'});
Parent=[Parent{:}];
UParent=unique(Parent);
if length(UParent)>1,
  error('All handles passed to UISTACK must have the same Parent.');
end

% move objects one type by one type
Hrest = Handles;
while ~isempty(Hrest)
    
    % find handles of the same type
    SameType = Hrest(1);
    Type = get(Hrest(1),'type');
    for i=2:length(Hrest)
        if (strcmp(Type,get(Hrest(i), 'type')))
            SameType = [SameType;Hrest(i)];
        end
    end
    
    % keep the rest
    TypeLoc = find(ismember(Hrest,SameType));
    Hrest(TypeLoc) = [];
    
    % change stack order
    NewOrder = getNewOrder(SameType, StackOpt, Step);

    % update stack order
    % For figures, need to do something special
    if isequal(UParent,0),
        for lp=length(NewOrder):-1:1,
            if strcmp(get(NewOrder(lp),'Visible'),'on'),
                figure(NewOrder(lp));
            end
        end
    else,
        AllChildren = allchild(UParent);
        AllChildren(find(ismember(AllChildren,NewOrder))) = NewOrder;
        set(UParent,'Children',AllChildren);
    end    
    
end %while

if nargout,
    varargout{1}=allchild(UParent);
end


% --------------------------------------------------------------------
function NewOrder = getNewOrder(SameType, StackOpt, Step)

NOUSE = -1;

Parent = get(SameType(1),'parent');
Type = get(SameType(1),'type');

Children=findobj(allchild(Parent), 'flat', 'type', Type);
HandleLoc=find(ismember(Children,SameType));

switch StackOpt,
case 'up',
    NewOrder=[ones(Step,1).*NOUSE;Children];
    HandleLoc = HandleLoc + Step;
    for lp=1:length(SameType),
        Idx=HandleLoc(lp);
        NewOrder= [NewOrder(1:Idx-Step-1);NewOrder(Idx);NewOrder(Idx-Step:Idx-1);NewOrder(Idx+1:length(NewOrder))];
    end % for lp
    NewOrder(find(NewOrder == NOUSE)) = [];
    
case 'down',
    NewOrder=[Children;ones(Step,1).*NOUSE];
    for lp=length(SameType):-1:1,
        Idx=HandleLoc(lp);
        NewOrder = [NewOrder(1:Idx-1);NewOrder(Idx+1:Idx+Step);NewOrder(Idx);NewOrder(Idx+Step+1:length(NewOrder))];
    end % for lp
    NewOrder(find(NewOrder == NOUSE)) = [];
    
case 'top',
    % to preserve the child order instead of the input handle order, uncomment the following line
    % SameType = Children(HandleLoc);
    Children(HandleLoc)=[];  
    NewOrder=[SameType;Children];
    
case 'bottom',
    % to preserve the child order instead of the input handle order, uncomment the following line
    % SameType = Children(HandleLoc);
    Children(HandleLoc)=[];  
    NewOrder=[Children;SameType];    
    
otherwise,
    error('Invalid Stack option for UISTACK');      
    
end % switch
