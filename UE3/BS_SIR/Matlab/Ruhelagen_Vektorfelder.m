%% Uebung Regelungssysteme  
% Epidemiemodell
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


close all
clc
%%  Ruhelage des offenen Kreises

beta = parSIR.beta;
gamma_ = parSIR.gamma;
delta = parSIR.delta;
i_soll = parSIR.i_soll;
u=0;

spacing = 0.02;
i_range = 0:spacing:1;
r_range = 0:spacing:1;
[i,r] = meshgrid(i_range,r_range);

ip = beta.*i.*(1-i-r) - gamma_.*i;
rp = gamma_.*i - delta.*r + u;

% nur vektoren plotten wo gilt: i+r<1
mask = i+r>1;
ip(mask) = 0; 
rp(mask) = 0;
% Normieren der Pfeillänge
if 1
    norm = sqrt(ip.^2+rp.^2);
    ip = ip./norm;
    rp = rp./norm;
end

% Ruhelagen bestimmen
syms  i_s r_s
[ir, rr] = solve(beta*i_s*(1-i_s-r_s) - gamma_*i_s == 0, gamma_*i_s - delta*r_s + u, i_s>0, r_s>0)

% Plot des Vektorfeldes und der Ruhelagen
figure('Name','Vektorfeld_Offen')
quiver(i,r,ip,rp,0.5)
hold on;
plot(ir,rr,'x','MarkerSize', 20)

xlabel('i');
ylabel('r');


%% Vektorfelder des Geschlossenen Systemes
c1=0.1;
c2=1;    

spacing = 0.005;
i_range = 0:spacing:1;
r_range = 0:spacing:1;
[i,r] = meshgrid(i_range,r_range);

% u für alle Kombinationen berechnen
u = (0.2e1 .* i .^ 2 .* (i + r / 0.2e1 - i_soll / 0.2e1 - 0.1e1 / 0.2e1) .* beta .^ 2 + (-i .^ 2 .* c2 + (-c1 .* i_soll + (-r + 0.1e1) .* c2 + delta .* r) .* i - c1 .* i_soll .* (r - 0.1e1)) .* beta + c2 .* (c1 - gamma_) .* i - c1 .* i_soll .* (c2 + gamma_)) ./ i ./ beta;
ip = beta.*i.*(1-i-r) - gamma_.*i;
rp = gamma_.*i - delta.*r + u;

%Limit u
u(u<0) = 0;
u(u>0.1) = 1;

% Normieren der Pfeillänge
if 1
    norm = sqrt(ip.^2+rp.^2);
    ip = ip./norm;
    rp = rp./norm;
end

% Plot des Vektorfeldes und der Ruhelagen
figure('Name','Vektorfeld_geschlossen, 0..1 Limit')
quiver(i,r,ip,rp,0.5)
hold on;
plot([1,0],[0,1])
xlabel('i')
ylabel('r')

%Limit u
u(u<0) = 0;
u(u>0.1) = 0.1;

ip = beta.*i.*(1-i-r) - gamma_.*i;
rp = gamma_.*i - delta.*r + u;
% Normieren der Pfeillänge
if 1
    norm = sqrt(ip.^2+rp.^2);
    ip = ip./norm;
    rp = rp./norm;
end

% Plot des Vektorfeldes und der Ruhelagen
figure('Name','Vektorfeld_geschlossen, 0..0.1 Limit')
quiver(i,r,ip,rp,0.5)
hold on;
plot([1,0],[0,1])
xlabel('i')
ylabel('r')
