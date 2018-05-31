
%Plant transfer function
N=[140 1148];
D=conv([1 0.3675],[1 3.5]);
Gp=tf(N,D);
rlocus(Gp)
%Use residue for Inverse Laplace transform
Dnew=conv([1 0],D);
[R,P,K]=residue(N,Dnew);
%Controller Transfer function
N=[1 4]
D=[1 10]
Gc=tf(N,D);
%Open Loop Transfer function
Go=series(Gp,Gc)
rlocus(Go)
rlocfind(Go)
sgrid
Gideal = tf([1],[1])
Gcl = feedback(0.6*Go,Gideal)

rlocus(Gcl)
pole(Gcl)  %closed-loop poles
step(Gcl)  %closed-loop step response

Gideal=tf([1],[1])
Gcl=feedback(Go,Gideal)
pole(Gcl)
zero(Gcl)
step(Gcl)