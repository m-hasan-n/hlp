
%% dataset_demo
% This script goes through some plotting functions that help you visualize
% the scene in a trial showing the table and objects on top. 
% You can also visualize motion of the human arm and objects and save this 
% animation to a video.

%% Define which subject and which trial you want to visualize
%Subject IDs from 1 to 26 (excluding 5 and 10).
%Trials IDs from 1 to 100.
subject_id = 1; 
trial_id = 15;

%Define a sclae to plot
plot_scale = 10;

%Path to subject's directory
curr_dir = pwd;
subject_dir = [curr_dir '/Dataset/sub_' sprintf('%02d',subject_id)];

%% Plotting the scene table and objects on top
%In each trial, the subject is told to start from a given location on the table
%and pick a target object. The starting location is plotted as a green
%ellipse and the target as a green rectangle. Other objects appear as red
%rectangles wherease the table as a black rectangle
plot_scene_objects(subject_dir,trial_id, plot_scale);

%% Animation
%animate the human trajecory showing arm and object motions and save
%the animation to a video on your disk
video_save_dir = fullfile(curr_dir,'animated-trials');
trial_animation(subject_dir,subject_id, trial_id, plot_scale, video_save_dir)

