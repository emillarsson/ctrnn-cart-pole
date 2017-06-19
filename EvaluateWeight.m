function reward = EvaluateWeight(weights, nodes, biases, timesteps)
y = zeros(nodes,1);
x = 0;
x_dot = 0;
theta = rand*2*pi;
theta_dot = 0;

GRAV            = -9.8;        % g
MASS_C          = 1.0;         % mass cart
MASS_P          = 0.1;         % mass pole
LENGTH          = 0.5;         % half length of pole
SAMPLE_INTERVAL = 0.05;        % delta t
MU_C            = 0.0005;      % coeff fric, cart on track  START: 0.0005
MU_P            = 0.000002;    % coeff frict, pole on cart  START: 0.000002
FORCE           = 10;          % magnitude of force applied at every time step (either plus or minus)

% For fitness function
fitness = zeros(timesteps,1);
summation = 0;
longest_balance = 0;
for i = 1:timesteps
    % Set inputs
    input = zeros(nodes,1);
    input(1:4) = [x; x_dot; theta; theta_dot];
    
    % CTRNN equation (Sample interval is intrinsic from step function)
    dy = zeros(nodes,1);
    for n = 1:nodes
        dy(n) = -y(n) + weights(n,:)*power(1+exp(-(y - biases)),-1) + input(n);
    end
    y = y + dy;
    force = y(end);
    
    % STEP
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
   
    % Fitness function: Check longest balancing time within an pi/5 angle 
    % deviation and within -5,+5 meters on the track
    if (abs(mod(theta,2*pi)-pi) < pi/5 && abs(x) < 5)
        summation = summation + 1;
        if summation > longest_balance
           longest_balance = summation; 
        end
        fitness(i) = 1/(abs(mod(theta,2*pi)-pi));% + abs(x_dot) + abs(theta_dot));
    else
        summation = 0;
    end
end
% Reward is longest balancing streak through all timesteps
reward = longest_balance/timesteps;
end
