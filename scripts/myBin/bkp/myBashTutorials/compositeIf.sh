my_error_flag=1
my_error_flag_o=1
if [ $my_error_flag -eq 1 ] &&  [ $my_error_flag_o -eq 2 ]; then
      echo "$my_error_flag"
else
    echo "no flag"
fi
