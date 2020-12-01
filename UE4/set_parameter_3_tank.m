% Parameterdatei Dreitank
% Uebung Regelungssysteme
%
% Erstellt:  19.10.2010 T. Utz
% Geaendert: 14.7.2011 F. Koenigseder
%            06.11.2014 S. Flixeder
% --------------------------------------
%

clc
close all;
clear;

% Parameter des Systems
parSys.Atank     = 1.539e-2;      % Grundfläche Tank
parSys.rho       = 998;           % Dichte Wasser
parSys.eta       = 8.9e-4;        % Dynamische Viskosität Wasser
parSys.g         = 9.81;          % Gravitationskonstante
parSys.alphaA1   = 0.0583;        % Kontraktionskoeffizient AV1
parSys.DA1       = 15e-3;         % Durchmesser AV1
parSys.alphaA2   = 0.1039;        % Kontraktionskoeffizient AV2
parSys.A2        = 1.0429e-4;     % Querschnittsflaeche AV2
parSys.alphaA3   = 0.0600;        % Kontraktionskoeffizient AV3
parSys.DA3       = 15e-3;         % Durchmesser AV3
parSys.alpha12_0 = 0.3038;        % Kontraktionskoeffizient ZV12
parSys.A12       = 5.5531e-5;     % Querschnittsflaeche ZV12
parSys.Dh12      = 7.7e-3;        % hydraulischer Durchmesser
parSys.lambdac12 = 24000;         % kritische Fliesszahl ZV12
parSys.alpha23_0 = 0.1344;        % Kontraktionskoeffizient ZV23
parSys.D23       = 15e-3;         % Durchmesser ZV23
parSys.lambdac23 = 29600;         % Kritische Fliesszahl ZV23
parSys.hmin      = 0.05;          % Minimale Fuellhoehe
parSys.hmax      = 0.55;          % Maximale Fuellhoehe
parSys.DA1_contr = parSys.DA1     % Parameter für den Regler bleoben gleich
parSys.DA3_contr = parSys.DA3     % wenn sich die des Modelles ändern      

param_schwank = 1;
parSys.integrator_on = 1;
% Parameter Schawankung
if param_schwank
    parSys.DA1 = parSys.DA1*1.1;
    parSys.DA3 = parSys.DA3*1.2;
end
% Abtastzeit
parSys.Ta = 0.2;                

% Anfangsbedingung
parSys.h1_0 = 0.22;
parSys.h2_0 = 0.1564721765;
parSys.h3_0 = 0.17;

% Maximale Zufluesse
parSys.qZ1max = 4.5e-3/60;        % Maximaler Zufluss Z1
parSys.qZ3max = 4.5e-3/60;        % Maximaler Zufluss Z3
parSys.qZ1min = 0;                % Minimaler Zufluss Z1
parSys.qZ3min = 0;                % Minimaler Zufluss Z3

% Sollwertfilter
s = tf('s');

% Pole weit links bedeutet bessere Annäherung (schneller) an den
% Eingangsverlauf
a = -0.015; 
a = poly(a*ones(1,3));

a0 = a(4);
a1 = a(3);
a2 = a(2);

A = [0,1,0;0,0,1;-a0,-a1,-a2];
B = [0;0;a0];
C = [1,0,0;0,1,0;0,0,1];
D = [0];

A2 = A;
B2 = B;
C2 = [1,0,0;0,1,0];
D2 = D;

sys = ss(A,B,C,D);
sys2 = ss(A2,B2,C2,D2);
Ts = parSys.Ta;
sysd = c2d(sys,Ts,'zoh');
sys2d = c2d(sys2,Ts,'zoh');

% Parameter des Sollwertfilters
parSollFilt.A = sysd.A;
parSollFilt.B = sysd.B;
parSollFilt.C = sysd.C;
parSollFilt.D = sysd.D;
parSollFilt.A2 = sys2d.A;
parSollFilt.B2 = sys2d.B;
parSollFilt.C2 = sys2d.C;
parSollFilt.D2 = sys2d.D;

parSollFilt.y1d0 = parSys.h2_0;
parSollFilt.y2d0 = parSys.h1_0-parSys.h3_0;

% Parameters des Reglers
parReg.delta_h_min = 0.0001;

% Pole sehr weit links bedeutet schnelleres abklingen der Fehlerdynamik
% Sehr weit links führt zu starkem Ripple
p1Reg = -0.5; 
p2Reg = -0.5;
p1IReg = -2;
p2IReg = -2;
a1Reg = poly(ones(2,1)*p1Reg);
a2Reg = poly(ones(1,1)*p2Reg);
parReg.a10 = a1Reg(3);
parReg.a11 = a1Reg(2);
parReg.a20 = a2Reg(end);

% Pole des geschlossenen Kreises mit Integrator,
if parSys.integrator_on
    a1IReg = poly(ones(3,1)*p1IReg);
    a2IReg = poly(ones(2,1)*p2IReg);
    parReg.a1I = a1IReg(4);
    parReg.a10 = a1IReg(3);
    parReg.a11 = a1IReg(2);
    parReg.a2I = a2IReg(3);
    parReg.a20 = a2IReg(2);
else
    parReg.a1I = 0;
    parReg.a2I = 0;
end