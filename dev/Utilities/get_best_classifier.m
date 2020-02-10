
%select the best binary classifier based on total, pos and negative accuracies
function best_classifier = get_best_classifier(total_acc, pos_acc, neg_acc, objects_classifiers)

    [~ , ids_total] = sort(total_acc,'descend');
    [~ , ids_pos] = sort(pos_acc,'descend');
    [~ , ids_neg] = sort(neg_acc,'descend');
    
    intersect_ids = intersect(intersect(ids_neg(1:3) , ids_pos(1:3)), ids_total(1:3));
    
    if isempty(intersect_ids)
        best_id = ids_total(1);
    else
        if length(intersect_ids)==1
            best_id = intersect_ids;
        else
            best_total = total_acc(intersect_ids);
            [~ , max_id] = max(best_total);
            best_id = intersect_ids(max_id);
        end
    end
    
    %use these {} not () TO RETURN A CLASSIFIER STRUCT NOT A CELL
    best_classifier = objects_classifiers{best_id};
    
end
