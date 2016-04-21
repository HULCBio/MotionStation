function mpc_guimask(eventSrc, eventData, action, param1, param2)
% MPC_GUIMASK Manages GUI/Mask interaction through listeners

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:54 $

switch action
%     case 'remove'
%         mpcobjlist = get(eventSrc.getChildren,{'Label'});
% 
%         % Controller was not deleted yet, so must remove name from list
%         nameremoved=eventData.Child.Label;
%         j=length(mpcobjlist);
%         while j>1,
%             if strcmp(mpcobjlist{j},nameremoved),
%                 mpcobjlist(j)=[];
%                 j=0;
%             end
%             j=j-1;
%         end
%         try
%             % Here param1=popBoxObj
%             set(param1,'String',mpcobjlist);
%         end
% 
%     case 'add'
%         mpcobjlist = get(eventSrc.getChildren,{'Label'});
%         try
%             % Here param1=popBoxObj
%             set(param1,'String',mpcobjlist);
%         end

    case 'update'
        try
            mpcobjlist = eventData.NewValue;
            % Here param1=popBoxObj
            set(param1,'String',mpcobjlist);
        end
    case 'destroy'
        % Listener when MPC object from the editBox is edited in the GUI 
        try
            
            % % The MPCobject was updated in the .MPCobject field
            % mpc2=eventSrc.MPCobject;

            mpc2=eventSrc.getController;

            % Here param1=editBoxObj
            mpcname=get(param1,'String');
            mpc1=evalin('base',mpcname);
            
             if ~compare(mpc1,mpc2),
                yesno=questdlg(sprintf(...
                    'Do you want to export MPC controller "%s" to workspace ?',...
                    mpcname),...
                    'Export MPC controller to workspace','Yes','No','Yes');
                if strcmp(yesno,'Yes'),
                    assignin('base',mpcname,mpc2);
                end
            end
        end
    case 'lin_destroy'
        % Listener when MPC object created from linearization and stored in
        % the editBox is edited in the GUI 
        try
            % Here param1=editBoxObj
            mpcname=get(param1,'String');
            % (JGO) modifed to use getController
            mpc2=eventSrc.getController;
            yesno=questdlg('Do you want to export the MPC controller to workspace ?',...
                'Export MPC controller to workspace','Yes','No','Yes');
            if strcmp(yesno,'Yes'),
                assignin('base',mpcname,mpc2);
            else
                % Return to previous state
                set(param1,'String','');
                % Here param2=blk
                set_param(param2,'mpcobj','');
            end
        end
end
