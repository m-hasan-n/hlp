
function [ out_classifier] = train_multiClass_classifier(feats,resps, nfold,train_ratio,balancing_flag)

% %out_conf_mat,

%resp_array = table2array(resps);
resp_array = resps;

%how many unique classes
unique_classes = unique(resp_array);
n_classes = size(unique_classes,1);
string_response_flag = 0;

if isstring(resp_array) && (balancing_flag==1)
    string_response_flag = 1;
    old_resp_array=resp_array;
    old_unique_classes =unique_classes ;
    unique_classes = 1:n_classes;
    resp_array=zeros(size(old_resp_array));
    for ii = 1 : n_classes
        resp_array(old_resp_array==old_unique_classes(ii))=ii;
    end
end



%what is the size of each class
class_size = zeros(n_classes,1);
for ii = 1:n_classes
    class_size(ii) = sum(resp_array==unique_classes(ii));
end

%what is the max size
[maxS , imax] = max(class_size);


%Balancing
if balancing_flag==1
    
    %Initialize with the clas of max size
    class_resp = unique_classes(imax);
    class_feat = feats(resp_array == class_resp,:);
    
    all_feat=class_feat;
    all_resp = class_resp*ones(maxS,1);

    %increase size of other classes
    for ii = 1:n_classes
        if ii~=imax
            class_resp = unique_classes(ii);
            class_feat = feats(resp_array == class_resp,:);
            class_feat_increased = increase_group_samples(class_feat,maxS);
            class_resp_increased = class_resp*ones(maxS,1);    
            all_feat =[all_feat;class_feat_increased];
            all_resp = [all_resp;class_resp_increased];
        end
    end
    
    feats = all_feat;
%     resps = num2str(all_resp);
    resps = all_resp;
    
    if string_response_flag==1
        new_resps = strings(size(resps));
        for ii = 1 : n_classes
            new_resps(resps==ii)=old_unique_classes(ii);
        end
        resps = new_resps;
    end
end


%Train and Test Cross Validation
% pred_acc = 0;

% conf_mat = zeros(n_classes,n_classes,nfold);
pred_acc = zeros(nfold,1);
trained_models = cell(nfold,1);
n_samples = size(feats,1);

for ii = 1 : nfold
    n_train_samples = round(train_ratio*n_samples );
    
    train_samples = randsample(1:n_samples,n_train_samples);
    test_samples = setdiff(1:n_samples,train_samples);
    
    train_data = feats(train_samples,:);
    train_resp = resps(train_samples,:);
    
    test_data = feats(test_samples,:);
    test_resp = resps(test_samples,:);
    
    %train
    trained_models{ii} = fitcecoc(train_data, train_resp); 

    %test
    lbl = predict(trained_models{ii} , test_data); %,'Verbose',1  [label,NegLoss,PBScore,Posterior]
%     kk = find(strcmp(lbl,test_resp));
%     p_a = length(kk)/length(lbl);
%     pred_acc = pred_acc + p_a;
    

%     conf_mat(:,:,ii) = confusionmat(test_resp,lbl,...
%         'Order',{'FF','BB','LL','RR','FR','FL','BR','BL'});%{'FF','FR','FL','RR','LL','BB','BR','BL'}); 
    
    pred_acc(ii) =  sum(strcmp(lbl,test_resp))/length(lbl);
    
%     avg_conf_mat = avg_conf_mat + confusionmat(test_resp,lbl,...
%         'Order',{'FF','RR','LL','BB'}); 
    
%     avg_conf_mat = avg_conf_mat + confusionmat(test_resp,lbl);
%     avg_conf_mat = avg_conf_mat + confusionmat(test_resp,lbl, 'Order',{'0','1','2','3'});

end

%select the best fold
[~ , id_max] = max(pred_acc);
% out_conf_mat = conf_mat(:,:,id_max);
out_classifier = trained_models{id_max};


