function varargout = cut(varargin)
% CUT M-file for cut.fig
%      CUT, by itself, creates a new CUT or raises the existing
%      singleton*.
%
%      H = CUT returns the handle to a new CUT or the handle to
%      the existing singleton*.
%
%      CUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CUT.M with the given input arguments.
%
%      CUT('Property','Value',...) creates a new CUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cut_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cut_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cut

% Last Modified by GUIDE v2.5 29-Nov-2005 13:38:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cut_OpeningFcn, ...
                   'gui_OutputFcn',  @cut_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cut is made visible.
function cut_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cut (see VARARGIN)

% Choose default command line output for cut
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cut wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cut_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hold.
function hold_Callback(hObject, eventdata, handles)
% hObject    handle to hold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: returns toggle state of hold
handles.holdplot=get(hObject,'Value');
guidata(gcbo,handles);
% --- Executes on button press in write_file.
function write_file_Callback(hObject, eventdata, handles)
% hObject    handle to write_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of write_file
handles.writefile=get(hObject,'Value');
guidata(gcbo,handles);
function intens_low_E_Callback(hObject, eventdata, handles)
% hObject    handle to intens_low_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intens_low_E as text
%        str2double(get(hObject,'String')) returns contents of intens_low_E as a double
handles.loEint=str2double(get(hObject,'String'));
guidata(gcbo,handles);
% --- Executes during object creation, after setting all properties.
function intens_low_E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intens_low_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inten_hi_E_Callback(hObject, eventdata, handles)
% hObject    handle to inten_hi_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inten_hi_E as text
%        str2double(get(hObject,'String')) returns contents of inten_hi_E as a double

handles.hiEint=str2double(get(hObject,'String'));
%if no windows then create with the limits set
if isempty(findobj('name','Energy cut')) == true;
figure('name','Energy cut','numbertitle','off')
end
hhh=findobj('name','Energy cut');
figure(hhh)
ylim([handles.loEint,handles.hiEint]);
guidata(gcbo,handles)



% --- Executes during object creation, after setting all properties.
function inten_hi_E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inten_hi_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_cut.
function plot_cut_Callback(hObject, eventdata, handles)
% hObject    handle to plot_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%initiliase some of the variable
if isfield(handles,{'writefile'}) == false
    handles.writefile=0;
end
if isfield(handles,{'iterate_val'}) == false
    handles.iterate_val=0;
end
if isfield(handles,{'holdplot'}) == false
    handles.holdplot=0;
end
  
guicut(handles.holdplot,handles.iterate_val,handles.writefile,handles.bin_fac)

guidata(gcbo,handles);


% --- Executes on button press in iterate.
function iterate_Callback(hObject, eventdata, handles)
% hObject    handle to iterate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of iterate
handles.iterate_val=get(hObject,'Value');
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function inten_lo_Q_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inten_lo_Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function inten_lo_Q_Callback(hObject, eventdata, handles)
% hObject    handle to inten_lo_Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inten_lo_Q as text
%        str2double(get(hObject,'String')) returns contents of inten_lo_Q as a double
handles.loQint=str2double(get(hObject,'String'));
guidata(gcbo,handles)

function inten_hi_Q_Callback(hObject, eventdata, handles)
% hObject    handle to inten_hi_Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inten_hi_Q as text
%        str2double(get(hObject,'String')) returns contents of inten_hi_Q as a double
handles.hiQint=str2double(get(hObject,'String'));
if isempty(findobj('name','|Q| cut')) == true;
figure('name','|Q| cut','numbertitle','off')
end
hhhh=findobj('name','|Q| cut');
figure(hhhh)
ylim([handles.loQint,handles.hiQint]);
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function inten_hi_Q_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inten_hi_Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function binfac_Callback(hObject, eventdata, handles)
% hObject    handle to binfac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binfac as text
%        str2double(get(hObject,'String')) returns contents of binfac as a double
handles.bin_fac=str2double(get(hObject,'String'));
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function binfac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binfac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

