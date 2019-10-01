function varargout = terrain_extraction(varargin)
% TERRAIN_EXTRACTION MATLAB code for terrain_extraction.fig
%      TERRAIN_EXTRACTION, by itself, creates a new TERRAIN_EXTRACTION or raises the existing
%      singleton*.
%
%      H = TERRAIN_EXTRACTION returns the handle to a new TERRAIN_EXTRACTION or the handle to
%      the existing singleton*.
%
%      TERRAIN_EXTRACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function  named CALLBACK in TERRAIN_EXTRACTION.M with the given input arguments.
%
%      TERRAIN_EXTRACTION('Property','Value',...) creates a new TERRAIN_EXTRACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before terrain_extraction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to terrain_extraction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help terrain_extraction

% Last Modified by GUIDE v2.5 26-Oct-2018 09:10:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @terrain_extraction_OpeningFcn, ...
                   'gui_OutputFcn',  @terrain_extraction_OutputFcn, ...
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


% --- Executes just before terrain_extraction is made visible.
function terrain_extraction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to terrain_extraction (see VARARGIN)

% Choose default command line output for terrain_extraction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes terrain_extraction wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global res;
res = str2double(get(handles.res,'string'));


% --- Outputs from this function are returned to the command line.
function varargout = terrain_extraction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in DEMfile.
function DEMfile_Callback(hObject, eventdata, handles)
% hObject    handle to DEMfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEM;

[f, p] = uigetfile('*.tif');
DEM = imread([p f]);

% --- Executes on button press in Hillfile.
function Hillfile_Callback(hObject, eventdata, handles)
% hObject    handle to Hillfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Hill;
global res;
[f, p] = uigetfile('*.tif');
Hill = imread([p f]);

s = size(Hill);

axes(handles.DEMplot)
imagesc(res:res:s(2)*res,res:res:s(1)*res,Hill);
colormap('gray');


function res_Callback(hObject, eventdata, handles)
% hObject    handle to res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of res as text
%        str2double(get(hObject,'String')) returns contents of res as a double
global res;
res = str2double(get(handles.res,'string'));


% --- Executes during object creation, after setting all properties.
function res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GetSlope.
function GetSlope_Callback(hObject, eventdata, handles)
% hObject    handle to GetSlope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEM;
global Hill;
global res;
global walk;
axes(handles.DEMplot);
hold on;

% get user defined endpoints, user keeps selecting them in order.
% Unfortunately it does not plot in between each click. User presses enter
% to indicate all points have been selected.
[x, y] = ginput;

N = length(x);

line = [x(1); y(1)];

for k=1:N-1
    
    % get the slope of the line
    m = (y(k+1)-y(k))/(x(k+1)-x(k));
    
    % total distance of line
    d = sqrt((y(k+1)-y(k))^2+(x(k+1)-x(k))^2);
    
    % samples along total distance
    sample = res:res:d;
    
    % relative distance from total
    sample = sample/d;
    
    % samples along the line in meters
    line = [line, [x(k)+(x(k+1)-x(k))*sample; y(k)+(y(k+1)-y(k))*sample], ...
        [x(k+1); y(k+1)]]; %#ok<AGROW>
    
    
end

% plot the path
plot(line(1,:),line(2,:),'r','linewidth',2);

% interpolate the gradient images
pixel = line/res;
Height_path = interp2(DEM,pixel(1,:),pixel(2,:));

% slope of the path
slope = diff(Height_path)./sqrt(diff(line(1,:)).^2+diff(line(2,:)).^2);

% slope angle in radians
theta = atan2(diff(Height_path),sqrt(diff(line(1,:)).^2+diff(line(2,:)).^2))*180/pi;

eta = (10^3.5); % Pa * s - lava flow viscosity
rho = 2600; % kg/m3 - lava flow density 
g = -9.81; %m/s2 - gravity

% creates a variable called velocity that contains the velocity at each
% point in the path
velocity = rho*g*sin(slope)/(4*eta);

assignin('base','velocity',velocity);

% creates a variable called path that contains the x and y points
% corresponding to the velocity
walk = line(:,1:end-1);
assignin('base','walk',walk);


% creates a variable called slope
% corresponding to the velocity
assignin('base','theta',theta);


% %This programme computes the velocities of a lava flow at a given point on
% %a DEM. It is based on a modification of Jefferey's equation, detailed in
% %"Modelling Volcanic Processes" by fagents et al. (page 88)
% 
% %User defined variables
% eta = (10^3.5); % Pa * s - lava flow viscosity
% rho = 2600; % kg/m3 - lava flow density
% h = 7; % m - flow thickness
% 
% %constant variables
% g = 9.81; %m/s2 - gravity
% 
% %calculated variables
% 
% theta = y; % degrees - neighbourhood slope of terrain (
% w = x; % m - width of channel
% u = (rho*g*(sin(theta))/(4*nu)); % m/s - downflow velocity
% Er = w*h*u; % m3/s - effusion rate


% --- Executes on button press in profile.
function profile_Callback(hObject, eventdata, handles)
% hObject    handle to profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get center estimate
[x, y] = ginput(1);

global DEM;
global Hill;
global res;
global walk;
axes(handles.DEMplot);
hold on;
plot(x,y,'x')
center = [x;y];

% crop DEM
ylim = get(gca,'ylim');
xlim = get(gca,'xlim');
ix = ceil(xlim/res);
iy = ceil(ylim/res);
s = size(DEM);
if(ix(2)>s(2))
    ix(2) = s(2);
end
if(iy(2)>s(1))
    iy(2) = s(1);
end

DEMcrop = DEM(iy(1):iy(2),ix(1):ix(2));
xcoor = (ix(1):ix(2))*res;
ycoor = (iy(1):iy(2))*res;

% get pixels that do not contain data
nanmap = DEMcrop==0;

% fill in non-data points
DEMcrop(DEMcrop(:)==0) = max(DEMcrop(:));

% get length to omit around center for ellipse fits
omit_center = str2double(get(handles.OmitL,'string'));

% get length on either side to collect data for ellipse fit
keep_side = str2double(get(handles.fitL,'string'));

% get total number of samples to fit ellipse
NA = round(str2double(get(handles.NA,'string')));

% save('line268.mat');

% fit ellipses
DEMcont = create_contour(DEMcrop,xcoor,ycoor,center,walk,omit_center,keep_side,NA);

% save('line273.mat');

% extract profiles
L = str2double(get(handles.proL,'string'));
profiles = project_heights2(DEMcont,DEMcrop,xcoor,ycoor,walk,res*2,L,nanmap);

% output ellipse fit, cropped DEM, and profiles variables to workspace
assignin('base','DEMcont',DEMcont);
assignin('base','profiles',profiles);
assignin('base','DEMcrop',DEMcrop);
assignin('base','xcoor',xcoor);
assignin('base','ycoor',ycoor);



function OmitL_Callback(hObject, eventdata, handles)
% hObject    handle to OmitL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OmitL as text
%        str2double(get(hObject,'String')) returns contents of OmitL as a double


% --- Executes during object creation, after setting all properties.
function OmitL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OmitL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fitL_Callback(hObject, eventdata, handles)
% hObject    handle to fitL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fitL as text
%        str2double(get(hObject,'String')) returns contents of fitL as a double


% --- Executes during object creation, after setting all properties.
function fitL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fitL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NA_Callback(hObject, eventdata, handles)
% hObject    handle to NA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NA as text
%        str2double(get(hObject,'String')) returns contents of NA as a double


% --- Executes during object creation, after setting all properties.
function NA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function proL_Callback(hObject, eventdata, handles)
% hObject    handle to proL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of proL as text
%        str2double(get(hObject,'String')) returns contents of proL as a double


% --- Executes during object creation, after setting all properties.


function proL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to proL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end