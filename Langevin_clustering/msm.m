function [centers, trans_matrix, markovian_check] = msm(coords_v_time, num_clusters)    
    %% Load and calculate distances
    
    xs = coords_v_time(:,1,:);
    ys = coords_v_time(:,2,:);
    zs = coords_v_time(:,3,:);
    
    % vector of 7 distances about the structure of the model
    [~,steps] = size(xs);
    distances = zeros(steps,7);
    for i=1:steps
        distances(i,1) = calc_dis([xs(1,i),ys(1,i),zs(1,i)], [xs(10,i), ys(10,i), zs(10,i)]);
        distances(i,2) = calc_dis([xs(1,i),ys(1,i),zs(1,i)], [xs(4,i), ys(4,i), zs(4,i)]);
        distances(i,3) = calc_dis([xs(1,i),ys(1,i),zs(1,i)], [xs(5,i), ys(5,i), zs(5,i)]);
        distances(i,4) = calc_dis([xs(2,i),ys(2,i),zs(2,i)], [xs(6,i), ys(6,i), zs(6,i)]);
        distances(i,5) = calc_dis([xs(4,i),ys(4,i),zs(4,i)], [xs(7,i), ys(7,i), zs(7,i)]);
        distances(i,6) = calc_dis([xs(5,i),ys(5,i),zs(5,i)], [xs(10,i), ys(10,i), zs(10,i)]);
        distances(i,7) = calc_dis([xs(5,i),ys(5,i),zs(5,i)], [xs(9,i), ys(9,i), zs(9,i)]);
    end
    
    
    writematrix(distances, "Residue_distances_over_time.csv");
    
    
    %% 3b) Clustering
    
    [clusters,centers] = kmeans(distances, num_clusters, 'MaxIter', 200);

    %fprintf("Clusters:\n");
    %disp(clusters);
    
    % Write clusters to file
    fileID = fopen('cluster_seq.txt', 'w');
    if fileID == -1
        error('Cannot open file for writing.');
    end
    
    % Define the format for printing each element of the matrix
    formatSpec = '%d\n';
    
    % Print the matrix to the file
    fprintf(fileID, formatSpec, clusters);
    
    % Close the file
    fclose(fileID);
    
    %% 3c) Transition matrix
    
    trans_matrix = zeros(6,6);
    
    % Iterate through each 50 steps and enter into transition matrix
    for i = 1:(steps-50)
        trans_matrix(clusters(i),clusters(i+50)) = trans_matrix(clusters(i),clusters(i+50)) + 1;
    end
    disp(clusters);
    
    % Normalize each row
    for i = 1:6
        trans_matrix(i,:) = trans_matrix(i,:)/sum(trans_matrix(i,:));
    end

    fprintf("Transition matrix:\n");
    disp(trans_matrix);
    
    % The transitions that did not change conformations have the highest
    % probabilities. Other than that, structure 2 to 5, 4 to 5, 5 to 2, 5 to 4,
    % and 6 to 2 has relatively higher probability of transition than the other
    % states. The lower probability transitions include structures 3 to 4, 3 to
    % 5, 2 to 3, 4 to 3, 5 to 3, 5 to 6, and 6 to 5. This might be because the
    % states that have higher probability transitions are closer in
    % conformation than ones that have lower probabilit transitions. It is also
    % possible that the transition energy of the two states affect transition
    % probability (ex. state 5 and 6 have a high activation energy)
    
    %% 3d)
    
    % Iterate through each 50 steps and enter into the state matrix
    state_matrix = zeros(6,1);
    for i = 1:steps
        state_matrix(clusters(i)) = state_matrix(clusters(i)) + 1;
    end
    
    fprintf("State matrix of clusters:\n");
    disp(state_matrix);
    
    %% 3e) 100 steps apart
    markovian_check = zeros(6,6);
    
    % Iterate through each 50 steps and enter into transition matrix
    for i = 1:(steps-100)
        markovian_check(clusters(i),clusters(i+100)) = markovian_check(clusters(i),clusters(i+100)) + 1;
    end
    
    % Normalize each row
    for i = 1:6
        markovian_check(i,:) = markovian_check(i,:)/sum(markovian_check(i,:));
    end
    trans_matrix_squared = trans_matrix*trans_matrix;
    fprintf("Markovian test:\n");
    disp(markovian_check - trans_matrix_squared);
    % It's not perfect markovian but it's kind of close
end