function n=nInstance(config)
% the function returns the number of instances of the class irrespectively
% of the depth of the inheritance hiraky the function has been called;
% which always returns the number of instances for basic class
%
% >> n= nInstance(config) where config is the config class or a class
%                        derived from this class
%
%
% $Revision$ ($Date$)
%

if strcmp(class(config),'config')
    n = config.nInstances;
else % iterate untill reached the topmost basic class config;
    names=fieldnames(config);
    is_config=ismember(names,'config');
    if any(is_config)
        n=config.config.nInstances;        
    else
        is_class= isobject(names);
        n=nInstance(config.(names{is_class}));
    end
end