 
function line_orient = line_orientation_discrete(trajectory_segment)

mode_sign_x = sign(trajectory_segment(end,1) - trajectory_segment(1,1));
mode_sign_y = sign(trajectory_segment(end,2) - trajectory_segment(1,2));



% diff_x = diff(trajectory_segment(:,1));
% diff_y = diff(trajectory_segment(:,2));
% 
% sign_x = sign(diff_x);
% sign_y = sign(diff_y);
% 
% mode_sign_x = mode(sign_x);
% mode_sign_y = mode(sign_y);
line_orient=[];

line_orientations = ["FF" ; "FR";"RR"; "BR"; "BB";"BL";"LL";"FL"];
if     mode_sign_x==0 && mode_sign_y==1
    line_orient = line_orientations(1,:); %'FF'
elseif mode_sign_x==1 && mode_sign_y==1
    line_orient = line_orientations(2,:); %'FR'
elseif mode_sign_x==1 && mode_sign_y==0
    line_orient = line_orientations(3,:); %'RR'
elseif mode_sign_x==1 && mode_sign_y==-1
    line_orient = line_orientations(4,:); %'BR'
elseif mode_sign_x==0 && mode_sign_y==-1
    line_orient = line_orientations(5,:); %'BB'
elseif mode_sign_x==-1 && mode_sign_y==-1
    line_orient = line_orientations(6,:); %'BL'
elseif mode_sign_x==-1 && mode_sign_y==0
    line_orient = line_orientations(7,:); %'LL'
elseif mode_sign_x==-1 && mode_sign_y==1
    line_orient = line_orientations(8,:); %'FL'
end

if isempty(line_orient)
    x=0;
end


