% Evolution parameters
N = 60;
generations = 500;
new_test = 1; 

% Weight evaluation parameters
tests = 10;
timesteps = 300;

% Network parameters
inputs = 4;
hidden = 5;
outputs = 1;
nodes = inputs + hidden + outputs;
connections = [ones(inputs,nodes-outputs) zeros(inputs,outputs); ones(hidden,nodes); zeros(outputs,inputs) ones(outputs,hidden+outputs)];
y = zeros(nodes,N);

% If new test: reinitialise weights and biases
if (new_test)
    avg_fitness = [];
    best_fitness = [];
    biases = randn(nodes,N);
    weights = zeros(nodes,nodes,N);
    weights(:,:,1:N) = rand(nodes,nodes,N)*2-1;
    for i = 1:N
        weights(:,:,i) = weights(:,:,i).*connections;
    end
end

% Variables for saving the best weights and biases
best_weight = [];
best_B = [];
for k = 1:generations
    clc
    fprintf('Generation %d of %d \r', k, generations)
    
    % Reinitialise fitness values for each network
    fitness = zeros(N,1);
    
    % Evaluate each networks fitness value over a mean of 'test' times
    for m = 1:N
        for mn = 1:tests
            fitness(m) = fitness(m) + EvaluateWeight(weights(:,:,m),nodes,biases(:,m),timesteps);
        end
        fitness(m) = fitness(m)/tests;
    end
    [~, sorted_index] = sort(fitness);
    
    % Check if there is a new best network
    if (fitness(sorted_index(end)) > max(best_fitness))
        best_weight = weights(:,:,sorted_index(end));
        best_B = biases(:,sorted_index(end));
    end
    
    % Save best and average fitness
    best_fitness = [best_fitness; fitness(sorted_index(end))];
    avg_fitness = [avg_fitness; mean(fitness)];
    
    % Initialise temporary weights and biases
    temp_w = zeros(nodes,nodes,N);
    temp_B = zeros(nodes,N);
    
    % Save top half of best networks
    temp_w(:,:,N/2:end) = weights(:,:,sorted_index(N/2:end));
    temp_B(:,N/2:end) = biases(:,sorted_index(N/2:end));
    
    % Duplicate top half with mutations
    for i = 1:N/2-N/20
        temp_w(:,:,i) = (weights(:,:,sorted_index(i+N/2+N/20)) + nodes/100.*randn(nodes,nodes)).*connections;
        temp_B(:,i) = biases(:,sorted_index(i+N/2+N/20)) + nodes/100.*randn(nodes,1);
    end
    
    % Introduce a set of random weights
    for i = 1:N/20
        temp_w(:,:,N/2-N/20+i) = randn(nodes,nodes).*connections;
        temp_B(:,N/2-N/20+i) = randn(nodes,1);
    end
    weights = temp_w;
    biases = temp_B;
    
    % Plot fitness
    figure(1)
    plot(best_fitness,'k')
    grid on
    xlabel('Generations')
    ylabel('Fitness')
    pause(0.001)
end
