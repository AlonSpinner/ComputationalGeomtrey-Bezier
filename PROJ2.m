%Project 2 in Computational Geomtrey 2 - 036020 winter 18-19

%---------------Important notes:
%User needs to select a patch before using the pushbuttons. it is
%evident to the user through the grassgreen-lightgreen colors on the buttons.

%SecPush.UserData stores the handle of the selected section (line)
%Section line has UserData:
% Ptch.UserData.Number=k; - for plot coloring (lines(k))
% Ptch.UserData.PatchCP=SecCP; - control points in num2cell([X,Y,Z],2)
% format (example: num2cell(magic(3),2))
% Sec.UserData.CntrlH=[SctH,PltH]; - handles of control points lines and
% scatters
% Ptch.Tag='Patch';

%lines between control points in v direction: '--'
%in u direction: '.-'

%ResetPntsPush.UserData stores the inital control points created by Enter Points

%SplitPush.UserData stores the amount of patches that have been plotted
%since the last reset (by enter points). For plot colors

function varargout = PROJ2(varargin)
% PROJ2 MATLAB code for PROJ2.fig
%      PROJ2, by itself, creates a new PROJ2 or raises the existing
%      singleton*.
%
%      H = PROJ2 returns the handle to a new PROJ2 or the handle to
%      the existing singleton*.
%
%      PROJ2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJ2.M with the given input arguments.
%
%      PROJ2('Property','Value',...) creates a new PROJ2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PROJ2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PROJ2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PROJ2

% Last Modified by GUIDE v2.5 20-Jun-2021 18:08:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PROJ2_OpeningFcn, ...
                   'gui_OutputFcn',  @PROJ2_OutputFcn, ...
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
function PROJ2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PROJ2 (see VARARGIN)

% Choose default command line output for PROJ2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Update Ax1 ButtonDownFcn to the one that resets cursor and selection
set(handles.Ax1,'ButtonDownFcn',{@WrongMdownCB,handles})

%load up some surface
PtchAmnt=4; R=1; 
Xnoise=0; Ynoise=0; Znoise=10;
Xscale=1; Yscale=1;
%Create Default Points
CP=cell(4,4,PtchAmnt); %build CP cell tenzor to include all points of surfaces
CPAmnt=16; %16 for cubic bezier surface. needs to be a squared number. CPAmnt=N^2
N=sqrt(CPAmnt);
for k=1:PtchAmnt
    xy=deal(linspace(-1,1,N)); %both x and y are the same
    [X,Y]=meshgrid(xy,xy);
    X=X*Xscale; Y=Y*Yscale; %X and Y scale
    %Introduce noise, circular translation, and Z surface
    if k==1, X=X*0.5*R; end %correction for first surface
    X=X+rand(size(X))*Xnoise+R*k; %add linear(k) translation in X
    Y=Y+rand(size(Y))*Ynoise;
    Z=rand([N,N])*Znoise;
    CPk=num2cell([X(:),Y(:),Z(:)],2); %to accomidate for format of CP. will be done in two stages
    CPk=reshape(CPk,[N,N]); %insert to CP after second stage formatting
    CP(:,:,k)=CPk; %insert into tenzor
end
CP=FixCP4C1(CP); %Fix continuaty
% Store the points in MovPush and ResetPntsPush user data
handles.ResetPntsPush.UserData=CP; %saves control points into ResetPntsPush
handles.MovPush.UserData=CP; %saves control points into MovPush
%Draw on Ax1
DrawInitialAx1(CP,handles);

%Change color of MovPush to OrangeBrick - can be used
OrangeBrick=[1,0.5,0.1];
handles.MovPush.BackgroundColor=OrangeBrick;
function varargout = PROJ2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%% CallBacks
%Main Push Buttons
function EnterPntsPush_Callback(hObject, eventdata, handles)
%% Obtain Input
%Obtain lambda and myu0,myu1 
lambda=str2num(handles.LambdaEdit.String);
Myu=str2num(handles.MyuEdit.String);
if isempty(lambda)||isempty(Myu), errordlg('Please input a correct lambda/Myu value','A-lon'); return, end
if lambda<=0, errordlg('lambda value must be positive','A-lon'); return, end
myu0=Myu(1); myu1=Myu(2);

%turn buttons to grass green having the user select
%curve for another activation
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.SurfPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

%Define Control points for each surface maintaining C1 in u and v
%directions. Control points will be in the form of nxmxk cell matrix of points inside
%a tenzor of patches where CP(:,:,k) holds the control points for patch number k
%EXAMPLE: CP(:,:,k)= {[x11,y11,z11]},{[x12,y12,z12]},{[x13,y13,z13]} -----> u
%           {[x21,y21,z21]},{[x22,y22,z22]},{[x23,y23,z23]}
%           |
%           |
%           |
%       v   V

%ask user for paramters
prompt={'Patch Amount','Linear Translation Factor','Noise Factor [x,y,z]','Scale Factor [x,y]'};
default={'4','1','[0,0,2]','[1,1]'};
Uinput=inputdlg(prompt,'Patch Parameters',1,default);
if isempty(Uinput), return, end
PtchPar=cellfun(@str2num ,Uinput,'un',0);
PtchAmnt=PtchPar{1}; R=PtchPar{2}; 
Xnoise=PtchPar{3}(1); Ynoise=PtchPar{3}(2); Znoise=PtchPar{3}(3);
Xscale=PtchPar{4}(1); Yscale=PtchPar{4}(2);

%Create Default Points
CP=cell(4,4,PtchAmnt); %build CP cell tenzor to include all points of surfaces
CPAmnt=16; %16 for cubic bezier surface. needs to be a squared number. CPAmnt=N^2
N=sqrt(CPAmnt);
for k=1:PtchAmnt
    xy=deal(linspace(-1,1,N)); %both x and y are the same
    [X,Y]=meshgrid(xy,xy);
    X=X*Xscale; Y=Y*Yscale; %X and Y scale
    %Introduce noise, circular translation, and Z surface
    if k==1, X=X*0.5*R; end %correction for first surface
    X=X+rand(size(X))*Xnoise+R*k; %add linear(k) translation in X
    Y=Y+rand(size(Y))*Ynoise;
    Z=rand([N,N])*Znoise;
    CPk=num2cell([X(:),Y(:),Z(:)],2); %to accomidate for format of CP. will be done in two stages
    CPk=reshape(CPk,[N,N]); %insert to CP after second stage formatting
    CP(:,:,k)=CPk; %insert into tenzor
end

CP=FixCP4C1(CP,lambda,myu0,myu1);

% Store the points in MovPush and ResetPntsPush user data
handles.ResetPntsPush.UserData=CP; %saves control points into ResetPntsPush
handles.MovPush.UserData=CP; %saves control points into MovPush

%Change color of MovPush to OrangeBrick - can be used
OrangeBrick=[1,0.5,0.1];
handles.MovPush.BackgroundColor=OrangeBrick;

%Draw on Ax1
DrawInitialAx1(CP,handles);
function ResetPntsPush_Callback(hObject, eventdata, handles)
%Redraws control polygons and curve. saves data in user data
%works exactly the same way as EnterPntPush callback, only the default is
%preset and not a new random

%Obtain lambda and myu0,myu1 
lambda=str2num(handles.LambdaEdit.String);
Myu=str2num(handles.MyuEdit.String);
if isempty(lambda)||isempty(Myu), errordlg('Please input a correct lambda/Myu value','A-lon'); return, end
if lambda<=0, errordlg('lambda value must be positive','A-lon'); return, end
myu0=Myu(1); myu1=Myu(2);

%turn buttons to grass green having the user select
%curve for another activation
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.SurfPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

%New CP from user
CP=handles.ResetPntsPush.UserData; %obtain original control points

%Fix continuaty with new lambda myu0 or myu1 values 
CP=FixCP4C1(CP,lambda,myu0,myu1); %Fix continuaty again if user screwed up shit

%Draw on Ax1
DrawInitialAx1(CP,handles);

%Change color of MovPush to OrangeBrick - can be used
OrangeBrick=[1,0.5,0.1];
handles.MovPush.BackgroundColor=OrangeBrick;
function SelPtchPush_Callback(hObject, eventdata, handles)
%Turns the pointer into a hand to alert the user that it its time to go to
%Ax1 and choose a curve section. Sets the sections
%appropriately.
Fig=handles.Project1;
Fig.Pointer='crosshair';
Ax1=handles.Ax1;
SecHandles=findobj(Ax1,'Tag','Patch');
set(SecHandles,'ButtonDownFcn',{@SelPtchMdownCB,handles})
function MovPush_Callback(hObject, eventdata, handles)
%Asks user to choose new control points. applies C1 algorithm on changed
%points, draws the new surfaces and save CP onto user data
%if elevate/split surfaces was used, user is asked to reset or enter new
%points

LightRed=[0.9,0.6,0.6];
if norm(hObject.BackgroundColor-LightRed)<eps %button is Brick Orange
        errordlg('Please reset or enter new points before continuing','A-lon');
        return
end

%Obtain lambda and myu0,myu1 
lambda=str2num(handles.LambdaEdit.String);
Myu=str2num(handles.MyuEdit.String);
if isempty(lambda)||isempty(Myu), errordlg('Please input a correct lambda/Myu value','A-lon'); return, end
if lambda<=0, errordlg('lambda value must be positive','A-lon'); return, end
myu0=Myu(1); myu1=Myu(2);

%turn buttons to grass green having the user select
%curve for another activation
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.SurfPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

%New CP from user
CP=handles.MovPush.UserData; %obtain original control points
m=size(CP,1); n=size(CP,2); PtchAmnt=size(CP,3);

%ask user which patch he wants to edit
Prompt=sprintf(['Please enter the index of the patch you want to edit\n\n',...
    'Indcies coded by MATLAB lines color.\n1 ~ blue\n2 ~ red\n3 ~ yellow\n4 ~ purple\n5 ~ green\n\n']);
Uinput=inputdlg(Prompt,'Patch Selection',1,{'1'});
if isempty(Uinput), return, end
EditPtchInd=str2num(Uinput{1});
if length(EditPtchInd)>1, errordlg('Please Choose one patch only'); return; end
if EditPtchInd>PtchAmnt, errordlg('Patch index exceeds inital Patch amount'); return; end

%Create cell array of strings for Prompt (see next Prompt variable)
CbcBezCPInd={'[1,1]','[1,2]','[1,3]','[1,4]';
              '[2,1]','[2,2]','[2,3]','[2,4]';
              '[3,1]','[3,2]','[3,3]','[3,4]';
              '[4,1]','[4,2]','[4,3]','[4,4]';};
CbcBezCPInd=CbcBezCPInd(:);
%allows user to edit control points
%split inputs into two groups as inputdlg is a bit retarded and has no
%scroll option
CPk=CP(:,:,EditPtchInd);
DefPnts=cell2mat(CPk(:));
DefPnts=cellstr(num2str(DefPnts)); %create prompt for inputdlg
%first input
DefPnts1=DefPnts(1:8);
Prompt1=strcat('Point Number ',CbcBezCPInd(1:8));
Prompt1{1}=sprintf(['Patch %g\nEnter control point vectors [x,y,z] indexed [u,v]\n\n'...
    'stiching is made along the v=const direction. See "info" pushbutton\n\n',Prompt1{1}],EditPtchInd);
Uinput1=inputdlg(Prompt1,'Bezier control points selection',1,DefPnts1,'on');
if isempty(Uinput1), return, end
%second input
DefPnts2=DefPnts(9:16);
Prompt2=strcat('Point Number ',CbcBezCPInd(9:16));
Prompt2{1}=sprintf(['Patch %g\nEnter control point vectors [x,y,z] indexed [u,v]\n\n',...
    'stiching is made along the u=const direction\n\n',Prompt2{1}],EditPtchInd);
Uinput2=inputdlg(Prompt2,'Bezier control points selection',1,DefPnts2,'on');
if isempty(Uinput2), return, end
%Obtain control points from user
CPk=reshape(cellfun(@str2num ,[Uinput1;Uinput2],'un',0),[m,n]); %Obtain points from user
CP(:,:,EditPtchInd)=CPk;

%Fix C1 while making sure that the changed points in the selected patch are
%changed the way the user wanted
if PtchAmnt>1 %if only 1 patch, no point fixing continuaty
    switch EditPtchInd       
        case 1 %first patch
            CP1=CP(:,:,[1,2]);
            CP1C1=FixCP4C1(CP1,lambda,myu0,myu1);
            CP(:,:,[1,2])=CP1C1;
        case PtchAmnt %last patch
            CP1=CP(:,:,[PtchAmnt,PtchAmnt-1]);
            CP1=fliplr(CP1);
            CP1C1=FixCP4C1(CP1,lambda,myu0,myu1);
            CP1C1=fliplr(CP1C1);
            CP(:,:,[PtchAmnt-1,PtchAmnt])=CP1C1(:,:,[2,1]);
        otherwise %some patch in the middle
            CP1=CP(:,:,[EditPtchInd,EditPtchInd+1]);
            CP1C1=FixCP4C1(CP1,lambda,myu0,myu1);
            CP(:,:,[EditPtchInd,EditPtchInd+1])=CP1C1;
            
            CP2=CP(:,:,[EditPtchInd,EditPtchInd-1]);
            CP2=fliplr(CP2);
            CP2C1=FixCP4C1(CP2,lambda,myu0,myu1);
            CP2C1=fliplr(CP2C1);
            CP(:,:,[EditPtchInd-1,EditPtchInd])=CP2C1(:,:,[2,1]);
    end
end

%Draw on Ax1
DrawInitialAx1(CP,handles);

%save to user data
handles.MovPush.UserData=CP;
%Mouse down callbacks for selection and deselection
function SelPtchMdownCB(Ptch,~,handles)
%Obtain previous Ptch and make sure it has no edge lines (indicator off),
%if wasnt deleted
OldSelPtch=handles.SelPtchPush.UserData;
if isvalid(OldSelPtch), OldSelPtch.EdgeColor='none'; end

%Activates when a user selected a section in Ax1.
%Turns the grassgreen buttons light green and SelPtchPush to
%section's data
Fig=handles.Project1;
Fig.Pointer='arrow'; %change the cursor back to an arrow

%input patch handle into SelPtch PushButton
handles.SelPtchPush.UserData=Ptch;

%point out that a section was selected
GrassGreen=[0.47,0.67,0.19]; %section unchosen color
handles.SurfPush.BackgroundColor=GrassGreen+0.2; 
handles.ElvPush.BackgroundColor=GrassGreen+0.2;
handles.SplitPush.BackgroundColor=GrassGreen+0.2;
handles.PlayPush.BackgroundColor=GrassGreen+0.2;

%show edges as indicator of selection
Ptch.EdgeColor=Ptch.FaceColor*0.9;
function WrongMdownCB(~,~,handles)
%Activates when the user has clicked on Ax1 or on a scattered point
%Marks unreadyness of the system - turns all green push to grass green
%user needs to select a new section
Fig=handles.Project1;
Fig.Pointer='arrow'; %change the cursor back to an arrow
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.SurfPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

%Obtain Patch handle and turn indicator off (if wasnt deleted)
PtchH=handles.SelPtchPush.UserData;
if isvalid(PtchH), PtchH.EdgeColor='none'; end
%Q2 callbacks - plot xyz as a function of u
function SurfPush_Callback(hObject, eventdata, handles)
GrassGreen=[0.47,0.67,0.19]; %section unchosen
if norm(hObject.BackgroundColor-GrassGreen)<eps %button is light green - no section chosen
    errordlg('Please select a patch before clicking the plot button','A-lon');
    return 
else
    %continue, but turn button to grass green having the user reselect
    %curve for another activation
    handles.SurfPush.BackgroundColor=GrassGreen; 
    handles.ElvPush.BackgroundColor=GrassGreen;
    handles.SplitPush.BackgroundColor=GrassGreen;
    handles.PlayPush.BackgroundColor=GrassGreen;
end

PtchH=handles.SelPtchPush.UserData;
%turn indicator off
PtchH.EdgeColor='none';
%Obtain section data
k=PtchH.UserData.Number;

%obtain relevant points
[PtchPnts,U,V]=CPk2PtchPnts(PtchH.UserData.PtchCP);
%PtchPnts - mxnx3 matrix where each depth dimension represents [x,y,z]
%U,V are meshgrid points for PtchPnts

%Plot it all up
LineColors=lines(k); %Colors
SurfColor=LineColors(k,:);
LightBrown=[0.93,0.9,0.6];
SurfFig=figure('name',['XYZ as a function u for section ',num2str(k)],'color',LightBrown);
SurfAx1=subplot(3,1,1,'parent',SurfFig);
SurfAx2=subplot(3,1,2,'parent',SurfFig);
SurfAx3=subplot(3,1,3,'parent',SurfFig);
surf(SurfAx1,U,V,PtchPnts(:,:,1),'facecolor',SurfColor,'edgecolor','none','facealpha',0.6);
surf(SurfAx2,U,V,PtchPnts(:,:,2),'facecolor',SurfColor,'edgecolor','none','facealpha',0.6);
surf(SurfAx3,U,V,PtchPnts(:,:,3),'facecolor',SurfColor,'edgecolor','none','facealpha',0.6);
grid(SurfAx1,'on'); grid(SurfAx2,'on'); grid(SurfAx3,'on');
xlabel(SurfAx1,'u'); ylabel(SurfAx1,'v'); zlabel(SurfAx1,'X');
xlabel(SurfAx2,'u'); ylabel(SurfAx2,'v'); zlabel(SurfAx2,'Y');
xlabel(SurfAx3,'u'); ylabel(SurfAx3,'v'); zlabel(SurfAx3,'Z');
title(SurfAx1,['Patch number ',num2str(k)]);
%Q3 callbacks - increase section degree
function ElvPush_Callback(hObject, eventdata, handles)
GrassGreen=[0.47,0.67,0.19]; %section unchosen
if norm(hObject.BackgroundColor-GrassGreen)<eps %button is light green - no section chosen
    errordlg('Please select a surface before clicking the Elevate button','A-lon');
    return 
else
    %continue, but turn button to grass green having the user reselect
    %curve for another activation
    handles.SurfPush.BackgroundColor=GrassGreen; 
    handles.ElvPush.BackgroundColor=GrassGreen;
    handles.SplitPush.BackgroundColor=GrassGreen;
    handles.PlayPush.BackgroundColor=GrassGreen;
end

%Obtain handle data - Patch and Ax
PtchH=handles.SelPtchPush.UserData;
PtchCP=PtchH.UserData.PtchCP;
k=PtchH.UserData.Number;

%turn indicator off
PtchH.EdgeColor='none';

%obtain relevant curve points
PtchPnts=CPk2PtchPnts(PtchCP);

%Plot it all up
LineColors=lines(k); %Colors
PtchColor=LineColors(k,:);
LightBrown=[0.93,0.9,0.6];
PlotFig=figure('name',['Increase Degree of Patch ',num2str(k)],'color',LightBrown);
ElvAx=axes('parent',PlotFig,'units','normalized','outerposition',[0.2,0,0.8,1]);
grid(ElvAx,'on'); hold(ElvAx,'on'); xlabel(ElvAx,'X'); ylabel(ElvAx,'Y'); zlabel(ElvAx,'Z');
view(ElvAx,3);
UlnAmnt=size(PtchCP,2); VlnAmnt=size(PtchCP,1);
title(ElvAx,sprintf('Increase Degree of Patch %g\n u degree - %g\nv degree - %g',k,UlnAmnt-1,VlnAmnt-1));
surf(ElvAx,PtchPnts(:,:,1),PtchPnts(:,:,2),PtchPnts(:,:,3),...
    'facecolor',PtchColor,'edgecolor','none','facealpha',0.6); %plot curve section
PltH=PltPtchCPLines(ElvAx,PtchCP,k); %plots and returns handles of all lines connecting between ordered control points
CPkCol=cell2mat(PtchCP(:)); %Col is acutally a matrix of [X,Y,Z] of all CP in patch with no account to order
SctH=scatter3(ElvAx,CPkCol(:,1),CPkCol(:,2),CPkCol(:,3),20,PtchColor,'filled'); %plot control points

%Set Axes limits to manual so they wont change with degree elevation
axis(ElvAx,'manual');

%Place pushbuttons
ElvUH=uicontrol('Parent',PlotFig,'Style','push','String','Elevate u','units','normalized','position',[0.02,0.8,0.2,0.1],...
    'backgroundcolor',GrassGreen+0.2,'fontsize',12);
ElvVH=uicontrol('Parent',PlotFig,'Style','push','String','Elevate v','units','normalized','position',[0.02,0.6,0.2,0.1],...
    'backgroundcolor',GrassGreen+0.2,'fontsize',12);
ElvUH.Callback={@ElvUCB,ElvAx,ElvVH}; ElvVH.Callback={@ElvVCB,ElvAx,ElvUH};
ResetH=uicontrol('Parent',PlotFig,'Style','push','String','Reset','units','normalized','position',[0.02,0.4,0.2,0.1],...
    'backgroundcolor',GrassGreen+0.2,'fontsize',12,'Callback',{@ResetElvSecCB,ElvAx,ElvVH,ElvUH});
ImpH=uicontrol('Parent',PlotFig,'Style','push','String','Implement','units','normalized','position',[0.02,0.2,0.2,0.1],...
    'backgroundcolor',GrassGreen+0.2,'fontsize',12,'Callback',{@ImpElvSecCB,ElvVH,handles});

%input kSecPnt into IncH user data. will be used to initailize the degree
%increase which works by control points. number is also placed for coloring
ElvVH.UserData.PtchCP=PtchCP;
ElvVH.UserData.Number=k+1;
ElvVH.UserData.CntrlH=[PltH,SctH];
ElvUH.UserData.PtchCP=PtchCP;
ElvUH.UserData.Number=k+1;
ElvUH.UserData.CntrlH=[PltH,SctH];

%ResetH user data obtain inital condition of control points and k for
%coloring
ResetH.UserData.PtchCP=PtchCP;
ResetH.UserData.Number=k;

%Input original k for title in ElvAx
ElvAx.UserData=k;

%Change color of MovPush to LightRed - can't be used
LightRed=[0.9,0.6,0.6];
handles.MovPush.BackgroundColor=LightRed;
function ElvVCB(ElvVH,~,ElvAx,ElvUH)
%Obtain relevant data from user data
CP=ElvVH.UserData.PtchCP;
k=ElvVH.UserData.Number;
CntrlH=ElvVH.UserData.CntrlH;
PltH=CntrlH(1:end-1); SctH=CntrlH(end);
% set(PltH,'color',[0.6,0.6,0.6]);
% set(SctH,'sizedata',5,'markerfacecolor',[0.6,0.6,0.6]);
set([PltH,SctH],'visible','off'); %<--------------CHANGE THIS IF U WANT TO. Decided against showing traces of old elevations

%find new control points and plot them
VlnAmnt=size(CP,2);
VlnCP=size(CP,1);
Q=cell(VlnCP+1,VlnAmnt);
for s=1:VlnAmnt
   Q(:,s)=IncCrvDeg(CP(:,s)); 
end
LineColors=lines(k);
PtchColor=LineColors(k,:);
PltH=PltPtchCPLines(ElvAx,Q,k); %plots and returns handles of all lines connecting between ordered control points
CPkCol=cell2mat(Q(:)); %Col is acutally a matrix of [X,Y,Z] of all CP in patch with no account to order
SctH=scatter3(ElvAx,CPkCol(:,1),CPkCol(:,2),CPkCol(:,3),20,PtchColor,'filled'); %plot control points
%Update Title
PatchNum=ElvAx.UserData;
title(ElvAx,sprintf('Increase Degree of Patch %g\n u degree - %g\nv degree - %g',PatchNum,size(Q,2)-1,size(Q,1)-1));

%Place new relevant data into user data for next iteration
ElvVH.UserData.PtchCP=Q;
ElvVH.UserData.Number=k+1;
ElvVH.UserData.CntrlH=[PltH,SctH];
ElvUH.UserData.PtchCP=Q;
ElvUH.UserData.Number=k+1;
ElvUH.UserData.CntrlH=[PltH,SctH];
function ElvUCB(ElvUH,~,ElvAx,ElvVH)
%Obtain relevant data from user data
CP=ElvUH.UserData.PtchCP;
k=ElvUH.UserData.Number;
CntrlH=ElvUH.UserData.CntrlH;
PltH=CntrlH(1:end-1); SctH=CntrlH(end);
% set(PltH,'color',[0.6,0.6,0.6]);
% set(SctH,'sizedata',5,'markerfacecolor',[0.6,0.6,0.6]);
set([PltH,SctH],'visible','off'); %<--------------CHANGE THIS IF U WANT TO Decided against showing traces of old elevations

%find new control points and plot them
UlnAmnt=size(CP,1);
UlnCP=size(CP,2);
Q=cell(UlnAmnt,UlnCP+1);
for s=1:UlnAmnt
   Q(s,:)=IncCrvDeg(CP(s,:)); 
end
LineColors=lines(k);
PtchColor=LineColors(k,:);
PltH=PltPtchCPLines(ElvAx,Q,k); %plots and returns handles of all lines connecting between ordered control points
CPkCol=cell2mat(Q(:)); %Col is acutally a matrix of [X,Y,Z] of all CP in patch with no account to order
SctH=scatter3(ElvAx,CPkCol(:,1),CPkCol(:,2),CPkCol(:,3),20,PtchColor,'filled'); %plot control points

%Update Title
PatchNum=ElvAx.UserData;
title(ElvAx,sprintf('Increase Degree of Patch %g\n u degree - %g\nv degree - %g',PatchNum,size(Q,2)-1,size(Q,1)-1));

%Place new relevant data into user data for next iteration
ElvVH.UserData.PtchCP=Q;
ElvVH.UserData.Number=k+1;
ElvVH.UserData.CntrlH=[PltH,SctH];
ElvUH.UserData.PtchCP=Q;
ElvUH.UserData.Number=k+1;
ElvUH.UserData.CntrlH=[PltH,SctH];
function ImpElvSecCB(~,~,ElvVH,handles)
%Obtain relevant data to implement the new control polygon into Ax1
Ax1=handles.Ax1;
Ptch=handles.SelPtchPush.UserData; %the original patch itself
PtchColor=Ptch.FaceColor; %extract color from original patch
k=Ptch.UserData.Number; %extract number from original patch
delete(Ptch.UserData.CntrlH); %Delete old control polygon
PtchCP=ElvVH.UserData.PtchCP; %obtain the new control polygon

%UPDATE PATCH: Draw control polygons and u/v directional bezier curves and
%save data to patch
PltH=PltPtchCPLines(Ax1,PtchCP,k); %plots and returns handles of all lines connecting between ordered control points
PtchCPCol=cell2mat(PtchCP(:)); %Col is acutally a matrix of [X,Y,Z] of all CP in patch with no account to order
SctH=scatter3(Ax1,PtchCPCol(:,1),PtchCPCol(:,2),PtchCPCol(:,3),20,PtchColor,'filled','ButtonDownFcn',{@WrongMdownCB,handles}); %plot control points
Ptch.UserData.PtchCP=PtchCP;
Ptch.UserData.CntrlH=[SctH,PltH];
function ResetElvSecCB(ResetH,~,ElvAx,ElvVH,ElvUH)
%Obtain relevant data from user data
PtchCP=ResetH.UserData.PtchCP;
k=ResetH.UserData.Number;

%plot inital conrol points and curve
cla(ElvAx);
grid(ElvAx,'on'); hold(ElvAx,'on'); xlabel(ElvAx,'X'); ylabel(ElvAx,'Y'); zlabel(ElvAx,'Z');
view(ElvAx,3)
title(ElvAx,sprintf('Increase Degree of Patch %g\n u degree - %g\nv degree - %g',k,size(PtchCP,2)-1,size(PtchCP,1)-1));

LineColors=lines(k);
PtchColor=LineColors(k,:);
PtchPnts=CPk2PtchPnts(PtchCP);
surf(ElvAx,PtchPnts(:,:,1),PtchPnts(:,:,2),PtchPnts(:,:,3),...
    'facecolor',PtchColor,'edgecolor','none','facealpha',0.6); %plot curve section
PltH=PltPtchCPLines(ElvAx,PtchCP,k); %plots and returns handles of all lines connecting between ordered control points
CPkCol=cell2mat(PtchCP(:)); %Col is acutally a matrix of [X,Y,Z] of all CP in patch with no account to order
SctH=scatter3(ElvAx,CPkCol(:,1),CPkCol(:,2),CPkCol(:,3),20,PtchColor,'filled'); %plot control points

%reset data in ElvV and ElvU
ElvVH.UserData.PtchCP=PtchCP;
ElvVH.UserData.Number=k+1;
ElvVH.UserData.CntrlH=[PltH,SctH];
ElvUH.UserData.PtchCP=PtchCP;
ElvUH.UserData.Number=k+1;
ElvUH.UserData.CntrlH=[PltH,SctH];

%Set Axes limits to manual so they wont change with degree elevation
axis(ElvAx,'manual');
%Q4 callbacks - split section
function SplitPush_Callback(hObject, eventdata, handles)
GrassGreen=[0.47,0.67,0.19]; %section unchosen
if norm(hObject.BackgroundColor-GrassGreen)<eps %button is light green - no section chosen
    errordlg('Please select a patch before clicking the Increase button','A-lon');
    return 
else
    %continue, but turn button to grass green having the user reselect
    %curve for another activation
    handles.SurfPush.BackgroundColor=GrassGreen; 
    handles.ElvPush.BackgroundColor=GrassGreen;
    handles.SplitPush.BackgroundColor=GrassGreen;
    handles.PlayPush.BackgroundColor=GrassGreen;
end

%Obtain u and v values
q=str2num(handles.uv4Edit.String);
if isempty(q), errordlg('Please input a correct u value','A-lon'); return, end
if q>1 || q<0, errordlg('value must be between 0 and 1','A-lon'); return, end

%Obtain handle data - Patch and Ax
PtchH=handles.SelPtchPush.UserData;
PtchCP=PtchH.UserData.PtchCP;
Ax1=handles.Ax1;

%turn indicator off
PtchH.EdgeColor='none';

%Obtain k for colors. SplitPush.UserData stores the number of sections that
%were drawn onto Ax1 from initalizing
k=handles.SplitPush.UserData;

%Split the section - obtain new control points
switch handles.SpltPopMenu.Value
    case 1 %u direction
        UlnAmnt=size(PtchCP,1);
        [Q1,Q2]=deal(cell(size(PtchCP)));
        for s=1:UlnAmnt
            [Q1(s,:),Q2(s,:)]=SplitBezCrv(PtchCP(s,:),q);
        end
    case 2 %v direction
        VlnAmnt=size(PtchCP,2);
        [Q1,Q2]=deal(cell(size(PtchCP)));
        for s=1:VlnAmnt
            [Q1(:,s),Q2(:,s)]=SplitBezCrv(PtchCP(:,s),q);
        end
end

%Build new sections and draw them onto Ax1 (setting properties of sections
%included)
LineColor=lines(k+2);
%First Half - Q1
    PltH=PltPtchCPLines(Ax1,Q1,k+1); %plots and returns handles of all lines connecting between ordered control points
    Q1Col=cell2mat(Q1(:)); %Col is acutally a matrix of [X,Y,Z] of all CP in patch with no account to order
    SctH=scatter3(Ax1,Q1Col(:,1),Q1Col(:,2),Q1Col(:,3),20,LineColor(k+1,:),'filled','ButtonDownFcn',{@WrongMdownCB,handles}); %plot control points
    Q1Srf=CPk2PtchPnts(Q1);
    h=surf(Ax1,Q1Srf(:,:,1),Q1Srf(:,:,2),Q1Srf(:,:,3),...
        'facecolor',LineColor(k+1,:),'edgecolor','none','facealpha',0.6); %plot curve section
    h.UserData.Number=k+1;
    h.UserData.PtchCP=Q1;
    h.UserData.CntrlH=[SctH,PltH];
    h.Tag='Patch';
%Second Half - Q2
    PltH=PltPtchCPLines(Ax1,Q2,k+2); %plots and returns handles of all lines connecting between ordered control points
    Q2Col=cell2mat(Q2(:)); %Col is acutally a matrix of [X,Y,Z] of all CP in patch with no account to order
    SctH=scatter3(Ax1,Q2Col(:,1),Q2Col(:,2),Q2Col(:,3),20,LineColor(k+2,:),'filled','ButtonDownFcn',{@WrongMdownCB,handles}); %plot control points
    Q2Srf=CPk2PtchPnts(Q2);
    h=surf(Ax1,Q2Srf(:,:,1),Q2Srf(:,:,2),Q2Srf(:,:,3),...
        'facecolor',LineColor(k+2,:),'edgecolor','none','facealpha',0.6); %plot curve section
    h.UserData.Number=k+2;
    h.UserData.PtchCP=Q2;
    h.UserData.CntrlH=[SctH,PltH];
    h.Tag='Patch';

%set SplitSec UserData for 2 more sections
handles.SplitPush.UserData=k+2;

%delete old section and its control polygon
delete(PtchH.UserData.CntrlH);
delete(PtchH);

%Change color of MovPush to LightRed - can't be used
LightRed=[0.9,0.6,0.6];
handles.MovPush.BackgroundColor=LightRed;
%Q5 callbacks - movie of point building with de Casteljau's 
function PlayPush_Callback(hObject, eventdata, handles)
GrassGreen=[0.47,0.67,0.19];
if norm(hObject.BackgroundColor-GrassGreen)<eps %button is light green - no section chosen
    errordlg('Please select a patch before clicking the Increase button','A-lon');
    return 
else
    %continue, but turn button to grass green having the user reselect
    %curve for another activation
    handles.SurfPush.BackgroundColor=GrassGreen; 
    handles.ElvPush.BackgroundColor=GrassGreen;
    handles.SplitPush.BackgroundColor=GrassGreen;
    handles.PlayPush.BackgroundColor=GrassGreen;
end

%Obtain PauseTime
PauseTime=str2num(handles.PauseEdit.String);
if isempty(PauseTime), errordlg('Please input a correct PauseTime value','A-lon'); return, end
if PauseTime<0, errordlg('PauseTime must be positive','A-lon'); return, end

%Obtain u and v values
uv=str2num(handles.uv5Edit.String);
if isempty(uv), errordlg('Please input a correct u value','A-lon'); return, end
if length(uv)~=2, errordlg('Please input a 1x2 vector','A-lon'); return, end
u=uv(1); v=uv(2);
if u>1 || u<0, errordlg('u must be between 0 and 1','A-lon'); return, end
if v>1 || v<0, errordlg('u must be between 0 and 1','A-lon'); return, end

%Obtain handle data - Patch and Ax
PtchH=handles.SelPtchPush.UserData;
PtchCP=PtchH.UserData.PtchCP;
Ax1=handles.Ax1;

%turn indicator off
PtchH.EdgeColor='none';

%Decastljau on each curve in the V direction to obtain curve for u
VlnAmnt=size(PtchCP,2);
VlnCP=size(PtchCP,1); %number of control points in Vln
UlnCP=VlnAmnt;
[Sct,Plt]=deal(cell(VlnCP,VlnAmnt)); %cell matrix to hold plotting handles
Colors=copper(VlnCP+UlnCP);
Q=PtchCP; %Initailize

%first iteration - plot current control points
for s=1:VlnAmnt
R=Q(:,s);
PltR=cell2mat(R);
Plt{1,s}=plot3(Ax1,PltR(:,1),PltR(:,2),PltR(:,3),...
    'color',Colors(1,:),'linew',1);
Sct{1,s}=scatter3(Ax1,PltR(:,1),PltR(:,2),PltR(:,3),...
    20,Colors(1,:),'filled','marker','o','MarkerEdgeColor','k');
end
pause(PauseTime);
k=1; %Initalizie
%do the rest of the v direction procedure
while VlnCP-k>0 %decrease by one point each time, until 1 point is left
    R=cell(VlnCP-k,VlnAmnt);
for s=1:VlnAmnt
    Spnts=BezCrvDecrease(Q(:,s),v);
    R(:,s)=Spnts;
    PltSpnts=cell2mat(Spnts);
    Plt{k+1,s}=plot3(Ax1,PltSpnts(:,1),PltSpnts(:,2),PltSpnts(:,3),...
        'color',Colors(k+1,:),'linew',1);
    Sct{k+1,s}=scatter3(Ax1,PltSpnts(:,1),PltSpnts(:,2),PltSpnts(:,3),...
        20,Colors(k+1,:),'filled','marker','o','MarkerEdgeColor','k');
end
    Q=R;
    k=k+1;
    pause(PauseTime);
end
pause(PauseTime*1.5) %Major Pause in the change to u
delete([Plt{:},Sct{:}]); %delete handles of v direction computation

Q=Q'; %turn to column vec

%Run on the created curve from before with u parameter
%UlnCP defined at top for Colors
[Sct,Plt]=deal(cell(UlnCP,1)); %cell matrix to hold plotting handles
k=1;
%Plot intermidiate points (last of v direction and first in u direction)
PltR=cell2mat(Q);
Plt{1}=plot3(Ax1,PltR(:,1),PltR(:,2),PltR(:,3),...
    'color',Colors(VlnCP,:),'linew',1);
Sct{1}=scatter3(Ax1,PltR(:,1),PltR(:,2),PltR(:,3),...
    20,Colors(VlnCP,:),'filled','marker','o','MarkerEdgeColor','k');
pause(PauseTime);
%Plot the rest of them
while UlnCP-k>0 %decrease by one point each time, until 1 point is left
    R=BezCrvDecrease(Q,u);  
    PltR=cell2mat(R);
    Plt{k+1}=plot3(Ax1,PltR(:,1),PltR(:,2),PltR(:,3),...
        'color',Colors(k+VlnCP,:),'linew',1);
    Sct{k+1}=scatter3(Ax1,PltR(:,1),PltR(:,2),PltR(:,3),...
        20,Colors(k+VlnCP,:),'filled','marker','o','MarkerEdgeColor','k');
    Q=R;
    k=k+1;
    pause(PauseTime);
end
pause(PauseTime);
delete([Plt{:},Sct{:}]); %delete handles of u direction computation

%Draw last point for emphasis 
Sct=scatter3(Ax1,PltR(:,1),PltR(:,2),PltR(:,3),...
    20,Colors(k+VlnCP,:),'filled','marker','o','MarkerEdgeColor','k');
pause(PauseTime*1.5);
delete(Sct);
%Additional Push functions
function TeaPotPush_Callback(hObject, eventdata, handles)
%turn button to grass green having the user reselect patch if needed
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.SurfPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

[Folder,~,~]=fileparts(mfilename('fullpath'));
FileName=[Folder,'\Teapot.mat'];
load(FileName,'Teapot');
DrawInitialAx1(Teapot,handles);

%Change color of MovPush to LightRed - can't be used
LightRed=[0.9,0.6,0.6];
handles.MovPush.BackgroundColor=LightRed;
function TentPush_Callback(hObject, eventdata, handles)
%turn button to grass green having the user reselect patch if needed
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.SurfPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

[Folder,~,~]=fileparts(mfilename('fullpath'));
FileName=[Folder,'\Tent.mat'];
load(FileName,'Tent');
DrawInitialAx1(Tent,handles);

%Change color of MovPush to LightRed - can't be used
LightRed=[0.9,0.6,0.6];
handles.MovPush.BackgroundColor=LightRed;
function StumpPush_Callback(hObject, eventdata, handles)
%turn button to grass green having the user reselect patch if needed
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.SurfPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

[Folder,~,~]=fileparts(mfilename('fullpath'));
FileName=[Folder,'\Stump.mat'];
load(FileName,'Stump');
DrawInitialAx1(Stump,handles);

%Change color of MovPush to LightRed - can't be used
LightRed=[0.9,0.6,0.6];
handles.MovPush.BackgroundColor=LightRed;
function InfoPush_Callback(hObject, eventdata, handles)
helpdlg(sprintf(['u direction can be spotted by ".-" lines between control points\n',...
        'v direction lines between control points have "- -" lines']),'A-lon');
function PointsAndLinesToggle_Callback(hObject, eventdata, handles)
%if on - shows all control points and control lines
% if off - hides all control points and control lines

if hObject.Value==0
    LineHandles=findobj(handles.Ax1,'Type','Line');
    ScatterHandles=findobj(handles.Ax1,'Type','Scatter');
    set(LineHandles,'Visible','off');
    set(ScatterHandles,'Visible','off');
else
    LineHandles=findobj(handles.Ax1,'Type','Line');
    ScatterHandles=findobj(handles.Ax1,'Type','Scatter');
    set(LineHandles,'Visible','on');
    set(ScatterHandles,'Visible','on');
end
function LimitsPopMenu_Callback(hObject, eventdata, handles)
Ax1=handles.Ax1;
switch hObject.Value
    case 1 %sets limits to auto
        axis(Ax1,'auto'); 
    case 2 %sets limits to manual
        axis(Ax1,'manual');
end
%% Functions
%calculte points and draw 
function DrawInitialAx1(CP,handles)
%% Initalize
%Draws cubic bezier patches on Ax1 and save relevant data to appropiate patches handles
%draws control point and lines between control points

%Control points will be in the form of nxmxk cell matrix of points inside
%a tenzor of patches where CP(:,:,k) holds the control points for patch number k
%EXAMPLE: CP(:,:,k)= {[x11,y11,z11]},{[x12,y12,z12]},{[x13,y13,z13]} -----> u
%           {[x21,y21,z21]},{[x22,y22,z22]},{[x23,y23,z23]}
%           |
%           |
%           |
%       v   V

PtchAmnt=size(CP,3);
%save PtchAmnt into SplitPush user data for later on splitting
handles.SplitPush.UserData=PtchAmnt;
%% Draw onto Ax1
Ax1=handles.Ax1;
cla(Ax1); grid(Ax1,'on'); hold(Ax1,'on'); view(Ax1,3);
xlabel(Ax1,'x');  ylabel(Ax1,'y'); zlabel(Ax1,'z');
LineColor=lines(PtchAmnt);

%Draw control polygons and u/v directional bezier curves
for k=1:PtchAmnt
    CPk=CP(:,:,k);
    PltH{k}=PltPtchCPLines(Ax1,CPk,k); %plots and returns handles of all lines connecting between ordered control points
    CPkCol=cell2mat(CPk(:)); %Col is acutally a matrix of [X,Y,Z] of all CP in patch with no account to order
    SctH{k}=scatter3(Ax1,CPkCol(:,1),CPkCol(:,2),CPkCol(:,3),20,LineColor(k,:),'filled','ButtonDownFcn',{@WrongMdownCB,handles}); %plot control points
end
%Draw Patch  and u/v direction bezier curves
%IMPORTANT: inserts the number of the section and some more into its user data
for k=1:PtchAmnt
    CPk=CP(:,:,k);
    PtchPntsk=CPk2PtchPnts(CPk);
    h=surf(Ax1,PtchPntsk(:,:,1),PtchPntsk(:,:,2),PtchPntsk(:,:,3),...
    'facecolor',LineColor(k,:),'edgecolor','none','facealpha',0.6); %plot curve section
    h.UserData.Number=k;
    h.UserData.PtchCP=CP(:,:,k);
    h.UserData.CntrlH=[SctH{k},PltH{k}];
    h.Tag='Patch';
end

%Input the last patch into SelPtch for initalzing
handles.SelPtchPush.UserData=h;
function R=BezCrvDeCasteljau(CP,q)
%CP - cell array of control points. can be row or column. each cell
%contains [X,Y,Z]
%q - running parameter of bezier curve. 0=<q<=1
%R - [X,Y,Z] point on bezier curve
% https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/de-casteljau.html

Q=cell2mat(CP(:)); %turns cell array of points {[X,Y,Z]} into a NX3 matrix (N is the number of control points)
n=size(Q,1)-1; %degree of bezier polynomial
for k=1:(n+1)
    for i=1:(n+1-k) %doesnt enter in first iteration
        Q(i,:)=(1-q)*Q(i,:)+q*Q(i+1,:);
    end
end
R=Q(1,:);
function R=BezPtchDeCasteljau(CPk,u,v)
%Referance https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/surface/bezier-de-casteljau.html
%u,v - numeric running values of patch (running 0 to 1)
% CPk=Patch control points in mxn cell array of numeric cartisian vectors
%EXAMPLE: CPk(:,:)= {[x11,y11,z11]},{[x12,y12,z12]},{[x13,y13,z13]} -----> u
%           {[x21,y21,z21]},{[x22,y22,z22]},{[x23,y23,z23]}
%           |
%           |
%           |
%       v   V

%runs algorithem on VLines with parameter v to obtain a set of points. the
%the run on those points with paramter u to obtain R(u,v)
VlnAmnt=size(CPk,2);
q=zeros(VlnAmnt,3); %Initalize
for j=1:VlnAmnt
    q(j,:)=BezCrvDeCasteljau(CPk(:,j),v); %q(j,:) is of the form [X,Y,Z]
end
q=num2cell(q,2); %turn q into a cell array of points
R=BezCrvDeCasteljau(q,u);
function Rvec=BezCrvDecrease(CP,q)
%CP - control points array in cell format {[1,2,3],...}
%q - running parameter of bezier curve. 0=<q<=1
%R - same format as CP, but after one iteration of de-castlaju was made
% https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/de-casteljau.html
n=length(CP)-1; %degree of bezier polynomial-
CP=cell2mat(CP(:)); %extract to control points in [X,Y,Z] mx3 format
Q=zeros(n,3); %initalize
for i=1:n
    Q(i,:)=(1-q)*CP(i,:)+q*CP(i+1,:);
end
Rvec=num2cell(Q,2);
function [PtchPnts,U,V]=CPk2PtchPnts(CPk)
% CPk=Patch control points in mxn cell array of numeric cartisian vectors
%EXAMPLE: CPk(:,:)= {[x11,y11,z11]},{[x12,y12,z12]},{[x13,y13,z13]} -----> u
%           {[x21,y21,z21]},{[x22,y22,z22]},{[x23,y23,z23]}
%           |
%           |
%           |
%       v   V

%returns PtchPnts - numeric matrix NxNx3 containing (:,:[X,Y,Z]) of patch
N=30;
PtchPnts=zeros(N,N,3); %initalize
u=linspace(0,1,N);
v=linspace(0,1,N);
[U,V]=meshgrid(u,v);
for i=1:N
    for j=1:N
        R=BezPtchDeCasteljau(CPk,U(i,j),V(i,j));
        PtchPnts(i,j,1)=R(1); PtchPnts(i,j,2)=R(2); PtchPnts(i,j,3)=R(3);
    end
end
function CrvPnts=CP2CrvPnts(CrvCP,N)
%CP - cell array of control points. can be row or column. each cell
%contains [X,Y,Z]
%BezCrvPnts - cell array containing in the format of [X,Y,Z]
q=linspace(0,1,N);
CrvPnts=zeros(N,3);
for i=1:N
CrvPnts(i,:)=BezCrvDeCasteljau(CrvCP,q(i));
end
CrvPnts=num2cell(CrvPnts,2);
function [uCrvPnts,vCrvPnts]=Ptch2uvCrvPnts(CPk)
% CPk=Patch control points in mxn cell array of numeric cartisian vectors
%EXAMPLE: CPk(:,:)= {[x11,y11,z11]},{[x12,y12,z12]},{[x13,y13,z13]} -----> u
%           {[x21,y21,z21]},{[x22,y22,z22]},{[x23,y23,z23]}
%           |
%           |
%           |
%       v   V
%
%returns uCrvPnts and vCrvPnts - cell array matrices where each column
%contains the points in [X,Y,Z] format for one curve
VlnAmnt=size(CPk,2);
UlnAmnt=size(CPk,1);
N=30;
vCrvPnts=cell(N,VlnAmnt);
uCrvPnts=cell(N,UlnAmnt);
for i=1:UlnAmnt
    uCrvPnts(:,i)=CP2CrvPnts(CPk(i,:),N); 
end
for j=1:VlnAmnt
    vCrvPnts(:,j)=CP2CrvPnts(CPk(:,j),N);
end
function h=PltPtchCPLines(Ax1,CPk,k)
%CPk - cell nxm matrix where each cell contains control point in (v,u)
%direction.
%k - numeric number (patch number since creation of current set) for line color
LineColor=lines(k);
% ULnAmnt=size(CPk,1);
VLnAmnt=size(CPk,2);
CPk=cell2mat(CPk);

Colxind=1:3:(VLnAmnt*3-2); Colyind=2:3:(VLnAmnt*3-1); Colzind=3:3:VLnAmnt*3;
VLnx=CPk(:,Colxind); VLny=CPk(:,Colyind); VLnz=CPk(:,Colzind); %Matrices of size CP per line x VLnAmnt - [Vln1,Vln2..]
VLnh=plot3(Ax1,VLnx,VLny,VLnz,'color',LineColor(k,:),'lines','--','linew',0.1,'hittest','off');
ULnx=VLnx'; ULny=VLny'; ULnz=VLnz'; %Matrices of size UlnAmnt x CP per line - [Vln1,Vln2..
ULnh=plot3(Ax1,ULnx,ULny,ULnz,'color',LineColor(k,:),'lines','-.','linew',0.1,'hittest','off');
h=[VLnh;ULnh]'; %returns all handles in row format
function h=PltuvCrvs(Ax1,CPk) %NOT IN USE
% CPk=Patch control points in mxn cell array of numeric cartisian vectors
%EXAMPLE: CPk(:,:)= {[x11,y11,z11]},{[x12,y12,z12]},{[x13,y13,z13]} -----> u
%           {[x21,y21,z21]},{[x22,y22,z22]},{[x23,y23,z23]}
%           |
%           |
%           |
%       v   V
%Ax1 - axes handle
%returns the handles to all the curve lines
[uCrvPnts,vCrvPnts]=Ptch2uvCrvPnts(CPk);
UlnAmnt=size(uCrvPnts,2); VlnAmnt=size(vCrvPnts,2);
for i=1:UlnAmnt
   Crv=cell2mat(uCrvPnts(:,i));
   uCrvh(i)=plot3(Ax1,Crv(:,1),Crv(:,2),Crv(:,3),'linestyle','--','color','k','linew',0.5,'hittest','off');
end
for j=1:VlnAmnt
   Crv=cell2mat(vCrvPnts(:,j));
   vCrvh(i)=plot3(Ax1,Crv(:,1),Crv(:,2),Crv(:,3),'linestyle','--','color','k','linew',0.5,'hittest','off');
end
h=[uCrvh,vCrvh];
%for C1 projections and fixes
function CPC1=FixCP4C1(CP,lambda,myu0,myu1)
%stitches along the u direction

% Control points will be in the form of nxmxk cell matrix of points inside
%a tenzor of patches where CP(:,:,k) holds the control points for patch number k
%EXAMPLE: CP(:,:,k)= {[x11,y11,z11]},{[x12,y12,z12]},{[x13,y13,z13]} -----> u
%           {[x21,y21,z21]},{[x22,y22,z22]},{[x23,y23,z23]}
%           |
%           |
%           |
%       v   V

%lambda>=0
%myu(v)=myu0+myu1*v
%if myu0=myu1=0 then the algorithem degenerates to case 1 in the book

%PAGE 216 in Faux and Pratt "Computational Geomtrey for Design and
%Manufacture".
%CP points equivalnent in the book for my patch cell matrix are:
%[r0 r10 r20 r30
%r01 r11 r21 r31
%r02 r12 r22 r32
%r03 r13 r23 r32]

if nargin<2, lambda=1; end
if nargin<3, myu0=0; end
if nargin<4, myu1=1; end

CPC1=CP; %Initalize

for k=2:size(CP,3)
    CPp=CP(:,:,k-1); %p for prev
    CPk=CP(:,:,k);
    
    CPk(:,1)=CPp(:,4); %shared v direction curve
    CPk{1,2}=CPk{1,1}+lambda*(CPp{1,4}-CPp{1,3})+myu0*(CPp{2,4}-CPp{1,4});
    CPk{2,2}=CPk{2,1}+lambda*(CPp{2,4}-CPp{2,3})+(1/3)*myu0*(2*CPp{3,4}-CPp{2,4}-CPp{1,4})+(1/3)*myu1*(CPp{2,4}-CPp{1,4});
    CPk{3,2}=CPk{3,1}+lambda*(CPp{3,4}-CPp{3,3})+(1/3)*myu0*(CPp{4,4}+CPp{3,4}-2*CPp{2,4})+(2/3)*myu1*(CPp{3,4}-CPp{2,4});
    CPk{4,2}=CPk{4,1}+lambda*(CPp{4,4}-CPp{4,3})+(myu0+myu1)*(CPp{4,4}-CPp{3,4});
    
    CPC1(:,:,k)=CPk; %insert to CPC1
end
%for Split and increase degree
function [Q1,Q2]=SplitBezCrv(P,u)
%Given control points P of cubic bezier curve u, split the bezier curve in p(u) to
%q1,q2 who belong to control points Q1,Q2.
%P,Q1,Q2 are of the format - cell{[X1,Y1,Z1],...} -  matrix

%Algorithm for Cubic bezier splitting
%control polygon P contains 3 lines
%split them with u ratio to create 3 new vertices K1,K2,K3 (by order)
%connect K1-K2 and K2-K3 with a line, and split them with u ratio again to
%create M1,M2. Finally connect M1,M2 with a line and split it u-wise to obtain the last point F==P(u).
% Q1=[P(1,:);K1;M1;F]; Q2=[F,M2;K3;P(4,:)];
%and in code:
% K1=u*P(1,:)+(1-u)*P(2,:);
% K2=u*P(2,:)+(1-u)*P(3,:);
% K3=u*P(3,:)+(1-u)*P(4,:);
% M1=u*K1+(1-u)*K2;
% M2=u*K2+(1-u)*K3;
% F=u*M1+(1-u)*M2;
% Q1=[P(1,:);K1;M1;F]; Q2=[F;M2;K3;P(4,:)];

%Unfourntly, We require one for n dimension bezier curve. here we go:
% https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/de-casteljau.html

%Honest to god, I have no fking clue about what is going on here.
%algorithm works without me needing to use brains.
P=P(:); %make it a column
n=length(P)-1;
Q=cell2mat(P); %turn to matrix format of mx3 [X,Y,Z] points
[Q1,Q2]=deal(zeros(size(Q)));
for k=1:(n+1)
    Q1(k,:)=Q(1,:);
    for i=1:(n+1-k) %doesnt enter in for first iteration
        Q(i,:)=(1-u)*Q(i,:)+u*Q(i+1,:);
    end
    Q2(k,:)=Q(n+2-k,:);
end
%flip Q2 so that bez(Q1,u=1)==bez(Q2,u=0)
Q2=flipud(Q2);
Q1=num2cell(Q1,2); Q2=num2cell(Q2,2); %turn back to cell format
function Q=IncCrvDeg(P)
%returns increased degree (+1) bezier curve control points 
%Q and P are both in the format of num2mat(mx3) ~ num2cell([X,Y,Z])
%Algorithem works like de castilaju, only that the ratio between points
%varies, and as a function of the degree
%help from https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/bezier-elev.html

%Algorithm in older but more explicit code:
% Q=zeros(n+2,3);
% Q(1,:)=P(1,:);
% for i=1:n
%     Q(i+1,:)=(i/(n+1))*P(i,:)+(1-(i/(n+1)))*P(i+1,:);
% end
% Q(n+2,:)=P(n+1,:);

P=cell2mat(P(:));
n=size(P,1)-1; %degree of polynom is number of control points -1
I=(1:n)'/(n+1); %matrix of weights per Q point [Xw,Yw,Zw] - w is the disance between Pi and Q and (1-w) is the distance between Q and Pi+1
Q=[P(1,:);I.*P(1:end-1,:)+(1-I).*P(2:end,:);P(end,:)];
Q=num2cell(Q,2);
%% GUI Functions - no use
function uv4Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uv4Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function uv5Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uv5Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function PauseEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function uv4Edit_Callback(hObject, eventdata, handles)
function uv5Edit_Callback(hObject, eventdata, handles)
function PauseEdit_Callback(hObject, eventdata, handles)
function SpltPopMenu_Callback(hObject, eventdata, handles)
function SpltPopMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function LambdaEdit_Callback(hObject, eventdata, handles)
function LambdaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LambdaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function MyuEdit_Callback(hObject, eventdata, handles)
function MyuEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MyuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function LimitsPopMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LimitsPopMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
