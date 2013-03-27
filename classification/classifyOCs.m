%script finds classifies by genre
avg=false;

addpath('Pohl_method/utilities/');

filename =  ('Pohl_method/data/data.mat');

data = load(filename);

diagonal=0;


%OCs
OCs = data.OCs;
%OPs = data.OPs;

[numInstances,~]=size(OCs);



m=data.params.period.pCoeff*data.params.period.fCoeff;

diags=zeros(numInstances,m);
OPsOC=zeros(numInstances,m);

if diagonal,
    for i=1:numInstances,
        temp=reshape(OCs(i,m+1:end),m,m);
        diags(i,:) = diag(temp);
        %temp=reshape(OPs(i,:),38,25);
        %temp=dct2(temp);
        %%temp = temp(1:data.params.period.fCoeff,1:data.params.period.pCoeff);
        %OPsOC(i,:)=temp(:);
        
    end
    OCs=[OCs(:,1:m) diags];
    %OCs = OPsOC;
end

genres = data.genres;

kloss=0;

[n,m] = size(OCs);

%normalization
%OPs = OPs./repmat(max(OPs,[],2),1,m);
%temp = (OPs - repmat(min(temp,[],1),n,1));
%OPs = temp./repmat(max(temp,[],1),n,1);


%standardization
%OPs = OPs - repmat(mean(OPs),n,1);
%OPs = OPs./repmat(std(OPs),n,1);

%one pass
if ~avg
    disp('creating model');
    genreClassify = ClassificationKNN.fit(OCs, genres);
    disp('Pertition');
    cp = cvpartition(genres,'k',10);
    
    genreClassify.Distance = @jsd;
    disp('create kfolds');
    cval = crossval(genreClassify, 'cvpartition', cp);
    disp('calcualte loss');
    kloss = kfoldLoss(cval);
    
    disp(filename);
    disp('Results for one pass:');
end

%Average over 32 passes
min=1;
if avg
    for i=1:32,
        genreClassify = ClassificationKNN.fit(OCs, genres);
        %genreClassify.Distance = @jsd;

        cp = cvpartition(genres,'k',10);

        cval = crossval(genreClassify, 'cvpartition', cp);

        kloss = kloss+kfoldLoss(cval);
        if min > kloss;
            min=kloss;
        end
    end
    kloss = kloss/32;    
    disp('results averaged over 32 passes');
end


disp(data.params.onset);
disp(data.params.period);
disp('Percent classified correctly: ');
disp((1-kloss)*100);
disp('Max: ');
disp((1-min)*100);
