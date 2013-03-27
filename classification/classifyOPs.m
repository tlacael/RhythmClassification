%script finds classifies by genre
avg=true;


filename =  ('Pohl_method/data/data.mat');

data = open(filename);



%OPs
OPs = data.OPs;


genres = data.genres;

kloss=0;

[n,m] = size(OPs);
 

%one pass
if ~avg
    disp('creating model');
    genreClassify = ClassificationKNN.fit(OPs, genres);
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
min=1;
if avg
    times=32;
    for i=1:times,
        genreClassify = ClassificationKNN.fit(OPs, genres);

        cp = cvpartition(genres,'k',10);



        cval = crossval(genreClassify, 'cvpartition', cp);

        kloss = kloss+kfoldLoss(cval);
        if min > kfoldLoss(cval);
            min=kfoldLoss(cval);
        end
    end
    kloss = kloss/times;    
    disp('results averaged over 32 passes');
end


disp(data.params.onset);
disp(data.params.period);
disp('Percent classified correctly: ');
disp((1-kloss)*100);
disp('Max: ');
disp((1-min)*100);
