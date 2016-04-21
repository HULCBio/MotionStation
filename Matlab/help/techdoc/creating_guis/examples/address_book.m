function varargout = address_book(varargin)
% ADDRESS_BOOK Application M-file for address_book.fig
%   ADDRESS_BOOK, by itself, creates a new ADDRESS_BOOK or raises the existing
%   singleton*.
%
%   H = ADDRESS_BOOK returns the handle to a new ADDRESS_BOOK or the handle to
%   the existing singleton*.
%
%   ADDRESS_BOOK('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in ADDRESS_BOOK.M with the given input arguments.
%
%   ADDRESS_BOOK('Property','Value',...) creates a new ADDRESS_BOOK or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before address_book_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to address_book_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help address_book

% Last Modified by GUIDE v2.5 08-Apr-2002 16:42:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @address_book_OpeningFcn, ...
                   'gui_OutputFcn',     @address_book_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    varargout{1:nargout} = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before address_book is made visible.
function address_book_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to address_book (see VARARGIN)

% Choose default command line output for address_book
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
if nargin < 4 
    % Load the default address book
    Check_And_Load([],handles);
    % If first element in varargin is 'book' and the second element is a
    % MATLAB file, then load that file
elseif (length(varargin) == 2 & strcmpi(varargin{1},'book') & (2 == exist(varargin{2},'file')))
    Check_And_Load(varargin{2},handles);
else
    errordlg('File Not Found','File Load Error')
    set(handles.Contact_Name,'String','')
    set(handles.Contact_Phone,'String','')
end	  

% UIWAIT makes address_book wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = address_book_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- 
function pass = Check_And_Load(file,handles)

% Initialize the variable "pass" to determine if this is a valid file.
pass = 0;

% If called without any file then set file to the default file name.
% Otherwise if the file exists then load it.
if isempty(file)
    file = 'addrbook.mat';
    handles.LastFile = file;
    guidata(handles.Address_Book,handles)
end

if exist(file) == 2
    data = load(file);
end

% Validate the MAT-file
% The file is valid if the variable is called "Addresses" and it has 
% fields called "Name" and "Phone"
flds = fieldnames(data);
if (length(flds) == 1) & (strcmp(flds{1},'Addresses'))
    fields = fieldnames(data.Addresses);
    if (length(fields) == 2) &(strcmp(fields{1},'Name')) & (strcmp(fields{2},'Phone'))
        pass = 1;
    end
end

% If the file is valid, display it
if pass
    % Add Addresses to the handles structure
    handles.Addresses = data.Addresses;
    % Display the first entry
    set(handles.Contact_Name,'String',data.Addresses(1).Name)
    set(handles.Contact_Phone,'String',data.Addresses(1).Phone)
    % Set the index pointer to 1
    handles.Index = 1;
    % Save the modified handles structure
    guidata(handles.Address_Book,handles)
else
    errordlg('Not a valid Address Book','Address Book Error')
end

% ------------------------------------------------------------
% Callback for Open menu - displays an open dialog
% ------------------------------------------------------------
function varargout = Open_Callback(h, eventdata, handles, varargin)
% Use UIGETFILE to allow for the selection of a custom address book.
[filename, pathname] = uigetfile( ...
    {'*.mat', 'All MAT-Files (*.mat)'; ...
        '*.*','All Files (*.*)'}, ...
    'Select Address Book');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    % Otherwise construct the fullfilename and Check and load the file.
else
    File = fullfile(pathname,filename);
    % if the MAT-file is not valid, do not save the name
    if Check_And_Load(File,handles)
        handles.LastFIle = File;
        guidata(h,handles)
    end
end


% ------------------------------------------------------------
% Callback for the Contact Name text box
% ------------------------------------------------------------
function varargout = Contact_Name_Callback(h, eventdata, handles, varargin)
% hObject    handle to Contact_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% Get the strings in the Contact Name and Phone text box
Current_Name = get(handles.Contact_Name,'string');
Current_Phone = get(handles.Contact_Phone,'string');

% If empty then return
if isempty(Current_Name)
    return
end
% Get the current list of addresses from the handles structure
Addresses = handles.Addresses;
% Go through the list of contacts
% Determine if the current name matches an existing name
for i = 1:length(Addresses)
    if strcmp(Addresses(i).Name,Current_Name)
        set(handles.Contact_Name,'string',Addresses(i).Name)
        set(handles.Contact_Phone,'string',Addresses(i).Phone)
        handles.Index = i;
        guidata(h,handles)
        return
    end
end
% If it's a new name, ask to create a new entry
Answer=questdlg('Do you want to create a new entry?', ...
    'Create New Entry', ...
    'Yes','Cancel','Yes');			
switch Answer
case 'Yes'
    Addresses(end+1).Name = Current_Name; % Grow array by 1
    Addresses(end).Phone = Current_Phone; 
    index = length(Addresses);
    handles.Addresses = Addresses;
    handles.Index = index;
    guidata(h,handles)
    return			
case 'Cancel'
    % Revert back to the original number
    set(handles.Contact_Name,'string',Addresses(handles.Index).Name)
    set(handles.Contact_Phone,'String',Addresses(handles.Index).Phone)
    return
end			

% ------------------------------------------------------------
% Callback for the Contact Phone # text box
% ------------------------------------------------------------
function varargout = Contact_Phone_Callback(h, eventdata, handles, varargin)
% hObject    handle to Contact_Phone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

Current_Phone = get(handles.Contact_Phone,'string');
% If either one is empty then return
if isempty(Current_Phone)
    return
end
% Get the current list of addresses from the handles structure
Addresses = handles.Addresses;
Answer=questdlg('Do you want to change the phone number?', ...
    'Change Phone Number', ...
    'Yes','Cancel','Yes');			
switch Answer
case 'Yes'
    % If no name match was found create a new contact
    Addresses(handles.Index).Phone = Current_Phone; 
    handles.Addresses = Addresses;
    guidata(h,handles)
    return			
case 'Cancel'
    % Revert back to the original number
    set(handles.Contact_Phone,'String',Addresses(handles.Index).Phone)
    return
end			

% ------------------------------------------------------------
% Callback for the Prev and Next buttons
% Pass a string argument (str) indicating which object was selected
% ------------------------------------------------------------
function varargout = Prev_Next_Callback(h, eventdata, handles, str)
% hObject    handle to Prev_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the index pointer and the addresses
index = handles.Index;
Addresses = handles.Addresses;
% Depending on whether Prev or Next was clicked change the display
switch str
case 'Prev'
    % Decrease the index by one
    i = index - 1;	
    % If the index is less then one then set it equal to the index of the 
    % last element in the Addresses array
    if i < 1
        i = length(Addresses);
    end
case 'Next'
    % Increase the index by one
    i = index + 1;
    
    % If the index is greater than the size of the array then point
    % to the first item in the Addresses array
    if i > length(Addresses)
        i = 1;
    end	
end

% Get the appropriate data for the index in selected
Current_Name = Addresses(i).Name;
Current_Phone = Addresses(i).Phone;
set(handles.Contact_Name,'string',Current_Name)
set(handles.Contact_Phone,'string',Current_Phone)

% Update the index pointer to reflect the new index
handles.Index = i;
guidata(h,handles)

% ------------------------------------------------------------
% Callback for Save and Save As menus 
% ------------------------------------------------------------
function varargout = Save_Callback(h, eventdata, handles, varargin)
% Get the Tag of the menu selected
Tag = get(h,'Tag');
% Get the address array
Addresses = handles.Addresses;
% Based on the item selected, take the appropriate action
switch Tag
case 'Save'
    % Save to the default addrbook file
    File = handles.LastFile;
    save(File,'Addresses')
case 'Save_As'
    % Allow the user to select the file name to save to
    [filename, pathname] = uiputfile( ...
        {'*.mat';'*.*'}, ...
        'Save as');	
    % If 'Cancel' was selected then return
    if isequal([filename,pathname],[0,0])
        return
    else
        % Construct the full path and save
        File = fullfile(pathname,filename);
        save(File,'Addresses')
        handles.LastFile = File;
        guidata(h,handles)
    end
end
% ------------------------------------------------------------
% Callback for the Contact --> Create New menu
% ------------------------------------------------------------
function varargout = New_Callback(h, eventdata, handles, varargin)
set(handles.Contact_Name,'String','')
set(handles.Contact_Phone,'String','')

% ------------------------------------------------------------
% Callback for the GUI figure ResizeFcn property.
% ------------------------------------------------------------
function varargout = ResizeFcn(h, eventdata, handles, varargin)
% Get the figure size and position
Figure_Size = get(h,'Position');
% Set the figure's original size in character units
Original_Size = [ 0 0 94 19.230769230769234];
% If the resized figure is smaller than the original figure size then compensate
if (Figure_Size(3) < Original_Size(3)) | (Figure_Size(4) ~= Original_Size(4))
    if Figure_Size(3) < Original_Size(3)
        % If the width is too small then reset to origianl width
        set(h,'Position',[Figure_Size(1) Figure_Size(2) Original_Size(3) Original_Size(4)])
        Figure_Size = get(h,'Position');
    end
    
    if Figure_Size(4) ~= Original_Size(4)
        % Do not allow the height to change 
        set(h,'Position',[Figure_Size(1) Figure_Size(2)+Figure_Size(4)-Original_Size(4) Figure_Size(3) Original_Size(4)])
    end
end
% Set the units of the Contact Name field to 'Normalized'
set(handles.Contact_Name,'units','normalized')
% Get its Position
C_N_pos = get(handles.Contact_Name,'Position');
% Reset it so that it's width remains normalized relative to figure
set(handles.Contact_Name,'Position',[C_N_pos(1) C_N_pos(2)  0.789 C_N_pos(4)])
% Return the units to 'Characters'
set(handles.Contact_Name,'units','characters')
% Reposition GUI on screen
movegui(h,'onscreen')


% --- Executes during object creation, after setting all properties.
function Contact_Name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Contact_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = ispc;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function Contact_Phone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Contact_Phone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = ispc;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


