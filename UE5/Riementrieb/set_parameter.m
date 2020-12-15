%% Übung Regelungssysteme  
% Parameterdatei und Berechnungsdatei zur Simulation des Riementriebs
%
% Ersteller:    WK, 01.11.2009
% Änderungen:   FM, 02.11.2010
%               FM, 12.07.2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;
s=tf('s');

%% Parameter des Systems Riementrieb
parSys.Il  = 4e-5;     %Trägheitsmoment Last
parSys.cr1 = 10;       %lineare Steifigkeit Riemen
parSys.cr3 = 1e6;      %kubische Steifigkeit Riemen (1e6)
parSys.dl  = 0.001;    %visk. Dämpfung Last
parSys.rl  = 0.05;     %Radius Riemenscheibe Last
parSys.Im  = 0.5e-5;   %Trägheitsmoment Motor
parSys.dm  = 0.01;     %viskose Dämpfung Motor
parSys.rm  = 0.025;    %Radius Riemenscheibe Motor
parSys.Rm  = 1.388;    %Widerstand PSM
parSys.Lm  = 1.475e-3; %Induktivität PSM
parSys.p   = 2.0;      %Polpaarzahl PSM
parSys.Phi = 2.715e-2; %Fluss Permanentmagnet PSM

% Abtastzeit der internen Dynamik
parSys.TsID = 0.1e-3;

%% Anfangsbedingungen des Systems Riementrieb
parSys.omegam_0  = 0;  %AB omegam
parSys.iq_0      = 0;  %AB iq
parSys.id_0      = 0;  %AB id
parSys.epsilon_0 = 0;  %AB epsilon
parSys.omegal_0  = 0;  %AB omegal
% Zusammenfassung der Parameter in einen Vektor
parSys.x0  = [parSys.omegam_0;parSys.iq_0;parSys.id_0;parSys.epsilon_0;parSys.omegal_0];

%% Anfangsbedingungen der Internen Dynamik
parSys.eta_1_0  = 0;  %AB eta_1
parSys.eta_2_0  = 0;  %AB eta_2

%% Parameter des Sollwertfilters omegam
parReg.ppSFc    = [-10,-12,-14]*10;
parReg.cpolySFc = poly(parReg.ppSFc);
parReg.AASF = [0,1,0;
               0,0,1;
               -parReg.cpolySFc(4),-parReg.cpolySFc(3),-parReg.cpolySFc(2)];
parReg.BBSF = [0;0;parReg.cpolySFc(4)];
parReg.CCSF = eye(3);
parReg.DDSF = zeros(3,1);
parReg.ssSF = ss(parReg.AASF,parReg.BBSF,parReg.CCSF,parReg.DDSF);
parReg.ratelim = 1000;     %maximale Änderung

%% Parameter des Sollwertfilters id
parReg.ppSFci    = [-10,-15];
parReg.cpolySFci = poly(parReg.ppSFci);
parReg.AASFi = [0,1;
                -parReg.cpolySFci(3),-parReg.cpolySFci(2)];
parReg.BBSFi = [0;parReg.cpolySFci(3)];
parReg.CCSFi = eye(2);
parReg.DDSFi = zeros(2,1);
parReg.ssSFi = ss(parReg.AASFi,parReg.BBSFi,parReg.CCSFi,parReg.DDSFi);

%% Parameter der PI-Regler

I__l = parSys.Il;
c__r1 = parSys.cr1;
c__r3 = parSys.cr3;
d__l = parSys.dl;
r__l = parSys.rl;
I__m = parSys.Im;
d__m = parSys.dm;
r__m = parSys.rm;
R__m = parSys.Rm;
L__m = parSys.Lm;
p = parSys.p;
Phi = parSys.Phi;

% Arbeitspunkt
M__l = 0;
omega__md = 0;
i__dd = 0;
syms cg; %Variable zur Root Bestimmung
Ae = [-0.1e1 / I__m * d__m 0.3e1 / 0.2e1 / I__m * p * Phi 0 0.2e1 / I__m * (3 * c__r3 * RootOf(2 * cg ^ 3 * c__r3 * r__l ^ 2 + 2 * cg * c__r1 * r__l ^ 2 + d__l * r__m * omega__md - M__l * r__l) ^ 2 + c__r1) * r__m 0; 0.2e1 / 0.3e1 / L__m * (0.3e1 / 0.2e1 * L__m * p * i__dd - p * Phi) -0.2e1 / 0.3e1 / L__m * R__m p * omega__md 0 0; 0.2e1 / 0.3e1 * (-d__l * r__m ^ 2 * omega__md - d__m * r__l ^ 2 * omega__md + M__l * r__l * r__m) / Phi / (r__l ^ 2) -p * omega__md -0.2e1 / 0.3e1 / L__m * R__m 0 0; -r__m 0 0 0 r__l; 0 0 0 -2 / I__l * (3 * c__r3 * RootOf(2 * cg ^ 3 * c__r3 * r__l ^ 2 + 2 * cg * c__r1 * r__l ^ 2 + d__l * r__m * omega__md - M__l * r__l) ^ 2 + c__r1) * r__l -1 / I__l * d__l;];
Be = [0 0; 0.2e1 / 0.3e1 / L__m 0; 0 0.2e1 / 0.3e1 / L__m; 0 0; 0 0;];

% Diagonale Übertragungsmatrix -> y1(u1), y2(u2)
ss_euq = ss(Ae, Be(:,1), [1,0,0,0,0], 0);
ss_eud = ss(Ae, Be(:,2), [0,0,1,0,0], 0);
dss_euq = c2d(ss_euq, 1e-4);
dss_eud = c2d(ss_eud, 1e-4);

% Regler auslegen
opts = pidtuneOptions('PhaseMargin',60);
wc = 100; %rad/s
[PI_euq, infoq] = pidtune(dss_euq, 'PI', wc, opts);
[PI_eud, infod] = pidtune(dss_eud, 'PI', wc, opts);
parPI_euq = ss(PI_euq);
parPI_eud = ss(PI_eud);

parPI.Aq = parPI_euq.A;
parPI.Bq = parPI_euq.B;
parPI.Cq = parPI_euq.C;
parPI.Dq = parPI_euq.D;
parPI.Ad = parPI_eud.A;
parPI.Bd = parPI_eud.B;
parPI.Cd = parPI_eud.C;
parPI.Dd = parPI_eud.D;


%% RootsOf aus Maple lösen
function epsilon__d = RootOf(equ)
roots = solve(equ == 0, 'Real', true);
epsilon__d = double(roots(1));
end
