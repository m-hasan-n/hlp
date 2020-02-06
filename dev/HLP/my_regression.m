

function trained_models = my_regression(data_in,data_out,n_fold,train_ratio)

%how many data points
n_data = size(data_in,1);

%how many outputs
n_outputs = size(data_out,2);

%iterate on outputs
for ind_out = 1 : n_outputs
    
    %intialize for each output
    gprMdls = cell(n_fold,1);
    pred_rmse = zeros(n_fold,1);
%     figure(ind_out)
    for ii = 1 : n_fold
        train_ids = randsample(1:n_data,round(train_ratio*n_data));
        test_ids = setdiff(1:n_data, train_ids);
        
        train_features = data_in(train_ids,:) ;
        test_features = data_in(test_ids,:);
        train_response = data_out(train_ids,ind_out);
        test_response = data_out(test_ids,ind_out);
        
        gprMdls{ii} = fitrgp(train_features, train_response);
        
        pred_out = predict(gprMdls{ii} , test_features);
        
        ids_nan = find(isnan(pred_out));
        pred_out(ids_nan)=[];
        
        test_response(ids_nan)=[];
        
%                 subplot(n_fold,1,ii)
%                 plot(test_response)
%                 hold on
%                 plot(pred_out)
        
        pred_rmse(ii) = (mean((pred_out - test_response).^2))^0.5;
    
    end
    
    %select the best model
    [~, id_min] = min(pred_rmse);
    trained_models(ind_out).mdl = gprMdls{id_min};


end

