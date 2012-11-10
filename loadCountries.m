function data = loadCountries()

    fid = fopen('data/countries.txt','r');
   
    csv = textscan(fid,'%s','delimiter','\n');
    
    data = csv{1};
    
    fclose(fid);

end