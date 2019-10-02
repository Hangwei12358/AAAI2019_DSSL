ulimit -c unlimited 
 ulimit unlimited 
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 0.01 -k 0.1 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 0.01 -k 1 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 0.01 -k 10 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 0.01 -k 100 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 0.1 -k 0.1 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 0.1 -k 1 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 0.1 -k 10 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 0.1 -k 100 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 1 -k 0.1 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 1 -k 1 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 1 -k 10 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 1 -k 100 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 10 -k 0.1 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 10 -k 1 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 10 -k 10 data_semi.all data_semi_all.model&
./smm-getKernelMatrix -f 0 -i 0 -t 2 -l 2 -g 10 -k 100 data_semi.all data_semi_all.model&
wait
