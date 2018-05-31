%% Q1 Plant
clear src
figure
Gp = tf([1.13 0.17041], [1 0.739 0.92333 0]);
Gideal = tf([1],[1]);
Gcl = feedback(Gp,Gideal);
pole(Gp)
zero(Gp)
step(Gcl)
title('Plant Step Response');
stepinfo(Gcl)

%%
%% Plant
clear src
figure
Gp = tf([1.13 0.17041], [1 0.739 0.92333 0]);
Gideal = tf([1],[1]);
Gcl = feedback(Gp,Gideal);
pole(Gp)
zero(Gp)
step(Gcl)
title('Plant Step Response');
stepinfo(Gcl)


%% Ideal controller
clear src
% Plant, actuator and controller
Gp = tf([1.13 0.17041], [1 0.739 0.92333 0]);
Gc = tf([1], [1]);
Ga = tf([1], [0.1 1]);

Go1 = series(Gp,Gc);
Go = series(Go1, Ga);

% Locus
figure
rlocus(Go)

% Closed loop step response
figure
Gfeedback = tf([2/pi],[1]);
Gcl = feedback(Go,Gfeedback);
step(Gcl)
stepinfo(Gcl)
title('Closed loop with actuator');
damp (Gcl)
%% PI Controller
clear src
k = .1;
z = 0.04;
p = 15;
% Plant, actuator and controller
Gp = tf([1.13 0.17041], [1 0.739 0.92333 0]);
Gc = tf(k*[1 z], [1 p]);
Ga = tf([1], [0.1 1]);

Go1 = series(Gp,Gc);
Go = series(Go1, Ga);

% Locus
figure
rlocus(Go)

% Closed loop step response
figure
Gfeedback = tf([2/pi],[1]);
Gcl = feedback(Go,Gfeedback);
step(Gcl)
stepinfo(Gcl)
title('Closed loop with PI controller');


%% PID Controller
clear src
% Zero choices
z1 = -0.5;
z2 = -0.8;

% Plant, actuator and controller
Gp = tf(2*[1.13 0.17041], pi*[1 0.739 0.92333 0]);
Gc = tf([poly([z1, z2])], [1 0]);
Ga = tf([1], [0.1 1]);

Go1 = series(Gp,Gc);
Go = series(Go1, Ga);

% Locus
figure
rlocus(Go)
sgrid

[k,poles] = rlocfind(Go);
%k=;
Gc = tf(10E-9*[poly([z1, z2])],[1 0]);

Go1 = series(Gp,Gc);
Go = series(Go1, Ga);

% Closed loop step response
figure
Gfeedback = tf([1],[1]);
Gcl = feedback(Go,Gfeedback);
step(Gcl)
stepinfo(Gcl)
poles (Gcl)
title('Closed loop With PID controller');