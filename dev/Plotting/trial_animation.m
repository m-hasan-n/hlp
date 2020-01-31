
%Animate a trial showing the motion of human arm and objects 
%the animation is also saved to a video named human_demo_'trial_name'

%Inputs:
%subject_dir: directory of all trials for a subject
%trial_id: id of the required trial 
%plot_scale: scale for matlab plot
%video_dir: directory to save the animation video

function trial_animation(subject_dir,trial_id, plot_scale, video_dir)


close all

%% Create Matlab video-writer object
%path to the trial
trial_name = ['T' sprintf('%03d',trial_id)];
trial_path = fullfile(subject_dir,trial_name);

delay_time=0.3;
number_frames=30;
fname = fullfile(video_dir, ['human_demo_'  trial_name]);
writerObj = VideoWriter(fname);
writerObj.FrameRate = 30;
% open the video writer
open(writerObj);


%% plot the scene without trajectory
[scene_objects,object_rectangle_handles] = plot_scene_objects(subject_dir,...
    trial_id, plot_scale);
h1 = text(-1,3,'Training Scene','FontSize',30);

for ii = 1 :number_frames
    ff = getframe(gcf) ;
    writeVideo(writerObj, ff);
    pause(delay_time/number_frames)
end

%% find and plot gaps
[~,table_obj , ~, ~, object_depth]= scene_geometry_info;
scene_objects_array = table2array(scene_objects(:,[2 4 5 7]));
obj_rect_cent_format = scene_objects_array(2:end,:);

[gap_rectangles, ~, ~] = find_gabs_bet_objects...
    (obj_rect_cent_format,table_obj.edges,object_depth);

for ii = 1  : size(gap_rectangles,1)
    rectangle('Position', 10*gap_rectangles(ii,:),'LineWidth',6,...
        'EdgeColor','b', 'LineStyle','--');
    X = gap_rectangles(ii,1)+gap_rectangles(ii,3)/2;
    Y = gap_rectangles(ii,2)+gap_rectangles(ii,4)/2;
    text(10*X-0.1,10*Y,['G' num2str(ii)],'FontSize',20,'Color','b')
end

%% plot objects
obj_rect_bl_format = to_matlab_rectangles(obj_rect_cent_format);
for ii = 1  : size(obj_rect_bl_format,1)
    rectangle('Position', 10*obj_rect_bl_format(ii,:),'LineWidth',6,'EdgeColor','r', 'LineStyle','--');
    text(10*obj_rect_cent_format(ii,1)-0.1,10*obj_rect_cent_format(ii,2),['O' num2str(ii)],'FontSize',20,'Color','r')
end
delete(h1);
h1 = text(-1,3,'Objects and Gaps','FontSize',30);


for ii = 1 :number_frames
    ff = getframe(gcf) ;
    writeVideo(writerObj, ff);
    pause(delay_time/number_frames)
end

%% Human Trajectory
delete(h1);
h1 = text(-1,3,'Human Trajectory','FontSize',30);

%interaction log file
%5 columns: start_time, end_time, dominant_object, 
% non_dominant_object, interaction_type
interaction_log = readtable(fullfile(trial_path,...
    ['movement/interaction_log_' trial_name '.csv']));
interaction_type = table2cell(interaction_log(:,5));

%find when picking or pushing happens 
pick_ids = find(strcmp(interaction_type,'PickedUp'));
push_ids = find(strcmp(interaction_type,'Pushed'));
pick_push_ids = sort([pick_ids; push_ids]);
pick_push_info = interaction_log(pick_push_ids,:);


%Hand, elbow and shoulder joints trajectories and timestamps
hand_trajectory_info = readtable(fullfile(trial_path,...
    ['movement/HandTracker_movement_' trial_name '.csv']));
hand_trajectory_timestamp = table2array(hand_trajectory_info(:,1));
hand_trajectory_xy = plot_scale*table2array(hand_trajectory_info(:,[2 4]));

elbow_trajectory_info = readtable(fullfile(trial_path,...
    ['movement/ElbowTracker_movement_' trial_name '.csv']));
% elbow_trajectory_timestamp = table2array(elbow_trajectory_info(:,1));
elbow_trajectory_xy = plot_scale*table2array(elbow_trajectory_info(:,[2 4]));

shoulder_trajectory_info = readtable(fullfile(trial_path,...
    ['movement/ShoulderTracker_movement_' trial_name '.csv']));
%     shoulder_trajectory_timestamp = table2array(shoulder_trajectory_info(:,1));
shoulder_trajectory_xy = plot_scale*table2array(shoulder_trajectory_info(:,[2 4]));

%estimated trajectory of the neck joint 
shoulder_elbow_link = (sum((shoulder_trajectory_xy(1,:) -elbow_trajectory_xy(1,:)).^2))^0.5;
neck_x = shoulder_trajectory_xy(:,1)- shoulder_elbow_link;
neck_y = shoulder_trajectory_xy(:,2);
neck_trajectory_xy = [ neck_x  neck_y];

%% animate the trajectory and objects
animate_trajectory_objects(trial_path,trial_name,pick_push_info,...
    hand_trajectory_timestamp,hand_trajectory_xy,elbow_trajectory_xy,shoulder_trajectory_xy,...
    neck_trajectory_xy,    scene_objects,object_rectangle_handles,plot_scale,writerObj)

%% Print the high-level plan on figure
% text(-3,-4.5,'High-level Plan','FontSize',25)
% line([-3.5 -1.2],[-4.8 -4.8],'Color','black','LineWidth',2)
% text(-3.5,-5,'Keypoint','FontSize',20)
% text(-2.2,-5,'Action','FontSize',20)
% line([-3.5 -1.2],[-5.25 -5.25],'Color','black','LineWidth',2)
% text(-3.2,-5.5,'G2','FontSize',20,'Color','b')
% text(-2,-5.5,'Go','FontSize',20,'Color','b')
% % text(-3.2,-5.5,'O1','FontSize',20,'Color','r')
% % text(-2.5,-5.5,'Move (Right)','FontSize',20,'Color','r')
% text(-3.2,-6,'O6','FontSize',20,'Color','r')
% text(-2.5,-6,'Move (Back Left)','FontSize',20,'Color','r')
% line([-3.5 -1.2],[-6.25 -6.25],'Color','black','LineWidth',2)


for ii = 1 :number_frames
    ff = getframe(gcf) ;
    writeVideo(writerObj, ff);
    pause(delay_time/number_frames)
end
 