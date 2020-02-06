

%estimate arm configuration at testing time
function [next_hand_config, elbow_joint,  shoulder_joint, hand_joint, neck_joint]= estimate_arm_config(ini_position,...
    final_position, current_config, arm_config_regressor,...
    shoulder_elbow_length,elbow_hand_length)

% direction of approaching the estimated position
trajectory_segment = [ini_position; final_position ];
dir_feat = line_orientation_discrete(trajectory_segment);

%distance to the estimated position
%normalized by sum of link lengths
dist_feat = (final_position - ini_position)/(shoulder_elbow_length+elbow_hand_length);

%concatenate features and predict next configuration
data_in = [array2table(current_config) array2table(dist_feat) array2table(dir_feat)];

next_hand_config(1) = predict(arm_config_regressor(1).mdl , data_in);
next_hand_config(2) = predict(arm_config_regressor(2).mdl , data_in);

%reconstruct the hand links using the estimated hand position, 
%new configuration and link lengths
hand_joint = final_position;
hand_angle =  sum(next_hand_config) - pi; 
elbow_x = hand_joint(1) + elbow_hand_length * cos(hand_angle);
elbow_y = hand_joint(2) - elbow_hand_length * sin(hand_angle);
elbow_joint = [elbow_x elbow_y];

shoulder_angle = pi -next_hand_config(1); 
shoulder_x = elbow_x - shoulder_elbow_length*cos(shoulder_angle);
shoulder_y = elbow_y - shoulder_elbow_length*sin(shoulder_angle);
shoulder_joint = [shoulder_x shoulder_y];

%plotting
neck_joint(1) = shoulder_x - shoulder_elbow_length;
neck_joint(2) = shoulder_y; 

% plot_arm_configuration(10*neck_joint,10*shoulder_joint,10*elbow_joint,...
%     10*hand_joint,next_hand_config, plot_clr);

end




