%% Parameterdatei Helikopter
%  Übung Regelungssysteme
%
%  Ersteller: T.Glück
%  Erstellt:  03.11.2009
%  Änderungen: Boeck, Okt. 2010
%
%%
clear all;
close all;
clc

s=tf('s');

%% Setzen der Systemparameter des vereinfachten und des vollständigen Modells

%Abtastzeit
Ta = 1e-3;
% Systemparameter des vereinfachten Modells
sysPar.a1 = -1.1713;
sysPar.a2 =  0.3946;
sysPar.a3 = -0.5326;

sysPar.b1 = -0.6354;
sysPar.b2 = -0.6523;
sysPar.b3 =  4.6276;

% Initialwerte des vereinfachten Modells
sysPar.x0 = [0;0;-atan(sysPar.a2 / sysPar.a1);0;0;0];

% Systemparameter des vollständigen Modells
set_parameter_vollstaendigesModell;

%% Setzen der Parameter für die Vorsteuerung

fbvsPar.T1 = 5;
fbvsPar.T2 = 10;

fbvsPar.q1d = [0,0,2*pi];
fbvsPar.q2d = [-atan(sysPar.a2/sysPar.a1),0,0];

%% Setzen der Reglerparameter - Bitte anpassen!

p1 = -0.7;
p2 = -0.7;

k1I = -p1 ^ 5;
k10 = 5 * p1 ^ 4;
k13 = 10 * p1 ^ 2;
k12 = -10 * p1 ^ 3;
k11 = -5 * p1;

k2I = -p2 ^ 3;
k20 = 3 * p2 ^ 2;
k21 = -3 * p2;

% Reglerparameter q1
regPar.k13 = k13;
regPar.k12 = k12;
regPar.k11 = k11;
regPar.k10 = k10;
regPar.k1I = k1I;
% Reglerparameter q2
regPar.k21 = k21;
regPar.k20 = k20;
regPar.k2I = k2I;