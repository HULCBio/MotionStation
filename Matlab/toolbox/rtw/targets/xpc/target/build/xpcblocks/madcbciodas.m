function [gain, offset, control]=madcbciodas(flag, channel, range, mux, ref, boardType)

% MADCBCIODAS - InitFcn and Mask Initialization for CB PCI-CIO (ISA) series A/D section

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2003/05/19 15:56:45 $

persistent pool

if flag==1
   pool=[];
   return
end

if flag==2

   maxChannel=16;

   switch boardType
   case 1
      maskdisplay='disp(''CIO-DAS16/JR\nComputerBoards\n';
      description='CIO-DAS16/JR';
      supRange=[-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25];
      supRangeStr='-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25';
      supControl=[8, 0, 1, 2, 3, 4, 5, 6, 7];
      resolution=12;
   case 2
      maskdisplay='disp(''CIO-DAS1601/12\nComputerBoards\n';
      description='CIO-DAS1601/12';
      supRange=[-10, -1, -0.1, -0.01, 10, 1, 0.1, 0.01];
      supRangeStr='-10, -1, -0.1, -0.01, 10, 1, 0.1, 0.01';
      supControl=[0, 1, 2, 3, 0, 1, 2, 3];
      resolution=12;
   case 3
      maskdisplay='disp(''CIO-DAS1602/12\nComputerBoards\n';
      description='CIO-DAS1602/12';
      supRange=[-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25];
      supRangeStr='-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25';
      supControl=[0, 1, 2, 3, 0, 1, 2, 3];
      resolution=12;
   case 4
      maskdisplay='disp(''CIO-DAS16/330\nComputerBoards\n';
      description='CIO-DAS16/300';
      supRange=[-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25];
      supRangeStr='-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25';
      supControl=[8, 0, 1, 2, 3, 4, 5, 6, 7];
      resolution=12;
   case 5
      maskdisplay='disp(''PC104-DAS16JR/12\nComputerBoards\n';
      description='PC104-DAS16JR/12';
      supRange=[-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25];
      supRangeStr='-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25';
      supControl=[8, 0, 1, 2, 3, 4, 5, 6, 7];
      resolution=12;
   case 6
      maskdisplay='disp(''CIO-DAS16JR/16\nComputerBoards\n';
      description='CIO-DAS16JR/16';
      supRange=[-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25];
      supRangeStr='-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25';
      supControl=[0, 1, 2, 3, 4, 5, 6, 7];
      resolution=16;
   case 7
      maskdisplay='disp(''CIO-DAS1602/16\nComputerBoards\n';
      description='CIO-DAS1602/16';
      supRange=[-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25];
      supRangeStr='-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25';
      supControl=[0, 1, 2, 3, 0, 1, 2, 3];
      resolution=16;
   case 8
        maskdisplay='disp(''PC104-DAS16JR/16\nComputerBoards\n';
      description='PC104-DAS16JR/16';
      supRange=[-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25];
      supRangeStr='-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25';
      supControl=[0, 1, 2, 3, 4, 5, 6, 7];
      resolution=16;
   end


   maskdisplay=[maskdisplay,'Analog Input'');'];
   for i=1:channel
        maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(i),''');'];
   end
   set_param(gcb,'MaskDisplay',maskdisplay);

   maskdescription=[description,10,'ComputerBoards',10,'Analog Input'];
   set_param(gcb,'MaskDescription',maskdescription);


   boardtype=['btype',num2str(boardType)];
   boardref='ref';
   boardref=[boardref,num2str(ref)];

   if ~isfield(pool,boardtype)
      eval(['pool.',boardtype,'=[];']);
   end
   level1=getfield(pool,boardtype);
   if ~isfield(level1,boardref)
      eval(['level1.',boardref,'.chUsed=0;']);
   else
      error('only one block per physical board allowed');
   end
   level2=getfield(level1,boardref);

   if size(channel,1)~=1 | size(channel,2)~=1
      error('Channel argument must be a scalar');
   end
   if size(range,1)~=1 | size(range,2)~= 1
      error('Range argument must be a scalar');
   end
   if size(mux,1)~=1 | size(mux,2)~= 1
      error('MUX argument must be a scalar');
   end
   if mux==2
      maxChannel=8;
   end

   if channel < 1 | channel > maxChannel
      error(['The number of channels must be in the range 1..',num2str(maxChannel)]);
   end

   if 1 %boardType==1 | boardType ==2
      rangeval= supRange(range);
      control= supControl(range);
      resolution=2^resolution;
      if rangeval < 0
         gain= -rangeval*2/resolution;
         offset= -rangeval;
      else
         gain= rangeval/resolution;
         offset= 0;
      end
   end

        level1=setfield(level1,boardref,level2);
        pool=setfield(pool,boardtype,level1);

end
