%  Возвращает новое имя файла

function new_name = replacing_names(old_name)
    M = {'w3_1',    'w3_1r';
         'w3_1a',   'w3_1l';
         'w3_2',    'w3_2r';
         'w3_2a',   'w3_2b';
         'w3_3',    'w3_3r';
         'w3_3a',   'w3_3r';
         'w3_4',    'w3_4r';
         'w3_4a',   'w3_4rab';

         'w4_1',    'w4_1r';
         'w4_1a',   'w4_1l';
         'w4_1b',   'w4_1b';
         'w4_2',    'w4_2r';
         'w4_2a',   'w4_2l';
         'w4_2b',   'w4_2b';
         'w4_3',    'w4_3r'
         'w4_3a',   'w4_3ab'

         'w5_1',    'w5_1r';
         'w5_1a',   'w5_1l';
         'w5_2',    'w5_2r';
         'w5_2a',   'w5_2l';
         'w5_2b',   'w5_2b';
         'w5_3',    'w5_3r';
         'w5_3a',   'w5_3ab';

         'w6_2', 'w6_2d';
         'w6_2a', 'w6_2l';
         'w6_2b', 'w6_2dl';
         'w6_2c', 'w6_2b';

         'w7_2ringa', 'w7_2d';
         'w7_2ringb', 'w7_2ll';
         'w7_2ringc', 'w7_2l';
         'w7_2ringd', 'w7_2lh';
         'w7_2ringe', 'w7_2b'};
    keySet = {M{:, 1}};
    valueSet = {M{:, 2}};
    map = containers.Map(keySet, valueSet);
    new_name = map(old_name);
end