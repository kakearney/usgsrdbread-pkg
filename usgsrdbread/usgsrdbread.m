function Data = usgsrdbread(file)
%USGSRDBREAD Read USGS tab-delimited water data file
%
% Data = usgsrdbread(file)
%
% Input variables:
%
%   file:   name of USGS .rdb file
%
% Output variables:
%
%   Data:   dataset array of file data

% Copyright 2013 Kelly Kearney

if ~exist(file, 'file')
    error('File not found');
end

fid = fopen(file);
count = 0;
while 1
    ln = fgetl(fid);
    if strncmp(ln, '#', 1);
        count = count + 1;
    else
        header1 = ln;
        if strncmp(header1, 'No sites/data', 13)
            error('USGSRDB:nodata', 'File contains no data');
        end
        header2 = fgetl(fid);
        break
    end
end
fclose(fid);

cols = textscan(header1, '%s', 'delimiter', '\t');
cols = cols{1};
fmt = textscan(header2, '%s', 'delimiter', '\t');
fmt = fmt{1};

% Fields are sometimes left blank, so can't read straight into dataset
% array or use textscan directly

fid = fopen(file);
tmp = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

comments = tmp{1}(1:count);
data = regexp(tmp{1}(count+3:end), '\t', 'split');
data = cat(1, data{:});

% Parse data

isnum = regexpfound(fmt, 'n');
for ii = find(isnum)'
    data(:,ii) = cellfun(@str2num, data(:,ii), 'uni', 0);
end

Data = dataset({data, cols{:}});
vname = get(Data, 'VarNames'); % May be different than cols if modified
for ii = find(isnum)'
    Data.(vname{ii}) = cell2matfill(Data.(vname{ii}), NaN);
end

% Parse comments to get column descriptions (timeseries files only)

idx1 = find(regexpfound(comments, '# Data provided'));
if isempty(idx1)
    return
end
idx2 = regexpfound(comments, '#\s*$');
idx2(1:idx1) = 0;
idx2 = find(idx2, 1);
codes = comments((idx1+2):(idx2-1));
pattern = comments{idx1+1};
pattern = regexprep(pattern, {'DD\s+','parameter\s+','statistic\s+','Description'}, ...
    {'(\\d+)\\s*','(\\d+)\\s*','(\\d+)\\s*','(.*)'});

desc = regexp(codes, pattern, 'tokens', 'once');
desc = cat(1, desc{:});
vardescrip = cell(size(cols));
[vardescrip{:}] = deal('');
for ii = 1:size(desc,1)
    str = sprintf('%s_', desc{ii,1:end-1});
    str = str(1:end-1);
    idx = find(strcmp(str, cols));
    vardescrip{idx} = desc{ii,end};
end

% Build dataset array

Data.Properties.VarDescription = vardescrip;
    
     

