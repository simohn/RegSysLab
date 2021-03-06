%% Uebung Regelungssysteme  
% Parameterdatei zur Simulation des RRP-Roboters
%
% Ersteller:    MK, 09.11.2009
% Aenderungen:  BM, AB,  2011
%               uknechte 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

% Soll-Trajektorie:
parReg.traj_fKreis     = 0.05;
parReg.traj_fz         = 2;
parReg.traj_phi10      = -pi/2; 
parReg.traj_phi20      = 0;
parReg.traj_s0         = 0.5;


% Roboter:
parSys.m1   = 20;
parSys.m2   = 20;
parSys.m3   = 20;
parSys.mL   = 30;
parSys.l1   = 1;
parSys.l2   = 1;
parSys.l3   = 1;
parSys.Ixx1 = 1.7;
parSys.Iyy1 = 1.7;
parSys.Izz1 = 7e-2;
parSys.Ixx2 = 1.7;
parSys.Iyy2 = 7e-2;
parSys.Izz2 = 1.7;
parSys.Ixx3 = 1.7;
parSys.Iyy3 = 7e-2;
parSys.Izz3 = 1.7;
parSys.d1   = 1;
parSys.d2   = 1;
parSys.d3   = 10;
parSys.delta_phi10 = 0;    %pi/4;
parSys.delta_phi20 = 0;    %pi/4;
parSys.delta_s0    = 0;    %0.25;
parSys.phi10 = parReg.traj_phi10 + parSys.delta_phi10;
parSys.phi20 = parReg.traj_phi20 + parSys.delta_phi20; 
parSys.s0    = parReg.traj_s0    + parSys.delta_s0; 
parSys.phi1p0 = 0;
parSys.phi2p0 = 0; 
parSys.sp0    = 0; 
parSys.g     = 9.81;


% Reglerparameter
% nominelle Streckenparameter
parReg.parSys = parSys;
parReg.parSys.mL = 20; % nominelle Lastmasse

% PD-Regler:
parReg.PD.Ts  = 0.005;

kp1 = 17000;
kp2 = 17000;
kp3 = 22000;
parReg.PD.Kp = [kp1,0,0;0,kp2,0;0,0,kp3];

kd1 = 2200;
kd2 = 2200;
kd3 = 1800;
parReg.PD.Kd = [kd1,0,0;0,kd2,0;0,0,kd3];

% Computed-Torque-Regler:
% Pole Fehlersystem bei (s+10)^2 = s^2 + 20s + 100
parReg.CT.Ts  = 0.005;

k01 = 100;
k02 = 100;
k03 = 100;
parReg.CT.K0 = [k01,0,0;0,k02,0;0,0,k03];

k11 = 20;
k12 = 20;
k13 = 20;
parReg.CT.K1 = [k11,0,0;0,k12,0;0,0,k13];

% Computed-Torque-Regler mit Adaptionsregelgesetz:
parReg.CTA.Ts  = 0.001;

A = [zeros(3,3) eye(3); -parReg.CT.K0 -parReg.CT.K1];
Q = eye(6);
parReg.CTA.P = lyap(A',Q);
parReg.CTA.B = [zeros(3,3);eye(3)];
parReg.CTA.Gamma = 0.00017;

% Sollwertfilter:
parReg.nennerpolynom = conv(conv([1/100 1],[1/100 1]),[1/100 1]);
parReg.par_filt_a0   = parReg.nennerpolynom(4)/parReg.nennerpolynom(1);
parReg.par_filt_a1   = parReg.nennerpolynom(3)/parReg.nennerpolynom(1);
parReg.par_filt_a2   = parReg.nennerpolynom(2)/parReg.nennerpolynom(1);
parReg.par_filt_V    = 1/parReg.nennerpolynom(1);