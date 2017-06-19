function TestWeight(weights, nodes, biases, timesteps)
close all;

y = zeros(nodes,1);
x = 0;
x_dot = 0;
theta = 0;
theta_dot = 0;

GRAV            = -9.8;        % g
MASS_C          = 1.0;         % mass cart
MASS_P          = 0.1;         % mass pole
LENGTH          = 0.5;         % half length of pole
SAMPLE_INTERVAL = 0.02;        % delta t
MU_C            = 0.0005;      % coeff fric, cart on track  START: 0.0005
MU_P            = 0.000002;    % coeff frict, pole on cart  START: 0.000002
FORCE           = 10;          % magnitude of force applied at every time step (either plus or minus)

for i = 1:timesteps
    input = zeros(nodes,1);
    input(1:4) = [x; x_dot; theta; theta_dot];
    
    % Update network
    dy = zeros(nodes,1);
    for n = 1:nodes
        dy(n) = -y(n) + weights(n,:)*power(1+exp(-(y - biases)),-1) + input(n);
    end
    y = y + dy;
    force = y(end);
    
    % Step
    th = theta;
    th_dot = theta_dot;
    f = FORCE* sign(force);
    top = GRAV*sin(th) + (cos(th)*(-f - (MASS_P*LENGTH*th_dot*th_dot*sin(th)) + MU_C*sign(x_dot))/(MASS_C + MASS_P)) - ((MU_P * th_dot)/(MASS_P*LENGTH));
    bottom = LENGTH*((4/3) - (MASS_P*cos(th)*cos(th))/(MASS_C + MASS_P));
    th_dotdot = top/bottom;
    x_dotdot = (f + MASS_P*LENGTH*(th_dot*th_dot*sin(th) - th_dotdot*cos(th)) - MU_C*sign(x_dot))/(MASS_C +MASS_P);
    theta = theta + SAMPLE_INTERVAL * theta_dot;
    theta_dot = theta_dot + SAMPLE_INTERVAL * th_dotdot;
    x = x + SAMPLE_INTERVAL * x_dot;
    x_dot = x_dot + SAMPLE_INTERVAL * x_dotdot;
    
    % Plot
    figure(1)
    plot(x,0,'k+','LineWidth',10);
    hold on
    plot([x-1 x+1], [0 0], 'k')
    plot(x-cos(theta+pi/2)*LENGTH,-sin(theta+pi/2)*LENGTH,'k+','LineWidth',10);
    plot([x x-cos(theta+pi/2)*LENGTH], [0 -sin(theta+pi/2)*LENGTH],'k','LineWidth',3)
    plot([0 0], [0.1 -0.1], 'k')
    hold off
    grid on
    set(gca,'XTickLabel',{})
    set(gca,'YTickLabel',{})
    
    axis([x-1 x+1 -1 1])
    pause(0.015)
end
end
