%% Programming with COM
% Component Object Model (COM), is a set of object-oriented technologies and
% tools that enable software developers to integrate application-specific
% components from different vendors into their own application solution.
%
% COM helps in integrating significantly different features into one
% application in a relatively easy manner. For example, using COM, a
% developer may choose a database access component by one vendor, a business
% graph component by another, and integrate these into a mathematical
% analysis package produced by yet a third.
%
% COM provides a framework for integrating reusable, binary software
% components into an application. Because components are implemented with
% compiled code, the source code may be written in any of the many
% programming languages that support COM. Upgrades to applications are
% simplified, as components can be simply swapped without the need to
% recompile the entire application. In addition, a component's location is
% transparent to the application, so components may be relocated to a 
% separate process or even a remote system without having to modify the
% application.
%
% Automation is a method of communication between COM clients and servers.
% It uses a single, standard COM interface called IDispatch. This interface
% enables the client to find out about, and invoke or access, methods and
% properties supported by a COM object. A client and server that
% communicate using IDispatch are known as an Automation client and
% Automation server. IDispatch is the only interface supported by MATLAB.
% Custom and dual interfaces are not supported. MATLAB can communicate with
% both Automation servers and controls.

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.5.4.3 $ $Date: 2004/04/10 23:24:59 $

%% Demo requirements
% The Calendar object is available on most Windows systems.  If there is an
% error, you can register it using "!regsvr32 mscal.ocx'".  You may have to
% specify the full path to "regsvr32.exe" and "mscal.ocx".
%
% This demo also requires Microsoft Excel.

%% Creating COM objects in MATLAB
% The following commands create an Automation control object and an
% Automation server object in MATLAB:

% Create an Automation control object and put it in a figure.
title('ActiveX Calendar') 
set(gca,'Xtick',[],'Ytick',[],'Box','on')
fp = get(gcf,'Position');
calendarPosition = get(gcf,'DefaultAxesPosition').*fp([3 4 3 4]) ;
hCalendar = actxcontrol('MSCAL.Calendar', calendarPosition+1, gcf)

% Create an Automation server object.
hExcel = actxserver('excel.application')


%% Displaying properties of COM objects 
% The properties of COM objects can be displayed to the MATLAB command
% window using the GET function, and are displayed graphically using the
% property inspector. For a demonstration of the property inspector, take a
% look at the Graphical Interface section of this demo.

get(hCalendar)


%% Changing COM object properties
% Properties of a COM object can be changed using the SET function.

% This makes the Excel Automation server application visible.
set(hExcel,'Visible',1)

%%
% The SET function returns a structure array if only the handle to the COM
% Object is passed as an argument.

out = set(hCalendar)

%%
% You can also use the SET function to simultaneously change multiple
% properties of COM objects.

set(hCalendar,'Day',20,'Month',3,'Year',2002)


%% Displaying and changing enumerated property types
% You can display and change properties with enumerated values using the SET
% and GET functions.

get(hExcel,'DefaultSaveFormat')

%%
% The SET function can be used to display all possible enumerated values for
% a specific property.

set(hExcel,'DefaultSaveFormat')

%%
% The SET function also enables you to set enumerated values for properties
% that support enumerated types.

set(hExcel,'DefaultSaveFormat','xlExcel9795');


%% Creating custom properties for a COM object
% You can create custom properties for a COM object in MATLAB. For
% instance, you can make the handle to the Excel COM object a property of
% the Calendar control and also make the handle to the Calendar control a
% property of the Excel COM Object.

addproperty(hCalendar,'ExcelHandle');
addproperty(hExcel,'CalendarHandle');
addproperty(hCalendar,'TestValue');

%%

set(hCalendar,'ExcelHandle',hExcel);
set(hCalendar,'TestValue',rand);
set(hExcel,'CalendarHandle',hCalendar);

%%

get(hExcel,'CalendarHandle')

%%

get(hCalendar,'ExcelHandle')

%%

get(hCalendar,'TestValue')

%%
% Custom properties that are created using the ADDPROPERTY function can also
% be removed.

deleteproperty(hCalendar,'TestValue');


%% Displaying methods of COM objects
% You can display methods of COM objects in MATLAB by using the INVOKE,
% METHODS and METHODSVIEW functions. METHODSVIEW provides a way to view the
% methods to the COM objects graphically. For a demonstration of the
% METHODSVIEW function, take a look at the Graphical Interface section of
% this demo.

invoke(hExcel)

%%

methods(hCalendar)

%%
% Calling methods of COM objects can be done in one of the following ways:
%
% Using the INVOKE function

hExcelWorkbooks = get(hExcel,'Workbooks');
hExcelw = invoke(hExcelWorkbooks, 'Add');

%%
% Using the method name

hExcelRange = Range(hExcel,'A1:D4');
set(hExcelRange,'Value',rand(4));


%% Passing arguments by reference
% Certain COM Objects expose methods with arguments that are also used as
% output. This is referred to as by-reference argument passing. In MATLAB,
% this is achieved by sending the output as the return from calling the
% method. 
%
% The GetFullMatrix method of a MATLAB Automation server is an example of a
% COM method that accepts arguments by reference. This example illustrates
% how passing arguments by reference is achieved in MATLAB.

hmatlab = actxserver('matlab.application')

%%

invoke(hmatlab)

%%

get(hmatlab)

%%
% Interact with the MATLAB running as an Automation server using the
% PutFullMatrix, Execute, and GetFullMatrix methods.

hmatlab.Execute('B2 = round(100*rand(1+round(10*rand)))');

%%
% In the next step, you can determine the size of the array to get from the
% MATLAB Automation server without needing to check manually.

Execute(hmatlab,'[r,c] = size(B2); B2_size = [r,c];');
[B_size, z_none] = GetFullMatrix(hmatlab,'B2_size','base',[0 0],[0,0]);

%%
% Since the size has been determined, you can just get the B2 data using the
% GetFullMatrix method.

[B, z_none] = GetFullMatrix(hmatlab,'B2','base',zeros(B_size),[0,0])

%%

delete(hmatlab)


%% Event handling
% Events associated with Automation controls can be registered with event
% handler routines, and also unregistered after the Automation control
% object has been created in MATLAB. 

events(hExcel)

%%
% The following command registers five of the supported events for hCalendar
% to the event handler, e_handler.m.

dbtype e_handler.m 1:7

%%

registerevent(hCalendar, {'NewYear' 'e_handler';...
   'NewMonth' 'e_handler';...
   'DblClick' 'e_handler';...
   'KeyPress' 'e_handler';...
   'AfterUpdate' 'e_handler'})
eventlisteners(hCalendar)

%%
% Another way of doing this would be to first register all the events, and
% then unregister the events that are not needed. First, restore the
% Automation control to its original state before any events were
% registered.

unregisterallevents(hCalendar)
eventlisteners(hCalendar)

%%
% Now register all the events that this COM object supports to the event
% handler, e_handler.m.

registerevent(hCalendar,'e_handler')
eventlisteners(hCalendar)

%%
% Next unregister any events you will not be needing.

unregisterevent(hCalendar,{'Click' 'e_handler';...
   'KeyDown' 'e_handler';...
   'KeyUp' 'e_handler';...
   'BeforeUpdate' 'e_handler'})
eventlisteners(hCalendar)


%% Error handling
% If there is an error when invoking a method, the error thrown shows the
% source, a description of the error, the source help file, and help context
% ID, if supported by the COM Object.

set(hExcelw,'Saved',1);
invoke(hExcelWorkbooks,'Close')
try
    Open(hExcelWorkbooks,'thisfiledoesnotexist.xls')
catch
    disp(lasterr)
end


%% Destroying COM objects
% COM objects are destroyed in MATLAB when the handle to the object or the
% handle to one of the object's interfaces is passed to the DELETE function.
% The resources used by a particular object or interface are released when
% the handle of the object or interface is passed to the RELEASE function.
%
% By displaying the contents of the MATLAB workspace using the WHOS command,
% you can observe the COM object and interface handles before and after
% using the RELEASE and DELETE functions.

whos hCalendar hExcel

%%

release(hExcelw)
whos hCalendar hExcel

%%

Quit(hExcel)
delete(hExcel);
delete(hCalendar);
whos hCalendar hExcel

