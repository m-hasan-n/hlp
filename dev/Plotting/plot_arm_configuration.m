

function plot_arm_configuration(neck_joint,shoulder_joint,elbow_joint,...
    hand_joint,shoulder_elbow_angles, plot_clr)

%plotting the joint points
pnt_size = 15;
plot(neck_joint(1) , neck_joint(2),'m s','LineWidth',pnt_size);
plot(shoulder_joint(1) , shoulder_joint(2),'y s','LineWidth',pnt_size);
plot(elbow_joint(1),elbow_joint(2),'g s','LineWidth',pnt_size);
plot(hand_joint(1),hand_joint(2),'r s','LineWidth',pnt_size);

%plotting the link lines
lin_size = 8;
line([neck_joint(1) shoulder_joint(1)],[neck_joint(2) shoulder_joint(2)],'LineWidth',lin_size,'Color',plot_clr,'LineStyle','--');
line([shoulder_joint(1) elbow_joint(1)],[shoulder_joint(2) elbow_joint(2)],'LineWidth',lin_size,'Color',plot_clr,'LineStyle','--');
line([elbow_joint(1) hand_joint(1)],[elbow_joint(2) hand_joint(2)  ],'LineWidth',lin_size,'Color',plot_clr,'LineStyle','--');

%display the angles
text(shoulder_joint(1),shoulder_joint(2),num2str(shoulder_elbow_angles(1)*180/pi),'FontSize',15);
text(elbow_joint(1),elbow_joint(2),num2str(shoulder_elbow_angles(2)*180/pi),'FontSize',15);

