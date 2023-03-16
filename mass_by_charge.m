% Возвращает массу элемента по его заряду

function m = mass_by_charge(q)
    switch q
        case 8
            m = 16;  %  замена 8 на 16
        case 11
            m = 23;  %  замена 11 на 23 и так далее
        otherwise
            m = q;  %  иначе, массе присваивается значение заряда
    end
end