%% Introduction to digital I/O lines.
%    DEMODIO_LINE introduces digital I/O lines by demonstrating
%    how to add lines to a digital I/O object and how to configure 
%    the lines for your acquisition.  
%
%    This demo gives examples on using the get/set notation, dot notation,
%    and named index notation for obtaining information about the line 
%    and for configuring the line for your acquisition.
%
%    See also ADDLINE, DAQDEVICE/GET, DAQDEVICE/SET, DIGITALIO,
%             DAQHELP.
%
%    MP 3-24-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:45:24 $

%%
% First find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% In this demo, you will learn about creating, accessing, and 
% configuring digital I/O lines. This demo will use National
% Instruments hardware. The information obtained for this 
% demonstration has been pre-recorded. Therefore, if you do 
% not have a National Instruments card, you can still learn  
% about digital I/O lines.

%%
% To get started, a digital I/O object, dio, associated with
% National Instrument hardware is created.
% 
% >> dio = digitalio('nidaq', 1);

%%
% You can add a line to a digital I/O object with the ADDLINE 
% command. ADDLINE needs at least three input arguments. The 
% first input argument specifies which digital I/O object the 
% line is being added to. The second argument is the id of 
% the hardware line you are adding to the digital I/O object. 
% The third input argument specifies the direction of the line. 
% The direction can be either 'In' in which case the line 
% is read from, or 'Out' in which case the line is written to.
% 
% >> addline(dio, 0, 'In');

%%
% There are three methods for accessing a line. In the first 
% method, the line is accessed through the digital I/O object's 
% Line property. For example, using the dot notation, all the
% digital I/O object's lines will be assigned to the variable 
% line1.
% 
% >> line1 = dio.Line
% 
%     Index:  LineName:  HwLine:  Port:  Direction:
%     1       ''         0        0      'In'   

%%   
% Or, using the get notation
% 
% >> line1 = get(dio, 'Line')
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     1       ''         0        0      'In'     

%%
% In the second method, the line is accessed at creation time 
% by assigning an output variable to ADDLINE.
% 
% The fourth input argument to ADDLINE assigns the name Line2 
% to the line created.
% 
% >> line2 = addline(dio, 1, 'Out', 'Line2')
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     2       'Line2'    1        0      'Out'

%%
% In the the third method, the line is accessed through its 
% LineName property value. This method is referred to as named 
% referencing. The second line added to the digital I/O object 
% was assigned the LineName 'Line2'. Therefore, the second 
% line can be accessed with the command
% 
% >> line2 = dio.Line2
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     2       'Line2'    1        0      'Out'

%%
% Lines that have the same parent (or are associated with 
% the same digital I/O object) can be concatenated into either
% row or column vectors. An error will occur if you try to 
% concatentate lines into a matrix.
% 
% >> daqline = [line1 line2];
% >> size(daqline)
% 
% ans =
% 
%     1     2
% 
% Or
% 
% >> daqline = [line1;line2];
% >> size(daqline)
% 
% ans =
% 
%     2     1

%%
% You can access specific lines by specifying the index of the 
% line in the digital I/O object's line array. To obtain the
% first line:
% 
% >> line1 = dio.Line(1)
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     1       ''         0        0      'In' 
% 
% To obtain the second line
% 
% >> line2 = dio.Line(2)
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     2       'Line2'    1        0      'Out' 

%%
% Or, if a 1-by-5 line array is created, it is possible to 
% access the the first, third, and fourth lines as follows
% 
% >> linearray = [line1 line2 line1 line1 line2]
% 
%     Index:  LineName:  HwLine:  Port:  Direction:  
%     1       ''         0        0      'In'  
%     2       'Line2'    1        0      'Out' 
%     1       ''         0        0      'In'  
%     1       ''         0        0      'In'  
%     2       'Line2'    1        0      'Out' 
% 
% >> temp = linearray([1 3 4])
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     1       ''         0        0      'In' 
%     1       ''         0        0      'In' 
%     1       ''         0        0      'In' 

%%
% You can obtain information regarding the line with the GET 
% command. When passing only the line to GET, a list of all 
% properties and their current values are displayed. The 
% common properties are listed first. If any device-specific 
% line properties exist, they will be listed second. 
% 
% >> get(line1)
%          Direction = In
%          HwLine = 0
%          Index = 1
%          LineName = 
%          Parent = [1x1 digitalio]
%          Port = 0

%%
% If an output variable is supplied to the GET command, a  
% structure is returned where the structure field names are 
% the line's property names and the structure field values 
% are the line's property values.
% 
% >> h = get(line2)
% 
% h = 
% 
%    Direction: 'Out'
%       HwLine: 1
%        Index: 2
%     LineName: 'Line2'
%       Parent: [1x1 digitalio]
%         Port: 0

%%
% You can obtain information pertaining to a specific property 
% by specifying the property name as the second input argument 
% to GET.
% 
% >> get(line1, 'Direction')
% 
% ans =
% 
%     In

%%
% If the line array is not 1-by-1, a cell array of property 
% values is returned.
% 
% >> get(daqline, 'Direction')
% 
% ans = 
% 
%     'In'
%     'Out'

%%
% You can obtain information pertaining to multiple properties 
% by specifying a cell array of property names as the second 
% input argument to GET.
% 
% >> get(line2, {'LineName','HwLine','Direction'})
% 
% ans = 
% 
%     'Line2'    [1]    'Out'

%%
% If the line array is not singular and a cell array of  
% property names is passed to GET, then a matrix of property 
% values is returned.
% 
% >> get(daqline, {'LineName','HwLine','Direction'})
% 
% ans = 
% 
%          ''    [0]    'In' 
%     'Line2'    [1]    'Out'
% 
% The returned property values matrix relate to each object 
% and property name as follows 
% 
%                LineName   HwLine    Direction
% line1           ''         [0]       'In'
% line2           'Line2'    [1]       'Out'

%%
% You can use the dot notation to obtain information from 
% each line.
% 
% >> line1.Direction
% 
% ans =
% 
%     In
% 
% >> dio.Line(2).LineName
% 
% ans =
% 
%     Line2

%%
% You can also obtain line information through named 
% referencing.
% 
% >> dio.Line2.Direction
% 
% ans =
% 
%     Out

%%
% You can assign values to different line properties with 
% the SET command. If only the line is passed to SET, a list 
% of settable properties and their possible values are 
% returned. Similar to the GET display, the common properties 
% are listed first. If any device-specific line properties 
% exist, they will be listed second. 
% 
% >> set(line1)
%          Direction: [ {In} | Out ]
%          HwLine
%          LineName

%%
% If you supply an output variable to SET, a structure is 
% returned where the structure field names are the line's 
% property names and the structure field values are the 
% possible property values for the line property.
% 
% >> h=set(line1)
% 
% h = 
% 
%    Direction: {2x1 cell}
%       HwLine: {}
%     LineName: {}

%%
% You can obtain information on possible property values for 
% a specific property by specifying the property name as the 
% second input argument to SET.
% 
% >> set(line1, 'Direction')
%     [ {In} | Out ]
% 
% Or, you can assign the result to an output variable.
% 
% >> direction = set(line1, 'Direction')
% 
% direction = 
% 
%    'In'
%    'Out'

%%
% You can assign values to a specific property as follows
% 
% >> set(line1, 'LineName', 'Line1');
% >> daqline
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     1       'Line1'    0        0      'In'   
%     2       'Line2'    1        0      'Out'  

%%
% You can assign the same property values to multiple lines 
% with one call to SET.
% 
% >> set(daqline, 'Direction', 'Out');
% 
% >> daqline
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     1       'Line1'    0        0      'Out' 
%     2       'Line2'    1        0      'Out' 

%%
% You can assign different property values to multiple 
% lines by specifying a cell array of property values in 
% the SET command.
% 
% >> set(daqline, {'Direction'}, {'Out'; 'In'})
% >> daqline
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     1       'Line1'    0        0      'Out' 
%     2       'Line2'    1        0      'In'  

%%
% This can be extended to assign multiple properties different 
% values for multiple lines. The cell array of property values 
% must be m-by-n, where m is the number of objects and n is 
% the number of properties. Each row of the property values 
% cell array contains the property values for a single object. 
% Each column of the property values cell array contains the 
% property values for a single property.
% 
% >> set(dio.Line, {'Direction'; 'LineName'}
%    {'In', 'DIOLine1'; 'Out', 'DIOLine2'});
%    
% >> dio.Line
% 
%     Index:  LineName:   HwLine:  Port:  Direction:
%     1       'DIOLine1'  0        0      'In'   
%     2       'DIOLine2'  1        0      'Out'  
% 
% The assigned property values matrix relate to each object 
% and property name as follows
% 
%                   Direction        LineName
% line1              'In'            'DIOLine1'
% line2              'Out'           'DIOLine2'

%%
% You can use the dot notation to assign values to line
% properties.
% 
% >> line1.Direction = 'Out';
% >> line2.LineName = 'MyLine2';
% >> dio.Line(1).LineName = 'MyLine1';
% >> dio.Line
% 
%     Index:  LineName:  HwLine:  Port:  Direction: 
%     1       'MyLine1'  0        0      'Out' 
%     2       'MyLine2'  1        0      'Out' 

%%
% Or, you can assign values to line properties through named 
% referencing.
% 
% >> dio.MyLine2.LineName = 'Digital';
% >> dio.Line
% 
%     Index:  LineName:  HwLine:  Port:  Direction:
%     1       'MyLine1'  0        0      'Out'
%     2       'Digital'  1        0      'Out'

