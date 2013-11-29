function [success,message]=set_key_value(config_file,keys,values)
% function looks through the mslice configuration file and tries to replace
% pairs of keys it founds by its values
%
% parameters:
% config_file -- full path to the configuration file
% keys        -- cell-arry of strings treated as keys
% values      -- cell-array of strings treated as values
% 
% retuns
% success -- 1 if success or 0 if faluer. 
% message --   the message which explain the reason for failure
%
if ~iscell(keys)
    keys = cellstr(keys);
end
if ~iscell(values)
    numbers = arrayfun(@(x) isnumeric(x), values);
    if any(numbers)
        svalues(numbers) = num2str(values(numbers));
    else
        svalues = values;
    end
    
    values = cellstr(svalues);
end

if numel(keys) ~= numel(values)
    error('MSLICE:set_key_value',' number of values  does not corresponds to the number of keys to set');       
end

if ~exist(config_file,'file')
    success = 0;
    message = 'can not find file '+config_file;
    return 
end


[fh,mes] = fopen(config_file,'r+');

if fh<0
    success = fh;
    message = ' can not open file: '+config_file+'\n';
    message = message+' system error message: '+mes;
    return
end

keywal = textscan(fh,'%s','delimiter','\n');
fclose(fh);

numbers = cellfun(@(x) isnumeric(x), values);
if any(numbers)
    values{numbers} = num2str(values{numbers});
end

key_val_delimiter = '=';
key_val_framing = ' '; % need key-val fraiming as we use split over spaces (it is just easier to do)

[dict_keys,dict_vals] = parse_dictionary(keywal{1},key_val_delimiter);

keys_notin_dict = ~ismember(keys,dict_keys);
if any(keys_notin_dict)
    disp([' found input keys to change which are not in the dictionary: ' config_file])
    cellfun( @(x) fprintf(' unknown key: %s \n',x),keys(keys_notin_dict));
    error('MSLICE:set_key_value',' invalid argument');       
end

% replace existing key-value pairs.
val_to_replace = ismember(dict_keys,keys);
% define cell function which will replace the key with correspondent value
fc = @(theKey)val_replacement(theKey,keys,values);
dict_vals(val_to_replace) = cellfun(fc,dict_keys(val_to_replace));

% write changed dictionary into temporary file
[path,name,ext]=fileparts(config_file);
tmp_file = fullfile(path,[name,ext,'.tmp']);
[fh,mes] = fopen(tmp_file,'w+');
if fh<0
    success = fh;
    message = ' can not temporary file: '+tmp_file+'\n';
    message = message+' system error message: '+mes;
end

print_string = @(x,y)print_string_f(x,y,fh,key_val_delimiter,key_val_framing);
cellfun(print_string,dict_keys,dict_vals);

fclose(fh);
% replace the old config file with the new one
movefile(tmp_file,config_file,'f');


function new_val = val_replacement(dict_key,keys,values)
%
newValIndex = ismember(keys,dict_key);
new_val=values(newValIndex);


function prstr=print_string_f(x,y,fh,delim,frame)
%
if x(1) == '#'
    prstr = fprintf(fh,'%s\n',x);
else
    prstr = fprintf(fh,'%-35s%s\n',x,[frame,delim,frame,y]);
end

function [keys,vals] = parse_dictionary(cellstrings,delim)
% function builds key-value dictionary from list of strings provided
%

n_strings = numel(cellstrings);
keys = cell(n_strings,1);
vals = cell(n_strings,1);
for i = 1:n_strings
    string = cellstrings{i};
    if string(1)== '#' % its comment, keep unchanged
        keys{i}=string;
        vals{i}='';
        continue
    end
    sent = regexp(string,'\s+','split');
    keys{i}=sent{1};
    if sent{2} ~= delim
        error('MSLICE:set_key_value',' can not properly understand the string N %d, namely: %s',i,cellstrings{i});
    end
    if numel(sent)==2
        vals{i}='';
    else
        if numel(sent)>3
            vals{i} = sprintf('%s ',sent{3:end});
        else
            vals{i}=sent{3};
        end
    end
end
