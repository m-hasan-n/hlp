
function [pred_acc, pos_acc, neg_acc, trained_classifiers] = train_binary_classifier...
    (object_features,object_response, balancing_flag,adjust_type,nfold,train_ratio, classifier_type)


pos_data = object_features(object_response==1,:);
neg_data = object_features(object_response==0,:);

% if balancing_flag==1
%     
%     %Balancing
%     if strcmp(category_to_balance,'NEG')
% %         data_rep = repmat(neg_data,round(size(pos_data,1)/size(neg_data,1)),1);
%         data_rep = increase_group_samples(neg_data,size(pos_data,1));
%         balanced_features = [pos_data ; data_rep];
%         balanced_reponse = [ones(size(pos_data,1),1) ; zeros(size(data_rep,1),1)];
%     else
% %         data_rep = repmat(pos_data,round(size(neg_data,1)/size(pos_data,1)),1);
%         data_rep = increase_group_samples(pos_data,size(neg_data,1));
%         balanced_features = [ data_rep; neg_data ];
%         balanced_reponse = [ones(size(data_rep,1),1) ; zeros(size(neg_data,1),1)];
%     end
%         
%     pos_data = balanced_features(balanced_reponse==1,:);
%     neg_data = balanced_features(balanced_reponse==0,:);
% end

if balancing_flag==1
    [pos_data, neg_data] = adjust_class_size(pos_data,neg_data,adjust_type);
end
%Training and testing
n_pos = size(pos_data,1);
n_neg = size(neg_data,1);

%Testing
pred_acc_arr = zeros(nfold,1);
pos_acc_arr = zeros(nfold,1);
neg_acc_arr = zeros(nfold,1);
trained_classifiers = cell(nfold,1);

for ii = 1 : nfold
    
    pos_train_ids = randsample(1:n_pos,round(train_ratio*n_pos));
    pos_test_ids = setdiff(1:n_pos,pos_train_ids);
    
    neg_train_ids = randsample(1:n_neg,round(train_ratio*n_neg));
    neg_test_ids = setdiff(1:n_neg,neg_train_ids);
    
    train_data = [pos_data(pos_train_ids,:);neg_data(neg_train_ids,:)];
    train_resp = [ones(length(pos_train_ids),1) ; zeros(length(neg_train_ids),1)];
    
    test_data = [pos_data(pos_test_ids,:);neg_data(neg_test_ids,:)];
    test_resp = [ones(length(pos_test_ids),1) ; zeros(length(neg_test_ids),1)];
    
    if strcmp(classifier_type,'LDA')
        Mdl = fitcdiscr(train_data,train_resp,'discrimType','pseudoLinear');
    elseif strcmp(classifier_type,'SVM_LINEAR')
        Mdl = fitcsvm(train_data,train_resp);
    elseif strcmp(classifier_type,'SVM_GAUSS')
        Mdl = fitcsvm(train_data,train_resp,'KernelFunction', 'gaussian',...
            'KernelScale', 0.25, 'BoxConstraint', 1, 'Standardize', true); 
    elseif strcmp(classifier_type,'SVM_GAUSS_MED')
        Mdl = fitcsvm(train_data,train_resp,'KernelFunction', 'gaussian', ...
                'PolynomialOrder', [],  'KernelScale', 5.2, 'BoxConstraint', 1, 'Standardize', true);
    elseif strcmp(classifier_type,'ENS_BAG_TREE')
        template = templateTree('MaxNumSplits', size(train_data,1));
        Mdl = fitcensemble(train_data, train_resp, 'Method', 'Bag', ...
                                        'NumLearningCycles', 30, 'Learners', template);
    elseif strcmp(classifier_type,'LOG_REG')
        Mdl = fitglm(train_data, train_resp, 'Distribution', 'binomial', 'link', 'logit');
    end
    
    % Predict on test data
    pred_class = predict(Mdl,test_data);
  
    %evaluate prediction
    pred_eval = pred_class==test_resp;
    pred_acc_arr(ii) =  sum(pred_eval)/length(test_resp);
    
    %positive and negative accuracy
    pos_eval = pred_eval(1:length(pos_test_ids));
    pos_acc_arr(ii) =  sum(pos_eval)/length(pos_eval);
    neg_eval = pred_eval(length(pos_test_ids)+1:end);
    neg_acc_arr(ii) =  sum(neg_eval)/length(neg_eval);
    trained_classifiers{ii} = Mdl;
end

pred_acc = pred_acc_arr;%sum(pred_acc_arr)/nfold;
pos_acc = pos_acc_arr;%sum(pos_acc_arr)/nfold;
neg_acc = neg_acc_arr;%sum(neg_acc_arr)/nfold;





