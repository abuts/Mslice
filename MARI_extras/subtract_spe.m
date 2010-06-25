function varargout = subtract_spe(varargin)
% SUBTRACT_SPE M-file for subtract_spe.fig
%      SUBTRACT_SPE, by itself, creates a new SUBTRACT_SPE or raises the existing
%      singleton*.
%
%      H = SUBTRACT_SPE returns the handle to a new SUBTRACT_SPE or the handle to
%      the existing singleton*.
%
%      SUBTRACT_SPE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUBTRACT_SPE.M with the given input arguments.
%
%      SUBTRACT_SPE('Property','Value',...) creates a new SUBTRACT_SPE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before subtract_spe_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to subtract_spe_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help subtract_spe

% Last Modified by GUIDE v2.5 11-Mar-2004 18:47:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @subtract_spe_OpeningFcn, ...
                   'gui_OutputFcn',  @subtract_spe_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before subtract_spe is made visible.
function subtract_spe_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to subtract_spe (see VARARGIN)

% Choose default command line output for subtract_spe
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes subtract_spe wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = subtract_spe_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]=uigetfile('.phx','SELECT PHX FILE');
file1=cat(2,path,file);
set(handles.edit1,'String',file1);
guidata(gcbo, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]=uigetfile('.SPE','SELECT DATA SPE FILE');
file2=cat(2,path,file);
set(handles.edit2,'String',file2);
guidata(gcbo, handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]=uigetfile('.SPE','SELECT BACKGROUND SPE FILE');
file3=cat(2,path,file);
set(handles.edit3,'String',file3);
guidata(gcbo, handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]=uiputfile('.SPE','SELECT NAME FOR CORRECTED SPE FILE');
file4=cat(2,path,file);
set(handles.edit4,'String',file4);
guidata(gcbo, handles);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('########################################################################')
disp('spe file subtraction routine')
disp('########################################################################')
tomslice=1;
phx_filename=get(handles.edit1,'String');
datafile=get(handles.edit2,'String');
backfile=get(handles.edit3,'String');
savefile=get(handles.edit4,'String');

data=buildspe(datafile,phx_filename);
back=buildspe(backfile,phx_filename);
choice=input('Correct for bose factor ? 1=Yes 0=no   ');
if choice == 1
temp_sample1=input('Temperature of sample data   ');
temp_back1=input('Temperature of background data ');
else
    disp('not correcting for temperature');
    temp_sample1='xx';
    temp_back1='xx';
end

if length(data.det_group)~=length(back.det_group)
    disp('########################################################################')
    disp('Data files have masked groups... will unmask all data before subtraction')
    disp('Read data into mslice manually')
    disp('########################################################################')
    tomslice=0;
    data=unmask(data);
    back=unmask(back);
end
corrected_data=data;
if isnumeric(temp_sample1) & isnumeric(temp_back1)
    data=bosefactor2(data,temp_sample1);
    back=bosefactor2(back,temp_back1);
end
r=input('Enter normalisation factor  ');

r2=input('input background level difference sample to can ');
 
 
 back.S=back.S.*r;
 back.ERR=back.ERR.*r;
 data.S=data.S+r2;
 corrected_data.S=data.S-(back.S);
 corrected_data.ERR=sqrt(data.ERR.^2+(back.ERR).^2);
 corrected_data.S=corrected_data.S';
 corrected_data.ERR=corrected_data.ERR';
 
 if tomslice==1
 towindow(corrected_data);
 end
 
 
%save the file
if isempty(savefile)
     disp('No file name given not saving');
else
ne=length(data.en);
de=data.en(1,2)-data.en(1,1);
en_grid=[data.en-de/2 data.en(1,ne)+de/2];
en_grid=round(en_grid*1e5)/1e5;	%truncate at the 5th decimal point

    jjjjj=find(corrected_data.ERR >= 1e10);
    corrected_data.ERR(jjjjj)=0;
    corrected_data.en=en_grid;
    
   put_spe(corrected_data,savefile);
   
 
end