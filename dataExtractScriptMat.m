 %script to analyze and save data on Onset coefficients
clear;
addpath('Pohl_method/');
addpath('Pohl_method/subdir/');

%enter filepath, folders separated by commas
dataset1='BallroomData';
dataset2='LMD-subset_beg';
dataset3='LMD-fullset_mid';


try
    delete('Pohl_method/normalize.mat');
catch err
end

curDataset=dataset1;

subdirs = dir(fullfile('./','Pohl_method','audio', curDataset));

numDirs = size(subdirs,1);

rowOff=1;
colOff=0;
outfile = 'Pohl_method/data/data.mat';

[OPs, ~, params,~] = pohl_main('Pohl_method/dummy.wav',true, false);
[fSize,pSize]=size(OPs);

genres = {};

%only keep first freq bin
dirNum=0;
OPs = [];
OCs =[];
OP_DFTs=[];
name=[];
for i=(1:numDirs),
    
    curDir = subdirs(i).name;
    
    if subdirs(i).isdir && ~strcmp(curDir, '.') && ~strcmp(curDir,'..'),
        dirNum = dirNum +1;
        matfiles = subdir(fullfile('./','Pohl_method','audio',...
        curDataset,curDir, '*.wav'));
        
        
        tracks = size(matfiles,1);
        %tracks = 1;
        if tracks >size(matfiles,1);
            tracks = size(matfiles,1);
        end
        for j=1:tracks,
            %get data
            try
                [OP, OC, ~,OP_DFT] = ...
                    pohl_main(matfiles(j).name,true, false);
            catch err,
                continue;
            end
            name =[name; matfiles(j).name(end-10:end)];
            genres = [genres;curDir(1:3)];
            OP = OP(:)';
            OPs = [OPs;OP];
            
            OP_DFT=OP_DFT(:)';
            OP_DFTs=[OP_DFTs;OP_DFT];
            
            OCs = [OCs; OC'];

            display([curDir '-' num2str(j)]);

        end
    end
end

%OCs = OCs';

save(outfile, 'genres', 'OPs', 'params', 'OCs','OP_DFTs', 'name');

