data_dir = '/data/jag/MELA/MelanopsinMR/';

subjNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...
    };

for nn = 1:length(subjNames)
    sessions = listdir(fullfile(data_dir, subjNames{nn}),'dirs');
    for ss = 1:length(sessions)
        session_dir = fullfile(data_dir, subjNames{nn}, sessions{ss});
        clean_up(session_dir)
    end
end