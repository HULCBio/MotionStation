function movemask(ModelName)
%MOVEMASK Restructure masked built-in blocks as masked subsystems.
%   MOVEMASK(ModelName) will look for all masked built-in blocks that are not
%   subsystems or s-functions, place the block in a subsystem and copy
%   the mask and block callbacks to the new subsystem.
%
%   See also HASMASK, HASMASKDLG, HASMASKICON.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $

MaskProperties={'MaskType'
                'MaskDescription'
                'MaskHelp'
                'MaskPromptString'
                'MaskStyleString'
                'MaskVariables'
                'MaskInitialization'
                'MaskDisplay'
                'MaskSelfModifiable'
                'MaskIconFrame'
                'MaskIconOpaque'
                'MaskIconRotate'
                'MaskIconUnits'
                'MaskValueString'
                };
Callbacks={'CopyFcn',
           'DeleteFcn',
           'UndoDeleteFcn',
           'LoadFcn',
           'ModelCloseFcn',
           'PreSaveFcn',
           'PostSaveFcn',
           'InitFcn',
           'StartFcn',
           'StopFcn',
           'NameChangeFcn',
           'ClipboardFcn',
           'DestroyFcn',
           'OpenFcn',
           'CloseFcn',
           'ParentCloseFcn',
           'EvalFcn',
           'MoveFcn',
          };

Other={'Tag',
       'Orientation'
       'BackgroundColor'
       'ForegroundColor'
       'DropShadow'
       'NamePlacement'
       'FontName'
       'FontSize'
       'FontWeight'
       'FontAngle'
       'ShowName'
       'UserData'
      };

Sys=find_system(ModelName,'LookUnderMasks','all'  , ...
                          'Mask'          ,'on'  , ...
                          'LinkStatus'    ,'none'  ...
                          );

maskedFeature=slfeature('masksubsystems');
if maskedFeature==2
  disp('No changes made in your model.')
  disp('Turn the masking feature off before using this function.')
end

if maskedFeature==1,
  if ~isempty(Sys),
    OnDlgParams   = strcmp(get_param(Sys,'MaskPromptString')  ,'');
    OnInitString  = strcmp(get_param(Sys,'MaskInitialization'),'');
    OnHelpText    = strcmp(get_param(Sys,'MaskHelp')          ,'');
    OnDescription = strcmp(get_param(Sys,'MaskDescription')   ,'');
    OnDisplay     = strcmp(get_param(Sys,'MaskDisplay')   ,'');

    MaskOnOnly=OnDlgParams  & OnInitString & ...
        OnHelpText   & OnDescription& OnDisplay;
    Sys(MaskOnOnly)=[];
  end % if ~isempty

  if ~isempty(Sys),
    BlockType=get_param(Sys,'BlockType');
    InportLoc = find(strcmp(BlockType,'Inport'));
    OutportLoc = find(strcmp(BlockType,'Outport'));
    IOLoc = [InportLoc ; OutportLoc];
    for lp=1:length(IOLoc),
      TempName=Sys{lp};
      TempName(TempName==sprintf('\n'))=' ';
      disp(['Block is an inport or outport. Can''t move mask on: ' TempName])
    end

    BlockType(IOLoc) = [];
    Sys(IOLoc) = [];

  end % if ~isempty

  if ~isempty(Sys),
    NonSubSys=Sys(~strcmp(BlockType,'SubSystem') & ~strcmp(BlockType,'S-Function'));
    if ~isempty(NonSubSys),
      set_param(ModelName,'Lock','off')
      for lp=1:length(NonSubSys),
        TempName=NonSubSys{lp};
        TempName(TempName==sprintf('\n'))=' ';
        disp(['Moving mask on: ' TempName])
        Position=get_param(NonSubSys{lp},'Position');
        NewSys=[get_param(NonSubSys{lp},'Parent') '/asdf'];
        add_block('built-in/SubSystem',NewSys,'Position',[1 1 5 5]);
        Properties=[MaskProperties;Callbacks];
        for mlp=1:length(Properties),
          set_param(NewSys, ...
              Properties{mlp},get_param(NonSubSys{lp},Properties{mlp}));
        end
        MaskNames=get_param(NonSubSys{lp},'MaskNames');
        for mlp=1:length(MaskNames),
          set_param(NewSys,MaskNames{mlp}, ...
              get_param(NonSubSys{lp},MaskNames{mlp}));
        end
        set_param(NonSubSys{lp},'Mask','off');
        for mlp=1:length(Callbacks),
          set_param(NonSubSys{lp},Callbacks{mlp},'');
        end
        for mlp=1:length(Other),
          set_param(NewSys,Other{mlp},get_param(NonSubSys{lp},Other{mlp}));
        end
        Width=Position(3)-Position(1);
        Height=Position(4)-Position(2);
        Name=get_param(NonSubSys{lp},'Name');
        SlashName=strrep(Name,'/','//');
        MovedSys=[NewSys '/' SlashName];
        PortInfo=get_param(NonSubSys{lp},'Ports');
        x1=90;x2=x1+Width;
        y1=max(60,40*max(PortInfo(1:2))/2);y2=y1+Height;
        add_block(NonSubSys{lp},MovedSys     , ...
            'Position'    ,[x1 y1 x2 y2], ...
            'Orientation' ,'right'        ...
            );
        delete_block(NonSubSys{lp});
        MidBlockPos = [x1+x2/2 y1+y2/2];
        Offset = (MidBlockPos(2)-PortInfo(1)*30)/2;
        for plp=1:PortInfo(1),
          PortPos = [20 Offset+40*plp 20+20 Offset+40*plp+20];
          PortName=['In' int2str(plp)];
          add_block('built-in/Inport',[NewSys '/' PortName]      , ...
              'Position'       ,PortPos  ...
              );
          add_line(NewSys,[PortName '/1'],[SlashName '/' int2str(plp)])
        end
        Offset = (MidBlockPos(2)-PortInfo(2)*30)/2;
        for plp=1:PortInfo(2),
          PortPos = [x2+30 Offset+40*plp x2+30+20 Offset+40*plp+20];
          PortName=['Out' int2str(plp)];
          add_block('built-in/Outport',[NewSys '/' PortName]      , ...
              'Position'        ,PortPos                      ...
              );
          add_line(NewSys,[SlashName '/' int2str(plp)],[PortName '/1'])
        end
        set_param(NewSys,'Name',Name,'Position',Position);
      end % for lp
    end % if ~isempty
  end % if ~isempty
end %if MaskFeature
