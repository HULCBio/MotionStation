function muei
% MEUI - Mask Initialization for all PCI boards by UEI
% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/06/17 12:12:29 $

% collect information accross blocks


blocks= find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','RegExp','on','MaskType', '^uei');

% create signature, define field using signature, assign fields and values

info=[];

boards={};
boardIndex=[];

maskValues= get_param(blocks,'MaskValues');
maskTypes=get_param(blocks, 'MaskType');
k=-1;
for i=1:length(blocks)
    % create signature
    maskType=maskTypes{i};
    index= find(maskType=='_');
    numIndex= str2num(maskType(index(end)+1:end));
    boardSection= maskType(index(1)+1:index(2)-1);
    tmp= maskValues{i}{1};
    tmp(find(tmp=='-'))=[];
    tmp(find(tmp=='/'))=[];
    signature= tmp;
    try
        pciSlot= eval([maskValues{i}{numIndex},';']);
    catch
        error('PCI slot cannot be evaluated');
    end
    if length(pciSlot)==2
        pciSlot=1000*pciSlot(1)+pciSlot(2);
    end
    tmp='';
    if pciSlot>=0
        tmp= num2str(pciSlot);
    end
    board= [signature,'b',tmp];
    signature= [signature, boardSection, 'b', tmp];
    % create signature field if necessary
    if isfield(info, signature)
        error('Only one block instance per physical board supported');
    end
    index= strmatch(board, boards);
    if isempty(index)
        k=k+1;
        boards= [boards, {board}];
        maxindex=k;
    end
    boardIndex= [boardIndex, maxindex];
    eval(['info.',signature,'= 1;']);
end


for i=1:length(blocks)
    set_param(blocks{i},'UserData',boardIndex(i));
end    

% update the xpc_rtwmakecfg_data parameter of the current model to signal
% that the xpcuei lib will be needed for the build

try
    data = get_param(bdroot, 'xpc_rtwmakecfg_data');
catch
    data = '';
    add_param(bdroot, 'xpc_rtwmakecfg_data', data);
end

if isempty( strfind(data, '_xpcuei_') )
    set_param(bdroot, 'xpc_rtwmakecfg_data', [data '_xpcuei_']);
end

