
%to find overlap between two parallel lines
function line_overlap = lines_overlap(S1,E1,S2,E2)

line_overlap = zeros(size(S1,1),1);

for ii = 1 : size(S1,1)
    %if S2 inside the line S1E1
    if S2(ii) >= S1(ii) && S2(ii) <= E1(ii)
        line_overlap(ii) = min(E1(ii),E2(ii)) - S2(ii);
    else
        %if S1 is inside the line S2E2
        if S1(ii) >= S2(ii) && S1(ii) <= E2(ii)
            line_overlap(ii) = min(E1(ii),E2(ii)) - S1(ii);
        else
            %if no overlap
            line_overlap(ii) = 0;
        end
    end
end

    