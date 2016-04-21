function usrdata=setcolorframe(usrdata)

% SETCOLORFRAME - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.1 $ $Date: 2004/04/08 21:04:37 $


if ~isempty(usrdata.figure.signalframes)
   for i=1:length(usrdata.figure.signalframes)
      set(usrdata.figure.signalframes(i),'visible','off');
   end;
end;
usrdata.figure.signalframes=[];

j=1;
if ~isempty(usrdata.edit.api.signals2trace)
   for i=1:length(usrdata.edit.api.signals2trace{1,1})
      if strcmp(usrdata.edit.signals2trace{i},usrdata.edit.trigger.signal)==0
         color=usrdata.edit.api.signals2trace{1,2};
         space_between_sigfrm=0.05;
      
         usrdata.figure.signalframes(j) = uicontrol('Parent',usrdata.figures.scope, ...
                                         'Units','normalized', ...
                                         'String', '', ...
                                         'Style', 'text', ...
                                         'Position',[0.01, 0.2+j*space_between_sigfrm, 0.02, .03], ...
                                         'Backgroundcolor', color(i,:),...
                                         'Tag','Pushbutton1');
         textsignm=usrdata.edit.signals2trace{i};
         textsignm(1)=[];
         text=['Signal: ',textsignm];                        
        % text=['Signal: ',usrdata.edit.signals2trace{i}];
         index=find(text=='.');
         text(index)='/';
         set(usrdata.figure.signalframes(j),'ToolTipString', text);  
         j=j+1;
      end;
   end;
end; 

numofframes=length(usrdata.figure.signalframes);

if length(usrdata.edit.api.triggersignal)==3 & usrdata.edit.trigger.mode~=4
   
   colortrigger=usrdata.edit.api.triggersignal{1,2};
   space_between_sigfrm=0.05;
   
   usrdata.figure.signalframes(numofframes+1) = uicontrol('Parent',usrdata.figures.scope, ...
                                    'Units','normalized', ...
                                    'String', '', ...
                                    'Style', 'text', ...
                                    'Position',[0.01, 0.2+(1+numofframes)*space_between_sigfrm, 0.02, .03], ...
                                    'Backgroundcolor', colortrigger(1,:),...
                                    'Tag','Pushbutton1');
                                 
   text=['Trigger: ',usrdata.S.modelname,usrdata.edit.trigger.signal];
   index=find(text=='.');
   text(index)='/';
   set(usrdata.figure.signalframes(numofframes+1),'ToolTipString', text);
end; 
