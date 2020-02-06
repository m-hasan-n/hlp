

% dataset_demo
% This script goes through some plotting functions that help you visualize
% the scene in a trial showing table and objects on top. 
% You can also visualize the motion of human arm and object and svae this 
% animation to a video.

%%
current_dir = pwd;
addpath(current_dir)

%Define which trial (of which subject) you want to visualize
subject_id = 3; 
trial_id = 25;

%call the function that plots the scene and objects
plot_scale = 10;
subject_dir = '/home/hasan/Documents/human-like-planning/Dataset/sub_01';

%% Plotting the scene table and objects on top
%In each trial, the subject is told to start from a given location on the table
%and pick a target object. The starting location is plotted as a green
%ellipse and the target as a green rectangle. Other objects appear as red
%rectangles wherease the table as a black rectangle
plot_scene_objects(subject_dir,trial_id, plot_scale);

%% Animation
%animate the human trajecory showing arm and object motions and save
%the animation to a video on your disk
video_save_dir = [];
trial_animation(subject_dir,trial_id, plot_scale, video_save_dir)
