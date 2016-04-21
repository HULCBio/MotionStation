function setstyle(h, Style_Switch)
%  SETSTYLE  Updates the colors for the response objects
%  
%  Style_Switch determines which mode the response lines will
%  be differentiated.  The options are 'color', 'linestyle', and
%  'marker'.   

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:46 $

if nargin == 1
    Style_Switch = 'color';
end  
   
% Set Color Property
numC = 8; % Number of Colors
CVals = rguicolors(numC);
numM = 8; % Number of Line Marker Styles
MVals = {'none';'x';'o';'+';'*';'s';'d';'p'};
numL = 4; % Number of Line Styles
LVals = {'-';'--';'-.';':'};

UnSet = [];
Used_Colors = [];
Used_LineStyle = [];
Used_MarkerStyle = [];

% Find unspecified plot styles
for i = 1:length(h.Responses)
    if ~isempty(h.Responses(i,1).Style)
        Used_Colors = [Used_Colors; h.Responses(i,1).Style.Color];
        Used_LineStyle = [Used_LineStyle; h.Responses(i,1).Style.LineStyle];
        Used_MarkerStyle = [Used_MarkerStyle; h.Responses(i,1).Style.MarkerStyle];
    else
        UnSet = [UnSet; h.Responses(i,1)];
    end
end    

% Put unused styles upfront to avoid duplicate styles
if any(any(Used_Colors)), 
    switch Style_Switch,
    case 'color',
        CVals = LocalReorder(CVals,Used_Colors);
    case 'linestyle',
        LVals = LocalReorder(LVals,Used_LineStyle);
    case 'marker',
        MVals = LocalReorder(MVals,Used_MarkerStyle);
    end
end

n = length(UnSet);

if n~=0
    switch Style_Switch
    case 'color'
        for idx = 1:n
            nc = length(UnSet(idx).View);
            % Compensate for wrapping the colors
            idx = idx - floor(idx/numC)*(numC-1);            
            UnSet(idx).Style = struct('Color', CVals{idx,1},...
                'LineStyle','-',...
                'MarkerStyle','none');     
            for idc = 1:nc    
                set(UnSet(idx).View(idc).Curves,'Color',CVals{idx,1})
                set(UnSet(idx).View(idc).Curves,'LineStyle','-')
                set(UnSet(idx).View(idc).Curves,'Marker','none')
            end    
        end
    case 'linestyle'
        for idx = 1:n
            nc = length(UnSet(idx).View); 
            % Compensate for wrapping the linestyles
            idx = idx - floor(idx/(numL+1))*(numL);            
            UnSet(idx).Style = struct('Color', CVals{1,1},...
                'LineStyle',LVals{idx},...
                'MarkerStyle','none');       
            for idc = i:nc
                set(UnSet(idx).View(idc).Curves,'Color',CVals{1,1})
                set(UnSet(idx).View(idc).Curves,'LineStyle',LVals{idx,1});
                set(UnSet(idx).View(idc).Curves,'Marker','none')
            end
        end
    case 'marker'
        for idx = 1:n 
            nc = length(UnSet(idx).View);
            % Compensate for wrapping the linestyles
            idx = idx - floor(idx/(numM+1))*(numM);            
            UnSet(idx).Style = struct('Color', CVals{1,1},...
                'LineStyle','-',...
                'MarkerStyle',MVals{idx});            
            for idc = 1:nc
                set(UnSet(idx).View(idc).Curves,'Color',CVals{1,1})
                set(UnSet(idx).View(idc).Curves,'LineStyle','-')
                set(UnSet(idx).View(idc).Curves,'Marker',MVals{idx,1});
            end
        end
    end
end

%----------------- Local functions --------------------

function List = LocalReorder(List,UsedStyles)

if ~isempty(UsedStyles)
   if isa(UsedStyles,'cell')
      % Linestyle or marker
      InUse = ismember(List,UsedStyles);
   else
      % Colors
      nc = size(List,1);
      InUse = logical(zeros(nc,1));
      for i=1:nc
         RGBColor = List{i,1};
         InUse(i) = any(max(abs(UsedStyles - RGBColor(ones(size(UsedStyles,1),1),:)),[],2) < 0.05);
      end
   end
   
   List = [List(~InUse,:) ; List(InUse,:)];
end