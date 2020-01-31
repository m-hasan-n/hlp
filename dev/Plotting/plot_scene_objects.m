
%plot_scene_objects.m
%plotting the scene (table and objects) for a single trial

%Inputs:
%subject_dir: directory of all trials for a subject
%trial_id: id of the required trial 
%plot_scale: scale for matlab plot

%Outputs:
%scene_objects:matlab table of all objects' position and dimension
%object_rectangle_handles: handles of rectangle matlab objects for further animation
%target_pos: position of the target object

function [scene_objects,object_rectangle_handles,target_pos] = ...
    plot_scene_objects(subject_dir,trial_id, plot_scale)

%scene (table and objects) dimensions 
[~, table_obj , ~, ~, ~]= scene_geometry_info;


table_pos = table_obj.pos*plot_scale;
table_width = table_obj.width*plot_scale;
table_depth = table_obj.depth*plot_scale;


%path to the trial
trial_name = ['T' sprintf('%03d',trial_id)];
trial_path = fullfile(subject_dir,trial_name);

%start position may be random 
scene_layout = readtable(fullfile(trial_path,...
    ['scene/scene_layout_' trial_name '.csv'])); 

scene_layout = table2array(scene_layout(:,2:end));
start_pos = [scene_layout(2,1) scene_layout(2,3)]*plot_scale;

% start_pos = [0 -0.25]*plot_scale;
% start_depth = 0.05*plot_scale;
start_width = 0.05*plot_scale;

%read the objcts layout table
%one row for each object
%7 columns: object name, x, y, z, width, height, depth
scene_objects = readtable(fullfile(trial_path,...
    ['scene/grid_objects_layout_' trial_name '.csv'])); 

%Target position may be random
target_rect = table2array(scene_objects(1,2:end));
target_pos = [target_rect(1) target_rect(3)];

%transform into a numeric array excluding the name of the object
scene_object_positions = plot_scale*table2array(scene_objects(:,2:end));
% target_center = scene_object_positions(1,[1,3]);



%Trajectory and Gaps
%path to the  trajectory
%without movement
%trajectory_table = readtable(fullfile(trial_path,['movement/TrackedHandRight_movement_' trial_name '.csv']));
%with movement
% trajectory_table = readtable(fullfile(trial_path,['movement/HandTracker_movement_' trial_name '.csv']));
% 
% trajectory_xy = plot_scale*table2array(trajectory_table(:,[2 4]));
% line(trajectory_xy(:,1),trajectory_xy(:,2))

%find gaps betwen objects
% table_left_edge = table_pos(1)- table_width/2;
% table_right_edge = table_pos(1)+ table_width/2;
% 
% gabs = find_gabs_bet_objects(scene_objects,table_left_edge,table_right_edge,object_depth);

%plotting
object_rectangle_handles = plot_scene_core(table_pos,table_width,...
    table_depth,start_pos,start_width,scene_object_positions);


