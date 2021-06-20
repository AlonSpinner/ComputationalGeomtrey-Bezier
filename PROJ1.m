%Project 1 in Computational Geomtrey 1 - 036020 winter 18-19

%---------------Important notes:
%User needs to select a section before using the pushbuttons. it is
%evident to the user through the grassgreen-lightgreen colors on the buttons.

%SecPush.UserData stores the handle of the selected section (line)
%Section line has UserData:
% Sec.UserData.Number=k; - for plot coloring (lines(k))
% Sec.UserData.SecCP=SecCP; - control points
% Sec.UserData.CntrlH=[SctH,PltH]; - handles of control points lines and
% scatters
% Sec.Tag='Section';

%MovPntsPush.UserData stores the inital control points created by Enter/Move Points

%SplitPush.UserData stores the amount of sections that have been plotted
%since the last reset (by move/enter points). For plot colors

%axis(Ax1,'auto') - on DrawInitialAx1.
%axis(Ax1,'manual') - on SplitSec iteractions

function varargout = PROJ1(varargin)
% PROJ1 MATLAB code for PROJ1.fig
%      PROJ1, by itself, creates a new PROJ1 or raises the existing
%      singleton*.
%
%      H = PROJ1 returns the handle to a new PROJ1 or the handle to
%      the existing singleton*.
%
%      PROJ1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJ1.M with the given input arguments.
%
%      PROJ1('Property','Value',...) creates a new PROJ1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PROJ1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PROJ1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PROJ1

% Last Modified by GUIDE v2.5 20-Jun-2021 18:09:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PROJ1_OpeningFcn, ...
                   'gui_OutputFcn',  @PROJ1_OutputFcn, ...
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
function PROJ1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PROJ1 (see VARARGIN)

% Choose default command line output for PROJ1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Update Ax1 ButtonDownFcn to the one that resets cursor and selection
set(handles.Ax1,'ButtonDownFcn',{@WrongMdownCB,handles})

%Enter random points into axes
%Calculate the amount of points needed. Create random default points and
%ask user for input. Input is fixed to accomidate curve C1 continuaty.
SecAmnt=4;
PntsAmnt=4+3*(SecAmnt-1);
Pnts=round(rand(PntsAmnt,3)*10); %create PntsAmntX3 random matrix
Pnts=FixPnts4C1(Pnts); %Fix continuaty
handles.MovPntsPush.UserData=Pnts; %saves control points into MovPntsPush
%Draw on Ax1
DrawInitialAx1(Pnts,handles);
function varargout = PROJ1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%% CallBacks
function u4Edit_Callback(hObject, eventdata, handles)
function u5Edit_Callback(hObject, eventdata, handles)
function PauseEdit_Callback(hObject, eventdata, handles)
%Main Push Buttons
function EnterPntsPush_Callback(hObject, eventdata, handles)
%% Obtain Input
%turn buttons to grass green having the user select
%curve for another activation
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.PlotPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

%Ask for amount of control polygons == Section amounts
SecAmnt={'4'};
Uinput=inputdlg('Enter the amount of control polygons you wish to work with','Control Polygon Amount',1,SecAmnt);
if isempty(Uinput), return, end
SecAmnt=str2num(Uinput{1});
if SecAmnt<0 || mod(SecAmnt,1)~=0, errordlg('control polygons amount must be a natrual number'); return, end

%Calculate the amount of points needed. Create random default points and
%ask user for input. Input is fixed to accomidate curve C1 continuaty.
PntsAmnt=4+3*(SecAmnt-1);
Pnts=round(rand(PntsAmnt,3)*10); %create PntsAmntX3 random matrix
Pnts=FixPnts4C1(Pnts); %Fix continuaty again
handles.MovPntsPush.UserData=Pnts; %saves control points into MovPntsPush

%Draw on Ax1
DrawInitialAx1(Pnts,handles);
function MovPntsPush_Callback(hObject, eventdata, handles)
%Redraws control polygons and curve. saves data in user data
%works exactly the same way as EnterPntPush callback, only the default
%points are the current points that need changing

%turn buttons to grass green having the user select
%curve for another activation
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.PlotPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;

Ax1=handles.Ax1;

%Obtain User Data
DefPnts=handles.MovPntsPush.UserData;
DrawInitialAx1(DefPnts,handles);

%Ask user if he wants to change points
Pnts=DefPnts; %initalize
DefPnts=cellstr(num2str(DefPnts)); %create prompt for inputdlg
PntsAmnt=size(DefPnts,1);
SecAmnt=(PntsAmnt-4)/3+1; %amounts of 3d degree bezier section curves in the major curve

%ask user which section he wants to edit
Prompt=sprintf(['Please enter the indices of the sections you want to edit\n\n',...
    'Indcies coded by MATLAB lines color.\n1 ~ blue\n2 ~ red\n3 ~ yellow\n4 ~ purple\n5 ~ green\n\n',...
    'Points are ordered from the begining to the end of the section\n']);
Uinput=inputdlg(Prompt,'Patch Selection',1,{sprintf('[1:%g]',SecAmnt)});
if isempty(Uinput), return, end
EditSecInd=str2num(Uinput{1});
if max(EditSecInd)>SecAmnt, errordlg('Patch index exceeds inital Patch amount'); return; end

%Obtain the new vertices from user data
for k=EditSecInd
    Prompt=strcat('Point Number ',cellstr(num2str((1:1:4)')));
    Prompt{1}=sprintf(['Section number %g\nEnter control point vectors [x,y,z]\n\n',Prompt{1}],k);
    kDefPntsInd=[3*(k-1)+1:3*(k-1)+4];
    Uinput=inputdlg(Prompt,'Bezier control points selection',1,DefPnts(kDefPntsInd));
    if isempty(Uinput), return, end
    kPnts=cell2mat(cellfun(@str2num ,Uinput,'un',0)); %Obtain points from user
    Pnts(kDefPntsInd,:)=kPnts;
end

[Pnts,WasUsed]=FixPnts4C1(Pnts); %Fix continuaty again
if WasUsed, warndlg('Points were fixed to accomidate C1 in curve stiching','A-lon'); end
%Store the points in MovePntPush user data for point moving
handles.MovPntsPush.UserData=Pnts;

%Draw on Ax1
DrawInitialAx1(Pnts,handles);
function SelSecPush_Callback(hObject, eventdata, handles)
%Turns the pointer into a hand to alert the user that it its time to go to
%Ax1 and choose a curve section. Sets the sections
%appropriately.
Fig=handles.Project1;
Fig.Pointer='crosshair';
Ax1=handles.Ax1;
SecHandles=findobj(Ax1,'Tag','Section');
set(SecHandles,'ButtonDownFcn',{@SelSecMdownCB,handles})
%Mouse down callbacks for selection and deselection
function SelSecMdownCB(Sec,~,handles)
%Activates when a user selected a section in Ax1.
%Turns the grassgreen buttons light green and SelSecPush to
%section's data
Fig=handles.Project1;
Fig.Pointer='arrow'; %change the cursor back to an arrow

%input section handle into SelSec PushButton
handles.SelSecPush.UserData=Sec;

%point out that a section was selected
GrassGreen=[0.47,0.67,0.19]; %section unchosen color
handles.PlotPush.BackgroundColor=GrassGreen+0.2; 
handles.ElvPush.BackgroundColor=GrassGreen+0.2;
handles.SplitPush.BackgroundColor=GrassGreen+0.2;
handles.PlayPush.BackgroundColor=GrassGreen+0.2;
function WrongMdownCB(~,~,handles)
%Activates when the user has clicked on Ax1 or on a scattered point
%Marks unreadyness of the system - turns all green push to grass green
%user needs to select a new section
Fig=handles.Project1;
Fig.Pointer='arrow'; %change the cursor back to an arrow
GrassGreen=[0.47,0.67,0.19]; %section unchosen
handles.PlotPush.BackgroundColor=GrassGreen;
handles.SplitPush.BackgroundColor=GrassGreen;
handles.ElvPush.BackgroundColor=GrassGreen;
handles.PlayPush.BackgroundColor=GrassGreen;
%Q2 callbacks - plot xyz as a function of u
function PlotPush_Callback(hObject, eventdata, handles)
GrassGreen=[0.47,0.67,0.19]; %section unchosen
if norm(hObject.BackgroundColor-GrassGreen)<eps %button is light green - no section chosen
    errordlg('Please select a curve before clicking the plot button','A-lon');
    return 
else
    %continue, but turn button to grass green having the user reselect
    %curve for another activation
    handles.PlotPush.BackgroundColor=GrassGreen; 
    handles.ElvPush.BackgroundColor=GrassGreen;
    handles.SplitPush.BackgroundColor=GrassGreen;
    handles.PlayPush.BackgroundColor=GrassGreen;
end

SecH=handles.SelSecPush.UserData;
%Obtain section data
k=SecH.UserData.Number;

%obtain relevant points
[kCurvePnts,u]=BezDeCasteljau(SecH.UserData.SecCP);

%Plot it all up
LineColors=lines(k); %Colors
PlotColor=LineColors(k,:);
LightBrown=[0.93,0.9,0.6];
PlotFig=figure('name',['XYZ as a function u for section ',num2str(k)],'color',LightBrown);
PlotAx1=subplot(3,1,1,'parent',PlotFig);
PlotAx2=subplot(3,1,2,'parent',PlotFig);
PlotAx3=subplot(3,1,3,'parent',PlotFig);
plot(PlotAx1,u,kCurvePnts(:,1),'color',PlotColor,'linew',2);
plot(PlotAx2,u,kCurvePnts(:,2),'color',PlotColor,'linew',2); 
plot(PlotAx3,u,kCurvePnts(:,3),'color',PlotColor,'linew',2);
grid(PlotAx1,'on'); grid(PlotAx2,'on'); grid(PlotAx3,'on');
xlabel(PlotAx1,'u'); ylabel(PlotAx1,'X');
xlabel(PlotAx2,'u'); ylabel(PlotAx2,'Y');
xlabel(PlotAx3,'u'); ylabel(PlotAx3,'Z');
title(PlotAx1,['Section number ',num2str(k)]);
%Q3 callbacks - increase section degree
function ElvPush_Callback(hObject, eventdata, handles)
GrassGreen=[0.47,0.67,0.19]; %section unchosen
if norm(hObject.BackgroundColor-GrassGreen)<eps %button is light green - no section chosen
    errordlg('Please select a curve before clicking the Elevate button','A-lon');
    return 
else
    %continue, but turn button to grass green having the user reselect
    %curve for another activation
    handles.PlotPush.BackgroundColor=GrassGreen; 
    handles.ElvPush.BackgroundColor=GrassGreen;
    handles.SplitPush.BackgroundColor=GrassGreen;
    handles.PlayPush.BackgroundColor=GrassGreen;
end

%Obtain section data
SecH=handles.SelSecPush.UserData;
k=SecH.UserData.Number;
kSecCP=SecH.UserData.SecCP;

%obtain relevant curve points
kCurvePnts=BezDeCasteljau(kSecCP);

%Plot it all up
LineColors=lines(k); %Colors
PlotColor=LineColors(k,:);
LightBrown=[0.93,0.9,0.6];
PlotFig=figure('name',['Increase Degree of section ',num2str(k)],'color',LightBrown);
ElvAx=axes('parent',PlotFig,'units','normalized','outerposition',[0.2,0,0.8,1]);
grid(ElvAx,'on'); hold(ElvAx,'on'); xlabel(ElvAx,'X'); ylabel(ElvAx,'Y'); zlabel(ElvAx,'Z');
title(ElvAx,['Increase Degree of section ',num2str(k)]);
plot3(ElvAx,kCurvePnts(:,1),kCurvePnts(:,2),kCurvePnts(:,3),'color',PlotColor,'linew',2); %plot curve
scatter3(ElvAx,kSecCP(:,1),kSecCP(:,2),kSecCP(:,3),20,LineColors(k,:),'filled'); %plot points
plot3(ElvAx,kSecCP(:,1),kSecCP(:,2),kSecCP(:,3),'color',LineColors(k,:),'lines','--','linew',0.1); %plot control polygon

%Place pushbuttons
IncH=uicontrol('Parent',PlotFig,'Style','push','String','Elevate','units','normalized','position',[0.02,0.8,0.2,0.1],...
    'backgroundcolor',GrassGreen+0.2,'fontsize',12,'Callback',{@ElvSecCB,ElvAx});
ResetH=uicontrol('Parent',PlotFig,'Style','push','String','Reset','units','normalized','position',[0.02,0.6,0.2,0.1],...
    'backgroundcolor',GrassGreen+0.2,'fontsize',12,'Callback',{@ResetElvSecCB,ElvAx,IncH});
ImpH=uicontrol('Parent',PlotFig,'Style','push','String','Implement','units','normalized','position',[0.02,0.4,0.2,0.1],...
    'backgroundcolor',GrassGreen+0.2,'fontsize',12,'Callback',{@ImpElvSecCB,IncH,handles});

%input kSecPnt into IncH user data. will be used to initailize the degree
%increase which works by control points. number is also placed for coloring
IncH.UserData.SecCP=kSecCP;
IncH.UserData.Number=k;

%ResetH user data obtain inital condition of control points and k for
%coloring
ResetH.UserData.SecCP=kSecCP;
ResetH.UserData.Number=k;
function ElvSecCB(IncH,~,ElvAx)
%Obtain relevant data from user data
P=IncH.UserData.SecCP;
k=IncH.UserData.Number;

%find new control points and plot them
Q=IncSecDeg(P);
LineColors=lines(k+1);
scatter3(ElvAx,Q(:,1),Q(:,2),Q(:,3),20,LineColors(k+1,:),'filled'); %plot points
plot3(ElvAx,Q(:,1),Q(:,2),Q(:,3),'color',LineColors(k+1,:),'lines','--','linew',0.1); %plot control polygon

%Place new relevant data into user data for next iteration
IncH.UserData.SecCP=Q;
IncH.UserData.Number=k+1;
function ImpElvSecCB(~,~,IncH,handles)
%Obtain relevant data to implement the new control polygon into Ax1
Ax1=handles.Ax1;
Sec=handles.SelSecPush.UserData; %the section itself
delete(Sec.UserData.CntrlH); %Delete old control polygon
kSecCP=IncH.UserData.SecCP; %obtain the new control polygon
%plot the new control polygon to Ax1
SctH=scatter3(Ax1,kSecCP(:,1),kSecCP(:,2),kSecCP(:,3),20,Sec.Color,'filled','ButtonDownFcn',{@WrongMdownCB,handles}); %plot points
PltH=plot3(Ax1,kSecCP(:,1),kSecCP(:,2),kSecCP(:,3),'color',Sec.Color,'lines','--','linew',0.1,'hittest','off'); %plot control polygon
%Save the new control polygon to the section handle
Sec.UserData.SecCP=kSecCP;
Sec.UserData.CntrlH=[SctH,PltH];
function ResetElvSecCB(ResetH,~,ElvAx,IncH)
%Obtain relevant data from user data
P=ResetH.UserData.SecCP;
k=ResetH.UserData.Number;

%plot inital conrol points and curve
cla(ElvAx);
grid(ElvAx,'on'); hold(ElvAx,'on'); xlabel(ElvAx,'X'); ylabel(ElvAx,'Y'); zlabel(ElvAx,'Z');
title(ElvAx,['Increase Degree of section ',num2str(k)]);

%obtain relevant curve points
kCurvePnts=BezDeCasteljau(P);

LineColors=lines(k);
plot3(ElvAx,kCurvePnts(:,1),kCurvePnts(:,2),kCurvePnts(:,3),'color',LineColors(k,:),'linew',2); %plot curve
scatter3(ElvAx,P(:,1),P(:,2),P(:,3),20,LineColors(k,:),'filled'); %plot points
plot3(ElvAx,P(:,1),P(:,2),P(:,3),'color',LineColors(k,:),'lines','--','linew',0.1); %plot control polygon

%reset data in IncH
IncH.UserData.SecCP=P;
IncH.UserData.Number=k;
%Q4 callbacks - split section
function SplitPush_Callback(hObject, eventdata, handles)
GrassGreen=[0.47,0.67,0.19]; %section unchosen
if norm(hObject.BackgroundColor-GrassGreen)<eps %button is light green - no section chosen
    errordlg('Please select a curve before clicking the Increase button','A-lon');
    return 
else
    %continue, but turn button to grass green having the user reselect
    %curve for another activation
    handles.PlotPush.BackgroundColor=GrassGreen; 
    handles.ElvPush.BackgroundColor=GrassGreen;
    handles.SplitPush.BackgroundColor=GrassGreen;
    handles.PlayPush.BackgroundColor=GrassGreen;
end

%Obtain u value
u=str2num(handles.u4Edit.String);
if isempty(u), errordlg('Please input a correct u value','A-lon'); return, end
if u>1 || u<0, errordlg('u must be between 0 and 1','A-lon'); return, end

%Obtain section data
SecH=handles.SelSecPush.UserData;
kSecCP=SecH.UserData.SecCP;

%Obtain k for colors. SplitPush.UserData stores the number of sections that
%were drawn onto Ax1 from initalizing
k=handles.SplitPush.UserData;

%Split the section - obtain new control points
[Q1,Q2]=SplitBezier(kSecCP,u);

%Build new sections and draw them onto Ax1 (setting properties of sections
%included)
Ax1=handles.Ax1;
axis(Ax1,'manual'); %set bounds to manual change so they wont change while splitting. reverts for DrawInitalAx1
LineColor=lines(k+2);
%First Half - Q1
Sec1H=scatter3(Ax1,Q1(:,1),Q1(:,2),Q1(:,3),20,LineColor(k+1,:),'filled','ButtonDownFcn',{@WrongMdownCB,handles}); %plot points
Plt1H=plot3(Ax1,Q1(:,1),Q1(:,2),Q1(:,3),'color',LineColor(k+1,:),'lines','--','linew',0.1,'hittest','off'); %plot control polygon
CrvPnts1=BezDeCasteljau(Q1);
h=plot3(Ax1,CrvPnts1(:,1),CrvPnts1(:,2),CrvPnts1(:,3),'color',LineColor(k+1,:),'linew',2); %plot curve section
h.UserData.Number=k+1;
h.UserData.SecCP=Q1;
h.UserData.CntrlH=[Sec1H,Plt1H];
h.Tag='Section';
%Second Half - Q2
Sec2H=scatter3(Ax1,Q2(:,1),Q2(:,2),Q2(:,3),20,LineColor(k+2,:),'filled','ButtonDownFcn',{@WrongMdownCB,handles}); %plot points
Plt2H=plot3(Ax1,Q2(:,1),Q2(:,2),Q2(:,3),'color',LineColor(k+2,:),'lines','--','linew',0.1,'hittest','off'); %plot control polygon
CrvPnts2=BezDeCasteljau(Q2);
h=plot3(Ax1,CrvPnts2(:,1),CrvPnts2(:,2),CrvPnts2(:,3),'color',LineColor(k+2,:),'linew',2); %plot curve section
h.UserData.Number=k+2;
h.UserData.SecCP=Q2;
h.UserData.CntrlH=[Sec2H,Plt2H];
h.Tag='Section';

%set SplitSec UserData for 2 more sections
handles.SplitPush.UserData=k+2;

%delete old section and its control polygon
delete(SecH.UserData.CntrlH);
delete(SecH);
%Q5 callbacks - movie of point building with de Casteljau's 
function PlayPush_Callback(hObject, eventdata, handles)
GrassGreen=[0.47,0.67,0.19];
if norm(hObject.BackgroundColor-GrassGreen)<eps %button is light green - no section chosen
    errordlg('Please select a curve before clicking the Increase button','A-lon');
    return 
else
    %continue, but turn button to grass green having the user reselect
    %curve for another activation
    handles.PlotPush.BackgroundColor=GrassGreen; 
    handles.ElvPush.BackgroundColor=GrassGreen;
    handles.SplitPush.BackgroundColor=GrassGreen;
    handles.PlayPush.BackgroundColor=GrassGreen;
end

%Obtain PauseTime
PauseTime=str2num(handles.PauseEdit.String);
if isempty(PauseTime), errordlg('Please input a correct PauseTime value','A-lon'); return, end
if PauseTime<0, errordlg('PauseTime must be positive','A-lon'); return, end

%Obtain u value
u=str2num(handles.u5Edit.String);
if isempty(u), errordlg('Please input a correct u value','A-lon'); return, end
if u>1 || u<0, errordlg('u must be between 0 and 1','A-lon'); return, end

%Obtain handle data - section and Ax
SecH=handles.SelSecPush.UserData;
kSecCP=SecH.UserData.SecCP;
Ax1=handles.Ax1;

%use DeCasteljau algorithm - see BezDeCasteljau for answer
Q=kSecCP;
n=size(Q,1)-1; %degree of bezier polynomial
[Sct,Plt]=deal(cell(n+1,1)); %initalize
Colors=copper(n+1); %COLORMAP HERE <--------------------------
for k=1:(n+1)
    for i=1:(n+1-k) %doesnt enter in first iteration
        Q(i,:)=(1-u)*Q(i,:)+u*Q(i+1,:);
    end
    Plt{k}=plot3(Ax1,Q(1:n+1-k,1),Q(1:n+1-k,2),Q(1:n+1-k,3),'color',Colors(k,:),'linew',1);
    Sct{k}=scatter3(Ax1,Q(1:n+1-k,1),Q(1:n+1-k,2),Q(1:n+1-k,3),20,Colors(k,:),'filled','marker','o','MarkerEdgeColor','k');
    pause(PauseTime);
end
%delete handles
delete([Plt{:},Sct{:}]);
%% Functions
function BezF=Bez3Cntrl2Crv(Rvec) %NOT IN USE - Decastljau more efficent
%a way of implementing 3d degree bezier curves
%for higher degrees, we use De Casteljau's algorithm.

%Rvec - [r0;r1;r2;r3] where ri=[x,y,z]. Rvec is a 4x3 matrix
%Return a function handle for the bezier curve.
%Fhandle(u) returns [xu,yu,zu]
M=[1,0,0,0;
    -3,3,0,0;
    3,-6,3,0;
    -1,3,-3,1];
Coeff=M*Rvec;
BezF=@(u) Coeff(1,:)*1+Coeff(2,:)*u+Coeff(3,:)*u^2+Coeff(4,:)*u^3;
function [R,u]=BezDeCasteljau(P)
%returns ordinates [X,Y,Z] in matrix R(NX3) calculated from control points
%P which are given in the same format.
%returns u - running parameter aswell
% https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/de-casteljau.html

%Tested and proved correct.

N=30;
u=linspace(0,1,N);
n=size(P,1)-1;

R=zeros(N,3);
for j=1:N
    Q=P;
    for k=1:(n+1)
        for i=1:(n+1-k) %doesnt enter in first iteration
            Q(i,:)=(1-u(j))*Q(i,:)+u(j)*Q(i+1,:);
        end
    end
    R(j,:)=Q(1,:);
end
function Bool=QPointInLine(P1,P2,P3) %NOT IN USE
%Precision: d<Precision = 1e-3
%P1,P2 make the line. all inputs are of format [x,y,z]
%Bool - 1 if P3 is in line and 0 otherwise

%check the distance between the line and Point. formula from wiki
%https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
Precision=1e-3;
d=norm(cross(P3-P1,P2-P1))/norm(P2-P1);
if d<Precision, Bool=1; else, Bool=0; end
function [Q1,Q2]=SplitBezier(P,u)
%Given control points P of cubic bezier curve p, split the bezier curve in p(u) to
%q1,q2 who belong to control points Q1,Q2.
%P,Q1,Q2 are of the format mx3 - [X,Y,Z] -  matrix

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
n=size(P,1)-1;
Q=P;
[Q1,Q2]=deal(zeros(size(P)));
for k=1:(n+1)
    Q1(k,:)=Q(1,:);
    for i=1:(n+1-k) %doesnt enter in for first iteration
        Q(i,:)=(1-u)*Q(i,:)+u*Q(i+1,:);
    end
    Q2(k,:)=Q(n+2-k,:);
end
%flip Q2 so that bez(Q1,u=1)==bez(Q2,u=0)
Q2=flipud(Q2);
function [C1Pnts,WasUsed]=FixPnts4C1(Pnts)
%Points is a MX3 matrix containing all the points in the major curve in
%order
C1Pnts=Pnts; %initalize
WasUsed=0; %1 if algorithm was used, 0 otherwise
%Build index vector of points of intereset
PntsAmnt=size(Pnts,1);
SecAmnt=(PntsAmnt-4)/3+1; %amounts of 3d degree bezier section curves in the major curve
CPntsInd=5:3:(5+3*(SecAmnt-2)); %indices of points that need to be altered to ensure continuaty
%Run on points of intereset and update them if needed in C1Pnts
for k=CPntsInd
    P1=Pnts(k-2,:);
    P2=Pnts(k-1,:);
    P3=Pnts(k,:);
    if norm((P3-P2)-(P2-P1))>eps 
        C1Pnts(k,:)=P2+(P2-P1); %make sure the distanc between P1 and P2 is as P2 and P3, and that they are all colinear.
        WasUsed=1;
    end
end
function Q=IncSecDeg(P)
%returns increased degree (+1) bezier curve control points 
%Q and P are both in the format of mx3 ~ [X,Y,Z] 
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

n=size(P,1)-1; %degree of polynom is number of control points -1
I=(1:n)'/(n+1); %matrix of weights per Q point [Xw,Yw,Zw] - w is the disance between Pi and Q and (1-w) is the distance between Q and Pi+1
Q=[P(1,:);I.*P(1:end-1,:)+(1-I).*P(2:end,:);P(end,:)];
function DrawInitialAx1(Pnts,handles)
%% Initalize
%Draws curve on Ax1 and save relevant data to appropiate section handles
%draws sections, control point and lines between control points
PntsAmnt=size(Pnts,1);
SecAmnt=(PntsAmnt-4)/3+1; %amounts of 3d degree bezier section curves in the major curve

%save SecAmnt into SplitPush user data for later on splitting
handles.SplitPush.UserData=SecAmnt;

%Create function handles for sections
%SecCPInd - [index of first point, index of last point]. matrix (:,2)
SecCPInd=1:3:PntsAmnt;
SecCPInd=[SecCPInd(1:end-1);SecCPInd(2:end)]';

%build SecCP cell array - Points of control polygon
[SecCP,SctH,PltH]=deal(cell(SecAmnt,1));
for k=1:SecAmnt
   SecCP{k}=Pnts(SecCPInd(k,1):SecCPInd(k,2),:);
end
%% Draw onto Ax1
Ax1=handles.Ax1;
axis(Ax1,'auto'); %set bounds to auto. Might have been on manual from SplitSec interactions
cla(Ax1); grid(Ax1,'on'); hold(Ax1,'on'); view(Ax1,3);
xlabel(Ax1,'x');  ylabel(Ax1,'y'); zlabel(Ax1,'z');
LineColor=lines(SecAmnt);

%Draw control polygons
for k=1:SecAmnt
    kSecCP=SecCP{k};
    SctH{k}=scatter3(Ax1,kSecCP(:,1),kSecCP(:,2),kSecCP(:,3),20,LineColor(k,:),'filled','ButtonDownFcn',{@WrongMdownCB,handles}); %plot points
    PltH{k}=plot3(Ax1,kSecCP(:,1),kSecCP(:,2),kSecCP(:,3),'color',LineColor(k,:),'lines','--','linew',0.1,'hittest','off'); %plot control polygon
end

%Draw Curve. 
%IMPORTANT: inserts the number of the section and some more into its user data
for k=1:SecAmnt
    kCurvePnts=BezDeCasteljau(SecCP{k});
    h=plot3(Ax1,kCurvePnts(:,1),kCurvePnts(:,2),kCurvePnts(:,3),'color',LineColor(k,:),'linew',2); %plot curve section
    h.UserData.Number=k;
    h.UserData.SecCP=SecCP{k};
    h.UserData.CntrlH=[SctH{k},PltH{k}];
    h.Tag='Section';
end
%% Create Functions - no use
function u4Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u4Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function u5Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u5Edit (see GCBO)
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
