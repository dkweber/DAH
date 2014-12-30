set encoding iso_8859_1
# A4 is 8.3 x 11.7 in
set terminal postscript eps enhanced color size 3.5in,3in 'Helvetica, 12'
set output 'example_xy.eps'
set style fill solid 1 border rgb 'black'
set boxwidth 15
set style line 1 lc rgb '#A80000'
set xrange [-180:180]
set xtics 15 rotate by 270
set xlabel 'Dihedral Bin'
set ylabel 'Frequency'
plot 'example_xy.dat' u ($1+7.5):2 w boxes ls 1 notitle

