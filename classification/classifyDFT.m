%script finds classifies by genre
avg=false;



filename =  ('Pohl_method/data/data.mat');

%filename =  ('Latin-Rhythms/data/LMD/data_DFT.mat');
%filename = ('normalNormed.mat');
data = open(filename);

%FPs
%OPs = data.FPs;
%OPs
DFTs = (data.OP_DFTs);%Cs(:,1:25);
%OPs = reshape(OPs,698,950);data_DFTCov

% reduce with PCA
disp('Performing PCA');
DFTsPCA = pca1(DFTs);
DFTs = DFTsPCA(:,1:300);

genres = data.genres;

kloss=0;

%[n,m] = size(OPs);
%OPs = OPs./repmat(max(OPs,[],2),1,m);
%OPs = OPs./repmat(max(OPs,[],1),n,1);


%one pass
if ~avg
    disp('creating model');
    genreClassify = ClassificationKNN.fit(DFTs, genres);
    disp('Pertition');
    cp = cvpartition(genres,'k',10);
    
    %genreClassify.Distance = @jsd;
    disp('create kfolds');
    cval = crossval(genreClassify, 'cvpartition', cp);
    disp('calcualte loss');
    kloss = kfoldLoss(cval);
    
    disp(filename);
    disp('Results for one pass:');
end

%Average over 32 passes
if avg
    times=32;
    for i=1:times,
        genreClassify = ClassificationKNN.fit(OPs, genres);

        cp = cvpartition(genres,'k',10);

        cval = crossval(genreClassify, 'cvpartition', cp);

        kloss = kloss+kfoldLoss(cval);
    end
    kloss = kloss/times;    
    disp('results averaged over 32 passes');
end


disp(data.params.onset);
disp(data.params.period);
disp('Percent classified correctly: ');
disp((1-kloss)*100);


%{
%recreate for cosine distance
cmdl = ClassificationKNN.fit(OPs,genres,'NSMethod','exhaustive',...
    'Distance','cosine');
cmdl.NumNeighbors = 3;
closs = resubLoss(cmdl)


%predict average song
songAvg = mean(OPs);
class = predict(genreClassify, songAvg);

%}