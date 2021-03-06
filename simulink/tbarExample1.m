clear all
close all
%==========================================================================
%Space T-bar example
%https://www.youtube.com/watch?v=1n-HMSCDYtM
%==========================================================================
%parameters
w_big = -5*2*pi; %5 hz clockwise about x-axis
w_small = .01*w_big;
R1 = .030; 
r = .015;
h = .150;
L = .075;
rho = 2700;
m1 = pi*R1^2*h*rho;
m2 = pi*r^2*L*rho;
CM = [m1/(m1+m2)*(R1+L/2)  0   0]';
I1 = [m1/12*(3*R1^2+h^2) 0                               0; ....
      0   m1/2*R1^2+m1*(m2/(m1+m2)*(R1+L/2))^2            0; ....
      0                 0     m1/12*(3*R1^2+h^2)+m1*(m2/(m1+m2)*(R1+L/2))^2];
I2 = [m2*r^2/2          0                               0;....
      0   m2/12*(3*r^2+L^2)+m2*(m1/(m1+m2)*(R1+L/2))^2   0;....
      0                 0     m2/12*(3*r^2+L^2)+m2*(m1/(m1+m2)*(R1+L/2))^2];      
I = I1 + I2;
Ixx = I(1,1);
Iyy = I(2,2);
Izz = I(3,3);
 %initialize time and angular velocity values
dt = .0001;
t=0:dt:6;
w1 = zeros(1,length(t));
w2 = zeros(1,length(t));
w3 = zeros(1,length(t));
%==========================================================================
%Case 1: w1 and w2 small w3 big initially (stable)
%==========================================================================
w1(1) = w_small;
w2(1) = w_small;
w3(1) = w_big;
for i=2:length(t)
    w1(i) = w1(i-1) +  1/Ixx*(Iyy-Izz)*w2(i-1)*w3(i-1)*dt;
    w2(i) = w2(i-1) +  1/Iyy*(Izz-Ixx)*w1(i-1)*w3(i-1)*dt;
    w3(i) = w3(i-1) +  1/Izz*(Ixx-Iyy)*w2(i-1)*w1(i-1)*dt;
end
figure('name','w3 big')
plot(t,w1,t,w2,t,w3)
legend('w1','w2','w3')
xlabel('time')
ylabel('angular velocity')
title('w3 big initially (stable) Iyy<Ixx<Izz')
%==========================================================================
%Case 2: w1 and w3 small w2 big initially (stable)
%==========================================================================
clear w1 w2 w3
w1 = zeros(1,length(t));
w2 = zeros(1,length(t));
w3 = zeros(1,length(t));
w1(1) = w_small; 
w2(1) = w_big;
w3(1) = w_small;
for i=2:length(t)
    w1(i) = w1(i-1) +  1/Ixx*(Iyy-Izz)*w2(i-1)*w3(i-1)*dt;
    w2(i) = w2(i-1) +  1/Iyy*(Izz-Ixx)*w1(i-1)*w3(i-1)*dt;
    w3(i) = w3(i-1) +  1/Izz*(Ixx-Iyy)*w2(i-1)*w1(i-1)*dt;
end
figure('name','w2 big')
plot(t,w1,t,w2,t,w3)
legend('w1','w2','w3')
xlabel('time')
ylabel('angular velocity')
title('w2 big initially (stable) Iyy<Ixx<Izz')
%==========================================================================
%Case 3: w2 and w3 small w1 big initially (unstable)
%==========================================================================
clear w1 w2 w3
w1 = zeros(1,length(t));
w2 = zeros(1,length(t));
w3 = zeros(1,length(t));
w1(1) = w_big;
w2(1) = w_small;
w3(1) = w_small;
for i=2:length(t)
    w1(i) = w1(i-1) +  1/Ixx*(Iyy-Izz)*w2(i-1)*w3(i-1)*dt;
    w2(i) = w2(i-1) +  1/Iyy*(Izz-Ixx)*w1(i-1)*w3(i-1)*dt;
    w3(i) = w3(i-1) +  1/Izz*(Ixx-Iyy)*w2(i-1)*w1(i-1)*dt;
end
figure('name','w1 big')
plot(t,w1,t,w2,t,w3)
legend('w1','w2','w3')
xlabel('time')
ylabel('angular velocity')
title('w1 big initially (unstable) Iyy<Ixx<Izz')
%==========================================================================
%PLOT MOTION FOR CASE 3
%==========================================================================
R = zeros(3,3,length(t));
R(:,:,1) = eye(3,3);
w = zeros(3,1,length(t));
w(1,1,:) = w1;
w(2,1,:) = w2;
w(3,1,:) = w3;
%--find euler parameter rates from angular velocity and then find rotation
%matrix from global to body fixed
eulParams = zeros(4,1,length(t));
eulParams(:,:,1) = [1 0 0 0]'; %global and fixed coordinates align at first
eulRates = zeros(4,1,length(t));
%we do rotation evolution with Euler Parameters, see "Analytical Dynamics,"
%by Baruh 1999 Section 7.7.
for i =2:length(t) 
    eulRates(:,:,i) = getEulRates(eulParams(:,:,i-1),w(:,:,i-1));
    eulParams(:,:,i) = eulParams(:,:,i-1) + dt*eulRates(:,:,i);
    R(:,:,i) = getRfromEulParams(eulParams(:,:,i));
end
%--now we create four points for the T-bar to draw lines
%body 1
body1(1:3,1) = [R1/2 0 h/2]'-CM;   %pt1
body1(1:3,2) = [R1/2 0 -h/2]'-CM;  %pt2
%body 2
body2(1:3,1) = [R1/2 0 0]'-CM;     %pt3
body2(1:3,2) = [L+R1/2 0 0]'-CM;   %pt4
%--now lets make movie
timeStep = 0.01; %seconds
stepSize = floor(timeStep/dt);
n=0;
figure
for i =1:stepSize:length(t) 
    newplot
    n = n+1;
    %map body fixed coordinates to lab coordinates
    body1_temp(1:3,1) = transpose(R(:,:,i))*body1(1:3,1);
    body1_temp(1:3,2) = transpose(R(:,:,i))*body1(1:3,2);
    body2_temp(1:3,1) = transpose(R(:,:,i))*body2(1:3,1);
    body2_temp(1:3,2) = transpose(R(:,:,i))*body2(1:3,2);
    %long bar points to draw lines
    x0 = [body1_temp(1,1) body1_temp(1,2)];
    y0 = [body1_temp(2,1) body1_temp(2,2)];
    z0 = [body1_temp(3,1) body1_temp(3,2)];
    %short bar points to draw lines
    x1 = [body2_temp(1,1) body2_temp(1,2)];
    y1 = [body2_temp(2,1) body2_temp(2,2)];
    z1 = [body2_temp(3,1) body2_temp(3,2)];
    %no plot lines
    line(x0,y0,z0);
    view(3)
    axis([-2*h 2*h -2*h 2*h -2*h 2*h])
    grid
    line(x1,y1,z1);
    %save plots
    F(n) = getframe(gcf);
end
%save plots (in F structure) to movie
v = VideoWriter('myMovie.avi')
open(v)
writeVideo(v,F)
close(v)