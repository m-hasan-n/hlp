function ang_12 = line_angles(lin1_pnts,lin2_pnts)
%line_points = [x1 y1;x2 y2];
lin1 =  lin1_pnts(2,:) - lin1_pnts(1,:);
lin2 =  lin2_pnts(2,:) - lin2_pnts(1,:);

lin1_abs = sum(lin1.^2)^0.5;
lin2_abs = sum(lin2.^2)^0.5;

ang_12 = acos(sum(lin1.*lin2) / (lin1_abs*lin2_abs));
