function confidences = test_boosted_dt_mc(classifier, features)
% confidences = test_boosted_dt_mc(classifier, features)
% returns a log likelihod ratio for each class in the classifier    
% confidences(ndata, nclasses)

tempvar = classifier.wcs(1).dt;
if numel(tempvar)==1
    tempvar = tempvar.npred;
else
    tempvar = tempvar(1).npred;
end
if size(features, 2)~=tempvar
    error('Incorrect number of attributes')
end

wcs = classifier.wcs;  
nclasses = size(wcs, 2);

ntrees = size(wcs, 1);

confidences = zeros(size(features, 1), nclasses);
for c = 1:nclasses    
    for t = 1:ntrees        
        if ~isempty(wcs(t,c).dt)            
            dt = wcs(t,c).dt;
            dt_children = dt.children;
            dt_catsplit = dt.catsplit;
            nodes = treevalc(int32(dt.var), dt.cut, int32(dt_children(:, 1)), ...
                    int32(dt_children(:, 2)), dt_catsplit(:, 1), features');  
            %[class_indices, nodes2, classes] = treeval(wcs(t, c).dt, features);        
            %         if sum(nodes~=nodes2)>0
            %              disp('error')
            % %              disp(num2str([nodes nodes2]))            
            %         end
            confidences(:, c) = confidences(:, c) + wcs(t, c).confidences(nodes);
        end        
    end
    confidences(:, c) = confidences(:, c) + classifier.h0(c);
end

   