% Проверяет, что время не вышло за границы диапазона по размеру файла

function [t1, t2] = check_t1_t2(t1, t2, T, filename)
    if isa(t2, 'char')
        t2 = T;
    end
    if (t2 > T)
        warning('\t%s\n%s\n%s\n%s\n\n', 'Внимание!', ['t2 введено больше (', num2str(t2), '), чем записано (', num2str(T), ') в файле:'], filename, ['t2 присвоено значение ', num2str(T)]);
        t2 = T;
    end
    if (t1 >= t2)
        warning('\t%s\n%s\n%s\n\n', 'Внимание!', ['t1 (', num2str(t1), ') введено больше либо равно, чем t2 (', num2str(t2), ')'], ['t1 присвоено значение ', num2str(1)]);
        t1 = 1;
    end
end