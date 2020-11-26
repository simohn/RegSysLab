clc
clear

s = tf('s');

p = -100;
a = poly(p*ones(1,3));

a0 = a(4);
a1 = a(3);
a2 = a(2);

A = [0,1,0;0,0,1;-a0,-a1,-a2];
B = [0;0;1];
C = [a0,0,0;0,1,0;0,0,1];
D = [0];

Gsys = ss(A,B,C,D);

Ts = 0.001;
Gdsys = c2d(Gsys,Ts);

step(Gdsys)