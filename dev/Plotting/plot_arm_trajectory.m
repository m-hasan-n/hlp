

function plot_arm_trajectory(hand_trajectory_xy, elbow_trajectory_xy,shoulder_trajectory_xy,neck_trajectory_xy,trajectory_time_stamp,writerObj)


%time taken between each movement    
delay_time = diff(trajectory_time_stamp);
if ~isempty(delay_time)
    delay_time(end+1)=delay_time(end);
else
    delay_time = 0.01;
end
    
%iterate over all movements
for ii = 1 :  size(hand_trajectory_xy,1) %20:
    hold on
   
    h1 = plot(neck_trajectory_xy(ii,1) , neck_trajectory_xy(ii,2),'m s','LineWidth',5);
    h2 = plot(shoulder_trajectory_xy(ii,1) , shoulder_trajectory_xy(ii,2),'b s','LineWidth',5);
    h3 = plot(elbow_trajectory_xy(ii,1),elbow_trajectory_xy(ii,2),'g s','LineWidth',5);
    h4 = plot(hand_trajectory_xy(ii,1),hand_trajectory_xy(ii,2),'r s','LineWidth',5);
    
    h5 = line([neck_trajectory_xy(ii,1) shoulder_trajectory_xy(ii,1)],[neck_trajectory_xy(ii,2) shoulder_trajectory_xy(ii,2)],'LineWidth',5);
    h6 = line([shoulder_trajectory_xy(ii,1) elbow_trajectory_xy(ii,1)],[shoulder_trajectory_xy(ii,2) elbow_trajectory_xy(ii,2)],'LineWidth',5);
    h7 = line([elbow_trajectory_xy(ii,1) hand_trajectory_xy(ii,1)],[elbow_trajectory_xy(ii,2) hand_trajectory_xy(ii,2)  ],'LineWidth',5);
  
    ff = getframe(gcf) ;
    writeVideo(writerObj, ff);
%     drawnow;
    
%     pause(delay_time(ii))
%     pause(0.005)
    delete(h1); delete(h2); delete(h3); delete(h4)
    delete(h5); delete(h6); delete(h7);
end