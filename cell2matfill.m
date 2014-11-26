function a = cell2matfill(c, empty)
%CELL2MATFILL Converts a cell array to a matrix filling in empty cells
%
% a = cell2matfill(c, empty)
%
% Input variables:
%
%   c:      cell array, where each cell holds either a numeric scalar or
%           empty array 
%
%   empty:  value used to replace empty arrays
%
% Output variables:
%
%   a:      numeric array, same size as c

% Copyright 2008 Kelly Kearney


isnum = cellfun(@(x) isscalar(x) && isnumeric(x), c);
isemp = cellfun(@isempty, c);

if ~all(isnum | isemp)
    error('All cell contents must be either numeric scalars or empty arrays');
end

if ~isnumeric(empty) || ~isscalar(empty)
    error('Fill value must be a numeric scalar');
end

a = ones(size(c)) * empty;

a(~isemp) = [c{~isemp}];




