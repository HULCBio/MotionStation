function xpctgboxdl(applicationame)
% This is a simple script that downloads the Stand Application into the
% xPCTargetBox. This function is designed to be used for ftp server that
% is distributed with xPCTargetBox. xPCTargetBox must be setup to run the
% ftp server on reboot for this function to work.
%Usage:
% xpctgboxdl('applicationame') will try connect and download the
% standalone application. If there is an application running the target
% will be rebooted.

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/08 21:03:32 $


p=pwd;
try
    % Try if the xPCTargetBox is responding
    address=getxpcenv('TCPIPTargetAddress');
    [a,b]=dos(['ping',' ',address,'']);
    
    if(~isempty(findstr(b,'TTL')))
        dosping=1;
    else
        dosping=0;
    end
    if(dosping==0)
        error('Target is not reachable')
    end
   % OK if it responds 
    if(dosping)
        status=xpctargetping;
        if(strmatch('success',status,'exact'))
            tg=xpc;
            tg.reboot;
            disp('Rebooting the xPC Target ...');
            tic;
            t=toc;
            [result,echo]=dos(['ping',' ',address,'']);
            while(~length(strfind(echo,'TTL'))||a<100)
                [result,echo]=dos(['ping',' ',address,'']);
                t=toc;
                if(length(strfind(echo,'TTL')))
                    a=100;
                end
            end
        end
      % Common fall trough   
        p=pwd;
        cd([applicationame,'_xpc_emb']);
        fid=fopen('ftp.scr','wt');
        s=sprintf('open %s  \n', address);
        fprintf(fid,s);
        fprintf(fid,'prompt\n');
        fprintf(fid,'bin\n');
        fprintf(fid,'put *.rtb\n');
        fprintf(fid,'put *.bat\n');
        fprintf(fid,'bye\n');
        fclose(fid);
        disp('Downloading the standalone application ...');
        [a,b]=dos('ftp -s:ftp.scr');
        if(a~=0)
            error(b)
        else
            disp('Done');
        end
        cd(p);
        
    end
    
    
    
catch
    cd(p);
    disp('Unexpected error in communication.The Standalone application cannot be downloaded')
    
end



