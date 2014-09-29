function test_checksum


check_sum = calc_checksum('calc_checksum.m');

assertEqual(int64(2174222323),check_sum);

check_sum = calc_checksum('calc_checksum.m','S');
assertEqual(int64(527462272),check_sum);

end

