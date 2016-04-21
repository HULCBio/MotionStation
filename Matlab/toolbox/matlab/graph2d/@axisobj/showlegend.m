function A = showlegend(A, varargin)
%AXISOBJ/SHOWLEGEND Show axisobj legend
%   This file is an internal helper function for plot annotation.

%   domethod(A,'showlegend')  toggles the legend for axisobj A
%   domethod(A,'showlegend','on')  creates or sets legend
%       visibility on for axisobj A
%   domethod(A,'showlegend','off')  sets legend does nothing or
%       visibility off for axisobj A
%   domethod(A,'showlegend','reset')  calls legend off
%       for axisobj A

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:11:48 $

HG = get(A,'MyHGHandle');
switch nargin
case 1
   newstate = '';  % toggle state
case 2
   newstate = varargin{1};
end

if strcmp(newstate,'reset')
   legend(HG,'off');
   return
end

legendHandle = legend(HG);
   
if ~isempty(legendHandle)
   % legend already exists
   children = get(legendHandle,'Children');
   if isempty(newstate) % showlegend(A)  toggle visibility
      if strcmp('on',get(legendHandle,'Visible'))
         newstate = 'off';
      else
         newstate = 'on';
      end
   end

   set([legendHandle; children],'Visible',newstate);

else % no legend exists for this axis
   if isempty(newstate)
      newstate = 'on';
   end
  
   if strcmp(newstate,'on')
%       dataObjects = flipud(get(A,'Children'));
        dataObjects = getchildren(HG);
      if isempty(dataObjects)
         errordlg('Can not add a legend to an empty plot.');
      else
         for i = 1:length(dataObjects)
            tag = get(dataObjects(i),'Tag');
            if ~isempty(tag)
               dataNames{i} = tag;
            else
               dataNames{i} = ['data' num2str(i)];
            end
         end
         legend(HG,dataNames{:});
      end
   end
end

%--------------------------------
function Kids = getchildren(ha)
%GETCHILDREN Get children that can have legends
%   Note: by default, lines get labeled before patches;
%   patches get labeled before surfaces.

linekids = findobj(ha,'type','line');
surfkids = findobj(ha,'type','surface');
patchkids = findobj(ha,'type','patch');

if ~isempty(linekids)
    goodlk = ones(1,length(linekids));
    for i=1:length(linekids)
        if ( (isempty(get(linekids(i),'xdata')) | isallnan(get(linekids(i),'xdata'))) & ...
                (isempty(get(linekids(i),'ydata')) | isallnan(get(linekids(i),'ydata'))) & ...
                (isempty(get(linekids(i),'zdata')) | isallnan(get(linekids(i),'zdata'))) )
            goodlk(i) = 0;
        end
    end
    linekids = linekids(logical(goodlk));
end

if ~isempty(surfkids)
    goodsk = ones(1,length(surfkids));
    for i=1:length(surfkids)
        if ( (isempty(get(surfkids(i),'xdata')) | isallnan(get(surfkids(i),'xdata'))) & ...
                (isempty(get(surfkids(i),'ydata')) | isallnan(get(surfkids(i),'ydata'))) & ...
                (isempty(get(surfkids(i),'zdata')) | isallnan(get(surfkids(i),'zdata'))) )
            goodsk(i) = 0;
        end
    end
    surfkids = surfkids(logical(goodsk));
end

if ~isempty(patchkids)
    goodpk = ones(1,length(patchkids));
    for i=1:length(patchkids)
        if ( (isempty(get(patchkids(i),'xdata')) | isallnan(get(patchkids(i),'xdata'))) & ...
                (isempty(get(patchkids(i),'ydata')) | isallnan(get(patchkids(i),'ydata'))) & ...
                (isempty(get(patchkids(i),'zdata')) | isallnan(get(patchkids(i),'zdata'))) )
            goodpk(i) = 0;
        end
    end
    patchkids = patchkids(logical(goodpk));
end

Kids = flipud([surfkids ; patchkids ; linekids]);

%----------------------------
function allnan = isallnan(d)

nans = isnan(d);
allnan = all(nans(:));

%----------------------------


