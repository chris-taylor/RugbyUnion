function data = loadSuperXVData()

    fname = 'data/superxv.csv';
    fid = fopen(fname);
    
    csv = textscan(fid,'%s %s %s %f %f %f %f %f %f %f %f','headerlines',1,'delimiter',',');
    
    data.date = datenum(csv{1});
    data.home = csv{2};
    data.away = csv{3};
    data.hometries = csv{4};
    data.homepens = csv{5};
    data.homecons = csv{6};
    data.homedrops = csv{7};
    data.awaytries = csv{8};
    data.awaypens = csv{9};
    data.awaycons = csv{10};
    data.awaydrops = csv{11};
    
%     assert(all(data.hometries >= data.homecons))
%     assert(all(data.awaytries >= data.awaycons))

%   Need to explicitly correct some matches??

end